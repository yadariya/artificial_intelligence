    % Function, which creates empty N*N lattice. N - the size of the map.
create_empty_map(N, Map) :-
 length(Row, N), maplist(=(0), Row), length(Map, N), maplist(=(Row), Map).

    % Function, which replaces the value in the lattice. X and Y are
    % the coordinates of the cell where we want to put new value, which is NewValue
add_agent(X, Y, Map, NewValue, NewMap):-
    nth0(Y, Map, OldRow, Rest1),
    nth0(Y, NewMap, NewRow, Rest1),
    nth0(X, OldRow, _, Rest2),
    nth0(X, NewRow, NewValue, Rest2).

    % Function for creating a map with actor, home, mask, two covid and doctor
    % infected is zone near covid
    % In this function you can change the position of agents for the backtracking algorithm.
solution(Map_with_agents):-
    create_empty_map(9, Map),
    add_agent(0, 0, Map, actor, NewMap),
    add_agent(7, 5, NewMap, home, NewMap1),
    add_agent(1, 4, NewMap1, mask, NewMap2),
    add_agent(3, 2, NewMap2, covid, NewMap3),
    add_agent(4, 5, NewMap3, covid, NewMap4),
    add_agent(7, 1, NewMap4, doctor, M),
    add_agent(2, 1, M, infected, M1),
    add_agent(3, 1, M1, infected, M2),
    add_agent(4, 1, M2, infected, M3),
    add_agent(2, 2, M3, infected, M4),
    add_agent(2, 3, M4, infected, M5),
    add_agent(3, 3, M5, infected, M6),
    add_agent(4, 3, M6, infected, M7),
    add_agent(4, 2, M7, infected, M8),
    add_agent(3, 4, M8, infected, M9),
    add_agent(4, 4, M9, infected, M10),
    add_agent(5, 4, M10, infected, M11),
    add_agent(5, 5, M11, infected, M12),
    add_agent(5, 6, M12, infected, M13),
    add_agent(4, 6, M13, infected, M14),
    add_agent(3, 6, M14, infected, M15),
    add_agent(3, 5, M15, infected, Map_with_agents).

    % Function, which returns the value of the cell with coordinates X and Y.
get_value(X, Y, OldMap, Value):-
    nth0(Y, OldMap, OldRow),
    nth0(X, OldRow, Value).

    % Function for checking if cell (X, Y) is safe.
    % It returns false if the cell is infected or has covid; true otherwise
is_safe(X, Y, OldMap, Safe) :-
  (get_value(X, Y, OldMap, infected) ->  Safe=false; Safe=true).

  % Function, which returns all adjacent cells of the cell with coordinates X Y
  % Each cell has a maximum of eight cells.
adjacent([X, Y], [X1, Y1]) :-
	X1 is X,
    Y1 is Y+1;
	X1 is X-1,
    Y1 is Y+1;
	X1 is X+1,
    Y1 is Y+1;

	X1 is X,
    Y1 is Y-1;
	X1 is X-1,
    Y1 is Y-1;
	X1 is X+1,
    Y1 is Y-1;

	X1 is X-1,
    Y1 is Y;
	X1 is X+1,
    Y1 is Y.

    % Function, which checks that algorithm doesn't go out of bounds of the lattice.
is_correct_pos(_Map, [X, Y]) :- X >=0, Y >= 0, X =< 8, Y =< 8.

is_suitable(Path):-
    length(Path,L),
    (   L < 11 ->   true; false).

way([X_a,Y_a],[X_h,Y_h],[X_a,Y2]):-
    A is X_h-X_a,
    B is Y_h-Y_a,
    A=0,
    B>0,
    Y2 is Y_a+1,!.

way([X_a,Y_a],[X_h,Y_h],[X2,Y_a]):-
    A is X_h-X_a,
    B is Y_h-Y_a,
    A<0,
    B=0,
    X2 is X_a-1,!.

way([X_a,Y_a],[X_h,Y_h],[X_a,Y2]):-
    A is X_h-X_a,
    B is Y_h-Y_a,
    A=0,
    B<0,
    Y2 is Y_a-1,!.

way([X_a,Y_a],[X_h,Y_h],[X2,Y_a]):-
    A is X_h-X_a,
    B is Y_h-Y_a,
    A>0,
    B=0,
    X2 is X_a+1,!.

way([X_a,Y_a],[X_h,Y_h],[X2,Y2]):-
    A is X_h-X_a,
    B is Y_h-Y_a,
    A>0,
    B>0,
    X2 is X_a+1,
    Y2 is Y_a+1,!.

way([X_a,Y_a],[X_h,Y_h],[X2,Y2]):-
    A is X_h-X_a,
    B is Y_h-Y_a,
    A<0,
    B>0,
    X2 is X_a-1,
    Y2 is Y_a+1,!.

way([X_a,Y_a],[X_h,Y_h],[X2,Y2]):-
    A is X_h-X_a,
    B is Y_h-Y_a,
    A>0,
    B<0,
    X2 is X_a+1,
    Y2 is Y_a-1,!.

way([X_a,Y_a],[X_h,Y_h],[X2,Y2]):-
    A is X_h-X_a,
    B is Y_h-Y_a,
    A<0,
    B<0,
    X2 is X_a-1,
    Y2 is Y_a-1.

    % Function, which returns all possible paths from starting coordinate to home
path(Map, Path, _, X, Y, FinPath):-
	get_value(X, Y, Map, home),
    FinPath =[[X, Y] | Path], !.
path(Map, Path, true, X, Y, FinalPath) :-
    get_value(X_h,Y_h,Map,home),
    way([X, Y], [X_h,Y_h], [X1, Y1]),
    \+ member([X1, Y1], Path),
    is_correct_pos(Map, [X1, Y1]),
    path(Map, [[X, Y] | Path], true, X1, Y1, FinalPath).

path(Map, Path, false, X, Y, FinalPath):-
	adjacent([X, Y], [X1, Y1]),
    \+ member([X1, Y1], Path),
    is_correct_pos(Map, [X1, Y1]),
    is_safe(X1, Y1, Map, true),
    is_suitable(Path),
    (   get_value(X1,Y1, Map, doctor) ->
    		path(Map, [[X, Y] | Path], true, X1, Y1, FinalPath);
    		path(Map, [[X, Y] | Path], false, X1, Y1, FinalPath)
    ).

    % Function, which returns path with minimal length from the set of all
    % possible paths from start to home
minimal_path(List, Y, _Min_lenght, Min_path, Min_path):-
	length(List,Y), !.
minimal_path(List, Y, Min_lenght, Min_path, Fin_path):-
    nth0(Y, List, Array),
    Y1 is Y+1,
    length(List, ListLength),
    Y < ListLength,
    length(Array,L),
    (L < Min_lenght ->
    minimal_path(List,Y1,L,Array,Fin_path);
    minimal_path(List,Y1, Min_lenght, Min_path,Fin_path)).

    % Function, which generates the first map
map1_b():-
  write('Map is:'),
  write('\n'),
  write('0 0 0 0 0 0 0 0 0'),
  write('\n'),
  write('0 0 0 0 0 0 0 0 0'),
  write('\n'),
  write('0 0 0 i i i 0 0 0'),
  write('\n'),
  write('0 0 0 i C i 0 H 0'),
  write('\n'),
  write('0 M 0 i i i 0 0 0'),
  write('\n'),
  write('0 0 i i i 0 0 0 0'),
  write('\n'),
  write('0 0 i C i 0 0 0 0'),
  write('\n'),
  write('0 0 i i i 0 0 D 0'),
  write('\n'),
  write('A 0 0 0 0 0 0 0 0'),
  write('\n'),
  write('Time taken by the backtracking algorithm to reach home is: '),
  bagof(Path, path([[actor, 0, 0, 0, 0, 0, 0, 0, 0],
  [0, 0, infected, infected, infected, 0, 0, doctor, 0],
  [0, 0, infected, covid, infected, 0, 0, 0, 0],
  [0, 0, infected, infected, infected, 0, 0, 0, 0],
  [0, doctor, 0, infected, infected, infected, 0, 0, 0],
  [0, 0, 0, infected, covid, infected, 0, home, 0],
  [0, 0, 0, infected, infected, infected, 0, 0, 0],
  [0, 0, 0, 0, 0, 0, 0, 0, 0],
  [0, 0, 0, 0, 0, 0, 0, 0, 0]],[],false, 0, 0, Path),Bag),
  time(minimal_path(Bag, 0, 13, _, Fin_path)),
  write('The path from right to left is: '),
  write(Fin_path),
  write('\n'),
  write('The lenght of the path is: '),
  length(Fin_path, L),
  write(L).

  % Function, which generates the second map
  map2_b():-
    write('Map is:'),
    write('\n'),
    write('0 0 0 0 0 0 D 0 H'),
    write('\n'),
    write('0 i i i 0 0 0 0 0'),
    write('\n'),
    write('0 i C i 0 0 0 0 0'),
    write('\n'),
    write('0 i i i 0 0 0 0 0'),
    write('\n'),
    write('0 0 0 0 0 i i i 0'),
    write('\n'),
    write('0 0 0 0 0 i C i 0'),
    write('\n'),
    write('0 0 0 0 0 i i i 0'),
    write('\n'),
    write('0 M 0 0 0 0 0 0 0'),
    write('\n'),
    write('A 0 0 0 0 0 0 0 0'),
    write('\n'),
    write('Time taken by the algorithm to reach home is: '),
    bagof(Path, path([[actor, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, doctor, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, infected, infected, infected, 0],
    [0, 0, 0, 0, 0, infected, covid, infected, 0],
    [0, 0, 0, 0, 0, infected, infected, infected, 0],
    [0, infected, infected, infected, 0, 0, 0, 0, 0],
    [0, infected, covid, infected, 0, 0, 0, 0, 0],
    [0, infected, infected, infected, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, doctor, 0, home]],[],false, 0, 0, Path),Bag),
    time(minimal_path(Bag, 0, 13, _, Fin_path)),
    write('The path from right to left is: '),
    write(Fin_path),
    write('\n'),
    write('The lenght of the path is: '),
    length(Fin_path, L),
    write(L).

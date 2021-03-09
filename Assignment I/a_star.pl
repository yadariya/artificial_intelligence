:- dynamic(way/2).
:- dynamic(side/3).

  % Function, which checks that algorithm doesn't go out of bounds of the lattice.
is_correct_pos([X, Y]) :-
  map_size(Size),
  X >= 0,
  Y >= 0,
  X =< Size,
  Y =< Size.

  % Function, which returns all adjacent cells of the cell with coordinates X Y
  % Each cell has a maximum of eight cells.
is_adjacent([X, Y], [X1, Y1]) :-
  ( X1 is X,    Y1 is Y+1;
    X1 is X-1,  Y1 is Y+1;
    X1 is X+1,  Y1 is Y+1;
    X1 is X,    Y1 is Y-1;
    X1 is X-1,  Y1 is Y-1;
    X1 is X+1,  Y1 is Y-1;
    X1 is X-1,  Y1 is Y;
    X1 is X+1,  Y1 is Y
  ),
  is_correct_pos([X1, Y1]).

  % Function for checking if cell (X, Y) is safe.
  % It returns false if the cell is infected or has covid; true otherwise
is_safe(Point, Path) :-
  mask_cell(Mask),
  doctor_cell(Doctor),
  covid_cell1(CovidCell1),
  covid_cell2(CovidCell2),
  (
    (member(Mask, Path); member(Doctor, Path)) -> true;
    (is_adjacent(CovidCell1, Point); is_adjacent(CovidCell2, Point)) -> false;
    true
  ).

  % Function, where we store all paths in the list of edges
generate_paths(Size) :-
	forall(
		between(0, Size, X1),
		(
			forall(
				between(0, Size, Y1),
				(
					forall(
						is_adjacent([X1, Y1], [X2, Y2]),
						assertz(side([X1, Y1], [X2, Y2], 1))
					)
				)
			)
		)
	)
	.

  % Function, which returns path with minimal distance
find_min_path(CurrentPath, Distance) :-
	CurrentPath = [Node | _],
	(
		way([Node | _], NodeDistance) ->
			Distance < NodeDistance ->
				retract(way([Node | _], _));
			true
	),
	assertz(way(CurrentPath, Distance)).

% Function with main logic of A* algorithm
a_star_algorithm(Start, CurrentPath,CurrentDistance) :-
	side(Start, Node, Cost),
	\+(member(Node, CurrentPath)),
	is_safe(Node, [Node | CurrentPath]),
	find_min_path([Node, Start | CurrentPath], CurrentDistance + Cost),
	a_star_algorithm(Node,[Start | CurrentPath],CurrentDistance + Cost
	).

  % Function, which generates the first map
map1_a():-
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

	assertz(map_size(8)),
	assertz(covid_cell1([3,2])),
	assertz(covid_cell2([4,5])),
	assertz(mask_cell([1,4])),
	assertz(doctor_cell([7,1])),
	assertz(initial_position([0,0])),
	assertz(home_position([7,5])),
	initial_position(InitialPosition),
	home_position(HomePosition),
	map_size(8),
	retractall(side(_, _, _)),
	retractall(way(_, _)),
	generate_paths(9),
  write('Time taken by the A* algorithm to reach home is: '),
	time(\+a_star_algorithm(
		InitialPosition,
		[],
		0
	)),

	(
		  way([HomePosition | Tail], Lenght) ->
			MinPath = [HomePosition | Tail],
			L is Lenght+1,
      write('The path from right to left is: '),
      write(MinPath),
      write('\n'),
      write('The lenght of the path is: '),
      write(L)
	).

  % Function, which generates the second map
  map2_a():-
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

  	assertz(map_size(8)),
  	assertz(covid_cell1([6,3])),
  	assertz(covid_cell2([2,6])),
  	assertz(mask_cell([1,1])),
  	assertz(doctor_cell([6,8])),
  	assertz(initial_position([0,0])),
  	assertz(home_position([8,8])),
  	initial_position(InitialPosition),
  	home_position(HomePosition),
  	map_size(8),
  	retractall(side(_, _, _)),
  	retractall(way(_, _)),
  	generate_paths(9),
    write('Time taken by the A* algorithm to reach home is: '),
  	time(\+a_star_algorithm(
  		InitialPosition,
  		[],
  		0
  	)),

  	(
  		  way([HomePosition | Tail], Lenght) ->
  			MinPath = [HomePosition | Tail],
  			L is Lenght+1,
        write('The path from right to left is: '),
        write(MinPath),
        write('\n'),
        write('The lenght of the path is: '),
        write(L)
  	).

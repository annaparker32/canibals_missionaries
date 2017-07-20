/* Chloe Johnson & Anna Parker
 * CSCI 0313
 * HW 10
 * Monday, May 15, 2017
 *
 * misscann.pl
 *
 * Missionaries and Cannibals Problem
 *
 */

:- use_module(library(lists)).

/* The Story:
Three missionaries and three cannibals are traveling together through the
jungle. Why are the cannibals traveling with the missionaries? Perhaps in
the expectation of an easy meal. Their problem, there will be no easy
meals unless they outnumber the missionaries. They arrive at a river.
There is a boat. The boat can carry at most two people. Both the missionaries
and cannibals can operate the boat. Can the missionaries devise a series of
boat trips that will transport the entire party across the river and where, on
either bank, the missionaries will not be outnumbered and become an easy meal?
*/

/* represent valid passenger configurations as lists: */
/* ([# of cannibals, # of missionaries]) */
canBeInBoat([0,1]).
canBeInBoat([1,0]).
canBeInBoat([2,0]).
canBeInBoat([0,2]).
canBeInBoat([1,1]).



/*membership: returns true if boat combinations used more than twice
Value is new possible boat combination, array is of previous boat states,
counter is number of times Value appears in array of states.
membership(ValueBeingSearchedFor, [Array being searched in], Counter)*/
membership(Value, [Value|_], 2) :- !.

membership(Value, [Value|States], Counter) :-
	Counter1 is Counter + 1,
	membership(Value, States, Counter1),
	!.

membership(_, [], _) :- false.

membership(Value, [_|States], Counter) :-
	membership(Value, States, Counter).



/* determines whether the given number of cannibals and missionaries is a valid
combination */
illegal([C,M|_]) :-
	C > M.
legal([_,0|_]) :- true.
legal([C,M|_]) :- not(illegal([C,M|_])).


/* print all solutions */
printAll :-
	solve(Moves),
	nl,                 /* newline */
	printList(Moves),
	fail.                /* backtrack to find other solutions */

/* print each element of a list on its own line */
printList([]).
printList([H|T]) :-
	writeln(H),
	printList(T).


/* this calls the main search routine solve/5 */
solve(Result) :-
	/* initial values (makes it easier to read): */
	/* missionaries, cannibals, */
	Left = [3,3], /* group on left bank of river */
	Right = [0,0],                        /* group on right bank of river */
	Moves = [],       /* moves made so far */
	States = [],  /* states been in so far */
	LR = 0,		/* boat must go right if LR is 0 and go left if LR is 1 */
	Crossings = 0, /* the boat has never crossed the river */

	/*The following variables ensure that the program doesn't get stuck in an infinite loop or a longer-than-necessary solution */
	AllPass = [], /*All Pass: stores all boat combinations used to that point, combinations can be used max twice. */
	PrevPass = [], /*Prev Pass: ensures boat doesn't turn around with the exact same combination with which it arrived */
	solve(Left, Right, Moves, States, LR, Crossings, AllPass, PrevPass, Result).

/* if left bank empty & right bank is full, we are done: return moves made in reverse order */
solve([0,0], [3,3], Moves, _, _,_, _, _, Result) :-
	/* reverse(Moves, Result). */
	reverse(Moves, Result),
	!.
	/*writeln(Res), */
	/*print(Crossings),
	!. */

/* otherwise, try a move, make sure it doesn't result in a state we've been
   in already, and keep searching recursively */
solve(L, R, Moves, States, LR, Crossings, AllPass, PrevPass, Result) :-

	/*return a new potential boat combination (M and Pass) & the potential makeup of the left (NewL) and right (NewR) coasts */
	makeMove(L, R, NewL, NewR, M, LR, Pass),

	/*checks new move to avoid loops/ extra long solutions below: */
	not(membership(Pass, AllPass, 0)),
	not(Pass = PrevPass),

	/*if potential move passes checkpoints, include in solution & call solve to find next move*/
	NewCrossings is Crossings + 1,

	/*NewLr determines if boat should go left or go right, depending on the length of current crossing: (even? right) (odd? left) */
	NewLR is mod(NewCrossings, 2),

	solve(NewL, NewR, [M|Moves], [NewL|States], NewLR, NewCrossings, [Pass|AllPass], Pass, Result).


/* comes up with a legal move for right-bound boats*/
/* NewR is new population of right coast given Passengers, NewL is new population of left coast given Passengers */
makeMove(L, R, NewL, NewR, goRight(Passengers), 0, Passengers) :-
	canBeInBoat(Passengers),
	remove(Passengers, L, NewL),
	legal(NewL),
	add(Passengers, R, NewR),
	legal(NewR).

/* comes up with a legal move for left-bound boats*/
/* NewR is new population of right coast given Passengers, NewL is new population of left coast given Passengers */
makeMove(L, R, NewL, NewR, goLeft(Passengers), 1, Passengers) :-
	canBeInBoat(Passengers),
	remove(Passengers, R, NewR),
	legal(NewR),
	add(Passengers, L, NewL),
	legal(NewL).




/*Shorthand for add/remove function:
   CP: Cannibal passengers,
	 MP: missionary passengers,
	 SP: shore cannibals,
	 SM: shore missionaries
	 NC: new shore cannibals
	 NM: new shore missionaries */

/*removes passengers about to leave on the boat from their shore. */
remove([CP,MP|_], [SC,SM|_], NewL) :-
	NC is SC - CP,
	NC >= 0,
	NM is SM - MP,
	NM >= 0,
	NewL = [NC,NM].

/*adds passengers incoming from boats onto the shore. */
add([CP,MP|_], [SC,SM|_], NewL) :-
	NC is SC + CP,
	NC =< 3,
	NM is SM + MP,
	NM =< 3,
	NewL = [NC,NM].


/*
TESTING CODE:

printAll: provides a list of possible boat moves.  goRight([Cannibals, Missionaries])
or goLeft([Cannibals, Missionaries]).

?- printAll.

goRight([2,0])
goLeft([1,0])
goRight([2,0])
goLeft([1,0])
goRight([0,2])
goLeft([1,1])
goRight([0,2])
goLeft([1,0])
goRight([2,0])
goLeft([0,1])
goRight([1,1])

goRight([2,0])
goLeft([1,0])
goRight([2,0])
goLeft([1,0])
goRight([0,2])
goLeft([1,1])
goRight([0,2])
goLeft([1,0])
goRight([2,0])
goLeft([0,1])
goRight([1,1])

goRight([1,1])
goLeft([0,1])
goRight([2,0])
goLeft([1,0])
goRight([0,2])
goLeft([1,1])
goRight([0,2])
goLeft([1,0])
goRight([2,0])
goLeft([0,1])
goRight([1,1])

goRight([1,1])
goLeft([0,1])
goRight([2,0])
goLeft([1,0])
goRight([0,2])
goLeft([1,1])
goRight([0,2])
goLeft([1,0])
goRight([2,0])
goLeft([0,1])
goRight([1,1])

goRight([1,1])
goLeft([0,1])
goRight([2,0])
goLeft([1,0])
goRight([0,2])
goLeft([1,1])
goRight([0,2])
goLeft([1,0])
goRight([2,0])
goLeft([1,0])
goRight([2,0])

goRight([1,1])
goLeft([0,1])
goRight([2,0])
goLeft([1,0])
goRight([0,2])
goLeft([1,1])
goRight([0,2])
goLeft([1,0])
goRight([2,0])
goLeft([1,0])
goRight([2,0])
false.



Other functions:

?- canBeInBoat([Cannibal, Missionary]).
Cannibal = 0,
Missionary = 1 ;
Cannibal = 1,
Missionary = 0 ;
Cannibal = 2,
Missionary = 0 ;
Cannibal = 0,
Missionary = 2 ;
Cannibal = Missionary, Missionary = 1.




?- membership(1, [1, 1], 0).
false.

?- membership(1, [1, 1, 1], 0).
true.

?- membership(1, [1, 0, 2, 1, 3, 1], 0).
true.

?- membership(1, [1, 0, 2, 1, 3], 0).
false.




?- remove([1, 1], [3, 3], X).
X = [2, 2].

?- remove([1, 0], [3, 3], X).
X = [2, 3].

?- remove([4, 0], [3, 3], X).
false.



?- add([1, 0], [1, 1], X).
X = [2, 1].

?- add([2, 2], [1, 1], X).
X = [3, 3].

?- add([3, 2], [1, 1], X).
false.




?- legal([1, 1]).
true.

?- legal([3, 1]).
false.

?- legal([3, 0]).
true ;
false.



*/

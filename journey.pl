mode(f, 5, 'foot').
mode(c, 80, 'car').
mode(t, 100, 'train').
mode(p, 500, 'plane').


route(dublin, cork, 200, 'fct').
route(cork, dublin, 200, 'fctp').
route(cork, corkAirport, 20, 'fc').
route(corkAirport, cork, 25, 'fc').
route(dublin, dublinAirport, 10, 'fc').
route(dublinAirport, dublin, 20, 'fc').
route(dublinAirport, corkAirport, 225, 'p').
route(corkAirport, dublinAirport, 225, 'p').
route(dublin, portmarnock, 20, 'fct').
route(portmarnock, dublin, 20, 'fct').
route(sligo, dublinAirport, 320, 'p').
route(dublinAirport, sligo, 320, 'p').
route(sligo, corkAirport, 420, 'p').
route(corkAirport, sligo, 420, 'p').
route(sligo, dublin, 320, 'ct').
route(dublin, sligo, 320, 'ct').
route(sligo, mayo, 100, 'ct').
route(mayo, sligo, 100, 'ct').
route(dublinAirport, nigeria, 5300, 'p').
route(sligo, nigeria, 5000, 'p').
route(nigeria, lagos, 100, 'cf').
route(nigeria, cork, 5600, 'p').
route(lagos, newyork, 65000, 'p').


get_list_occurences([], _, []).

get_list_occurences([H|Lst1], Lst2, [H|Occurence]):-
   get_list_occurences(Lst1, Lst2, Occurence),
   member(H, Lst2), !.

get_list_occurences([_|Lst1], Lst2, Occurence):-
   get_list_occurences(Lst1, Lst2, Occurence).

get_mode_occurrences(MyModes, AllModes, Occurence):-
   string_chars(MyModes, Lst1),
   string_chars(AllModes, Lst2),
   get_list_occurences(Lst1, Lst2, Occurence).



get_best_mode([Mode], Mode, Speed, Name):-
   mode(Mode, Speed, Name).

get_best_mode([Mode|Lst], Mode, NewSpeed, NewName):-
   mode(Mode, NewSpeed, NewName),
   get_best_mode(Lst, _, X, _),
   NewSpeed > X.

get_best_mode([Mode|Lst], X, BestSpeed, Name):-
   mode(Mode, Speed, _),
   get_best_mode(Lst, X, BestSpeed, Name),
   BestSpeed > Speed.

get_best_mode([Mode|Lst], X, BestSpeed, Name):-
   mode(Mode, Speed, _),
   get_best_mode(Lst, X, BestSpeed, Name),
   Speed = BestSpeed.



get_route(Source, FinalDest, MyModes, SeenDest, Route, FullDistance, TotalTime, [ModeTaken]):-
   route(Source, FinalDest, Distance, AllModes),
   not(member(FinalDest, SeenDest)),
   get_mode_occurrences(MyModes, AllModes, Occurences),
   Occurences \= [],
   append([FinalDest, Source], SeenDest, R),
   reverse(R, Route),
   FullDistance is Distance,
   get_best_mode(Occurences, _, Speed, ModeTaken),
   TotalTime is Distance / Speed.

get_route(Source, FinalDest, MyModes, SeenDest, Route, FullDistance, TotalTime, [ModeTaken|AllModeTaken]):-
   route(Source, SomeDest, Distance, AllModes),
   not(member(SomeDest, SeenDest)),
   get_mode_occurrences(MyModes, AllModes, Occurences),
   Occurences \= [],
   get_route(SomeDest, FinalDest, MyModes, [Source|SeenDest], Route, PrevDist, PrevTime, AllModeTaken),
   FullDistance is Distance + PrevDist,
   get_best_mode(Occurences, _, Speed, ModeTaken),
   NewTime is Distance / Speed,
   TotalTime is NewTime + PrevTime.



get_quickest_route(Source, FinalDest, MyModes, Route, FullDistance, BestTime, AllModeTaken):-
   get_route(Source, FinalDest, MyModes, [], _, _, _, _),
   findall(Time, get_route(Source, FinalDest, MyModes, [], _, _, Time, _), Lst),
   min_member(BestTime, Lst),
   get_route(Source, FinalDest, MyModes, [], Route, FullDistance, BestTime, AllModeTaken), !.



write_route([], []).
write_route([Dest|Route], [Mode|AllModeTaken]):-
   write('\nthen go to '), write(Dest),
   write(' by '), write(Mode),
   write_route(Route, AllModeTaken).


get_overflow(N, Factor, 0, Remainder):-
   X is N - Factor,
   Remainder is round(N * 100),
   X < 0, !.

get_overflow(N, Factor, Overflow, Remainder):-
   X is N - Factor,
   get_overflow(X, Factor, O, Remainder),
   Overflow is O + 1.


journey(S, D, M):-
   get_quickest_route(S, D, M, [Start|Route], Distance, Time, AllModeTaken),
   get_overflow(Time, 0.60, Hours, Minutes),
   write('Route: '), write([Start|Route]),
   write('\nDistance: '), write(Distance), write(' kilometers'),
   write('\nTotal travel time: '), write(Hours), write(' hour(s) '), write(Minutes), write(' minute(s)'),
   write('\n\nStart at '), write(Start),
   write_route(Route, AllModeTaken), !.

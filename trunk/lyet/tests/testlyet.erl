-module (testlyet).
-compile ({ parse_transform, lyet }).

-ifdef (HAVE_EUNIT).
-include_lib ("eunit/include/eunit.hrl").
-endif.

g (X) -> X + 1.
h (X) -> X + 2.
l (X) -> X + 3.
m (X) -> X + 4.

% different equivalent ways of writing m (l (h (g (X))))
% i like the first one the best

testone (X) ->
  lyet:lyet (X = g (X),
             X = h (X),
             X = l (X),
             m (X)).


testtwo (X) ->
  lyet:lyet (X = g (X), 
    lyet:lyet (X = h (X), 
      lyet:lyet (X = l (X), 
        m (X)
      )
    )
  ).

testthree (X) ->
  lyet:lyet (X = 
    lyet:lyet (X = 
      lyet:lyet (X = 
        lyet:lyet (X = g (X), 
                   X), 
        h (X)), 
    l (X)), 
  m (X)).

testnoassign () ->
  lyet:lyet (9 + 2).

-ifdef (EUNIT).

one_test () -> 
  ?assertEqual (11, testone (1)).

two_test () -> 
  ?assertEqual (11, testtwo (1)).

three_test () -> 
  ?assertEqual (11, testthree (1)).

noassign_test () -> 
  ?assertEqual (11, testnoassign ()).

-endif.

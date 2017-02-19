(define breadth-first
  {state --> (state --> (list state)) --> (state --> boolean) --> boolean}
  Start F Test -> (b* F Test (F Start)))

(define b*
  {(state --> (list state)) --> (state --> boolean) --> (list state) --> boolean}
  F Test States -> true 	where (some Test States)
  F Test States -> (let NewStates (mapcan F States)
                     (if (empty? NewStates)
                         false
                         (b* F Test NewStates))))

(define some
  {(A --> boolean) --> (list A) --> boolean}
  Test [] -> false
  Test [X|Y] -> (or (Test X) (some Test Y)))

(define depth
  {state --> (state --> (list state)) --> (state --> boolean) --> boolean}
  Start _ Test -> true 	where (Test Start)
  Start F Test -> (d* F Test (F Start)))

(define d*
  {(state --> (list state)) --> (state --> boolean) --> (list state) --> boolean}
  _ Test [State | _] -> true 	where (Test State)
  F Test [State | States] <- (fail-if (= false) (d* F Test (F State)))
  F Test [_ | States] -> (d* F Test States)
  _ _ _ -> false)

(define hill
  {(state --> number) --> state --> (state --> (list state)) --> (state --> boolean) --> boolean}
  _ Start _ Test -> true 	where (Test Start)
  E Start F Test -> (h* E F Test (order_states E (F Start))))

(define h*
  {(state --> number) --> (state --> (list state)) --> (state --> boolean) --> (list state) --> boolean}
  _ _ Test [State | _] -> true 	where (Test State)
  E F Test [State | States]
  <- (fail-if (/. X (= X false)) (h* E F Test (order_states E (F State))))
  E F Test [_ | States] -> (h* E F Test States)
  _ _ _ _ -> false)

(define order_states
  {(state --> number) --> (list state) --> (list state)}
  E States -> (sort (/. S1 (/. S2 (> (E S1) (E S2)))) States))

(define sort
  {(A --> (A --> boolean)) --> (list A) --> (list A)}
  R X -> (fix (/. Y (sort* R Y)) X))

(define sort*
  {(A --> A --> boolean) --> (list A) --> (list A)}
  _ [] -> []
  _ [X] -> [X]
  R [X Y | Z] -> [Y | (sort* R [X | Z])]	where (R Y X)
  R [X Y | Z] -> [X | (sort* R [Y | Z])])

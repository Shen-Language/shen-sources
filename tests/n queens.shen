(define n-queens
  {number --> (list (list number))}
  N -> (n-queens-loop N (initialise N)))

(define initialise
  {number --> (list number)}
  0 -> []
  N -> [1 | (initialise (- N 1))])

(define n-queens-loop
  {number --> (list number) --> (list (list number))}
  N Config -> []    where (all_Ns? N Config)
  N Config -> [Config | (n-queens-loop N (next_n N Config))]
      where (and (ok_row? Config) (ok_diag? Config))
  N Config -> (n-queens-loop N (next_n N Config)))

(define all_Ns?
  {number --> (list number) --> boolean}
  _ [] -> true
  N [N | Ns] -> (all_Ns? N Ns)
  _ _ -> false)

(define next_n
  {number --> (list number) --> (list number)}
  N [N | Ns] -> [1 | (next_n N Ns)]
  _ [N | Ns] -> [(+ 1 N) | Ns])

(define ok_row?
  {(list number) --> boolean}
  [] -> true
  [N | Ns] -> false     where (element? N Ns)
  [_ | Ns] -> (ok_row? Ns))

(define ok_diag?
  {(list number) --> boolean}
  [] -> true
  [N | Ns] -> (and (ok_diag_N? (+ N 1) (- N 1) Ns)
                   (ok_diag? Ns)))

(define ok_diag_N?
  {number --> number --> (list number) --> boolean}
  _ _ [] -> true
  Up Down [Up | _] -> false
  Up Down [Down | _] -> false
  Up Down [_ | Ns] -> (ok_diag_N? (+ 1 Up) (- Down 1) Ns))

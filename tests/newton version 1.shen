(define newtons-method
  N -> (let Guess (/ N 2.0)
         (run-newtons-method
          N
          (round-to-2-places (average Guess (/  N Guess)))
          Guess)))

(define run-newtons-method
  _ Sqrt Sqrt -> Sqrt
  N Better_Guess _
  -> (run-newtons-method
      N
      (round-to-2-places (average Better_Guess (/  N Better_Guess)))
      Better_Guess))

(define round-to-2-places
  N -> (/ (round (* 100.0 N)) 100.0))

(define average
  M N -> (/ (+ M N) 2.0))

(datatype progression

  X : (A * (A --> A) * (A --> boolean));
  ======================================
  X : (progression A);)

(define delay
  {(progression A) --> (progression A)}
  (@p X F E) -> (if (not (E X))
                    (@p (F X) F E)
                    (error "progression exhausted!~%")))

(define force
  {(progression A) --> A}
  (@p X F E) -> X)

(define end?
  {(progression A) --> boolean}
  (@p X _ E) -> (E X))

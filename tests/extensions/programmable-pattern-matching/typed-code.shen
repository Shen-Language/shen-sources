(define ppm.match-typed-surface
  { (number * string) --> boolean }
  (first X) -> true)

(define ppm.match-typed-binding
  { (number * string) --> number }
  (first X) -> X)

(define ppm.match-typed-nested
  { ((number * string) * boolean) --> number }
  (first (first X)) -> X)

(define ppm.match-typed-binary
  { ppm-pair --> boolean }
  (two X Y) -> true)

(define ppm.match-typed-nullary
  { symbol --> boolean }
  (nothing) -> true
  _ -> false)

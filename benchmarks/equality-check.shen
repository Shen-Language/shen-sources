\\ Copyright (c) 2019 Bruno Deferrari.
\\ BSD 3-Clause License: http://opensource.org/licenses/BSD-3-Clause

(define equality-check-control-loop
  _ 0 -> ok
  C N -> (equality-check-control-loop C (- N 1)))

(define equal-values
  _ _ _ 0 -> ok
  ValA ValB _ N -> (equal-values ValA ValB (= ValA ValB) (- N 1)))

(define equal-symbol-literal
  _ _ 0 -> ok
  Sym _ N -> (equal-symbol-literal Sym (= Sym symbol) (- N 1)))

(define equal-integer-literal
  _ _ 0 -> ok
  Num _ N -> (equal-integer-literal Num (= Num 8) (- N 1)))

(define equal-float-literal
  _ _ 0 -> ok
  Num _ N -> (equal-float-literal Num (= Num 8.0) (- N 1)))

(define equal-string-literal
  _ _ 0 -> ok
  Str _ N -> (equal-string-literal Str (= Str "string") (- N 1)))

(benchmark "equality check control loop"
  (equality-check-control-loop 0)
  8)

(benchmark "symbol equality (true)"
  (equal-values symbol symbol false)
  8)
(benchmark "symbol equality (false)"
  (equal-values symbol "not a symbol" false)
  8)

(benchmark "literal symbol equality (true)"
  (equal-symbol-literal symbol true)
  8)
(benchmark "literal symbol equality (false)"
  (equal-symbol-literal "not a symbol" false)
  8)

(benchmark "number equality (true)"
  (equal-values 1 1 true)
  8)
(benchmark "number equality (false)"
  (equal-values 1 "not a number" false)
  8)

(benchmark "literal integer equality (true)"
  (equal-integer-literal 8 true)
  8)
(benchmark "literal integer equality (false)"
  (equal-integer-literal "not a number" false)
  8)

(benchmark "literal float equality (true)"
  (equal-float-literal 8.0 true)
  8)
(benchmark "literal float equality (false)"
  (equal-float-literal "not a number" false)
  8)

(benchmark "string equality (true)"
  (equal-values "string" "string" true)
  8)
(benchmark "string equality (false)"
  (equal-values "string" [not-a-string] false)
  8)

(benchmark "literal string equality (true)"
  (equal-string-literal "string" true)
  8)
(benchmark "literal string equality (false)"
  (equal-string-literal [not-a-string] false)
  8)

(benchmark "list equality (true)"
  (equal-values [a list of symbols] [a list of symbols] true)
  8)
(benchmark "list equality (false)"
  (equal-values [a list of symbols] "not a list" false)
  8)

(benchmark "vector equality (true)"
  (equal-values (@v a vector of symbols <>) (@v a vector of symbols <>) true)
  8)
(benchmark "vector equality (false)"
  (equal-values (@v a vector of symbols <>) "not a vector" false)
  8)

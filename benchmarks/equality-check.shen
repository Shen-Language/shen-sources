\\ Copyright (c) 2019 Bruno Deferrari.
\\ BSD 3-Clause License: http://opensource.org/licenses/BSD-3-Clause

(define equality-check-control-loop
  _ 0 -> ok
  C N -> (equality-check-control-loop C (- N 1)))

(define equal-values
  _ _ R 0 -> R
  ValA ValB _ N -> (equal-values ValA ValB (= ValA ValB) (- N 1)))

(define equal-symbol-literal
  _ R 0 -> R
  Sym _ N -> (equal-symbol-literal Sym (= Sym symbol) (- N 1)))

(define equal-integer-literal
  _ R 0 -> R
  Num _ N -> (equal-integer-literal Num (= Num 8) (- N 1)))

(define equal-float-literal
  _ R 0 -> R
  Num _ N -> (equal-float-literal Num (= Num 8.0) (- N 1)))

(define equal-string-literal
  _ R 0 -> R
  Str _ N -> (equal-string-literal Str (= Str "string") (- N 1)))

(add-benchmark equality-check
  "equality check control loop"
  (equality-check-control-loop 0)
  8)

(add-benchmark equality-check
  "symbol equality (true)"
  (equal-values symbol symbol false)
  8)
(add-benchmark equality-check
  "symbol equality (false)"
  (equal-values symbol "not a symbol" false)
  8)

(add-benchmark equality-check
  "literal symbol equality (true)"
  (equal-symbol-literal symbol true)
  8)
(add-benchmark equality-check
  "literal symbol equality (false)"
  (equal-symbol-literal "not a symbol" false)
  8)

(add-benchmark equality-check
  "number equality (true)"
  (equal-values 1 1 true)
  8)
(add-benchmark equality-check
  "number equality (false)"
  (equal-values 1 "not a number" false)
  8)

(add-benchmark equality-check
  "literal integer equality (true)"
  (equal-integer-literal 8 true)
  8)
(add-benchmark equality-check
  "literal integer equality (false)"
  (equal-integer-literal "not a number" false)
  8)

(add-benchmark equality-check
  "literal float equality (true)"
  (equal-float-literal 8.0 true)
  8)
(add-benchmark equality-check
  "literal float equality (false)"
  (equal-float-literal "not a number" false)
  8)

(add-benchmark equality-check
  "string equality (true)"
  (equal-values "string" "string" true)
  8)
(add-benchmark equality-check
  "string equality (false)"
  (equal-values "string" [not-a-string] false)
  8)

(add-benchmark equality-check
  "literal string equality (true)"
  (equal-string-literal "string" true)
  8)
(add-benchmark equality-check
  "literal string equality (false)"
  (equal-string-literal [not-a-string] false)
  8)

(add-benchmark equality-check
  "list equality (true)"
  (equal-values [a list of symbols] [a list of symbols] true)
  8)
(add-benchmark equality-check
  "list equality (false)"
  (equal-values [a list of symbols] "not a list" false)
  8)

(add-benchmark equality-check
  "vector equality (true)"
  (equal-values (@v a vector of symbols <>) (@v a vector of symbols <>) true)
  8)
(add-benchmark equality-check
  "vector equality (false)"
  (equal-values (@v a vector of symbols <>) "not a vector" false)
  8)


\\ Separately constructed operands exercise traversal beyond identity and
\\ first-element/type mismatch. Input construction is outside the clock.
(define equality-list-input
  0 -> []
  N -> [N | (equality-list-input (- N 1))])

(define equality-tree-input
  N -> [branch [leaf N] [branch [leaf (+ N 1)] [leaf (+ N 2)]]])

(define equality-vector-fill
  V 0 _ -> V
  V N Last -> (equality-vector-fill
                (vector-> V N (if (= N 32) Last N)) (- N 1) Last))

(define equality-vector-input
  Last -> (equality-vector-fill (vector 32) 32 Last))

(let Xs (equality-list-input 32)
     Ys (equality-list-input 32)
     PrefixA (append (equality-list-input 32) [a])
     PrefixB (append (equality-list-input 32) [b])
     Tree (equality-tree-input 1)
     OtherTree (equality-tree-input 1)
     VecA (equality-vector-input 32)
     VecB (equality-vector-input 32)
     VecC (equality-vector-input 0)
  (do
    (add-benchmark equality-check "distinct list equality (32 items, equal)"
      (equal-values Xs Ys false) 6)
    (add-benchmark equality-check "list equality (early mismatch)"
      (equal-values Xs [other | (tl Ys)] true) 6)
    (add-benchmark equality-check "list equality (late mismatch)"
      (equal-values PrefixA PrefixB true) 6)
    (add-benchmark equality-check "distinct nested tree equality"
      (equal-values Tree OtherTree false) 6)
    (add-benchmark equality-check "distinct vector equality (32 items, equal)"
      (equal-values VecA VecB false) 5)
    (add-benchmark equality-check "vector equality (last element mismatch)"
      (equal-values VecA VecC true) 5)
    (add-benchmark equality-check "numeric equality (integer/fractional)"
      (equal-values 1 1.5 true) 6)))

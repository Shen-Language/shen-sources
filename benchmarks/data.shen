\\ Copyright (c) 2019 Bruno Deferrari.
\\ BSD 3-Clause License: http://opensource.org/licenses/BSD-3-Clause

(define data-control-loop
  _ 0 -> ok
  C N -> (data-control-loop C (- N 1)))

(define absvector-create-small
  V 0 -> V
  V N -> (absvector-create-small (absvector 1) (- N 1)))

(define absvector-create-big
  V 0 -> V
  V N -> (absvector-create-big (absvector 100) (- N 1)))

(define absvector-read
  _ R 0 -> R
  V _ N -> (absvector-read V (<-address V 1) (- N 1)))

(define absvector-write
  V 0 -> V
  V N -> (absvector-write (address-> V 1 N) (- N 1)))

(define vector-create-small
  V 0 -> V
  V N -> (vector-create-small (vector 1) (- N 1)))

(define vector-create-big
  V 0 -> V
  V N -> (vector-create-big (vector 100) (- N 1)))

(define vector-read
  _ R 0 -> R
  V _ N -> (absvector-read V (<-vector V 1) (- N 1)))

(define vector-write
  V 0 -> V
  V N -> (absvector-write (vector-> V 1 N) (- N 1)))

(define tuple-create
  T 0 -> T
  T N -> (tuple-create (@p 1 2) (- N 1)))

(define tuple-read
  _ R 0 -> R
  T _ N -> (tuple-read T (fst T) (- N 1)))

(define string-prepend-one
  _ R 0 -> R
  S _ N -> (string-prepend-one S (cn "a" S) (- N 1)))

(define string-prepend-long
  _ R 0 -> R
  S _ N -> (string-prepend-long S (cn "abcdefghijklmnopqrstuvwxyz" S) (- N 1)))

(define string-read-first
  _ R 0 -> R
  S _ N -> (string-read-first S (hdstr S) (- N 1)))

(define string-read-last
  _ R 0 -> R
  S _ N -> (string-read-last S (pos S 63) (- N 1)))

(define string-get-tail
  _ R 0 -> R
  S _ N -> (string-get-tail S (tlstr S) (- N 1)))

(define dict-create
  D 0 -> D
  D N -> (dict-create (shen.dict 100) (- N 1)))

(define dict-read
  _ R 0 -> R
  D _ N -> (dict-read D (shen.<-dict D "exists") (- N 1)))

(define dict-write
  _ 0 -> ok
  D N -> (dict-write (do (shen.dict-> D "key" 1) D) (- N 1)))

(add-benchmark data
  "data control loop"
  (data-control-loop 0)
  8)

(add-benchmark data
  "absvector read"
  (absvector-read (@v 1 <>) 1)
  8)
(add-benchmark data
  "absvector write"
  (absvector-write (@v 2 <>))
  8)
(add-benchmark data
  "absvector create (small)"
  (absvector-create-small (absvector 1))
  7)
(add-benchmark data
  "absvector create (big)"
  (absvector-create-big (absvector 1))
  7)

(add-benchmark data
  "vector read"
  (vector-read (@v 1 <>) 1)
  8)
(add-benchmark data
  "vector write"
  (vector-write (@v 2 <>))
  8)
(add-benchmark data
  "vector create (small)"
  (vector-create-small (vector 1))
  7)
(add-benchmark data
  "vector create (big)"
  (vector-create-big (vector 1))
  7)

(add-benchmark data
  "tuple read"
  (tuple-read (@p 1 2) 1)
  8)
(add-benchmark data
  "tuple create"
  (tuple-create (@p 1 2))
  7)

(add-benchmark data
  "string (short) prepend one"
  (string-prepend-one "string" "")
  7)
(add-benchmark data
  "string (short) prepend long"
  (string-prepend-long "string" "")
  7)
(add-benchmark data
  "string (long) prepend one"
  (string-prepend-one "a longer string a longer string a longer string a longer string." "")
  7)
(add-benchmark data
  "string (long) prepend long"
  (string-prepend-long "a longer string a longer string a longer string a longer string." "")
  7)
(add-benchmark data
  "string read first"
  (string-read-first "string" "")
  8)
(add-benchmark data
  "string read last"
  (string-read-last "a longer string a longer string a longer string a longer string." "")
  8)
(add-benchmark data
  "string get tail (short)"
  (string-get-tail "string" "")
  8)
(add-benchmark data
  "string get tail (longer)"
  (string-get-tail "a longer string a longer string a longer string a longer string." "")
  7)

(add-benchmark data
  "dict read"
  (dict-read (let D (shen.dict 100) _ (shen.dict-> D "exists" 1 ) D) 1)
  7)
(add-benchmark data
  "dict write"
  (dict-write (shen.dict 100))
  7)
(add-benchmark data
  "dict create"
  (dict-create (shen.dict 100))
  7)


\\ Fixed 32-item lists and bounded live allocation windows. Inputs and
\\ initial closures are constructed at registration, outside the clock.
(define list-benchmark-input
  0 -> []
  N -> [N | (list-benchmark-input (- N 1))])

(define list-benchmark-sum
  [] R -> R
  [X | Xs] R -> (list-benchmark-sum Xs (+ R X)))

(define list-benchmark-copy
  [] -> []
  [X | Xs] -> [X | (list-benchmark-copy Xs)])

(define list-traverse
  _ R 0 -> R
  Xs _ N -> (list-traverse Xs (list-benchmark-sum Xs 0) (- N 1)))

(define list-length
  _ R 0 -> R
  Xs _ N -> (list-length Xs (length Xs) (- N 1)))

(define list-rebuild
  _ R 0 -> R
  Xs _ N -> (list-rebuild Xs (list-benchmark-copy Xs) (- N 1)))

(define list-append
  _ _ R 0 -> R
  Xs Ys _ N -> (list-append Xs Ys (append Xs Ys) (- N 1)))

(define list-reverse
  _ R 0 -> R
  Xs _ N -> (list-reverse Xs (reverse Xs) (- N 1)))

(define list-member
  _ _ R 0 -> R
  X Xs _ N -> (list-member X Xs (element? X Xs) (- N 1)))

(define list-allocation-live
  _ A B C 0 -> [A B C]
  Seed A B _ N -> (list-allocation-live Seed
                    (list-benchmark-copy Seed) A B (- N 1)))

(define closure-benchmark-prepend
  X -> (/. Xs [X | Xs]))

(define closure-allocation-live
  _ A B C 0 -> (A (B (C [])))
  Seed A B _ N -> (closure-allocation-live Seed
                    (closure-benchmark-prepend Seed) A B (- N 1)))

(let Xs (list-benchmark-input 32)
     Ys (list-benchmark-input 32)
     A (closure-benchmark-prepend Xs)
     B (closure-benchmark-prepend Xs)
     C (closure-benchmark-prepend Xs)
  (do
    (add-benchmark data "list traversal (32 items)"
      (list-traverse Xs 0) 5)
    (add-benchmark data "list length (32 items)"
      (list-length Xs 0) 5)
    (add-benchmark data "recursive list rebuild (32 items)"
      (list-rebuild Xs []) 5)
    (add-benchmark data "append (32 + 32 items)"
      (list-append Xs Ys []) 5)
    (add-benchmark data "reverse (32 items)"
      (list-reverse Xs []) 5)
    (add-benchmark data "list membership (first item)"
      (list-member 32 Xs false) 6)
    (add-benchmark data "list membership (last item)"
      (list-member 1 Xs false) 5)
    (add-benchmark data "list membership (absent item)"
      (list-member 0 Xs true) 5)
    (add-benchmark data "list allocation (three live generations)"
      (list-allocation-live Xs Xs Ys Xs) 5)
    (add-benchmark data "closure allocation (three live generations)"
      (closure-allocation-live Xs A B C) 6)))

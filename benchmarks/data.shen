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
  V 0 -> V
  V N -> (absvector-read V (- N (<-address V 1))))

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
  V 0 -> V
  V N -> (absvector-read V (- N (<-vector V 1))))

(define vector-write
  V 0 -> V
  V N -> (absvector-write (vector-> V 1 N) (- N 1)))


(define tuple-create
  T 0 -> T
  T N -> (tuple-read (@p 1 2) (- N 1)))

(define tuple-read
  T 0 -> T
  T N -> (tuple-read T (- N (fst T))))

(define string-prepend-one
  S 0 -> S
  S N -> (string-prepend-one (do (cn "a" S) S) (- N 1)))

(define string-prepend-long
  S 0 -> S
  S N -> (string-prepend-one (do (cn "abcdefghijklmnopqrstuvwxyz" S) S) (- N 1)))

(define string-read-first
  S 0 -> S
  S N -> (string-read-first (do (hdstr S) S) (- N 1)))

(define string-read-last
  S 0 -> S
  S N -> (string-read-last (do (pos S 63) S) (- N 1)))

(define string-get-tail
  S 0 -> S
  S N -> (string-get-tail (do (tlstr S) S) (- N 1)))

(benchmark "data control loop"
  (data-control-loop 0)
  8)

(benchmark "absvector read"
  (absvector-read (@v 1 <>))
  8)
(benchmark "absvector write"
  (absvector-write (@v 2 <>))
  8)
(benchmark "absvector create (small)"
  (absvector-create-small (absvector 1))
  7)
(benchmark "absvector create (big)"
  (absvector-create-big (absvector 1))
  7)

(benchmark "vector read"
  (vector-read (@v 1 <>))
  8)
(benchmark "vector write"
  (vector-write (@v 2 <>))
  8)
(benchmark "vector create (small)"
  (vector-create-small (vector 1))
  7)
(benchmark "vector create (big)"
  (vector-create-big (vector 1))
  7)

(benchmark "tuple read"
  (tuple-read (@p 1 2))
  8)
(benchmark "tuple create"
  (tuple-create (@p 1 2))
  7)

(benchmark "string (short) prepend one"
  (string-prepend-one "string")
  7)
(benchmark "string (short) prepend long"
  (string-prepend-long "string")
  7)
(benchmark "string (long) prepend one"
  (string-prepend-one "a longer string a longer string a longer string a longer string.")
  7)
(benchmark "string (long) prepend long"
  (string-prepend-long "a longer string a longer string a longer string a longer string.")
  7)
(benchmark "string read first"
  (string-read-first "string")
  8)
(benchmark "string read last"
  (string-read-last "a longer string a longer string a longer string a longer string.")
  8)
(benchmark "string get tail (short)"
  (string-get-tail "string")
  8)
(benchmark "string get tail (longer)"
  (string-get-tail "a longer string a longer string a longer string a longer string.")
  7)
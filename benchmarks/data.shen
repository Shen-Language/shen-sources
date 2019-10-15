\\ Copyright (c) 2019 Bruno Deferrari.
\\ BSD 3-Clause License: http://opensource.org/licenses/BSD-3-Clause

(define data-control-loop
  _ 0 -> ok
  C N -> (data-control-loop C (- N 1)))

(define absvector-create-small
  _ 0 -> ok
  V N -> (absvector-create-small (absvector 1) (- N 1)))

(define absvector-create-big
  _ 0 -> ok
  V N -> (absvector-create-big (absvector 100) (- N 1)))

(define absvector-read
  _ 0 -> ok
  V N -> (absvector-read V (- N (<-address V 1))))

(define absvector-write
  V 0 -> ok
  V N -> (absvector-write (address-> V 1 N) (- N 1)))

(define vector-create-small
  _ 0 -> ok
  V N -> (vector-create-small (vector 1) (- N 1)))

(define vector-create-big
  _ 0 -> ok
  V N -> (vector-create-big (vector 100) (- N 1)))

(define vector-read
  _ 0 -> ok
  V N -> (absvector-read V (- N (<-vector V 1))))

(define vector-write
  V 0 -> ok
  V N -> (absvector-write (vector-> V 1 N) (- N 1)))


(define tuple-create
  _ 0 -> ok
  T N -> (tuple-read (@p 1 2) (- N 1)))

(define tuple-read
  _ 0 -> ok
  T N -> (tuple-read T (- N (fst T))))

\\ string prepend 1
\\ string prepend many

(define string-read-first
  _ 0 -> ok
  S N -> (string-read-first (do (hdstr S) S) (- N 1)))

(define string-read-last
  _ 0 -> ok
  S N -> (string-read-last (do (pos S 63) S) (- N 1)))

(define string-get-tail
  _ 0 -> ok
  S N -> (string-get-tail (do (tlstr S) S) (- N 1)))

(benchmark "data control loop"
  (data-control-loop 0)
  100000000)

(benchmark "absvector read"
  (absvector-read (@v 1 <>))
  100000000)
(benchmark "absvector write"
  (absvector-write (@v 2 <>))
  100000000)
(benchmark "absvector create (small)"
  (absvector-create-small (absvector 1))
  10000000)
(benchmark "absvector create (big)"
  (absvector-create-big (absvector 1))
  10000000)

(benchmark "vector read"
  (vector-read (@v 1 <>))
  100000000)
(benchmark "vector write"
  (vector-write (@v 2 <>))
  100000000)
(benchmark "vector create (small)"
  (vector-create-small (vector 1))
  10000000)
(benchmark "vector create (big)"
  (vector-create-big (vector 1))
  10000000)

(benchmark "tuple read"
  (tuple-read (@p 1 2))
  100000000)
(benchmark "tuple create"
  (tuple-create (@p 1 2))
  10000000)

(benchmark "string read first"
  (string-read-first "string")
  100000000)
(benchmark "string read last"
  (string-read-last "a longer string a longer string a longer string a longer string.")
  100000000)
(benchmark "string get tail (short)"
  (string-get-tail "string")
  100000000)
(benchmark "string get tail (longer)"
  (string-get-tail "a longer string a longer string a longer string a longer string.")
  10000000)
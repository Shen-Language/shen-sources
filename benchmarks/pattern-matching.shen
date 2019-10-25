\\ Copyright (c) 2019 Bruno Deferrari.
\\ BSD 3-Clause License: http://opensource.org/licenses/BSD-3-Clause

(define pattern-matching-control-loop
  R 0 -> R
  C N -> (pattern-matching-control-loop C (- N 1)))

(define match-list-single
  R 0 -> R
  [A B C D E F G H I J K L] N -> (match-list-single [A B C D E F G H I J K L] (- N 1))
  Other N -> (match-list-single Other (- N 1)))

(define match-list-multiple
  R 0 -> R
  [A B C D E F G H I J K 0] N -> (match-list-multiple [A B C D E F G H I J K 0] (- N 1))
  [A B C D E F G H I J K 1] N -> (match-list-multiple [A B C D E F G H I J K 1] (- N 1))
  [A B C D E F G H I J K 2] N -> (match-list-multiple [A B C D E F G H I J K 2] (- N 1))
  [A B C D E F G H I J K 3] N -> (match-list-multiple [A B C D E F G H I J K 3] (- N 1))
  [A B C D E F G H I J K 4] N -> (match-list-multiple [A B C D E F G H I J K 4] (- N 1))
  [A B C D E F G H I J K 5] N -> (match-list-multiple [A B C D E F G H I J K 5] (- N 1))
  [A B C D E F G H I J K 6] N -> (match-list-multiple [A B C D E F G H I J K 6] (- N 1))
  [A B C D E F G H I J K 7] N -> (match-list-multiple [A B C D E F G H I J K 7] (- N 1))
  [A B C D E F G H I J K 8] N -> (match-list-multiple [A B C D E F G H I J K 8] (- N 1))
  [A B C D E F G H I J K 9] N -> (match-list-multiple [A B C D E F G H I J K 9] (- N 1))
  [A B C D E F G H I J K L] N -> (match-list-multiple [A B C D E F G H I J K L] (- N 1))
  Other N -> (match-list-multiple Other (- N 1)))

(define match-tuple-single
  R 0 -> R
  (@p A B C D E F G H I J K L) N -> (match-tuple-single (@p A B C D E F G H I J K L) (- N 1))
  Other N -> (match-tuple-single Other (- N 1)))

(define match-tuple-multiple
  R 0 -> R
  (@p A B C D E F G H I J K 0) N -> (match-tuple-multiple (@p A B C D E F G H I J K 0) (- N 1))
  (@p A B C D E F G H I J K 1) N -> (match-tuple-multiple (@p A B C D E F G H I J K 1) (- N 1))
  (@p A B C D E F G H I J K 2) N -> (match-tuple-multiple (@p A B C D E F G H I J K 2) (- N 1))
  (@p A B C D E F G H I J K 3) N -> (match-tuple-multiple (@p A B C D E F G H I J K 3) (- N 1))
  (@p A B C D E F G H I J K 4) N -> (match-tuple-multiple (@p A B C D E F G H I J K 4) (- N 1))
  (@p A B C D E F G H I J K 5) N -> (match-tuple-multiple (@p A B C D E F G H I J K 5) (- N 1))
  (@p A B C D E F G H I J K 6) N -> (match-tuple-multiple (@p A B C D E F G H I J K 6) (- N 1))
  (@p A B C D E F G H I J K 7) N -> (match-tuple-multiple (@p A B C D E F G H I J K 7) (- N 1))
  (@p A B C D E F G H I J K 8) N -> (match-tuple-multiple (@p A B C D E F G H I J K 8) (- N 1))
  (@p A B C D E F G H I J K 9) N -> (match-tuple-multiple (@p A B C D E F G H I J K 9) (- N 1))
  (@p A B C D E F G H I J K L) N -> (match-tuple-multiple (@p A B C D E F G H I J K L) (- N 1))
  Other N -> (match-tuple-multiple Other (- N 1)))

(define match-vector-single
  R 0 -> R
  (@v A B C D E F G H I J K L <>) N -> (match-vector-single (@v A B C D E F G H I J K L <>) (- N 1))
  Other N -> (match-vector-single Other (- N 1)))

(define match-vector-multiple
  R 0 -> R
  (@v A B C D E F G H I J K 0 <>) N -> (match-vector-multiple (@v A B C D E F G H I J K 0 <>) (- N 1))
  (@v A B C D E F G H I J K 1 <>) N -> (match-vector-multiple (@v A B C D E F G H I J K 1 <>) (- N 1))
  (@v A B C D E F G H I J K 2 <>) N -> (match-vector-multiple (@v A B C D E F G H I J K 2 <>) (- N 1))
  (@v A B C D E F G H I J K 3 <>) N -> (match-vector-multiple (@v A B C D E F G H I J K 3 <>) (- N 1))
  (@v A B C D E F G H I J K 4 <>) N -> (match-vector-multiple (@v A B C D E F G H I J K 4 <>) (- N 1))
  (@v A B C D E F G H I J K 5 <>) N -> (match-vector-multiple (@v A B C D E F G H I J K 5 <>) (- N 1))
  (@v A B C D E F G H I J K 6 <>) N -> (match-vector-multiple (@v A B C D E F G H I J K 6 <>) (- N 1))
  (@v A B C D E F G H I J K 7 <>) N -> (match-vector-multiple (@v A B C D E F G H I J K 7 <>) (- N 1))
  (@v A B C D E F G H I J K 8 <>) N -> (match-vector-multiple (@v A B C D E F G H I J K 8 <>) (- N 1))
  (@v A B C D E F G H I J K 9 <>) N -> (match-vector-multiple (@v A B C D E F G H I J K 9 <>) (- N 1))
  (@v A B C D E F G H I J K L <>) N -> (match-vector-multiple (@v A B C D E F G H I J K L <>) (- N 1))
  Other N -> (match-vector-multiple Other (- N 1)))

(define match-string-single
  R 0 -> R
  (@s A B C D E F G H I J K L "X") N -> (match-string-single (@s A B C D E F G H I J K L "X") (- N 1))
  Other N -> (match-string-single Other (- N 1)))

(define match-string-multiple
  R 0 -> R
  (@s A B C D E F G H I J K L "A") N -> (match-string-multiple (@s A B C D E F G H I J K L "A") (- N 1))
  (@s A B C D E F G H I J K L "B") N -> (match-string-multiple (@s A B C D E F G H I J K L "B") (- N 1))
  (@s A B C D E F G H I J K L "C") N -> (match-string-multiple (@s A B C D E F G H I J K L "C") (- N 1))
  (@s A B C D E F G H I J K L "D") N -> (match-string-multiple (@s A B C D E F G H I J K L "D") (- N 1))
  (@s A B C D E F G H I J K L "E") N -> (match-string-multiple (@s A B C D E F G H I J K L "E") (- N 1))
  (@s A B C D E F G H I J K L "F") N -> (match-string-multiple (@s A B C D E F G H I J K L "F") (- N 1))
  (@s A B C D E F G H I J K L "G") N -> (match-string-multiple (@s A B C D E F G H I J K L "G") (- N 1))
  (@s A B C D E F G H I J K L "H") N -> (match-string-multiple (@s A B C D E F G H I J K L "H") (- N 1))
  (@s A B C D E F G H I J K L "I") N -> (match-string-multiple (@s A B C D E F G H I J K L "I") (- N 1))
  (@s A B C D E F G H I J K L "J") N -> (match-string-multiple (@s A B C D E F G H I J K L "J") (- N 1))
  (@s A B C D E F G H I J K L "X") N -> (match-string-multiple (@s A B C D E F G H I J K L "X") (- N 1))
  Other N -> (match-string-multiple Other (- N 1)))

(add-benchmark pattern-matching
  "pattern-matching control loop"
  (pattern-matching-control-loop 0)
  8)

(add-benchmark pattern-matching
  "match list (single clause, matching)"
  (match-list-single [0 1 2 3 4 5 6 7 8 9 9 9])
  8)
(add-benchmark pattern-matching
  "match list (single clause, not matching)"
  (match-list-single other)
  8)

(add-benchmark pattern-matching
  "match list (multiple clauses, matching)"
  (match-list-multiple [0 1 2 3 4 5 6 7 8 9 9 9])
  8)
(add-benchmark pattern-matching
  "match list (multiple clauses, not matching)"
  (match-list-multiple other)
  8)

(add-benchmark pattern-matching
  "match tuple (single clause, matching)"
  (match-tuple-single (@p 0 1 2 3 4 5 6 7 8 9 9 9))
  7)
(add-benchmark pattern-matching
  "match tuple (single clause, not matching)"
  (match-tuple-single other)
  8)

(add-benchmark pattern-matching
  "match tuple (multiple clauses, matching)"
  (match-tuple-multiple (@p 0 1 2 3 4 5 6 7 8 9 9 9))
  7)
(add-benchmark pattern-matching
  "match tuple (multiple clauses, not matching)"
  (match-tuple-multiple other)
  8)

(add-benchmark pattern-matching
  "match vector (single clause, matching)"
  (match-vector-single (@v 0 1 2 3 4 5 6 7 8 9 9 9 <>))
  4)
(add-benchmark pattern-matching
  "match vector (single clause, not matching)"
  (match-vector-single other)
  8)

(add-benchmark pattern-matching
  "match vector (multiple clauses, matching)"
  (match-vector-multiple (@v 0 1 2 3 4 5 6 7 8 9 9 9 <>))
  4)
(add-benchmark pattern-matching
  "match vector (multiple clauses, not matching)"
  (match-vector-multiple other)
  8)

(add-benchmark pattern-matching
  "match string (single clause, matching)"
  (match-string-single "ABCDEFGHIJKLX")
  6)
(add-benchmark pattern-matching
  "match string (single clause, not matching)"
  (match-string-single other)
  8)

(add-benchmark pattern-matching
  "match string (multiple clauses, matching)"
  (match-string-multiple "ABCDEFGHIJKLX")
  6)
(add-benchmark pattern-matching
  "match string (multiple clauses, not matching)"
  (match-string-multiple other)
  8)

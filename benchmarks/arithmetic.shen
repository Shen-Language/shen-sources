\\ Copyright (c) 2026 Bruno Deferrari.
\\ BSD 3-Clause License: http://opensource.org/licenses/BSD-3-Clause

(define arithmetic-add
  _ _ R 0 -> R
  A B _ N -> (arithmetic-add A B (+ A B) (- N 1)))

(define arithmetic-multiply
  _ _ R 0 -> R
  A B _ N -> (arithmetic-multiply A B (* A B) (- N 1)))

(add-benchmark arithmetic "addition (integers)"
  (arithmetic-add 1 2 0) 6)

(add-benchmark arithmetic "addition (integer/fractional)"
  (arithmetic-add 1 2.5 0) 6)

(add-benchmark arithmetic "multiply (integers)"
  (arithmetic-multiply 3 7 0) 6)

(add-benchmark arithmetic "multiply (integer/fractional)"
  (arithmetic-multiply 3 2.5 0) 6)

(define even*?
  1 -> false
  X -> (odd*? (- X 1)))

(define odd*?
  1 -> true
  X -> (even*? (- X 1)))

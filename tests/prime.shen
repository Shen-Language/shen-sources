(define prime?
  X -> (prime* X (/ X 2) 2))

(define prime*
  X Max Div -> false	where (integer? (/ X Div))
  X Max Div -> true	where (> Div Max)
  X Max Div -> (prime* X Max (+ 1 Div)))

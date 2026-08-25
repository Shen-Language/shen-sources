(define simp
 Want Have -> (simp Want (succ Have)) where (< Have Want)
 Want Have -> Have)

(define <
  X X -> false
  X Y -> (<= X Y))

(define <=
  0 _ -> true
  _ 0 -> false
  X Y -> (<= (pred X) (pred Y)))

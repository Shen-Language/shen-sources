(package lkl (lkl-external-symbols)

(declare eval [term --> term])

(define store-axioms
  [defun F Params Body] -> (put F axioms (axiomatic-semantics (subst == = [defun F Params Body])))
  _ -> [])

(define get-axioms
  F -> (trap-error (get F axioms) (/. E [])))

(define succ
  N -> (+ N 1))

(define pred
  0 -> (abort)
  N -> (- N 1))

(declare succ   [nat --> nat])
(declare pred   [nat --> nat])

(declare get-axioms [proper-symbol --> [list prop]])

(declare store-axioms  [unit --> [list prop]])   )

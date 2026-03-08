(define append
  [] X -> X
  [X | Y] Z -> [X | (append Y Z)]
  _ _ -> (simple-error "attempt to append a non-list"))
  
(define reverse
  [] -> []
  [X | Y] -> (append (reverse Y) [X]))  

(define assoc
  _ [] -> []
  X [[X | Y] | _] -> [X | Y]
  X [_ | Y] -> (assoc X Y)
  _ _ -> (error "attempt to search a non-list with assoc~%"))

(define boolean?
  true -> true
  false -> true
  _ -> false)

(define difference
  [] _ -> []
  [X | Y] Z -> (if (element? X Z) (difference Y Z) [X | (difference Y Z)])
  _ _ -> (error "attempt to find the difference with a non-list~%"))

(define do
  X Y -> Y)

(define element?
  _ [] -> false
  X [X | _] -> true
  X [_ | Z] -> (element? X Z)
  _ _ -> (error "attempt to find an element in a non-list~%"))

(define empty?
  [] -> true
  _ -> false)
  
(define fix
  F X -> (fix-help F X (F X)))

(define fix-help
  _ X X -> X
  F _ X -> (fix-help F X (F X)))

(define sum
  [] -> 0
  [N | Ns] -> (add N (sum Ns))
  _ -> (error "attempt to sum a non-list~%"))

(define head
  [X | _] -> X
  _ -> (error "head expects a non-empty list~%"))

(define tail
  [_ | Y] -> Y
  _ -> (error "tail expects a non-empty list~%"))

(define intersection
  [] _ -> []
  [X | Y] Z -> (if (element? X Z) [X | (intersection Y Z)] (intersection Y Z))
  _ _ -> (error "attempt to find the intersection with a non-list~%"))
  
(define union
  [] X -> X
  [X | Y] Z -> (if (element? X Z) (union Y Z) [X | (union Y Z)])
  _ _ -> (error "attempt to find the union with a non-list~%"))

(define subst
  X Y Y -> X
  X Y [W | Z] -> [(subst X Y W) | (subst X Y Z)]
  _ _ Z -> Z)

(define map
  F X -> (map-h F X []))
  
(define map-h
  F [] Acc -> (reverse Acc)
  F [X | Y] Acc -> (map-h F Y [(F X) | Acc]))  
 
(define length
  X -> (length-h X 0))

(define length-h
  [] N -> N
  X N -> (length-h (tl X) (add N 1))
  _ _ -> (error "attempt to find the length of a non-list~%"))

(define occurrences
  X X -> 1
  X [Y | Z] -> (add (occurrences X Y) (occurrences X Z))
  _ _ -> 0)
  
(define add
  0 X -> X
  X Y -> (succ (add (pred X) Y)))  

(define nth 
  1 [X | _] -> X
  N [_ | Y] -> (nth (- N 1) Y)
  N X -> (error "nth applied to ~A, ~A~%" N X))
  

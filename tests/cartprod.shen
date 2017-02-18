(define cartesian-product
  [] _ -> []
  [X | Y] Z -> (append (all-pairs-using-X X Z) (cartesian-product Y Z)))

(define all-pairs-using-X
  _ [] -> []
  X [Y | Z] -> [[X Y] | (all-pairs-using-X X Z)])

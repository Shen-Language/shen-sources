(define powerset
  [] -> [[]]
  [X | Y] -> (let Powerset (powerset Y)
               (append (cons-X-to-each-set X Powerset) Powerset)))

(define cons-X-to-each-set
  _ [ ] -> [ ]
  X [Y | Z] -> [[X | Y] | (cons-X-to-each-set X Z)])

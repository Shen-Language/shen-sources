(define ppm.match-simple
  [two A B] -> [A B]
  _ -> no)

(define ppm.match-repeat
  [two X X] -> same
  [two _ _] -> different)

(define ppm.match-nested
  [two [two A B] C] -> [A B C]
  _ -> no)

(define ppm.match-cons
  [H | T] -> [H T]
  _ -> no)

(define ppm.match-literal-list
  [1 2] -> yes
  _ -> no)

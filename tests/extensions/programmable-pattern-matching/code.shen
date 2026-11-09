(define ppm.match-simple
  (two A B) -> [A B]
  _ -> no)

(define ppm.match-repeat
  (two X X) -> same
  (two _ _) -> different)

(define ppm.match-nested
  (two (two A B) C) -> [A B C]
  _ -> no)

(define ppm.match-cons
  [H | T] -> [H T]
  _ -> no)

(define ppm.match-literal-list
  [1 2] -> yes
  _ -> no)

(define ppm.match-list-argument
  (two [A | _] B) -> [A B]
  _ -> no)

(define ppm.match-literal-list-argument
  (two [A B] C) -> [A B C]
  _ -> no)

(define ppm.match-nested-list-argument
  (two (two [A | _] B) C) -> [A B C]
  _ -> no)

(define ppm.match-custom-in-list
  [(two A B) | _] -> [A B]
  _ -> no)

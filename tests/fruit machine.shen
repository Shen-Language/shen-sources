(define return-fruit
  0 -> cherry
  1 -> cherry
  2 -> cherry
  3 -> cherry
  4 -> cherry
  5 -> pear
  6 -> pear
  7 -> pear
  8 -> pear
  9 -> orange
  10 -> orange
  11 -> orange
  12 -> pineapple
  13 -> pineapple
  14 -> lemon)

(define spin-wheel
  -> (return-fruit (random 14)))

(define payoff
  cherry cherry cherry -> 60
  pear pear pear -> 100
  orange orange orange -> 200
  pineapple pineapple pineapple -> 300
  lemon lemon lemon -> 500
  cherry cherry X -> 10
  X cherry cherry -> 10
  pear pear X -> 20
  X pear pear -> 20
  orange orange X -> 30
  X orange orange -> 30
  pineapple pineapple X -> 40
  X pineapple pineapple -> 40
  lemon lemon X -> 50
  X lemon lemon -> 50
  X Y Z -> 0)

(define fruit-machine
  start -> (announce-payoff  (spin-wheel) (spin-wheel) (spin-wheel)))

(define announce-payoff
  Fruit1 Fruit2 Fruit3
  -> (output "~A ~A ~A~%You win ~A pence~%"
             Fruit1 Fruit2 Fruit3 (payoff Fruit1 Fruit2 Fruit3)))

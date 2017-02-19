(define count-change
  Amount -> (count-change* Amount 200))

(define count-change*
  0 _ -> 1
  _ 0 -> 0
  Amount _ -> 0  	where (> 0 Amount)
  Amount Fst_Denom
  -> (+ (count-change* (- Amount Fst_Denom) Fst_Denom)
        (count-change* Amount (next-denom Fst_Denom))))

(define next-denom
  200 -> 100
  100 -> 50
  50 -> 20
  20 -> 10
  10 -> 5
  5 -> 2
  2 -> 1
  1 -> 0)

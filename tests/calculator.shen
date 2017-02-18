(datatype arith-expr

  X : number;
  ====================
  [num X] : arith-expr;

  if (element? Op [+ - * /])
  X : arith-expr; Y : arith-expr;
  ===============================
  [X Op Y] : arith-expr;)

(define do-calculation
  {arith-expr --> number}
  [X + Y] -> (+ (do-calculation X) (do-calculation Y))
  [X - Y] -> (- (do-calculation X) (do-calculation Y))
  [X * Y] -> (* (do-calculation X) (do-calculation Y))
  [X / Y] -> (/ (do-calculation X) (do-calculation Y))
  [num X] -> X)

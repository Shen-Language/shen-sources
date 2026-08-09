(define non-standard-boolean-algebra
   {--> symbol}
    -> (kb-> (protect [[[or X [or Y Z]] = [or Y [or X Z]]]
              [[and X Y] = [not [or [not X] [not Y]]]]
              [[or X [not X]] = [or Y [not Y]]]
              [[and [or X [not Y]] [or X Y]] = X]])))

(define distributivity
  {--> prop}
  -> [[and a [or b c]] = [or [and a b] [and a c]]])
  
(<-kb (distributivity))  
(package tuple [pairoff assocp cartprodp assocp-if assocp-if-not]

  (define pairoff
    {(list A) --> (list B) --> (list (A * B))}
     [] _ -> []
     _ [] -> []
     [X | Y] [W | Z] -> [(@p X W) | (pairoff Y Z)])
     
  (define assocp
    {A --> (list (A * B)) --> (A * B)}
     _ [] -> (error "pair not found~%")
     X [(@p X Y) | _] -> (@p X Y)
     X [_ | Pairs] -> (assocp X Pairs))
     
  (define cartprodp
    {(list A) --> (list B) --> (list (A * B))}
     [] _ -> []
     [X | Y] Z -> (append (map (/. W (@p X W)) Z) (cartprodp Y Z)))
     
  (define assocp-if
    {(A --> boolean) --> (list (A * B)) --> (A * B)}
     _ [] -> (error "pair not found~%")
     F? [(@p X Y) | _] -> (@p X Y)   where (F? X)
     F? [_ | Pairs] -> (assocp-if F? Pairs))    
     
  (define assocp-if-not
    {(A --> boolean) --> (list (A * B)) --> (A * B)}
     _ [] -> (error "pair not found~%")
     F? [(@p X Y) | _] -> (@p X Y)   where (not (F? X))
     F? [_ | Pairs] -> (assocp-if-not F? Pairs))  )   
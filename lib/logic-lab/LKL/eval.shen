(define evaluate
  [cons? X]            -> (cons? (evaluate X))
  [cons X Y]           -> [cons (evaluate X) (evaluate Y)]
  [lambda X Y]         -> [lambda X Y]
  [if X Y Z]           -> (if (evaluate X) (evaluate Y) (evaluate Z))
  [cond [P X] | Cases] -> (if (evaluate P) (evaluate X) (evaluate [cond | Cases]))
  [and P Q]            -> (and (evaluate P) (evaluate Q))
  [or P Q]             -> (or (evaluate P) (evaluate Q))
  [not P]              -> (not (evaluate P))
  [hd [cons X Y]]      -> X
  [tl [cons X Y]]      -> Y
  [= X Y]              -> (= (evaluate X) (evaluate Y))
  [[lambda X Y] Z]     -> (evaluate (subst (evaluate Z) X Y))
  [[lambda X Y] W | Z] -> (evaluate [[[lambda X Y] W] | Z])
  [[X | Y] | Z]        -> (evaluate [(evaluate [X | Y]) | Z]) 
  [F | X]              -> (let Lambda  (trap-error (snd (assocp F (value *E*))) 
                                                   (/. E (error "~A is undefined~%" F)))
                               Apply [Lambda | X]
                               (evaluate Apply))
  X                    -> X)
  
(define def
  F X -> (set *E* [(@p F X) | (value *E*)])) 
  
(set *E* [(@p append [lambda X [lambda Y [cond [[= X []] Y]
                                               [[cons? X] [cons [hd X] [append [tl X] Y]]]]]])]) 
                                               
(evaluate [append [cons 0 [cons 1 []]]  [cons 2 []]])

                                             
                          
                    
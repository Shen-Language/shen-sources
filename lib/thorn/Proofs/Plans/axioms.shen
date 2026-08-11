
 (define rcc-axioms
  {--> (list prop)}
   -> [(c-refl) (c-symm) (def-dc) (def-p) (def-p) (def-pp) (def-e=) (def-o)
       (def-po) (def-ec) (def-dr) (def-tpp) (def-ntpp) (def-p-1) (def-pp-1)
       (def-tpp-1) (def-ntpp-1)])
  
(define group-theory
  {--> (list prop)}
  -> [[all x [all y [all z [[+ x [+ y z]] = [+ [+ x y] z]]]]]
      [all x [[+ e x] = x]] 
      [all x [[+ x e] =  x]]
      [all x [[+ x [inv x]] = e]]])
  
(define c-refl
  {--> prop}
   -> [all x [c x x]])
   
(define c-symm
 {--> prop}
  -> [all x [all y [[c x y] => [c y x]]]])
  
(define def-dc
 {--> prop}
 -> [all x [all y [[dc x y] <=> [~ [c x y]]]]])
 
(define def-p 
  {--> prop}
  -> [all x [all y [[p x y] <=> [all z [[c z x] => [c z y]]]]]])
  
(define def-pp
  {--> prop}  
  -> [all x [all y [[pp x y] <=> [[p x y] & [~ [p y x]]]]]])
  
(define def-e=
  {--> prop}  
  -> [all x [all y [[e= x y] <=> [[p x y] & [p y x]]]]])
  
(define def-o
  {--> prop}
  -> [all x [all y [[o x y] <=> [exists z [[p z x] & [p z y]]]]]])
  
(define def-po
  {--> prop}
  -> [all x [all y [[po x y] <=> [[o x y] & [[~ [p x y]] & [~ [p y x]]]]]]])
  
(define def-ec  
  {--> prop}
  -> [all x [all y [[ec x y] <=> [[c x y] & [~ [o x y]]]]]])
  
(define def-dr  
  {--> prop}
  -> [all x [all y [[dr x y] <=> [~ [o x y]]]]])
  
(define def-tpp
    {--> prop}
    -> [all x [all y [[tpp x y] <=> [[pp x y] & [exists z [[ec z x] & [ec z y]]]]]]])
    
(define def-ntpp
    {--> prop}    
   -> [all x [all y [[ntpp x y] <=> [[pp x y] & [~ [exists z [[ec z x] & [ec z y]]]]]]]])

(define def-p-1
   {--> prop}    
   -> [all x [all y [[p-1 x y] <=> [p y x]]]])
   
 (define def-pp-1
   {--> prop}      
   -> [all x [all y [[pp-1 x y] <=> [pp y x]]]])
   
 (define def-tpp-1
   {--> prop}  
   -> [all x [all y [[tpp-1 x y] <=> [tpp y x]]]])
   
 (define def-ntpp-1 
   {--> prop} 
  -> [all x [all y [[ntpp-1 x y] <=> [ntpp y x]]]])   
      
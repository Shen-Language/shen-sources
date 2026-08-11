\* 13 shortest single axioms

   P(e(e(x,y),e(e(z,y),e(x,z)))) # label("Peterson 1, YQL").
   P(e(e(x,y),e(e(x,z),e(z,y)))) # label("Peterson 2, YQF").
   P(e(e(x,y),e(e(z,x),e(y,z)))) # label("Peterson 3, YQJ").
   P(e(e(e(x,y),z),e(y,e(z,x)))) # label("Peterson 4, UM").
   P(e(x,e(e(y,e(x,z)),e(z,y)))) # label("Peterson 5, XGF").
   P(e(e(x,e(y,z)),e(z,e(x,y)))) # label("Peterson 7, WN").
   P(e(e(x,y),e(z,e(e(y,z),x)))) # label("Peterson 8, YRM").
   P(e(e(x,y),e(z,e(e(z,y),x)))) # label("Peterson 9, YRO").
   P(e(e(e(x,e(y,z)),z),e(y,x))) # label("PYO").
   P(e(e(e(x,e(y,z)),y),e(z,x))) # label("PYM").
   P(e(x,e(e(y,e(z,x)),e(z,y)))) # label("XGK").
   P(e(x,e(e(y,z),e(e(x,z),y)))) # label("XHK").
   P(e(x,e(e(y,z),e(e(z,x),y)))) # label("XHN"). *\

(thorn.defaults)
(thorn.depth 13)

(define mp
  {--> prop}
  -> [all x [all y [[[p [e x y]] & [p x]] => [p y]]]])       

(define yql
  {--> prop}
   -> [all x [all y [all z [p [e [e x y] [e [e z y] [e x z]]]]]]])
   
(define yqf
  {--> prop}
   -> [all x [all y [all z [p [e [e x y] [e [e x z] [e z y]]]]]]])
   
(define yqj
  {--> prop}
   -> [all x [all y [all z [p [e [e x y] [e [e z x] [e y z]]]]]]])
      
(define um
  {--> prop}
   -> [all x [all y [all z [p [e [e [e x y] z] [e y [e z x]]]]]]])
  
(define xgf
  {--> prop}
  -> [all x [all y [all z [p [e x [e [e y [e x z]] [e z y]]]]]]])
  
(define wn
  {--> prop}
  -> [all x [all y [all z [p [e [e x [e y z]] [e z [e x y]]]]]]]) 
  
(define yrm
  {--> prop}
  -> [all x [all y [all z [p [e [e x y] [e z [e [e y z] x]]]]]]])
  
(define yro
  {--> prop}
  -> [all x [all y [all z [p [e [e x y] [e z [e [e z y] x]]]]]]])  
  
(define pyo
  {--> prop}
  ->  [all x [all y [all z [p [e [e [e x [e y z]] z] [e y x]]]]]])
  
(define pym
  {--> prop}
  ->  [all x [all y [all z [p [e [e [e x [e y z]] y] [e z x]]]]]])
  
(define xgk
  {--> prop}
  ->  [all x [all y [all z [p [e x [e [e y [e z x]] [e z y]]]]]]])
  
(define xhk
  {--> prop}
  ->  [all x [all y [all z [p [e x [e [e y z] [e [e x z] y]]]]]]])
    
(define xhn
  {--> prop}
  ->  [all x [all y [all z [p [e x [e [e y z] [e [e z x] y]]]]]]])   
        
(define ec   
  {--> prop}
   -> [[[p [e x x]] & [p [e [e x y] [e y x]]]] 
                               & [p [e [e x y] [e [e y z] [e x z]]]]]) 
                               
(kb-> [(mp) (yql)])
(<-kb (ec))                                
                               
\*

 Try any of these and then enter (<-kb (ec)) 

(kb-> [(mp) (yql)])  1.25 sec; depth 13
          
(kb-> [(mp) (yqf)])   0.15 solution at depth 11

(kb-> [(mp) (yqj)])   2.43 sec; depth 13

(kb-> [(mp) (um)])   no solution at depth 12  refl depth 11/3.57, sym ns at 12, trans ns at 11 

(kb-> [(mp) (xgf)])   no solution at depth 12  refl,symm, trans depth 12/ns

(kb-> [(mp) (wn)])   no solution at depth 13 refl 10.9/depth 3

(kb-> [(mp) (yrm)])   no solution at depth 11

(kb-> [(mp) (yro)])   no solution at depth 11

(kb-> [(mp) (pyo)])   no solution at depth 14 refl depth 13/0.47

(kb-> [(mp) (pym)])   no solution at depth 12 for all problems   

(kb-> [(mp) (xgk)])   no solution at depth 12 refl depth 11/.01   

(kb-> [(mp) (xhk)])   no solution at depth 11 for all problems

(kb-> [(mp) (xhn)])   no solution at depth 11 for all problems *\


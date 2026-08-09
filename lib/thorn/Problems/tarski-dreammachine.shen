(define tarski
  {-->  symbol}
  -> (kb-> [
                \\1
                [all a [all b [[between a b a] => [a = b]]]]

                \\2
               [all a [all b [all c [all d [all e [all f [[[equi a b c d] & [equi a b e f]] => [equi c d e f]]]]]]]]

               \\3 
               [all a [all b [equi a b b a]]]

                \\4                
                [all a [all b [all c [[equi a b c c] => [a = b]]]]]

                \\5                
                [all a [all p [all c [all b [all q [[[between a p c] & [between b q c]] 
                    => [exists x [[between p x b] & [between q x a]]]]]]]]]

                \\6
                [all a [all d [all t [all b [all c [[[between a d t] & [[between b d c] & [~ [eq a d]]]]
                                     => [exists x [exists y [[[between a b x] & [between a c y]] & [between x t y]]]]]]]]]]
                                      
                \\7
                [all a [all b [all a* [all b* [all c [all c* [all d [all d*
                  [[[[[equi a b a* b*] & [equi b c b* c*]] & [[between a b c] 
                & [between a* b* c*]]] & [~ [a = b]]] => [equi c d c* d*]]]]]]]]]] 
                                      
                \\8
                [all a [all b [all c [exists e [[between a b e] & [equi b e c d]]]]]]

                \\9
                [exists a [exists b [exists c [[between a b c] & [[~ [between b c a]] & [~ [between c a b]]]]]]]

                \\10
                [all a [all p [all q [all b [all c 
                  [[[[equi a p a q] & [equi b p b q]] & [[equi c p c q] & [~ [p = q]]]] 
                       => [[[between a b c] v [between b c a]] v [between c a b]]]]]]]]
                  
               \\11
                [all x* [all y* [[exists a [all x [all y [[[mem x x*] & [mem y y*]] => [between a x y]]]]]
                                 => [exists b [all x [all y [[mem x x*] => [[mem y y*] => [between x b y]]]]]]]]] 
                     ]))
                                 
(tarski)                                 

(thorn.depth 9)
(thorn.complex 15)
               
(<-kb [all x [all y [equi x y x y]]])
(<-kb [all x [all y [all z [all w [[equi x y z w] => [equi z w x y]]]]]])
(<-kb [all w [all x [all y [all z [all u [all t [[[equi x y z u] & [equi x y t w]] => [equi z u t w]]]]]]]])         

(<-kb [all x [all y [all z [all w [[equi x y z w] => [equi x y w z]]]]]])
(<-kb [all x [all y [all z [all w [[equi x y z w] => [equi y x z w]]]]]])
(<-kb [all x [all y [all z [all w [[equi x y z w] => [equi y x w z]]]]]])

(thorn.depth 10)
(<-kb [all x [all y [between x x y]]]) 
\\(<-kb [all x [all y [all z [[between x y z] => [between x z y]]]]]) too hard

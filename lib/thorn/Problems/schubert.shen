(thorn.defaults)

(define schubert
  {--> symbol}
   -> (kb-> [ [all x [[wolf x] => [animal x]]]
        [all x [[fox x] => [animal x]]]
        [all x [[bird x] => [animal x]]]
        [all x [[caterpillar x] => [animal x]]]
        [all x [[snail x] => [animal x]]]
        [all x [[grain x] => [plant x]]]
        
        [exists x [wolf x]]
        [exists x [fox x]]
        [exists x [bird x]]
        [exists x [caterpillar x]]
        [exists x [snail x]]
        [exists x [grain x]]
        
        [all x [[animal x] => [[all y [[plant y] => [eats x y]]]
                    v 
                    [all z [[[[animal z] &
                             [smaller z x]] &
                             [exists u [[plant u] & [eats z u]]]]
                             => 
                             [eats x z]]]]]]

        [all x [all y [[[caterpillar x] & [bird y]] => [smaller x y]]]]
        [all x [all y [[[snail x] & [bird y]]  =>  [smaller x y]]]]
        [all x [all y [[[bird x] & [fox y]]  =>  [smaller x y]]]]
        [all x [all y [[[fox x] & [wolf y]]  =>  [smaller x y]]]]
        [all x [all y [[[bird x] & [caterpillar y]]  =>  [eats x y]]]]
        
        [all x [[caterpillar x]  
                 =>  [exists y [[plant y] & [eats x y]]]]]
        [all x [[snail x]        
                 =>  [exists y [[plant y] & [eats x y]]]]]

        [all x [all y [[[wolf x] & [fox y]]  =>  [~ [eats x y]]]]]
        [all x [all y [[[wolf x] & [grain y]]  =>  [~ [eats x y]]]]]
        [all x [all y [[[bird x] & [snail y]]  =>  [~ [eats x y]]]]] ]))
                     
(schubert)  

(define steamroller
  {--> prop}
   -> [exists x [exists y [[[animal x] &
	                       [animal y]] &
	                         [[eats x y] &
                              [all z [[grain z] => [eats y z]]]]]]])

(<-kb (steamroller))                              
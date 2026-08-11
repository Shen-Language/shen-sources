(thorn.defaults)

(define st
  {--> symbol}
  -> (kb-> [[all x [~ [m x e]]]
                [all x [all y [[[sub x y] & [sub y x]] <=> [=s x y]]]]
                [all x [all y [[sub x y] <=> [all z [[m z x] => [m z y]]]]]]
                [all x [all y [[pow x y] <=> [all z [[m z x] <=> [sub z y]]]]]]
                [all x [all y [[com x y] <=> [all z [[m z x] <=> [~ [m z y]]]]]]]
                [all x [all y [all z [[prod x y z] <=> [all w [[m w x] <=> [[pair w] & [[m [fst w] y] & [m [snd w] z]]]]]]]]] 
                [all x [all y [all z [[int x y z] <=> [all w [[m w x] <=> [[m w y] & [m w z]]]]]]]]
                [all x [all y [all z [[un x y z] <=> [all w [[m w x] <=> [[m w y] v [m w z]]]]]]]]]))
                
(st)                      
            
(<-kb  [un a a a])  
(<-kb  [int a a a] )
(<-kb  [all x [all y [all z [[un x y z] <=> [un x z y]]]]])             
(<-kb  [all x [all y [[pow x y] => [m y x]]]])
(<-kb  [all x [all y [[prod x y e] => [=s x e]]]])
(<-kb  [all x [all y [[sub x y] <=> [un y x y]]]])
(<-kb  [[[com x y] & [com y z]] => [=s x z]])
(<-kb  [~ [com a a]])
(<-kb [[int a b c] => [[sub a b] & [sub a c]]])

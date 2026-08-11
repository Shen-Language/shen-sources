(thorn.depth 14)

(define dreadbury
  {--> symbol}
  -> (kb->
        [ [exists x [[lives x] & [killed x agatha]]]

        [lives agatha]

        [lives butler]

        [lives charles]
        
        [all x [[lives x] => [[x = agatha] v [[x = butler] v [x = charles]]]]]
        
        [all x [all y [[killed x y] => [hates x y]]]]

        [all x [all y [[killed x y] => [~ [richer x y]]]]]

        [all x [[hates agatha x] => [~ [hates charles x]]]]

        [all x [[~ [x = butler]] => [hates agatha x]]]

        [all x [[~ [richer x agatha]] => [hates butler x]]]

        [all x [[hates agatha x] => [hates butler x]]]

        [all x [exists y [~ [hates x y]]]]

        [~ [butler = agatha]]]))
        
(dreadbury)        
    
(<-kb [killed agatha agatha])

(set thorn.*paramodulate?* true)
(set thorn.*depth* 14)

(define dreadbury
  {--> symbol}
  -> (kb->
        [[[lives killer] & [killed killer agatha]]

        [lives agatha]

        [lives butler]

        [lives charles]
        
        [all x [[lives x] => [[eq x agatha] v [[eq x butler] v [eq x charles]]]]]
        
        [all x [all y [[killed x y] => [hates x y]]]]

        [all x [all y [[killed x y] => [~ [richer x y]]]]]

        [all x [[hates agatha x] => [~ [hates charles x]]]]

        [all x [[~ [eq x butler]] => [hates agatha x]]]

        [all x [[~ [richer x agatha]] => [hates butler x]]]

        [all x [[hates agatha x] => [hates butler x]]]

        [all x [exists y [~ [hates x y]]]]

        [~ [eq butler agatha]]]))
        
(dreadbury)        
    
(<-kb [killed agatha agatha])

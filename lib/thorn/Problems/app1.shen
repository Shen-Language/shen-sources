(set thorn.*=l?* true)
(set thorn.*depth* 6)

(define appaxioms
  {--> symbol}
   -> (kb-> [     [all w [eq [append [] w] w]]
                  [all w [all x [all y [eq [append [@c w x] y] [@c w [append x y]]]]]] ]))
      
(appaxioms)
                                
(<-kb [eq [append [] []] []])
                                     
(<-kb [eq [append [@c tm1 []] []] [@c tm1 []]])

(<-kb [eq [append [@c tm2 [@c tm1 []]] []] [@c tm2 [@c tm1 []]]])

(<-kb [eq [append [@c tm3 [@c tm2 [@c tm1 []]]] []] [@c tm3 [@c tm2 [@c tm1 []]]]])



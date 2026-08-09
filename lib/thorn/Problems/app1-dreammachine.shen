(thorn.defaults)
(thorn.depth 6)

(define appaxioms
  {--> symbol}
   -> (kb-> [     [all w [[append [] w] = w]]
                  [all w [all x [all y [[append [cons w x] y] = [cons w [append x y]]]]]] ]))
      
(appaxioms)
                                
(<-kb [ [append [] []] = []])
                                     
(<-kb [ [append [cons tm1 []] []] = [cons tm1 []]])

\\(<-kb [ [append [cons tm2 [cons tm1 []]] []] = [cons tm2 [cons tm1 []]]]) - bug to be investigated

\\(<-kb [ [append [cons tm3 [cons tm2 [cons tm1 []]]] []] = [cons tm3 [cons tm2 [cons tm1 []]]]])



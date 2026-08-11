(thorn.depth 8)

(define group
  {--> symbol}
-> (kb-> 
      [[all x [all y [all z [[+ x [+ y z]] = [+ [+ x y] z]]]]]
       [all x [[+ e x] = x]]
       [all x [[+ x e] =  x]]
       [all x [[+ x [inv x]] = e]]]))
       
(group)       
       
(thorn.complex 14)
(<-kb [all a [all x [[[+ a x] = e] => [a = [inv x]]]]])
(thorn.complex 16)
(<-kb [all x [[inv [inv x]] = x]]) 




       
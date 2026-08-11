(set thorn.*depth* 8)
(set thorn.*=l?* true)

(define group
  {--> symbol}
-> (kb-> 
      [[all x [all y [all z [eq [+ x [+ y z]] [+ [+ x y] z]]]]]
       [all x [eq [+ e x] x]]
       [all x [eq [+ x e] x]]
       [all x [eq [+ x [inv x]] e]]]))
       
(group)       
       
(<-kb [all a [all x [[eq [+ a x] e] => [eq a [inv x]]]]])
(<-kb [all x [eq [inv [inv x]] x]]) 




       
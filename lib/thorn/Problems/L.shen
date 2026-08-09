(set thorn.*depth* 8)
(set thorn.*paramodulate?* false)

(define system-L
 {--> symbol}
 -> (kb-> 

      (protect [[prv [imp P [imp Q P]]]
      [prv [imp [imp P [imp Q R]] [imp [imp P Q] [imp P R]]]]
      [prv [imp [imp [neg P] [neg Q]] [imp [imp [neg P] Q] P]]]
      [[[prv [imp P Q]] & [prv P]] => [prv Q]]
      
      [[prv [or P Q]] <=> [prv [imp [neg P] Q]]]
      [[prv [and P Q]] <=> [prv [neg [or [neg P] [neg Q]]]]]
      [[prv [equiv P Q]] <=> [prv [and [imp P Q] [imp Q P]]]]])))
      
(system-L)

(<-kb [prv [imp p p]])
(<-kb [prv [or p [neg p]]])
(<-kb [prv [imp [neg [neg p]] p]])
(<-kb [prv [imp p [neg [neg p]]]]) \\ too hard?
(<-kb [prv [imp [and p q] p]]) \\ too hard?



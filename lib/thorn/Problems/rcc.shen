(prolog-memory 1e6)
(thorn.defaults)
    
(define rcc
  {--> symbol}
   -> 
      (kb-> 
       [[all x [c x x]]
       [all x [all y [all x [all y [[c x y] => [c y x]]]]]]
       [all x [all y [[dc x y] <=> [~ [c x y]]]]]
       [all x [all y [[p x y] <=> [all z [[c z x] => [c z y]]]]]]
       [all x [all y [[pp x y] <=> [[p x y] & [~ [p y x]]]]]]
       [all x [all y [[e x y] <=> [[p x y] & [p y x]]]]]
       [all x [all y [[o x y] <=> [exists z [[p z x] & [p z y]]]]]]
       [all x [all y [[po x y] <=> [[o x y] & [[~ [p x y]] & [~ [p y x]]]]]]]
       [all x [all y [[ec x y] <=> [[c x y] & [~ [o x y]]]]]]
       [all x [all y [[dr x y] <=> [~ [o x y]]]]]
       [all x [all y [[tpp x y] <=> [[pp x y] & [exists z [[ec z x] & [ec z y]]]]]]]
       [all x [all y [[ntpp x y] <=> [[pp x y] & [~ [exists z [[ec z x] & [ec z y]]]]]]]]]))  
       
       (rcc)   
       
(<-kb [[[tpp a b] & [ec b c]] => [[dc a c] v [ec a c]]]) \\ run time: 0.7 secs, 6,374,719 inferences
(<-kb [[[tpp a b] & [tpp b c]] => [[tpp a c] v [ntpp a c]]])  \\ ??
(<-kb [[[tpp a b] & [dc b c]] => [dc a c]]) \\ run time: 0.0 secs 3468 inferences
(<-kb [[[tpp a b] & [po b c]] => [[[dc a c] v [ec a c]] v [[[po a c] v [tpp a c]] v [ntpp a c]]]])  \\??
(<-kb [[[tpp a b] & [nttp b c]] => [ntpp a c]]) \\??
(<-kb [[[tpp a b] & [e b c]] => [tpp a c]]) \\ ??
(<-kb [[[dc a b] & [ec b c]] => [[[dc a c] v [ec a c]] v [[[po a c] v [tpp a c]] v [ntpp a c]]]]) \\ ??
(<-kb [[[dc a b] & [po b c]] => [[[dc a c] v [ec a c]] v [[[po a c] v [tpp a c]] v [ntpp a c]]]]) \\ ??
(<-kb [[[dc a b] & [tpp b c]] => [[[dc a c] v [ec a c]] v [[[po a c] v [tpp a c]] v [ntpp a c]]]]) \\ ??

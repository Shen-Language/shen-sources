(prolog-memory 1e6)
(thorn.defaults)
(thorn.wipe-kb)
(thorn.timeout 5)
    
(define rcc
  {--> symbol}
   -> 
      (kb-> 
       [[all x [c x x]]
       [all x [all y [[c x y] => [c y x]]]]
       [all x [all y [[dc x y] <=> [~ [c x y]]]]]
       [all x [all y [[p x y] <=> [all z [[c z x] => [c z y]]]]]]
       [all x [all y [[pp x y] <=> [[p x y] & [~ [p y x]]]]]]
       [all x [all y [[e= x y] <=> [[p x y] & [p y x]]]]]
       [all x [all y [[o x y] <=> [exists z [[p z x] & [p z y]]]]]]
       [all x [all y [[po x y] <=> [[o x y] & [[~ [p x y]] & [~ [p y x]]]]]]]
       [all x [all y [[ec x y] <=> [[c x y] & [~ [o x y]]]]]]
       [all x [all y [[dr x y] <=> [~ [o x y]]]]]
       [all x [all y [[tpp x y] <=> [[pp x y] & [exists z [[ec z x] & [ec z y]]]]]]]
       [all x [all y [[ntpp x y] <=> [[pp x y] & [~ [exists z [[ec z x] & [ec z y]]]]]]]]
       [all x [all y [[p-1 x y] <=> [p y x]]]]
       [all x [all y [[pp-1 x y] <=> [pp y x]]]]
       [all x [all y [[tpp-1 x y] <=> [tpp y x]]]]
       [all x [all y [[ntpp-1 x y] <=> [ntpp y x]]]]]))  
       
       (rcc)   
       
(<-kb [all x [all y [all z [[[dc x y] & [ec y z]] => [[[[[dc x z] v [ec x z]] v [po x z]] v [tpp x z]] v [ntpp x z]]]]]]) \\ plan solved

(<-kb [all x [all y [all z [[[dc x y] & [po y z]] => [[[[[dc x z] v [ec x z]] v [po x z]] v [tpp x z]] v [ntpp x z]]]]]])

(<-kb [all x [all y [all z [[[dc x y] & [tpp y z]] => [[[[[dc x z] v [ec x z]] v [po x z]] v [tpp x z]] v [ntpp x z]]]]]])

(<-kb [all x [all y [all z [[[dc x y] & [ntpp y z]] => [[[[[dc x z] v [ec x z]] v [po x z]] v [tpp x z]] v [ntpp x z]]]]]])

(<-kb [all x [all y [all z [[[dc x y] & [tpp-1 y z]] => [dc x z]]]]])

(<-kb [all x [all y [all z [[[dc x y] & [ntpp-1 y z]] => [dc x z]]]]])

(<-kb [all x [all y [all z [[[dc x y] & [e= y z]] => [dc x z]]]]])

(<-kb [all x [all y [all z [[[ec x y] & [dc y z]] => [[[[[dc x z] v [ec x z]] v [po x z]] v [tpp-1 x z]] v [ntpp-1 x z]]]]]])

(<-kb [all x [all y [all z [[[ec x y] & [ec y z]] => [[[[[dc x z] v [ec x z]] v [po x z]] v [tpp-1 x z]] v [[e= x z] v [tpp x z]]]]]]])

(<-kb [all x [all y [all z [[[ec x y] & [po y z]] => [[[[[dc x z] v [ec x z]] v [po x z]] v [tpp x z]] v [ntpp x z]]]]]])

(<-kb [all x [all y [all z [[[ec x y] & [tpp y z]] => [[[ec x z] v [po x z]] v [[tpp x z] v [ntpp x z]]]]]]])

(<-kb [all x [all y [all z [[[ec x y] & [ntpp y z]] => [[po x z] v [[tpp x z] v [ntpp x z]]]]]]])

(<-kb [all x [all y [all z [[[ec x y] & [tpp-1 y z]] => [[dc x z] v [ec x z]]]]]])

(<-kb [all x [all y [all z [[[ec x y] & [ntpp-1 y z]] => [dc x z]]]]])

(<-kb [all x [all y [all z [[[ec x y] & [e= y z]] => [ec x z]]]]])

(<-kb [all x [all y [all z [[[po x y] & [dc y z]] => [[[[[dc x z] v [ec x z]] v [po x z]] v [tpp-1 x z]] v [ntpp-1 x z]]]]]])

(<-kb [all x [all y [all z [[[po x y] & [ec y z]] => [[[[[dc x z] v [ec x z]] v [po x z]] v [tpp-1 x z]] v [ntpp-1 x z]]]]]])

(<-kb [all x [all y [all z [[[po x y] & [tpp y z]] => [[[po x z] v [tpp x z]] v [ntpp x z]]]]]])

(<-kb [all x [all y [all z [[[po x y] & [ntpp y z]] => [[[po x z] v [tpp x z]] v [ntpp x z]]]]]])

(<-kb [all x [all y [all z [[[po x y] & [tpp-1 y z]] => [[[[[dc x z] v [ec x z]] v [po x z]] v [tpp-1 x z]] v [ntpp-1 x z]]]]]])

(<-kb [all x [all y [all z [[[po x y] & [ntpp-1 y z]] => [[[[[dc x z] v [ec x z]] v [po x z]] v [tpp-1 x z]] v [ntpp-1 x z]]]]]])

(<-kb [all x [all y [all z [[[po x y] & [e= y z]] => [po x z]]]]])

(<-kb [all x [all y [all z [[[tpp x y] & [dc y z]] => [dc x z]]]]])

(<-kb [all x [all y [all z [[[tpp x y] & [ec y z]] => [[dc x z] v [ec x z]]]]]])

(<-kb [all x [all y [all z [[[tpp x y] & [po y z]] => [[[[dc x z] v [ec x z]] v [po x z]] v [[tpp x z] v [nttp x z]]]]]]])

(<-kb [all x [all y [all z [[[tpp x y] & [tpp y z]] => [[tpp x z] v [ntpp x z]]]]]])

(<-kb [all x [all y [all z [[[tpp x y] & [ntpp y z]] => [ntpp x z]]]]])

(<-kb [all x [all y [all z [[[tpp x y] & [tpp-1 y z]] => [[[[dc x z] v [ec x z]] v [po x z]] v [[e= x z] v [[tpp x z] v [tpp-1 x z]]]]]]]])

(<-kb [all x [all y [all z [[[tpp x y] & [ntpp-1 y z]] => [[[[dc x z] v [ec x z]] v [po x z]] v [[tpp-1 x z] v [ntpp-1 x z]]]]]]])

(<-kb [all x [all y [all z [[[tpp x y] & [e= y z]] => [tpp x z]]]]])

(<-kb [all x [all y [all z [[[ntpp x y] & [dc y z]] => [dc x z]]]]])

(<-kb [all x [all y [all z [[[ntpp x y] & [ec y z]] => [dc x z]]]]])

(<-kb [all x [all y [all z [[[ntpp x y] & [po y z]] => [[[[[dc x z] v [ec x z]] v [po x z]] v [tpp x z]] v [ntpp x z]]]]]])

(<-kb [all x [all y [all z [[[ntpp x y] & [tpp y z]] => [ntpp x z]]]]])

(<-kb [all x [all y [all z [[[ntpp x y] & [ntpp y z]] => [ntpp x z]]]]])

(<-kb [all x [all y [all z [[[ntpp x y] & [tpp-1 y z]] => [[[[[dc x z] v [ec x z]] v [po x z]] v [tpp x z]] v [ntpp x z]]]]]])

(<-kb [all x [all y [all z [[[ntpp x y] & [e= y z]] => [ntpp x z]]]]])

(<-kb [all x [all y [all z [[[tpp-1 x y] & [dc y z]] => [[[[[dc x z] v [ec x z]] v [po x z]] v [tpp-1 x z]] v [ntpp-1 x z]]]]]])

(<-kb [all x [all y [all z [[[tpp-1 x y] & [ec y z]] => [[[[ec x z] v [po x z]] v [tpp-1 x z]] v [ntpp-1 x z]]]]]])

(<-kb [all x [all y [all z [[[tpp-1 x y] & [po y z]] => [[[po x z] v [tpp-1 x z]] v [ntpp-1 x z]]]]]])

(<-kb [all x [all y [all z [[[tpp-1 x y] & [tpp y z]] => [[[e= x z] v [po x z]] v [tpp-1 x z]] v [tpp-1 x z]]]]])

(<-kb [all x [all y [all z [[[tpp-1 x y] & [ntpp y z]] => [[[po x z] v [tpp x z]] v [ntpp x z]]]]]])

(<-kb [all x [all y [all z [[[tpp-1 x y] & [tpp-1 y z]] => [[tpp-1 x z] v [ntpp-1 x z]]]]]])

(<-kb [all x [all y [all z [[[tpp-1 x y] & [ntpp-1 y z]] => [ntpp-1 x z]]]]])

(<-kb [all x [all y [all z [[[tpp-1 x y] & [e= y z]] => [tpp-1 x z]]]]])

(<-kb [all x [all y [all z [[[ntpp-1 x y] & [dc y z]] => [[[[[dc x z] v [ec x z]] v [po x z]] v [tpp-1 x z]] v [ntpp-1 x z]]]]]])

(<-kb [all x [all y [all z [[[ntpp-1 x y] & [ec y z]] => [[[po x z] v [tpp-1 x z]] v [ntpp-1 x z]]]]]])

(<-kb [all x [all y [all z [[[ntpp-1 x y] & [po y z]] => [[[po x z] v [tpp-1 x z]] v [ntpp-1 x z]]]]]])

(<-kb [all x [all y [all z [[[ntpp-1 x y] & [tpp y z]] => [[[e= x z] v [po x z]] v [[tpp-1 x z] v [tpp-1 x z]]]]]]])

(<-kb [all x [all y [all z [[[ntpp-1 x y] & [ntpp y z]] => [[[[e= x z] v [tpp-1 x y]] v [[nttp-1 x z]
                                                             v [po x z]]] v [[tpp x z] v [ntpp x z]]]]]]])

(<-kb [all x [all y [all z [[[ntpp-1 x y] & [tpp-1 y z]] => [ntpp-1 x z]]]]])

(<-kb [all x [all y [all z [[[ntpp-1 x y] & [ntpp-1 y z]] => [ntpp-1 x z]]]]])

(<-kb [all x [all y [all z [[[ntpp-1 x y] & [e= y z]] => [ntpp-1 x z]]]]])

(<-kb [all x [all y [all z [[[e= x y] & [dc y z]] => [dc x z]]]]])

(<-kb [all x [all y [all z [[[e= x y] & [ec y z]] => [ec x z]]]]])

(<-kb [all x [all y [all z [[[e= x y] & [po y z]] => [po x z]]]]])

(<-kb [all x [all y [all z [[[e= x y] & [tpp y z]] => [tpp x z]]]]])

(<-kb [all x [all y [all z [[[e= x y] & [ntpp y z]] => [ntpp x z]]]]])

(<-kb [all x [all y [all z [[[e= x y] & [tpp-1 y z]] => [tpp-1 x z]]]]])

(<-kb [all x [all y [all z [[[e= x y] & [ntpp-1 y z]] => [ntpp-1 x z]]]]])

(<-kb [all x [all y [all z [[[e= x y] & [e= y z]] => [e= x z]]]]])


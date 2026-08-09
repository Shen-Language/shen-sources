(let   RCC (rcc-axioms)
       Theorem [all x [all y [all z [[[dc x y] & [ec y z]]
                 => [[[[[dc x z] v [ec x z]] v [po x z]] v [tpp x z]] v [ntpp x z]]]]]]


       Lemma1 [all x [all y [[pp x y] => [[tpp x y] v [ntpp x y]]]]]        

       [RCC Theorem (initialise-plan)
                   (kb-> RCC)
                   (lemma Lemma1 "Show lemma1")
                   (kb-> [Lemma1 | RCC])
                   (lemma Theorem "Finally prove main theorem")
                   (end-of-plan)])
      
      
  

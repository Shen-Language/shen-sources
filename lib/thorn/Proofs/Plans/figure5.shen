(let   RCC (rcc-axioms)
       Theorem [all x [all y [all z [[[dc x y] & [tpp y z]] 
          =>  [[[[[dc x z] v [ec x z]] 
                 v [po x z]] v [tpp x z]] v [ntpp x z]]]]]]

       Lemma1 [all x [all y [all z [[[dc x y] & [tpp y z]] 
                => [[[dc x z] v [ec x z]] v [[po x z] v [pp x z]]]]]]]

       Lemma2 [all x [all y [[pp x y] => [[tpp x y] v [ntpp x y]]]]]      

       [RCC Theorem  (initialise-plan)
                   (kb-> RCC)
                   (lemma Lemma1 "Show lemma 1")
                   (kb-> [Lemma1 | RCC])
                   (lemma Lemma2 "Show lemma 2")
                   (kb-> [Lemma2 Lemma1 | RCC])
                   (lemma Theorem "Finally prove main theorem")
                   (end-of-plan)])
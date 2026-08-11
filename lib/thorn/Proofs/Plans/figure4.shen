(let   RCC (rcc-axioms)
       Theorem [[[tpp a b] & [tpp b c]] => [[tpp a c] v [ntpp a c]]]

       Lemma1 [all x [all y [[tpp x y] => [pp x y]]]]
       Lemma2 [all x [all y [[pp x y] => [p x y]]]]
       Lemma3 [all x [all y [all z [[[p x y] & [p y z]] => [p x z]]]]]
       Lemma4 [all x [all y [all z [[[tpp x y] & [tpp y z]] => [p x z]]]]]
       Lemma5 [all x [all y [all z [[[tpp x y] & [tpp y z]] => [pp x z]]]]]
       Lemma6 [all x [all y [[pp x y] => [[tpp x y] v [ntpp x y]]]]]

        [RCC Theorem  (initialise-plan)
                   (kb-> RCC)
                   (lemma Lemma1 "Show tpp implies pp")
                   (kb-> [Lemma1 | RCC])
                   (lemma Lemma2 "Show pp implies p")
                   (kb-> [Lemma2 Lemma1 | RCC])
                   (lemma Lemma3 "Transitivity of p")
                   (kb-> [Lemma3 Lemma2 Lemma1 | RCC])
                   (lemma Lemma4 "So tpp-tpp implies p via trans")
                   (kb-> [Lemma4 Lemma3 Lemma2 Lemma1 | RCC])
                   (lemma Lemma5 "So also implies pp by pp def")
                   (kb-> [Lemma5 Lemma4 Lemma3 Lemma2 Lemma1 | RCC])
                   (lemma Lemma6 "Decompose pp into tpp or ntpp")
                   (kb-> [Lemma6 Lemma5 Lemma4 Lemma3 Lemma2 Lemma1 | RCC])
                   (lemma Theorem "Finally prove main theorem")
                   (end-of-plan)])
      
      
  

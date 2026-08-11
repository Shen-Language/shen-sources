(time (let* RCC (rcc-axioms)

     Theorem
     [all x [all y [all z
       [[[tpp x y] & [e= y z]]
        => [tpp x z]]]]]

     Lemma1
     [all x [all y
       [[tpp x y] => [pp x y]]]]

     Lemma2
     [all x [all y
       [[pp x y] => [p x y]]]]

     Lemma3
     [all x [all y [all z
       [[[e= x y] & [p z x]]
        => [p z y]]]]]

     Lemma4
     [all x [all y [all z
       [[[e= x y] & [ec z x]]
        => [ec z y]]]]]

     Lemma5
     [all x [all y [all z
       [[[tpp x y] & [e= y z]]
        => [pp x z]]]]]

     Lemma6
     [all x [all y [all z
       [[[tpp x y] & [e= y z]]
        => [exists w [[ec w x] & [ec w z]]]]]]]

     [RCC Theorem (initialise-plan)

      (kb-> RCC)
      (lemma Lemma1 "tpp implies pp.")

      (kb-> [Lemma1 | RCC])
      (lemma Lemma2 "pp implies p.")

      (kb-> [Lemma2 Lemma1 | RCC])
      (lemma Lemma3 "Equality transports parthood.")

      (kb-> [Lemma3 Lemma2 Lemma1 | RCC])
      (lemma Lemma4 "Equality transports external connection.")

      (kb-> [Lemma4 Lemma3 Lemma2 Lemma1 | RCC])
      (lemma Lemma5 "From tpp(x,y) and e=(y,z), derive pp(x,z).")

      (kb-> [Lemma5 Lemma4 Lemma3 Lemma2 Lemma1 | RCC])
      (lemma Lemma6 "From tpp(x,y) and e=(y,z), transport the tangential witness to z.")

      (kb-> [Lemma6 Lemma5 Lemma4 Lemma3 Lemma2 Lemma1 | RCC])
      (lemma Theorem
       "Use Lemma5 for pp(x,z) and Lemma6 for an ec witness shared by x and z; hence tpp(x,z).")

      (end-of-plan)]))
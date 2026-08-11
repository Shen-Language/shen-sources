(let RCC (rcc-axioms)

     Theorem
     [all x [all y [all z
       [[[ec x y] & [e= y z]]
        => [ec x z]]]]]

     Lemma1
     [all x [all y
       [[ec x y] => [c x y]]]]

     Lemma2
     [all x [all y
       [[ec x y] => [~ [o x y]]]]]

     Lemma3
     [all x [all y [all z
       [[[e= x y] & [c z x]]
        => [c z y]]]]]

     Lemma4
     [all x [all y [all z
       [[[e= x y] & [o z x]]
        => [o z y]]]]]

     Lemma5
     [all x [all y [all z
       [[[ec x y] & [e= y z]]
        => [c x z]]]]]

     Lemma6
     [all x [all y [all z
       [[[ec x y] & [e= y z]]
        => [~ [o x z]]]]]]

     [RCC Theorem (initialise-plan)

      (kb-> RCC)
      (lemma Lemma1 "External connection implies connection.")

      (kb-> [Lemma1 | RCC])
      (lemma Lemma2 "External connection excludes overlap.")

      (kb-> [Lemma2 Lemma1 | RCC])
      (lemma Lemma3 "Equality preserves connection.")

      (kb-> [Lemma3 Lemma2 Lemma1 | RCC])
      (lemma Lemma4 "Equality preserves overlap.")

      (kb-> [Lemma4 Lemma3 Lemma2 Lemma1 | RCC])
      (lemma Lemma5 "From ec(x,y) and e=(y,z), derive c(x,z).")

      (kb-> [Lemma5 Lemma4 Lemma3 Lemma2 Lemma1 | RCC])
      (lemma Lemma6 "From ec(x,y) and e=(y,z), derive not overlap(x,z).")

      (kb-> [Lemma6 Lemma5 Lemma4 Lemma3 Lemma2 Lemma1 | RCC])
      (lemma Theorem
       "Combine c(x,z) with not o(x,z) to obtain ec(x,z).")

      (end-of-plan)])
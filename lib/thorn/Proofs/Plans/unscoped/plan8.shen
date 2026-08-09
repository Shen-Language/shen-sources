(time (let* RCC (rcc-axioms)
     Theorem
     [all x [all y [all z
       [[[ec x y] & [dc y z]]
         => [[[[[dc x z] v [ec x z]] v [po x z]] v [tpp-1 x z]] v [ntpp-1 x z]]]]]]

     Lemma1
     [all x [all y [[ec x y] => [c x y]]]]

     Lemma2
     [all x [all y [[pp x y] => [p x y]]]]

     Lemma3
     [all x [all y [[tpp x y] => [pp x y]]]]

     Lemma4
     [all x [all y [[ntpp x y] => [pp x y]]]]

     Lemma5
     [all x [all y [all z [[[p x y] & [c z x]] => [c z y]]]]]

     Lemma6
     [all x [all y [all z
       [[[ec x y] & [dc y z]] => [~ [p x z]]]]]]

     Lemma7
     [all x [all y [all z
       [[[ec x y] & [dc y z]] => [[dc x z] v [c x z]]]]]]

     Lemma8
     [all x [all y [all z
       [[[[ec x y] & [dc y z]] & [c x z]]
        => [[ec x z] v [o x z]]]]]]

     Lemma9
     [all x [all y [all z
       [[[[[ec x y] & [dc y z]] & [c x z]] & [o x z]]
        => [[po x z] v [pp-1 x z]]]]]]

     Lemma10
     [all x [all y [[pp-1 x y] => [[tpp-1 x y] v [ntpp-1 x y]]]]]

     Lemma11
     [all x [all y [all z
       [[[[[ec x y] & [dc y z]] & [c x z]] & [o x z]]
        => [[po x z] v [[tpp-1 x z] v [ntpp-1 x z]]]]]]]

     [RCC Theorem (initialise-plan)
      (kb-> RCC)

      (lemma Lemma1)
      (kb-> [Lemma1 | RCC])

      (lemma Lemma2)
      (kb-> [Lemma2 Lemma1 | RCC])

      (lemma Lemma3)
      (kb-> [Lemma3 Lemma2 Lemma1 | RCC])

      (lemma Lemma4)
      (kb-> [Lemma4 Lemma3 Lemma2 Lemma1 | RCC])

      (lemma Lemma5)
      (kb-> [Lemma5 Lemma4 Lemma3 Lemma2 Lemma1 | RCC])

      (lemma Lemma6)
      (kb-> [Lemma6 Lemma5 Lemma4 Lemma3 Lemma2 Lemma1 | RCC])

      (lemma Lemma7)
      (kb-> [Lemma7 Lemma6 Lemma5 Lemma4 Lemma3 Lemma2 Lemma1 | RCC])

      (lemma Lemma8)
      (kb-> [Lemma8 Lemma7 Lemma6 Lemma5 Lemma4 Lemma3 Lemma2 Lemma1 | RCC])

      (lemma Lemma9)
      (kb-> [Lemma9 Lemma8 Lemma7 Lemma6 Lemma5 Lemma4 Lemma3 Lemma2 Lemma1 | RCC])

      (lemma Lemma10)
      (kb-> [Lemma10 Lemma9 Lemma8 Lemma7 Lemma6 Lemma5 Lemma4 Lemma3 Lemma2 Lemma1 | RCC])

      (lemma Lemma11)
      (kb-> [Lemma11 Lemma10 Lemma9 Lemma8 Lemma7 Lemma6 Lemma5 Lemma4 Lemma3 Lemma2 Lemma1 | RCC])

      (lemma Theorem)
      (end-of-plan)]))
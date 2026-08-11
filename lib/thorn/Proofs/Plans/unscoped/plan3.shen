(time (let* RCC (rcc-axioms)
     Theorem
     [all x [all y [all z
       [[[dc x y] & [tpp y z]]
         => [[[[[dc x z] v [ec x z]] v [po x z]] v [tpp x z]] v [ntpp x z]]]]]]

     Lemma1  [all x [all y [[ec x y] => [c x y]]]]
     Lemma2  [all x [all y [[pp x y] => [p x y]]]]
     Lemma3  [all x [all y [[tpp x y] => [pp x y]]]]
     Lemma4  [all x [all y [[ntpp x y] => [pp x y]]]]
     Lemma5  [all x [all y [all z [[[p x y] & [c z x]] => [c z y]]]]]

     Lemma6  [all x [all y [all z [[[dc x y] & [tpp y z]] => [~ [p z x]]]]]]

     Lemma7  [all x [all y [all z [[[dc x y] & [tpp y z]] => [[dc x z] v [c x z]]]]]]
     Lemma8  [all x [all y [all z [[[[dc x y] & [tpp y z]] & [c x z]]
                                   => [[ec x z] v [o x z]]]]]]
     Lemma9  [all x [all y [all z [[[[[dc x y] & [tpp y z]] & [c x z]] & [o x z]]
                                   => [[po x z] v [pp x z]]]]]]
     Lemma10 [all x [all y [[pp x y] => [[tpp x y] v [ntpp x y]]]]]
     Lemma11 [all x [all y [all z [[[[[dc x y] & [tpp y z]] & [c x z]] & [o x z]]
                                   => [[po x z] v [[tpp x z] v [ntpp x z]]]]]]]

     [RCC Theorem (initialise-plan)
      (kb-> RCC)

      (lemma Lemma1 "External connection implies connection.")
      (kb-> [Lemma1 | RCC])

      (lemma Lemma2 "Proper part implies parthood.")
      (kb-> [Lemma2 Lemma1 | RCC])

      (lemma Lemma3 "Tangential proper part implies proper part.")
      (kb-> [Lemma3 Lemma2 Lemma1 | RCC])

      (lemma Lemma4 "Non-tangential proper part implies proper part.")
      (kb-> [Lemma4 Lemma3 Lemma2 Lemma1 | RCC])

      (lemma Lemma5 "Parthood lifts connection from part to whole.")
      (kb-> [Lemma5 Lemma4 Lemma3 Lemma2 Lemma1 | RCC])

      (lemma Lemma6 "If x is disconnected from y and y is a tangential proper part of z, then z is not part of x.")
      (kb-> [Lemma6 Lemma5 Lemma4 Lemma3 Lemma2 Lemma1 | RCC])

      (lemma Lemma7 "Case split on whether x is connected to z; if not, then dc x z.")
      (kb-> [Lemma7 Lemma6 Lemma5 Lemma4 Lemma3 Lemma2 Lemma1 | RCC])

      (lemma Lemma8 "If x is connected to z, split on overlap to get ec x z or o x z.")
      (kb-> [Lemma8 Lemma7 Lemma6 Lemma5 Lemma4 Lemma3 Lemma2 Lemma1 | RCC])

      (lemma Lemma9 "If x overlaps z and z is not part of x, then either po x z or pp x z.")
      (kb-> [Lemma9 Lemma8 Lemma7 Lemma6 Lemma5 Lemma4 Lemma3 Lemma2 Lemma1 | RCC])

      (lemma Lemma10 "Proper part decomposes into tangential or non-tangential proper part.")
      (kb-> [Lemma10 Lemma9 Lemma8 Lemma7 Lemma6 Lemma5 Lemma4 Lemma3 Lemma2 Lemma1 | RCC])

      (lemma Lemma11 "Refine the overlap case from po or pp to po or tpp or ntpp.")
      (kb-> [Lemma11 Lemma10 Lemma9 Lemma8 Lemma7 Lemma6 Lemma5 Lemma4 Lemma3 Lemma2 Lemma1 | RCC])

      (lemma Theorem "Combine the local case splits: dc or c; if c then ec or o; if o then po or pp; finally split pp into tpp or ntpp.")
      (end-of-plan)]))
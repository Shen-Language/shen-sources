(time (let* RCC (rcc-axioms)

     Theorem
     [all x [all y [all z
       [[[tpp x y] & [po y z]]
        => [[[[[dc x z] v [ec x z]] v [po x z]] v [tpp x z]] v [ntpp x z]]]]]]

     Lemma1
     [all x [all y [all z
       [[[tpp x y] & [po y z]]
        => [~ [p z x]]]]]]

     Lemma2
     [all x [all y
       [[tpp x y] => [pp x y]]]]

     Lemma3
     [all x [all y
       [[pp x y] => [p x y]]]]

     Lemma4
     [all x [all y
       [[po x y] => [o x y]]]]

     Lemma5
     [all x [all y
       [[o x y] => [c x y]]]]

     Lemma6
     [all x [all y [all z
       [[[p x y] & [c z x]]
        => [c z y]]]]]

     Lemma7
     [all x [all y [all z
       [[[tpp x y] & [po y z]]
        => [[dc x z] v [c x z]]]]]]

     Lemma8
     [all x [all y [all z
       [[[[tpp x y] & [po y z]] & [c x z]]
        => [[ec x z] v [[po x z] v [pp x z]]]]]]]

     Lemma9
     [all x [all y
       [[pp x y] => [[tpp x y] v [ntpp x y]]]]]

     [RCC Theorem (initialise-plan)

      (kb-> RCC)

      (thorn.timeout 20)
      (lemma Lemma1 "If x is a tangential proper part of y and y partially overlaps z, then z is not part of x.")
      (thorn.timeout 5)

      (kb-> [Lemma1 | RCC])
      (lemma Lemma2 "Tangential proper part implies proper part.")

      (kb-> [Lemma2 Lemma1 | RCC])
      (lemma Lemma3 "Proper part implies parthood.")

      (kb-> [Lemma3 Lemma2 Lemma1 | RCC])
      (lemma Lemma4 "Partial overlap implies overlap.")

      (kb-> [Lemma4 Lemma3 Lemma2 Lemma1 | RCC])
      (lemma Lemma5 "Overlap implies connection.")

      (kb-> [Lemma5 Lemma4 Lemma3 Lemma2 Lemma1 | RCC])
      (lemma Lemma6 "Parthood transports connection from part to whole.")

      (kb-> [Lemma6 Lemma5 Lemma4 Lemma3 Lemma2 Lemma1 | RCC])
      (lemma Lemma7 "Split x,z into disconnection or connection.")

      (kb-> [Lemma7 Lemma6 Lemma5 Lemma4 Lemma3 Lemma2 Lemma1 | RCC])
      (lemma Lemma8 "In the connected case, classify x,z as ec or po or pp.")

      (kb-> [Lemma8 Lemma7 Lemma6 Lemma5 Lemma4 Lemma3 Lemma2 Lemma1 | RCC])
      (lemma Lemma9 "Proper part splits into tangential or non-tangential proper part.")

      (kb-> [Lemma9 Lemma8 Lemma7 Lemma6 Lemma5 Lemma4 Lemma3 Lemma2 Lemma1 | RCC])
      (lemma Theorem
       "Use Lemma7. In the dc case finish immediately. In the connected case use Lemma8; then split pp into tpp or ntpp with Lemma9.")

      (end-of-plan)]))
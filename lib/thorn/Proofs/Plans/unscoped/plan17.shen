(let RCC (rcc-axioms)

     Theorem
     [all x [all y [all z
       [[[po x y] & [ec y z]]
        => [[[[[dc x z] v [ec x z]] v [po x z]] v [tpp-1 x z]] v [ntpp-1 x z]]]]]]

     Lemma1
     [all x [all y [all z
       [[[po x y] & [ec y z]]
        => [~ [p x z]]]]]]

     Lemma2
     [all x [all y
       [[po x y] => [o x y]]]]

     Lemma3
     [all x [all y
       [[o x y] => [c x y]]]]

     Lemma4
     [all x [all y
       [[ec x y] => [c x y]]]]

     Lemma5
     [all x [all y [all z
       [[[p x y] & [c z x]]
        => [c z y]]]]]

     Lemma6
     [all x [all y [all z
       [[[po x y] & [ec y z]]
        => [[dc x z] v [c x z]]]]]]

     Lemma7
     [all x [all y [all z
       [[[[po x y] & [ec y z]] & [c x z]]
        => [[[ec x z] v [po x z]] v [p z x]]]]]]

     Lemma8
     [all x [all y
       [[[p y x] & [~ [p x y]]]
        => [pp-1 x y]]]]

     Lemma9
     [all x [all y
       [[pp-1 x y] => [[tpp-1 x y] v [ntpp-1 x y]]]]]

     [RCC Theorem (initialise-plan)

      (kb-> RCC)
      (thorn.timeout 20)
      (lemma Lemma1 "If x partially overlaps y and y is externally connected to z, then x is not part of z.")
      (thorn.timeout 5)

      (kb-> [Lemma1 | RCC])
      (lemma Lemma2 "Partial overlap implies overlap.")

      (kb-> [Lemma2 Lemma1 | RCC])
      (lemma Lemma3 "Overlap implies connection.")

      (kb-> [Lemma3 Lemma2 Lemma1 | RCC])
      (lemma Lemma4 "External connection implies connection.")

      (kb-> [Lemma4 Lemma3 Lemma2 Lemma1 | RCC])
      (lemma Lemma5 "Parthood transports connection from part to whole.")

      (kb-> [Lemma5 Lemma4 Lemma3 Lemma2 Lemma1 | RCC])
      (lemma Lemma6 "Split x,z into disconnection or connection.")

      (kb-> [Lemma6 Lemma5 Lemma4 Lemma3 Lemma2 Lemma1 | RCC])
      (lemma Lemma7 "In the connected case, x,z are ec or po or z is part of x.")

      (kb-> [Lemma7 Lemma6 Lemma5 Lemma4 Lemma3 Lemma2 Lemma1 | RCC])
      (lemma Lemma8 "Converse parthood plus failure of forward parthood gives inverse proper part.")

      (kb-> [Lemma8 Lemma7 Lemma6 Lemma5 Lemma4 Lemma3 Lemma2 Lemma1 | RCC])
      (lemma Lemma9 "Inverse proper part splits into tangential or non-tangential inverse proper part.")

      (kb-> [Lemma9 Lemma8 Lemma7 Lemma6 Lemma5 Lemma4 Lemma3 Lemma2 Lemma1 | RCC])
      (lemma Theorem
       "Split dc/c. In connected case use Lemma7. If p(z,x), use Lemma1 to eliminate p(x,z), yielding pp-1(x,z), then split to tpp-1 or ntpp-1.")

      (end-of-plan)])
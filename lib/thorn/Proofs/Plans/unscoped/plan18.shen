(let RCC (rcc-axioms)

     Theorem
     [all x [all y [all z
       [[[po x y] & [tpp y z]]
        => [[[po x z] v [tpp x z]] v [ntpp x z]]]]]]

     Lemma1
     [all x [all y [all z
       [[[po x y] & [tpp y z]]
        => [~ [p z x]]]]]]

     Lemma2
     [all x [all y
       [[po x y] => [o x y]]]]

     Lemma3
     [all x [all y
       [[o x y] => [c x y]]]]

     Lemma4
     [all x [all y
       [[tpp x y] => [pp x y]]]]

     Lemma5
     [all x [all y
       [[pp x y] => [p x y]]]]

     Lemma6
     [all x [all y [all z
       [[[p x y] & [c z x]]
        => [c z y]]]]]

     Lemma7
     [all x [all y [all z
       [[[po x y] & [tpp y z]]
        => [c x z]]]]]

     Lemma8
     [all x [all y [all z
       [[[po x y] & [tpp y z]]
        => [[ec x z] v [[po x z] v [pp x z]]]]]]]

     Lemma9
     [all x [all y [all z
       [[[po x y] & [tpp y z]]
        => [~ [ec x z]]]]]]

     Lemma10
     [all x [all y
       [[pp x y] => [[tpp x y] v [ntpp x y]]]]]

     [RCC Theorem (initialise-plan)

      (kb-> RCC)

      (thorn.timeout 20)
      (lemma Lemma1 "If x partially overlaps y and y is a tangential proper part of z, then z is not part of x.")
      (thorn.timeout 5)

      (kb-> [Lemma1 | RCC])
      (lemma Lemma2 "Partial overlap implies overlap.")

      (kb-> [Lemma2 Lemma1 | RCC])
      (lemma Lemma3 "Overlap implies connection.")

      (kb-> [Lemma3 Lemma2 Lemma1 | RCC])
      (lemma Lemma4 "Tangential proper part implies proper part.")

      (kb-> [Lemma4 Lemma3 Lemma2 Lemma1 | RCC])
      (lemma Lemma5 "Proper part implies parthood.")

      (kb-> [Lemma5 Lemma4 Lemma3 Lemma2 Lemma1 | RCC])
      (lemma Lemma6 "Parthood transports connection from part to whole.")

      (kb-> [Lemma6 Lemma5 Lemma4 Lemma3 Lemma2 Lemma1 | RCC])
      (lemma Lemma7 "From po(x,y) and tpp(y,z), x is connected to z.")

      (kb-> [Lemma7 Lemma6 Lemma5 Lemma4 Lemma3 Lemma2 Lemma1 | RCC])
      (lemma Lemma8 "Classify x,z as ec or po or pp.")

      (kb-> [Lemma8 Lemma7 Lemma6 Lemma5 Lemma4 Lemma3 Lemma2 Lemma1 | RCC])

      (thorn.timeout 20)
      (lemma Lemma9 "The ec(x,z) branch is impossible under po(x,y) and tpp(y,z).")
      (thorn.timeout 5)

      (kb-> [Lemma9 Lemma8 Lemma7 Lemma6 Lemma5 Lemma4 Lemma3 Lemma2 Lemma1 | RCC])
      (lemma Lemma10 "Proper part splits into tangential or non-tangential proper part.")

      (kb-> [Lemma10 Lemma9 Lemma8 Lemma7 Lemma6 Lemma5 Lemma4 Lemma3 Lemma2 Lemma1 | RCC])
      (lemma Theorem
       "Use Lemma8 and eliminate ec with Lemma9. Then split pp into tpp or ntpp.")

      (end-of-plan)])
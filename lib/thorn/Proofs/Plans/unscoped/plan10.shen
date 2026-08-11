(time (let* RCC (rcc-axioms)

     Theorem
     [all x [all y [all z
       [[[ec x y] & [po y z]]
        => [[[[[dc x z] v [ec x z]] v [po x z]] v [tpp x z]] v [ntpp x z]]]]]]

     Lemma1
     [all x [all y [all z
       [[[ec x y] & [po y z]]
        => [~ [p z x]]]]]]

     Lemma2
     [all x [all y
       [[ec x y] => [c x y]]]]

     Lemma3
     [all x [all y
       [[po x y] => [o x y]]]]

     Lemma4
     [all x [all y
       [[o x y] => [c x y]]]]

     Lemma5
     [all x [all y [all z
       [[[p x y] & [c z x]]
        => [c z y]]]]]

     Lemma6
     [all x [all y [all z
       [[[ec x y] & [po y z]]
        => [[dc x z] v [c x z]]]]]]

     Lemma7
     [all x [all y [all z
       [[[[ec x y] & [po y z]] & [c x z]]
        => [[[ec x z] v [po x z]] v [p x z]]]]]]

     Lemma8
     [all x [all y
       [[[p x y] & [~ [p y x]]]
        => [pp x y]]]]

     Lemma9
     [all x [all y
       [[pp x y] => [[tpp x y] v [ntpp x y]]]]]

     [RCC Theorem (initialise-plan)

      (kb-> RCC)
      (thorn.timeout 100)
      (lemma Lemma1 "If ec(x,y) and po(y,z), then z is not part of x.")
      (thorn.timeout 5)

      (kb-> [Lemma1 | RCC])
      (lemma Lemma2 "External connection implies connection.")

      (kb-> [Lemma2 Lemma1 | RCC])
      (lemma Lemma3 "Partial overlap implies overlap.")

      (kb-> [Lemma3 Lemma2 Lemma1 | RCC])
      (lemma Lemma4 "Overlap implies connection.")

      (kb-> [Lemma4 Lemma3 Lemma2 Lemma1 | RCC])
      (lemma Lemma5 "Parthood transports connection from part to whole.")

      (kb-> [Lemma5 Lemma4 Lemma3 Lemma2 Lemma1 | RCC])
      (lemma Lemma6 "From ec(x,y) and po(y,z), either x is disconnected from z or connected to z.")

      (kb-> [Lemma6 Lemma5 Lemma4 Lemma3 Lemma2 Lemma1 | RCC])
      (lemma Lemma7 "In the connected case, ec(x,z) or po(x,z) or p(x,z).")

      (kb-> [Lemma7 Lemma6 Lemma5 Lemma4 Lemma3 Lemma2 Lemma1 | RCC])
      (lemma Lemma8 "Parthood plus failure of converse parthood gives proper part.")

      (kb-> [Lemma8 Lemma7 Lemma6 Lemma5 Lemma4 Lemma3 Lemma2 Lemma1 | RCC])
      (lemma Lemma9 "Proper part is tangential or non-tangential.")

      (kb-> [Lemma9 Lemma8 Lemma7 Lemma6 Lemma5 Lemma4 Lemma3 Lemma2 Lemma1 | RCC])
      (lemma Theorem
       "Split into dc(x,z) or c(x,z). In the connected case use Lemma7. If p(x,z), combine with Lemma1 to get pp(x,z), then Lemma9 gives tpp(x,z) or ntpp(x,z).")

      (end-of-plan)]))
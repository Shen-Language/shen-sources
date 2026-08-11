(time (let* RCC (rcc-axioms)
     Theorem
     [all x [all y [all z
       [[[ec x y] & [ec y z]]
        => [[[[[[dc x z] v [ec x z]] v [po x z]] v [tpp x z]] v [tpp-1 x z]] v [e= x z]]]]]]

     Lemma1
     [all x [all y [[ec x y] => [c x y]]]]

     Lemma2
     [all x [all y [all z
       [[[ec x y] & [ec y z]]
        => [[dc x z] v [c x z]]]]]]

     Lemma3
     [all x [all y [all z
       [[[[ec x y] & [ec y z]] & [c x z]]
        => [[ec x z] v [o x z]]]]]]

     Lemma4
     [all x [all y [[o x y]
        => [[[[po x y] v [pp x y]] v [pp-1 x y]] v [e= x y]]]]]

     Lemma5
     [all x [all y [all z
       [[[[[ec x y] & [ec y z]] & [c x z]] & [o x z]]
        => [[[[po x z] v [pp x z]] v [pp-1 x z]] v [e= x z]]]]]]

     Lemma6
     [all x [all y [all z
       [[[[ec x y] & [ec y z]] & [pp x z]]
        => [tpp x z]]]]]

     Lemma7
     [all x [all y [all z
       [[[[ec x y] & [ec y z]] & [pp-1 x z]]
        => [tpp-1 x z]]]]]

     Lemma8
     [all x [all y [all z
       [[[[[ec x y] & [ec y z]] & [c x z]] & [o x z]]
        => [[[[po x z] v [tpp x z]] v [tpp-1 x z]] v [e= x z]]]]]]

     Lemma9
     [all x [all y [all z
       [[[ec x y] & [ec y z]]
        => [[[dc x z] v [ec x z]]
            v [[[[po x z] v [tpp x z]] v [tpp-1 x z]] v [e= x z]]]]]]]

     Lemma10
     [all x [all y [all z
       [[[ec x y] & [ec y z]]
        => [[[[[[dc x z] v [ec x z]] v [po x z]] v [tpp x z]] v [tpp-1 x z]] v [e= x z]]]]]]

     [RCC Theorem (initialise-plan)
      (kb-> RCC)

      (lemma Lemma1
       "External connection implies connection.")
      (kb-> [Lemma1 | RCC])

      (lemma Lemma2
       "Case split: x and z are either disconnected or connected.")
      (kb-> [Lemma2 Lemma1 | RCC])

      (lemma Lemma3
       "If x and z are connected, split into external connection or overlap.")
      (kb-> [Lemma3 Lemma2 Lemma1 | RCC])

      (lemma Lemma4
       "Overlap decomposes into po, pp, pp-1, or extensional equality.")
      (kb-> [Lemma4 Lemma3 Lemma2 Lemma1 | RCC])

      (lemma Lemma5
       "Lift the overlap decomposition into the ec/ec context.")
      (kb-> [Lemma5 Lemma4 Lemma3 Lemma2 Lemma1 | RCC])

      (lemma Lemma6
       "Under ec/ec, proper part sharpens to tangential proper part.")
      (kb-> [Lemma6 Lemma5 Lemma4 Lemma3 Lemma2 Lemma1 | RCC])

      (lemma Lemma7
       "Under ec/ec, converse proper part sharpens to converse tangential proper part.")
      (kb-> [Lemma7 Lemma6 Lemma5 Lemma4 Lemma3 Lemma2 Lemma1 | RCC])

      (lemma Lemma8
       "Refine the overlap case to po, tpp, tpp-1, or equality.")
      (kb-> [Lemma8 Lemma7 Lemma6 Lemma5 Lemma4 Lemma3 Lemma2 Lemma1 | RCC])

      (lemma Lemma9
       "Combine the dc/c split with the ec/o split and the refined overlap case.")
      (kb-> [Lemma9 Lemma8 Lemma7 Lemma6 Lemma5 Lemma4 Lemma3 Lemma2 Lemma1 | RCC])

      (lemma Lemma10
       "Reassociate the disjunctions into the target shape.")
      (kb-> [Lemma10 Lemma9 Lemma8 Lemma7 Lemma6 Lemma5 Lemma4 Lemma3 Lemma2 Lemma1 | RCC])

      (lemma Theorem
       "Finally prove the main theorem.")
      (end-of-plan)]))
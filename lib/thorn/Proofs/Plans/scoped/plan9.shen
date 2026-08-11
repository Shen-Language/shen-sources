(time
 (let* RCC [(c-refl) (c-symm) (def-dc) (def-p) (def-pp) (def-e=) (def-o)
            (def-po) (def-ec) (def-dr) (def-tpp) (def-ntpp) (def-p-1) (def-pp-1)
            (def-tpp-1) (def-ntpp-1)]

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

       \\ scopes via dependency unions

       EC-Scope
       [(c-refl) (c-symm) (def-p) (def-o) (def-ec)]

       EC-EC-Case-Scope
       [(c-refl) (c-symm) (def-p) (def-o) (def-ec) (def-dc)]

       EC-EC-DR-Scope
       [(c-refl) (c-symm) (def-p) (def-o) (def-ec) (def-dr)]

       O-Decomp-Scope
       [(c-refl) (c-symm) (def-p) (def-pp) (def-o) (def-po)
        (def-e=) (def-pp-1)]

       TPP-Scope
       [(c-refl) (c-symm) (def-p) (def-pp) (def-o) (def-ec) (def-tpp)]

       TPP-1-Scope
       [(c-refl) (c-symm) (def-p) (def-pp) (def-o) (def-ec)
        (def-pp-1) (def-tpp-1)]

       [RCC Theorem (initialise-plan)

        (kb-> EC-Scope)
        (lemma Lemma1)

        (kb-> [Lemma1 | EC-EC-Case-Scope])
        (lemma Lemma2)

        (kb-> [Lemma2 Lemma1 | EC-EC-DR-Scope])
        (lemma Lemma3)

        (kb-> O-Decomp-Scope)
        (lemma Lemma4)

        (kb-> [Lemma4 Lemma3 Lemma2 Lemma1])
        (lemma Lemma5)

        (kb-> [Lemma5 Lemma4 Lemma3 Lemma2 Lemma1 | TPP-Scope])
        (lemma Lemma6)

        (kb-> [Lemma6 Lemma5 Lemma4 Lemma3 Lemma2 Lemma1 | TPP-1-Scope])
        (lemma Lemma7)

        (kb-> [Lemma7 Lemma6 Lemma5 Lemma4 Lemma3 Lemma2 Lemma1])
        (lemma Lemma8)

        (kb-> [Lemma8 Lemma7 Lemma6 Lemma5 Lemma4 Lemma3 Lemma2 Lemma1])
        (lemma Lemma9)

        (kb-> [Lemma9 Lemma8 Lemma7 Lemma6 Lemma5 Lemma4 Lemma3 Lemma2 Lemma1])
        (lemma Lemma10)

        (kb-> [Lemma10 Lemma9 Lemma8 Lemma7 Lemma6 Lemma5 Lemma4 Lemma3 Lemma2 Lemma1])
        (lemma Theorem)

        (end-of-plan)]))
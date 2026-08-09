(time
 (let* RCC [(c-refl) (c-symm) (def-dc) (def-p) (def-pp) (def-e=) (def-o)
            (def-po) (def-ec) (def-dr) (def-tpp) (def-ntpp) (def-p-1) (def-pp-1)
            (def-tpp-1) (def-ntpp-1)]

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

       EC-Scope
       [(c-refl) (c-symm) (def-ec) (def-o) (def-p)]

       PP-Scope
       [(c-refl) (c-symm) (def-p) (def-pp)]

       TPP-Scope
       [(c-refl) (c-symm) (def-p) (def-pp) (def-o) (def-ec) (def-tpp)]

       NTPP-Scope
       [(c-refl) (c-symm) (def-p) (def-pp) (def-o) (def-ec) (def-ntpp)]

       P-Scope
       [(c-refl) (c-symm) (def-p)]

       EC-DC-P-Scope
       [(c-refl) (c-symm) (def-ec) (def-o) (def-p) (def-dc)]

       EC-DC-C-Scope
       [(c-refl) (c-symm) (def-ec) (def-o) (def-p) (def-dc)]

       EC-DC-DR-Scope
       [(c-refl) (c-symm) (def-ec) (def-o) (def-p) (def-dc) (def-dr)]

       O-PO-PP-1-Scope
       [(c-refl) (c-symm)
        (def-p) (def-pp) (def-o) (def-po) (def-pp-1)]

       PP-1-Split-Scope
       [(c-refl) (c-symm)
        (def-p) (def-pp) (def-o) (def-ec)
        (def-pp-1) (def-tpp) (def-ntpp) (def-tpp-1) (def-ntpp-1)]

       [RCC Theorem (initialise-plan)

        (kb-> EC-Scope)
        (lemma Lemma1)

        (kb-> PP-Scope)
        (lemma Lemma2)

        (kb-> TPP-Scope)
        (lemma Lemma3)

        (kb-> NTPP-Scope)
        (lemma Lemma4)

        (kb-> P-Scope)
        (lemma Lemma5)

        (kb-> [Lemma1 Lemma5 | EC-DC-P-Scope])
        (lemma Lemma6)

        (kb-> [Lemma1 | EC-DC-C-Scope])
        (lemma Lemma7)

        (kb-> [Lemma7 | EC-DC-DR-Scope])
        (lemma Lemma8)

        (kb-> [Lemma6 | O-PO-PP-1-Scope])
        (lemma Lemma9)

        (kb-> PP-1-Split-Scope)
        (lemma Lemma10)

        (kb-> [Lemma9 Lemma10])
        (lemma Lemma11)

        (kb-> [Lemma7 Lemma8 Lemma11])
        (lemma Theorem)

        (end-of-plan)]))
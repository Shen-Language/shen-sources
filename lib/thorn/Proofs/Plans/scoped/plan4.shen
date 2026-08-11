(time
 (let* RCC [(c-refl) (c-symm) (def-dc) (def-p) (def-pp) (def-e=) (def-o)
            (def-po) (def-ec) (def-dr) (def-tpp) (def-ntpp) (def-p-1) (def-pp-1)
            (def-tpp-1) (def-ntpp-1)]

       Theorem
       [all x [all y [all z
         [[[dc x y] & [ntpp y z]]
           => [[[[[dc x z] v [ec x z]] v [po x z]] v [tpp x z]] v [ntpp x z]]]]]]

       Lemma1  [all x [all y [[ec x y] => [c x y]]]]
       Lemma2  [all x [all y [[pp x y] => [p x y]]]]
       Lemma3  [all x [all y [[tpp x y] => [pp x y]]]]
       Lemma4  [all x [all y [[ntpp x y] => [pp x y]]]]
       Lemma5  [all x [all y [all z [[[p x y] & [c z x]] => [c z y]]]]]

       Lemma6  [all x [all y [all z [[[dc x y] & [ntpp y z]] => [~ [p z x]]]]]]

       Lemma7  [all x [all y [all z [[[dc x y] & [ntpp y z]] => [[dc x z] v [c x z]]]]]]
       Lemma8  [all x [all y [all z [[[[dc x y] & [ntpp y z]] & [c x z]]
                                     => [[ec x z] v [o x z]]]]]]
       Lemma9  [all x [all y [all z [[[[[dc x y] & [ntpp y z]] & [c x z]] & [o x z]]
                                     => [[po x z] v [pp x z]]]]]]
       Lemma10 [all x [all y [[pp x y] => [[tpp x y] v [ntpp x y]]]]]
       Lemma11 [all x [all y [all z [[[[[dc x y] & [ntpp y z]] & [c x z]] & [o x z]]
                                     => [[po x z] v [[tpp x z] v [ntpp x z]]]]]]]

       \\ scopes

       EC-Scope
       [(c-refl) (c-symm) (def-ec)]

       PP-Scope
       [(c-refl) (c-symm) (def-p) (def-pp)]

       TPP-Scope
       [(c-refl) (c-symm) (def-p) (def-pp) (def-tpp)]

       NTPP-Scope
       [(c-refl) (c-symm) (def-p) (def-pp) (def-ntpp)]

       P-Scope
       [(c-refl) (c-symm) (def-p)]

       DC-NTPP-P-Scope
       [(c-refl) (c-symm) (def-dc) (def-p) (def-pp) (def-ntpp)
        (def-o) (def-p-1) (def-pp-1)]

       DC-NTPP-C-Scope
       [(c-refl) (c-symm) (def-dc) (def-ntpp) (def-pp) (def-p)
        (def-o) (def-p-1) (def-pp-1)]

       DC-NTPP-DR-Scope
       [(c-refl) (c-symm) (def-dc) (def-ntpp) (def-pp) (def-p)
        (def-o) (def-ec) (def-dr) (def-e=)
        (def-p-1) (def-pp-1)]

       O-PO-PP-Scope
       [(c-refl) (c-symm) (def-p) (def-pp) (def-o) (def-po)
        (def-p-1) (def-pp-1)]

       PP-Split-Scope
       [(c-refl) (c-symm) (def-p) (def-pp) (def-tpp) (def-ntpp)]

       [RCC Theorem (initialise-plan)

        (kb-> EC-Scope)
        (lemma Lemma1
         "External connection implies connection.")

        (kb-> [Lemma1 | PP-Scope])
        (lemma Lemma2
         "Proper part implies parthood.")

        (kb-> [Lemma2 | TPP-Scope])
        (lemma Lemma3
         "Tangential proper part implies proper part.")

        (kb-> [Lemma2 | NTPP-Scope])
        (lemma Lemma4
         "Non-tangential proper part implies proper part.")

        (kb-> P-Scope)
        (lemma Lemma5
         "Parthood lifts connection from part to whole.")

        (kb-> [Lemma5 | DC-NTPP-P-Scope])
        (lemma Lemma6
         "If x is disconnected from y and y is a non-tangential proper part of z, then z is not part of x.")

        (kb-> DC-NTPP-C-Scope)
        (lemma Lemma7
         "Case split on whether x is connected to z; if not, then dc x z.")

        (kb-> [Lemma7 | DC-NTPP-DR-Scope])
        (lemma Lemma8
         "If x is connected to z, split on overlap to get ec x z or o x z.")

        (kb-> [Lemma2 Lemma6 | O-PO-PP-Scope])
        (lemma Lemma9
         "If x overlaps z and z is not part of x, then either po x z or pp x z.")

        (kb-> [Lemma3 Lemma4 | PP-Split-Scope])
        (lemma Lemma10
         "Proper part decomposes into tangential or non-tangential proper part.")

        (kb-> [Lemma9 Lemma10])
        (lemma Lemma11
         "Refine the overlap case from po or pp to po or tpp or ntpp.")

        (kb-> [Lemma7 Lemma8 Lemma11])
        (lemma Theorem
         "Combine the same local case splits as before.")

        (end-of-plan)]))
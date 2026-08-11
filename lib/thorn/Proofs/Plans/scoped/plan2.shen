(time
 (let* RCC [(c-refl) (c-symm) (def-dc) (def-p) (def-pp) (def-e=) (def-o)
            (def-po) (def-ec) (def-dr) (def-tpp) (def-ntpp) (def-p-1) (def-pp-1)
            (def-tpp-1) (def-ntpp-1)]

       Theorem
       [all x [all y [all z
         [[[dc x y] & [po y z]]
          => [[[[[dc x z] v [ec x z]] v [po x z]] v [tpp x z]] v [ntpp x z]]]]]]

       Lemma1  [all x [all y [[pp x y] => [p x y]]]]
       Lemma2  [all x [all y [[tpp x y] => [pp x y]]]]
       Lemma3  [all x [all y [[ntpp x y] => [pp x y]]]]
       Lemma4  [all x [all y [all z [[[p x y] & [c z x]] => [c z y]]]]]
       Lemma5  [all x [all y [all z [[[dc x y] & [po y z]] => [~ [p z x]]]]]]
       Lemma6  [all x [all y [all z
                 [[[dc x y] & [po y z]] => [[dc x z] v [c x z]]]]]]
       Lemma7  [all x [all y [all z
                 [[[[dc x y] & [po y z]] & [c x z]]
                  => [[ec x z] v [o x z]]]]]]
       Lemma8  [all x [all y [all z
                 [[[[[dc x y] & [po y z]] & [c x z]] & [o x z]]
                  => [[po x z] v [pp x z]]]]]]
       Lemma9  [all x [all y [[pp x y] => [[tpp x y] v [ntpp x y]]]]]
       Lemma10 [all x [all y [all z
                 [[[[[dc x y] & [po y z]] & [c x z]] & [o x z]]
                  => [[po x z] v [[tpp x z] v [ntpp x z]]]]]]]

       PP-Scope
       [(c-refl) (c-symm) (def-p) (def-pp)]

       TPP-Scope
       [(c-refl) (c-symm) (def-p) (def-pp) (def-tpp)]

       NTPP-Scope
       [(c-refl) (c-symm) (def-p) (def-pp) (def-ntpp)]

       P-Scope
       [(c-refl) (c-symm) (def-p)]

       DC-PO-P-Scope
       [(c-refl) (c-symm) (def-dc) (def-p) (def-o) (def-po)
        (def-p-1) (def-pp) (def-pp-1)]

       DC-PO-C-Scope
       [(c-refl) (c-symm) (def-dc) (def-o) (def-po)
        (def-p) (def-p-1) (def-pp) (def-pp-1)]

       DC-PO-DR-Scope
       [(c-refl) (c-symm) (def-dc) (def-o) (def-po) (def-ec) (def-dr)
        (def-p) (def-p-1) (def-pp) (def-pp-1) (def-e=)]

       O-PO-PP-Scope
       [(c-refl) (c-symm) (def-p) (def-pp) (def-o) (def-po)
        (def-p-1) (def-pp-1)]

       PP-Split-Scope
       [(c-refl) (c-symm) (def-p) (def-pp) (def-tpp) (def-ntpp)]

       [RCC Theorem (initialise-plan)

        (kb-> PP-Scope)
        (lemma Lemma1
         "Proper part implies parthood.")

        (kb-> [Lemma1 | TPP-Scope])
        (lemma Lemma2
         "Tangential proper part implies proper part.")

        (kb-> [Lemma1 | NTPP-Scope])
        (lemma Lemma3
         "Non-tangential proper part implies proper part.")

        (kb-> P-Scope)
        (lemma Lemma4
         "Parthood lifts connection from part to whole.")

        (kb-> [Lemma4 | DC-PO-P-Scope])
        (lemma Lemma5
         "If x is disconnected from y and y partially overlaps z, then z is not part of x.")

        (kb-> DC-PO-C-Scope)
        (lemma Lemma6
         "Case split on whether x is connected to z; if not, then dc x z.")

        (kb-> [Lemma6 | DC-PO-DR-Scope])
        (lemma Lemma7
         "If x is connected to z, split on overlap to get ec x z or o x z.")

        (kb-> [Lemma1 Lemma5 | O-PO-PP-Scope])
        (lemma Lemma8
         "If x overlaps z and z is not part of x, then either po x z or pp x z.")

        (kb-> [Lemma2 Lemma3 | PP-Split-Scope])
        (lemma Lemma9
         "Proper part decomposes into tangential or non-tangential proper part.")

        (kb-> [Lemma8 Lemma9])
        (lemma Lemma10
         "Refine the overlap case from po or pp to po or tpp or ntpp.")

        (kb-> [Lemma6 Lemma7 Lemma10])
        (lemma Theorem
         "Combine the local case splits: dc or c; if c then ec or o; if o then po or pp; finally split pp into tpp or ntpp.")

        (end-of-plan)]))
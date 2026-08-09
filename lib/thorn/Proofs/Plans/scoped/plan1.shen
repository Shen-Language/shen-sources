(time (let* RCC [(c-refl) (c-symm) (def-dc) (def-p) (def-pp) (def-e=) (def-o)
          (def-po) (def-ec) (def-dr) (def-tpp) (def-ntpp) (def-p-1) (def-pp-1)
          (def-tpp-1) (def-ntpp-1)]

     Theorem
     [all x [all y [all z
       [[[dc x y] & [ec y z]]
        => [[[[[dc x z] v [ec x z]] v [po x z]] v [tpp x z]] v [ntpp x z]]]]]]

     Lemma1 [all x [all y [[ec x y] => [c x y]]]]
     Lemma2 [all x [all y [[pp x y] => [p x y]]]]
     Lemma3 [all x [all y [[tpp x y] => [pp x y]]]]
     Lemma4 [all x [all y [[ntpp x y] => [pp x y]]]]

     Lemma5 [all x [all y [all z [[[p x y] & [c z x]] => [c z y]]]]]

     Lemma6 [all x [all y [all z
       [[[dc x y] & [ec y z]] => [~ [p z x]]]]]]

     Lemma7 [all x [all y [all z
       [[[dc x y] & [ec y z]] => [[dc x z] v [c x z]]]]]]

     Lemma8 [all x [all y [all z
       [[[[dc x y] & [ec y z]] & [c x z]]
         => [[ec x z] v [o x z]]]]]]

     Lemma9 [all x [all y [all z
       [[[[[dc x y] & [ec y z]] & [c x z]] & [o x z]]
         => [[po x z] v [pp x z]]]]]]

     Lemma10 [all x [all y [[pp x y] => [[tpp x y] v [ntpp x y]]]]]

     Lemma11 [all x [all y [all z
       [[[[[dc x y] & [ec y z]] & [c x z]] & [o x z]]
         => [[po x z] v [[tpp x z] v [ntpp x z]]]]]]]

     \\ scoped dependency closures

     EC-Scope  [(c-symm) (def-ec)]
     PP-Scope  [(def-p) (def-pp)]
     TPP-Scope [(def-p) (def-pp) (def-tpp)]
     NTPP-Scope [(def-p) (def-pp) (def-ntpp)]

     P-Scope   [(c-symm) (def-p)]

     DC-EC-P-Scope
       [(c-symm) (def-dc) (def-p) (def-ec)]

     DC-EC-DR-Scope
       [(c-symm) (def-dc) (def-ec) (def-dr)]

     O-PO-PP-Scope
       [(c-symm) (def-p) (def-pp) (def-o) (def-po)]

     PP-Split-Scope
       [(def-p) (def-pp) (def-tpp) (def-ntpp)]

     [RCC Theorem (initialise-plan)

      (kb-> EC-Scope)
      (lemma Lemma1
       "External connection implies connection.")

      (kb-> PP-Scope)
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

      (kb-> [Lemma1 Lemma5 | DC-EC-P-Scope])
      (lemma Lemma6
       "Disconnected from y and externally connected to z excludes z being part of x.")

      (kb-> [Lemma1 | DC-EC-P-Scope])
      (lemma Lemma7
       "From dc(x,y) and ec(y,z), either dc(x,z) or c(x,z).")

      (kb-> [Lemma1 | DC-EC-DR-Scope])
      (lemma Lemma8
       "Given c(x,z), refine to ec(x,z) or o(x,z).")

      (kb-> [Lemma2 Lemma6 | O-PO-PP-Scope])
      (lemma Lemma9
       "If x overlaps z and z is not part of x, then po(x,z) or pp(x,z).")

      (kb-> [Lemma3 Lemma4 | PP-Split-Scope])
      (lemma Lemma10
       "Proper part splits into tangential or non-tangential proper part.")

      (kb-> [Lemma9 Lemma10])
      (lemma Lemma11
       "Refine po-or-pp to po-or-tpp-or-ntpp.")

      (kb-> [Lemma1 Lemma7 Lemma8 Lemma11])
      (lemma Theorem
       "Combine the dc/c split, then ec/o split, then po/tpp/ntpp refinement.")

      (end-of-plan)]))
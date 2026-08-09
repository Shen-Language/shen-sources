(time
 (let* RCC
       [(c-refl) (c-symm)
        (def-p) (def-o) (def-ec) (def-dc)
        (def-po) (def-pp) (def-tpp) (def-ntpp)]

       Theorem
       [all x [all y [all z
         [[[tpp x y] & [po y z]]
           => [[[[[dc x z] v [ec x z]] v [po x z]] v [tpp x z]] v [ntpp x z]]]]]]

       L1 [all x [all y [[tpp x y] => [pp x y]]]]
       L2 [all x [all y [[pp x y] => [p x y]]]]
       L3 [all x [all y [[po x y] => [o x y]]]]
       L4 [all x [all y [[po x y] => [~ [p y x]]]]]
       L5 [all x [all y [[c x y] => [[ec x y] v [o x y]]]]]
       L6 [all x [all y [[dc x y] v [c x y]]]]
       L7 [all x [all y [[pp x y] => [[tpp x y] v [ntpp x y]]]]]

       Hard
       [all x [all y [all z
         [[[[tpp x y] & [po y z]] & [o x z]]
           => [[po x z] v [pp x z]]]]]]

  [RCC Theorem
   (initialise-plan)

   (kb-> [(c-refl) (c-symm) (def-p) (def-pp) (def-tpp)])
   (lemma L1 "tpp gives pp")

   (kb-> [(c-refl) (c-symm) (def-p) (def-pp)])
   (lemma L2 "pp gives p")

   (kb-> [(c-refl) (c-symm) (def-p) (def-o) (def-po)])
   (lemma L3 "po gives overlap")
   (lemma L4 "po excludes p(z,y)")

   (kb-> [(c-refl) (c-symm) (def-o) (def-ec)])
   (lemma L5 "c splits into ec or overlap")

   (kb-> [(c-refl) (c-symm) (def-dc)])
   (lemma L6 "dc or c")

   (kb-> [(c-refl) (c-symm) (def-p) (def-pp) (def-tpp) (def-ntpp)])
   (lemma L7 "pp refines to tpp or ntpp")

   \\(thorn.timeout 30)
   (kb-> [(c-refl) (c-symm)
          (def-p) (def-o) (def-po) (def-pp) (def-tpp)])
   (lemma Hard "under tpp(x,y) and po(y,z), overlap xz refines to po or pp")
  \\ (thorn.timeout 5)

   (kb-> [L1 L2 L3 L4 L5 L6 L7 Hard
          (c-refl) (c-symm)
          (def-p) (def-o) (def-ec) (def-dc)
          (def-po) (def-pp) (def-tpp) (def-ntpp)])
   (lemma Theorem
          "split xz by dc/c; if c then ec/o; use the hard bridge on overlap; refine pp")
   (end-of-plan)]))
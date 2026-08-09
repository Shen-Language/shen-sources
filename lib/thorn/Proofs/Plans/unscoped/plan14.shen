(let RCC (rcc-axioms)

     Theorem
     [all x [all y [all z
       [[[ec x y] & [ntpp-1 y z]]
         => [dc x z]]]]]

     Lemma1 [all x [all y [[ntpp-1 x y] => [pp-1 x y]]]]
     Lemma2 [all x [all y [[pp-1 x y] => [p-1 x y]]]]
     Lemma3 [all x [all y [[ec x y] => [~ [o x y]]]]]

     Lemma4 [all x [all y [all z
       [[[ec x y] & [ntpp-1 y z]]
         => [~ [ec x z]]]]]]

     Lemma5 [all x [all y [all z
       [[[[ec x y] & [ntpp-1 y z]] & [c x z]]
         => [~ [o x z]]]]]]

     Lemma6 [all x [all y [all z
       [[[[ec x y] & [ntpp-1 y z]] & [c x z]]
         => [ec x z]]]]]

     [RCC Theorem (initialise-plan)

      (kb-> RCC)
      (lemma Lemma1 "Inverse non-tangential proper part implies inverse proper part.")

      (kb-> [Lemma1 | RCC])
      (lemma Lemma2 "Inverse proper part implies inverse parthood.")

      (kb-> [Lemma2 Lemma1 | RCC])
      (lemma Lemma3 "External connection excludes overlap.")

      (kb-> [Lemma3 Lemma2 Lemma1 | RCC])
      (thorn.timeout 20)
      (lemma Lemma4 "If y non-tangentially contains z, nothing can be externally connected to both y and z.")
      (thorn.timeout 5)

      (kb-> [Lemma4 Lemma3 Lemma2 Lemma1 | RCC])
      (lemma Lemma5 "Under the hypotheses, if x is connected to z then x does not overlap z.")

      (kb-> [Lemma5 Lemma4 Lemma3 Lemma2 Lemma1 | RCC])
      (lemma Lemma6 "Connected plus non-overlap gives ec(x,z).")

      (kb-> [Lemma6 Lemma5 Lemma4 Lemma3 Lemma2 Lemma1 | RCC])
      (lemma Theorem
       "Split on dc(x,z) or c(x,z). In the connected case use Lemma6 to get ec(x,z), contradicting Lemma4. Hence dc(x,z).")

      (end-of-plan)])
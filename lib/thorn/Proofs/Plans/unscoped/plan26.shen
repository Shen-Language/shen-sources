(let RCC (rcc-axioms)

     Theorem
     [all x [all y [all z
       [[[tpp x y] & [tpp y z]]
        => [[tpp x z] v [ntpp x z]]]]]]

     Lemma1
     [all x [all y
       [[tpp x y] => [pp x y]]]]

     Lemma2
     [all x [all y
       [[pp x y] => [p x y]]]]

     Lemma3
     [all x [all y [all z
       [[[p x y] & [p y z]]
        => [p x z]]]]]

     Lemma4
     [all x [all y
       [[[p x y] & [~ [p y x]]]
        => [pp x y]]]]

     Lemma5
     [all x [all y
       [[pp x y] => [[tpp x y] v [ntpp x y]]]]]

     [RCC Theorem (initialise-plan)

      (kb-> RCC)
      (lemma Lemma1 "Tangential proper part implies proper part.")

      (kb-> [Lemma1 | RCC])
      (lemma Lemma2 "Proper part implies parthood.")

      (kb-> [Lemma2 Lemma1 | RCC])
      (lemma Lemma3 "Parthood is transitive.")

      (kb-> [Lemma3 Lemma2 Lemma1 | RCC])
      (lemma Lemma4 "Parthood plus failure of converse parthood gives proper part.")

      (kb-> [Lemma4 Lemma3 Lemma2 Lemma1 | RCC])
      (lemma Lemma5 "Proper part splits into tangential or non-tangential proper part.")

      (kb-> [Lemma5 Lemma4 Lemma3 Lemma2 Lemma1 | RCC])
      (lemma Theorem
       "From tpp(x,y) and tpp(y,z) get p(x,y) and p(y,z); by transitivity get p(x,z). Since z cannot be part of x, infer pp(x,z), then split to tpp(x,z) or ntpp(x,z).")

      (end-of-plan)])
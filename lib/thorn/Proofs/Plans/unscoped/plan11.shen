(time (let* RCC (rcc-axioms)

     Theorem
     [all x [all y [all z
       [[[ec x y] & [tpp y z]]
        => [[[[ec x z] v [po x z]] v [tpp x z]] v [ntpp x z]]]]]]

     Lemma1
     [all x [all y [all z
       [[[ec x y] & [tpp y z]]
        => [~ [p z x]]]]]]

     Lemma2
     [all x [all y
       [[tpp x y] => [pp x y]]]]

     Lemma3
     [all x [all y
       [[pp x y] => [p x y]]]]

     Lemma4
     [all x [all y [all z
       [[[p x y] & [c z x]]
        => [c z y]]]]]

     Lemma5
     [all x [all y
       [[ec x y] => [c x y]]]]

     Lemma6
     [all x [all y [all z
       [[[ec x y] & [tpp y z]]
        => [c x z]]]]]

     Lemma7
     [all x [all y [all z
       [[[ec x y] & [tpp y z]]
        => [[ec x z] v [o x z]]]]]]

     Lemma8
     [all x [all y [all z
       [[[[ec x y] & [tpp y z]] & [o x z]]
        => [[po x z] v [pp x z]]]]]]

     Lemma9
     [all x [all y
       [[pp x y] => [[tpp x y] v [ntpp x y]]]]]

     Lemma10
     [all x [all y [all z
       [[[[ec x y] & [tpp y z]] & [o x z]]
        => [[po x z] v [[tpp x z] v [ntpp x z]]]]]]]

     [RCC Theorem (initialise-plan)

      (kb-> RCC)
      (thorn.timeout 100)
      (lemma Lemma1 "If x is externally connected to y and y is a tangential proper part of z, then z is not part of x.")
      (thorn.timeout 5)

      (kb-> [Lemma1 | RCC])
      (lemma Lemma2 "Tangential proper part implies proper part.")

      (kb-> [Lemma2 Lemma1 | RCC])
      (lemma Lemma3 "Proper part implies parthood.")

      (kb-> [Lemma3 Lemma2 Lemma1 | RCC])
      (lemma Lemma4 "Parthood transports connection from part to whole.")

      (kb-> [Lemma4 Lemma3 Lemma2 Lemma1 | RCC])
      (lemma Lemma5 "External connection implies connection.")

      (kb-> [Lemma5 Lemma4 Lemma3 Lemma2 Lemma1 | RCC])
      (lemma Lemma6 "From ec(x,y) and tpp(y,z), x is connected to z.")

      (kb-> [Lemma6 Lemma5 Lemma4 Lemma3 Lemma2 Lemma1 | RCC])
      (lemma Lemma7 "Since x is connected to z, either ec(x,z) or x overlaps z.")

      (kb-> [Lemma7 Lemma6 Lemma5 Lemma4 Lemma3 Lemma2 Lemma1 | RCC])
      (lemma Lemma8 "In the overlap case, exclusion of converse parthood yields po(x,z) or pp(x,z).")

      (kb-> [Lemma8 Lemma7 Lemma6 Lemma5 Lemma4 Lemma3 Lemma2 Lemma1 | RCC])
      (lemma Lemma9 "Proper part splits into tangential or non-tangential proper part.")

      (kb-> [Lemma9 Lemma8 Lemma7 Lemma6 Lemma5 Lemma4 Lemma3 Lemma2 Lemma1 | RCC])
      (lemma Lemma10 "Refine the overlap case to po(x,z) or tpp(x,z) or ntpp(x,z).")

      (kb-> [Lemma10 Lemma9 Lemma8 Lemma7 Lemma6 Lemma5 Lemma4 Lemma3 Lemma2 Lemma1 | RCC])
      (lemma Theorem
       "Use connection transport to get c(x,z). Then split into ec(x,z) or o(x,z). In the overlap case refine to po(x,z) or pp(x,z), then split pp into tpp(x,z) or ntpp(x,z).")

      (end-of-plan)]))
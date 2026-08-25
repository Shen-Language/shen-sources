(package lkl (lkl-external-symbols)

  \\(spy +)

  (d-rule nn1 ()

    [all x [[pred [succ x]] = x]] >> P;
    ___________________________________
    P;)

  (d-rule nn2 ()

    [all x [[~ [x = 0]] => [[succ [pred x]] = x]]] >> P;
    ____________________________________________________
    P;)

  (d-rule nn3 ()

    [all x [~ [[succ x] = 0]]] >> P;
    ________________________________
    P;)

  (d-rule nn4 ()

    [all x [all y [[[succ x] = [succ y]] => [x = y]]]] >> P;
    ________________________________________________________
    P;)

  (d-rule mathind ()

    let Base (fol.sub 0 X P)
    let Psucc (fol.sub [succ X] X P)
    let Inductive [all X [P => Psucc]]
    Base;
    Inductive;
    ________________________________
    [all X P];)

  (define kl-atom?
    {term --> boolean}
    Term -> (and (not (fol.t-term? Term))
                 (or (symbol? Term)
                     (string? Term)
                     (number? Term)
                     (boolean? Term)
                     (empty? Term))))

   (d-rule l1 (Z : term)

    if (kl-atom? Z)
    [all x [all y [~ [Z = [cons x y]]]]] >> P;
    ____________________________________________
    P;)

   (d-rule l2 ()

    [all x [all y [~ [[cons x y] = x]]]] >> P;
    ____________________________________________
    P;)

   (d-rule l3 ()

    [all x [all y [~ [[cons x y] = y]]]] >> P;
    __________________________________________
    P;)

    (d-rule l4 ()

    [all x [all y [[hd [cons x y]] = x]]] >> P;
    ____________________________________________
    P;)

    (d-rule l5 ()

    [all x [all y [[tl [cons x y]] = y]]] >> P;
    ____________________________________________
    P;)

    (d-rule l6 ()

      [all x [all y [all w [all z [[[cons x y] = [cons w z]] => [[x = w] & [y = z]]]]]]] >> P;
      ________________________
      P;)

    (d-rule listind ()

      let Base (fol.sub [] X P)
      let Y (gensym y)
      let Pcons (fol.sub [cons Y X] X P)
      let Inductive [all X [all Y [P => Pcons]]]
      Base;
      Inductive;
      _________________________________________
     [all X P];)

    (d-rule t1 ()

      [all x [~ [[@p x y] = x]]] >> P;
      ________________________________
      P;)

    (d-rule t2 ()

      [all x [~ [[@p x y] = x]]] >> P;
      ________________________________
      P;)

     (d-rule t3 ()

      [all x [[fst [@p x y]] = x]] >> P;
      ________________________________
      P;)

     (d-rule t4 ()

      [all x [[snd [@p x y]] = y]] >> P;
      ________________________________
      P;)

    (d-rule t5 ()

      [all x [all y [all w [all z [[[@p x y] = [@p w z]] => [[x = w] & [y = z]]]]]]] >> P;
      ________________________
      P;)

    (d-rule because ()

      ____________
      P;)

    (d-rule semantics (S : proper-symbol)

      let Hypotheses (append (get-axioms S) Hypotheses)

      P;
      ____
      P;)

    (define normalise-prop
      {term --> number --> prop --> prop}
       X N P -> (fol.subn (eval X) X P N)  where (evaluable? X (boundv P))
       _ _ P -> P)

    (define boundv
      {prop --> (list term)}
      [all X P] -> [X | (boundv P)]
      [exists X P] -> [X | (boundv P)]
      [P v Q] -> (append (boundv P) (boundv Q))
      [P & Q] -> (append (boundv P) (boundv Q))
      [P => Q] -> (append (boundv P) (boundv Q))
      [P <=> Q] -> (append (boundv P) (boundv Q))
      [~ P] -> (boundv P)
      _ -> [])

    (define normalise-nth-prop
      {number --> term --> number --> (list prop) --> (list prop)}
       _ _ _ [] -> []
       1 X N [P | Ps] -> [(normalise-prop X N P) | Ps]
       M X N [P | Ps] -> [P | (normalise-nth-prop (- M 1) X N Ps)])

    (d-rule normalise (X : term M : number N : number)

     let Q (if (= M 0) (normalise-prop X N P) P)
     let Hypotheses (if (> M 0)
                        (normalise-nth-prop M X N Hypotheses)
                        Hypotheses)
     Q;
     ____________
     P;)

    (d-rule b1 ()

    [~ [true = false]] >> P;
    ___________________
    P;)

    (define beta-reduce
     {term --> term}
     [[lambda X Y] W] -> (fol.sub* W X Y)
     [[lambda X Y] W | Z] -> [(fol.sub* W X Y) | Z]
     X -> X)

    (define beta-prop
      {term --> number --> prop --> prop}
       X N P -> (fol.subn (beta-reduce X) X P N)
       _ _ P -> P)

  (define beta-nth-prop
      {number --> term --> number --> (list prop) --> (list prop)}
       _ _ _ [] -> []
       1 X N [P | Ps] -> [(beta-prop X N P) | Ps]
       M X N [P | Ps] -> [P | (beta-nth-prop (- M 1) X N Ps)])

   (d-rule beta (X : term M : number N : number)

     let Q (if (= M 0) (beta-prop X N P) P)
     let Hypotheses (if (> M 0)
                        (beta-nth-prop M X N Hypotheses)
                        Hypotheses)
     Q;
     ____________
     P;)  )

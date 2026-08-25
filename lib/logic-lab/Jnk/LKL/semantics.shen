(package lkl (append [x y z x1 y1 z1 x2 y2 z2 xn yn fol.atomic?] (lkl-external-symbols))

(synonyms clause (list prop))

(define axiomatise
  {string --> string}
   File -> (let KLFile       (bootstrap File)
                KL           (read-file KLFile)
                Axioms       (mapcan (fn store-axioms) KL)
                StringAxioms (map (/. Axiom (make-string "~R~%~%" Axiom)) Axioms)
                Plan9Axioms  (map (fn p9) Axioms)
                AxiomsFile   (file-extension File ".axioms")
                Plan9File    (file-extension File ".plan9")
                OpenAxioms   (open AxiomsFile out)
                OpenPlan9    (open Plan9File out)
                WriteAxioms  (map (/. String (pr String OpenAxioms)) StringAxioms)
                WritePlan9   (map (/. String (pr String OpenPlan9)) Plan9Axioms)
                CloseAxioms  (close OpenAxioms)
                ClosePlan9   (close OpenPlan9)
                AxiomsFile))

(define axiomatic-semantics
  {def --> (list prop)}
  Def -> (let FUNC              (func Def)
              REDUCE            (reduction Def)
              NORMALISE         (normalise-terms REDUCE)
              ASCEND            (ascend NORMALISE)
              DIST              (dist ASCEND)
              PROPS             (props DIST)
              CLAUSES           (mapcan (fn clauses) PROPS)
              EMEND             (mapcan (fn emend) CLAUSES)
              IMPLICATIONS      (implications EMEND FUNC)
              ConsIntro         (map (fn cons-introduction) IMPLICATIONS)
              Closure           (map (fn universal-closure) ConsIntro)
              Closure))

\\ ------------------STAGE 1 Reduction ---------------------------------

(define reduction
  {def --> def}
  [defun F Params Body] -> [defun F Params (fixwalk (fn reduce-h) Body)])

(define fixwalk
   {(term --> term) --> term --> term}
    F X -> (let Walk (walk F X)
                      (if (= X Walk)
                          X
                          (fixwalk F Walk))))

(define walk
   {(term --> term) --> term --> term}
    F [X | Y] -> (F [(walk F X) | (map (/. Z (walk F Z)) Y)])
    F X -> (F X))

(define reduce-h
   {term --> term}
   [cond [true Q]]  -> Q
   [cond [P Q]]     -> [if P Q [abort]]
   [cond [P Q] | R] -> [if P Q [cond | R]]
   [or P Q]         -> [if P true Q]
   [not P]          -> [if P false true]
   [freeze X]       -> [lambda (newv) X]
   [let X Y Z]      -> [[lambda X Z] Y]
   [[lambda X Y] Z] -> (fol.sub* Z X Y)
   [thaw X]         -> [X 0]
   [shen.f-error _] -> [abort]
   [simple-error _] -> [abort]
   [error | _]      -> [abort]
   X -> X)

\\ ------------------STAGE 2 Normalisation ---------------------------------

(define normalise-terms
   {def --> def}
   [defun F Params Body] -> [defun F Params (normalise-h Body (syms->terms Params))])

(define syms->terms
  {(list proper-symbol) --> (list term)}
   [] -> []
   [S | Ss] -> [S | (syms->terms Ss)])

(define normalise-h
   {term --> (list term) --> term}
   [lambda X Y] Bound -> [lambda X (normalise-h Y [X | Bound])]
   [X | Y] Bound -> (eval [X | Y])       where (evaluable? [X | Y] Bound)
   [X | Y] Bound -> [(normalise-h X Bound) | (map (/. Z (normalise-h Z Bound)) Y)]
   X _ -> X)

(define evaluable?
   {term --> (list term) --> boolean}
    [abort] _ -> false
    [X | Y] Bound -> (every? (/. Z (evaluable? Z Bound)) [X | Y])
    X Bound -> false          where (element? X Bound)
    X _ -> false              where (fresh? X)
    _ _ -> true)

(define fresh?
  {term --> boolean}
   X -> (and (symbol? X) (fresh-h? (x->ascii X))))

(define fresh-h?
  {(list number) --> boolean}
   [116 109 | _] -> true
   _ -> false)

\\ ----------------Stage 3 Semantic Ascent ---------

(define ascend
    {def --> prop}
    [defun F Parameters Body]
    -> (let Prop (ascend-def [defun F Parameters Body] [F | (syms->terms Parameters)])
            (fixwalkprop (fn ascend-prop) Prop)))

(define fixwalkprop
   {(prop --> prop) --> prop --> prop}
    F X -> (let Walk (walkprop F X)
                      (if (= X Walk)
                           X
                           (fixwalkprop F Walk))))

(define walkprop
   {(prop --> prop) --> prop --> prop}
     F [all V P]    -> (F [all V (walkprop F P)])
     F [exists V P] -> (F [exists V (walkprop F P)])
     F [P v Q]      -> (F [(walkprop F P) v (walkprop F Q)])
     F [P & Q]      -> (F [(walkprop F P) & (walkprop F Q)])
     F [P => Q]     -> (F [(walkprop F P) => (walkprop F Q)])
     F [P <=> Q]    -> (F [(walkprop F P) <=> (walkprop F Q)])
     F [~ P]        -> (F [~ (walkprop F P)])
     F P            -> (F P))

(define ascend-def
   {def --> term --> prop}
    [defun F [] Body] FX   -> [FX = Body]
    [defun F [X | Y] Body] FX -> [all X (ascend-def [defun F Y Body] FX)])

(define ascend-prop
   {prop --> prop}
   [[if P Q R] = X]    -> [[[P = true] => [X = Q]] & [[P = false] => [X = R]]]
   [X = [if P Q R]]    -> [[[P = true] => [X = Q]] & [[P = false] => [X = R]]]
   [[and P Q] = true]  -> [[P = true] & [Q = true]]
   [true = [and P Q]]  -> [[P = true] & [Q = true]]
   [[and P Q] = false] -> [[P = false] v [Q = false]]
   [false = [and P Q]] -> [[P = false] v [Q = false]]
   [[or P Q] = true]   -> [[P = true] v [Q = true]]
   [true = [or P Q]]   -> [[P = true] v [Q = true]]
   [[or P Q] = false]  -> [[P = false] v [Q = false]]
   [false = [or P Q]]  -> [[P = false] v [Q = false]]
   [[not P] = true]    -> [P = false]
   [[not P] = false]   -> [P = true]
   [[== X Y] = true]   -> [X = Y]
   [true = [== X Y]]   -> [X = Y]
   [[== X Y] = false]  -> [~ [X = Y]]
   [false = [== X Y]]  -> [~ [X = Y]]
   [true = [cons? X]]  -> (let Y (newv)
                               Z (newv)
                               [exists Y [exists Z [[cons Y Z] = X]]])
   [[cons? X] = true]  -> (let Y (newv)
                               Z (newv)
                               [exists Y [exists Z [[cons Y Z] = X]]])
   [true = [tuple? X]] -> (let Y (newv)
                               Z (newv)
                               [exists Y [exists Z [[@p Y Z] = X]]])
   [[tuple? X] = true] -> (let Y (newv)
                               Z (newv)
                               [exists Y [exists Z [[@p Y Z] = X]]])
   P -> P)

\\ ----------------Stage 4 Distributing & ---------

(define dist
  {prop --> prop}
   P -> (fixwalkprop (fn distrules) P))

(define distrules
  {prop --> prop}
   [all X [P & Q]] -> [[all X P] & [all X Q]]
   [P => [Q & R]] -> [[P => Q] & [P => R]]
   P -> P)

\\ ----------------Stage 5 Generating props from conjunctions --------------

(define props
  {prop --> (list prop)}
   [P & Q] -> (append (props P) (props Q))
   P -> [P])

\\ -------------------- Stage 6 Conversion to Clause Form ---------------------

(define clauses
  {prop --> (list clause)}
   P -> (subsumption (cnf->clauses (cnf P))))

(define subsumption
  {(list clause) --> (list clause)}
   Clauses -> (subsumption-h Clauses Clauses))

(define subsumption-h
  {(list clause) --> (list clause) --> (list clause)}
   [] _ -> []
   [C | Cs] Clauses -> (subsumption-h Cs Clauses)  where (subsumed-within? C Clauses)
   [C | Cs] Clauses -> [C | (subsumption-h Cs Clauses)])

(define subsumed-within?
  {clause --> (list clause) --> boolean}
   Clause Clauses -> (subsumed-within-h? Clause (remove Clause Clauses)))

(define subsumed-within-h?
  {clause --> (list clause) --> boolean}
   _ [] -> false
   C [C* | Cs] -> (or (subsumed? C C*) (subsumed-within-h? C Cs)))

(define subsumed?
  {clause --> clause --> boolean}
  C C* -> (subset? C* C))

(define cnf->clauses
  {prop --> (list clause)}
  [P & Q] -> (union (cnf->clauses P) (cnf->clauses Q))
  P -> [(cch P)])

(define cch
  {prop --> clause}
  [P v Q] -> (union (cch P) (cch Q))
  P -> [P])

(define cnf
  {prop --> prop}
   P -> (elim-all (skolemise P)))

(define elim-all
  {prop --> prop}
   [all X P] -> (fol.sub (newv) X (elim-all P))
   P -> P)

(define skolemise
  {prop --> prop}
  P -> (sk-help (prenex P) []))

(define sk-help
  {prop --> (list term) --> prop}
  [all X P] Vs -> [all X (sk-help P [X | Vs])]
  [exists X P] Vs
  -> (let Q (sk-help P Vs)
          SkTerm (type (if (empty? Vs) (gensym c) [(gensym f) | Vs]) term)
          (sk-help (fol.sub SkTerm X Q) Vs))
  P _ -> P)

(define prenex
  {prop --> prop}
   P -> (fix (fn prenex*) (rectify P)))

(define rectify
  {prop --> prop}
  [all X P] -> (let Y (gensym x)  [all Y (rectify (fol.sub Y X P))])
  [exists X P]
    -> (let Y (gensym x)  [exists Y (rectify (fol.sub Y X P))])
  [P & Q] -> [(rectify P) & (rectify Q)]
  [P v Q] -> [(rectify P) v (rectify Q)]
  [P => Q] -> [(rectify P) => (rectify Q)]
  [P <=> Q] -> [(rectify P) <=> (rectify Q)]
  [~ P] -> [~ (rectify P)]
  P -> P)

(define prenex*
  {prop --> prop}
  [~ [all X P]] -> [exists X [~ P]]
  [~ [exists X P]] -> [all X [~ P]]
  [~ [P & Q]] -> [[~ P] v [~ Q]]
  [~ [P v Q]] -> [[~ P] & [~ Q]]
  [~ [~ P]] -> P
  [~ P] -> [~ (prenex* P)]
  [[all X P] & Q] -> [all X [P & Q]]
  [[all X P] v Q] -> [all X [P v Q]]
  [[exists X P] & Q] -> [exists X [P & Q]]
  [[exists X P] v Q] -> [exists X [P v Q]]
  [P & [all X Q]] -> [all X [P & Q]]
  [P & [exists X Q]] -> [exists X [P & Q]]
  [P v [Q & R]] -> (rectify [[P v Q] & [P v R]])
  [[Q & R] v P] -> (rectify [[P v Q] & [P v R]])
  [P v [all X Q]] -> [all X [P v Q]]
  [P v [exists X Q]] -> [exists X [P v Q]]
  [P v Q] -> [(prenex* P) v (prenex* Q)]
  [P => Q] -> [[~ P] v Q]
  [P <=> Q] -> (rectify [[P => Q] & [Q => P]])
  [P & Q] -> [(prenex* P) & (prenex* Q)]
  [all X P] -> [all X (prenex* P)]
  [exists X P] -> [exists X (prenex* P)]
  P -> P)

  ----------------------- Stage 7 Emending ------------------------------------

(define emend
  {clause --> (list clause)}
   Clause -> (if (truism? Clause)
                 []
                 (let Factorise Clause \\ (factorise-clause Clause)
                      Cross     (cross-fertilise Factorise)
                      Remove    (remove-contradictions Cross)
                      Demod     (demod-clause Remove)
                      (if (= Demod Clause)
                          [Clause]
                          (emend Demod)))))

 \\ ------------------------ 7.1 truism Elimination -----------------------------

(define truism?
  {clause --> boolean}
   Clause -> (or (contains-necessary-truth? Clause)
                 (tautology? Clause)))

(define contains-necessary-truth?
  {clause --> boolean}
   Clause -> (some? (fn necessary-truth?) Clause))

(define necessary-truth?
  {prop --> boolean}
   [[cons? [cons X Y]] = true] -> true
   [true = [cons? [cons X Y]]] -> true
   [~ [[cons? [cons X Y]] = false]] -> true
   [~ [false = [cons? [cons X Y]]]] -> true
   P -> false)

(define tautology?
   {clause --> boolean}
   [] -> false
   [P | Ps] -> (or (find-complement? P Ps) (truism? Ps)))

(define find-complement?
  {prop --> clause --> boolean}
   _ [] -> false
   P [Q | Ps] -> (or (complement? P Q) (find-complement? P Ps)))

(define complement?
  {prop --> prop --> boolean}
   [~ P] P -> true
   P [~ P] -> true
   _ _ -> false)

 \\----------------------- Stage 7.2 Factorisation ------------------------------------

(define factorise-clause
  {clause --> clause}
  Clause -> (factorise-clause-h Clause Clause))

(define factorise-clause-h
  {clause --> clause --> clause}
  [] Clause -> Clause
  [P | Ps] Clause -> (let MGU (find-factor P (remove P Clause))
                          (if (failed? MGU)
                              (factorise-clause-h Ps Clause)
                              (remove-duplicates (deref-clause Clause MGU)))))

(define deref-clause
  {clause --> (list (term * term)) --> clause}
   Clause MGU -> (map (/. P (deref-prop P MGU)) Clause))

(define deref-prop
  {prop --> (list (term * term)) --> prop}
   [~ P] MGU -> [~ (deref-prop P MGU)]
   [X = Y] MGU -> [(deref X MGU) = (deref Y MGU)]
   [F | X] MGU -> [F | (map (/. Y (deref Y MGU)) X)]  where (fol.atomic? [F | X]))

(define find-factor
  {prop --> clause --> (list (term * term))}
   P [] -> (failed!)
   P [Q | Ps] -> (let MGU (unify P Q)
                      (if (failed? MGU)
                          (find-factor P Ps)
                          MGU)))

(define unify
  {prop --> prop --> (list (term * term))}
   [~ P] [~ Q]     -> (unify P Q)
   [~ P] _         -> (failed!)
   _ [~ Q]         -> (failed!)
   [X = Y] [W = Z] -> (unify-h (listtm->tm [X Y]) (listtm->tm [W Z]) [])
   [F | X] [F | Y] -> (unify-h (listtm->tm X) (listtm->tm Y) []) where (and (fol.atomic? [F | X])
                                                                            (fol.atomic? [F | Y]))
   _ _             -> (failed!))

(define listtm->tm
  {(list term) --> term}
  [] -> []
  [X | Y] -> [X | Y])

(define unify-h
  {term --> term --> (list (term * term)) --> (list (term * term))}
  X X MGU -> MGU
  X Y MGU -> [(@p X Y) | MGU]         where (and (variable? X) (= (occurrences X Y) 0))
  Y X MGU -> [(@p X Y) | MGU]         where (and (variable? X) (= (occurrences X Y) 0))
  [X | Y] [W | Z] MGU -> (let NewMGU (unify-h X W MGU)
                              (if (failed? NewMGU)
                                  (failed!)
                                  (unify-h (deref (listtm->tm Y) NewMGU)
                                           (deref (listtm->tm Z) NewMGU)
                                           NewMGU)))
  _ _ _ -> (failed!))

(define failed?
  {(list (term * term)) --> boolean}
    [(@p void void)] -> true
    _ -> false)

(define failed!
  {--> (list (term * term))}
   ->  [(@p void void)])

(define deref
  {term --> (list (term * term)) --> term}
   [X | Y] MGU -> [(deref X MGU) | (map (/. Z (deref Z MGU)) Y)]
   X MGU -> (let ValX (trap-error (snd (assocp X MGU)) (/. E X))
                 (if (= ValX X)
                     X
                     (deref ValX MGU))))

\\ ------------------------ Stage 7.3 Cross Fertilisation ------------------------------

(define cross-fertilise
  {clause --> clause}
   Clause -> (let Cross (cross-fertilise-h Clause Clause)
                  (if (= Cross Clause)
                      Clause
                      (cross-fertilise Cross))))

(define cross-fertilise-h
  {clause --> clause --> clause}
   [] Clause -> Clause
   [[~ [X = Y]] | Ps] Clause -> (let MGU (unify-h X Y [])
                                     (if (failed? MGU)
                                         (cross-fertilise-h Ps Clause)
                                         (remove~X=X (deref-clause Clause MGU))))
   [_ | Ps] Clause -> (cross-fertilise-h Ps Clause))

(define remove~X=X
  {clause --> clause}
   [] -> []
   [[~ [X = X]] | Ps] -> (remove~X=X Ps)
   [P | Ps] -> [P | (remove~X=X Ps)])

\\ ------------------------ Stage 7.4  Removing Contradictions ----------------------------

(define remove-contradictions
  {clause --> clause}
   Clause -> (remove-if (fn contradiction?) Clause))

(define contradiction?
  {prop --> boolean}
   [[] = [cons X Y]] -> true
   [[cons X Y] = []] -> true
   [true = false]    -> true
   [false = true]    -> true
   _ -> false)

\\ ------------------------ Stage 7.5  Demodulation ---------------------------

(define demod-clause
  {clause --> clause}
   Clause -> (map (fn demod-prop) Clause))

(define demod-prop
  {prop --> prop}
   P -> (walkprop (fn demodterms) P))

(define demodterms
  {prop --> prop}
   [X = Y] -> [(demod-term X) = (demod-term Y)]
   P -> P)

(define demod-term
  {term --> term}
   [hd [cons X Y]] -> X
   [tl [cons X Y]] -> Y
   [fst [@p X Y]]  -> X
   [snd [@p X Y]]  -> Y
   [X | Y] -> [(demod-term X) | (map (fn demod-term) Y)]
   X -> X)

\\ -------------------- Stage 8 Implications ---------------------

(define func
  {def --> term}
   [defun F X Y] -> F)

(define implications
  {(list clause) --> term --> (list prop)}
   Clauses Func -> (map (/. Clause (implication Clause Func)) Clauses))

(define implication
  {clause --> term --> prop}
   Clause Func -> (let Head (find-head Clause Func)
                       Body (remove Head Clause)
                      (if (empty? Body)
                          Head
                          [(conjneg Body) => Head])))

(define find-head
  {clause --> term --> prop}
   [[[Func | X] = Y] | _] Func -> [[Func | X] = Y]
   [[Y = [Func | X]] | _] Func -> [Y = [Func | X]]
   [_ | Ps] Func -> (find-head Ps Func))

(define conjneg
  {clause --> prop}
   [P] -> (complement P)
   [P | Ps] -> [(complement P) & (conjneg Ps)])

(define complement
  {prop --> prop}
   [~ P] -> P
   P -> [~ P])

\\ -------------------- Stage 9 Cons Introduction ------------------

(define cons-introduction
  {prop --> prop}
   P -> (walkprop (fn cons-introduction-rule) P))

(define cons-introduction-rule
   {prop --> prop}
   [[cons? X] = false]  -> (let Y xn
                                Z yn
                                [all Y [all Z [~ [X = [cons Y Z]]]]])
   [false = [cons? X]]  -> (let Y xn
                                Z yn
                                [all Y [all Z [~ [X = [cons Y Z]]]]])
   [[tuple? X] = false]  -> (let Y xn
                                Z yn
                                [all Y [all Z [~ [X = [@p Y Z]]]]])
   [false = [tuple? X]]  -> (let Y xn
                                Z yn
                                [all Y [all Z [~ [X = [@p Y Z]]]]])
   P -> P)

\\ -------------------- Stage 10 universal closure --------------------------

(define universal-closure
  {prop --> prop}
   P -> (let Vars (vars-in P)
             Pretty (type [x y z x1 y1 z1 x2 y2 z2] (list proper-symbol))
             Sub   (form-universal-closure Pretty Vars P)
             Sub))

(define form-universal-closure
  {(list proper-symbol) --> (list term) --> prop --> prop}
  _ [] P -> P
  [Pretty | Prettys] [V | Vs] P -> [all Pretty (fol.sub Pretty V (form-universal-closure Prettys Vs P))])

(define vars-in
  {prop --> (list term)}
   [all V P]    -> (vars-in P)
   [exists V P] -> (vars-in P)
   [P v Q]      -> (union (vars-in P) (vars-in Q))
   [P & Q]      -> (union (vars-in P) (vars-in Q))
   [P => Q]     -> (union (vars-in P) (vars-in Q))
   [P <=> Q]    -> (union (vars-in P) (vars-in Q))
   [~ P]        -> (vars-in P)
   [X = Y]      -> (vars-in-term (listtm->tm [X Y]))
   [F | X]      -> (vars-in-term (listtm->tm X))  where (fol.atomic? [F | X]))

(define vars-in-term
  {term --> (list term)}
   X -> [X]           where (variable? X)
   [X | Y] -> (union (vars-in-term X) (vars-in-term (listtm->tm Y)))
   _ -> [])  )

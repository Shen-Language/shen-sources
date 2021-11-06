\\           Copyright (c) 2010-2019, Mark Tarver

\\                  All rights reserved.

(package shen []

(defcc <datatype>
  D <datatype-rules> := (let Prolog (rules->prolog D <datatype-rules>)
                             (remember-datatype D (fn D)));)

(defcc <datatype-rules>
  <datatype-rule> <datatype-rules> := (append <datatype-rule> <datatype-rules>);
  <!> := (if (empty? <!>) [] (error "datatype syntax error here:~% ~R~% ..." <!>));)

(defcc <datatype-rule>
  <single>;
  <double>;)

(defcc <single>
  <sides> <prems> <sng> <conc> <sc> := [[<sides> <prems> <conc>]];)

(defcc <double>
  <sides> <formulae> <dbl> <formula> <sc> := (lr-rule <sides> <formulae> [[] <formula>]);)

(defcc <formulae>
  <formula> <sc> <formulae> := [[[] <formula>] | <formulae>];
  <formula> <sc>            := [[[] <formula>]];)

(defcc <conc>
  <ass> >> <formula> := [<ass> <formula>];
  <formula>          := [[] <formula>];)

(defcc <prems>
  <prem> <sc> <prems> := [<prem> | <prems>];
  <e> := [];)

(defcc <prem>
  !                   := !;
  <ass> >> <formula>  := [<ass> <formula>];
  <formula>           := [[] <formula>];)

(defcc <ass>
   <formula> <iscomma> <ass> := [<formula> | <ass>];
   <formula>         := [<formula>];
   <e> := [];)

(defcc <iscomma>
  X := skip  where (= X (intern ","));)

(defcc <formula>
   <expr> <iscolon> <type> := [(curry <expr>) (intern ":") (rectify-type <type>)];
   <expr>          := <expr>;)

(defcc <iscolon>
  X := skip   where (= X (intern ":"));)

(defcc <sides>
  <side> <sides> := [<side> | <sides>];
  <e> := [];)

(defcc <side>
  if P    := [if P];
  let X Y := [let X Y];
  let! X Y := [let! X Y];)

(define lr-rule
  Side Sequents [[] C] -> (let P (gensym (protect P))
                               LConc [[C] P]
                               LPrem [(coll-formulae Sequents) P]
                               Left [Side [LPrem] LConc]
                               Right [Side Sequents [[] C]]
                               [Right Left])
  _ _ _ -> (simple-error "implementation error in shen.lr-rule"))

(define coll-formulae
  [] -> []
  [[[] Q] | Sequents] -> [Q | (coll-formulae Sequents)]
  _ -> (simple-error "implementation error in shen.coll-formulae"))

(defcc <expr>
  X := (macroexpand X) where (not (key-in-sequent-calculus? X));)

(define key-in-sequent-calculus?
  X -> (or (element? X [>> (intern ";") (intern ",") (intern ":") <--]) (sng? X) (dbl? X)))

(defcc <type>
   <expr> := <expr>;)

(defcc <dbl>
  X := X	where (dbl? X);)

(defcc <sng>
  X := X	where (sng? X);)

(define sng?
  S -> (and (symbol? S) (sng-h? (str S))))

(define sng-h?
  "___" -> true
  (@s "_" S) -> (sng-h? S)
  _ -> false)

(define dbl?
  S -> (and (symbol? S) (dbl-h? (str S))))

(define dbl-h?
  "===" -> true
  (@s "=" S) -> (dbl-h? S)
  _ -> false)

(define remember-datatype
  D Fn -> (do (set *datatypes* (assoc-> D Fn (value *datatypes*)))
              (set *alldatatypes* (assoc-> D Fn (value *alldatatypes*)))
              D))

(define rules->prolog
  D Rules -> (let Clauses (mapcan (/. Rule (rule->clause Rule)) Rules)
                  (eval [defprolog D | Clauses])))

(define rule->clause
    [S P [As R]] -> (let Constraints (extract-vars [S P [As R]])
                         HypVs (nvars (+ 1 (length As)))
                         Active (extract-vars R)
                         Head (compile-consequent R HypVs)
                         Goals (goals Constraints As S P HypVs Active)
                         (append Head [<--] Goals [(intern ";")]))
    _            -> (simple-error "implementation error in shen.rule->clause"))

(define compile-consequent
  R [H | _] -> [(optimise-typing R) H]
  _ _ -> (simple-error "implementation error in shen.compile-consequent"))

(define nvars
   0 -> []
   N -> [(gensym (protect V)) | (nvars (- N 1))])

(define optimise-typing
  [X C A] -> [- (cons-form-with-modes [X C [+ A]])]  where (= C (intern ":"))
  X -> [+ (cons-form-with-modes X)])

(define cons-form-with-modes
  [- X] -> [- (cons-form-with-modes X)]
  [+ X] -> [+ (cons-form-with-modes X)]
  [mode X Mode] -> [Mode (cons-form-with-modes X)]
  [bar! Y] -> Y
  [X | Y] -> [cons (cons-form-with-modes X) (cons-form-with-modes Y)]
  X -> X)

(define goals
   Constraints As S P HypVs Active
   -> (let GoalsAs (compile-assumptions As Constraints HypVs Active)
           GoalsS (compile-side-conditions S)
           GoalsP (compile-premises P HypVs)
           (append GoalsAs GoalsS GoalsP)))

(define compile-assumptions
  [] _ _ _ -> []
  [A | As] Constraints [H1 H2 | HypVs] Active
   -> (let NewActive (append (extract-vars A) Active)
           [(compile-assumption A H1 H2 Constraints Active)
            | (compile-assumptions As Constraints [H2 | HypVs] NewActive)])
  _ _ _ _ ->  (simple-error "implementation error in shen.compile-assumptions"))

(define compile-assumption
  A H1 H2 Constraints Active
  -> (let F (gensym search)
          Compile (compile-search-procedure F A H1 H2 Constraints Active)
          [F H1 [] H2 | Constraints]))

(define compile-search-procedure
    F A H1 H2 Constraints Active
     -> (let Past (gensym (protect Previous))
             Base (foundit! A H1 Past H2 Constraints Active)
             Recursive (keep-looking F H1 Past H2 Constraints)
             (eval [defprolog F | (append Base Recursive)])))

(define foundit!
    A H1 Past H2 Constraints Active
    -> (let  Passive (passive A Active)
             Table (tabulate-passive Passive)
             Head  (head-foundit! A H1 Past H2 Constraints Table)
             Body (body-foundit! H1 Past H2 Table)
             (append Head [<--] Body [(intern ";")])))

(define keep-looking
   F H1 Past H2 Constraints
   ->  (let X (gensym (protect V))
            Head   [[- [cons X H1]] Past H2 | Constraints]
            Body   [[F H1 [cons X Past] H2 | Constraints]]
            (append Head [<--] Body [(intern ";")])))

(define passive
   [X | Y] Active -> (union (passive X Active) (passive Y Active))
   X Active -> [X]  where (passive? X Active)
   _ _ -> [])

(define passive?
   X Active -> (and (not (element? X Active)) (variable? X)))

(define tabulate-passive
   Passive -> (map (/. X [X | (gensym (protect V))]) Passive))

(define head-foundit!
    A H1 Past H2 Constraints Table
  -> (let Optimise (optimise-passive Constraints Table)
             [[- [cons (optimise-typing A) H1]] Past H2 | Optimise]))

(define optimise-passive
   Constraints Table -> (map (/. C (optimise-passive-h C Table)) Constraints))

(define optimise-passive-h
   C Table -> (let Entry (assoc C Table)
                   (if (empty? Entry) C (tl Entry))))

(define body-foundit!
  H1 Past H2 [] -> [[bind H2 [append [1 Past] [1 H1]]]]
  H1 Past H2 [[C | V] | Table] -> [[bind V C] | (body-foundit! H1 Past H2 Table)]
  _ _ _ _ -> (simple-error "implementation error in shen.body-foundit!"))

(define compile-side-conditions
  S -> (map (/. X (compile-side-condition X)) S))

(define compile-side-condition
  [let X Y] -> [is X Y]
  [let! X Y] -> [is! X Y]
  [if P] -> [when P]
  _ -> (simple-error "implementation error in shen.compile-side-condition"))

(define compile-premises
  P HypVs -> (let Hyp (hd (reverse HypVs))
                  (map (/. X (compile-premise X Hyp)) P)))

(define compile-premise
  ! _ -> !
  [As R] Hyp -> (compile-premise-h (reverse As) R Hyp)
  _ _ -> (simple-error "implementation error in shen.premise"))

(define compile-premise-h
  [] R Hyp -> [system-S (cons-form-no-modes R) Hyp]
  [A | As] R Hyp -> (compile-premise-h As R [cons (cons-form-no-modes A) Hyp])
  _ _ _ -> (simple-error "implementation error in shen.compile-premise-h"))

(define cons-form-no-modes
  [bar! Y] -> Y
  [X | Y]  -> [cons (cons-form-no-modes X) (cons-form-no-modes Y)]
  X -> X)

(define preclude
   Types -> (let InternTypes (map (/. X (intern-type X)) Types)
                 Datatypes   (value *datatypes*)
                 Remove      (remove-datatypes InternTypes Datatypes)
                 NewDatatypes (set *datatypes* Remove)
                 (show-datatypes NewDatatypes)))

(define remove-datatypes
  [] Datatypes       -> Datatypes
  [D | Ds] Datatypes -> (remove-datatypes Ds (unassoc D Datatypes))
  _ _ -> (simple-error "implementation error in shen.remove-datatypes"))

(define unassoc
  _ []            -> []
  X [[X | _] | Y] -> Y
  X [Y | Z]       -> [Y | (unassoc X Z)]
  _ _             -> (simple-error "implementation error in shen.unassoc"))

(define show-datatypes
  Datatypes -> (map (/. X (hd X)) Datatypes))

(define include
  Types -> (let InternTypes (map (/. X (intern-type X)) Types)
                Remember    (map (/. D (remember-datatype D (fn D))) InternTypes)
                Datatypes   (value *datatypes*)
                (show-datatypes Datatypes)))

(define preclude-all-but
  Types -> (let Initialise (set *datatypes* [])
                InternTypes  (map (/. X (intern-type X)) Types)
                NewDatatypes (map (/. D (remember-datatype D (fn D))) InternTypes)
                (show-datatypes (value *datatypes*))))

(define include-all-but
  Types -> (let InternTypes  (map (/. X (intern-type X)) Types)
                AllDatatypes (value *alldatatypes*)
                Datatypes (set *datatypes* (remove-datatypes InternTypes AllDatatypes))
                (show-datatypes Datatypes))) )
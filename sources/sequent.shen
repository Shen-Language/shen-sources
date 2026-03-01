\\           Copyright (c) 2010-2019, Mark Tarver

\\                  All rights reserved.

(package shen [ctxt]

(defcc <datatype>
  D <datatype-rules> := (let Prolog (rules->prolog D <datatype-rules>)
                             (remember-datatype D (fn D)));)

(define remember-datatype
  D Fn -> (do (set *datatypes* (assoc-> D Fn (value *datatypes*)))
              (set *alldatatypes* (assoc-> D Fn (value *alldatatypes*)))
              D))

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
  ctxt X  := [ctxt X] where (variable? X);)

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

(define rules->prolog
  D Rules -> (let Clauses (mapcan (/. Rule (rule->clause Rule)) Rules)
                  Prolog  [defprolog D | Clauses]
                  (eval Prolog)))

(define rule->clause
  [S Ps [As Q]] -> (let Active (extract-vars Q)
                     (append (rule->head Q) [<--] (rule->body Active (protect Assumptions) S Ps As))))

(define rule->head
  X       -> [(macro-@ch X) (protect Assumptions)])

(define macro-@ch
  X -> [@ch X])

(define macro-@c
  X -> [@c X])

(define rule->body
  Active Assumptions S Ps []       -> (side-conditions->goals [] Active Assumptions S Ps)
  Active Assumptions S [] [A]      -> (let Passive (passive-variables A Active)
                                           NoBystanders (remove-bystanders Active A)
                                           [(specialise-member A Assumptions NoBystanders Passive)
                                            | (side-conditions->goals [] Active Assumptions S [])])
  Active Assumptions S Ps [A | As] -> (let Out     (gensym (protect NewAssumptions))
                                           Passive (passive-variables A Active)
                                           NoBystanders (remove-bystanders Active A)
                                           [(specialise-consume A Assumptions NoBystanders Passive Out)
                                             | (rule->body (append Active Passive) Out S Ps As)]))

(define specialise-member
   A Assumptions NoBystanders Passive -> (let F            (gensym member)
                                              Clause       (member-clause F A NoBystanders Passive)
                                              [F Assumptions | (append NoBystanders Passive)]))

(define remove-bystanders
  [] _ -> []
  [V | Vs] A -> [V | (remove-bystanders Vs A)] where (occurs-check? V A)
  [V | Vs] A -> (remove-bystanders Vs A))

(define member-clause
 F A Active Passive -> (let NVars  (nvars (length Passive))
                            Base   (append [[- [cons (macro-@ch A) _]]] Active NVars [<--] (passive-bind Passive NVars) [(intern ";")])
                            Ind    (let Hyps (gensym (protect Hypotheses))
                                        Vars (append Active Passive)
                                        Head (append [[- [cons _ Hyps]]] Vars)
                                        Body [[F Hyps | Vars]]
                                        (append Head [<--] Body [(intern ";")]))
                            Prolog [defprolog F | (append Base Ind)]
                            (eval Prolog)))

(define nvars
   0 -> []
   N -> [(gensym (protect NewV)) | (nvars (- N 1))])

(define passive-bind
  [] [] -> []
  [Pass | Passive] [NVar | NVars] -> [[bind NVar Pass] | (passive-bind Passive NVars)])

(define specialise-consume
   A Assumptions NoBystanders Passive Out
   -> (let F      (gensym consume)
           Clause (consume-clause F A NoBystanders Passive Out)
           [F Assumptions Out | (append NoBystanders Passive)]))

(define consume-clause
 F A Active Passive Out -> (let NVars  (nvars (length Passive))
                                V      (gensym (protect Assumption))
                                Base   [[- [cons (macro-@ch A) V]] Out
                                          | (append Active NVars  [<--]
                                                    (passive-bind Passive NVars)
                                                    [[bind Out V] (intern ";")])]
                                Ind    (let Hyps (gensym (protect Hypotheses))
                                            Vars (append Active Passive)
                                            BV   (gensym (protect Assumptions))
                                            Head [[- [cons V Hyps]] [cons BV Out] | Vars]
                                            Body [[bind BV V] [F Hyps Out | Vars]]
                                            (append Head [<--] Body [(intern ";")]))
                                Prolog [defprolog F | (append Base Ind)]
                                (eval Prolog)))

(define passive-variables
  A Active -> (difference (extract-vars A) Active))

(define side-conditions->goals
  CtxtVs _ Assumptions [] Ps                      -> (premises->goals CtxtVs Assumptions Ps)
  CtxtVs Active Assumptions [[if Boolean] | S] Ps -> [[when Boolean] | (side-conditions->goals CtxtVs Active Assumptions S Ps)]
  CtxtVs Active Assumptions [[let X Y] | S]    Ps -> (if (element? X Active)
                                                         [[is! X Y] | (side-conditions->goals CtxtVs Active Assumptions S Ps)]
                                                         [[bind X Y] | (side-conditions->goals CtxtVs [X | Active] Assumptions S Ps)])
  CtxtVs Active Assumptions [[ctxt Ctxt] | S]  Ps -> (if (element? Ctxt Active)
                                                         (side-conditions->goals [Ctxt | CtxtVs] Active Assumptions S Ps)
                                                         [[bind Ctxt Assumptions]
                                                           | (side-conditions->goals [Ctxt | CtxtVs] [Ctxt | Active] Ctxt S Ps)]))

(define premises->goals
  _ _ [] -> [(intern ";")]
  CtxtVs Assumptions [! | Ps]        -> [! | (premises->goals CtxtVs Assumptions Ps)]
  CtxtVs Assumptions [fail | Ps]     -> [[when false] | (premises->goals CtxtVs Assumptions Ps)]
  CtxtVs Assumptions [[As C] | Ps]   -> [[system-S (macro-@c C) (construct-context CtxtVs As Assumptions)]
                                             | (premises->goals CtxtVs Assumptions Ps)])

(define construct-context
  _ [] Assumptions            -> Assumptions
  CtxtVs [Ctxt] _             -> Ctxt where (element? Ctxt CtxtVs)
  CtxtVs [A | As] Assumptions -> [cons (macro-@c A) (construct-context CtxtVs As Assumptions)])

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
                (show-datatypes Datatypes)))

)

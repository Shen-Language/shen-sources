\\           Copyright (c) 2010-2019, Mark Tarver
\\                 All rights reserved.


(package shen []

(define compile-prolog
  F Clauses -> (compile (/. X (<defprolog> X)) [F | Clauses]))

(defcc <defprolog>
  F <clauses> := (let Aritycheck (prolog-arity-check F <clauses>)
                      LeftLinear (map (/. X (linearise-clause X)) <clauses>)
                      (horn-clause-procedure F LeftLinear));)

(defcc <clauses>
  <clause> <clauses> := [<clause> | <clauses>];
  <!> := (if (empty? <!>) [] (error "Prolog syntax error here:~% ~R~% ..." <!>));)

(define prolog-arity-check
  _ [_] -> skip
  F [[H B] | Clauses] -> (pac-h F (length H) Clauses))

(define linearise-clause
  [H B] -> (lch (linearise (@p H B))))

(define lch
  (@p H B) -> [H (lchh B)])

(define lchh
  [where [= X Y] B] -> [[(if (value *occurs*) is! is) X Y] | (lchh B)]
  B -> B)

(define pac-h
  _ _ [] -> true
  F N [[H | _] | Clauses] -> (if (= N (length H))
                                  (pac-h F N Clauses)
                                  (error "arity error in prolog procedure ~A~%" F)))

(defcc <clause>
  <head> <-- <body> <sc> := [<head> <body>];)

(defcc <head>
  <hterm> <head> := [<hterm> | <head>];
  <e> := [];)

(defcc <hterm>
  X := X  where (and (atom? X) (not (prolog-keyword? X)));
  X := X  where (= X (intern ":"));
  [cons <hterm1> <hterm2>] := [cons <hterm1> <hterm2>];
  [+ <hterm>] := [+m <hterm>];
  [- <hterm>] := [-m <hterm>];
  [mode <hterm> +] := [+m <hterm>];
  [mode <hterm> -] := [-m <hterm>];)

(define prolog-keyword?
  X -> (element? X [(intern ";") <--]))

(define atom?
  X -> (or (symbol? X) (string? X) (boolean? X) (number? X) (empty? X)))

(defcc <hterm1>
  <hterm>;)

(defcc <hterm2>
  <hterm>;)

(defcc <body>
  <literal> <body> := [<literal> | <body>];
  <e> := [];)

(defcc <literal>
  ! := !;
  [<bterms>] := <bterms>;)

(defcc <bterms>
  <bterm> <bterms> := [<bterm> | <bterms>];
  <e> := [];)

(defcc <bterm>
  <wildcard> := <wildcard>;
  X := X   where (atom? X);
  [<bterms>] := <bterms>;)

(defcc <wildcard>
  X := (gensym (protect Y))  where (= X _);)

(defcc <sc>
  X := X  where (semicolon? X);)

(define semicolon?
  X -> (= X (intern ";")))

(define horn-clause-procedure
   F Clauses -> (let Bindings (gensym (protect B))
                     Lock (gensym (protect L))
                     Key (gensym (protect K))
                     Continuation (gensym (protect C))
                     Parameters (prolog-parameters Clauses)
                     HasCut? (hascut? Clauses)
                     FBody (prolog-fbody Clauses Parameters Bindings Lock Key Continuation HasCut?)
                     CutFBody (if HasCut? [let Key [+ Key 1] FBody] FBody)
                     Shen [define F | (append Parameters [Bindings Lock Key Continuation ->] [CutFBody])]
                     Shen))

(define hascut?
  ! -> true
  [X | Y] -> (or (hascut? X) (hascut? Y))
  _ -> false)

(define prolog-parameters
  [[H | _] | _] -> (parameters (length H)))

(define prolog-fbody
   [] _ _ Lock Key _ true -> [unlock Lock Key]
   [[H B]] Parameters Bindings Lock Key Continuation false
        ->  (let Continue (continue H B Bindings Lock Key Continuation)
                 [if [unlocked? Lock]
                     (compile-head +m H Parameters Bindings Continue)
                     false])
   [[H B] | Clauses] Parameters Bindings Lock Key Continuation HasCut?
        -> (let Case (protect (gensym C))
                     Continue (continue H B Bindings Lock Key Continuation)
                     [let Case [if [unlocked? Lock]
                                   (compile-head +m H Parameters Bindings Continue)
                                   false]
                          [if [= Case false]
                              (prolog-fbody Clauses Parameters Bindings Lock Key Continuation HasCut?)
                              Case]])
   _ _ _ _ _ _ _ -> (simple-error "implementation error in shen.prolog-fbody"))

(define unlock
  Lock Key -> (if (and (locked? Lock) (fits? Key Lock))
                  (openlock Lock)
                  false))

(define locked?
  Lock -> (not (unlocked? Lock)))

(define unlocked?
  Lock -> (<-address Lock 1))

(define openlock
  Lock -> (do (address-> Lock 1 true) false))

(define fits?
  Key Lock -> (= Key (<-address Lock 2)))

(define cut
  _ Lock Key Continuation -> (let Compute (thaw Continuation)
                                 (if (and (= Compute false) (unlocked? Lock))
                                     (lock Key Lock)
                                     Compute)))

(define lock
  Key Lock -> (let SetLock (address-> Lock 1 false)
                   SetKey (address-> Lock 2 Key)
                   false))

(define continue
  H B Bindings Lock Key Continuation
  -> (let HVs (extract-vars H)
          BVs (extract-vars B)
          Free (difference BVs HVs)
          ContinuationCode [do [incinfs] (compile-body B Bindings Lock Key Continuation)]
          (stpart Free ContinuationCode Bindings)))

(define compile-body
  [] _ _ _ Continuation -> [thaw Continuation]
  [! | Literals] Bindings Lock Key Continuation -> (compile-body [[cut] | Literals] Bindings Lock Key Continuation)
  [P] Bindings Lock Key Continuation -> (append (deref-calls P Bindings) [Bindings Lock Key Continuation])
  [P | Literals] Bindings Lock Key Continuation -> (let P* (deref-calls P Bindings)
                                                        (append P* [Bindings
                                                                    Lock
                                                                    Key
                                                                    (freeze-literals Literals
                                                                                     Bindings
                                                                                     Lock
                                                                                     Key
                                                                                     Continuation)]))
  _ _ _ _ _ -> (simple-error "implementation error in shen.compile-fbody"))

(define freeze-literals
  [] _ _ _ Continuation -> Continuation
  [! | Literals] Bindings Lock Key Continuation -> (freeze-literals [[cut] | Literals] Bindings Lock Key Continuation)
  [P | Literals] Bindings Lock Key Continuation -> (let P* (deref-calls P Bindings)
                                                           [freeze (append P* [Bindings
                                                                    Lock
                                                                    Key
                                                                    (freeze-literals Literals Bindings Lock Key Continuation)])])
  _ _ _ _ _ -> (simple-error "implementation error in shen.freeze-literals"))

(define deref-calls
  [fork | X] Bindings -> [fork (deref-forked-literals X Bindings)]
  [F | X] Bindings -> [F | (map (/. Y (function-calls Y Bindings)) X)]
  _ _ -> (simple-error "implementation error in shen.deref-calls"))

(define deref-forked-literals
  [] _ -> []
  [Literal | Literals] Bindings -> [cons (deref-calls Literal Bindings)
                                         (deref-forked-literals Literals Bindings)]
  _ _ -> (error "fork requires a list of literals~%"))

(define function-calls
  [cons X Y] Bindings -> [cons (function-calls X Bindings) (function-calls Y Bindings)]
  [F | X] Bindings -> (deref-terms [F | X] Bindings)
  X _ -> X)

(define deref-terms
  [0 X] _ ->  (if (variable? X) X (error "attempt to optimise a non-variable ~S~%" X))
  [1 X] Bindings -> (if (variable? X) [lazyderef X Bindings] (error "attempt to optimise a non-variable ~S~%" X))
  X Bindings -> [deref X Bindings]           where (variable? X)
  [X | Y] Bindings -> (map (/. Z (deref-terms Z Bindings)) [X | Y])
  X _ -> X)

(define compile-head
   _ [] [] Bindings Continuation                 -> Continuation
   Mode [[+m Si] | S] T Bindings Continuation    -> (compile-head Mode [+m Si Mode | S] T Bindings Continuation)
   Mode [[-m Si] | S] T Bindings Continuation    -> (compile-head Mode [-m Si Mode | S] T Bindings Continuation)
   _ [-m | S] T Bindings Continuation            -> (compile-head -m S T Bindings Continuation)
   _ [+m | S] T Bindings Continuation            -> (compile-head +m S T Bindings Continuation)
   Mode [Si | S] [_ | T] Bindings Continuation   -> (compile-head Mode S T Bindings Continuation)         where (wildcard? Si)
   Mode [Si | S] T Bindings Continuation         -> (variable-case Mode [Si | S] T Bindings Continuation) where (variable? Si)
   -m [Si | S] T Bindings Continuation           -> (atom-case-minus [Si | S] T Bindings Continuation)    where (atom? Si)
   -m [[cons Sa Sb] | S] T Bindings Continuation -> (cons-case-minus [[cons Sa Sb] | S] T Bindings Continuation)
   +m [Si | S] T Bindings Continuation           -> (atom-case-plus [Si | S] T Bindings Continuation)     where (atom? Si)
   +m [[cons Sa Sb] | S] T Bindings Continuation -> (cons-case-plus [[cons Sa Sb] | S] T Bindings Continuation)
   _ _ _ _ _                           -> (simple-error "implementation error in shen.compile-head"))

(define variable-case
  Mode [Si | S] [Ti | T] Bindings Continuation -> (if (variable? Ti)
                                                      (compile-head Mode S T Bindings (subst Ti Si Continuation))
                                                      [let Si Ti (compile-head Mode S T Bindings Continuation)])
  _ _ _ _ _ -> (simple-error "implementation error in shen.variable-case"))

(define atom-case-minus
  [Si | S] [Ti | T] Bindings Continuation -> (let Tm (gensym (protect Tm))
                                                  [let Tm [lazyderef Ti Bindings]
                                                       [if [= Tm Si]
                                                           (compile-head -m S T Bindings Continuation)
                                                           false]])
  _ _ _ _ -> (simple-error "implementation error in shen.atom-case-minus"))

(define cons-case-minus
  [[cons Sa Sb] | S] [Ti | T] Bindings Continuation -> (let Tm (gensym (protect Tm))
                                                            [let Tm [lazyderef Ti Bindings]
                                                                 [if [cons? Tm]
                                                                     (compile-head -m
                                                                                  [Sa Sb | S]
                                                                                  [[hd Tm] [tl Tm] | T]
                                                                                  Bindings Continuation)
                                                         false]])
   _ _ _ _ -> (simple-error "implementation error in shen.cons-case-minus"))

(define atom-case-plus
  [Si | S] [Ti | T] Bindings Continuation -> (let Tm (gensym (protect Tm))
                                                  GoTo (gensym (protect GoTo))
                                                  [let Tm [lazyderef Ti Bindings]
                                                       GoTo [freeze (compile-head +m S T Bindings Continuation)]
                                                       [if [= Tm Si]
                                                           [thaw GoTo]
                                                           [if [pvar? Tm]
                                                               [bind! Tm (demode Si) Bindings GoTo]
                                                               false]]])
   _ _ _ _ -> (simple-error "implementation error in shen.atom-case-plus"))

(define cons-case-plus
  [[cons Sa Sb] | S] [Ti | T] Bindings Continuation
   -> (let Tm (gensym (protect Tm))
           GoTo (gensym (protect GoTo))
           Vars (extract-vars [Sa | Sb])
           Tame (tame [cons Sa Sb])
           TVars (extract-vars Tame)
           [let Tm [lazyderef Ti Bindings]
                GoTo (goto Vars (compile-head +m S T Bindings Continuation))
                [if [cons? Tm]
                    (compile-head +m [Sa Sb] [[hd Tm] [tl Tm]] Bindings (invoke GoTo Vars))
                    [if [pvar? Tm]
                        (stpart TVars [bind! Tm
                                           (demode Tame)
                                           Bindings
                                           [freeze (invoke GoTo Vars)]] Bindings)
                        false]]])
     _ _ _ _ -> (simple-error "implementation error in shen.cons-case-plus"))

(define demode
  [+m X] -> (demode X)
  [-m X] -> (demode X)
  [X | Y] -> (map (/. Z (demode Z)) [X | Y])
  X -> X)

(define tame
  X -> (gensym (protect Y))   where (wildcard? X)
  [X | Y] -> (map (/. Z (tame Z)) [X | Y])
  X -> X)

(define goto
  [] Procedure -> [freeze Procedure]
  Vars Procedure -> (goto-h Vars Procedure))

(define goto-h
  [] Procedure -> Procedure
  [X | Y] Procedure -> [lambda X (goto-h Y Procedure)])

(define invoke
  GoTo [] -> [thaw GoTo]
  GoTo Vars -> [GoTo | Vars])

(define wildcard?
  X -> (= X _))

(define pvar?
  X -> (trap-error (and (absvector? X) (= (<-address X 0) pvar)) (/. E false)))

(define lazyderef
  X Bindings -> (if (pvar? X)
                  (let Value (<-address Bindings (<-address X 1))
                       (if (= Value -null-)
                           X
                           (lazyderef Value Bindings)))
                  X))

(define deref
  [X | Y] Bindings -> [(deref X Bindings) | (deref Y Bindings)]
  X Bindings -> (if (pvar? X)
                  (let Value (<-address Bindings (<-address X 1))
                      (if (= Value -null-)
                         X
                         (deref Value Bindings)))
                  X))

(define bind!
  PVar Si Bindings Continuation -> (let Bind (bindv PVar Si Bindings)
                                      Compute (thaw Continuation)
                                      (if (= Compute false)
                                          (unwind PVar Bindings Compute)
                                           Compute)))
(define bindv
  PVar Si Bindings -> (address-> Bindings (<-address PVar 1) Si))

(define unwind
   PVar Bindings Compute -> (do (address-> Bindings (<-address PVar 1) -null-) Compute))

(define stpart
  [] Continuation _ -> Continuation
  [X | Y] Continuation Bindings -> [let X [newpv Bindings]
                                          [gc Bindings (stpart Y Continuation Bindings)]]
   _ _ _ -> (simple-error "implementation error in shen.stpart"))

(define gc
   Bindings Computation -> (if (= Computation false)
                             (let N (ticket-number Bindings)
                                  (do (decrement-ticket N Bindings)
                                      Computation))
                             Computation))

(define decrement-ticket
  N Bindings -> (address-> Bindings 1 (- N 1)))

(define newpv
   Bindings -> (let N (ticket-number Bindings)
                    NewBindings (make-prolog-variable N)
                    NextTicket (nextticket Bindings N)
                    NewBindings))

(define ticket-number
  Bindings -> (<-address Bindings 1))

(define nextticket
  Bindings N -> (let NewVector (address-> Bindings N -null-)
                  (address-> NewVector 1 (+ N 1))))

(define make-prolog-variable
  N -> (address-> (address-> (absvector 2) 0 pvar) 1 N))

(define pvar
  Bindings -> (make-string "Var~A" (<-address Bindings 1)))

(define incinfs
  -> (set *infs* (+ 1 (value *infs*))))

(define prolog-vector-size
  N -> (if (and (integer? N) (> N 0))
           (set *size-prolog-vector* N)
           (error "prolog vector size: size should be a positive integer; not ~A" N)))

(define lzy=!
   X X _ Continuation -> (thaw Continuation)
   X Y Bindings Continuation -> (bind! X Y Bindings Continuation)
                                 where (and (pvar? X) (not (occurs? X (deref Y Bindings))))
   X Y Bindings Continuation -> (bind! Y X Bindings Continuation)
                                 where (and (pvar? Y) (not (occurs? Y (deref X Bindings))))
   [X | Y] [W | Z] Bindings Continuation -> (lzy=! (lazyderef X Bindings)
                                                   (lazyderef W Bindings)
                                                   Bindings
                                                   (freeze (lzy=! (lazyderef Y Bindings)
                                                                  (lazyderef Z Bindings)
                                                                  Bindings
                                                                  Continuation)))
   _ _ _ _ -> false)

(define lzy=
   X X _ Continuation -> (thaw Continuation)
   X Y Bindings Continuation -> (bind! X Y Bindings Continuation) where (pvar? X)
   X Y Bindings Continuation -> (bind! Y X Bindings Continuation) where (pvar? Y)
   [X | Y] [W | Z] Bindings Continuation -> (lzy= (lazyderef X Bindings)
                                                  (lazyderef W Bindings)
                                                  Bindings
                                                  (freeze (lzy= (lazyderef Y Bindings)
                                                                (lazyderef Z Bindings)
                                                                Bindings
                                                                Continuation)))
   _ _ _ _ -> false)

(define occurs?
  X X -> true
  X [Y | Z] -> (or (occurs? X Y) (occurs? X Z))
  _ _ -> false)

(define call
  Call Bindings Lock Key Continuation -> (Call Bindings Lock Key Continuation))

(define return
  X Bindings _ _ _ -> (deref X Bindings))

(define when
  X _ _ _ Continuation -> (if X (thaw Continuation) false))

(define is
  X Y Bindings Lock Key Continuation
   -> (lzy= (lazyderef X Bindings)
            (lazyderef Y Bindings)
            Bindings
            Continuation))

(define is!
  X Y Bindings Lock Key Continuation
   -> (lzy=! (lazyderef X Bindings)
             (lazyderef Y Bindings)
             Bindings
             Continuation))

(define bind
  X Y Bindings _ _ Continuation -> (bind! X Y Bindings Continuation))

(define var?
  X Bindings Lock Key Continuation -> (if (pvar? (lazyderef X Bindings)) (thaw Continuation) false))

(define print-prolog-vector
  _ -> "|prolog vector|")

(define fork
  [] _ _ _ _ -> false
  [Call | Calls] Bindings Lock Key Continuation -> (let Case (Call Bindings Lock Key Continuation)
                                                        (if (= Case false)
                                                            (fork Calls Bindings Lock Key Continuation)
                                                            Case))
  _ _ _ _ _ -> (error "fork expects a list of literals~%"))

(defprolog findall
  In Literal Out <-- (is Store [])
                     (findall-h In Literal Out Store);)

(defprolog findall-h
  In Literal _ Store <-- (call Literal) (overbind In Store);
  _ _ Store Store <--;)

(define overbind
  In Store Bindings _ _ _ -> (do (bindv Store [(deref In Bindings) | (lazyderef Store Bindings)] Bindings)
                                 false))

(define occurs-check
  + -> (set *occurs* true)
  - -> (set *occurs* false)
  _ -> (error "occurs-check expects a + or a -.~%"))                                  )
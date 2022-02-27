\\           Copyright (c) 2010-2019, Mark Tarver

\\                  All rights reserved.

(package shen [&]

(define typecheck
  X A -> (let Vs (extract-vars A)
              A* (rectify-type A)
              Curried (curry X)
              (prolog? (insert-prolog-variables (receive Vs) (receive A*) Out)
                       (toplevel-forms (receive Curried) Out)
                       (return Out))))

(defprolog insert-prolog-variables
  (- []) Out Out <--;
  (- [V | Vs]) A* Out <-- (insert-prolog-variables Vs (subst X (0 V) (0 A*)) Out);)

(defprolog toplevel-forms
  (- [define F | X]) A  <-- !  (signal-def (value *spy*) F) (t* [define F | X] A);
  X A                   <-- (system-S [X (intern ":") A] []);)

(defprolog signal-def
  (- false) _ <--;
  (- true) F <-- (is ShowF (output "~%typechecking (fn ~A)~%" F));)

(define rectify-type
  A -> (demodulate (curry-type A)))

(define demodulate
  X -> (trap-error (let Demod (walk (/. Y (demod Y)) X)
                       (if (= Demod X)
                           X
                           (demodulate Demod))) (/. E X)))

(define curry-type
  [A --> B --> | C] -> (curry-type [A --> [B --> | C]])
  [In ==> Out] -> (curry-type [[In * (protect A)] --> [[vector boolean] --> [In * Out]]])
  [A * B * | C] -> (curry-type [A * [B * | C]])
  [X | Y] -> (map (/. Z (curry-type Z)) [X | Y])
  X -> X)

(define curry
  [define F | X] -> [define F | X]
  [type X A] -> [type (curry X) A]
  [input+ A S] -> [input+ A (curry S)]
  [F | X] -> [F | (map (/. Y (curry Y)) X)]   where (special? F)
  [F | X] -> [F | X]   where (extraspecial? F)
  [F X Y | Z] -> (curry [[F X] Y | Z])
  [F X] -> [(curry F) (curry X)]
  X -> X)

(define special?
  F -> (element? F (value *special*)))

(define extraspecial?
  F -> (element? F (value *extraspecial*)))

(defprolog system-S
  _ _                 <-- (when (maxinfexceeded?));
  (- [X Colon A]) Hyp <-- (when (= Colon (intern ":"))) (when (type-theory-enabled?)) ! (system-S-h X A Hyp);
  P Hyp               <-- (when (value *spy*)) (show P Hyp);
  P Hyp               <-- (search-user-datatypes P Hyp (value *datatypes*));)

(define show
  P Hyps Bindings _ _ _
   -> (do (line)
          (show-p (deref P Bindings))
          (nl 2)
          (show-assumptions (deref Hyps Bindings) 1)
          (pause-for-user)
          false))

(define line
  -> (let Infs (inferences)
       (output "____________________________________________________________ ~A inference~A ~%?- "
                Infs (if (= 1 Infs) "" "s"))))

(define show-p
  [X Colon A] -> (do (prterm X) (pr " : ") (output "~R" A))  where (= Colon (intern ":"))
  P -> (prterm P))

(define prterm
  [cons X Y] -> (do (pr "[") (prterm X) (prtl Y) (pr "]"))
  [F | X] -> (do (pr "(") (prterm F) (map (/. Y (do (pr " ") (prterm Y))) X) (pr ")"))
  X -> (print X))

(define prtl
  [] -> ""
  [cons X Y] -> (do (pr " ") (prterm X) (prtl Y))
  X -> (do (pr " | ") (prterm X)))

(define show-assumptions
  [] _ -> (output "~%> ")
  [X | Y] N -> (do (output "~A. " N) (show-p X) (nl) (show-assumptions Y (+ N 1)))
  _ _ -> (simple-error "implementation error in shen.show-assumptions"))

(define pause-for-user
   -> (let Byte (read-byte (stinput))
             (if (= Byte 94)
                 (error "input aborted~%")
                 (nl))))

(define type-theory-enabled?
  -> (value *shen-type-theory-enabled?*))

(define maxinfexceeded?
  -> (if (> (inferences) (value *maxinferences*))
         (simple-error "maximum inferences exceeded")
         false))

(defprolog system-S-h
  X A Hyp                         <-- (when (value *spy*)) (show [X (intern ":") A] Hyp);
  X A _                           <-- (when (not (cons? (1 X)))) (primitive X A);
  X A Hyp                         <-- (by-hypothesis X A Hyp);
  (- [F]) A Hyp                   <-- (lookupsig F [--> A]);
  (- [fn F]) A _                  <-- (lookupsig F A);
  (- [F X]) A Hyp                 <-- (when (not (cons? (1 F)))) (lookupsig F [B --> A]) (system-S-h X B Hyp);
  (- [F X]) A Hyp                 <-- (system-S-h F [B --> A] Hyp) (system-S-h X B Hyp);
  (- [cons X Y]) [list A] Hyp     <-- (system-S-h X A Hyp) (system-S-h Y [list A] Hyp);
  (- [@p X Y]) [A * B] Hyp        <-- (system-S-h X A Hyp) (system-S-h Y B Hyp);
  (- [@v X Y]) [vector A] Hyp     <-- (system-S-h X A Hyp) (system-S-h Y [vector A] Hyp);
  (- [@s X Y]) string Hyp         <-- (system-S-h X string Hyp) (system-S-h Y string Hyp);
  (- [lambda X Y]) [A --> B] Hyp  <-- (bind New (freshterm (1 X)))
                                         (bind Z (beta (1 X) New Y))
                                         (system-S-h Z B [[New (intern ":") A] | Hyp]);
  (- [let X Y Z]) A Hyp           <-- (system-S-h Y B Hyp)
                                      (bind New (freshterm (1 X)))
                                      (bind W (beta (1 X) (1 New) (1 Z)))
                                      (system-S-h W A [[New (intern ":") B] | Hyp]);
  (- [open File D]) [stream D] Hyp <-- (when (element? (1 D) [in out]))
                                       (system-S-h File string Hyp);
  (- [type X A]) B Hyp            <-- !  (is! (rectify-type A) B)
                                         (system-S-h X B Hyp);
  (- [input+ A Stream]) B Hyp     <--   (is! B (rectify-type A))
                                        (system-S-h Stream [stream in] Hyp);
  (- [set Var Val]) A Hyp         <--  (system-S-h Var symbol Hyp)
                                       (system-S-h [value Var] A Hyp)
                                         (system-S-h Val A Hyp);
  X A Hyp                         <-- (l-rules Hyp Normalised false) ! (system-S-h X A Normalised);
  X A Hyp                         <-- (search-user-datatypes [X (intern ":") A] Hyp (value *datatypes*));)

(defprolog primitive
  X number        <-- (when (number? (1 X)));
  X boolean       <-- (when (boolean? (1 X)));
  X string        <-- (when (string? (1 X)));
  X symbol        <-- (when (symbol? (1 X)));
  (- []) [list A] <--;)

(defprolog by-hypothesis
 X A (- [[Y Colon B] | _]) <-- (when (= Colon (intern ":"))) (when (= X Y)) (is! A B);
 X A (- [_ | Hyp])         <-- (by-hypothesis X A Hyp);)

(defprolog lookupsig
  X A <-- (sigf (assoc (0 X) (value *sigf*)) A);)

(define sigf
  [_ | Lambda] A Bindings Lock Key Continuation -> (Lambda A Bindings Lock Key Continuation)
  _ _ _ _ _ _ -> false)

(define freshterm
  X -> (let V (absvector 3)
            V0 (address-> V 0 print-freshterm)
            V1 (address-> V0 1 X)
            V2 (address-> V1 2 (set *gensym* (+ 1 (value *gensym*))))
            V2))

(define print-freshterm
  V -> (cn "&&" (str (<-address V 1))))

(defprolog search-user-datatypes
   P Hyp (- [[_ | Fn] | _]) <-- (call (Fn P Hyp));
   P Hyp (- [_ | Ds]) <-- (search-user-datatypes P Hyp Ds);)

(defprolog l-rules
  (- []) Normalised (- true) <-- ! (bind Normalised []);
  (- [[[cons X Y] Colon [list A]] | Hyp]) Normalised _
	<-- (when (= Colon (intern ":"))) ! (l-rules [[X Colon A] [Y Colon [list A]] | Hyp] Normalised true);
  (- [[[@p X Y] Colon [A * B]] | Hyp]) Normalised _
	<-- (when (= Colon (intern ":"))) ! (l-rules [[X Colon A] [Y Colon B] | Hyp] Normalised true);
  (- [[[@s X Y] Colon string] | Hyp]) Normalised _
	<-- (when (= Colon (intern ":"))) ! (l-rules [[X Colon string] [Y Colon string] | Hyp] Normalised true);
  (- [[[@v X Y] Colon [vector A]] | Hyp]) Normalised _
	<-- (when (= Colon (intern ":"))) ! (l-rules [[X Colon A] [Y Colon [vector A]] | Hyp] Normalised true);
  (- [P | Hyp]) [Q | Normalised] Flag?
	<-- (bind Q P) (l-rules Hyp Normalised Flag?);)

(defprolog t*
  (- [define F | X]) A <-- !  (bind SigxRules (sigxrules [(0 F) | (0 X)]))
                              (bind Sig (fst (1 SigxRules)))
                              (bind Rules (snd (1 SigxRules)))
                              (bind FreshSig (freshen-sig Sig))
                              (t*-rules F Rules FreshSig 1)
                              (is Sig A);)

(define sigxrules
  Def -> (compile (/. X (<sig*rules> X)) Def))

(defcc <sig*rules>
  F { <signature> } <rules*> := (let Rectified (rectify-type <signature>)
                                     (@p Rectified <rules*>));)

(define freshen-sig
  Sig -> (let Vs (extract-vars Sig)
              Assoc (map (/. V [V | (freshterm (concat & V))]) Vs)
              (freshen-type Assoc Sig)))

(define freshen-type
  [] X -> X
  [[V | Fresh] | Assoc] X -> (freshen-type Assoc (subst Fresh V X)))

(defcc <rules*>
  <rule*> <rules*> := [(linearise <rule*>) | <rules*>];
  <rule*> := [(linearise <rule*>)];)

(defcc <rule*>
  <patterns> -> Action where Guard := (@p <patterns> [where Guard Action]);
  <patterns> <- Action where Guard := (@p <patterns> (correct [where Guard Action]));
  <patterns> <- Action             := (@p <patterns> (correct Action));
  <patterns> -> Action             := (@p <patterns> Action);)

(define correct
  [where G [fail-if F R]] -> [where [and G [not [F R]]] R]
  [where G R] -> [where [and G [not [= R [fail]]]] R]
  [fail-if F R] -> [where [not [F R]] R]
  R -> [where [not [= R [fail]]] R])

(defprolog t*-rules
  _ (- []) _ _ <--;
  F (- [Rule | Rules]) A Counter <-- (bind Fresh (freshen-rule Rule))
                                     (t*-rule F Counter (fst (1 Fresh)) (snd (1 Fresh)) A)
                                     !
                                     (t*-rules F Rules A (+ (0 Counter) 1));)

(define freshen-rule
  (@p Patterns Action) -> (let Vs (extract-vars Patterns)
                               Assoc (map (/. V [V | (freshterm V)]) Vs)
                               (@p (freshen Assoc Patterns) (freshen Assoc Action))))

(define freshen
  [] X -> X
  [[V | Fresh] | Assoc] X -> (freshen Assoc (beta V Fresh X)))

(defprolog t*-rule
  _ _ Ps R A <-- (t*-rule-h Ps R A);
  F Counter _ _ _ <-- (bind Err (error "type error in rule ~A of ~A~%" (0 Counter) (0 F)));)

(defprolog t*-rule-h
  (- []) R (- [--> A]) <-- ! (t*-correct R A []);
  Ps R A 	             <-- (t*-integrity Ps A Hyps B) ! (t*-correct R B Hyps);)

(defprolog t*-correct
  (- [where G R]) A Hyps <-- !
                             (bind CurryG (curry (0 G)))
                             (system-S-h CurryG boolean Hyps)
                             !
                             (t*-correct R A [[CurryG (intern ":") verified] | Hyps]);
  R A Hyps               <-- (system-S-h (curry (0 R)) A Hyps);)

(defprolog t*-integrity
  (- []) B [] B                             <--;
  (- [P | Ps]) (- [A --> B]) [Hyp | Hyps] C <--  (bind Hyp [P (intern ":") A])
                                                 (p-hyps P PHyps)
                                                 !
                                                 (system-S-h P A PHyps)
                                                 !
                                                 (t*-integrity Ps B Hyps C);)

(defprolog p-hyps
  P PHyps  <-- (when (freshterm? P)) ! (bind PHyps [[P (intern ":") A]]);
  (- [X | Y]) PHyps  <-- ! (p-hyps X XHyps)
                           (p-hyps Y YHyps)
                           (join XHyps YHyps PHyps);
   _ PHyps <-- (bind PHyps []);)

(define freshterm?
  X -> (and (absvector? X) (not (string? X)) (= (<-address X 0) print-freshterm)))

(defprolog join
  (- []) X X* <-- (bind X* X);
  (- [X | Y]) W [X* | Z] <-- (bind X* X) (join Y W Z);))
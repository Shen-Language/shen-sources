\*

Copyright (c) 2010-2015, Mark Tarver

All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
1. Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.
3. The name of Mark Tarver may not be used to endorse or promote products
   derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY Mark Tarver ''AS IS'' AND ANY
EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL Mark Tarver BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

*\

(package shen [&& &&&]

(define typecheck
  X A -> (let Curry (curry X)
              ProcessN (start-new-prolog-process)
              Type (insert-prolog-variables (demodulate (curry-type A)) ProcessN)
              Continuation (freeze (return Type ProcessN void))
           (t* [Curry : Type] [] ProcessN Continuation)))

(define curry
  [F | X] -> [F | (map (/. Y (curry Y)) X)]   where (special? F)
  [Def F | X] -> [Def F | X] where (extraspecial? Def)
  [type X A] -> [type (curry X) A]
  [F X Y | Z] -> (curry [[F X] Y | Z])
  [F X] -> [(curry F) (curry X)]
  X -> X)

(define special?
  F -> (element? F (value *special*)))

(define extraspecial?
  F -> (element? F (value *extraspecial*)))

(defprolog t*
  _ _ <-- (fwhen (maxinfexceeded?)) (bind Error (errormaxinfs));
  (mode fail -) _ <-- ! (prolog-failure);
  (mode [X : A] -) Hyp <-- (fwhen (type-theory-enabled?)) ! (th* X A Hyp);
  P Hyp <-- (show P Hyp) (bind Datatypes (value *datatypes*)) (udefs* P Hyp Datatypes);)

(define type-theory-enabled?
  -> (value *shen-type-theory-enabled?*))

(define enable-type-theory
  + -> (set *shen-type-theory-enabled?* true)
  - -> (set *shen-type-theory-enabled?* false)
  _ -> (error "enable-type-theory expects a + or a -~%"))

(define prolog-failure
  _ _ -> false)

(define maxinfexceeded?
  -> (> (inferences) (value *maxinferences*)))

(define errormaxinfs
  -> (simple-error "maximum inferences exceeded~%"))

(defprolog udefs*
  P Hyp (mode [D | _] -) <-- (call [D P Hyp]);
  P Hyp (mode [_ | Ds] -) <-- (udefs* P Hyp Ds);)

(defprolog th*
  X A Hyps <-- (show [X : A] Hyps) (when false);
  X A _ <-- (fwhen (typedf? X)) (bind F (sigf X)) (call [F A]);
  X A _ <-- (base X A);
  X A Hyp <-- (by_hypothesis X A Hyp);
  (mode [F] -) A Hyp <-- (th* F [--> A] Hyp);
  (mode [F X] -) A Hyp <-- (th* F [B --> A] Hyp) (th* X B Hyp);
  (mode [cons X Y] -) [list A] Hyp <-- (th* X A Hyp) (th* Y [list A] Hyp);
  (mode [@p X Y] -) [A * B] Hyp <-- (th* X A Hyp) (th* Y B Hyp);
  (mode [@v X Y] -) [vector A] Hyp <-- (th* X A Hyp) (th* Y [vector A] Hyp);
  (mode [@s X Y] -) string Hyp <-- (th* X string Hyp) (th* Y string Hyp);
  (mode [lambda X Y] -) [A --> B] Hyp <-- ! (bind X&& (placeholder))
                                            (bind Z (ebr X&& X Y))
                                            (th* Z B [[X&& : A] | Hyp]);
  (mode [let X Y Z] -) A Hyp <-- (th* Y B Hyp)
                                 (bind X&& (placeholder))
                                 (bind W (ebr X&& X Z))
                                 (th* W A [[X&& : B] | Hyp]);
  (mode [open FileName Direction] -) [stream Direction] Hyp
    <-- ! (fwhen (element? Direction [in out]))
          (th* FileName string Hyp);
  (mode [type X A] -) B Hyp <-- ! (unify A B) (th* X A Hyp);
  (mode [input+ A Stream] -) B Hyp <-- (bind C (demodulate A))
                                       (unify B C)
                                       (th* Stream [stream in] Hyp);
  (mode [set Var Val] -) A Hyp <-- ! (th* Var symbol Hyp)
                                   ! (th* [value Var] A Hyp)
                                     (th* Val A Hyp);
  X A Hyp <-- (t*-hyps Hyp NewHyp) (th* X A NewHyp);
  (mode [define F | X] -) A Hyp <-- ! (t*-def [define F | X] A Hyp);
  (mode [defmacro | _] -) unit Hyp <-- !;
  (mode [process-datatype | _] -) symbol _ <--;
  (mode [synonyms-help | _] -) symbol _ <--;
  X A Hyp <-- (bind Datatypes (value *datatypes*))
              (udefs* [X : A] Hyp Datatypes);)

(defprolog t*-hyps
  (mode [[[cons X Y] : (mode [list A] +)] | Hyp] -) Out
    <-- (bind Out [[X : A] [Y : [list A]] | Hyp]);
  (mode [[[@p X Y] : (mode [A * B] +)] | Hyp] -) Out
    <-- (bind Out [[X : A] [Y : B] | Hyp]);
  (mode [[[@v X Y] : (mode [vector A] +)] | Hyp] -) Out
    <-- (bind Out [[X : A] [Y : [vector A]] | Hyp]);
  (mode [[[@s X Y] : (mode string +)] | Hyp] -) Out
    <-- (bind Out [[X : string] [Y : string] | Hyp]);
  (mode [X | Hyp] -) Out
    <-- (bind Out [X | NewHyps]) (t*-hyps Hyp NewHyps);)

(define show
  P Hyps ProcessN Continuation
  -> (do (line)
         (show-p (deref P ProcessN))
         (nl)
         (nl)
         (show-assumptions (deref Hyps ProcessN) 1)
         (output "~%> ")
         (pause-for-user)
         (thaw Continuation))
      where (value *spy*)
  _ _ _ Continuation -> (thaw Continuation))

(define line
  -> (let Infs (inferences)
       (output "____________________________________________________________ ~A inference~A ~%?- "
               Infs (if (= 1 Infs) "" "s"))))

(define show-p
  [X : A] -> (output "~R : ~R" X A)
  P -> (output "~R" P))

\* Enumerate assumptions. *\
(define show-assumptions
  [] _ -> skip
  [X | Y] N -> (do (output "~A. " N)
                   (show-p X)
                   (nl)
                   (show-assumptions Y (+ N 1))))

\* Pauses for user *\
(define pause-for-user
  -> (let Byte (read-byte (stinput))
       (if (= Byte 94)
           (error "input aborted~%")
           (nl))))

\* Does the function have a type? *\
(define typedf?
  F -> (cons? (assoc F (value *signedfuncs*))))

\* The name of the Horn clause containing the signature of F. *\
(define sigf
  F -> (concat type-signature-of- F))

\* Generate a placeholder - a symbol which stands for an arbitrary object.  *\
(define placeholder
  -> (gensym &&))

(defprolog base
  X number <-- (fwhen (number? X));
  X boolean <-- (fwhen (boolean? X));
  X string <-- (fwhen (string? X));
  X symbol <-- (fwhen (symbol? X)) (fwhen (not (ue? X)));
  (mode [] -) [list A] <--;)

(defprolog by_hypothesis
  X A (mode [[Y : B] | _] -) <-- (identical X Y) (unify! A B);
  X A (mode [_ | Hyp] -) <-- (by_hypothesis X A Hyp);)

(defprolog t*-def
  (mode [define F | X] -) A Hyp
    <-- (t*-defh (compile (/. Y (<sig+rules> Y)) X) F A Hyp);)

(defprolog t*-defh
  (mode [Sig | Rules] -) F A Hyp <-- (t*-defhh Sig (ue-sig Sig) F A Hyp Rules);)

(defprolog t*-defhh
  Sig Sig&& F A Hyp Rules <-- (t*-rules Rules Sig&& 1 F [[F : Sig&&] | Hyp])
                              (memo F Sig A);)

(defprolog memo
  F A A <-- (bind Jnk (declare F A));)

(defcc <sig+rules>
  <signature> <non-ll-rules> := [<signature> | <non-ll-rules>];)

(defcc <non-ll-rules>
  <rule> <non-ll-rules> := [<rule> | <non-ll-rules>];
  <rule> := [<rule>];)

(define ue
  [P X] -> [P X]	where (= P protect)
  [X | Y] -> (map (/. Z (ue Z)) [X | Y])
  X -> (concat && X)        where (variable? X)
  X -> X)

(define ue-sig
  [X | Y] -> (map (/. Z (ue-sig Z)) [X | Y])
  X -> (concat &&& X)        where (variable? X)
  X -> X)

(define ues
  X -> [X]   where (ue? X)
  [X | Y] -> (union (ues X) (ues Y))
  _ -> [])

(define ue?
  X -> (and (symbol? X) (ue-h? (str X))))

(define ue-h?
  (@s "&&" _) -> true
  _ -> false)

(defprolog t*-rules
  (mode [] -) _ _ _ _ <--;
  (mode [Rule | Rules] -) A N F Hyp <-- (t*-rule (ue Rule) A Hyp)
                                        !
                                        (t*-rules Rules A (+ N 1) F Hyp);
  _ _ N F _ <-- (bind Err (error "type error in rule ~A of ~A" N F));)

(defprolog t*-rule
  (mode [Patterns Action] -) A Hyp
    <-- (newhyps (placeholders Patterns) Hyp NewHyps)
        (t*-patterns Patterns A NewHyps)
        !
        (t*-action
           (curry (ue Action))
           (result-type Patterns A) (patthyps Patterns A Hyp));)

(define placeholders
  X -> [X]    where (ue? X)
  [X | Y] -> (union (placeholders X) (placeholders Y))
  _ -> [])

(defprolog newhyps
  (mode [] -) Hyp Hyp <--;
  (mode [V | Vs] -) Hyp [[V : A] | NewHyp]  <-- (newhyps Vs Hyp NewHyp);)

(define patthyps
  [] _ Hyp -> Hyp
  [Pattern | Patterns] [A --> B] Hyp -> (adjoin [Pattern : A] (patthyps Patterns B Hyp)))

(define result-type
  [] [--> A] -> A
  [] A -> A
  [_ | Patterns] [A --> B] -> (result-type Patterns B))

(defprolog t*-patterns
  (mode [] -) _ _ <--;
  (mode [Pattern | Patterns] -) (mode [A --> B] -) Hyp <-- (t* [Pattern : A] Hyp)
  (t*-patterns Patterns B Hyp);)

(defprolog t*-action
  (mode [where P Action] -) A Hyp
    <-- ! (t* [P : boolean] Hyp) ! (t*-action Action A [[P : verified] | Hyp]);
  (mode [choicepoint! [[fail-if F] Action]] -) A Hyp
    <-- ! (t*-action [where [not [F Action]] Action] A Hyp);
  (mode [choicepoint! Action] -) A Hyp
    <-- ! (t*-action [where [not [[= Action] [fail]]] Action] A Hyp);
  Action A Hyp <-- (t* [Action : A] Hyp);)

(defprolog findall
  Pattern Literal X <-- (bind A (gensym a))
                        (bind B (set A []))
                        (findallhelp Pattern Literal X A);)

(defprolog findallhelp
  Pattern Literal X A <-- (call Literal) (remember A Pattern) (when false);
  _ _ X A <-- (bind X (value A));)

(defprolog remember
  A Pattern <-- (is B (set A [Pattern | (value A)]));)

)

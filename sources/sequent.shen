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
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.c#34;



*\

(package shen []

(define datatype-error 
  [D _] -> (error "datatype syntax error here:~%~% ~A~%" (next-50 50 D)))

(defcc <datatype-rules>
  <datatype-rule> <datatype-rules> := [<datatype-rule> | <datatype-rules>];
  <e> := [];)

(defcc <datatype-rule>
  <side-conditions> <premises> <singleunderline> <conclusion>
  := (sequent single [<side-conditions> <premises> <conclusion>]);
  <side-conditions> <premises> <doubleunderline> <conclusion>
  := (sequent double [<side-conditions> <premises> <conclusion>]);)

(defcc <side-conditions>
  <side-condition> <side-conditions> := [<side-condition> | <side-conditions>];
  <e> := [];)

(defcc <side-condition>
  if <expr> := [if <expr>];
  let <variable?> <expr> := [let <variable?> <expr>];)

(defcc <variable?>
  X := X	where (variable? X);)

(defcc <expr>
  X := (remove-bar X) where (not (or (element? X [>> ;]) 
                                     (singleunderline? X) 
                                     (doubleunderline? X)));)

(define remove-bar
  [X B Y] -> [X | Y] where (= B bar!)
  [X | Y] -> [(remove-bar X) | (remove-bar Y)]
  X -> X)

(defcc <premises>
  <premise> <semicolon-symbol> <premises> := [<premise> | <premises>];
  <e> := [];)

(defcc <semicolon-symbol>
  X := skip	where (= X ;);)

(defcc <premise>
  ! := !; 
  <formulae> >> <formula> := (sequent <formulae> <formula>);
  <formula> := (sequent [] <formula>);)

(defcc <conclusion>
  <formulae> >> <formula> <semicolon-symbol> := (sequent <formulae> <formula>);
  <formula> <semicolon-symbol> := (sequent [] <formula>);)

(define sequent
  Formulae Formula -> (@p Formulae Formula))

(defcc <formulae>
   <formula> <comma-symbol> <formulae> := [<formula> | <formulae>];
   <formula> := [<formula>];
   <e> := [];)

(defcc <comma-symbol>
  X := skip 	where (= X (intern ","));)

(defcc <formula>
   <expr> : <type> := [(curry <expr>) : (demodulate <type>)];
   <expr> := <expr>;)

(defcc <type>
   <expr> := (curry-type <expr>);)

(defcc <doubleunderline>
  X := X	where (doubleunderline? X);)

(defcc <singleunderline> 
  X := X	where (singleunderline? X);)

(define singleunderline?
  S -> (and (symbol? S) (sh? (str S))))

(define sh?
  "_" -> true
  S -> (and (= (pos S 0) "_") (sh? (tlstr S))))
            
(define doubleunderline?
  S -> (and (symbol? S) (dh? (str S))))

(define dh?
  "=" -> true
  S -> (and (= (pos S 0) "=") (dh? (tlstr S))))

(define process-datatype 
  D Rules -> (remember-datatype (s-prolog (rules->horn-clauses D Rules))))

(define remember-datatype 
  [D | _] -> (do (set *datatypes* (adjoin D (value *datatypes*)))
                 (set *alldatatypes* (adjoin D (value *alldatatypes*))) 
                 D))

(define rules->horn-clauses
   _ [] -> []
   D [(@p single Rule) | Rules] 
    -> [(rule->horn-clause D Rule) | (rules->horn-clauses D Rules)]
   D [(@p double Rule) | Rules] 
   -> (rules->horn-clauses D (append (double->singles Rule) Rules)))

(define double->singles
  Rule -> [(right-rule Rule) (left-rule Rule)])

(define right-rule
  Rule -> (@p single Rule))

(define left-rule
  [S P (@p [] C)] -> (let Q (gensym (protect Qv))
                          NewConclusion (@p [C] Q)
                          NewPremises [(@p (map (/. X (right->left X)) P) Q)]
                          (@p single [S NewPremises NewConclusion])))

(define right->left
  (@p [] C) -> C
  _ -> (error "syntax error with ==========~%")) 

(define rule->horn-clause
  D [S P (@p A C)] -> [(rule->horn-clause-head D C) :- (rule->horn-clause-body S P A)])

(define rule->horn-clause-head
  D C -> [D (mode-ify C) (protect Context_1957)])

(define mode-ify
  [X : A] -> [mode [X : [mode A +]] -]  
  X -> X)

(define rule->horn-clause-body
  S P A -> (let Variables (map (/. X (extract_vars X)) A)
                Predicates (map (/. X (gensym cl)) A)
                SearchLiterals (construct-search-literals 
                                       Predicates Variables (protect Context_1957) (protect Context1_1957))
                SearchClauses (construct-search-clauses Predicates A Variables)
                SideLiterals (construct-side-literals S)
                PremissLiterals (map (/. X (construct-premiss-literal X (empty? A))) P)
                (append SearchLiterals SideLiterals PremissLiterals)))

(define construct-search-literals
  [] [] _ _ -> []
  Predicates Variables Context Context1 
  -> (csl-help Predicates Variables Context Context1))
 
(define csl-help
  [] [] In _ -> [[bind (protect ContextOut_1957) In]]
  [P | Ps] [V | Vs] In Out -> [[P In Out | V] | (csl-help Ps Vs Out (gensym (protect Context)))])

(define construct-search-clauses
  [] [] [] -> skip
  [Pred | Preds] [A | As] [V | Vs] -> (do (construct-search-clause Pred A V)
                                          (construct-search-clauses Preds As Vs)))

(define construct-search-clause 
  Pred A V -> (s-prolog [(construct-base-search-clause Pred A V)
                         (construct-recursive-search-clause Pred A V)]))

(define construct-base-search-clause
  Pred A V -> [[Pred [(mode-ify A) | (protect In_1957)] (protect In_1957) | V] :- []])

(define construct-recursive-search-clause
  Pred A V -> [[Pred [(protect Assumption_1957) | (protect Assumptions_1957)] [(protect Assumption_1957) | (protect Out_1957)] | V] 
                 :- [[Pred (protect Assumptions_1957) (protect Out_1957) | V]]])

(define construct-side-literals
  [] -> []
  [[if P] | Sides] -> [[when P] | (construct-side-literals Sides)]
  [[let X Y] | Sides] -> [[is X Y] | (construct-side-literals Sides)]
  [_ | Sides] -> (construct-side-literals Sides))

(define construct-premiss-literal
  (@p A C) Flag -> [t* (recursive_cons_form C) (construct-context Flag A)]
  ! _ -> [cut (protect Throwcontrol)])

(define construct-context
  true [] -> (protect Context_1957)
  false [] -> (protect ContextOut_1957)
  Flag [X | Y] -> [cons (recursive_cons_form X) (construct-context Flag Y)])

(define recursive_cons_form
  [X | Y] -> [cons (recursive_cons_form X) (recursive_cons_form Y)]
  X -> X) 

(define preclude
  Types -> (preclude-h (map (/. X (intern-type X)) Types)))

(define preclude-h
   Types -> (let FilterDatatypes (set *datatypes* (difference (value *datatypes*) Types))
                 (value *datatypes*)))

(define include
  Types -> (include-h (map (/. X (intern-type X)) Types)))
             
(define include-h
   Types -> (let ValidTypes (intersection Types (value *alldatatypes*))
                 NewDatatypes (set *datatypes* (union ValidTypes (value *datatypes*)))
                 (value *datatypes*)))

(define preclude-all-but
  Types -> (preclude-h (difference (value *alldatatypes*) (map (/. X (intern-type X)) Types))))

(define include-all-but
  Types -> (include-h (difference (value *alldatatypes*) (map (/. X (intern-type X)) Types))))

(define synonyms-help
  [] -> (demodulation-function (value *tc*) 
                      (mapcan (/. X (demod-rule X)) (value *synonyms*)))
  [S1 S2 | S] -> (let Vs (difference (extract_vars S2) (extract_vars S1))
                      (if (empty? Vs)
                          (do (pushnew [S1 S2] *synonyms*)
                              (synonyms-help S))
                          (free_variable_warnings S2 Vs)))
  _ -> (error "odd number of synonyms~%"))

(define pushnew
   X Global -> (if (element? X (value Global))
                   (value Global)
                   (set Global [X | (value Global)])))
                   
(define demod-rule
  [S1 S2] -> [(rcons_form S1) -> (rcons_form S2)])                               

(define demodulation-function
  TC? Rules -> (do (tc -) 
                   (eval [define demod | (append Rules (default-rule))]) 
                   (if TC? (tc +) skip) 
                   synonyms))
                
(define default-rule
  -> (protect [X -> X]))
                  )           
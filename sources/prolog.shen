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

(defcc <defprolog>
  <predicate*> <clauses*> 
  := (hd (prolog->shen (map (/. X (insert-predicate <predicate*> X)) <clauses*>)));)

(define prolog-error
  F [X _] -> (error "prolog syntax error in ~A here:~%~% ~A~%" F (next-50 50 X))
  F _ -> (error "prolog syntax error in ~A~%" F))

(define next-50
  _ [] -> ""
  0 _ -> ""
  N [X | Y] -> (cn (decons-string X) (next-50 (- N 1) Y)))

(define decons-string
  [cons X Y] -> (make-string "~S " (eval-cons [cons X Y]))
  X -> (make-string "~R " X))
   
(define insert-predicate
  Predicate [Terms Body] -> [[Predicate | Terms] :- Body])   
  
(defcc <predicate*>
   X := X;)  
  
(defcc <clauses*> 
  <clause*> <clauses*> := [<clause*> | <clauses*>];
  <e> := [];)
  
(defcc <clause*>
  <head*> <-- <body*> <end*> := [<head*> <body*>];)
  
(defcc <head*>
  <term*> <head*> := [<term*> | <head*>];
  <e> := [];)
  
(defcc <term*>
  X := (eval-cons X)  where (and (not (= <-- X)) (legitimate-term? X));)

(define legitimate-term?
  [cons X Y] -> (and (legitimate-term? X) (legitimate-term? Y))
  [mode X +] -> (legitimate-term? X)
  [mode X -] -> (legitimate-term? X)
  [_ | _] -> false
  X -> true)
  
(define eval-cons
  [cons X Y] -> [(eval-cons X) | (eval-cons Y)]
  [mode X Mode] -> [mode (eval-cons X) Mode]
  X -> X)    
  
(defcc <body*>
  <literal*> <body*> := [<literal*> | <body*>];
  <e> := [];)
  
(defcc <literal*>
  ! := [cut (intern "Throwcontrol")];
  X := X	where (cons? X);)  
  
(defcc <end*>
  X := X	where (= X ;);)  

(define cut
  Throw ProcessN Continuation -> (let Result (thaw Continuation) 
                                      (if (= Result false)
                                          Throw
                                          Result)))  

(define insert_modes
   [mode X M] -> [mode X M]
   [] -> []
   [X | Y] -> [[mode X +] | [mode (insert_modes Y) -]]
   X -> X)

(define s-prolog
  Clauses -> (map (/. X (eval X)) (prolog->shen Clauses)))

(define prolog->shen
  Clauses -> (map (/. X (compile_prolog_procedure X)) 
                   (group_clauses 
                     (map (/. X (s-prolog_clause X)) 
                        (mapcan (/. X (head_abstraction X)) Clauses)))))

(define s-prolog_clause
  [H :- B] -> [H :- (map (/. X (s-prolog_literal X)) B)])

(define head_abstraction
  [H :- B] -> [[H :- B]]  where (< (complexity_head H) (value *maxcomplexity*))
  [[F | X] :- B] -> (let Terms (map (/. Y (gensym (protect V))) X)
                         XTerms (rcons_form (remove_modes X))
                         Literal [unify (cons_form Terms) XTerms]
                         Clause [[F | Terms] :- [Literal | B]]
                         [Clause]))

(define complexity_head
  [_ | Terms] -> (product (map (/. X (complexity X)) Terms)))

(define complexity
  [mode [mode X Mode] _] -> (complexity [mode X Mode])
  [mode [X | Y] +] -> (* 2 (complexity [mode X +]) (complexity [mode Y +]))
  [mode [X | Y] -] -> (* (complexity [mode X -]) (complexity [mode Y -]))
  [mode X _] -> 1	      where (variable? X)
  [mode _ +] -> 2
  [mode _ -] -> 1
  X -> (complexity [mode X +]))   

(define product
  [] -> 1
  [X | Y] -> (* X (product Y)))

(define s-prolog_literal
  [is X Y] -> [bind X (insert_deref Y)]
  [when X] -> [fwhen (insert_deref X)]
  [bind X Y] -> [bind X (insert_lazyderef Y)]
  [fwhen X] -> [fwhen (insert_lazyderef X)]
  [F | X] -> [F | X])
  
(define insert_deref
  V -> [deref V (protect ProcessN)]	 where (variable? V)
  [X | Y] -> [(insert_deref X) | (insert_deref Y)]
  X -> X)
  
(define insert_lazyderef
  V -> [lazyderef V (protect ProcessN)]	 where (variable? V)
  [X | Y] -> [(insert_lazyderef X) | (insert_lazyderef Y)]
  X -> X)      

(define group_clauses
  [] -> []
  [Clause | Clauses] -> (let Group (collect (/. X (same_predicate? Clause X)) 
                                            [Clause | Clauses])
                             Rest (difference [Clause | Clauses] Group)
                             [Group | (group_clauses Rest)]))

(define collect
   _ [] -> []
   F [X | Y] -> (if (F X) [X | (collect F Y)] (collect F Y)))

(define same_predicate?
  [[F | _] | _] [[G | _] | _] -> (= F G))

(define compile_prolog_procedure
  Clauses -> (let F (procedure_name Clauses)
                  Shen (clauses-to-shen F Clauses)
                  Shen))

(define procedure_name
  [[[F | _] | _] | _] -> F)
  
(define clauses-to-shen
  F Clauses -> (let Linear (map (/. X (linearise-clause X)) Clauses)
                    Arity (prolog-aritycheck F (map (/. X (head X)) Clauses))
                    Parameters (parameters Arity) 
                    AUM_instructions (map (/. X (aum X Parameters)) Linear)
                    Code (catch-cut (nest-disjunct (map (/. X (aum_to_shen X)) AUM_instructions)))
                    ShenDef [define F | (append Parameters [(protect ProcessN) (protect Continuation)] [-> Code])]
                    ShenDef))
                                        
(define catch-cut
  Code -> Code     where (not (occurs? cut Code))
  Code -> [let (protect Throwcontrol) [catchpoint]
              [cutpoint (protect Throwcontrol) Code]])
              
(define catchpoint 
  -> (set *catch* (+ 1 (value *catch*))))                   
              
(define cutpoint
  Catch Catch -> false
  _ X -> X)                                
            
(define nest-disjunct
  [Case] -> Case
  [Case | Cases] -> (lisp-or Case (nest-disjunct Cases)))  
  
(define lisp-or
  P Q -> [let (protect Case) P
              [if [= (protect Case) false]
                  Q
                  (protect Case)]])
  
(define prolog-aritycheck
  _ [H] -> (- (length H) 1)
  F [H1 H2 | Hs] -> (if (= (length H1) (length H2))
                        (prolog-aritycheck F [H2 | Hs])
                        (error "arity error in prolog procedure ~A~%" [F])))     

(define linearise-clause 
  [H :- Tl] -> (let Linear (linearise [H Tl])
                    (clause_form Linear)))

(define clause_form
   [H Tl] -> [(explicit_modes H) :- (cf_help Tl)])

(define explicit_modes
  [Pred | Terms] -> [Pred | (map (/. X (em_help X)) Terms)])

(define em_help
  [mode X M] -> [mode X M]
  X -> [mode X +])

(define cf_help
  [where [= X Y] Tl] -> [[(if (value *occurs*) unify! unify) X Y] | (cf_help Tl)]
  Tl -> Tl)

(define occurs-check
  + -> (set *occurs* true)
  - -> (set *occurs* false)
  _ -> (error "occurs-check expects + or -~%"))

(define aum
  [[F | Terms] :- Body] Fparams 
  -> (let MuApplication (make_mu_application [mu Terms (continuation_call Terms Body)] Fparams)
          (mu_reduction MuApplication +)))

(define continuation_call
  Terms Body -> (let VTerms [(protect ProcessN) | (extract_vars Terms)]
                     VBody (extract_vars Body)
                     Free (remove (protect Throwcontrol) (difference VBody VTerms))
                     (cc_help Free Body)))                
                 
(define remove
  X Y -> (remove-h X Y []))

(define remove-h
  _ [] X -> (reverse X)
  X [X | Y] Z -> (remove-h X Y Z)
  X [Y | Z] W -> (remove-h X Z [Y | W]))

(define cc_help
   [] [] -> [pop the stack]  
   Vs [] -> [rename the variables in Vs and then [pop the stack]]
   [] Body -> [call the continuation Body]
   Vs Body -> [rename the variables in Vs and then [call the continuation Body]])

(define make_mu_application 
   [mu [] Body] [] -> Body
   [mu [Term | Terms] Body] [FP | FPs] 
   -> [[mu Term (make_mu_application [mu Terms Body] FPs)] FP])

(define mu_reduction
   [[mu [mode X Mode] Body] FP] _ -> (mu_reduction [[mu X Body] FP] Mode)
   [[mu U Body] FP] Mode -> (mu_reduction Body Mode)		   	where (= _ U)
   [[mu V Body] FP] Mode 
    -> (subst FP V (mu_reduction Body Mode))     where (ephemeral_variable? V FP)
   [[mu V Body] FP] Mode -> [let V be FP in (mu_reduction Body Mode)] where (variable? V)
   [[mu C Body] FP] - -> (let Z (gensym (protect V)) 
                                [let Z be [the result of dereferencing FP]
                                   in [if [Z is identical to C] 
                                       then (mu_reduction Body -) 
                                       else  
			               failed!]])	where (prolog_constant? C)    
   [[mu C Body] FP] + -> (let Z (gensym (protect V)) 
                                [let Z be [the result of dereferencing FP]
                                   in [if [Z is identical to C] 
                                       then (mu_reduction Body +) 
                                       else  
									   [if [Z is a variable]
										then
                                        [bind Z to C in (mu_reduction Body +)]
                                        else 
                                        failed!]]])		where (prolog_constant? C)
   [[mu [X | Y] Body] FP] -
    -> (let Z (gensym (protect V))
		    [let Z be [the result of dereferencing FP]
     			   in [if [Z is a non-empty list]
                       then 
         	  (mu_reduction [[mu X [[mu Y Body] [the tail of Z]]] [the head of Z]] -)
                       else 
                       failed!]])
   [[mu [X | Y] Body] FP] +
    -> (let Z (gensym (protect V))
			[let Z be [the result of dereferencing FP]
     		       in [if [Z is a non-empty list]
                       then
      		(mu_reduction [[mu X [[mu Y Body] [the tail of Z]]] [the head of Z]] +)
                       else  
                       [if [Z is a variable]
					     then 
                         [rename the variables in (extract_vars [X | Y]) 
                          and then [bind Z to (rcons_form (remove_modes [X | Y])) 
						  in (mu_reduction Body +)]]
                          else 
                          failed!]]])
  X _ -> X)

(define rcons_form
  [X | Y] -> [cons (rcons_form X) (rcons_form Y)]
  X -> X)

(define remove_modes
   [mode X +] -> (remove_modes X)
   [mode X -] -> (remove_modes X)
   [X | Y] -> [(remove_modes X) | (remove_modes Y)]
   X -> X)

(define ephemeral_variable?
  V FP -> (and (variable? V) (variable? FP)))

(define prolog_constant?
  [_ | _] -> false
  _ -> true)

(define aum_to_shen
   [let Z* be AUM1 in AUM2]
    -> [let Z* (aum_to_shen AUM1) (aum_to_shen AUM2)]
   [the result of dereferencing Z] -> [lazyderef (aum_to_shen Z) (protect ProcessN)]
   [if AUM1 then AUM2 else AUM3]
    -> [if (aum_to_shen AUM1) (aum_to_shen AUM2) (aum_to_shen AUM3)]
   [Z is a variable] -> [pvar? Z]
   [Z is a non-empty list] -> [cons? Z]
   [rename the variables in [] and then AUM] -> (aum_to_shen AUM)
   [rename the variables in [X | Y] and then AUM] 
   -> [let X [newpv (protect ProcessN)] 
           (aum_to_shen [rename the variables in Y and then AUM])]
   [bind Z to X in AUM] -> [do [bindv Z (chwild X) (protect ProcessN)]
                               [let (protect Result) (aum_to_shen AUM)
                                    [do [unbindv Z (protect ProcessN)]
                                        (protect Result)]]]
   [Z is identical to X] -> [= X Z]   
   failed! -> false   
   [the head of X] -> [hd X]
   [the tail of X] -> [tl X]
   [pop the stack] -> [do [incinfs] [thaw (protect Continuation)]]
   [call the continuation Body] 
   -> [do [incinfs] (call_the_continuation (chwild Body) 
                                           (protect ProcessN)
                                           (protect Continuation))]
   X -> X)  
 
(define chwild
   X -> [newpv (protect ProcessN)]   where (= X _)
   [X | Y] -> (map (/. Z (chwild Z)) [X | Y])
   X -> X)     
   
(define newpv 
  N -> (let Count+1 (+ (<-address (value *varcounter*) N) 1)
            IncVar (address-> (value *varcounter*) N Count+1)
            Vector (<-address (value *prologvectors*) N)
            ResizeVectorIfNeeded (if (= Count+1 (limit Vector)) 
                                     (resizeprocessvector N Count+1)
                                     skip)
            (mk-pvar Count+1)))
            
(define resizeprocessvector
   N Limit -> (let Vector (<-address (value *prologvectors*) N)
                   BigVector (resize-vector Vector (+ Limit Limit) -null-)
                   (address-> (value *prologvectors*) N BigVector)))

(define resize-vector
  Vector Resize Fill -> (let BigVector (address-> (absvector (+ 1 Resize)) 0 Resize)
                             (copy-vector Vector BigVector (limit Vector) Resize Fill)))
                        
(define copy-vector
  Vector BigVector VectorLimit BigVectorLimit Fill
    -> (copy-vector-stage-2 (+ 1 VectorLimit) (+ BigVectorLimit 1) Fill 
        (copy-vector-stage-1 1 Vector BigVector (+ 1 VectorLimit))))
        
(define copy-vector-stage-1 
  Max _ BigVector Max -> BigVector
  Count Vector BigVector Max 
  -> (copy-vector-stage-1 (+ 1 Count)
                           Vector
                           (address-> BigVector Count (<-address Vector Count))
                           Max))
                           
(define copy-vector-stage-2 
  Max Max _ BigVector -> BigVector
  Count Max Fill BigVector 
   -> (copy-vector-stage-2 (+ Count 1) Max Fill (address-> BigVector Count Fill))) 
    
(define mk-pvar 
  N -> (address-> (address-> (absvector 2) 0 pvar) 1 N))  

(define pvar?
  X -> (trap-error (and (absvector? X) (= (<-address X 0) pvar)) (/. E false)))

(define bindv
  Var Val N -> (let Vector (<-address (value *prologvectors*) N)
                    (address-> Vector (<-address Var 1) Val)))
                    
(define unbindv 
  Var N -> (let Vector (<-address (value *prologvectors*) N)
                (address-> Vector (<-address Var 1) -null-)))
             
(define incinfs
  -> (set *infs* (+ 1 (value *infs*))))

(define call_the_continuation
  [[F | X]] ProcessN Continuation -> [F | (append X [ProcessN Continuation])]
  [[F | X] | Calls] ProcessN Continuation 
   -> (let NewContinuation (newcontinuation Calls ProcessN Continuation)
           [F | (append X [ProcessN NewContinuation])]))

(define newcontinuation
  [] ProcessN Continuation -> Continuation
  [[F | X] | Calls] ProcessN Continuation 
  -> [freeze [F | (append X [ProcessN (newcontinuation Calls ProcessN Continuation)])]]) 
  
(define return
  X ProcessN _ -> (deref X ProcessN)) 
  
(define measure&return
  X ProcessN _ -> (do (output "~A inferences~%" (value *infs*)) (deref X ProcessN)))   
 
(define unify 
  X Y ProcessN Continuation 
  -> (lzy= (lazyderef X ProcessN) (lazyderef Y ProcessN) ProcessN Continuation))

(define lzy= 
   X X ProcessN Continuation -> (thaw Continuation)
   X Y ProcessN Continuation -> (bind X Y ProcessN Continuation)    where (pvar? X)
   X Y ProcessN Continuation -> (bind Y X ProcessN Continuation)    where (pvar? Y)
   [X | Y] [W | Z] ProcessN Continuation -> (lzy= (lazyderef X ProcessN) 
                                                   (lazyderef W ProcessN) 
                                                    ProcessN
                                                    (freeze (lzy= (lazyderef Y ProcessN)
                                                                   (lazyderef Z ProcessN)
                                                                   ProcessN Continuation)))
   _ _ _ _ -> false)

(define deref 
  [X | Y] ProcessN -> [(deref X ProcessN) | (deref Y ProcessN)]
  X ProcessN -> (if (pvar? X) 
                   (let Value (valvector X ProcessN)
                      (if (= Value -null-)
                         X
                         (deref Value ProcessN)))
                      X))
           
(define lazyderef 
  X ProcessN -> (if (pvar? X) 
                  (let Value (valvector X ProcessN)
                     (if (= Value -null-)
                         X
                         (lazyderef Value ProcessN)))
                  X))

(define valvector
  Var ProcessN -> (<-address (<-address (value *prologvectors*) ProcessN) (<-address Var 1))) 

(define unify! 
   X Y ProcessN Continuation 
   -> (lzy=! (lazyderef X ProcessN) (lazyderef Y ProcessN) ProcessN Continuation))

(define lzy=!   
   X X ProcessN Continuation -> (thaw Continuation)
   X Y ProcessN Continuation -> (bind X Y ProcessN Continuation) 
                                 where (and (pvar? X) (not (occurs? X (deref Y ProcessN))))
   X Y ProcessN Continuation -> (bind Y X ProcessN Continuation)    
                                 where (and (pvar? Y) (not (occurs? Y (deref X ProcessN))))
   [X | Y] [W | Z] ProcessN Continuation -> (lzy=! (lazyderef X ProcessN) 
                                                    (lazyderef W ProcessN) 
                                                    ProcessN
                                                    (freeze (lzy=! (lazyderef Y ProcessN)
                                                                    (lazyderef Z ProcessN)
                                                                    ProcessN Continuation)))
   _ _ _ _ -> false)

(define occurs?
  X X -> true
  X [Y | Z] -> (or (occurs? X Y) (occurs? X Z))
  _ _ -> false)

(define identical 
  X Y P Continuation -> (lzy== (lazyderef X P) (lazyderef Y P) P Continuation))

(define lzy== 
  X X ProcessN Continuation -> (thaw Continuation)
  [X | Y] [W | Z] ProcessN Continuation 
    -> (lzy== (lazyderef X ProcessN) 
              (lazyderef W ProcessN) 
              ProcessN
              (freeze (lzy== Y Z ProcessN Continuation)))
  _ _ _ _ -> false)

(define pvar 
  X -> (make-string "Var~A" (<-address X 1)))

(define bind 
  X Y ProcessN Continuation -> (do (bindv X Y ProcessN) 
                                   (let Result (thaw Continuation)
                                       (do (unbindv X ProcessN)
                                           Result))))
                                           
(define fwhen 
   true _ Continuation -> (thaw Continuation)
   false _ _ -> false
   X _ _ -> (error "fwhen expects a boolean: not ~S%" X))

(define call 
  [F | X] ProcessN Continuation 
   -> (call-help (function (lazyderef F ProcessN)) X ProcessN Continuation)
   _ _ _ -> false)
  
(define call-help
  F [] ProcessN Continuation -> (F ProcessN Continuation)  
  F [X | Y] ProcessN Continuation -> (call-help (F X) Y ProcessN Continuation))   

(define intprolog
  [[F | X] | Y] -> (let ProcessN (start-new-prolog-process)
                        (intprolog-help F (insert-prolog-variables [X Y] ProcessN) ProcessN)))

(define intprolog-help
  F [X Y] ProcessN -> (intprolog-help-help F X Y ProcessN))

(define intprolog-help-help
  F [] Rest ProcessN -> (F ProcessN (freeze (call-rest Rest ProcessN)))
  F [X | Y] Rest ProcessN -> (intprolog-help-help (F X) Y Rest ProcessN)) 

(define call-rest
  [] _ -> true
  [[F X | Y] | Z] ProcessN -> (call-rest [[(F X) | Y] | Z] ProcessN)
  [[F] | Z] ProcessN -> (F ProcessN (freeze (call-rest Z ProcessN))))

(define start-new-prolog-process
  -> (let IncrementProcessCounter (set *process-counter* (+ 1 (value *process-counter*))) 
          (initialise-prolog IncrementProcessCounter)))

(define insert-prolog-variables
  X ProcessN -> (insert-prolog-variables-help X (flatten X) ProcessN)) 

(define insert-prolog-variables-help 
  X [] ProcessN -> X
  X [Y | Z] ProcessN -> (let V (newpv ProcessN)
                             XV/Y (subst V Y X)
                             Z-Y (remove Y Z) 
                             (insert-prolog-variables-help XV/Y Z-Y ProcessN))   where (variable? Y)
  X [_ | Z] ProcessN -> (insert-prolog-variables-help X Z ProcessN))                     
               
(define initialise-prolog
  N -> (let Vector (address-> (value *prologvectors*) 
                               N
                               (fillvector (vector 10) 1 10 -null-))
            Counter (address-> (value *varcounter*) N 1)
            N))
)
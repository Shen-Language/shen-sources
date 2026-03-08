\* 

Copyright (c) 2010-2021, Mark Tarver

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
 
(package logiclab [sequent prop d-rule pprint step]

(declare intro [[list [[list prop] * prop]] --> step]) 

(define intro
  S -> S)    

(defmacro d-rule-macro
 [d-rule Der Parameters | D-Rule] 
  -> (let SPC (parse-d-rule D-Rule)
          (compile-spc Der (concat Der $) Parameters SPC)))

(define parse-d-rule 
  D-Rule -> (compile (fn <sequent>) D-Rule))

(defcc <sequent>
  shen.<sides> shen.<prems> shen.<sng> shen.<conc> shen.<sc> 
   := [shen.<sides> shen.<prems> shen.<conc>];)
                                          
(define compile-spc
   Der Der$ Parameters  [S P [H C]] 
  -> (let Next        (gensym f) 
          Arguments   (shen.extract-vars Parameters)
          Types       (types-in Parameters)
          Constraints [cons C []]
          Program     (append (compile-der Der Der$ Arguments Types)
                              (compile-C Der$ Constraints C Next Arguments Types)
                              (compile-H Constraints S P H Next Arguments Types))
          [package null [] | (reverse Program)]))
          
(define compile-der
  Der Der$ Arguments Types -> (let Signature (derivation-type (append Types [step]) step)
                                   Input     (append Arguments [(protect Sequents) ->])
                                   CallDer$  (append [Der$] Arguments [false (protect Sequents)]) 
                                   Output    [[let (protect Solutions) CallDer$
                                                   [if [empty? (protect Solutions)]
                                                       (protect Sequents)
                                                       [head (protect Solutions)]]]]
                                   Def (append [define Der] 
                                               Signature
                                               Input
                                               Output)
                                   [Def]))
                     
(define types-in
  [] -> []
  [X : A | Parameters] -> [A | (types-in Parameters)]  where (variable? X)
  [X | _] -> (error "~A is not a variable~%" X))                     

(define compile-C
  Der Constraints C Next Arguments Types
 -> (let Record       (set *d-rules* (adjoin Der (trap-error (value *d-rules*) (/. E []))))
         SignatureA 	(derivation-type (append Types [boolean step]) [list step])
         SignatureB   (derivation-type (append Types [boolean [list sequent]]) [list step])
         Preamble	    (append Arguments [(protect Flag)])
         Main0        [(protect Sequents)]
         Main1        [[cons [@p (protect Hypotheses) C] (protect Sequents)]]
         Input0       (append Preamble Main0)
         Input1       (append Preamble Main1)
         F            (gensym f)
         Output0      [F | Input0]
         Output1  	  [let (protect Collect) [type [@v [] [vector 0]] [vector [list step]]]
                           (protect Search)  [Next (protect Flag) 
                                                 (protect Hypotheses)
                                                 Constraints  
                                                 []
                                                 (protect Sequents)
                                                 (protect Collect) 
                                                | Arguments]
                         [<-vector (protect Collect) 1]]
         Rule0         (append Input0 [->] [Output0])                
         Rule1         (append Input1 [->] [Output1])
         Input2        (map (/. X _) Input1)
         Output2       []
         Rule2         (append Input2 [->] [Output2])
         Def1          [define Der | (append SignatureA Rule0)] 
         Def2          [define F | (append SignatureB Rule1 Rule2)]
         [Def1 Def2]))

(define derivation-type
   Types Result -> (append [{] (derivation-type-h Types Result) [}]))

(define derivation-type-h
    [] A -> A
    [A | As] B -> [A --> (derivation-type-h As B)])
 
(define compile-H
   Constraints Sides Premises [] F Arguments Types 
    -> (let Signature (derivation-type [boolean [list prop] [list prop] [list prop] 
                                       [list sequent] [vector [list step]] | Types] symbol)
            Input   [(protect Flag) (protect Hypotheses) Constraints (protect Past) 
                            (protect Sequents) (protect Collect) | Arguments]                          
            Output  [(compile-sides Sides Premises)]
            Rule    (append Input [->] Output)
            Def (append [define F] Signature Rule)
            [Def])                            
   Constraints Sides Premises [H1 | Hs] F Arguments Types
   -> (let Next      (gensym f)
           Signature (derivation-type [boolean [list prop] [list prop] [list prop] 
                                       [list sequent] [vector [list step]] | Types] symbol)
           Input0    [false _ _ _ _ (protect Collect) | Arguments]
           Output0   [[fail]  where [not [empty? [<-vector (protect Collect) 1]]]] 
           Rule0     (append Input0 [->] Output0)                           
           Input1    [(protect Flag) [cons H1 (protect Hypotheses)] Constraints (protect Past) 
                              (protect Sequents) (protect Collect) | Arguments] 
           Output1   [[Next (protect Flag) [append [reverse (protect Past)] (protect Hypotheses)] 
                              [cons H1 Constraints] [] (protect Sequents) (protect Collect) | Arguments]]
           Rule1     (append Input1 [<-] Output1)
           Input2    [(protect Flag) [cons (protect H) (protect Hypotheses)] (protect C) (protect Past) 
                            (protect Sequents) (protect Collect) | Arguments]
           Output2   [[F (protect Flag) (protect Hypotheses) (protect C)
                         [cons (protect H) (protect Past)] (protect Sequents) (protect Collect) | Arguments]]
           Rule2     (append Input2 [<-] Output2)
           Input3    (map (/. X _) Input1)
           Output3   [[fail]]
           Rule3     (append Input3 [->] Output3)
           [[define F | (append Signature Rule0 Rule1 Rule2 Rule3)] 
             | (compile-H [cons H1 Constraints] Sides Premises Hs Next Arguments Types)]))
             
(define compile-sides
  [[let X Y] | Sides] Premises -> [let X Y (compile-sides Sides Premises)]
  [[if P] | Sides] Premises    -> [if P (compile-sides Sides Premises) [fail]]
  [] Premises                  -> (collect (protect Collect) (compile-premises Premises)))
                                                    
(define collect
  Collect Solution -> [do [vector-> Collect 1 [cons [intro Solution] [<-vector Collect 1]]] [fail]])
  
(define compile-premises
  [] -> (protect Sequents)
  [P | Ps] -> [cons (compile-premise P) (compile-premises Ps)])
  
(define compile-premise
  [Hyp C] -> [@p (process-hyps Hyp) C]) 
  
(define process-hyps
  [] -> (protect Hypotheses)
  [H | Hs] -> [cons H (process-hyps Hs)]))
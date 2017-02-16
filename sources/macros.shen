
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

(define macroexpand
  X -> (let Y (compose (value *macros*) X)
            (if (= X Y)
                X
                (walk (/. Z (macroexpand Z)) Y))))

(define error-macro
  [error String | Args] -> [simple-error (mkstr String Args)]
  X -> X)
  
(define output-macro
  [output String | Args] -> [prhush (mkstr String Args) [stoutput]]
  [pr String] -> [pr String [stoutput]]
  X -> X)  

(define make-string-macro
  [make-string String | Args] -> (mkstr String Args)
  X -> X)

(define input-macro
  [lineread] -> [lineread [stinput]]
  [input] -> [input [stinput]]
  [read] -> [read [stinput]]
  [input+ Type] -> [input+ Type [stinput]]
  [read-byte] -> [read-byte [stinput]]
  X -> X)
  
(define compose
   [] X -> X
   [F | Fs] X -> (compose Fs (F X)))
   
(define compile-macro
  [compile F X] -> [compile F X [lambda (protect E) [if [cons? (protect E)]
                                   [error "parse error here: ~S~%" (protect E)]
                                              [error "parse error~%"]]]]
  X -> X)

(define prolog-macro
  [prolog? | Literals] -> (let F (gensym f)
                               Receive (receive-terms Literals)
                               PrologDef (eval (append [defprolog F] Receive [<--] (pass-literals Literals) [;]))
                               Query [F | (append Receive [[start-new-prolog-process] [freeze true]])]
                               Query)
  X -> X)

(define receive-terms
  [] -> []
  [[receive X] | Terms] -> [X | (receive-terms Terms)]
  [_ | Terms] -> (receive-terms Terms))

(define pass-literals
  [] -> []
  [[receive _] | Literals] -> (pass-literals Literals)
  [Literal | Literals] -> [Literal | (pass-literals Literals)])

(define defprolog-macro
  [defprolog F | X] -> (compile (/. Y (<defprolog> Y)) [F | X] (/. Y (prolog-error F Y)))
  X -> X)

(define datatype-macro
  [datatype F | Rules] 
   -> (protect [process-datatype (intern-type F)
        [compile [lambda X [<datatype-rules> X]] 
                 (rcons_form Rules) [function datatype-error]]])
  X -> X)

(define intern-type
  F -> (intern (cn "type#" (str F))))

(define @s-macro
  [@s W X Y | Z] -> [@s W (@s-macro [@s X Y | Z])]
  [@s X Y] -> (let E (explode X)
                   (if (> (length E) 1)
                       (@s-macro [@s | (append E [Y])])
                       [@s X Y]))   where (string? X)
  X -> X)

(define synonyms-macro
  [synonyms | X] -> [synonyms-help (rcons_form (curry-synonyms X))]
  X -> X)

(define curry-synonyms
  Synonyms -> (map (/. X (curry-type X)) Synonyms))

(define nl-macro
  [nl] -> [nl 1]
  X -> X)

(define assoc-macro   
  [F W X Y | Z] -> [F W (assoc-macro [F X Y | Z])]
                        where (element? F [@p @v append and or + * do])
  X -> X) 
  
(define let-macro
   [let V W X Y | Z] -> [let V W (let-macro [let X Y | Z])]
   X -> X)  

(define abs-macro
   [/. V W X | Y] -> [lambda V (abs-macro [/. W X | Y])]   
   [/. X Y] -> [lambda X Y]
   X -> X)

(define cases-macro
  [cases true X | _] -> X
  [cases X Y] -> [if X Y [simple-error "error: cases exhausted"]]
  [cases X Y | Z] -> [if X Y (cases-macro [cases | Z])]
  [cases X] -> (error "error: odd number of case elements~%")
  X -> X)
  
(define timer-macro
   [time Process] -> (let-macro
                        [let (protect Start) [get-time run]
                             (protect Result) Process
                             (protect Finish) [get-time run]
                             (protect Time) [- (protect Finish) (protect Start)]
                             (protect Message) [prhush [cn "c#10;run time: " 
                                                       [cn [str (protect Time)] 
                                                           " secsc#10;"]]
                                                   [stoutput]] 
                             (protect Result)])
    X -> X)                           
  
(define tuple-up
  [X | Y] -> [@p X (tuple-up Y)]
  X -> X)   
      
(define put/get-macro
  [put X Pointer Y] -> [put X Pointer Y [value *property-vector*]] 
  [get X Pointer] -> [get X Pointer [value *property-vector*]]
  [unput X Pointer] -> [unput X Pointer [value *property-vector*]]
  X -> X)

(define function-macro
  [function F] -> (function-abstraction F (arity F))
  X -> X)
  
(define function-abstraction 
  F 0 -> (error "~A has no lambda form~%" F)
  F -1 -> [function F]
  F N -> (function-abstraction-help F N []))  

(define function-abstraction-help
  F 0 Vars -> [F | Vars]
  F N Vars -> (let X (gensym (protect V)) 
                [/. X (function-abstraction-help F (- N 1) (append Vars [X]))]))

(define undefmacro
  F -> (let MacroReg (value *macroreg*)
            Pos (findpos F MacroReg)
            Remove1 (set *macroreg* (remove F MacroReg))
            Remove2 (set *macros* (remove-nth Pos (value *macros*)))
            F))

(define findpos
  F [] -> (error "~A is not a macro~%" F)
  F [F | _] -> 1
  F [_ | Y] -> (+ 1 (findpos F Y)))

(define remove-nth
  1 [_ | Y] -> Y
  N [X | Y] -> [X | (remove-nth (- N 1) Y)])) 
  
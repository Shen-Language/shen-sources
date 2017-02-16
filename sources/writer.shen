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

(define pr
  String Sink -> (trap-error (prh String Sink 0) (/. E String)))

(define prh
  String Sink N -> (prh String Sink (write-char-and-inc String Sink N)))

(define write-char-and-inc
  String Sink N -> (do (write-byte (string->n (pos String N)) Sink) (+ N 1)))

(define print 
  X -> (let String (insert X "~S")
            Print (prhush String (stoutput))
            X)) 

(define prhush
  String Stream -> (if (value *hush*) String (pr String Stream)))

(define mkstr
  String Args -> (mkstr-l (proc-nl String) Args)   where (string? String)
  String Args -> (mkstr-r [proc-nl String] Args))

(define mkstr-l
  String [] -> String  
  String [Arg | Args] -> (mkstr-l (insert-l Arg String) Args))

(define insert-l
  _ "" -> ""
  Arg (@s "~A" S) -> [app Arg S a]
  Arg (@s "~R" S) -> [app Arg S r]
  Arg (@s "~S" S) -> [app Arg S s]
  Arg (@s S Ss) -> (factor-cn [cn S (insert-l Arg Ss)])
  Arg [cn S Ss] -> [cn S (insert-l Arg Ss)]
  Arg [app S Ss Mode] -> [app S (insert-l Arg Ss) Mode])

(define factor-cn
  [cn S1 [cn S2 S3]] -> [cn (cn S1 S2) S3]  where (and (string? S1) (string? S2))
  Cn -> Cn)
  
(define proc-nl
 "" -> ""
 (@s "~%" Ss) -> (cn (n->string 10) (proc-nl Ss))
 (@s S Ss) -> (cn S (proc-nl Ss)))

(define mkstr-r
  String [] -> String  
  String [Arg | Args] -> (mkstr-r [insert Arg String] Args))

(define insert
  Arg String -> (insert-h Arg String ""))

(define insert-h
  _ "" String -> String
  Arg (@s "~A" S) String -> (cn String (app Arg S a))
  Arg (@s "~R" S) String -> (cn String (app Arg S r))
  Arg (@s "~S" S) String -> (cn String (app Arg S s))
  Arg (@s S Ss) String -> (insert-h Arg Ss (cn String S)))
  
(define app
  Arg String Mode -> (cn (arg->str Arg Mode) String))
  
(define arg->str
  F _ -> "..."	   		  where (= F (fail))
  L Mode -> (list->str L Mode)    where (list? L)  		
  S Mode -> (str->str S Mode)  	  where (string? S)
  V Mode -> (vector->str V Mode)  where (absvector? V)
  At _ -> (atom->str At))
   
(define list->str
  L r -> (@s "(" (iter-list L r (maxseq)) ")")
  L Mode -> (@s "[" (iter-list L Mode (maxseq)) "]"))

(define maxseq
  -> (value *maximum-print-sequence-size*))
  
(define iter-list
  [] _ _ -> ""
  _ _ 0 -> "... etc"
  [X] Mode _ -> (arg->str X Mode)
  [X | Y] Mode N -> (@s (arg->str X Mode) " " (iter-list Y Mode (- N 1)))
  X Mode N -> (@s "| " (arg->str X Mode)))
  
(define str->str
  S a -> S
  S _ -> (@s (n->string 34) S (n->string 34)))
  
(define vector->str
  V Mode -> (cases (print-vector? V) ((function (<-address V 0)) V)
                   (vector? V) (@s "<" (iter-vector V 1 Mode (maxseq)) ">")
                   true (@s "<<" (iter-vector V 0 Mode (maxseq)) ">>")))
              
(define print-vector?
  P -> (let Zero (<-address P 0)
                 (cases (= Zero tuple) true
                        (= Zero pvar) true
                        (not (number? Zero)) (fbound? Zero)
                        true false))) 
                        
(define fbound?
  F -> (trap-error (do (ps F) true) (/. E false)))

(define tuple
  P -> (make-string "(@p ~S ~S)" (<-address P 1) (<-address P 2)))
              
(define iter-vector
  _ _ _ 0 -> "... etc"
  V N Mode Max -> (let Item (trap-error (<-address V N) (/. E out-of-bounds))
                       Next (trap-error (<-address V (+ N 1)) (/. E out-of-bounds))
                       (cases (= Item out-of-bounds) ""
                              (= Next out-of-bounds) (arg->str Item Mode)
                              true (@s (arg->str Item Mode)
                                       " "
                                       (iter-vector V (+ N 1) Mode (- Max 1))))))
  
(define atom->str
  At -> (trap-error (str At) (/. E (funexstring))))
  
(define funexstring
  -> (@s "c#16;fune" (arg->str (gensym (intern "x")) a) "c#17;"))

(define list?
  X -> (or (empty? X) (cons? X)))		)
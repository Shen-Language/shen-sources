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

(define load
   FileName -> (let Load (time (load-help (value *tc*) (read-file FileName)))
                    Infs (if (value *tc*)
                             (output "~%typechecked in ~A inferences~%" (inferences))
                             skip)
                    loaded))

(define load-help
  false File -> (map (/. X (output "~S~%" (eval-without-macros X))) File)
  _ File -> (let RemoveSynonyms (mapcan (/. X (remove-synonyms X)) File)
                 Table (mapcan (/. X (typetable X)) RemoveSynonyms)
                 Assume (map (/. X (assumetype X)) Table)
                 (trap-error (map (/. X (typecheck-and-load X)) RemoveSynonyms) 
                             (/. E (unwind-types E Table)))))
                             
                             
(define remove-synonyms
  [synonyms-help | S] -> (do (eval [synonyms-help | S]) [])
  Code -> [Code])

(define typecheck-and-load
  X -> (do (nl) (typecheck-and-evaluate X (gensym (protect A)))))
                 
(define typetable
  [define F | X] -> (let Sig (compile (/. Y (<sig+rest> Y)) X (/. E (error "~A lacks a proper signature.~%" F)))
                         [[F | Sig]])
   _ -> [])

(define assumetype
  [F | Type] -> (declare F Type))

(define unwind-types
  E [] -> (simple-error (error-to-string E))
  E [[F | _] | Table] -> (do (remtype F) (unwind-types E Table)))

(define remtype
  F -> (set *signedfuncs* (removetype F (value *signedfuncs*)))) 

(define removetype
  _ [] -> []
  F [[F | _] | Table] -> (removetype F Table)
  F [Entry | Table] -> [Entry | (removetype F Table)])      
                
(defcc <sig+rest>
  <signature> <!> := <signature>;) 
                   
(define write-to-file
   File Text -> (let Stream (open File out)
                     String (if (string? Text) 
                                (make-string "~A~%~%" Text) 
                                (make-string "~S~%~%" Text))
                     Write (pr String Stream) 
                     Close (close Stream)
                     Text)))


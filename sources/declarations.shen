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

(package shen []

(set *installing-kl* false)
(set *history* [])
(set *tc* false)
(set *property-vector* (vector 20000))
(set *process-counter* 0)
(set *varcounter* (vector 1000))
(set *prologvectors* (vector 1000))
(set *macroreg* [timer-macro cases-macro abs-macro put/get-macro
                 compile-macro datatype-macro let-macro assoc-macro
                 make-string-macro output-macro input-macro error-macro
                 prolog-macro synonyms-macro nl-macro
                 @s-macro defprolog-macro function-macro])
(set *macros*
     [(/. X (timer-macro X))
      (/. X (cases-macro X))
      (/. X (abs-macro X))
      (/. X (put/get-macro X))
      (/. X (compile-macro X))
      (/. X (datatype-macro X))
      (/. X (let-macro X))
      (/. X (assoc-macro X))
      (/. X (make-string-macro X))
      (/. X (output-macro X))
      (/. X (input-macro X))
      (/. X (error-macro X))
      (/. X (prolog-macro X))
      (/. X (synonyms-macro X))
      (/. X (nl-macro X))
      (/. X (@s-macro X))
      (/. X (defprolog-macro X))
      (/. X (function-macro X))])
(set *gensym* 0)
(set *tracking* [])
(set *alphabet* [A B C D E F G H I J K L M N O P Q R S T U V W X Y Z])
(set *special* [@p @s @v cons lambda let where set open])
(set *extraspecial* [define process-datatype input+ defcc read+ defmacro])
(set *spy* false)
(set *datatypes* [])
(set *alldatatypes* [])
(set *shen-type-theory-enabled?* true)
(set *synonyms* [])
(set *system* [])
(set *signedfuncs* [])
(set *maxcomplexity* 128)
(set *occurs* true)
(set *maxinferences* 1000000)
(set *maximum-print-sequence-size* 20)
(set *catch* 0)
(set *call* 0)
(set *infs* 0)
(set *hush* false)
(set *optimise* false)
(set *version* "Shen 19.3.1")
(if (not (bound? *home-directory*))
    (set *home-directory* "")
    skip)

(define initialise_arity_table
  [] -> []
  [F Arity | Table] -> (let DecArity (put F arity Arity)
                         (initialise_arity_table Table)))

(define arity
  F -> (trap-error (get F arity) (/. E -1)))

(initialise_arity_table
 [abort 0 absvector? 1 absvector 1 adjoin 2 and 2 append 2 arity 1
  assoc 2 boolean? 1 cd 1 compile 3 concat 2 cons 2 cons? 1
  cn 2 declare 2 destroy 1 difference 2 do 2 element? 2 empty? 1
  enable-type-theory 1 interror 2 eval 1
  eval-kl 1 explode 1 external 1 fail-if 2 fail 0 fix 2
  findall 5 freeze 1 fst 1 gensym 1 get 3
  get-time 1 address-> 3 <-address 2 <-vector 2 > 2 >= 2 = 2
  hd 1 hdv 1 hdstr 1 head 1 if 3 integer? 1
  intern 1 identical 4 inferences 0 input 1 input+ 2 implementation 0
  intersection 2 internal 1 it 0 kill 0 language 0
  length 1 lineread 1 load 1 < 2 <= 2 vector 1 macroexpand 1 map 2
  mapcan 2 maxinferences 1 not 1 nth 2
  n->string 1 number? 1 occurs-check 1 occurrences 2 occurs-check 1
  optimise 1 or 2 os 0 package 3 package? 1
  port 0 porters 0 pos 2 print 1 profile 1 profile-results 1 pr 2
  ps 1 preclude 1 preclude-all-but 1 protect 1
  address-> 3 put 4 reassemble 2 read-file-as-string 1 read-file 1
  read 1 read-byte 1 read-from-string 1
  receive 1 release 0 remove 2 require 3 reverse 1 set 2
  simple-error 1 snd 1 specialise 1 spy 1 step 1 stinput 0 stoutput 0
  string->n 1 string->symbol 1 string? 1 subst 3 sum 1
  symbol? 1 systemf 1 tail 1 tl 1 tc 1 tc? 0
  thaw 1 tlstr 1 track 1 trap-error 2 tuple? 1 type 2
  return 3 undefmacro 1 unput 3 unprofile 1 unify 4 unify! 4
  union 2 untrack 1 unspecialise 1 undefmacro 1
  vector 1 vector-> 3 value 1 variable? 1 version 0
  write-byte 2 write-to-file 2 y-or-n? 1 + 2 * 2 / 2 - 2 == 2
  <e> 1 <!> 1 @p 2 @v 2 @s 2 preclude 1 include 1
  preclude-all-but 1 include-all-but 1])

(define systemf
  F -> (let Shen (intern "shen")
            External (get Shen external-symbols)
            Place (put Shen external-symbols (adjoin F External))
          F))

(define adjoin
  X Y -> (if (element? X Y) Y [X | Y]))

(put (intern "shen") external-symbols
     [! } { --> <-- && : ; :- := _
      *language* *implementation* *stinput* *stoutput* *home-directory* *version*
      *maximum-print-sequence-size* *macros* *os* *release* *property-vector*
      *port* *porters* *hush*
      @v @p @s
      <- -> <e> <!> == = >= > /. =! $ - / * + <= < >> <>
      y-or-n? write-to-file write-byte where when warn version
      verified variable? value vector-> <-vector vector vector?
      unspecialise untrack unit unix union unify
      unify! unput unprofile undefmacro return type tuple? true
      trap-error track time thaw tc? tc tl tlstr tlv
      tail systemf synonyms symbol symbol? string->symbol sum subst
      string? string->n stream string stinput
      stoutput step spy specialise snd simple-error set save str run
      reverse remove release read receive
      read-file read-file-as-bytelist read-file-as-string read-byte
      read-from-string package? put preclude
      preclude-all-but ps prolog? protect profile-results profile print
      pr pos porters port package output out os or
      optimise open occurrences occurs-check n->string number? number
      null nth not nl mode macroexpand
      maxinferences mapcan map make-string load loaded list lineread
      limit length let lazy lambda language kill is
      intersection inferences intern integer? input input+ include
      include-all-but it in internal implementation if identical head
      hd hdv hdstr hash get get-time gensym function fst freeze fix
      file fail fail-if fwhen findall
      false enable-type-theory explode external exception eval-kl eval
      error-to-string error empty?
      element? do difference destroy defun define defmacro defcc
      defprolog declare datatype cut cn
      cons? cons cond concat compile cd cases call close bind bound?
      boolean? boolean bar! assoc arity
      append and adjoin <-address address-> absvector? absvector abort])

(define symbol-table-entry
  F -> (let ArityF (arity F)
         (cases (= ArityF -1) []
                (= ArityF 0) [] \\ change to [[F | F]] for CL if wanted
                true [[F | (eval-kl (lambda-form F ArityF))]])))

(define lambda-form
  F 0 -> F
  F N -> (let X (gensym (protect V))
           [lambda X (lambda-form (add-end F X) (- N 1))]))

(define add-end
  [F | Y] X -> (append [F | Y] [X])
  F X -> [F X])

(set *symbol-table*
      [[datatype-error | (/. X (datatype-error X))]
       [tuple | (/. X (tuple X))]
       [pvar | (/. X (pvar X))]
       |
       (mapcan (/. X (symbol-table-entry X)) (external (intern "shen")))])

(define specialise
  F -> (do (set *special* [F | (value *special*)]) F))

(define unspecialise
  F -> (do (set *special* (remove F (value *special*))) F))

)

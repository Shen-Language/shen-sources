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

(define declare
  F A -> (let Record (set *signedfuncs* [[F | A] | (value *signedfuncs*)])
              Variancy (trap-error (variancy-test F A) (/. E skip))
              Type (rcons_form (demodulate A))
              F* (concat type-signature-of- F)
              Parameters (parameters 1)
              Clause [[F* (protect X)] :- [[unify! (protect X) Type]]]
              AUM_instruction (aum Clause Parameters)
              Code (aum_to_shen AUM_instruction)
              ShenDef [define F* | (append Parameters
                                           [(protect ProcessN) (protect Continuation)]
                                           [-> Code])]
              Eval (eval-without-macros ShenDef)
            F))

(define demodulate
  X -> (trap-error (let Demod (walk (/. Y (demod Y)) X)
                     (if (= Demod X)
                         X
                         (demodulate Demod))) (/. E X)))

(define variancy-test
  F A -> (let TypeF (typecheck F (protect B))
              Check (cases (= symbol TypeF) skip
                           (variant? TypeF A) skip
                           true (output "warning: changing the type of ~A may create errors~%" F))
              skip))

(define variant?
  X X -> true
  [X | Y] [X | Z] -> (variant? Y Z)
  [X | Y] [W | Z] -> (variant? (subst a X Y) (subst a W Z))
      where (and (pvar? X) (variable? W))
  [[X | Y] | Z] [[X* | Y*] | Z*] -> (variant? (append [X | Y] Z)
                                              (append [X* | Y*] Z*))
  _ _ -> false)

(declare absvector? [A --> boolean])
(declare adjoin [A --> [[list A] --> [list A]]])
(declare and [boolean --> [boolean --> boolean]])
(declare app [A --> [string --> [symbol --> string]]])
(declare append [[list A] --> [[list A] --> [list A]]])
(declare arity [A --> number])
(declare assoc [A --> [[list [list A]] --> [list A]]])
(declare boolean? [A --> boolean])
(declare bound? [symbol --> boolean])
(declare cd [string --> string])
(declare close [[stream A] --> [list B]])
(declare cn [string --> [string --> string]])
(declare compile [[A ==> B] --> [A --> [[A --> B] --> B]]])
(declare cons? [A --> boolean])
(declare destroy [[A --> B] --> symbol])
(declare difference [[list A] --> [[list A] --> [list A]]])
(declare do [A --> [B --> B]])
(declare <e> [[list A] ==> [list B]])
(declare <!> [[list A] ==> [list A]])
(declare element? [A --> [[list A] --> boolean]])
(declare empty? [A --> boolean])
(declare enable-type-theory [symbol --> boolean])
(declare external [symbol --> [list symbol]])
(declare error-to-string [exception --> string])
(declare explode [A --> [list string]])
(declare fail [--> symbol])
(declare fail-if [[symbol --> boolean] --> [symbol --> symbol]])
(declare fix [[A --> A] --> [A --> A]])
(declare freeze [A --> [lazy A]])
(declare fst [[A * B] --> A])
(declare function [[A --> B] --> [A --> B]])
(declare gensym [symbol --> symbol])
(declare <-vector [[vector A] --> [number --> A]])
(declare vector-> [[vector A] --> [number --> [A --> [vector A]]]])
(declare vector [number --> [vector A]])
(declare get-time [symbol --> number])
(declare hash [A --> [number --> number]])
(declare head [[list A] --> A])
(declare hdv [[vector A] --> A])
(declare hdstr [string --> string])
(declare if [boolean --> [A --> [A --> A]]])
(declare it [--> string])
(declare implementation [--> string])
(declare include [[list symbol] --> [list symbol]])
(declare include-all-but [[list symbol] --> [list symbol]])
(declare inferences [--> number])
(declare insert [A --> [string --> string]])
(declare integer? [A --> boolean])
(declare internal [symbol --> [list symbol]])
(declare intersection [[list A] --> [[list A] --> [list A]]])
(declare kill [--> A])
(declare language [--> string])
(declare length [[list A] --> number])
(declare limit [[vector A] --> number])
(declare load [string --> symbol])
(declare map [[A --> B] --> [[list A] --> [list B]]])
(declare mapcan [[A --> [list B]] --> [[list A] --> [list B]]])
(declare maxinferences [number --> number])
(declare n->string [number --> string])
(declare nl [number --> number])
(declare not [boolean --> boolean])
(declare nth [number --> [[list A] --> A]])
(declare number? [A --> boolean])
(declare occurrences [A --> [B --> number]])
(declare occurs-check [symbol --> boolean])
(declare optimise [symbol --> boolean])
(declare or [boolean --> [boolean --> boolean]])
(declare os [--> string])
(declare package? [symbol --> boolean])
(declare port [--> string])
(declare porters [--> string])
(declare pos [string --> [number --> string]])
(declare pr [string --> [[stream out] --> string]])
(declare print [A --> A])
(declare profile [[A --> B] --> [A --> B]])
(declare preclude [[list symbol] --> [list symbol]])
(declare proc-nl [string --> string])
(declare profile-results [[A --> B] --> [[A --> B] * number]])
(declare protect [symbol --> symbol])
(declare preclude-all-but [[list symbol] --> [list symbol]])
(declare prhush [string --> [[stream out] --> string]])
(declare ps [symbol --> [list unit]])
(declare read [[stream in] --> unit])
(declare read-byte [[stream in] --> number])
(declare read-file-as-bytelist [string --> [list number]])
(declare read-file-as-string [string --> string])
(declare read-file [string --> [list unit]])
(declare read-from-string [string --> [list unit]])
(declare release [--> string])
(declare remove [A --> [[list A] --> [list A]]])
(declare reverse [[list A] --> [list A]])
(declare simple-error [string --> A])
(declare snd [[A * B] --> B])
(declare specialise [symbol --> symbol])
(declare spy [symbol --> boolean])
(declare step [symbol --> boolean])
(declare stinput [--> [stream in]])
(declare stoutput [--> [stream out]])
(declare string? [A --> boolean])
(declare str [A --> string])
(declare string->n [string --> number])
(declare string->symbol [string --> symbol])
(declare sum [[list number] --> number])
(declare symbol? [A --> boolean])
(declare systemf [symbol --> symbol])
(declare tail [[list A] --> [list A]])
(declare tlstr [string --> string])
(declare tlv [[vector A] --> [vector A]])
(declare tc [symbol --> boolean])
(declare tc? [--> boolean])
(declare thaw [[lazy A] --> A])
(declare track [symbol --> symbol])
(declare trap-error [A --> [[exception --> A] --> A]])
(declare tuple? [A --> boolean])
(declare undefmacro [symbol --> symbol])
(declare union [[list A] --> [[list A] --> [list A]]])
(declare unprofile [[A --> B] --> [A --> B]])
(declare untrack [symbol --> symbol])
(declare unspecialise [symbol --> symbol])
(declare variable? [A --> boolean])
(declare vector? [A --> boolean])
(declare version [--> string])
(declare write-to-file [string --> [A --> A]])
(declare write-byte [number --> [[stream out] --> number]])
(declare y-or-n? [string --> boolean])
(declare > [number --> [number --> boolean]])
(declare < [number --> [number --> boolean]])
(declare >= [number --> [number --> boolean]])
(declare <= [number --> [number --> boolean]])
(declare = [A --> [A --> boolean]])
(declare + [number --> [number --> number]])
(declare / [number --> [number --> number]])
(declare - [number --> [number --> number]])
(declare * [number --> [number --> number]])
(declare == [A --> [B --> boolean]])

)

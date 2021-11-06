\\           Copyright (c) 2010-2019, Mark Tarver

\\                  All rights reserved.

(package shen [shen update-lambda-table inline]

(set *history* [])
(set *tc* false)
(set *property-vector* (vector 20000))
(set *macros* [ [defmacro-macro | (/. X (defmacro-macro X))]
                [timer-macro | (/. X (timer-macro X))]
                [cases-macro | (/. X (cases-macro X))]
                [abs-macro | (/. X (abs-macro X))]
                [put/get-macro | (/. X (put/get-macro X))]
                [datatype-macro | (/. X (datatype-macro X))]
                [let-macro | (/. X (let-macro X))]
                [assoc-macro | (/. X (assoc-macro X))]
                [make-string | (/. X (make-string-macro X))]
                [output-macro | (/. X (output-macro X))]
                [input-macro | (/. X (input-macro X))]
                [error-macro | (/. X (error-macro X))]
                [prolog-macro | (/. X (prolog-macro X))]
                [synonyms-macro | (/. X (synonyms-macro X))]
                [nl-macro | (/. X (nl-macro X))]
                [@s-macro | (/. X (@s-macro X))]
                [defprolog | (/. X (defprolog-macro X))]
                [defcc-macro | (/. X (defcc-macro X))]
                [u!-macro | (/. X (u!-macro X))]])
(set *gensym* 0)
(set *tracking* [])
(set *profiled* [])
(set *home-directory* "")
(set *special* [@p @s @v cons lambda let where set open input+ type])
(set *extraspecial* [])
(set *spy* false)
(set *datatypes* [])
(set *alldatatypes* [])
(set *shen-type-theory-enabled?* true)
(set *package* null)
(set *synonyms* [])
(set *system* [])
(set *sigf* [])
(set *occurs* true)
(set *factorise?* false)
(set *maxinferences* 1000000)
(set *maximum-print-sequence-size* 20)
(set *call* 0)
(set *infs* 0)
(set *hush* false)
(set *optimise* false)
(set *version* "31")
(set *step* false)
(set *it* "")
(set *residue* [])

(define prolog-memory
   N -> (let Bindings (absvector N)
             PrintNamed (address-> Bindings 0 print-prolog-vector)
             Ticketed (address-> Bindings 1 2)
             Assign (set *prolog-vector* Ticketed)
             N))

(prolog-memory 1e4)
(set *loading?* false)

(define initialise-lambda-tables
  [] -> []
  [F Arity | Table] -> (let DecArity (put F arity Arity)
                            (initialise-arity-table Table))
  _ -> (simple-error "implementation error in shen.initialise-arity-table"))

(define arity
   F -> (trap-error (get F arity) (/. E -1)))

(define initialise-arity-table
  [] -> []
  [F Arity | Table] -> (let DecArity (put F arity Arity)
                            (initialise-arity-table Table))
  _ -> (simple-error "implementation error in shen.initialise_arity_table"))

(initialise-arity-table
  [abort 0 absvector? 1 absvector 1 address-> 3 adjoin 2 and 2 append 2 arity 1
  assoc 2 atom? 1 boolean? 1 bootstrap 1 bound? 1 bind 6 call 5 cd 1 compile 2 concat 2 cons 2 cons? 1 cn 2 close 1 declare 2 destroy 1 difference 2
  do 2 element? 2 empty? 1 enable-type-theory 1 external 1 error-to-string 1 interror 2 eval 1
  eval-kl 1 explode 1 external 1 factorise 1 fail-if 2 fail 0 fix 2 findall 7 fork 5 freeze 1 fresh 0
  fst 1 fn 1 function 1 gensym 1 get 3 get-time 1 address-> 3 <-address 2 <-vector 2 > 2 >= 2 = 2 hash 2 hd 1
  hdv 1 hdstr 1 head 1 if 3 include 1 in-package 1 integer? 1 internal 1 intern 1 inferences 0
  input 1 input+ 2 implementation 0 include-all-but 1 intersection 2 internal 1 it 0 is 6 is! 6
  language 0 length 1 limit 1 lineread 1 list 1 load 1 < 2 <= 2 vector 1 macroexpand 1 map 2 mapcan 2
  maxinferences 1 nl 1 not 1 nth 2 n->string 1 number? 1 occurs-check 1 occurrences 2 occurs-check 1
  open 2 optimise 1 or 2 os 0 package 3 package? 1 port 0 porters 0 pos 2 preclude-all-but 1
   print 1 pprint 1 profile 1 print-prolog-vector 1 print-freshterm 1 printF 1
   prolog-memory 1 profile-results 1 pr 2 ps 1 preclude 1 preclude-all-but 1 protect 1
   put 4 read-file-as-string 1 read-file-as-bytelist 1 read-file 1 read 1 read-byte 1
   read-from-string 1 read-from-string-unprocessed 1 read-unit-string 1 receive 1 release 0 remove 2 reverse 1 set 2 simple-error 1 snd 1
   specialise 2 spy 1 step 1 stinput 0 stoutput 0 str 1 string->n 1 string->symbol 1 string? 1 subst 3
   sum 1 symbol? 1 systemf 1 tail 1 tl 1 tc 1 tc? 0 thaw 1 tlstr 1 track 1 trap-error 2
   tuple? 1 type 2 return 5 undefmacro 1 unput 3 unprofile 1 union 2 untrack 1 undefmacro 1
   update-lambda-table 2 vector 1 vector? 1 vector-> 3 value 1 variable? 1 var? 5 version 0 when 5 write-byte 2
   write-to-file 2 y-or-n? 1 + 2 * 2 / 2 - 2 == 2 <e> 1 <end> 1 <!> 1 @p 2 @v 2 @s 2])

(define systemf
  F -> (let External (get shen external-symbols)
            Place (put shen external-symbols (adjoin F External))
            F))

(define adjoin
  X Y -> (if (element? X Y) Y [X | Y]))

(put shen external-symbols
     [! } { --> <-- && (intern ":") (intern ";") (intern ":=") (intern ",") _ *language* *implementation*
     *stinput* *stoutput* *home-directory* *version* *maximum-print-sequence-size* *macros* *os* *release*
     *property-vector* @v @p @s *port* *porters* *hush* <- -> <e> == = >= > ==> /. <!> <end> $ - / * + <=
     < >> <> y-or-n? write-to-file write-byte where when warn version verified variable? var?
     value vector-> <-vector vector vector? u! update-lambda-table unspecialise untrack unit unix union unput unprofile undefmacro
     return type tuple? true trap-error track time thaw tc? tc tl tlstr tlv tail systemf synonyms symbol symbol?
     string->symbol sum subst string? string->n stream string stinput stoutput step spy specialise snd simple-error
     set save str run reverse remove release read receive read-file read-file-as-bytelist read-file-as-string
     read-byte read-from-string read-from-string-unprocessed package? put preclude preclude-all-but ps prolog?
     protect profile-results profile prolog-memory print pprint pr pos porters port package output out os or
     optimise open occurrences occurs-check n->string number? number null nth not nl mode macroexpand maxinferences
     mapcan map make-string load loaded list lineread limit length let lazy lambda language is intersection inferences
     intern integer? input input+ inline include include-all-but it is is! in in-package internal implementation if
      head hd hdv hdstr hash get get-time gensym fn function fst freeze fresh fork fix file fail fail-if factorise
      findall false enable-type-theory explode external exception eval-kl eval error-to-string error empty? element?
      do difference destroy defun define defmacro defcc defprolog declare datatype cn cons? cons cond concat
      compile cd cases call close bind bound? boolean? boolean bootstrap (intern "bar!")
      atom? assoc arity append and adjoin <-address address-> absvector? absvector abort])

(define lambda-entry
  F -> (let ArityF (arity F)
            (if (or (= ArityF -1) (= ArityF 0))
                []
                [F | (eval-kl (lambda-function [F] ArityF))])))

(define build-lambda-table
  Fs -> (let LambdaEntries (map (/. X (lambda-entry X)) Fs)
             (set *lambdatable* [[tuple | (/. X (tuple X))]
                                 [pvar | (/. X (pvar X))]
                                 [print-prolog-vector | (/. X (print-prolog-vector X))]
                                 [print-freshterm | (/. X (print-freshterm X))]
                                 [printF | (/. X (printF X))]
                                 | LambdaEntries])))

(build-lambda-table (external shen))                                    )
\\           Copyright (c) 2010-2019, Mark Tarver

\\                  All rights reserved.

(package shen []

(define macroexpand
  X -> (let Fs (map (/. X (tl X)) (value *macros*))
           (macroexpand-h X Fs Fs)))

(define macroexpand-h
  X [] _ -> X
  X [F | Fs] Macros -> (let Y (walk F X)
                            (if (= X Y)
                                (macroexpand-h X Fs Macros)
                                (macroexpand-h Y Macros Macros)))
  _ _ _ -> (simple-error "implementation error in shen.macroexpand-h"))

(define walk
  F [X | Y] -> (F (map (/. Z (walk F Z)) [X | Y]))
  F X -> (F X))

(define defmacro-macro
  [defmacro F | Rest] -> (let Default [(protect X) -> (protect X)]
                              Def (eval [define F | (append Rest Default)])
                              Record (record-macro F (/. X (F X)))
                              F)
   X -> X)

(define u!-macro
  [u! S] -> [protect (make-uppercase S)]
  X -> X)

(define make-uppercase
  S -> (intern (mu-h (str S))))

(define mu-h
  "" -> ""
  (@s S Ss) -> (let ASCII (string->n S)
                    ASCII-32 (- ASCII 32)
                    Upper (if (and (>= ASCII 97) (<= ASCII 122)) (n->string ASCII-32) S)
                    (@s Upper (mu-h Ss))))

(define record-macro
  F Lambda -> (set *macros* (update-assoc F Lambda (value *macros*))))

(define update-assoc
  F Lambda [] -> [[F | Lambda]]
  F Lambda [[F | _] | Macros] -> [[F | Lambda] | Macros]
  F Lambda [Macro | Macros] -> [Macro | (update-assoc F Lambda Macros)]
  _ _ _ -> (simple-error "implementation error in shen.update-assoc"))

(define error-macro
  [error String | Args] -> [simple-error (mkstr String Args)]
  X -> X)

(define output-macro
  [output String | Args] -> [pr (mkstr String Args) [stoutput]]
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
  [read-byte] -> (if (char-stinput? (stinput))
                     [string->n [read-unit-string [stinput]]]
                     [read-byte [stinput]])
  X -> X)

(define defcc-macro
  [defcc | X] -> (yacc->shen X)
  X -> X)

(define prolog-macro
  [prolog? | Literals] -> (call-prolog Literals)
  X -> X)

(define call-prolog
  Literals -> (let Bindings [reset-prolog-vector]
                   Lock [@v true 0 [vector 0]]
                   Key 0
                   Continuation [freeze true]
                   CLiterals (compile (/. X (<body> X)) Literals)
                   Received (received Literals)
                   B (gensym (protect V))
                   L (gensym (protect L))
                   K (gensym (protect K))
                   C (gensym (protect C))
                   Lambda [lambda B [lambda L [lambda K [lambda C (continue Received CLiterals B L K C)]]]]
                   [Lambda Bindings Lock Key Continuation]))

(define received
  [receive X] -> [X]
  [X | Y] -> (union (received X) (received Y))
  _ -> [])

(define reset-prolog-vector
  -> (address-> (value *prolog-vector*) 1 2))

(define receive
  X -> X)

(define defprolog-macro
  [defprolog F | Clauses] -> (compile-prolog F Clauses)
  X -> X)

(define datatype-macro
  [datatype F | Rules]
   -> (let D (intern-type F)
           Compile (compile (/. X (<datatype> X)) [D | Rules])
           D)
  X -> X)

(define rcons_form
  [X | Y] -> [cons (rcons_form X) (rcons_form Y)]
  X -> X)

(define intern-type
  F -> (intern (cn (str F) "#type")))

(define @s-macro
  [@s W X Y | Z] -> [@s W (@s-macro [@s X Y | Z])]
  [@s X Y] -> (let E (explode X)
                   (if (> (length E) 1)
                       (@s-macro [@s | (append E [Y])])
                       [@s X Y]))   where (string? X)
  X -> X)

(define synonyms-macro
  [synonyms | X] -> (synonyms-h (append X (value *synonyms*)))
  X -> X)

(define synonyms-h
  Synonyms -> (let CurryTypes (map (/. X (curry-type X)) Synonyms)
                   Eval (eval [define demod | (compile-synonyms CurryTypes)])
                   synonyms))

(define compile-synonyms
  [] -> (let X (gensym (protect X)) [X -> X])
  [X SynX | Synonyms] -> [(rcons_form X) -> (rcons_form SynX)
                          | (compile-synonyms Synonyms)]
  _ -> (error "synonyms requires an even number of arguments~%"))

(define nl-macro
  [nl] -> [nl 1]
  X -> X)

(define assoc-macro
  [F W X Y | Z] -> [F W (assoc-macro [F X Y | Z])]
                        where (element? F [@p @v append and or + * do])
  X -> X)

(define let-macro
   [let V W X Y | Z] -> [let V W (let-macro [let X Y | Z])]
   [let X Y Z] -> (if (variable? X) [let X Y Z] (error "~S is not a variable~%" X))
   X -> X)

(define abs-macro
   [/. V W X | Y] -> [lambda V (abs-macro [/. W X | Y])]
   [/. X Y] -> (if (variable? X) [lambda X Y] (error "~S is not a variable~%" X))
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
                             (protect Message) [pr [cn "c#10;run time: "
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

(define undefmacro
  F -> (do (set *macros* (remove (assoc F (value *macros*)) (value *macros*)))
           F)) )
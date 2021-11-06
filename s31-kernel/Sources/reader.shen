\\           Copyright (c) 2010-2019, Mark Tarver

\\                  All rights reserved.

(package shen [shen]

(define read-file
  File -> (let Bytelist (read-file-as-bytelist File)
               S-exprs (trap-error (compile (/. X (<s-exprs> X)) Bytelist)
                                   (/. E (print-residue (value *residue*))))
               Process (process-sexprs S-exprs)
               Process))

(define print-residue
  Residue -> (let Err (output "syntax error here:~%")
                  (nchars 50 Residue)))

(define nchars
  0 _ -> (do (pr " ...") (abort))
  _ [] -> (do (pr " ...") (abort))
  N [Byte | Bytes] -> (do (pr (n->string Byte)) (nchars (- N 1) Bytes)))

(define it
  -> (value *it*))

(define read-file-as-bytelist
 File -> (let  Stream (open File in)
               Byte   (read-byte Stream)
               Bytes  (read-file-as-bytelist-help Stream Byte [])
               Close  (close Stream)
               (reverse Bytes)))

(define read-file-as-bytelist-help
  Stream -1 Bytes -> Bytes
  Stream Byte Bytes -> (read-file-as-bytelist-help Stream (read-byte Stream) [Byte | Bytes]))

(define read-file-as-string
   File -> (let Stream (open File in)
               (rfas-h Stream (read-byte Stream) "")))

(define rfas-h
  Stream -1 String -> (do (close Stream) String)
  Stream N String  -> (rfas-h Stream (read-byte Stream) (cn String (n->string N))))

(define input
  Stream -> (eval-kl (read Stream)))

(define input+
  Type Stream -> (let Mono? (monotype Type)
                      Input (read Stream)
                      (if (= false (typecheck Input (rectify-type Type)))
                          (error "type error: ~R is not of type ~R~%" Input Type)
                          (eval-kl Input))))

(define monotype
  [X | Y] -> (map (/. Z (monotype Z)) [X | Y])
  X       -> (if (variable? X) (error "input+ expects a monotype: not ~A~%" X) X))

(define lineread
  Stream -> (read-loop Stream (my-read-byte Stream) [] (/. X (return? X))))

(define read-from-string
  String -> (let Bytelist (str->bytes String)
                 S-exprs (compile (/. X (<s-exprs> X)) Bytelist)
                 Process (process-sexprs S-exprs)
                 Process))

(define read-from-string-unprocessed
  String -> (let Bytelist (str->bytes String)
                 S-exprs (compile (/. X (<s-exprs> X)) Bytelist)
                 S-exprs))

(define str->bytes
  "" -> []
  (@s S Ss) -> [(string->n S) | (str->bytes Ss)])

(define read
  Stream -> (hd (read-loop Stream (my-read-byte Stream) [] (/. X (whitespace? X)))))

(define my-read-byte
  Stream -> (if (char-stinput? Stream)
                (string->n (read-unit-string Stream))
                (read-byte Stream)))

(define read-loop
   _ 94 Bytes Terminate?      -> (error "read aborted")
  _ -1 Bytes Terminate?       -> (if (empty? Bytes)
                                      (simple-error "error: empty stream")
                                      (compile (/. X (<s-exprs> X)) Bytes))
  Stream 0 Bytes Terminate?    -> (read-loop Stream (my-read-byte Stream) Bytes Terminate?)
  Stream Byte Bytes Terminate? -> (if (Terminate? Byte)
                                      (let Parse (try-parse Bytes)
                                          (if (nothing-doing? Parse)
                                              (read-loop Stream
                                                         (my-read-byte Stream)
                                                         (append Bytes [Byte])
                                                         Terminate?)
                                              (do (record-it Bytes) Parse)))
                                      (read-loop Stream
                                                (my-read-byte Stream)
                                                (append Bytes [Byte])
                                                Terminate?)))

(define try-parse
   Bytes -> (let S-exprs (trap-error (compile (/. X (<s-exprs> X)) Bytes) (/. E i-failed!))
                 (if (nothing-doing? S-exprs)
                     i-failed!
                     (process-sexprs S-exprs))))

(define nothing-doing?
   i-failed! -> true
   [] -> true
   _ -> false)

(define record-it
  Bytes -> (set *it* (bytes->string Bytes)))

(define bytes->string
    [] -> ""
    [Byte | Bytes] -> (cn (n->string Byte) (bytes->string Bytes)))

(define process-sexprs
   S-exprs -> (let Unpack&Expand (unpackage&macroexpand S-exprs)
                   FindArities (find-arities Unpack&Expand)
                   Types (find-types Unpack&Expand)
                   (map (/. X (process-applications X Types)) Unpack&Expand)))

(define find-types
  [Colon A | X] -> [A | (find-types X)]  where (= Colon (intern ":"))
  [X | Y] -> (append (find-types X) (find-types Y))
  X -> [])

(define find-arities
  [define F { | X] -> (store-arity F (find-arity F 1 X))
  [define F | X] -> (store-arity F (find-arity F 0 X))
  [X | Y] -> (map (/. Z (find-arities Z)) [X | Y])
  _ -> skip)

(define store-arity
  F N -> (let ArityF (arity F)
              (cases (= ArityF -1) (execute-store-arity F N)
                     (= ArityF N)  skip
                     true (do (output "changing the arity of ~A may cause errors~%" F)
                              (execute-store-arity F N)))))

(define execute-store-arity
  F 0 -> (put F arity 0)
  F N -> (do (put F arity N)
             (update-lambdatable F N)))

(define update-lambdatable
  F N -> (let LambdaTable (value *lambdatable*)
              Lambda (eval-kl (lambda-function [F] N))
              Insert (assoc-> F Lambda LambdaTable)
              Reset (set *lambdatable* Insert)
              Reset))

(define lambda-function
  _ 0 -> skip
  FX 1 -> (let X (protect (gensym Y)) [lambda X (append FX [X])])
  FX N -> (let X (protect (gensym Y)) [lambda X (lambda-function (append FX [X]) (- N 1))]))

(define assoc->
  F X [] -> [[F | X]]
  F X [[F | _] | Y] -> [[F | X] | Y]
  F X [Y | Z] -> [Y | (assoc-> F X Z)]
  _ _ _ -> (simple-error "implementation error in shen.assoc->"))

(define find-arity
  _ 0 [X | _] -> 0  where (= X ->)
  _ 0 [X | _] -> 0  where (= X <-)
  F 0 [_ | X] -> (+ 1 (find-arity F 0 X))
  F 1 [} | X] -> (find-arity F 0 X)
  F 1 [_ | X] -> (find-arity F 1 X)
  F 1 _ -> (error "syntax error in ~A definition: missing }~%" F)
  F _ _ -> (error "syntax error in ~A definition: missing -> or <-~%" F))

(defcc <s-exprs>
  <lsb> <s-exprs1> <rsb> <s-exprs2>  := [(cons-form <s-exprs1>) | <s-exprs2>];
  <lrb> <s-exprs1> <rrb> <s-exprs2>  := (add-sexpr <s-exprs1> <s-exprs2>);
  <lcurly> <s-exprs>                 := [{ | <s-exprs>];
  <rcurly> <s-exprs>                 := [} | <s-exprs>];
  <bar> <s-exprs>                    := [bar! | <s-exprs>];
  <semicolon> <s-exprs>              := [(intern ";") | <s-exprs>];
  <colon> <equal> <s-exprs>          := [(intern ":=") | <s-exprs>];
  <colon> <s-exprs>                  := [(intern ":") | <s-exprs>];
  <comma> <s-exprs>                  := [(intern ",") | <s-exprs>];
  <comment> <s-exprs>                := <s-exprs>;
  <atom> <s-exprs>                   := [<atom> | <s-exprs>];
  <whitespaces> <s-exprs>            := <s-exprs>;
  <e>                                := [];)

(define add-sexpr
  [$ X] Y -> (append (explode X) Y)
  X Y -> [X | Y])

(defcc <lsb>
   91 := skip;)

(defcc <rsb>
   93 := skip;)

(defcc <s-exprs1>
  <s-exprs> := <s-exprs>;)

(defcc <s-exprs2>
  <s-exprs> := <s-exprs>;)

(define cons-form
  []              -> []
  [X Bar Y]       -> [cons X Y]	                      where (= Bar bar!)
  [X Bar Y Z | _] -> (error "misapplication of |~%")  where (= Bar bar!)
  [X | Y]         -> [cons X (cons-form Y)])

(defcc <lrb>
  40 := skip;)

(defcc <rrb>
  41 := skip;)

(defcc <lcurly>
  123 := skip;)

(defcc <rcurly>
  125 := skip;)

(defcc <bar>
  124 := skip;)

(defcc <semicolon>
  59 := skip;)

(defcc <colon>
  58 := skip;)

(defcc <comma>
  44 := skip;)

(defcc <equal>
  61 := skip;)

(defcc <comment>
  <singleline> := skip;
  <multiline>  := skip;)

(defcc <singleline>
  <backslash> <backslash> <shortnatters> <returns> := skip;)

(defcc <backslash>
  92 := skip;)

(defcc <shortnatters>
   <shortnatter> <shortnatters> := skip;
   <e> := skip;)

(defcc <shortnatter>
   Byte := skip   where (not (return? Byte));)

(defcc <returns>
  <return> <returns> := skip;
  <return>           := skip;)

(defcc <return>
  Byte := skip  where (return? Byte);)

(define return?
  Byte -> (element? Byte [9 10 13]))

(defcc <multiline>
  <backslash> <times> <longnatter> := skip;)

(defcc <times>
  42 := skip;)

(defcc <longnatter>
  <comment> <longnatter> := skip;
  <times> <backslash> := skip;
  _ <longnatter> := skip;)

(defcc <atom>
  <str> := <str>;
  <number> := <number>;
  <sym> := (if (= <sym> "<>")
               [vector 0]
               (intern <sym>));)

(defcc <sym>
  <alpha> <alphanums> := (cn <alpha> <alphanums>);)

(defcc <alpha>
  Byte := (n->string Byte)	  where (alpha? Byte);)

(define alpha?
  Byte -> (or (lowercase? Byte) (uppercase? Byte) (misc? Byte)))

(define lowercase?
   Byte -> (and (>= Byte 97) (<= Byte 122)))

(define uppercase?
   Byte -> (and (>= Byte 65) (<= Byte 90)))

(define misc?
  Byte -> (element? Byte [61 45 42 47 43 95 63 36 33 64 126
                          46 62 60 38 37 39 35 96]))

(defcc <alphanums>
   <alphanum> <alphanums> := (cn <alphanum> <alphanums>);
   <e> := "";)

(defcc <alphanum>
    <alpha> := <alpha>;
    <numeral> := <numeral>;)

(defcc <numeral>
  Byte := (n->string Byte)    where (digit? Byte);)

(define digit?
  Byte -> (and (>= Byte 48) (<= Byte 57)))

(defcc <str>
  <dbq> <strcontents> <dbq> := <strcontents>;)

(defcc <dbq>
   34 := skip;)

(defcc <strcontents>
  <strc> <strcontents> := (cn <strc> <strcontents>);
  <e> := "";)

(defcc <strc>
   <control>;
   <notdbq>;)

(defcc <control>
   <lowC> <hash> <integer> <semicolon> := (n->string <integer>);)

(defcc <notdbq>
   Byte := (n->string Byte)	 where (not (= Byte 34));)

(defcc <lowC>
   99 := skip;)

(defcc <hash>
  35 := skip;)

(defcc <number>
   <minus> <number> := (- 0 <number>);
   <plus> <number>  := <number>;
   <e-number>;
   <float>;
   <integer>;)

(defcc <minus>
  45 := skip;)

(defcc <plus>
  43 := skip;)

(defcc <integer>
  <digits> := (compute-integer <digits>);)

(defcc <digits>
   <digit> <digits> := [<digit> | <digits>];
   <digit> := [<digit>];)

(defcc <digit>
  Byte := (byte->digit Byte)  where (digit? Byte);)

(define byte->digit
    Byte -> (- Byte 48))

(define compute-integer
  Digits -> (compute-integer-h (reverse Digits) 0))

(define compute-integer-h
   [] _ -> 0
   [Digit | Digits] Expt -> (+ (* (expt 10 Expt) Digit) (compute-integer-h Digits (+ Expt 1))))

(define expt
    _ 0       -> 1
    Base Expt -> (* Base (expt Base (- Expt 1)))  where (> Expt 0)
    Base Expt -> (/ (expt Base (+ Expt 1)) Base))

(defcc <float>
   <integer> <stop> <fraction> := (+ <integer> <fraction>);
   <stop> <fraction> := <fraction>;)

(defcc <stop>
  46 := skip;)

(defcc <fraction>
  <digits> := (compute-fraction <digits>);)

(define compute-fraction
  Digits -> (compute-fraction-h Digits -1))

(define compute-fraction-h
   [] _ -> 0
   [Digit | Digits] Expt -> (+ (* (expt 10 Expt) Digit)
                               (compute-fraction-h Digits (- Expt 1))))

(defcc <e-number>
   <float> <lowE> <log10> 	 := (compute-E <float> <log10>);
   <integer> <lowE> <log10>  := (compute-E <integer> <log10>);)

(defcc <log10>
  <plus> <log10> := <log10>;
  <minus> <log10> := (- 0 <log10>);
  <integer>;)

(defcc <lowE>
  101 := skip;)

(define compute-E
  N Log10 -> (* N (expt 10 Log10)))

(defcc <whitespaces>
  <whitespace> <whitespaces> := skip;
  <whitespace> := skip;)

(defcc <whitespace>
  Byte := skip     where  (whitespace? Byte);)

(define whitespace?
   32 -> true
   13 -> true
   10 -> true
    9 -> true
    _ -> false)

(define unpackage&macroexpand
  [] -> []
  [Package | S-exprs] -> (unpackage&macroexpand (append (unpackage Package) S-exprs))  where (packaged? Package)
  [S-expr | S-exprs]  -> (let M (macroexpand S-expr)
                              (if (packaged? M)
                                  (unpackage&macroexpand [M | S-exprs])
                                  [M | (unpackage&macroexpand S-exprs)])))

(define packaged?
  [package P E | Code] -> true
  _                    -> false)

(define unpackage
  [package null _ | S-exprs]     -> S-exprs
  [package P External | S-exprs] -> (let External! (eval External)
                                         Package (package-symbols (str P) External! S-exprs)
                                         RecordExternal (record-external P External!)
                                         Package))

(define record-external
  P E* -> (let External (trap-error (get P external-symbols) (/. E []))
               (put P external-symbols (union E* External))))

(define package-symbols
  P External [S-expr | S-exprs] -> (map (/. X (package-symbols P External X))
                                        [S-expr | S-exprs])
  P External S-expr -> (intern-in-package P S-expr)     where (internal? S-expr P External)
  _ _ S-expr -> S-expr)

(define intern-in-package
  P S-expr -> (intern (@s P "." (str S-expr))))

(define internal?
  S-expr P External -> (and (not (element? S-expr External))
                            (not (sng? S-expr))
                            (not (dbl? S-expr))
                            (symbol? S-expr)
                            (not (sysfunc? S-expr))
                            (not (variable? S-expr))
                            (not (internal-to-shen? (str S-expr)))
                            (not (internal-to-P? P (str S-expr)))))

(define internal-to-shen?
  (@s "shen." _) -> true
  _              -> false)

(define sysfunc?
  F -> (element? F (get shen external-symbols)))

(define internal-to-P?
   "" (@s "." _)        -> true
   (@s S Ss) (@s S Ss*) -> (internal-to-P? Ss Ss*)
  _ _                   -> false)

(define process-applications
  X Types -> X  where (element? X Types)
  [F | X] Types -> (special-case F [F | X] Types)   where (non-application? F)
  [F | X] Types -> (process-application (map (/. Y (process-applications Y Types)) [F | X]) Types)
  X _ -> X)

(define non-application?
  define -> true
  defun  -> true
  synonyms -> true
  F      -> true   where (special? F)
  F      -> true   where (extraspecial? F)
  _      -> false)

(define special-case
  lambda [lambda X Y] Types     -> [lambda X (process-applications Y Types)]
  let [let X Y Z]     Types     -> [let X (process-applications Y Types) (process-applications Z Types)]
  defun [defun F X Y] Types     -> [defun F X Y]
  define [define F { | X] Types -> [define F { | (process-after-type F X Types)]
  define [define F | X] Types   -> [define F | (map (/. Y (process-applications Y Types)) X)]
  synonyms X _                  -> [synonyms | X]
  type   [type X A] Types       -> [type (process-applications X Types) A]
  input+ [input+ A X] Types     -> [input+ A (process-applications X Types)]
  _ [F | X] Types               -> [F | (map (/. Y (process-applications Y Types)) X)]  where (special? F)
  _ [F | X] Types               -> [F | X]   where (extraspecial? F))

(define process-after-type
  F [} | X] Types -> [} | (map (/. Y (process-applications Y Types)) X)]
  F [X | Y] Types -> [X | (process-after-type F Y Types)]
  F _ Types -> (error "missing } in ~A~%" F))

(define process-application
  [F | X] Types -> (let ArityF (arity F)
                        N (length X)
                        (cases (element? [F | X] Types)           [F | X]
                               (shen-call? F)                     [F | X]
                               (fn-call? [F | X])                 (fn-call [F | X])
                               (zero-place? [F | X])              [F | X]
                               (undefined-f? F ArityF)            (simple-curry [[fn F] | X])
                               (variable? F)                      (simple-curry [F | X])
                               (application? F)                   (simple-curry [F | X])
                               (partial-application*? F ArityF N) (lambda-function [F | X] (- ArityF N))
                               (overapplication? F ArityF N)      (simple-curry [F | X])
                               true                               [F | X])))

(define zero-place?
  [F] -> true
  _ -> false)

(define shen-call?
   F -> (and (symbol? F) (internal-to-shen? (str F))))

(define internal-to-shen?
  (@s "shen." _) -> true
  _ -> false)

(define application?
  F -> (cons? F))

(define undefined-f?
   F -1 -> (and (lowercase-symbol? F) (not (element? F (external shen))))
   _ _ -> false)

(define lowercase-symbol?
  F -> (and (symbol? F) (not (variable? F))))

(define simple-curry
   [F X]       -> [F X]
   [F X Y | Z] -> (simple-curry [[F X] Y | Z])
   X -> X)

(define function
  F -> (fn F))

(define fn
   F -> (let LookUp (assoc F (value *lambdatable*))
             (if (empty? LookUp)
                 (error  "fn: ~A is undefined~%" F)
                 (tl LookUp))))

(define fn-call?
   [fn F] -> true
   [function F] -> true
   _ -> false)

(define fn-call
   [function F] -> (fn-call [fn F])
   [fn F] -> (let ArityF (arity F)
                (cases (= ArityF -1) [fn F]
                       (= ArityF 0) (error "fn cannot be applied to a zero place function~%")
                       true (lambda-function [F] ArityF))))

(define partial-application*?
  F ArityF N -> (let Verdict (> ArityF N)
                     Message (if (and Verdict (loading?) (not (element? F [+ -])))
                                 (output "partial application of ~A~%" F)
                                 skip)
                     Verdict))

(define loading?
  -> (value *loading?*))

(define overapplication?
  F ArityF N -> (let Verdict (< ArityF N)
                     Message (if (and Verdict (loading?))
                               (output "~A might not like ~A argument~A~%"
                                        F N (if (= N 1) "" "s"))
                               skip)
                     Verdict))                    )
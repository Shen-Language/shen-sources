\\ LICENSE NOTE: This code is used to generate KLambda from Shen source
\\ under the 3-clause BSD license. The code may be changed but the contents
\\ of "LICENSE.txt" must be copied to the generated KLambda verbatim. The
\\ KLambda produced is a direct derivative of the Shen sources which are
\\ 3-clause BSD licensed. Please look at the file LICENSE.txt for an
\\ accompanying discussion.

\\ Standard library precompiler.
\\
\\ This builder compiles the tracked core stlib sources to a single
\\ "klambda/stlib.kl" artifact. In addition to the executable KL code for the
\\ ordinary definitions, it also emits explicit initialisation functions that
\\ restore the runtime state normally produced by loading the Shen sources:
\\ package tables, arities, macros, datatypes, type declarations, source
\\ metadata and final installer cleanup.

(load "extensions/expand-dynamic.shen")

(do
  (set make-stlib.*defuns* [])
  (set make-stlib.*environment-init* [])
  (set make-stlib.*arity-init* [])
  (set make-stlib.*macro-init* [])
  (set make-stlib.*synonym-init* [])
  (set make-stlib.*datatype-init* [])
  (set make-stlib.*type-init* [])
  (set make-stlib.*source-init* [])
  (set make-stlib.*final-init* [])
  (set make-stlib.*packages* [])
  done)

(define make-stlib
  -> (do
       (set *maximum-print-sequence-size* 10000)
       (set shen.*gensym* 0)
       (factorise -)
       (make-stlib.reset-state)
       (shen.x.expand-dynamic.initialise)
       (let SavedMacros (value *macros*)
            MacroNames (make-stlib.core-macro-names)
            MaskedMacros (make-stlib.mask-macro-table MacroNames SavedMacros)
            Mask (set *macros* MaskedMacros)
            Result (trap-error (make-stlib.build)
                     (/. E (do (set *macros* SavedMacros)
                               (simple-error (error-to-string E)))))
         (do (set *macros* SavedMacros)
             Result))))

(define make-stlib.build
  -> (do
       (output "~%")
       (output "compiling stlib to klambda/stlib.kl:~%")
       (make-stlib.reset-package-tables (make-stlib.package-roots))
       (make-stlib.compile-install-plan (make-stlib.core-install-plan) false)
       (make-stlib.add-package-init (reverse (value make-stlib.*packages*)))
       (make-stlib.add-final-init)
       (make-stlib.write-output "klambda/stlib.kl")
       (output "stlib compilation complete.~%")
       "klambda/stlib.kl"))

(define make-stlib.reset-state
  -> (do
       (set make-stlib.*defuns* [])
       (set make-stlib.*environment-init* [])
       (set make-stlib.*arity-init* [])
       (set make-stlib.*macro-init* [])
       (set make-stlib.*synonym-init* [])
       (set make-stlib.*datatype-init* [])
       (set make-stlib.*type-init* [])
       (set make-stlib.*source-init* [])
       (set make-stlib.*final-init* [])
       (set make-stlib.*packages* [])
       done))

(define make-stlib.package-roots
  -> [symbol maths rational complex numerals list string vector
      file tuple print encrypt stlib])

(define make-stlib.core-install-plan
  -> [[load "Symbols/symbols1.shen"]
      [tc +]
      [load "Symbols/symbols2.shen"]
      [tc +]
      [load "Maths/macros.shen"]
      [load "Maths/maths.shen"]
      [tc -]
      [load "Maths/rationals.dtype"]
      [tc +]
      [load "Maths/rationals.shen"]
      [tc -]
      [load "Maths/complex.dtype"]
      [tc +]
      [load "Maths/complex.shen"]
      [tc -]
      [load "Maths/numerals.dtype"]
      [tc +]
      [load "Maths/numerals.shen"]
      [load "Lists/lists.shen"]
      [load "Strings/macros.shen"]
      [load "Strings/strings.shen"]
      [tc -]
      [load "Strings/smart.shen"]
      [load "Vectors/macros.shen"]
      \\ [load "Encrypt/encrypt.shen"] temporarily skipped until its
      \\ precompilation path is stable.
      [tc +]
      [load "Vectors/vectors.shen"]
      [load "IO/prettyprint.shen"]
      [tc -]
      [load "IO/delete-file.shen"]
      [tc +]
      [load "IO/files.shen"]
      [load "Tuples/tuples.shen"]
      [tc -]
      [load "package-stlib.shen"]])

(define make-stlib.core-macro-names
  -> [maths.maths-macro
      numerals.numeral-macro
      string-macros
      vector.vector-macros
      print.pprint-macro
      file.file-macro
      stlib.stlib-macros])

(define make-stlib.mask-macro-table
  _ [] -> []
  Names [[F | Lambda] | Macros] -> (make-stlib.mask-macro-table Names Macros)
                                   where (element? F Names)
  Names [Macro | Macros] -> [Macro | (make-stlib.mask-macro-table Names Macros)])

(define make-stlib.compile-install-plan
  [] _ -> done
  [[load File] | Steps] TC?
  -> (do
       (make-stlib.compile-file (make-string "lib/stlib/~A" File) TC?)
       (make-stlib.compile-install-plan Steps TC?))
  [[tc +] | Steps] _ -> (make-stlib.compile-install-plan Steps true)
  [[tc -] | Steps] _ -> (make-stlib.compile-install-plan Steps false)
  [Step | _] _ -> (error "make-stlib: unsupported install step ~R~%" Step))

(define make-stlib.compile-file
  File TC?
  -> (let Forms (make-stlib.read-unpackaged-file File)
          PreRegister (make-stlib.pre-register-file-arities Forms)
          Log (output "  - ~A~%" File)
          Compile (make-stlib.compile-forms Forms TC? File)
          Macros (make-stlib.install-buildtime-file-macros Forms)
       Compile))

(define make-stlib.read-unpackaged-file
  File -> (let Source (read-file-as-string File)
               Forms (read-from-string-unprocessed Source)
            (make-stlib.unpackage-only Forms)))

(define make-stlib.unpackage-only
  [] -> []
  [Package | Forms]
  -> (make-stlib.unpackage-only (append (make-stlib.unpackage-package Package) Forms))
     where (make-stlib.packaged? Package)
  [Form | Forms] -> [Form | (make-stlib.unpackage-only Forms)])

(define make-stlib.packaged?
  [package P E | Code] -> true
  _ -> false)

(define make-stlib.unpackage-package
  [package null _ | S-exprs] -> S-exprs
  [package P External | S-exprs]
  -> (let External! (eval External)
          Record (make-stlib.record-package P External! S-exprs)
          Package (make-stlib.package-symbols (str P) External! S-exprs)
       Package))

(define make-stlib.note-package
  [package null _ | _] -> null
  [package P _ | _] -> (set make-stlib.*packages* (adjoin P (value make-stlib.*packages*)))
  _ -> skip)

(define make-stlib.record-package
  P External! S-exprs
  -> (let Note (make-stlib.note-package [package P External! | S-exprs])
          RecordExternal (make-stlib.record-external P External!)
          RecordInternal (make-stlib.record-internal P External! S-exprs)
       done))

(define make-stlib.record-external
  P E*
  -> (let External (trap-error (get P (make-stlib.external-symbols-key)) (/. E []))
          New (union E* External)
       (put P (make-stlib.external-symbols-key) New)))

(define make-stlib.record-internal
  P External! S-exprs
  -> (let Old (trap-error (get P (make-stlib.internal-symbols-key)) (/. E []))
          New (make-stlib.internal-symbols (str P) External! S-exprs)
       (put P (make-stlib.internal-symbols-key) (union New Old))))

(define make-stlib.internal-symbols
  P External [X | Y] -> (union (make-stlib.internal-symbols P External X)
                               (make-stlib.internal-symbols P External Y))
  P External X -> [(make-stlib.intern-in-package P X)]
                  where (make-stlib.internal? X P External)
  _ _ _ -> [])

(define make-stlib.package-symbols
  P External [S-expr | S-exprs]
  -> (map (/. X (make-stlib.package-symbols P External X))
          [S-expr | S-exprs])
  P External S-expr -> (make-stlib.intern-in-package P S-expr)
                       where (make-stlib.internal? S-expr P External)
  _ _ S-expr -> S-expr)

(define make-stlib.intern-in-package
  P S-expr -> (intern (@s P "." (str S-expr))))

(define make-stlib.internal?
  S-expr P External
  -> (and (not (element? S-expr External))
          (not (make-stlib.sng? S-expr))
          (not (make-stlib.dbl? S-expr))
          (symbol? S-expr)
          (not (make-stlib.sysfunc? S-expr))
          (not (variable? S-expr))
          (not (make-stlib.internal-to-shen? (str S-expr)))
          (not (make-stlib.internal-to-P? P (str S-expr)))))

(define make-stlib.internal-to-shen?
  (@s "shen." _) -> true
  _ -> false)

(define make-stlib.sysfunc?
  F -> (element? F (get shen (make-stlib.external-symbols-key))))

(define make-stlib.sng?
  S -> (and (symbol? S) (make-stlib.sng-h? (str S))))

(define make-stlib.sng-h?
  "___" -> true
  (@s "_" S) -> (make-stlib.sng-h? S)
  _ -> false)

(define make-stlib.dbl?
  S -> (and (symbol? S) (make-stlib.dbl-h? (str S))))

(define make-stlib.dbl-h?
  "===" -> true
  (@s "=" S) -> (make-stlib.dbl-h? S)
  _ -> false)

(define make-stlib.internal-to-P?
  "" (@s "." _) -> true
  (@s S Ss) (@s S Ss*) -> (make-stlib.internal-to-P? Ss Ss*)
  _ _ -> false)

(define make-stlib.external-symbols-key
  -> shen.external-symbols)

(define make-stlib.internal-symbols-key
  -> shen.internal-symbols)

(define make-stlib.compile-forms
  [] _ _ -> done
  [Form | Forms] TC? File
  -> (do
       (make-stlib.compile-form Form TC? File)
       (make-stlib.compile-forms Forms TC? File)))

(define make-stlib.install-buildtime-file-macros
  [] -> skip
  [[defmacro F | _] | Forms]
  -> (do
       (shen.record-macro F (make-stlib.buildtime-macro-lambda F))
       (make-stlib.install-buildtime-file-macros Forms))
  [_ | Forms] -> (make-stlib.install-buildtime-file-macros Forms))

(define make-stlib.pre-register-file-arities
  [] -> done
  [[define F { | X] | Forms]
  -> (do
       (make-stlib.pre-register-arity F (make-stlib.find-arity F 1 X))
       (make-stlib.pre-register-file-arities Forms))
  [[define F | X] | Forms]
  -> (do
       (make-stlib.pre-register-arity F (make-stlib.find-arity F 0 X))
       (make-stlib.pre-register-file-arities Forms))
  [_ | Forms] -> (make-stlib.pre-register-file-arities Forms))

(define make-stlib.pre-register-arity
  F 0 -> (put F arity 0)
  F N -> (update-lambda-table F N))

(define make-stlib.find-arity
  _ 0 [X | _] -> 0  where (= X ->)
  _ 0 [X | _] -> 0  where (= X <-)
  F 0 [_ | X] -> (+ 1 (make-stlib.find-arity F 0 X))
  F 1 [} | X] -> (make-stlib.find-arity F 0 X)
  F 1 [_ | X] -> (make-stlib.find-arity F 1 X)
  F 1 _ -> (error "syntax error in ~A definition: missing }~%" F)
  F _ _ -> (error "syntax error in ~A definition: missing -> or <-~%" F))

(define make-stlib.compile-form
  [define F | Def] TC? _ -> (make-stlib.compile-define [define F | Def] TC?)
  [defmacro F | Rest] _ _ -> (make-stlib.compile-defmacro F Rest)
  [datatype F | Rules] _ _ -> (make-stlib.compile-datatype F Rules)
  [synonyms | X] _ _ -> (make-stlib.compile-synonyms X)
  [declare F Sig] _ _ -> (make-stlib.add-compiled-output type [declare F Sig])
  Form _ _ -> (make-stlib.add-compiled-output environment Form))

(define make-stlib.compile-define
  Define TC?
  -> (let Processed (make-stlib.prepare-form Define)
          KLDef (make-stlib.kl-define Processed)
          AddDefun (make-stlib.add-defun KLDef)
          Arity (make-stlib.install-buildtime-defun KLDef)
          InitArity (make-stlib.add-runtime-defun-init (make-stlib.defun-name KLDef) Arity KLDef)
          InitType (make-stlib.maybe-add-inline-type TC? Define)
       KLDef))

(define make-stlib.kl-define
  [define F | Def] -> (shen.shendef->kldef F Def)
  Other -> (error "make-stlib: expected definition, got ~R~%" Other))

(define make-stlib.prepare-form
  Form -> (let Expanded (macroexpand Form)
              Types (shen.find-types Expanded)
           (shen.process-applications Expanded Types)))

(define make-stlib.install-buildtime-defun
  [defun F Params Body]
  -> (let Arity (length Params)
          Register (update-lambda-table F Arity)
          Eval (eval-kl [defun F Params Body])
       Arity)
  KL -> (error "make-stlib: expected defun, got ~R~%" KL))

(define make-stlib.add-runtime-defun-init
  F Arity KLDef
  -> (do
       (make-stlib.add-init arity
         (make-stlib.compile-expression
           [update-lambda-table F Arity]))
       (make-stlib.add-init source
         (make-stlib.compile-expression
           [shen.record-kl F (make-stlib.literal-expression KLDef)]))
       done))

(define make-stlib.maybe-add-inline-type
  false _ -> skip
  true [define F { | X]
  -> (let Sig (shen.type-F F X)
          Decl [declare F (make-stlib.literal-expression Sig)]
       (make-stlib.add-init type (make-stlib.compile-expression Decl)))
  _ _ -> skip)

(define make-stlib.compile-defmacro
  F Rest
  -> (let Processed (make-stlib.prepare-form (make-stlib.defmacro->define F Rest))
          KLDef (make-stlib.kl-define Processed)
          AddDefun (make-stlib.add-defun KLDef)
          Arity (make-stlib.install-buildtime-defun KLDef)
          InitDefun (make-stlib.add-runtime-defun-init F Arity KLDef)
          InitMacro (make-stlib.add-init macro
                      (make-stlib.compile-expression
                        (make-stlib.macro-record-expression F)))
       KLDef))

(define make-stlib.defmacro->define
  F Rest -> [define F | (append Rest (make-stlib.defmacro-default))])

(define make-stlib.defmacro-default
  -> [(protect X) -> (protect X)])

(define make-stlib.macro-record-expression
  F -> (let X (protect X)
         [shen.record-macro F [/. X [F X]]]))

(define make-stlib.buildtime-macro-lambda
  F -> (let X (protect X)
         (eval [/. X [F X]])))

(define make-stlib.compile-datatype
  F Rules
  -> (let BuildTime (eval [datatype F | Rules])
          Init (make-stlib.add-init datatype
                 (make-stlib.compile-expression
                   [shen.process-datatype F (make-stlib.literal-expression Rules)]))
       F))

(define make-stlib.compile-synonyms
  X
  -> (let BuildTime (eval [synonyms | X])
          Init (make-stlib.add-init synonym
                 (make-stlib.compile-expression
                   [shen.process-synonyms (make-stlib.literal-expression X)]))
       synonyms))

(define make-stlib.compile-expression
  Expr -> (let Expanded (macroexpand Expr)
               Types (shen.find-types Expanded)
               Processed (shen.process-applications Expanded Types)
            (shen.shen->kl-h Processed)))

(define make-stlib.add-compiled-output
  Phase Expr
  -> (make-stlib.classify-compiled-output
       Phase
       (make-stlib.top-level-kl-forms (make-stlib.compile-expression Expr))))

(define make-stlib.classify-compiled-output
  _ [] -> done
  Phase [[defun F Params Body] | Forms]
  -> (let KLDef [defun F Params Body]
          AddDefun (make-stlib.add-defun KLDef)
          Arity (make-stlib.install-buildtime-defun KLDef)
          Init (make-stlib.add-runtime-defun-init F Arity KLDef)
       (make-stlib.classify-compiled-output Phase Forms))
  Phase [[] | Forms] -> (make-stlib.classify-compiled-output Phase Forms)
  Phase [KL | Forms]
  -> (do
       (make-stlib.add-init Phase KL)
       (make-stlib.classify-compiled-output Phase Forms)))

(define make-stlib.top-level-kl-forms
  [do X Y] -> (append (make-stlib.top-level-kl-forms X)
                      (make-stlib.top-level-kl-forms Y))
  X -> [X])

(define make-stlib.literal-expression
  [] -> []
  [X | Y] -> [cons (make-stlib.literal-expression X)
                   (make-stlib.literal-expression Y)]
  X -> [protect X]  where (and (symbol? X) (variable? X))
  X -> X)

(define make-stlib.defun-name
  [defun F | _] -> F
  KL -> (error "make-stlib: expected defun, got ~R~%" KL))

(define make-stlib.defun-arity
  [defun _ Params _] -> (length Params)
  KL -> (error "make-stlib: expected defun, got ~R~%" KL))

(define make-stlib.add-defun
  KLDef -> (set make-stlib.*defuns* [KLDef | (value make-stlib.*defuns*)]))

(define make-stlib.add-init
  environment KL -> (set make-stlib.*environment-init* [KL | (value make-stlib.*environment-init*)])
  arity KL -> (set make-stlib.*arity-init* [KL | (value make-stlib.*arity-init*)])
  macro KL -> (set make-stlib.*macro-init* [KL | (value make-stlib.*macro-init*)])
  synonym KL -> (set make-stlib.*synonym-init* [KL | (value make-stlib.*synonym-init*)])
  datatype KL -> (set make-stlib.*datatype-init* [KL | (value make-stlib.*datatype-init*)])
  type KL -> (set make-stlib.*type-init* [KL | (value make-stlib.*type-init*)])
  source KL -> (set make-stlib.*source-init* [KL | (value make-stlib.*source-init*)])
  final KL -> (set make-stlib.*final-init* [KL | (value make-stlib.*final-init*)]))

(define make-stlib.reset-package-tables
  [] -> []
  [P | Ps]
  -> (do
       (put P (make-stlib.external-symbols-key) [])
       (put P (make-stlib.internal-symbols-key) [])
       (make-stlib.reset-package-tables Ps)))

(define make-stlib.add-package-init
  [] -> done
  [P | Ps]
  -> (do
       (make-stlib.add-package-init-entry P)
       (make-stlib.add-package-init Ps)))

(define make-stlib.add-package-init-entry
  P
  -> (let External (make-stlib.package-value P (make-stlib.external-symbols-key))
          Internal (make-stlib.package-value P (make-stlib.internal-symbols-key))
          ExtInit (make-stlib.add-init environment
                    (make-stlib.compile-expression
                      [put P (make-stlib.external-symbols-key)
                           (make-stlib.literal-expression External)]))
          IntInit (make-stlib.add-init environment
                    (make-stlib.compile-expression
                      [put P (make-stlib.internal-symbols-key)
                           (make-stlib.literal-expression Internal)]))
       P))

(define make-stlib.package-value
  P Pointer -> (trap-error (get P Pointer) (/. E [])))

(define make-stlib.add-final-init
  -> (do
       (make-stlib.add-init final
         (make-stlib.compile-expression (make-stlib.final-systemf-expression)))
       (make-stlib.add-init final
         (make-stlib.compile-expression
           [preclude-all-but []]))
       (make-stlib.add-init final
         (make-stlib.compile-expression
           [set shen.*userdefs* []]))
       (make-stlib.add-init final
         (make-stlib.compile-expression
           [cd ""]))
       (make-stlib.add-init final
         (make-stlib.compile-expression
           [tc -]))
       done))

(define make-stlib.final-systemf-expression
  -> [let external [external stlib]
        [let externalf
             [filter [lambda x [> [arity x] -1]] external]
          [let systemf-result
               [map [fn systemf] externalf]
            ok]]])

(define make-stlib.write-output
  File
  -> (let Defuns (reverse (value make-stlib.*defuns*))
          InitDefuns (make-stlib.initialiser-defuns)
          KlString (make-string "~A" (make-stlib.list->string (append Defuns InitDefuns)))
          Write (write-to-file File KlString)
       File))

(define make-stlib.initialiser-defuns
  -> [(make-stlib.wrap-init-defun stlib.initialise-environment
        (reverse (value make-stlib.*environment-init*)))
      (make-stlib.wrap-init-defun stlib.initialise-arities
        (reverse (value make-stlib.*arity-init*)))
      (make-stlib.wrap-init-defun stlib.initialise-macros
        (reverse (value make-stlib.*macro-init*)))
      (make-stlib.wrap-init-defun stlib.initialise-synonyms
        (reverse (value make-stlib.*synonym-init*)))
      (make-stlib.wrap-init-defun stlib.initialise-datatypes
        (reverse (value make-stlib.*datatype-init*)))
      (make-stlib.wrap-init-defun stlib.initialise-types
        (reverse (value make-stlib.*type-init*)))
      (make-stlib.wrap-init-defun stlib.initialise-sources
        (reverse (value make-stlib.*source-init*)))
      (make-stlib.wrap-init-defun stlib.initialise-final
        (reverse (value make-stlib.*final-init*)))
      (make-stlib.wrap-init-defun stlib.initialise
        [[stlib.initialise-environment]
         [stlib.initialise-arities]
         [stlib.initialise-macros]
         [stlib.initialise-synonyms]
         [stlib.initialise-datatypes]
         [stlib.initialise-types]
         [stlib.initialise-sources]
         [stlib.initialise-final]])])

(define make-stlib.wrap-init-defun
  Name Exprs -> [defun Name [] (make-stlib.to-single-expression Exprs)])

(define make-stlib.to-single-expression
  [] -> []
  [Exp] -> Exp
  [Exp | Exps] -> [do Exp (make-stlib.to-single-expression Exps)])

(define make-stlib.list->string
  [] -> ""
  [[defun fail | _] | Y] -> (@s "(defun fail () shen.fail!)" (make-stlib.list->string Y))
  [X | Y] -> (@s (make-string "~R~%~%" X) (make-stlib.list->string Y)))

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

\\ Phase metadata and mutable build state.

(define make-stlib.phases
  -> [environment arity macro synonym datatype type source final])

(define make-stlib.phase-variable
  environment -> make-stlib.*environment-init*
  arity -> make-stlib.*arity-init*
  macro -> make-stlib.*macro-init*
  synonym -> make-stlib.*synonym-init*
  datatype -> make-stlib.*datatype-init*
  type -> make-stlib.*type-init*
  source -> make-stlib.*source-init*
  final -> make-stlib.*final-init*
  Phase -> (error "make-stlib: unknown phase ~R~%" Phase))

(define make-stlib.phase-initialiser
  environment -> stlib.initialise-environment
  arity -> stlib.initialise-arities
  macro -> stlib.initialise-macros
  synonym -> stlib.initialise-synonyms
  datatype -> stlib.initialise-datatypes
  type -> stlib.initialise-types
  source -> stlib.initialise-sources
  final -> stlib.initialise-final
  Phase -> (error "make-stlib: unknown phase ~R~%" Phase))

(define make-stlib.reset-phase-state
  [] -> done
  [Phase | Phases]
  -> (do
       (set (make-stlib.phase-variable Phase) [])
       (make-stlib.reset-phase-state Phases)))

(do
  (set make-stlib.*defuns* [])
  (set make-stlib.*packages* [])
  (make-stlib.reset-phase-state (make-stlib.phases))
  done)

(define make-stlib.reset-state
  -> (do
       (set make-stlib.*defuns* [])
       (set make-stlib.*packages* [])
       (make-stlib.reset-phase-state (make-stlib.phases))
       done))

(define make-stlib.add-defun
  KLDef -> (set make-stlib.*defuns* [KLDef | (value make-stlib.*defuns*)]))

(define make-stlib.add-init
  Phase KL
  -> (let Variable (make-stlib.phase-variable Phase)
       (set Variable [KL | (value Variable)])))

\\ Public entrypoints.

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
         (do
           (set *macros* SavedMacros)
           Result))))

(define make-stlib.build
  -> (do
       (output "~%")
       (output "compiling stlib to klambda/stlib.kl:~%")
       (make-stlib.compile-install-plan (make-stlib.core-install-plan) false)
       (make-stlib.add-package-init (reverse (value make-stlib.*packages*)))
       (make-stlib.add-final-init)
       (make-stlib.write-output "klambda/stlib.kl")
       (output "stlib compilation complete.~%")
       "klambda/stlib.kl"))

\\ Build configuration.

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

\\ Install-plan driving and file ingestion.

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
       (do
         (output "  - ~A~%" File)
         (make-stlib.compile-file-forms Forms TC?))))

(define make-stlib.compile-file-forms
  Forms TC?
  -> (do
       (make-stlib.pre-register-file-arities Forms)
       (make-stlib.compile-forms Forms TC?)))

\\ KL-like inputs must be read without package processing or macroexpansion.
\\ This uses the Shen reader internals directly because there is no public
\\ file-level unprocessed reader yet.
(define make-stlib.read-file-unprocessed
  File -> (let Bytelist (read-file-as-bytelist File)
               S-exprs (trap-error (compile (/. X (shen.<s-exprs> X)) Bytelist)
                                   (/. E (shen.reader-error (value shen.*residue*))))
            S-exprs))

(define make-stlib.read-unpackaged-file
  File -> (let Forms (make-stlib.read-file-unprocessed File)
            (make-stlib.unpackage-only Forms)))

(define make-stlib.unpackage-only
  [] -> []
  [Package | Forms]
  -> (let PackageState (make-stlib.ensure-package-state Package)
          Unpackaged (shen.unpackage Package)
       (make-stlib.unpackage-only (append Unpackaged Forms)))
     where (shen.packaged? Package)
  [Form | Forms] -> [Form | (make-stlib.unpackage-only Forms)])

(define make-stlib.ensure-package-state
  [package null _ | _] -> null
  [package P _ | _]
  -> (let Packages (value make-stlib.*packages*)
       (if (element? P Packages)
           P
           (do
             (make-stlib.clear-package-state P)
             (set make-stlib.*packages* [P | Packages])
             P)))
  _ -> skip)

(define make-stlib.clear-package-state
  P -> (do
         (put P shen.external-symbols [])
         (put P shen.internal-symbols [])
         P))

\\ Per-file passes.

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

(define make-stlib.compile-forms
  [] _ -> done
  [Form | Forms] TC?
  -> (do
       (make-stlib.compile-form Form TC?)
       (make-stlib.compile-forms Forms TC?)))

\\ Top-level form compilation.

(define make-stlib.compile-form
  [define F | Def] TC? -> (make-stlib.compile-define [define F | Def] TC?)
  [defmacro F | Rest] _ -> (make-stlib.compile-defmacro F Rest)
  [datatype F | Rules] _ -> (make-stlib.compile-datatype F Rules)
  [synonyms | X] _ -> (make-stlib.compile-synonyms X)
  [declare F Sig] _ -> (make-stlib.compile-top-level-effect type [declare F Sig])
  Form _ -> (make-stlib.compile-top-level-effect environment Form))

(define make-stlib.compile-define
  Define TC?
  -> (let KLDef (make-stlib.kl-define (make-stlib.normalise-form Define))
       (do
         (make-stlib.register-kl-defun KLDef)
         (make-stlib.maybe-add-inline-type TC? Define)
         KLDef)))

(define make-stlib.compile-defmacro
  F Rest
  -> (let KLDef (make-stlib.kl-define
                  (make-stlib.normalise-form (make-stlib.defmacro->define F Rest)))
       (do
         (make-stlib.register-kl-defun KLDef)
         (shen.record-macro F (make-stlib.buildtime-macro-lambda F))
         (make-stlib.queue-runtime-effect macro
           (make-stlib.macro-record-expression F))
         KLDef)))

(define make-stlib.compile-datatype
  F Rules
  -> (make-stlib.eval-buildtime-and-queue-runtime-effect
       [datatype F | Rules]
       datatype
       [shen.process-datatype F (make-stlib.literal-expression Rules)]
       F))

(define make-stlib.compile-synonyms
  X
  -> (make-stlib.eval-buildtime-and-queue-runtime-effect
       [synonyms | X]
       synonym
       [shen.process-synonyms (make-stlib.literal-expression X)]
       synonyms))

(define make-stlib.compile-top-level-effect
  Phase Expr -> (make-stlib.add-compiled-output Phase Expr))

\\ Lowering and runtime-effect helpers.

(define make-stlib.kl-define
  [define F | Def] -> (shen.shendef->kldef F Def)
  Other -> (error "make-stlib: expected definition, got ~R~%" Other))

(define make-stlib.normalise-form
  Form -> (let Expanded (macroexpand Form)
              Types (shen.find-types Expanded)
           (shen.process-applications Expanded Types)))

(define make-stlib.compile-expression
  Expr -> (shen.shen->kl-h (make-stlib.normalise-form Expr)))

(define make-stlib.install-buildtime-defun
  [defun F Params Body]
  -> (let Arity (length Params)
       (do
         (update-lambda-table F Arity)
         (eval-kl [defun F Params Body])
         Arity))
  KL -> (error "make-stlib: expected defun, got ~R~%" KL))

(define make-stlib.register-kl-defun
  KLDef
  -> (let F (make-stlib.defun-name KLDef)
          Arity (make-stlib.install-buildtime-defun KLDef)
       (do
         (make-stlib.add-defun KLDef)
         (make-stlib.add-runtime-defun-init F Arity KLDef)
         KLDef)))

(define make-stlib.add-runtime-defun-init
  F Arity KLDef
  -> (do
       (make-stlib.queue-runtime-effect arity
         [update-lambda-table F Arity])
       (make-stlib.queue-runtime-effect source
         [shen.record-kl F (make-stlib.literal-expression KLDef)])
       done))

(define make-stlib.queue-runtime-effect
  Phase Expr -> (make-stlib.add-init Phase (make-stlib.compile-expression Expr)))

(define make-stlib.eval-buildtime-and-queue-runtime-effect
  BuildTimeExpr Phase RuntimeExpr Result
  -> (do
       (eval BuildTimeExpr)
       (make-stlib.queue-runtime-effect Phase RuntimeExpr)
       Result))

(define make-stlib.maybe-add-inline-type
  false _ -> skip
  true [define F { | X]
  -> (let Sig (shen.type-F F X)
          Decl [declare F (make-stlib.literal-expression Sig)]
       (make-stlib.queue-runtime-effect type Decl))
  _ _ -> skip)

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

(define make-stlib.add-compiled-output
  Phase Expr
  -> (make-stlib.classify-compiled-output
       Phase
       (make-stlib.top-level-kl-forms (make-stlib.compile-expression Expr))))

(define make-stlib.classify-compiled-output
  _ [] -> done
  Phase [[defun F Params Body] | Forms]
  -> (do
       (make-stlib.register-kl-defun [defun F Params Body])
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

\\ Initialiser and output assembly.

(define make-stlib.add-package-init
  [] -> done
  [P | Ps]
  -> (do
       (make-stlib.add-package-init-entry P)
       (make-stlib.add-package-init Ps)))

(define make-stlib.add-package-init-entry
  P
  -> (let External (make-stlib.package-value P shen.external-symbols)
          Internal (make-stlib.package-value P shen.internal-symbols)
       (do
         (make-stlib.queue-runtime-effect environment
           [put P shen.external-symbols
                (make-stlib.literal-expression External)])
         (make-stlib.queue-runtime-effect environment
           [put P shen.internal-symbols
                (make-stlib.literal-expression Internal)])
         P)))

(define make-stlib.package-value
  P Pointer -> (trap-error (get P Pointer) (/. E [])))

(define make-stlib.add-final-init
  -> (do
       (make-stlib.queue-runtime-effect final
         (make-stlib.final-systemf-expression))
       (make-stlib.queue-runtime-effect final
         [preclude-all-but []])
       (make-stlib.queue-runtime-effect final
         [set shen.*userdefs* []])
       (make-stlib.queue-runtime-effect final
         [cd ""])
       (make-stlib.queue-runtime-effect final
         [tc -])
       done))

(define make-stlib.final-systemf-expression
  -> [let (protect External) [external stlib]
        [let (protect ExternalF)
             [filter [lambda (protect X) [> [arity (protect X)] -1]]
                     (protect External)]
          [let (protect SystemfResult)
               [map [fn systemf] (protect ExternalF)]
            ok]]])

(define make-stlib.write-output
  File
  -> (let Defuns (reverse (value make-stlib.*defuns*))
          InitDefuns (make-stlib.initialiser-defuns)
          KlString (make-stlib.list->string (append Defuns InitDefuns))
       (do
         (write-to-file File KlString)
         File)))

(define make-stlib.initialiser-defuns
  -> (append
       (make-stlib.phase-init-defuns (make-stlib.phases))
       [(make-stlib.wrap-init-defun stlib.initialise
          (make-stlib.phase-call-expressions (make-stlib.phases)))]))

(define make-stlib.phase-init-defuns
  [] -> []
  [Phase | Phases]
  -> [(make-stlib.wrap-init-defun (make-stlib.phase-initialiser Phase)
        (reverse (value (make-stlib.phase-variable Phase))))
      | (make-stlib.phase-init-defuns Phases)])

(define make-stlib.phase-call-expressions
  [] -> []
  [Phase | Phases]
  -> [[(make-stlib.phase-initialiser Phase)]
      | (make-stlib.phase-call-expressions Phases)])

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

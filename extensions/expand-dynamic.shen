\\ Copyright (c) 2019 Bruno Deferrari.
\\ BSD 3-Clause License: http://opensource.org/licenses/BSD-3-Clause

\\ Documentation: docs/extensions/expand-dynamic.md

(package shen.x.expand-dynamic [shen quote]

(define initialise
  -> (set *arities* []))

(define expand-dynamic
  [] -> []
  [[declare Name Sig] | Exps] -> [(expand-declare [declare Name Sig])
                                  | (expand-dynamic Exps)]

  \\ Store arities for use in the expansion of lambda forms
  [[shen.initialise-arity-table Arities] | Exps]
  -> (do (set *arities* (eval-kl Arities))
         [[shen.initialise-arity-table Arities] | (expand-dynamic Exps)])

  [[shen.build-lambda-table [external shen]] | Exps]
  -> (let X (protect X)
        (append (expand-lambda-entries
                    \\ TODO: would be good to obtain these from the definition itself
                    [shen.tuple 1 shen.pvar 1 shen.dictionary 1 shen.print-prolog-vector 1
                     shen.print-freshterm 1 shen.printF 1
                     | (value *arities*)])
                (expand-dynamic Exps)))

  [Exp | Exps] -> [Exp | (expand-dynamic Exps)])

(define functions-with-lambdas
  [] -> []
  [F N | Rest] -> [F | (functions-with-lambdas Rest)])

(define expand-declare
  [declare Name Sig]
  -> (let Sig (eval-kl Sig)
          Abstraction (shen.prolog-abstraction Sig)
          RecordSig [set shen.*sigf* [shen.assoc-> Name Abstraction [value shen.*sigf*]]]
       RecordSig
       ))

\\ Preserve declaration checks when precompiling load-equivalent metadata.
\\ Computed signatures retain declare so their effects happen at runtime.
(define expand-declare/checked
  [declare Name Sig]
  -> (let Abstraction (shen.prolog-abstraction (eval-kl Sig))
       [shen.declare-with-signature Name Sig [freeze Abstraction]])
    where (literal-signature? Sig)
  Expr -> Expr)

(define literal-signature?
  [protect X] -> (symbol? X)
  [cons X Y] -> (and (literal-signature? X) (literal-signature? Y))
  [] -> true
  X -> (or (symbol? X) (or (number? X) (or (string? X) (boolean? X)))))

(define expand-lambda-entries
  [] -> []
  [F Arity | Rest] -> (append
                        (expand-lambda-form-entry F Arity)
                        (expand-lambda-entries Rest))
  Other -> (error "expand-lambda-entries: got unexpected ~A" Other))

(define expand-lambda-form-entry
  package _ -> []
  receive _ -> []
  list _ -> []
  foreign _ -> []
  F Arity -> (cases (= Arity -1) []
                    (= Arity 0) []
                    true [[shen.set-lambda-form-entry
                            [cons F (shen.lambda-function [F] Arity)]]]))

\\ Expand executable KL only; parameter lists, cond clauses, and quoted data
\\ have different structure. Known lists the functions supplied by this build.
(define expand-initializer
  Expr Known -> (expand-initializer-h Expr [] Known))

(define expand-initializer-h
  [quote X] _ _ -> [quote X]
  [Op | Args] _ _ -> [Op | Args] where (opaque-initializer? Op)
  [protect X] _ _ -> [protect X]
  [defun F Params Body] _ Known
  -> [defun F Params (expand-initializer-h Body Params Known)]
  [lambda V Body] Scope Known
  -> [lambda V (expand-initializer-h Body [V | Scope] Known)]
  [let V Value Body] Scope Known
  -> [let V (expand-initializer-h Value Scope Known)
            (expand-initializer-h Body [V | Scope] Known)]
  [cond | Clauses] Scope Known
  -> [cond | (map (/. Clause (expand-initializer-clause Clause Scope Known)) Clauses)]
  [shen.update-lambda-table/precompiled | Args] _ _
  -> [shen.update-lambda-table/precompiled | Args]
  [declare Name Sig] Scope _
  -> (expand-declare/checked [declare Name Sig])
    where (and (empty? (intersection [declare shen.declare-with-signature
                                        is! cons shen.newpv shen.gc] Scope))
               (literal-in-scope? Sig Scope))
  [update-lambda-table F N] Scope Known
  -> [shen.update-lambda-table/precompiled F N
       [freeze (if (= N 0) false (shen.lambda-function [F] N))]
       [shen.precompiled-function? F]]
    where (and (and (symbol? F) (element? F Known))
               (and (integer? N)
                    (and (>= N 0)
                         (and (not (element? F Scope))
                              (and (not (element? update-lambda-table Scope))
                                   (and (not (element? shen.precompiled-function? Scope))
                                        (not (element? shen.update-lambda-table/precompiled Scope))))))))
  [Op | Args] Scope Known
  -> [(expand-initializer-h Op Scope Known)
       | (map (/. Arg (expand-initializer-h Arg Scope Known)) Args)]
  X _ _ -> X)

(define opaque-initializer?
  Op -> (opaque-initializer-name? (explode (str Op))) where (symbol? Op)
  _ -> false)

(define opaque-initializer-name?
  ["s" "c" "m" "." | _] -> true
  _ -> false)

(define expand-initializer-clause
  [Test Body] Scope Known
  -> [(expand-initializer-h Test Scope Known)
      (expand-initializer-h Body Scope Known)])

(define literal-in-scope?
  [protect X] _ -> (symbol? X)
  [cons X Y] Scope -> (and (not (element? cons Scope))
                          (and (literal-in-scope? X Scope)
                               (literal-in-scope? Y Scope)))
  X Scope -> (and (literal-signature? X) (not (element? X Scope))))

(define split-defuns-h
  [[defun | Defun] | Exps] (@p Defuns Other)
  -> (split-defuns-h Exps (@p [[defun | Defun] | Defuns] Other))
  [Exp | Exps] (@p Defuns Other)
  -> (split-defuns-h Exps (@p Defuns [Exp | Other]))
  [] (@p Defuns Other) -> (@p (reverse Defuns) (reverse Other)))

(define split-defuns
  Exps -> (split-defuns-h Exps (@p [] [])))

(define wrap-in-defun
  Name Args Exprs -> [defun Name Args (to-single-expression Name Exprs)])

(define to-single-expression
  _ [Exp] -> Exp
  Name [Exp | Exps] -> [do Exp (to-single-expression Name Exps)]
  Name _ -> (error "to-single-expression: got empty list of expressions: ~A" Name))

)

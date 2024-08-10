\\ Copyright (c) 2019 Bruno Deferrari.
\\ BSD 3-Clause License: http://opensource.org/licenses/BSD-3-Clause

\\ Documentation: docs/extensions/expand-dynamic.md

(package shen.x.expand-dynamic [shen]

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

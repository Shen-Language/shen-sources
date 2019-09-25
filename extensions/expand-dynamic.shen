\\ Copyright (c) 2019 Bruno Deferrari.
\\ BSD 3-Clause License: http://opensource.org/licenses/BSD-3-Clause

\\ Documentation: docs/extensions/expand-dynamic.md

(package shen.x.expand-dynamic []

(define initialise
  -> (do (set *external-symbols* [])
         (set *arities* [])))

(define expand-dynamic
  [] -> []
  [[declare Name Sig] | Exps] -> (append (expand-declare [declare Name Sig])
                                         (expand-dynamic Exps))

  \\ Store the external symbols for use in the expansion of lambda forms
  [[put [intern "shen"] shen.external-symbols Symbols PVec] | Exps]
  -> (do (set *external-symbols* (eval-kl Symbols))
         [[put [intern "shen"] shen.external-symbols Symbols PVec]
          | (expand-dynamic Exps)])

  \\ Store arities for use in the expansion of lambda forms
  [[shen.initialise_arity_table Arities] | Exps]
  -> (do (set *arities* (eval-kl Arities))
         [[shen.initialise_arity_table Arities] | (expand-dynamic Exps)])

  [[shen.for-each
     [lambda Entry [shen.set-lambda-form-entry Entry]]
     Entries]
   | Exps]
  -> (append (expand-lambda-entries Entries)
             (expand-dynamic Exps))
  [Exp | Exps] -> [Exp | (expand-dynamic Exps)])

(define expand-declare
  [declare Name Sig]
  -> (let Eval (eval-kl [declare Name Sig])
          F* (concat shen.type-signature-of- Name)
          KlDef (ps F*)
          RecordSig [set shen.*signedfuncs*
                         [cons [cons Name Sig]
                               [value shen.*signedfuncs*]]]
          RecordLambda [shen.set-lambda-form-entry
                        [cons F* (shen.lambda-form F* 3)]]
       [KlDef RecordSig RecordLambda]))

(define expand-lambda-entries
  [] -> []
  [mapcan [lambda X [shen.lambda-form-entry X]] [external [intern "shen"]]]
  -> (mapcan (/. F (expand-lambda-form-entry F))
             (value *external-symbols*))
  [cons [cons X Lambda] Y] -> [[shen.set-lambda-form-entry [cons X Lambda]]
                               | (expand-lambda-entries Y)])

(define get-arity
  Name [] -> -1
  Name [Name Arity | Rest] -> Arity
  Name [_ _ | Rest] -> (get-arity Name Rest))

(define expand-lambda-form-entry
  package -> []
  receive -> []
  F -> (let ArityF (get-arity F (value *arities*))
         (cases (= ArityF -1) []
                (= ArityF 0) []
                true [[shen.set-lambda-form-entry
                        [cons F (shen.lambda-form F ArityF)]]])))

(define split-defuns-h
  [[defun | Defun] | Exps] (@p Defuns Other)
  -> (split-defuns-h Exps (@p [[defun | Defun] | Defuns] Other))
  [Exp | Exps] (@p Defuns Other)
  -> (split-defuns-h Exps (@p Defuns [Exp | Other]))
  [] (@p Defuns Other) -> (@p (reverse Defuns) (reverse Other)))

(define split-defuns
  Exps -> (split-defuns-h Exps (@p [] [])))

(define wrap-in-defun
  Name Args Exprs -> [defun Name Args (to-single-expression Exprs)])

(define to-single-expression
  [Exp] -> Exp
  [Exp | Exps] -> [do Exp (to-single-expression Exps)])

)

\\ Copyright (c) 2026 Bruno Deferrari.  All rights reserved.
\\ BSD 3-Clause License: http://opensource.org/licenses/BSD-3-Clause

\\ Documentation: doc/extensions/type-annotations.md

(package shen.x.type-annotations []

(define annotate-kl
  [defun Name Params Body]
  -> (let Type (function-type Name)
          Table (type-table Type Params)
       [defun Name Params (annotate Params Table Body)])
  KL -> (annotate [] [] KL))

(define function-type
  [_ | _] -> false
  F -> false where (not (symbol? F))
  F -> (let Type (prolog? (shen.lookupsig (receive F) T)
                           (return T))
        (if (= Type false)
            false
            (fst (reify-type Type [])))))

\\ Convert the Prolog variables returned by shen.lookupsig into Shen
\\ variables so the resulting KLambda can be printed and serialised.
(define reify-type
  [X | Xs] Vars
  -> (let First (reify-type X Vars)
          Rest (reify-type Xs (snd First))
       (@p [(fst First) | (fst Rest)] (snd Rest)))
  X Vars
  -> (let Key (<-address X 1)
          Entry (assoc Key Vars)
       (if (empty? Entry)
           (let Var (gensym (protect A))
             (@p Var [[Key | Var] | Vars]))
           (@p (tl Entry) Vars))) where (shen.pvar? X)
  X Vars -> (@p X Vars))

(define type-table
  [A --> B] [X | Xs]
  -> (if (variable? A)
         (type-table B Xs)
         [[X | A] | (type-table B Xs)])
  _ _ -> [])

(define annotate
  Bound Table [type Expression Type] -> [type Expression Type]
  Bound Table [let X Y Z]
  -> [let X (annotate Bound Table Y)
       (annotate [X | Bound] Table Z)]
  Bound Table [lambda X Y]
  -> [lambda X (annotate [X | Bound] Table Y)]
  Bound Table [cond | Cases]
  -> [cond | (annotate-cases Bound Table Cases)]
  Bound Table [F | Args]
  -> (let Type (function-type F)
          CallTable (type-table Type Args)
       [F | (map (/. Arg (annotate Bound
                                   (append Table CallTable)
                                   Arg))
                 Args)])
  Bound Table Atom
  -> (let Entry (assoc Atom Table)
       (cases (cons? Entry) [type Atom (tl Entry)]
              (element? Atom Bound) Atom
              true (atom-type Atom))))

(define annotate-cases
  _ _ [] -> []
  Bound Table [[Test Result] | Cases]
  -> [[(annotate Bound Table Test)
       (annotate Bound Table Result)]
      | (annotate-cases Bound Table Cases)]
  _ _ Cases -> Cases)

(define atom-type
  Atom -> (cases (string? Atom) [type Atom string]
                 (number? Atom) [type Atom number]
                 (boolean? Atom) [type Atom boolean]
                 (symbol? Atom) [type Atom symbol]
                 true Atom))

)

\* Copyright (c) 2012-2019 Bruno Deferrari.  All rights reserved.    *\
\* BSD 3-Clause License: http://opensource.org/licenses/BSD-3-Clause *\

(package shen.x.factorise-cond [%%goto-label %%let-label %%label]

(define factorise-cond
  [cond | Cases] Else -> (inline-mono-labels (rebranch Cases Else))
  X _ -> X)

(define generate-label
  -> (gensym %%label))

(define free-variables
  Body Scope -> (reverse (free-variables-h Body Scope [])))

(define free-variables-h
  [let Var Value Body] Scope Acc -> (free-variables-h Body (remove Var Scope)
                                      (free-variables-h Value Scope Acc))
  [lambda Var Body] Scope Acc -> (free-variables-h Body (remove Var Scope) Acc)
  [X | Xs] Scope Acc -> (free-variables-h Xs Scope
                          (free-variables-h X Scope Acc))
  Var Scope Acc -> (adjoin Var Acc)
      where (element? Var Scope)
  _ _ Acc -> Acc)

(define inline-mono-labels
  [%%let-label Label LabelBody Body]
  -> (let CleanedUpLabelBody (inline-mono-labels LabelBody)
          CleanedUpBody (inline-mono-labels Body)
       (if (> (occurrences [%%goto-label Label] CleanedUpBody) 1)
           [%%let-label Label CleanedUpLabelBody CleanedUpBody]
           (subst CleanedUpLabelBody [%%goto-label Label] CleanedUpBody)))
  [if Test Then Else] -> [if Test (inline-mono-labels Then) (inline-mono-labels Else)]
  [let Var Val Body] -> [let Var Val (inline-mono-labels Body)]
  X -> X)

(define rebranch
  [] Else -> Else
  [[true Result] | _] _ -> Result
  [[[and Test MoreTs] Result] | Cases] Else
  -> (let TrueBranch (true-branch Test [[[and Test MoreTs] Result] | Cases])
          FalseBranch (false-branch Test [[[and Test MoreTs] Result] | Cases])
       (rebranch-h Test TrueBranch FalseBranch Else))
  [[Test Result] | Cases] Else
  -> (let TrueBranch (true-branch Test [[Test Result] | Cases])
          FalseBranch (false-branch Test [[Test Result] | Cases])
      (rebranch-h Test TrueBranch FalseBranch Else)))

(define rebranch-h
  Test TrueBranch FalseBranch Else
  -> (let NewElse (rebranch FalseBranch Else)
       (with-labelled-else NewElse
        (/. GotoElse
         (merge-same-else-ifs
          [if Test
              (optimize-selectors Test (rebranch TrueBranch GotoElse))
              GotoElse])))))

(define true-branch
  Test [[[and Test MoreTs] Result] | Cases]
  -> [[MoreTs Result] | (true-branch Test Cases)]
  Test [[Test Result] | Cases] -> [[true Result]]
  _ _ -> [])

(define false-branch
  Test [[[and Test MoreTs] Result] | Cases] -> (false-branch Test Cases)
  Test [[Test Result] | Cases] -> (false-branch Test Cases)
  _ Cases -> Cases)

(define with-labelled-else
  Atom F -> (F Atom) where (not (cons? Atom))
  [%%goto-label Label] F -> (F [%%goto-label Label])
  Body F -> (let Label (generate-label)
              [%%let-label Label Body
                (F [%%goto-label Label])]))

\\ When an immediate child if-branch has the same
\\ Else as the parent, merge into a single if with (and T1 T2)
(define merge-same-else-ifs
  [if Test1 [if Test2 Then2 Else] Else] -> [if [and Test1 Test2] Then2 Else]
  X -> X)

(define concat/
  A B -> (concat A (concat / B)))

(define exp-var
  [SelF Exp] -> (concat/ (exp-var Exp) SelF)
      where (element? SelF [hd tl hdv tlv fst snd tlstr])
  [hdstr Exp] -> (concat/ (exp-var Exp) hdstr)
  Var -> Var)

(define optimize-selectors
  Test Code -> (bind-repeating-selectors (test->selectors Test) Code))

(define test->selectors
  [cons? X] -> [[hd X] [tl X]]
  [tuple? X] -> [[fst X] [snd X]]
  [string? X] -> [[hdstr X] [tlstr X]]
  [vector? X] -> [[hdv X] [tlv X]]
  _ -> [])

(define bind-repeating-selectors
  [SelA SelB] Body -> (bind-selector SelA (bind-selector SelB Body))
   _ Body -> Body)

(define bind-selector
  Sel Body -> (let Var (exp-var Sel)
                [let Var Sel (subst Var Sel Body)])
      where (> (occurrences Sel Body) 1)
  _ Body -> Body)

)
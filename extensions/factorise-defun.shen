\\ Copyright (c) 2012-2019 Bruno Deferrari.  All rights reserved.
\\ BSD 3-Clause License: http://opensource.org/licenses/BSD-3-Clause

\\ Documentation: docs/extensions/factorise-defun.md

(package shen.x.factorise-defun [%%goto-label %%let-label %%label %%return]

(define factorise-defun
  [defun Name Params [cond | Cases]] -> [defun Name Params
                                          (factorise-cond [cond | Cases]
                                                          [shen.f_error Name]
                                                          Params)]
  X -> X)

(define factorise-cond
  [cond | Cases] Else Scope -> (inline-mono-labels
                                (rebranch (add-returns Cases) Else)
                                Scope)
  X _ _ -> X)

(define add-returns
  [] -> []
  [[Test Body] | Rest] -> [[Test [%%return Body]] | (add-returns Rest)])

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

\\ Attaches free variables to labels and label jumps.
\\ Useful to have these for some compilation strategies.
(define attach-free-variables
  [%%let-label Label LabelBody Body] Scope
  -> (let FreeVars (free-variables LabelBody Scope)
          NewBody (if (= [] FreeVars)
                      Body
                      (subst [%%goto-label Label | FreeVars]
                             [%%goto-label Label]
                             Body))
       [%%let-label [Label | FreeVars] LabelBody
         (inline-mono-labels NewBody Scope)]))

\\ After the transformation there may remain some
\\ labels to which there exists a single jump.
\\ In such cases the label is not necessary.
\\ This function finds such cases and replaces
\\ the jump with the inlined body of the label.
\\ The labels that are not removed are augmented
\\ to include the list of free variables referenced
\\ in the body using `attach-free-variables`.
(define inline-mono-labels
  [%%let-label Label LabelBody Body] Scope
  -> (attach-free-variables
       [%%let-label Label (inline-mono-labels LabelBody Scope) Body]
       Scope)
      where (> (occurrences [%%goto-label Label] Body) 1)

  [%%let-label Label LabelBody Body] Scope
  -> (subst (inline-mono-labels LabelBody Scope)
            [%%goto-label Label]
            (inline-mono-labels Body Scope))

  [if Test Then Else] Scope -> [if Test
                                   (inline-mono-labels Then Scope)
                                   (inline-mono-labels Else Scope)]

  [let Var Val Body] Scope -> [let Var Val
                                (inline-mono-labels Body [Var | Scope])]

  X _ -> X)


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

\\ Generates a new label for some code, except when:
\\ - code is a literal, a variable reference, or (fail)
\\ - code is a goto-label jump
(define with-labelled-else
  [%%return Atom] F -> (F [%%return Atom]) where (not (cons? Atom))
  [fail] F -> (F [fail])
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
  [Sel Exp] -> (concat/ (exp-var Exp) Sel) where (symbol? Sel)
  [Sel | _] -> (gensym Sel)
  Var -> Var)

(define optimize-selectors
  Test Code -> (bind-repeating-selectors (test->selectors Test) Code))

(define test->selectors
  [cons? X] -> [[hd X] [tl X]]
  [tuple? X] -> [[fst X] [snd X]]
  [shen.+string? X] -> [[hdstr X] [tlstr X]]
  [shen.+vector? X] -> [[hdv X] [tlv X]]
  Other <- (apply-selector-handlers (value *selector-handlers*) Other)
  _ -> [])

(define bind-repeating-selectors
  [Sel | Rest] Body -> (bind-selector Sel (bind-repeating-selectors Rest Body))
  [] Body -> Body)

(define bind-selector
  Sel Body -> (let Var (exp-var Sel)
                [let Var Sel (subst Var Sel Body)])
      where (> (occurrences Sel Body) 1)
  _ Body -> Body)

(define apply-selector-handlers
  [] _ -> (fail)
  [Handler | _] Exp <- (Handler Exp)
  [_ | Handlers] Exp -> (apply-selector-handlers Handlers Exp))

(define initialise
  -> (do (set *selector-handlers* [])
         (set *selector-handlers-reg* [])
         done))

(define register-selector-handler
  F -> F where (element? F (value *selector-handlers*))
  F -> (do (set *selector-handlers-reg* [F | (value *selector-handlers*)])
           (set *selector-handlers* [(function F) | (value *selector-handlers*)])
           F))

(define findpos
  Sym L -> (trap-error (shen.findpos Sym L)
                       (/. _ (error "~A is not a selector handler~%" Sym))))

(define unregister-selector-handler
  F -> (let Reg (value *selector-handlers-reg*)
            Pos (findpos F Reg)
            RemoveReg (set *selector-handlers-reg* (remove F Reg))
            RemoveFun (set *selector-handlers* (shen.remove-nth Pos (value *selector-handlers*)))
         F))

)

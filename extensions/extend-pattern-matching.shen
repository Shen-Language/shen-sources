\\ Copyright (c) 2019 Bruno Deferrari.  All rights reserved.
\\ BSD 3-Clause License: http://opensource.org/licenses/BSD-3-Clause

\\ Documentation: docs/extensions/extend-pattern-matching.md

(package shen.x.extend-pattern-matching []

(define register-pattern-handler
  F -> skip where (element? F (value *pattern-handlers-reg*))
  F -> (do (set *pattern-handlers-reg* [F | (value *pattern-handlers-reg*)])
           (set *pattern-handlers* [(function F) | (value *pattern-handlers*)])))

(define apply-pattern-handlers
  [] _ _ _ _ -> (fail)
  [Handler | _] Ref Is? Assign Expr <- (Handler Ref Is? Assign Expr)
  [_ | Handlers] Ref Is? Assign Expr -> (apply-pattern-handlers Handlers Ref Is? Assign Expr))

(define make-stack
  -> (address-> (absvector 1) 0 []))

(define push
  S V -> (address-> S 0 [V | (<-address S 0)]))

(define pop-all
  S -> (let Res (<-address S 0)
            _ (address-> S 0 [])
         Res))

(define compile-pattern
  Patt Handlers OnFail
  -> (let VarsStack (make-stack)
          Ref (protect Self$$7907$$)
          Is? (/. _ ignored)
          Assign (/. Var _ (push VarsStack Var))
          Result (apply-pattern-handlers Handlers Ref Is? Assign Patt)
       (if (= Result (fail))
           (thaw OnFail)
           (compile-pattern-h Patt (reverse (pop-all VarsStack))))))

(define compile-pattern-h
  [Constructor | Args] Vars
  -> (let Compile (/. X (shen.<pattern> X))
          Handler (/. E (error "failed to compile ~A" E))
          NewArgs (map (/. Arg (if (element? Arg Vars)
                                   (compile Compile [Arg] Handler)
                                   Arg))
                       Args)
       [Constructor | NewArgs]))

(define reduce
  [[/. [Constructor | Args] Body] Ref] Handlers
  -> (let SelectorStack (make-stack)
          Is? (/. Expr (shen.add_test Expr))
          Assign (/. Var Expr (push SelectorStack (@p Var Expr)))
          Result (apply-pattern-handlers Handlers Ref Is? Assign [Constructor | Args])
          Vars+Sels (reverse (pop-all SelectorStack))
          Vars (map (function fst) Vars+Sels)
          Selectors (map (function snd) Vars+Sels)
          Abstraction (shen.abstraction_build Vars (shen.ebr Ref [Constructor | Args] Body))
          Application (shen.application_build Selectors Abstraction)
       (shen.reduce_help Application)))

(define initialise
  -> (do (set shen.*custom-pattern-compiler* (/. Arg OnFail (compile-pattern Arg (value *pattern-handlers*) OnFail)))
         (set shen.*custom-pattern-reducer* (/. Arg (reduce Arg (value *pattern-handlers*))))
         (set *pattern-handlers* [])
         (set *pattern-handlers-reg* [])
         done))

)
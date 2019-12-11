\\ Copyright (c) 2019 Bruno Deferrari.  All rights reserved.
\\ BSD 3-Clause License: http://opensource.org/licenses/BSD-3-Clause

\\ Documentation: docs/extensions/programmable-pattern-matching.md

(package shen.x.programmable-pattern-matching []

(define apply-pattern-handlers
  [] _ _ _ _ -> (fail)
  [Handler | _] Self AddTest Bind Patt <- (Handler Self AddTest Bind Patt)
  [_ | Handlers] Self AddTest Bind Patt -> (apply-pattern-handlers Handlers Self AddTest Bind Patt))

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
          Self (protect Self$$7907$$)
          AddTest (/. _ ignored)
          Bind (/. Var _ (push VarsStack Var))
          Result (apply-pattern-handlers Handlers Self AddTest Bind Patt)
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
  [[/. [Constructor | Args] Body] Self] Handlers
  -> (let SelectorStack (make-stack)
          AddTest (/. Expr (shen.add_test Expr))
          Bind (/. Var Expr (push SelectorStack (@p Var Expr)))
          Result (apply-pattern-handlers Handlers Self AddTest Bind [Constructor | Args])
          Vars+Sels (reverse (pop-all SelectorStack))
          Vars (map (function fst) Vars+Sels)
          Selectors (map (function snd) Vars+Sels)
          Abstraction (shen.abstraction_build Vars (shen.ebr Self [Constructor | Args] Body))
          Application (shen.application_build Selectors Abstraction)
       (shen.reduce_help Application)))

(define initialise
  -> (do (set shen.*custom-pattern-compiler* (/. Arg OnFail (compile-pattern Arg (value *pattern-handlers*) OnFail)))
         (set shen.*custom-pattern-reducer* (/. Arg (reduce Arg (value *pattern-handlers*))))
         (set *pattern-handlers* [])
         (set *pattern-handlers-reg* [])
         done))

(define register-handler
  F -> F where (element? F (value *pattern-handlers-reg*))
  F -> (do (set *pattern-handlers-reg* [F | (value *pattern-handlers-reg*)])
           (set *pattern-handlers* [(function F) | (value *pattern-handlers*)])
           F))

(define findpos
  Sym L -> (trap-error (shen.findpos Sym L)
                       (/. _ (error "~A is not a pattern handler~%" Sym))))

(define unregister-handler
  F -> (let Reg (value *pattern-handlers-reg*)
            Pos (findpos F Reg)
            RemoveReg (set *pattern-handlers-reg* (remove F Reg))
            RemoveFun (set *pattern-handlers* (shen.remove-nth Pos (value *pattern-handlers*)))
         F))

)
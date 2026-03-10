\\ Copyright (c) 2019 Bruno Deferrari.  All rights reserved.
\\ BSD 3-Clause License: http://opensource.org/licenses/BSD-3-Clause

\\ Documentation: doc/extensions/programmable-pattern-matching.md

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

(define surface-pattern
  [cons Head Tail] -> [(surface-pattern Head) | (surface-pattern-tail Tail)]
  X -> X)

(define surface-pattern-tail
  [] -> []
  [cons Head Tail] -> [(surface-pattern Head) | (surface-pattern-tail Tail)]
  X -> X)

(define compile-pattern
  Patt Handlers OnFail
  -> (let SurfacePatt (surface-pattern Patt)
          VarsStack (make-stack)
          Self (protect Self$$7907$$)
          AddTest (/. Ignored ignored)
          Bind (/. Pattern Ignored (push VarsStack Pattern))
          Result (apply-pattern-handlers Handlers Self AddTest Bind SurfacePatt)
       (if (= Result (fail))
           (thaw OnFail)
           [@p shen.custom-pattern
               (compile-pattern-h SurfacePatt (reverse (pop-all VarsStack)))])))

(define compile-pattern-h
  [Constructor | Args] Vars
  -> (let NewArgs (map (/. Arg (if (element? Arg Vars)
                                   (shen.compile-pattern-fragment Arg)
                                   Arg))
                       Args)
       [Constructor | NewArgs]))

(define reduce
  (@p Patt Self) Handlers
  -> (let SurfacePatt (surface-pattern Patt)
          TestStack (make-stack)
          SelectorStack (make-stack)
          AddTest (/. Expr (push TestStack Expr))
          Bind (/. Pattern Expr (push SelectorStack (@p Pattern Expr)))
          Result (apply-pattern-handlers Handlers Self AddTest Bind SurfacePatt)
       (if (= Result (fail))
           (fail)
           (@p (reverse (pop-all TestStack))
               (reverse (pop-all SelectorStack))))))

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
  Sym L -> (findpos-h Sym L 1))

(define findpos-h
  Sym [] _ -> (error "~A is not a pattern handler~%" Sym)
  Sym [Sym | _] N -> N
  Sym [_ | L] N -> (findpos-h Sym L (+ N 1)))

(define remove-nth
  N X -> X where (not (and (integer? N) (> N 0)))
  _ [] -> []
  1 [_ | Y] -> Y
  N [X | Y] -> [X | (remove-nth (- N 1) Y)])

(define unregister-handler
  F -> (let Reg (value *pattern-handlers-reg*)
            Pos (findpos F Reg)
            RemoveReg (set *pattern-handlers-reg* (remove F Reg))
            RemoveFun (set *pattern-handlers* (remove-nth Pos (value *pattern-handlers*)))
         F))

)

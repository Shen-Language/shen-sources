\\           Copyright (c) 2010-2019, Mark Tarver

\\                  All rights reserved.

(package shen [u! consp t car cdr t consp stringp numberp null equal eq quote funcall eql]

(define kl-to-lisp
  KL -> (kl-to-lisp-h [] KL))

(define kl-to-lisp-h
   Params Param             -> Param    where (= (u! t) ((u! member) Param Params))
   Params [type X _]        -> (kl-to-lisp-h Params X)
   Params [protect X]       -> (kl-to-lisp-h Params X)
   Params [lambda X Y]      -> (kl-to-lisp-h Params (rectify-t [lambda X Y]))  where (= X (u! t))
   Params [lambda X Y]      -> [(u! function) [(u! lambda) [X] (kl-to-lisp-h [X | Params] Y)]]
   Params [let X Y Z]       -> (kl-to-lisp-h Params (rectify-t [let X Y Z]))  where (= X (u! t))
   Params [let X Y Z]       -> [(u! let) [[X (kl-to-lisp-h Params Y)]] (kl-to-lisp-h [X | Params] Z)]
   _ [defun F Params Code]  -> [(u! defun) F Params (kl-to-lisp-h Params Code)]
   Params [cond | Cond]     -> [(u! cond) | ((u! mapcar) (/. C (cond-code Params C)) Cond)]
   Params [F | X]           -> (let Lisp ((u! mapcar) (/. Y (kl-to-lisp-h Params Y)) [F | X])
                                    (currylisp Lisp))     where (or (= (u! t) ((u! member) F Params)) (cons? F))
   Params [F | X]           -> (let LispX ((u! mapcar) (/. Y (kl-to-lisp-h Params Y)) X)
                                    LispF (maplispsym F)
                                    (optimise-application [LispF | LispX]))     where (fastsymbol? F)
   _ X                      -> X   where (or (number? X) (string? X) (empty? X))
   _ S                      -> [(u! quote) S])

(define rectify-t
  X -> ((u! subst) ((u! gensym) "x") (u! t) X))

(define currylisp
  [F X Y | Z] -> (currylisp [[(u! funcall) F X] Y | Z])
  [F X] -> [(u! funcall) F X]
  [F] -> [(u! funcall) F]
  X -> X)

(define optimise-application
   [hd X]             -> [(u! car) (optimise-application X)]
   [tl X]             -> [(u! cdr) (optimise-application X)]
   [cons X Y]         -> [(u! cons) (optimise-application X) (optimise-application Y)]
   [append X Y]       -> [(u! append) (optimise-application X) (optimise-application Y)]
   [reverse X]        -> [(u! reverse) (optimise-application X)]
   [length X]         -> [(u! list-length) (optimise-application X)]
   [if P Q R]         -> [(u! if) (wrap P) (optimise-application Q) (optimise-application R)]
   [value [Quote X]]  -> X  	       where (= Quote (u! quote))
   [map F X]          -> [(u! mapcar) F X]
   [+ 1 X]            -> [(intern "1+") (optimise-application X)]
   [+ X 1]            -> [(intern "1+") (optimise-application X)]
   [- X 1]            -> [(intern "1-") (optimise-application X)]
   [X | Y]            -> ((u! mapcar) (/. Z (optimise-application Z)) [X | Y])
   X -> X)

(define cond-code
   Params [Test Result] -> (let LispTest (wrap (kl-to-lisp-h Params Test))
                                LispResult (kl-to-lisp-h Params Result)
                                [LispTest LispResult])
   _ _                  -> (simple-error "implementation error in shen.cond-code"))

(define wrap
   [Quote true]                    -> (u! t)                    where (= Quote (u! quote))
   [cons? X]                       -> [(u! consp) X]
   [string? X]                     -> [(u! stringp) X]
   [number? X]                     -> [(u! numberp) X]
   [empty? X]                      -> [(u! null) X]
   [and P Q]                       -> [(u! and) (wrap P) (wrap Q)]
   [or P Q]                        -> [(u! or) (wrap P) (wrap Q)]
   [not P]                         -> [(u! not) (wrap P)]
   [equal? X []]                   -> [(u! null) X]
   [equal? [] X]                   -> [(u! null) X]
   [equal? X [Quote Y]]            -> [(u! eq) X [Quote Y]]      where (and (= Quote (u! quote)) (fastsymbol? Y))
   [equal? [Quote Y] X]            -> [(u! eq) [Quote Y] X]      where (and (= Quote (u! quote)) (fastsymbol? Y))
   [equal? [fail] X]               -> [(u! eq) [fail] X]
   [equal? X [fail]]               -> [(u! eq) X [fail]]
   [equal? S X]                    -> [(u! equal) S X]  where (string? S)
   [equal? X S]                    -> [(u! equal) X S]  where (string? S)
   [equal? N X]                    -> [(u! eql) N X]  where (number? N)
   [equal? X N]                    -> [(u! eql) X N]  where (number? N)
   [equal? X Y]                    -> [shen.ABSEQUAL X Y]
   [greater? X Y]                  -> [> X Y]
   [greater-than-or-equal-to? X Y] -> [>= X Y]
   [less? X Y]                     -> [< X Y]
   [less-than-or-equal-to? X Y]    -> [<= X Y]
   X -> [wrapper X])

(define fastsymbol?
  [_ | _] -> false
  [] -> false
  X -> false   where (string? X)
  X -> false   where (number? X)
  _ -> true)

(define wrapper
   true -> (u! t)
   false -> []
   X -> (simple-error "boolean expected"))

(define maplispsym
    = -> equal?
    > -> greater?
    < -> less?
    >= -> greater-than-or-equal-to?
    <= -> less-than-or-equal-to?
    + -> add
    - -> subtract
    / -> divide
    * -> multiply
    F -> F)     )
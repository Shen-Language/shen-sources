\* Setup must be loaded before the test definitions so the compiler sees
   the custom pattern hooks while compiling them. *\

(load "extensions/programmable-pattern-matching.shen")

(define ppm.two-handler
  Self AddTest Bind [two A B]
  -> (do (AddTest [tuple? Self])
         (Bind A [fst Self])
         (Bind B [snd Self]))
  _ _ _ _ -> (fail))

(shen.x.programmable-pattern-matching.initialise)
(shen.x.programmable-pattern-matching.register-handler ppm.two-handler)

\* Setup must be loaded before the test definitions so the compiler sees
   the custom pattern hooks while compiling them. *\

(load "extensions/programmable-pattern-matching.shen")

(define ppm.two-handler
  Self AddTest Bind [two A B]
  -> (do (AddTest [tuple? Self])
         (Bind A [fst Self])
         (Bind B [snd Self]))
  _ _ _ _ -> (fail))

(define ppm.nothing-handler
  Self AddTest _ [nothing]
  -> (do (AddTest [= Self nothing])
         handled)
  _ _ _ _ -> (fail))

(define ppm.first-handler
  Self AddTest Bind [first X]
  -> (do (AddTest [tuple? Self])
         (Bind X [fst Self])
         handled)
  _ _ _ _ -> (fail))

(shen.x.programmable-pattern-matching.initialise)
(shen.x.programmable-pattern-matching.register-handler ppm.two-handler)
(shen.x.programmable-pattern-matching.register-handler ppm.nothing-handler)
(shen.x.programmable-pattern-matching.register-handler ppm.first-handler)

(datatype ppm.pattern-types
  X : A;
  ======================
  (first X) : (A * B);

  __________________
  (two X Y) : ppm-pair;

  __________________
  (nothing) : symbol;)

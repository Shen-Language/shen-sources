\\ Copyright (c) 2019 Bruno Deferrari.  All rights reserved.
\\ BSD 3-Clause License: http://opensource.org/licenses/BSD-3-Clause

\\ Documentation: docs/extensions/extend-pattern-matching.md

(package shen.x.extend-pattern-matching []

(define valid-constructor?
  [X | Args] -> (= (trap-error (get X constructor-length) (/. _ -1))
                   (length Args))
  _ -> false)

(define register-constructor
  Head Predicate Accessors -> (do (put Head pattern-test Predicate)
                                  (put Head accessors Accessors)
                                  (put Head constructor-length (length Accessors))
                                done))

(define compile-pattern
  [Constructor | Args] -> (let Compile (/. X (<patterns> X))
                               Handler (/. E (error "failed to compile ~A" E))
                            [Constructor | (compile Compile Args Handler)]))

(define reduce
  [[/. [Constructor | Args] Body] A]
  -> (let MkTest (app-form-lambda (get Constructor pattern-test))
          Test (MkTest A)
          AccessorBuilders (map (/. S (app-form-lambda S)) (get Constructor accessors))
          AddTest (shen.add_test Test)
          Abstraction (build-abstraction Args (shen.ebr A [Constructor | Args] Body))
          Application (build-application Abstraction AccessorBuilders A)
       (shen.reduce_help Application)))

(define app-form-lambda
  Sym -> (/. A [Sym A]) where (symbol? Sym)
  F -> F)

(define build-abstraction
  [] Body -> Body
  [Arg | Args] Body -> [/. Arg (build-abstraction Args Body)])

(define build-application
  Abstraction [] _ -> Abstraction
  Abstraction [AB | ABs] A -> [(build-application Abstraction ABs A) (AB A)])

(define driver
  "valid?" Arg -> (valid-constructor? Arg)
  "compile" Arg -> (compile-pattern Arg)
  "reduce" Arg -> (reduce Arg))

(define initialise
  -> (set shen.*custom-patterns-handler* (/. Msg Arg (driver Msg Arg))))

)
\\ Copyright (c) 2019 Bruno Deferrari.  All rights reserved.
\\ BSD 3-Clause License: http://opensource.org/licenses/BSD-3-Clause

\\ Documentation: docs/extensions/extend-pattern-matching.md

(package shen.x.extend-pattern-matching [defpatterns =>]

(define defpatterns-macro
  [defpatterns Name | Rest] -> (construct-register-patterns Name Rest)
  X -> X)

(define construct-register-patterns
  Name [] -> Name
  Name [Var => Body where Test | Rest]
  -> (let Constructor (pattern-constructor Body)
          Head (head Constructor)
          Args (tail Constructor)
          Selectors (shen.cons_form (pattern-selectors Var Args Body))
          TestLambda (if (= true Test) true [lambda Var (shen.rcons_form Test)])
       [do [register-constructor Head TestLambda Selectors]
           (construct-register-patterns Name Rest)])
  Name [Var => Body | Rest] -> (construct-register-patterns
                                 Name [Var => Body where true | Rest])
  Name X -> (error "invalid clause syntax in defpatterns '~A'" Name))

(define pattern-constructor
  [let _ _ Body] -> (pattern-constructor Body)
  [Head | Args] -> [Head | Args] where (and (symbol? Head)
                                            (variables? Args))
  Exp -> (error "Invalid constructor pattern in defpatterns: ~A" Exp))

(define variables?
  [] -> true
  [X | Rest] -> (and (variable? X) (variables? Rest)))

\\ FIXME: match selector order to args order
(define pattern-selectors
  _ [] _ -> []
  Var Args [let Arg Selector Body] -> [[lambda Var (shen.rcons_form Selector)]
                                       | (pattern-selectors Var (remove Arg Args) Body)]
      where (and (element? Arg Args)
                 (valid-selector? Var Selector))
  _ _ Body -> (error "defpatterns: Invalid selector pattern ~A." Body))

(define valid-selector?
  Var [_ | Rest] -> (element? Var Rest)
  Var Var -> true
  _ _ -> false)

(define valid-constructor?
  [X | Args] -> (= (trap-error (get X constructor-length) (/. _ -1))
                   (length Args))
  _ -> false)

(define register-constructor
  Head Predicate Selectors -> (do (put Head pattern-test Predicate)
                                  (put Head selectors Selectors)
                                  (put Head constructor-length (length Selectors))
                                done))

(define compile-pattern
  [Constructor | Args] -> (let Compile (/. X (shen.<patterns> X))
                               Handler (/. E (error "failed to compile ~A" E))
                            [Constructor | (compile Compile Args Handler)]))

(define reduce
  [[/. [Constructor | Args] Body] A]
  -> (let MkTest (app-form-lambda (get Constructor pattern-test))
          Test (MkTest A)
          SelectorBuilders (map (/. S (app-form-lambda S)) (get Constructor selectors))
          AddTest (shen.add_test Test)
          Abstraction (build-abstraction Args (shen.ebr A [Constructor | Args] Body))
          Application (build-application Abstraction (reverse SelectorBuilders) A)
       (shen.reduce_help Application)))

(define app-form-lambda
  true -> (/. _ true)
  let -> (/. A A)
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
  -> (do (set shen.*custom-patterns-handler* (/. Msg Arg (driver Msg Arg)))
         (shen.add-macro defpatterns-macro)))

)
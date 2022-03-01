(maxinferences 1e7)

(report "cartesian product"

    (load "cartprod.shen") loaded
    (cartesian-product [1 2 3] [1 2 3])
                          [[1 1] [1 2] [1 3] [2 1] [2 2] [2 3] [3 1] [3 2] [3 3]])

(report "powerset"

    (load "powerset.shen") loaded
    (powerset* [1 2 3]) [[1 2 3] [1 2] [1 3] [1] [2 3] [2] [3] []])

(report "bubble sort"

  (load "bubble version 1.shen") loaded
  (bubble-sort [1 2 3])  [3 2 1]
  (load "bubble version 2.shen") loaded
  (bubble-sort [1 2 3]) [3 2 1])

(report "spreadsheet"

  (load "spreadsheet.shen") loaded
  (assess-spreadsheet [[jim [wages (/. Spreadsheet (get' frank wages Spreadsheet))]
                             [tax (/. Spreadsheet (* (get' frank tax Spreadsheet) .8))]]
                        [frank [wages 20000]
                               [tax (/. Spreadsheet (* .25 (get' frank wages Spreadsheet)))]]])

              [[jim [wages 20000] [tax 4000.0]] [frank [wages 20000] [tax 5000.0]]]   )

(report "primes"

      (load "prime.shen") loaded
      (prime*? 1000003) true
      (load "mutual.shen") loaded
      (even*? 56) true
      (odd*? 77)  true
      (load "change.shen") loaded
      (count-change 100) 4563)

(report "semantic nets"

    (load "semantic net.shen") loaded
    (clear Mark_Tarver) []
    (clear man) []
    (assert [Mark_Tarver is_a man]) [man]
    (assert [man type_of human]) [human]
    (query [is Mark_Tarver human]) yes)

\\ Prolog

(report "einsteins riddle"

   (load "einsteins-riddle.shen") loaded
   (prolog? (riddle)) german)

(report "Prolog call"

  (load "call.shen") loaded
  (prolog? (mapit (fn consit) [1 2 3] X) (return X))  [[1 1] [1 2] [1 3]]
  (prolog? (different 1 2)) true
  (prolog? (different 1 1)) false)

(report "Prolog cut"

  (load "cut.shen") loaded
  (prolog? (a X) (return X)) 4)

(report "Prolog naive reverse"

  (load  "nreverseprolog.shen") loaded
  (prolog? (nreverse [1 2 3 4] X) (return X))  [4 3 2 1])

(report "findall in Prolog"

  (load "findall.shen") loaded
  (prolog? (fads mark)) [tea chocolate])

(report "Prolog tableau"

  (load  "tableauprolog.shen") loaded
  (prolog? (prop [] [[p <=> q] <=> [q <=> p]]))  true
  (prolog? (prop [] [[p <=> q] <=> [q <=> r]]))  false)

(report "proplog"

     (load "proplog version 1.shen") loaded
     (backchain q [[q <= p] [q <= r] [r <=]]) proved
     (backchain q [[q <= p] [q <= r]]) (fail)
     (load "proplog version 2.shen") loaded
     (backchain q [[q <= p] [q <= r] r]) true
     (backchain q [[q <= p] [q <= r]]) false)

(report "metaprogramming"

    (load "metaprog.shen") loaded
    (do (generate_parser [sent --> np vp  np --> name  np  --> det n
              name --> "John"  name --> "Bill"
              name --> "Tom" det  --> "the"  det  --> "a"
              det  --> "that" det  --> "this"
              n --> "girl"  n --> "ball"
              vp --> vtrans np  vp --> vintrans
              vtrans --> "kicks" vtrans --> "likes"
              vintrans --> "jumps" vintrans --> "flies"]) ok) ok)

(report "binary number datatype"
     (load "binary.shen") loaded
     (complement [1 0]) [0 1]
     (load "streams.shen") loaded
     (fst (delay (@p 0 (+ 1) (/. X false)))) 1)

 (report "calculator"
     (load "calculator.shen") loaded
     (do-calculation [[num 12] + [[num 7] * [num 4]]]) 40 )

(report "structures 1"
    (load "structures-untyped.shen") loaded
    (defstruct ship [length name]) ship
    (make-ship 200 "Mary Rose")  [[structure | ship] [length | 200] [name | "Mary Rose"]]
    (ship-length (make-ship 200 "Mary Rose")) 200
    (ship-name (make-ship 200 "Mary Rose"))  "Mary Rose")

(report "structures 2"
  (load "structures-typed.shen") loaded
  (defstruct ship [(@p length number) (@p name string)]) ship
  (make-ship 200 "Mary Rose")  [[structure | ship] [length | 200] [name | "Mary Rose"]]
  (ship-length (make-ship 200 "Mary Rose")) 200
  (ship-name (make-ship 200 "Mary Rose"))  "Mary Rose")

(report "classes 1"
   (load "classes-untyped.shen") loaded
   (defclass ship [length name]) ship
   (set s (make-instance ship)) [[class | ship] [length | fail] [name | fail]]
   (has-value? length (value s)) false
   (set s (change-value (value s) length 100)) [[class | ship] [length | 100] [name | fail]]
   (get-value length (value s)) 100)

(report "classes 2"
   (load "classes-typed.shen") loaded
   (defclass ship [(@p length number) (@p name string)]) ship
   (has-value? length (make-instance ship)) false
   (change-value (make-instance ship) length 100) [[class | ship] [length | 100] [name | fail]]
   (get-value length (change-value (make-instance ship) length 100)) 100)

 (report "abstract datatypes"
   (load "stack.shen") loaded
   (top (push 0 (empty-stack _))) 0)

 (report "yacc"
   (load "yacc.shen") loaded
   (compile (fn <sent>) [the cat likes the dog]) [the cat likes the dog]
   (trap-error (compile (fn <sent>) [the cat likes the canary]) (/. E (fail))) (fail)
   (compile (fn <asbscs>) [a a a b b c])  [a a a b b c]
   (compile (fn <find-digit>) [a v f g 6 y u]) [6]
   (compile (fn <vp>) [chases the cat]) [chases the cat]
   (compile (fn <des>) [[d] [e e]]) [d e e]
   (compile (fn <sent'>) [the cat likes the dog]) [is it true that your father likes the dog ?]
   (compile (fn <as>) [a a a]) [a a a]
   (compile (fn <find-digit'>) [a v f g 6 y u]) [6 y u]
   (trap-error (compile (fn <asbs'cs>) [a v f g 6 y u]) (/. E (fail))) (fail)
   (compile (fn <find-digit''>) [a v f g 6 y u]) 6
   (compile (fn <anbncn>) [a a a b b b c c c]) [a a a b b b c c c])

(preclude-all-but [])
(tc +)

(report "N Queens"
     (preclude-all-but [])  []
     (tc +) true
     (load "n queens.shen") loaded
     (n-queens 5) [[4 2 5 3 1] [3 5 2 4 1] [5 3 1 4 2] [4 1 3 5 2] [5 2 4 1 3] [1 4 2 5 3]
                    [2 5 3 1 4] [1 3 5 2 4] [3 1 4 2 5] [2 4 1 3 5]]
     (tc -) false)

(report "search"
     (tc +) true
     (load "search.shen") loaded
     (tc -) false)

(report "montague"
     (tc +) true
     (load "montague.shen")  loaded
     (compile (fn <sent>) [Mary likes John]) [likes Mary John])

(report "c-"
     (tc +)  true
     (load "c-minus.shen")  loaded)

(report "L interpreter"
     (tc +) true
     (load "interpreter.shen") loaded
     (normal-form [[[y-combinator [/. ADD [/. X [/. Y [if [= X 0] Y [[ADD [-- X]] [++ Y]]]]]]] 3] 4])  7
     (normal-form [[[y-combinator [/. APPEND [/. X [/. Y
                  [if [= X [ ]] Y  [cons [[/. [cons A B] A] X]
                     	[[APPEND [[/. [cons A B] B] X]] Y]]]]]]] [cons 1 [ ]]] [cons 2 [ ]]])
      [cons 1 [cons 2 []]]
     (tc -) false)

(report "proof assistant"

   (tc +) true
   (load "proof assistant.shen") loaded
   (tc -) false)

(report "quantifier machine"

  (tc +) true
   (load "qmachine.shen") loaded
   (exists [1 (+ 1) (= 100)] (> 50)) true
   (tc -) false)

(report "depth first search"

   (tc +) true
   (load "depth.shen") loaded
   (depth 4 (/. X [(+ X 3) (+ X 4) (+ X 5)]) (/. X (= X 27)) (/. X (> X 27))) [4 7 10 13 16 19 22 27]
   (depth 4 (/. X [(+ X 3)]) (/. X (= X 27)) (/. X (> X 27))) []
   (tc -) false)

(report "secd"

   (tc +) true
   (load "secd1.shen") loaded
   (evaluate [[lambda x x] b]) b
   (evaluate [lambda x x]) [closure [] x x]
   (let If [lambda z [lambda x [lambda y [[z x] y]]]]
        True [lambda x [lambda y x]]
        (evaluate [[[If True] a] b]))  a)

(report "unification"

   (tc -)  false
   (load "unification.shen") loaded
   (unify [f a] X) [[X f a]]
   (unify [f Y] [f b]) [[Y | b]])

(report "total in Prolog"

 (load "totalprolog.shen")  loaded
 (prolog? (findall Age (lived Person Age) Ages)
          (total Ages Total)
          (return Total))   7625)

(report "Prolog fork"

   (load "fork.shen") loaded
   (prolog? (g a))    true)

(report "Prolog interpreter"

   (tc +) true
   (load "prologinterp.shen") loaded
   (tc -) false)

(reset)
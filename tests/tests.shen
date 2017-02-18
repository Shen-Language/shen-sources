(maxinferences 10000000000)

(report
 prolog-tests

 (load "prolog.shen") loaded
 (prolog? (f a)) true
 (prolog? (g a)) false
 (prolog? (g b)) true
 (prolog? (mem 1 [X | 2]) (return X)) 1
 (prolog? (rev [1 2] X) (return X)) [2 1]
 (load "einstein.shen") loaded
 (prolog? (einsteins_riddle X) (return X)) german
 (prolog? (enjoys mark X) (return X)) chocolate
 (prolog? (enjoys willi X) (return X)) chocolate
 (prolog? (fads mark)) [tea chocolate]
 (prolog? (prop [] [p <=> p]))  true
 (prolog? (mapit consit [1 2 3] Out) (return Out)) [[1 1] [1 2] [1 3]]
 (prolog? (different a b)) true
 (prolog? (different a a)) false
 (prolog? (likes john Who) (return Who)) mary
 (load "parse.prl") loaded
 (prolog? (pparse ["the" + ["boy" + "jumps"]]
                  [[s = [np + vp]]
                   [np = [det + n]]
                   [det = "the"]
                   [n = "girl"]
                   [n = "boy"]
                   [vp = vintrans]
                   [vp = [vtrans + np]]
                   [vintrans = "jumps"]
                   [vtrans = "likes"]
                   [vtrans = "loves"]])) true)

\* (report "FPQi chapter 2"
(load "fruit machine.shen") loaded
(do (print (fruit-machine start)) ok) ok) *\


(report
 "FPQi chapter 4"

 (load "cartprod.shen") loaded
 (cartesian-product [1 2 3] [1 2 3])
 [[1 1] [1 2] [1 3] [2 1] [2 2] [2 3] [3 1] [3 2] [3 3]]
 (load "powerset.shen") loaded
 (powerset [1 2 3]) [[1 2 3] [1 2] [1 3] [1] [2 3] [2] [3] []])

(nl 2)

(report
 "FPQi chapter 5"

 (load "bubble version 1.shen") loaded
 (bubble-sort [1 2 3])  [3 2 1]
 (load "bubble version 2.shen") loaded
 (bubble-sort [1 2 3]) [3 2 1]
 \* (load "newton version 1.shen") loaded
 (newtons-method 4) 2
 (load "newton version 2.shen") loaded
 (newtons-method 4) 2 *\
 (load "spreadsheet.shen") loaded
 (assess-spreadsheet [[jim [wages (/. Spreadsheet (get' frank wages Spreadsheet))]
                           [tax (/. Spreadsheet (* (get' frank tax Spreadsheet) .8))]]
                      [frank [wages 20000]
                             [tax (/. Spreadsheet (* .25 (get' frank wages Spreadsheet)))]]])

 [[jim [wages 20000] [tax 4000.0]] [frank [wages 20000] [tax 5000.0]]])

(report
 "FPQi chapter 3"

 (load "prime.shen") loaded
 (prime? 1000003) true
 (load "mutual.shen") loaded
 (even? 56) true
 (odd? 77)  true
 (load "change.shen") loaded
 (count-change 100) 4563)

(report
 "FPQi chapter 6"

 (load "semantic net.shen") loaded
 (clear Mark_Tarver) []
 (clear man) []
 (assert [Mark_Tarver is_a man]) [man]
 (assert [man type_of human]) [human]
 (query [is Mark_Tarver human]) yes)

(report
 "FPQi chapter 7"

 (load "proplog version 1.shen") loaded
 (backchain q [[q <= p] [q <= r] [r <=]]) proved
 (backchain q [[q <= p] [q <= r]]) (fail)
 (load "proplog version 2.shen") loaded
 (backchain q [[q <= p] [q <= r] r]) true
 (backchain q [[q <= p] [q <= r]]) false)

(report
 "FPQi chapter 8"

 (load "metaprog.shen") loaded
 (generate_parser [sent --> np vp  np --> name  np  --> det n
                        name --> "John"  name --> "Bill"
                        name --> "Tom" det  --> "the"  det  --> "a"
                        det  --> "that" det  --> "this"
                        n --> "girl"  n --> "ball"
                        vp --> vtrans np  vp --> vintrans
                        vtrans --> "kicks" vtrans --> "likes"
                        vintrans --> "jumps" vintrans --> "flies"]) [sent np name det n vp vtrans vintrans])

(report
 "chapter 11"

 (load "binary.shen") loaded
 (complement [1 0]) [0 1]
 (load "streams.shen") loaded
 (fst (delay (@p 0 (+ 1) (/. X false)))) 1)

(report
 "strings"

 (load "strings.shen") loaded
 (subst-string "a" "b" "cba") "caa"
 (strlen "123") 3
 (trim-string-left [" "] " hi ") "hi "
 (trim-string-right [" "] " hi ") " hi"
 (trim-string [" "] " hi ") "hi"
 (reverse-string "abc") "cba"
 (alldigits? "123") true)

(report
 "calculator.shen - chapter 11"

 (load "calculator.shen") loaded
 (do-calculation [[num 12] + [[num 7] * [num 4]]]) 40)

(report
 "structures 1 - chapter 12"

 (load "structures-untyped.shen") loaded
 (defstruct ship [length name]) ship
 (make-ship 200 "Mary Rose")  [[structure | ship] [length | 200] [name | "Mary Rose"]]
 (ship-length (make-ship 200 "Mary Rose")) 200
 (ship-name (make-ship 200 "Mary Rose"))  "Mary Rose")

(report "structures 2 - chapter 12"
        (load "structures-typed.shen") loaded
        (defstruct ship [(@p length number) (@p name string)]) ship
        (make-ship 200 "Mary Rose")  [[structure | ship] [length | 200] [name | "Mary Rose"]]
        (ship-length (make-ship 200 "Mary Rose")) 200
        (ship-name (make-ship 200 "Mary Rose")) "Mary Rose")

(report
 "classes 1 - chapter 12"

 (load "classes-untyped.shen") loaded
 (defclass ship [length name]) ship
 (set s (make-instance ship)) [[class | ship] [length | fail] [name | fail]]
 (has-value? length (value s)) false
 (set s (change-value (value s) length 100)) [[class | ship] [length | 100] [name | fail]]
 (get-value length (value s)) 100)

(report
 "classes 2 - chapter 12"

 (load "classes-typed.shen") loaded
 (defclass ship [(@p length number) (@p name string)]) ship
 (has-value? length (make-instance ship)) false
 (change-value (make-instance ship) length 100) [[class | ship] [length | 100] [name | fail]]
 (get-value length (change-value (make-instance ship) length 100)) 100)

(report
 "abstract datatypes - chapter 12"

 (load "stack.shen") loaded
 (top (push 0 (empty-stack _))) 0)

(report
 "yacc"

 (load "yacc.shen") loaded
 (compile (function <sent>) [the cat likes the dog]) [the cat likes the dog]
 (compile (function <sent>) [the cat likes the canary] (/. E (fail))) (fail)
 (compile (function <asbscs>) [a a a b b c])  [a a a b b c]
 (compile (function <find-digit>) [a v f g 6 y u]) [6]
 (compile (function <vp>) [chases the cat]) [chases the cat]
 (compile (function <des>) [[d] [e e]]) [d e e]
 (compile (function <sent'>) [the cat likes the dog]) [is it true that your father likes the dog ?]
 (compile (function <as>) [a a a]) [a a a]
 (compile (function <find-digit'>) [a v f g 6 y u]) [6 y u]
 (compile (function <asbs'cs>) [a v f g 6 y u] (/. E (fail))) (fail)
 (compile (function <find-digit''>) [a v f g 6 y u]) 6
 (compile (function <anbncn>) [a a a b b b c c c]) [a a a b b b c c c])

(preclude-all-but [])
(tc +)

(report
 "N Queens"

 (preclude-all-but [])  []
 (tc +) true
 (load "n queens.shen") loaded
 (n-queens 5) [[4 2 5 3 1] [3 5 2 4 1] [5 3 1 4 2] [4 1 3 5 2] [5 2 4 1 3] [1 4 2 5 3]
               [2 5 3 1 4] [1 3 5 2 4] [3 1 4 2 5] [2 4 1 3 5]]
 (tc -) false)

(report
 "search"

 (tc +) true
 (load "search.shen") loaded
 (tc -) false)

(report
 "whist - chapter 11"

 (tc +) true
 (load "whist.shen") loaded
 (tc -) false)

(report
 "Qi interpreter - chapter 13"

 (tc +) true
 (load "interpreter.shen") loaded
 (tc -) false)

(report "proof assistant - chapter 15"
        (tc +) true
        (load "proof assistant.shen") loaded
        (tc -) false)

(report
 "quantifier machine"

 (tc +) true
 (load "qmachine.shen") loaded
 \* (filter [1 (+ 1) (= 100)] (/. X (integer? (sqrt X)))) [1 4 9 16 25 36 49 64 81] *\
 (exists [1 (+ 1) (= 100)] (> 50)) true
 (tc -) false)

(report
 "depth first search"

 (tc +) true
 (load "depth'.shen") loaded
 (depth' 4 (/. X [(+ X 3) (+ X 4) (+ X 5)]) (/. X (= X 27)) (/. X (> X 27))) [4 7 10 13 16 19 22 27]
 (depth' 4 (/. X [(+ X 3)]) (/. X (= X 27)) (/. X (> X 27))) []
 (tc -) false)

\* (report "red/black trees"
(tc +) true
(load "red-black.shen") loaded) *\

(report
 "Lisp type checker"

 (load "TinyTypes.shen") loaded
 (tc +) true
 (load "TinyLispFunctions.txt") loaded
 (tc -) false)

(reset) 

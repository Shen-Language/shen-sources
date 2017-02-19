(synonyms

 proof  (list step)
 step ((list sequent) * tactic)
 tactic ((list sequent) --> (list sequent))
 sequent ((list wff) * wff))

(datatype globals

  _______________________
  (value *proof*) : proof;)

(define proof-assistant
  {A --> symbol}
  _ -> (let Assumptions (input-assumptions 1)
            Conclusion (input-conclusion _)
            Sequents [(@p Assumptions Conclusion)]
            Proof (time (proof-loop Sequents []))
         (do (nl) proved)))

(define input-assumptions
  {number --> (list wff)}
  N -> (let More? (y-or-n? "~%Input assumptions? ")
         (if More?
             (do (output "~%~A. " N)
                 [(input+ wff) | (input-assumptions (+ N 1))])
             [])))

(define input-conclusion
  {A --> wff}
  _ -> (do (output "~%Enter conclusion: ") (input+ wff)))

(define proof-loop
  {(list sequent) --> proof --> proof}
  [ ] Proof -> (set *proof* (reverse Proof))
  S Proof -> (let Show (show-sequent S (+ 1 (length Proof)))
                  D (user-directive _)
                  Step (@p S D)
               (if (= D back)
                   (proof-loop (go-back Proof) (tail Proof))
                   (proof-loop (D S) [Step | Proof]))))

(define show-proof
  {string --> symbol}
  S -> (show-proof-help (value *proof*) 1))

(define show-proof-help
  {proof --> number --> symbol}
  [ ] _ -> proved
  [(@p Sequents Tactic) | Proof] N -> (do (show-sequent Sequents N)
                                          (output "~%Tactic: ~A~%" Tactic)
                                          (show-proof-help Proof (+ N 1))))

(define show-sequent
  {(list sequent) --> number --> symbol}
  Sequents N -> (let Unsolved (length Sequents)
                     Sequent (head Sequents)
                     Wffs (fst Sequent)
                     Wff (snd Sequent)
                  (do (output "==============================~%")
                      (output "Step ~A     	unsolved ~A~%~%"
                              N Unsolved)
                      (output "?- ~S~%~%" Wff)
                      (enumerate Wffs 1))))

(define enumerate
  {(list A) --> number --> symbol}
  [] _ -> _
  [X | Y] N -> (do (output "~A. ~S~%" N X) (enumerate Y (+ N 1))))

(define user-directive
  {A --> tactic}
  _ -> (do (output "~%Tactic: ") (input+ tactic)))

(define back
  {(list sequent) --> (list sequent)}
  S -> S)

(define go-back
  {proof --> (list sequent)}
  [(@p S _) | _] -> S)

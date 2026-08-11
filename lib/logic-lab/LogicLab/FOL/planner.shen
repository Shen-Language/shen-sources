(datatype add-hammer

  _____________________________________
  (fn sledgehammer) : (step --> step);)

(defmacro compose-macro
 [compose F G H | X] -> [compose F [compose G H]])

(define use-planner
  {step --> step}
   Step -> ((planner Step) Step))
                 
(define planner
  {(list sequent) --> (step --> step)}
  [] -> (/. X X)
  [(@p Ass P) | S]                      -> (let N*Terms*Q    (def (head S))     where (defined? Ass P)
                                                N            (fst N*Terms*Prop)
                                                Terms        (fst (snd Prop))
                                                Q            (snd (snd Prop))
                                                (compose     (unfold-plan Terms N) 
                                                             (plan [(@p Ass Q) | S])))   
  [(@p Ass [P & Q]) | S] -> (compose (fn &r) [(@p Ass P) (@p Ass Q) | S])
  [(@p Ass [P => Q])     -> (compose (fn =>r) (planner (@p [P | Ass] Q)))
  [_ | Ss]               -> (compose (fn (sledgehammer)) (planner S)))
  
(define compose
  {(B --> C) --> (A --> B) --> (A --> C)}
    F G -> (/. X (F (G X))))  
  
(define defined?
  {(list prop) --> boolean}
   Ass P -> (trap-error (do (def Ass P 1) true) (/. E false)))  
  
(define def
  {(list prop) --> prop --> (number * (list term) * prop)}
   _ _         -> (abort)
   [Q | Ass] P N -> (trap-error (@p N (defh P P Q [])) (/. E (def Ass P (+ N 1)))) 
                       
(define defh
 {prop --> prop --> prop --> (list term) --> ((list term) * prop)}
  _ P [P <=> Q] Terms          -> (@p Terms Q)
  [F X | Xs] P [all Y Q] Terms -> [X | (defh [F Xs] P (replace Y X Q))]
  _ _ _                        -> (abort))
  
(define unfold-plan
  {(list term) --> number --> step --> step}
    Terms N Step -> (let Swap    (swap 1 N Step)
                         AllLeft (multiple-all-l Terms Swap)
                         EqLeft  (<=>l AllLeft)
                         AndLeft (&l   EqLeft)
                         ImpLeft (=>l  AndLeft)
                         (thin-n-times (+ 2 (length Terms)))))
                         
(define thin-n-times
  {number --> step --> step}
   0 Step -> Step
   N Step -> (thin-n-times (- N 1) (thin 1 Step))) 
   
(define sledgehammer
  {(list sequent) --> (list sequent)}
   [(@p Ass P) | S] -> (let KB     (kb-> Ass)
                            Query? (<-kb P)
                            (if Query?
                                S
                                [(@p Ass P) | S])))
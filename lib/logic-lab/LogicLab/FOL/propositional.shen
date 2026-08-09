(package fol (fol-external-symbols)

(define exchange
  {number --> number --> (list A) --> (list A)}
   M N X -> (exchange-h M N X)   where (and (integer? M)
                                            (> M 0)
                                            (integer? N)
                                            (> N 0)
                                            (>= (length X) M)
                                            (>= (length X) N))
   _ _ X -> X)

(define exchange-h 
  {number --> number --> (list A) --> (list A)}
   M N X -> X     where (or (= M 0) (= N 0))
   M N X -> X     where (or (> M (length X)) (> N (length X)))
   1 N [X | Y] -> (let Z (nth N [X | Y])
                            [Z | (insert-nth X (- N 1) Y)])
   M 1 [X | Y] -> (let Z (nth M [X | Y])
                            [Z | (insert-nth X (- M 1) Y)])
   M N [X | Y] -> [X | (exchange-h (- M 1) (- N 1) Y)])

(define remove-nth
  {number --> (list A) --> (list A)}
  N X -> X  	where (not (natural? N))
  _ [] -> []
  1 [_ | Y] -> Y
  N [X | Y] -> [X | (remove-nth (- N 1) Y)])

(define insert-nth
  {A --> number --> (list A) --> (list A)}
   X 1 [_ | Y] -> [X | Y]
   X N [Y | Z] -> [Y | (insert-nth X (- N 1) Z)]) 
   
(d-rule hyp ()
   
     ______________
     P >> P;)
   
   (d-rule vr1 ()

     P;
     ______________
     [P v Q];)
   
   (d-rule vr2 ()

     Q;
     ______________
     [P v Q];)
   
   (d-rule vl ()

     Q >> P;
     R >> P;
     ______________
     [Q v R] >> P;)
   
   (d-rule &r ()
   
      P; Q;
      _____
      [P & Q];)
    
    (d-rule &l ()
    
      P, Q >> R;
      __________
      [P & Q] >> R;)
      
    (d-rule =>r ()
    
      P >> Q;
      _______
      [P => Q];)
      
     (d-rule =>l ()
     
       [P => Q] >> P;
       ______________
       [P => Q] >> Q;)
       
     (d-rule <=>r ()
     
       [[P => Q] & [Q => P]];
       ______________________
       [P <=> Q];)
       
     (d-rule <=>l ()
     
       [[P => Q] & [Q => P]] >> R;
       ______________________
       [P <=> Q] >> R;) 
       
     (d-rule ~r ()
     
       [P => falsum];
       ______________
       [~ P];)
       
     (d-rule ~l ()
     
       [P => falsum] >> Q;
       ______________
       [~ P] >> Q;)                
   
     (d-rule lemma (Q : prop)
   
       Q;
       Q >> P;
       _______
       P;)

      (d-rule lem (P : prop)

      [P v [~ P]] >> Q;
       ______________
       Q;)
       
     (d-rule exp ()
      
       falsum;
       _______
       P;)       
     
     (d-rule thin (N : number)
     
      let Hypotheses (remove-nth N Hypotheses)
      P;
      _________________________________________
      P;)
            
      (d-rule swap (M : number N : number)
      
        let Hypotheses (exchange M N Hypotheses)
        P;
        _________________________________________
        P;))
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
        P;)   

    (d-rule =r ()
      
       _______
       [X = X];)
        
      (d-rule =l ()
      
       let PX/Y (subst X Y P)
       [X = Y] >> PX/Y;
       ________________________
       [X = Y] >> P;)       
           
     (d-rule alll (T : term)
      
       let PX/T (subst T X P)
       PX/T, [all X P] >> Q;
       ________________________
       [all X P] >> Q;)
       
     (d-rule allr (T : term)
      
       if (= (occurrences T [[all X P] | Hypotheses]) 0)
       let PX/T (subst T X P)
       PX/T;
       ________________________
       [all X P];)
       
      (d-rule existsl (T : term)
      
       if (= (occurrences T [Q [exists X P] | Hypotheses]) 0)
       let PX/T (subst T X P)
       PX/T >> Q;
       ________________________
       [exists X P] >> Q;)
       
     (d-rule existsr (T : term)
      
       let PX/T (subst T X P)
       PX/T;
       ________________________
       [exists X P];)  
       
      (d-rule mathind ()
  
        let Base (subst 0 X P)
        let Psucc (subst [succ X] X P)  
        let Inductive [all X [P => Psucc]]
        Base; 
        Inductive;
        __________
        [all X P];)
        
       (d-rule listind ()
  
        let Base (subst [] X P)
        let Pcons (subst [cons y X] X P)
        let Inductive [all X [all y [P => Pcons]]]
        Base; 
        Inductive;
        ___________
        [all X P];)
        
 (d-rule nn1 ()
  
          [all x [[pred [succ x]] = x]] >> P;
          ___________________________________
          P;)
    
  (d-rule nn2 ()
  
          [all x [[~ [x = 0]] => [[succ [pred x]] = x]]] >> P;
          ____________________________________________________
          P;)
    
  (d-rule nn3 ()
  
        [all x [~ [[succ x] = 0]]] >> P;
        ________________________________
        P;)
    
   (d-rule nn4 ()
  
        [all x [all y [[[succ x] = [succ y]] => [x = y]]]] >> P;
        ________________________________________________________
        P;)    
        
   (d-rule l1 (Z : term)
   
    [all x [all y [~ [Z = [cons x y]]]]] >> P;
    ____________________________________________
    P;)
    
   (d-rule l2 ()
   
    [all x [all y [~ [[cons x y] = x]]]] >> P;
    ____________________________________________
    P;) 
    
   (d-rule l3 ()
   
    [all x [all y [~ [[cons x y] = y]]]] >> P;
    __________________________________________
    P;) 
    
    (d-rule l4 ()
   
    [all x [all y [[hd [cons x y]] = x]]] >> P;
    ____________________________________________
    P;) 
    
    (d-rule l5 ()
   
    [all x [all y [[tl [cons x y]] = y]]] >> P;
    ____________________________________________
    P;) 
    
    (d-rule l6 ()
      
      [all x [all y [all w [all z [[[cons x y] = [cons w z]] => [[x = w] & [y = z]]]]]]] >> P;
      ________________________________________________________________________________________
      P;)    
      
     (d-rule thorn ()
     
        let KB (kb-> [[all x [all y [[call-typechecker x y] => [x : y]]]] | Hypotheses])
        if (<-kb P)
        ___________
         P;)  
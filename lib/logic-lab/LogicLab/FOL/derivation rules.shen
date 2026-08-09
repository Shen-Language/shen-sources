(package fol (fol-external-symbols)

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
 ________
  P;)
            
 (d-rule swap (M : number N : number)
      
   let Hypotheses (exchange M N Hypotheses)
   P;
   ____________
   P;)
        
(d-rule allr (T : term)

   let PT/X (replace X T P)
   if (fresh? T Hypotheses)
   if (fresh? T [all X P])

   PT/X;
   _______
  [all X P];)  
  
(d-rule alll (T : term)

   let PT/X (replace X T P)
   
   PT/X, [all X P] >> Q;
   _______
   [all X P] >> Q;)
   
(d-rule existsr (T : term)

   let PT/X (replace X T P)
   
   PT/X;
   _______
  [exists X P];)	
  
(d-rule existsl (T : term)

   let PT/X (replace X T P)
   if (fresh? T Hypotheses)
   if (fresh? T [exists X P]) 

   PT/X >> Q;
   _______________
   [exists X P] >> Q;)

(d-rule =r ()

  _____
  [T = T];)	
  
(d-rule =l ()

   let P* (replace* S T P)

  [S = T] >> P*;
  _____
  [S = T] >> P;))


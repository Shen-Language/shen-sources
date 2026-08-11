(package fol (fol-external-symbols)

     (d-rule indirect-proof ()
     
        [~ P] >> P;
        ____________
        P;)
        
      (d-rule contradiction ()
     
        ____________
        [~ P], P >> Q;)        
        
     (d-rule demorgan1 () 
     
       [[~ P] & [~ Q]] >> R;
       _____________________
       [~ [P v Q]] >> R;)
       
     (d-rule demorgan2  ()
     
       [[~ P] v [~ Q]] >> R;
       _____________________
       [~ [P & Q]] >> R;)
       
     (d-rule dn ()
     
       P >> Q;
       _______
       [~ [~ P]] >> Q;)             

     (d-rule ~=> ()
     
       [P & [~ Q]] >> R;
       _______
       [~ [P => Q]] >> R;)
       
     (d-rule ~<=> ()
     
       [[~ [P => Q]] v [~ [Q => P]]] >> R;
       _______
       [~ [P <=> Q]] >> R;)
         
     (d-rule vl ()

       P >> R;
       Q >> R;
       ______________
       [P v Q] >> R;)   
        
      (d-rule &l ()
      
        P, Q >> R;
        __________
        [P & Q] >> R;)      
           
       (d-rule =>l ()
       
         [[~ P] v Q] >> R;
         ______________
         [P => Q] >> R;)
            
       (d-rule <=>l ()
       
         [[P => Q] & [Q => P]] >> R;
         ______________________
         [P <=> Q] >> R;)
  
      (d-rule alll (T : term)

         let PT/X (replace X T P)
         
         PT/X, [all X P] >> Q;
         _______
         [all X P] >> Q;)
        
      (d-rule existsl (T : term)

         let PT/X (replace X T P)
         if (fresh? T Hypotheses)
         if (fresh? T [exists X P]) 

         PT/X >> Q;
         _______________
         [exists X P] >> Q;)
         
                  
        (d-rule clause-form ()

          let Hypotheses (mapcan (fn clauses) Hypotheses)
          P;
          _____________
          P;) 
          
        (d-rule amplified-clause-form (N : number)
        
           let Hypotheses (mapcan (amplify-clauses N) Hypotheses)    
           P;
          _____________
          P;)
          
        (d-rule contradiction+ ()
        
               let MGU (unify P Q)
               if (defined? MGU)
               let Sequents (deref-sequents Sequents MGU)
                ____________
               [~ P], Q >> R;)
   )


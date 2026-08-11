(datatype prop

 _______________
 [X : A] : prop;)
 
(s-rule hyp ()

  if (or (variable? X) (variable? Y))
  let Sequents (if (variable? X) (assign Y X Sequents) (assign X Y Sequents) )
  ______________________________________________________________________
  [X : A] >> [Y : A];)
   
(s-rule ->r ()

  let Y (newv)
  let Z (newv)
  let Sequents (assign X [/. Y Z] Sequents)
  [Y : A] >> [Z : B];  
  _______________
  [X : [A --> B]];)  
  
(s-rule ->l (A : prop)

  let Y (newv)
  let Z (newv)
  let Sequents (assign X [Y Z] Sequents)
  [Y : [A --> B]];
  [Z : A];
  ____________
  [X : B];)
  
(s-rule &r ()

 let Y (newv)
 let Z (newv)
 let Sequents (assign X [@p Y Z] Sequents)
 [Y : A];
 [Z : B]; 
 ____________ 
 [X : [A & B]];) 
 
 (s-rule &l1 (B : prop)
 
 let Y (newv)
 let Sequents (assign X [fst Y] Sequents)
 [Y : [A & B]];
 ______________
 [X : A];)
 
 (s-rule &l2 (A : prop)
 
 let Y (newv)
 let Sequents (assign X [snd Y] Sequents)
 [Y : [A & B]]; 
 ______________
 [X : B];)
 
 (s-rule lemma (A : symbol)
 
  let Y (newv)
  [Y : A];
  [Y : A] >> [X : B];
  ___________________
  [X : B];)
 
 (s-rule vr1 ()
 
   let Y (newv)   
   let Sequents (assign X [@p 0 Y] Sequents)
   [Y : P];
   _____________
   [X : [P v Q]];)
   
 (s-rule vr2 ()
 
   let Y (newv)
   let Sequents (assign X [@p 1 Y] Sequents)   
   [Y : Q];
   _____________
   [X : [P v Q]];)  
   
 (s-rule vl (A : prop B : prop)
 
   let W (newv)
   let Y (newv)
   let Z (newv)
   let Sequents (assign X [cases W Y Z] Sequents)
   [W : [A v B]];
   [Y : [A --> C]];
   [Z : [B --> C]];
   ________________
   [X : C];)
   
   (s-rule ~r ()
   
     [X : [A --> falsum]];   
     _____________________
     [X : [~ A]];)
     
   (s-rule ~l ()
   
     [X : [A --> falsum]] >> P;   
     _____________________
     [X : [~ A]] >> P;)   
     
   (s-rule exp ()
   
     let Y (newv)
     let Sequents (assign X [abort Y] Sequents)
     [Y : falsum];
     ___________
     [X : P];)  
     
    (s-rule existsr (Witness : symbol)
    
      let Z (newv)
      let Sequents (assign X [@p Witness Z] Sequents)
      let BWitness/Y (subst Witness Y B)
      Witness : A;
      Z : BWitness/Y;
      _______________________
      [X : [exists Y : A B]];) 
      
    (s-rule existsl ()    
     
     let Sequents (assign X [fst Y] Sequents)
     [X : A], [Y : [exists Z : A B]] >> P;
     ________________________________________
     [Y : [exists Z : A B]] >> P;)
    
    (s-rule existsl2 ()    
     
     let C (subst [fst X] Z B)
     let Z (newv)
     Y : C, [X : [exists Z : A B]] >> P;
     __________________________________________
     [X : [exists Z : A B]] >> P;)
     
     
     (s-rule existsl1 ()    
     
     [Witness : A], [[@p Witness Y] : [exists Z : A B]] >> P;
     __________________________________________
     [[@p Witness Y] : [exists Z : A B]] >> P;)
    
    (s-rule existsl2 ()    
     
     let C (subst Witness Z B)
     Y : C, [[@p Witness Y] : [exists Z : A B]] >> P;
     __________________________________________
     [X : [exists Z : A B]] >> P;)
 
 (s-rule env ()
 
   if (variable? X)
   let Sequents (map (/. S (deref X Y S)) Sequents)
   ________________________________________________
   [X <-- Y];)
   
(define deref
  X Y (@p Hyp P) -> (@p (subst Y X Hyp) (subst Y X P)))      
    
(define assign
   Var Val [] -> [(@p [] [Var <-- Val])]
   Var Val [(@p Hyp [Var* <-- Val*]) | Sequents] 
   -> [(@p [] [Var <-- Val]) (@p Hyp [Var* <-- Val*]) | Sequents]
   Var Val [Sequent | Sequents] -> [Sequent | (assign Var Val Sequents)])
(datatype prop

 _______________
 [X : A] : prop;
 
 ______________
 X : any;)
 
(s-rule hyp ()

  if (or (variable? X) (variable? Y) (= X Y))
  let Sequents (cases (= X Y) Sequents
                      (variable? X) (assign X Y Sequents) 
                      true (assign Y X Sequents))
  ______________________________________________________________________
  [X : A] >> [Y : A];)
   
(s-rule -->r ()

  let Y (newv)
  let Z (newv)
  let Sequents (assign X [/. Y Z] Sequents)
  [Y : A] >> [Z : B];  
  _______________
  [X : [A --> B]];)  
  
(s-rule -->l ()

  let Y (newv)
  let Z (newv)
  let Sequents (assign X [Y Z] Sequents)
  [Y : [A --> B]] >> [Z : A];
  ____________
  [Y : [A --> B]] >> [X : B];)
  
(s-rule &r ()

 let Y (newv)
 let Z (newv)
 let Sequents (assign X [@p Y Z] Sequents)
 [Y : A];
 [Z : B]; 
 ____________ 
 [X : [A & B]];) 
 
 (s-rule &l () 
 
 let Y (newv)
 let Z (newv)
 let Sequents (assign Y [fst X] Sequents)
 let Sequents (assign Z [snd X] Sequents) 
 [Y : A], [Z : B] >> P;
 _______________________
 [X : [A & B]] >> P;)
  
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
   
 (s-rule vl ()
 
   let Y (newv)
   let Z (newv)
   let Sequents (assign X [cases W Y Z] Sequents)
   [Y : [A --> C]];
   [Z : [B --> C]];
   ________________
   [W : [A v B]] >> [X : C];)
   
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
     
    (s-rule existsr (Witness : any)
    
      let Z (newv)
      let BWitness/Y (subst Witness Y B)
      let Sequents (assign X [@p Witness Z] Sequents)
      [Witness : A];
      [Z : BWitness/Y];
      _______________________
      [X : [exists Y : A B]];)
    
    (s-rule existsl ()    
     
     let C (subst [fst Y] Z B)
     let W (newv)
     let X (newv)
     [[fst Y] : A], [[snd Y] : C] >> P;
     ________________________________________
     [Y : [exists Z : A B]] >> P;) 
     
     (s-rule allr ()
     
       let T (gensym t)
       let Z (newv)
       let BT/Y (subst T Y B) 
       let Sequents (assign Z [X T] Sequents)
       [T : A] >> Z : BT/Y;
       ____________________
       [X : [all Y : A B]];)
       
      (s-rule alll (T : any)     
       
       let Z (newv)
       let BT/Y (subst T Y B) 
       let Sequents (assign Z [X T] Sequents)
       [X : [all Y : A B]] >> [T : A];
       [Z : BT/Y], [X : [all Y : A B]] >> P;
       _____________________________________
       [X : [all Y : A B]] >> P;)   
 
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
   Var Val [Sequent | Sequents] -> [(deref Var Val Sequent) | (assign Var Val Sequents)])
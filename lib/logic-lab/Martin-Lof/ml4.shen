(datatype prop

 _______________
 [X : A] : prop;
 
 ______________
 X : any;)
 
(s-rule hyp1 ()

  ________
  P >> P;)
  
(s-rule hyp2 ()

  if (variable? X)  
  [X <-- Y];
  ___________________
  [X : A] >> [Y : A];) 
  
(s-rule hyp3 ()

  if (variable? Y)
  [Y <-- X];
  ___________________
  [X : A] >> [Y : A];) 
  
(s-rule hyp

  let Var (cases (= X Y) X
                 (variable? X) X
                 (variable? Y) Y
                 true void)
  if (not (= Var Void))
  let Val (if (= Var X) Y X)
  [Var <-- Val];
 ___________________
  [X : A] >> [Y : A];)         
  
(s-rule -->r ()

  let Y (newv)
  let Z (newv)
  [Y : A] >> [Z : B]; 
  [X <-- [/. Y : A Z]]; 
  ___________________
  [X : [A --> B]];)  
  
(s-rule -->l ()

  let Z (newv)
  [Y : [A --> B]] >> [Z : A];
  [X <-- [Y Z]];
  ___________________________
  [Y : [A --> B]] >> [X : B];)
  
(s-rule &r ()

 let Y (newv)
 let Z (newv)
 [Y : A];
 [Z : B]; 
 [X <-- [@p Y Z]];
 ____________ 
 [X : [A & B]];) 
 
 (s-rule &l () 
 
 let Y (newv)
 let Z (newv)
 [Y : A], [Z : B] >> P;
 [Y <-- [fst X]];
 [Z <-- [snd X]];
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
   [Y : P];
   [X <-- [@p 0 Y]];
   _____________
   [X : [P v Q]];)
   
 (s-rule vr2 ()
 
   let Y (newv)
   [Y : Q];
   [X <-- [@p 1 Y]];
   _____________
   [X : [P v Q]];)  
   
 (s-rule vl ()
 
   let Y (newv)
   let Z (newv)
   [Y : [A --> C]];
   [Z : [B --> C]];
   [X <-- [cases W Y Z]];
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
     [Y : falsum];
     [X <-- [abort Y]];
     ___________
     [X : P];)  
     
    (s-rule existsr (Witness : any)
    
      let Z (newv)
      let BWitness/Y (subst Witness Y B)
      [Witness : A];
      [Z : BWitness/Y];
      [X <-- [@p Witness Z]];
      _______________________
      [X : [exists Y : A B]];)
    
    (s-rule existsl ()    
     
     let X (newv)
     let Fst (newv)
     let Snd (newv)
     let App (newv)
     let C (subst [fst Y] Z B)
     [Fst : A], [App : C] >> P;
     [Fst <-- [fst Y]];
     [Snd <-- [snd Y]];
     [App <-- [Snd Fst]];
     ________________________________________
     [Y : [exists Z : A B]] >> P;)  
     
     (s-rule existsl ()    
     
     let C (subst [fst Y] Z B)
     [[fst Y] : A], [[[snd Y] [fst Y]] : C] >> P;
     ________________________________________
     [Y : [exists Z : A B]] >> P;) 
       
       (s-rule allr ()
     
       let T (gensym t)
       let Z (newv)
       let BT/Y (subst T Y B) 
       [T : A] >> [Z : BT/Y];
       [X <-- [/. T : A Z]];
       ____________________
       [X : [all Y : A B]];) 
       
      (s-rule alll (T : any)     
       
       let Z (newv)
       let BT/Y (subst T Y B) 
       [X : [all Y : A B]] >> [T : A];
       [Z : BT/Y], [X : [all Y : A B]] >> P;
       [Z <-- [X T]];
       _____________________________________
       [X : [all Y : A B]] >> P;) 
       
      (s-rule zeroax ()
      
        ____________
        [0 : natnum];)
        
      (s-rule succax ()
      
         [N : natnum];
         ___________
         [[s N] : natnum];)
         
      (s-rule mathind ()
      
         let C (newv)
         let F (newv)
         let N (newv)
         let Base (subst 0 Y P)
         let Inductive [all Y : natnum [P --> (subst [s Y] Y P)]]
         [C : Base];
         [F : Inductive];
         [X <-- [/. N : natnum [prim N C F]]];
         ______________________________
         [X : [all Y : natnum P]];)
            
      (s-rule plus-base ()
      
        let Y (newv)
        [X : natnum];
        [Z <-- [/. Y Y]];
        ____________________
        [Z : [plus 0 X X]];) 

           
       (s-rule plus-induct ()
       
       let W (newv)
       [W : [plus X [s Y] Z]];
       [Ws <-- [f W]];
       _______________________
       [Ws : [plus [s X] Y Z]];)
       
       (s-rule env ()
 
         let Sequents (deref-sequents Sequents [X <-- Y])   
         _______________________________________
         [X <-- Y];)
       
 (define s
   {number --> number}
   N -> (+ N 1))
          
 (define prim
  {number --> A --> (number --> A --> A) --> A}
  0 C F -> C
  X C F -> (F X (prim (- X 1) C F)))
  
 (define f
  {number --> number --> number}
   X Y -> (s Y))
       
 (define deref-sequents
   Stack [X <-- Y] -> (map (/. S (deref-sequent X Y S)) Stack))
   
 (define deref-sequent
   X Y (@p Hyp [Z <-- W]) -> (@p (subst Y X Hyp) [Z <-- (subst Y X W)])
   X Y (@p Hyp P) -> (@p (subst Y X Hyp) (subst Y X P))) 
      
 (define add
   {number --> number --> number}
M N -> (let Add  (/. X14411 
  (prim X14411
   (/. T14412 
    (@p T14412 (/. X X)))
   (/. T14419 
    (/. X14421 
     (/. T14423 (@p
       (fst
        (X14421
         (s T14423)))
       (f ((snd
         (X14421
          (s T14423)))
        (fst
         (X14421
          (s T14423)))))))))))
          (fst (Add M N))))
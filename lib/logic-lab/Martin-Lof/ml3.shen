(datatype prop

 _______________
 [X : A] : prop;
 
 ______________
 X : any;)
 
(s-rule hyp ()

  let Stack (unify X Y Stack)
  __________________________________
  [X : A] >> [Y : A];)
  
(s-rule -->r ()

  let Y (newv)
  let Z (newv)
  let Stack (unify X [/. Y : A Z] Stack)
  [Y : A] >> [Z : B];  
  ___________________
  [X : [A --> B]];)  
  
(s-rule -->l ()

  let Z (newv)
  let Stack (unify X [Y Z] Stack)
  [Y : [A --> B]] >> [Z : A];
  ___________________________
  [Y : [A --> B]] >> [X : B];)
  
(s-rule &r ()

 let Y (newv)
 let Z (newv)
 let Stack (unify X [@p Y Z] Stack)
 [Y : A];
 [Z : B]; 
 ____________ 
 [X : [A & B]];) 
 
 (s-rule &l () 
 
 let Y (newv)
 let Z (newv)
 let Stack (unify Y [fst X] Stack)
 let Stack (unify Z [snd X] Stack) 
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
   let Stack (unify X [@p 0 Y] Stack)
   [Y : P];
   _____________
   [X : [P v Q]];)
   
 (s-rule vr2 ()
 
   let Y (newv)
   let Stack (unify X [@p 1 Y] Stack)   
   [Y : Q];
   _____________
   [X : [P v Q]];)  
   
 (s-rule vl ()
 
   let Y (newv)
   let Z (newv)
   let Stack (unify X [cases W Y Z] Stack)
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
     let Stack (unify X [abort Y] Stack)
     [Y : falsum];
     ___________
     [X : P];)  
     
    (s-rule existsr (Witness : any)
    
      let Z (newv)
      let BWitness/Y (subst Witness Y B)
      let Stack (unify X [@p Witness Z] Stack)
      [Witness : A];
      [Z : BWitness/Y];
      _______________________
      [X : [exists Y : A B]];)
    
    (s-rule existsl ()    
     
     let X (newv)
     let C (subst [fst Y] Z B)
     let Stack (unify X [[snd Y] [fst Y]])
     [[fst Y] : A], [[[snd Y] [fst Y]] : C] >> P;
     ________________________________________
     [Y : [exists Z : A B]] >> P;) 
     
     (s-rule allr ()
     
       let T (gensym t)
       let Z (newv)
       let BT/Y (subst T Y B) 
       let Stack (unify Z [X T] Stack)
       [T : A] >> [Z : BT/Y];
       ____________________
       [X : [all Y : A B]];)
       
      (s-rule alll (T : any)     
       
       let Z (newv)
       let BT/Y (subst T Y B) 
       let Stack (unify Z [X T] Stack)
       [X : [all Y : A B]] >> [T : A];
       [Z : BT/Y], [X : [all Y : A B]] >> P;
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
         let Stack (unify X [/. N [prim N C F]] Stack)
         [C : Base];
         [F : Inductive];
         ______________________________
         [X : [all Y : natnum P]];)  
         
         
      (s-rule plus-base ()

        ___________________________
        [[trivial : [plus X 0 X]]];)

      (s-rule plus-induct ()

       [A : [plus X Y Z]];
       _______________________
       [A : [plus X [succ Y] [succ Z]]];)        
 
 (s-rule env ()
 
   let Stack (subst-term Y X Stack)
   ________________________________
   [X <-- Y];)
   
 (define subst-term
   _ _ [] -> []
   X Y [(@p Hyps P) | Sequents] -> [(@p (subst X Y Hyps) (subst X Y P)) | (subst-term X Y Sequents)]) 

(define unify
   X X Stack -> Stack
   X Y Stack -> (deref-stack (assign X Y Stack))  where (variable? X)
   X Y Stack -> (deref-stack (assign Y X Stack))  where (variable? Y)
   _ _ _ -> (abort))
 
 (define assign  
   Var Val [] -> [(@p [] [Var <-- Val])]
   Var Val [(@p Hyp [Var* <-- Val*]) | Stack]     
   -> [(@p [] [Var <-- Val]) (@p Hyp [Var* <-- Val*]) | Stack]   where (not (= Var (protect What?)))
   Var Val [Sequent | Stack] -> [Sequent | (assign Var Val Stack)])
   
(define deref-stack
  Stack -> (let Bindings (bindings Stack)
                (map (/. X (deref-sequent X Bindings)) Stack)))
                
(define bindings
  [] -> []
  [(@p _ [X <-- Y]) | Stack] -> [[X | Y] | (bindings Stack)]
  [_ | Stack] -> (bindings Stack))

(define deref-sequent
  (@p Hyp [X <-- Y]) _ -> (@p Hyp [X <-- Y])
  (@p Hyp P) Bindings -> (@p (map (/. X (deref-prop X Bindings)) Hyp) (deref-prop P Bindings)))
  
(define deref-prop  
  [X : A] Bindings -> [(deref-term X Bindings) : A])
  
(define deref-term
  X Bindings -> (let Val (assoc X Bindings)
                     (if (empty? Val)
                         X
                         (deref-term (tl Val) Bindings)))
  [X | Y] Bindings -> (map (/. Z (deref-term Z Bindings)) [X | Y]))
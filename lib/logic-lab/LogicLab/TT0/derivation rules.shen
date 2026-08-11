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
   
(d-rule hyp ()

  [X == Y];
 ___________________
  [X : A] >> [Y : A];)
  
(d-rule env ()
 
         let MGU (unify X Y )
         if (succeeds? MGU)
         let Sequents (deref-sequents Sequents MGU)   
         _______________________________________
         [X == Y];)                   
  
(d-rule -->r ()

  let Z (newv)
  let Y (gensym t)
  
  [Y : A] >> [Z : B]; 
  [X == [/. Y : A Z]]; 
  ___________________
  [X : [A --> B]];)
  
(d-rule -->l ()

  let Z (newv)
  [Y : [A --> B]] >> [Z : A];
  [X == [Y Z]];
  ___________________
  [Y : [A --> B]] >> [X : B];)
  
(d-rule &r ()

 let Y (newv)
 let Z (newv)
 [Y : A];
 [Z : B]; 
 [X == [@p Y Z]];
 ____________ 
 [X : [A & B]];)
 
(d-rule &l () 
 
 let Y (newv)
 let Z (newv)
 [Y : A], [Z : B] >> P;
 [Y == [fst X]];
 [Z == [snd X]];
 _______________________
 [X : [A & B]] >> P;)  
 
(d-rule &l1 (B : type) 
 
 let Y (newv)
 [Y : [A & B]];
 [X == [fst Y]]; 
 ___________
 [X : A];)
 
(d-rule &l2 (A : type) 
 
 let Y (newv)
 [Y : [A & B]];
 [X == [snd Y]]; 
 ___________
 [X : B];)
 
 (d-rule lemma (P : prop)
 
  P;
  P >> Q;
  ___________________
  Q;) 

 (d-rule vr1 ()
 
   let Y (newv)   
   [Y : P];
   [X == [@p 0 Y]];
   _____________
   [X : [P v Q]];)
   
 (d-rule vr2 ()
 
   let Y (newv)
   [Y : Q];
   [X == [@p 1 Y]];
   _____________
   [X : [P v Q]];)  
   
 (d-rule vl ()
 
   let Y (newv)
   let Z (newv)
   [Y : [A --> C]];
   [Z : [B --> C]];
   [X == [cases W Y Z]];
   ________________
   [W : [A v B]] >> [X : C];)
   
 (d-rule ~r ()
   
     [X : [A --> falsum]];   
     _____________________
     [X : [~ A]];)
     
   (d-rule ~l ()
   
     [X : [A --> falsum]] >> P;   
     _____________________
     [X : [~ A]] >> P;)   
     
   (d-rule exp ()
   
     let Y (newv)
     [Y : falsum];
     [X == [abort Y]];
     ___________
     [X : P];) 
     
(d-rule existsr (Witness : term)
    
    let Z (newv)
    let BW/Y (replace Y Witness B)
     
    [Witness : A];
    [Z : BW/Y];
    [X == [@p Witness Z]];      
    __________________
     [X : [exists Y : A B]];)  
 
 (d-rule existsl ()    
     
    let C (replace Y [fst X] B)

    [[fst X] : A], [[snd X] : C] >> P;
    _________________
    [X : [exists Y : A B]] >> P;)       
 
 (d-rule allr (T : proper-symbol)

    if (fresh? T Hypotheses)
    if (fresh? T (type [X : [all Y : A B]] prop))
    let Z (type (newv) proper-symbol)
    let BT/Y (replace Y T B)

    [T : A] >> [Z : BT/Y];
    [X == [/. T : A Z]];
    ___________________
    [X : [all Y : A B]];)

  (d-rule alll (T : term)

    let BT/Y (replace Y T B)

    [T : A];
    [[X T] : BT/Y],[X : [all Y : A B]] >> P;
    __________________________
    [X : [all Y : A B]] >> P;)

 (d-rule zeroax ()
      
        ____________
        [0 : natnum];)
        
      (d-rule succax ()
      
         [N : natnum];
         ___________
         [[s N] : natnum];)
         
      (d-rule mathind ()
      
         let C (newv)
         let F (newv)
         let N (newv)
         let Base (replace Y 0 P)
         let Inductive (type [all Y : natnum [P --> (replace Y [s Y] P)]] type)
         
         [C : Base];
         [F : Inductive];
         [X == [/. N : natnum [prim N C F]]];
         ______________________________
         [X : [all Y : natnum P]];)  
         
 (d-rule plus-base ()
      
        let Y (type (newv) proper-symbol)
        [X : natnum];
        [Z == [/. Y : natnum Y]];
        ____________________
        [Z : [plus 0 X X]];) 
           
       (d-rule plus-induct ()
       
       let W (newv)
       [W : [plus X [s Y] Z]];
       [Ws == [f W]];
       _______________________
       [Ws : [plus [s X] Y Z]];)  
       
       (define s
   {number --> number}
   N -> (+ N 1))
          
 (define prim
  {number --> A --> (number --> A --> A) --> A}
  0 C F -> C
  X C F -> (F X (prim (- X 1) C F)))
  
 (define f
  {A --> number --> number}
   X Y -> (s Y))          
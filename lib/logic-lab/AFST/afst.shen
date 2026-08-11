(d-rule defv! ()

  [all x [member x v!]] >> P;
  ___________________________
  P;)
  
(d-rule defe! ()

  [all x [~ [member x e!]]] >> P;
  ___________________________
  P;)
    
(d-rule =sr ()

   [[subset A B] & [subset B A]];
   ______________________________
   [=s A B];)
      
(d-rule =sl ()

   [[subset A B] & [subset B A]] >> P;
   ______________________________
   [=s A B] >> P;)
   
(d-rule subsetr ()

   [all x [[member x A] => [member x B]]];
   _______________________________________
   [subset A B];)
   
(d-rule subsetl ()

   [all x [[member x A] => [member x B]]] >> P;
   _______________________________________
   [subset A B] >> P;) 
   
(d-rule psubsetr ()

   [[subset A B] & [~ [subset B A]]];
   _______________________________________
   [psubset A B];)
   
(d-rule psubsetr ()

   [[subset A B] & [~ [subset B A]]] >> P;
   _______________________________________
   [psubset A B] >> P;)
   
(d-rule unionr ()

  [[member X A] v [member X B]];
  _____________________________
  [member X [union A B]];)
  
(d-rule unionl ()

  [[member X A] v [member X B]] >> P;
  _____________________________
  [member X [union A B]] >> P;)                 
  
(d-rule interr ()

  [[member X A] & [member X B]];
  _____________________________
  [member X [inter A B]];)
  
(d-rule interl ()

  [[member X A] & [member X B]] >> P;
  _____________________________
  [member X [inter A B]] >> P;)
  
(d-rule complr ()

  [~ [member X A]];
  _____________________________
  [member X [comp A]];)
  
(d-rule compl ()

  [~ [member X A]] >> P;
  _____________________________
  [member X [comp A]] >> P;) 
  
(d-rule diffr ()

  [[member X A] & [~ [member X B]]];
  _____________________________
  [member X [diff A B]];)
  
(d-rule diffl ()

  [[member X A] & [~ [member X B]]] >> P;
  _____________________________
  [member X [diff A B]] >> P;) 
  
(d-rule powerr ()

  [subset X A];
  ____________________ 
  [member X [power A]];)
  
(d-rule powerl ()

  [subset X A] >> P;
  ____________________ 
  [member X [power A]] >> P;)
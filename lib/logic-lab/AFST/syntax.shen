(package fol (fol-external-symbols)

(datatype prop

   !; F : function-symbol; Ts : (list term);
   _________________________________________
   [F | Ts] : term; 
   
   !; 
   F : function-symbol, Ts : (list term) >> P;
   _________________________________________
   [F | Ts] : term >> P; 
   
   if (not (element? S [v ~ => <=> & all exists =]))
  S : symbol;
  ___________________________
  S : proper-symbol;
  
  S : symbol;
 __________________
 (gensym S) : proper-symbol;

  N : proper-symbol;
  ____________
  N : name;  

  N : string;
  ___________
  N : name;  

  N : number;
  ______________
  N : name;  

  N : boolean;
  ______________
  N : name;  

  ___________
   [] : name;
  
  X : proper-symbol;
  ____________
  X : variable; 

  F : proper-symbol;
  ________________
  F : function-symbol;  

  Pred : proper-symbol;
  __________
  Pred : predicate;
   
  T : name;
  ________
  T : term;

  T : variable;
  __________
  T : term;

      
    
    !; T1 : term; T2 : term;
    ________________________
    [T1 = T2] : prop;

     !; 
     T1 : term, T2 : term >> P;
     ________________________
     [T1 = T2] : prop >> P;
    
     !; P : prop;
     _____________
     [~ P] : prop;
     
     !; P : prop >> Q;
     _____________
     [~ P] : prop >> Q;     

     if (element? C [v & => <=>])
     !; P : prop; Q : prop;
     ______________________
     [P C Q] : prop;
     
     if (element? C [v & => <=>])
     !; 
     P : prop, Q : prop >> R;
     ______________________
     [P C Q] : prop >> R;

     !; 
     X : variable; P : prop;
     __________________________
     [exists X P] : prop;
     
     !; 
     X : variable, P : prop >> Q;
     __________________________
     [exists X P] : prop >> Q;

     !; 
     X : variable; P : prop;
     __________________________
     [all X P] : prop;
     
     !; 
     X : variable, P : prop >> Q;
     __________________________
     [all X P] : prop >> Q;
     
     P : proper-symbol;
    _________
    P : prop;
      
    Pred : predicate; Ts : (list term);
    ===================================
    [Pred | Ts] : prop;)    )
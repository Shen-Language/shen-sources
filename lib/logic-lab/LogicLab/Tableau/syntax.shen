(package fol (fol-external-symbols)

(datatype prop

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
  ___________________
  F : function-symbol;  

  Pred : proper-symbol;
  _____________________
  Pred : predicate;
   
  T : name;
  ________
  T : term;

  T : variable;
  __________
  T : term;

   F : function-symbol; Ts : (list term);
   ======================================
   [F | Ts] : term;
   
    P : proper-symbol;
    __________________
    P : prop;

   Pred : predicate; Ts : (list term);
   _________________________
   [Pred | Ts] : prop;
   
    (atomic? [Pred | Ts]) : verified, Pred : predicate, Ts : (list term) >> Q;
    __________________________________________________________________________
    (atomic? [Pred | Ts]) : verified, [Pred | Ts] : prop >> Q;
    
    P : verified, Q : verified >> R;
    _______________________________
    (and P Q) : verified >> R;

    T1 : term; T2 : term;
    =====================
    [T1 = T2] : prop;

     P : prop;
     ==========
     [~ P] : prop;

     if (element? C [v & => <=>])
     P : prop; Q : prop;
     ===============
     [P C Q] : prop;

     X : variable; P : prop;
     ==================
     [exists X P] : prop;

     X : variable; P : prop;
     =================
     [all X P] : prop;))
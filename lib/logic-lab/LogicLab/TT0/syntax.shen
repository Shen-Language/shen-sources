(datatype prop

  X : term; A : type;
  ===================
  [X : A] : prop;
  
  X : term; Y : term;
 ====================
  [X == Y] : prop;
  
  if (not (element? S [v ~ --> & all exists /.]))
  S : symbol;
  ___________________________
  S : proper-symbol;
  
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
   
  _______________________
  (newv) : proper-symbol;
  
  X : proper-symbol;
  ____________
  X : variable; 

  F : proper-symbol;
  ________________
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
  
   X : variable; A : type; Y : term;
   =================================
   [/. X : A Y] : term;

   T : term; Ts : (list term);
   ===========================
   [T | Ts] : term;
   
    P : proper-symbol;
    _________
    P : type;

   Pred : predicate; Ts : (list term);
   ___________________________________
   [Pred | Ts] : type;
   
    if (atomic? [Pred | Ts])
    _________________________________
    (atomic? [Pred | Ts]) : verified;

    (atomic? [Pred | Ts]) : verified;
    Pred : predicate, Ts : (list term) >> Q;
    ________________________________________
    [Pred | Ts] : type >> Q;

     P : type;
     =============
     [~ P] : type;

     if (element? C [v & -->])
     P : type; Q : type;
     ===================
     [P C Q] : type;

     X : variable; A : type; P : type;
     =================================
     [exists X : A P] : type;

     X : variable; A : type; P : type;
     =================================
     [all X : A P] : type;)
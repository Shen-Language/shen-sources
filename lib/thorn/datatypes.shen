(package thorn [prop <=> => ~ v & exists all f c x eq &r eR compiled
                revsk hypdisj kb-> <-kb =l hyp on unix term]                                         
                                         
(define constant?
  {symbol --> boolean}
  X -> (element? X [<=> => ~ v & exists all =]))

(datatype term  
   
   T : proper-symbol; Ts : (list term);
   ==============================
   [T | Ts] : term;
   
   __________
   [] : term;
   
   T : number;
   _________
   T : term;
   
   T : boolean;
   ____________
   T : term;
   
   T : string;
   ___________
   T : term;
   
   T : proper-symbol;
   ___________
   T : term;
   
   if (symbol? X)
   if (not (constant? X))
   _______________________
    X : proper-symbol;)

(datatype prop

  P : prop;
  =============
  [~ P] : prop;

  if (element? C [v & => <=>])
  P : prop; Q : prop;
  ===================
  [P C Q] : prop;
  
  X : term; Y : term;
  ===================
  [X = Y] : prop;
  
  X : term; A : term;
  ===================
  [X : A] : prop;

  X : proper-symbol; P : prop;
  ============================
  [exists X P] : prop;

  X : proper-symbol; P : prop;
  ============================
  [all X P] : prop;
  
  X : proper-symbol; A : term; P : prop;
  ======================================
  [exists X : A P] : prop;

  X : proper-symbol; A : term; P : prop;
  ======================================
  [all X : A P] : prop;

  F : proper-symbol; T : (list term);
  _______________________________
  [F | T] : prop;
  
  F : proper-symbol;
  T : (list term);
  _____________________ 
  [F | T] : prop;
  
  T : (list term) >> P;
  ___________________________________________________ 
  (proper-symbol? F) : verified, [F | T] : prop >> P;
  
  P : proper-symbol;
  __________________
  P : prop;) )
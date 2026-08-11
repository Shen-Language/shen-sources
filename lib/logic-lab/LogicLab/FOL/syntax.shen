(package fol (fol-external-symbols)

 (define proper-symbol?
  {A --> boolean}
  S -> (and (symbol? S)
            (not (== S v))
            (not (== S &))
            (not (== S =>))
            (not (== S <=>))
            (not (== S ~))
            (not (== S all))
            (not (== S exists))
            (not (== S =)))) 
            
(define atomic?
  {prop --> boolean}
   [all X P] -> false
   [exists X P] -> false
   [P v Q] -> false
   [P & Q] -> false
   [P => Q] -> false
   [P <=> Q] -> false
   [~ P] -> false
   [X = Y] -> false
   P -> true)
   
(datatype term   
   
   [T | Ts] : (list term);
   =======================
   [T | Ts] : term;
   
   T : term >> P;
   ____________________
   T : (- (list term)) >> P;
   
   S : string;   
   ___________
   S : term;

   S : nat;
   ___________
   S : term;

   S : boolean;
   ____________
   S : term;

   __________
   [] : term; 

   if (natural? T)
   _______________
   T : nat; 
   
   _______________________
   (newv) : proper-symbol; 
   
   X : symbol;
   ___________________________
   (gensym X) : proper-symbol; 

   if (proper-symbol? T)
   _____________________
   T : proper-symbol;
   
   T : proper-symbol;
   __________________
   T : term;)

(datatype prop

  P : proper-symbol;
  __________________
  P : prop;

  F : proper-symbol; T : (list term);
  ___________________________________
  [F | T] : prop;
  
  F : proper-symbol, T : (list term), (atomic? [F | T]) : verified >> P;
  _______________________________________________________________________
  [F | T] : prop, (atomic? [F | T]) : verified >> P;
  
  X : term; Y : term;
  ===================
  [X = Y] : prop;
  
  X : term; Y : term;
  ===================
  [X : Y] : prop;
  
  P : prop;
  =============
  [~ P] : prop;

  if (element? C [v & => <=>])
  P : prop; Q : prop;
  ===================
  [P C Q] : prop;

  X : proper-symbol; P : prop;
  ============================
  [exists X P] : prop;

  X : proper-symbol; P : prop;
  ============================
  [all X P] : prop;))
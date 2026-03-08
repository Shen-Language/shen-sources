(declare subst [term --> [term --> [prop --> prop]]])

(synonyms predicate proper-symbol
          functor   proper-symbol)
          
 (datatype prop

  P : prop;
  ============
  [~ P] : prop;

  if (element? C [v => <=> &])
  P : prop; Q : prop;
  =================
  [P C Q] : prop;
  
  if (= C <--)
  P : prop; Qs : (list prop);
  ===========================
  [P C | Qs] : prop;

  if (element? Q [all exists])
  X : proper-symbol; P : prop;
  ============================
  [Q X P] : prop;
  
  X : term; Y : term;
  ===================
  [X = Y] : prop;
  
  X : term; Y : term;
  ===================
  [X : Y] : prop;
  
  P : proper-symbol;
  __________________
  P : prop;
   
  if (symbol? S)
  if (not (element? S [<=> => ~ v & exists all = :]))
  ____________________________________________________
  S : proper-symbol;
    
  F : predicate; X : (list term);
  _______________________________
  [F | X] : prop;  
  
  F : functor; X : (list term);
  =============================
  [F | X] : term;
    
  __________
  [] : term;
  
  F : proper-symbol;
  __________________
  F : term;
  
  F : number;
  ___________
  F : term;

  F : string;
  ___________
  F : term;

  F : boolean;
  ____________
  F : term;)
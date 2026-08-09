(package fol (fol-external-symbols)

(define clauses
  {prop --> (list prop)}
   P -> (elim-& (elim-all (skolemise (prenex P)))))
  
(define elim-&
  {prop --> (list prop)}
   [P & Q] -> (append (elim-& P) (elim-& Q))
   P -> [P])

(define elim-all
  {prop --> prop}
   [all X P] -> (elim-all (replace X (newv) P))
   P -> P)
     
(define skolemise
 {prop --> prop}
  P -> (sk-help P [])) 

(define sk-help
    {prop --> (list term) --> prop}
    [all X P] Vs -> [all X (sk-help P [X | Vs])]
    [exists X P] Vs 
    -> (let Q (sk-help P Vs)
            SkTerm (type (if (empty? Vs) (gensym c) [(gensym f) | Vs]) term)
            (sk-help (replace X SkTerm Q) Vs))
    P _ -> P)   
  
(define prenex
    {prop --> prop}
     P -> (fix (fn prenex*) P))     
  
(define rectify
    {prop --> prop}
    [all X P] -> (let Y (gensym x)  [all Y (rectify (replace Y X P))])
    [exists X P] 
      -> (let Y (gensym x)  [exists Y (rectify (replace X Y P))])
    [P & Q] -> [(rectify P) & (rectify Q)]
    [P v Q] -> [(rectify P) v (rectify Q)]
    [P => Q] -> [(rectify P) => (rectify Q)]
    [P <=> Q] -> [(rectify P) <=> (rectify Q)]
    [~ P] -> [~ (rectify P)]
    P -> P)
   
(define prenex*
    {prop --> prop}
    [~ [all X P]] -> [exists X [~ P]]
    [~ [exists X P]] -> [all X [~ P]]
    [~ [P & Q]] -> [[~ P] v [~ Q]]
    [~ [P v Q]] -> [[~ P] & [~ Q]]
    [~ [~ P]] -> P
    [~ P] -> [~ (prenex* P)]
    [[all X P] & Q] -> [all X [P & Q]]
    [[all X P] v Q] -> [all X [P v Q]]
    [[exists X P] & Q] -> [exists X [P & Q]]
    [[exists X P] v Q] -> [exists X [P v Q]]
    [P & [all X Q]] -> [all X [P & Q]]
    [P & [exists X Q]] -> [exists X [P & Q]]
    [P v [Q & R]] -> (rectify [[P v Q] & [P v R]])
    [[Q & R] v P] -> (rectify [[P v Q] & [P v R]])   
    [P v [all X Q]] -> [all X [P v Q]]
    [P v [exists X Q]] -> [exists X [P v Q]]
    [P v Q] -> [(prenex* P) v (prenex* Q)]
    [P => Q] -> [[~ P] v Q]
    [P <=> Q] -> (rectify [[P => Q] & [Q => P]]) 
    [P & Q] -> [(prenex* P) & (prenex* Q)]  
    [all X P] -> [all X (prenex* P)]
    [exists X P] -> [exists X (prenex* P)]
    P -> P) )
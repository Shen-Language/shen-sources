(define defaults
 -> (do (set *depth* 20) 
        (set *time-allowed* 60)
        (set *=l?* false)
        (set *trace?* false)
        set))
        
(defaults)        

(declare kb-> [[list prop] --> symbol])
(declare <-kb [prop --> boolean]) 
(declare defaults [--> symbol])    

\\--------------------------------------- Query ----------------------------

(define demod
  X -> X)
    
(define <-kb
  P -> (let PrOut      (set *prout* (open "prf.txt" out))
            Store      (value shen.*infs*)  
            Initialise (do (set shen.*infs* 0) (set *timeout* (+ (get-time unix) (value *time-allowed*))))                                
            Prolog     (time (trap-error (prolog? (<-kb-h (receive P)))
                                  (/. E (do (pr (error-to-string E)) false))))
            Inferences (output "~A inferences~%" (inferences))
            Restore    (set shen.*infs* Store)  
            Close      (close PrOut)
            Prolog))  
  
(defprolog <-kb-h
  P <-- (is Show (set *show?* false))
        (is RevskP (reverse-skolemise P))
        !
        (solve RevskP Prf)
        (enable-proof)
        (show+rule [] P revsk)
        (solve RevskP Prf);)
            
(define reverse-skolemise
  {prop --> prop}
  P -> (let Prenex (prenex P)
            ChQ    (change-quantifiers Prenex)
            Sk     (skolemise ChQ)
            (change-quantifiers Sk)))
              
(define change-quantifiers
  {prop --> prop}
  [all X P]    -> [exists X (change-quantifiers P)]
  [exists X P] -> [all X (change-quantifiers P)]
  P -> P)                            
           
(defprolog enable-proof
  <-- (is Step (set *step* 0))
      (is Show (set *show?* true))
      (is Indent (set *indent* 0));)

(defprolog solve                            
                                                         
  (- [P & Q]) [&r | [fork Prf1 Prf2]]  <--     (ground? P)
                                               (show+rule [] [P & Q] &r) 
                                               !                                                        
                                               (solve P Prf1)
                                               ! 
                                               (solve Q Prf2);
      
  (- [P & Q]) [&r | [fork Prf1 Prf2]]  <-- !   (show+rule [] [P & Q] &r)                                                         
                                               (solve P Prf1) 
                                               (solve Q Prf2);
                                                     
  (- [exists X P]) [eR | Prf]          <-- !   (show+rule [] [exists X P] eR) 
                                               (solve (subst Y X P) Prf);
                                                    
  P Prf                                <--     (bind Literals (reverse (literals P)))
                                               (bind Hyp (signed-complements Literals))
                                               (hypdisj Hyp Literals P Prf);)
  
(defprolog ground?
  X <-- (var? X) ! (when false);
  (- [X | Y]) <-- ! (ground? X) ! (ground? Y);
  _ <--;)                                                                  
                                                         
(define literals
  [P v Q] -> (union (literals P) (literals Q))
  P -> [P])  
  
(define signed-complements
  Literals -> (map (fn signed-complement) Literals))
  
(define signed-complement
  P -> (sign (complement P)))
  
(defprolog hypdisj                                       
   Hyp (- [P | _]) Disjunction [[hypdisj P] | Prf] <-- (bind New (remove (sign (complement P)) Hyp))
                                                       (show+rule [] Disjunction hypdisj)
                                                       (iterative-deepening New (sign P) Prf 0);
   Hyp (- [_ | Ps]) Disjunction Prf <-- (hypdisj Hyp Ps Disjunction Prf);)
   
(defprolog iterative-deepening
  _ _ _ Depth          <-- (when (depth-exceeded? Depth)) ! (when false);
  Hyp P [hyp | Prf] _  <-- (when (uncompiled? P)) ! (show+rule Hyp P hyp) (ishyp P Hyp);  
  Hyp P [[depth Depth] | Prf] Depth      <-- (callF Hyp P Prf Depth);
  Hyp P Prf Depth      <-- (iterative-deepening Hyp P Prf (+ 1 Depth));)
  
(define depth-exceeded?
  Depth -> (> Depth (value thorn.*depth*)))   
  
(define uncompiled?
  [F | _] -> (= (arity F) -1))    
   
(defprolog callF
  Hyp (- [F Boolean | X]) Prf Depth <-- (running-F Hyp F Boolean X Prf Depth);) 
  
(defprolog ishyp
  P (- [P | _]) <--;
  P (- [_ | Hyp]) <-- (ishyp P Hyp);)    
                                            
(defprolog running-F
  Hyp F Boolean X Prf Depth <-- (call (apply (fn F) (append [Boolean] X [Hyp 0 Depth Prf])));)
 
(define apply
  F [] -> F
  F [X | Y] -> (apply (F X) Y)) 
                                                              
(define sign
  {prop --> prop}
   [~ [F | X]] -> [F false | X] 
   [~ P] -> [P false]
   [F | X] -> [F true | X]   
   P -> [P true]) 
                   
(define print-hyps
  [] _ Indent  -> Indent
  [P | Ps] N Indent -> (cn (make-string "~A~A. ~R~%" Indent N (unsign P)) 
                           (print-hyps Ps (+ N 1) Indent)))
                    
(define unsign
  [F true] -> F
  [F false] -> [~ F]
  [F true | X] -> [F | X]
  [F false | X] -> [~ [F | X]]
  P -> P)
  
\\ ------------------------------------ compile --------------------------------------
(define kb->
  Ps -> (let Horn            (filter (fn horn-clause?) Ps)
             NonHorn         (remove-if (fn horn-clause?) Ps)
             Clauses         (mapcan (fn clauses) (if (value *=l?*)
                                                      (format-infix [[all x [x = x]] | NonHorn])
                                                      (format-infix NonHorn)))
             Horn            (set *Horn?* (every? (fn horn?) Clauses))                                         
             Contrapositives (mapcan (fn contrapositives) Clauses)
             Signed          (append Horn (map (fn sign-contrapositives) Contrapositives))
             Groups          (partition (fn same-predicate?) Signed)
             Sort            (map (/. Group (sort (fn shorter-body?) Group)) Groups)
             Prolog          (map (fn compile-contrapositives) Sort)
             MacroExpand     (map (fn macroexpand) Prolog)
             Arities         (shen.find-arities MacroExpand)
             Compile         (map (fn eval) MacroExpand)
             compiled)) 
             
(define horn-clause?
  {prop --> boolean}
   [P <-- | Q] -> true
   _ -> false)              
             
(define format-infix
  {(list prop) --> (list prop)}
   Ps -> (map (/. P (format-infix-h P)) Ps))
   
(define format-infix-h
  {prop --> prop}
   [all X P]    -> [all X (format-infix-h P)]
   [exists X P] -> [exists X (format-infix-h P)] 
   [P & Q]      -> [(format-infix-h P) & (format-infix-h Q)]
   [P v Q]      -> [(format-infix-h P) v (format-infix-h Q)]
   [P => Q]     -> [(format-infix-h P) => (format-infix-h Q)]
   [P <=> Q]    -> [(format-infix-h P) <=> (format-infix-h Q)]
   [~ P]        -> [~ (format-infix-h P)] 
   [X = Y]      -> [eq X Y]
   [X : Y]      -> [istype X Y]
   P            -> P)                 
             
(define horn?
  {(list prop) --> boolean}
   Clause -> (>= 1 (length (filter (fn positive-literal?) Clause))))   
   
(define positive-literal?
  {prop --> boolean}
   [~ P] -> false
   _ -> true)             
             
(define contrapositives
  {prop --> (list prop)}
   Clause -> (map (/. P [P <-- | (map (fn complement) (remove P Clause))]) Clause))
             
(define clauses
  {prop --> (list clause)}
   P -> (let Clauses (cnf->clauses (cnf P))
             Contingent (remove-if (fn tautology?) Clauses)
             Independent (remove-subsumed Contingent)
             Factorise (map (fn remove-duplicates) Independent)
             Factorise))
             
(define tautology?
  {clause --> boolean}
   [] -> false
   [P | Ps] -> (or (element? (complement P) Ps) 
                   (tautology? Ps)))
                   
(define remove-subsumed
  {(list clause) --> (list clause)}
   Clauses -> (rsh Clauses Clauses))
   
(define rsh
  {(list clause) --> (list clause) --> (list clause)}
   [] _ -> []
   [Clause | Rest] Clauses -> (rsh Rest Clauses)   where (subsumed? Clause Clauses)
   [Clause | Rest] Clauses -> [Clause | (rsh Rest Clauses)])
   
(define subsumed?
  {clause --> (list clauses) --> boolean}
   _ [] -> false
   C [C | Cs] -> (subsumed? C Cs)
   C [C* | _] -> true             where (subset? C C*)
   C [_ | Cs] -> (subsumed? C Cs))

(define cnf->clauses
  {prop --> (list clause)}
  [P & Q] -> (union (cnf->clauses P) (cnf->clauses Q))
  P -> [(cch P)])

(define cch
  {prop --> clause}
  [P v Q] -> (union (cch P) (cch Q))
  P -> [P])

(define cnf
  {prop --> prop}
   P -> (elim-all (skolemise (prenex P))))

(define elim-all
  {prop --> prop}
   [all X P] -> (replace (uppercasesym X) X (elim-all P))
   P -> P)
   
(define uppercasesym
  {symbol --> symbol}
   x -> (protect X)
   y -> (protect Y)
   z -> (protect Z)
   _ -> (gensym (protect X)))    
  
(define complement
  {prop --> prop}
   [~ P] -> P
   P -> [~ P])
   
(define skolemise
    {prop --> prop}
    P -> (sk-help P [])) 

(define sk-help
    {prop --> (list term) --> prop}
    [all X P] Vs -> [all X (sk-help P [X | Vs])]
    [exists X P] Vs 
    -> (let Q (sk-help P Vs)
            SkTerm (type (if (empty? Vs) (gensym c) [(gensym f) | (reverse Vs)]) term)
            (sk-help (replace SkTerm X Q) Vs))
    P _ -> P)   
  
(define prenex
    {prop --> prop}
     P -> (fix (fn prenex*) (rectify P))) 
   
(define rectify
    {prop --> prop}
    [all X P] -> (let Y (gensym x)  [all Y (rectify (replace Y X P))])
    [exists X P] 
      -> (let Y (gensym x)  [exists Y (rectify (replace Y X P))])
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
    P -> P) 
    
(define replace
    {term --> term --> prop --> prop}
    Tm _ [all V P] -> [all V P]    where (== Tm V)
    Tm _ [exists V P] -> [exists V P]  where (== Tm V)
    Tm V [all X Y] -> [all X (replace Tm V Y)]
    Tm V [exists X Y] -> [exists X (replace Tm V Y)]
    Tm V [P v Q] -> [(replace Tm V P) v (replace Tm V Q)]
    Tm V [P & Q] -> [(replace Tm V P) & (replace Tm V Q)]	
    Tm V [P => Q] -> [(replace Tm V P) => (replace Tm V Q)]
    Tm V [P <=> Q] -> [(replace Tm V P) <=> (replace Tm V Q)]
    Tm V [~ P] -> [~ (replace Tm V P)]
    Tm V [F | Terms] -> [F | (map (/. Term (replace* Tm V Term)) Terms)]
    _ _ P -> P)  
    
(define replace*
    {term --> term --> term --> term}
    Tm V V -> Tm
    Tm V [Func | Tms] -> [Func | (map (/. Term (replace* Tm V Term)) Tms)]
    _ _ Term -> Term)              
             
(define same-predicate?
  [[F | _] | _] [[F | _] | _] -> true
  _ _ -> false)
  
(define sign-contrapositives
  [P <-- | Q] -> [(sign P) <-- | (map (fn sign) Q)])  
  
(define shorter-body?
  [P <-- | Q] [R <-- | S] -> (> (length S) (length Q)))  
  
(define compile-contrapositives
  Contrapositives -> (let F (predicate Contrapositives)
                          Arity (arity-predicate Contrapositives)
                          Vs    (make-vs Arity)
                      [defprolog F |
                        (append (timeout-clause Vs)
                                (depth-clause Vs)
                                (show-clause F Vs)
                                (hyp-clause F Vs)
                                (loop-clause F Vs)
                                (compile-contrapositives-h Contrapositives)
                                (paramodulation-clause F Vs))]))                                                     
                               
(define show-clause
  F Vs -> (protect (let Head (append Vs [Hyp Depth Max Prf])
                        Body [[show Hyp (my-cons-form [F | Vs])]]
                        (append Head [<--] Body [;]))))
    
(defprolog show+rule
  _ _ _      <-- (when (not (value *show?*))) !;
  Hyp P Rule <-- (fork (show Hyp P) (showrule Rule));)  

(defprolog show
  _ _   <--   (when (not (value *show?*))) ! (when false);
  Hyp P <--   (show-h Hyp P);)
  
(defprolog show-h
  Hyp P <--   (is Indent (n-indents (value *indent*)))
              (is Step (set *step* (+ (value *step*) 1)))
              (is PrintP (make-string "~AStep ~A~%~A~%~A? ~R~%~A~%" 
                                    Indent Step Indent Indent (unsign P) Indent))
              (is PrintHyp (print-hyps Hyp 1 Indent))
              (is PrintSequent (@s PrintP PrintHyp))
              (is Export (pr PrintSequent (value *prout*)))
              !
              (when false);)                  
  
(defprolog showrule
  _ <-- (when (not (value *show?*))) !;
  Rule  <-- (is Indent (n-indents (value *indent*)))
            (is PrintRule (make-string "~%~A> ~A~%~A=============================~%" Indent Rule Indent))
            (is Print (pr PrintRule (value *prout*)))                       
            (is NewIndent (indents (compute-indent Rule)));)
  
(define compute-indent
  hyp -> -1
  &r    -> 1
  "=l" -> 1
  "system-S" -> -1
  Rule   -> (compute-indent-from-clause (read-from-string-unprocessed Rule)) where (string? Rule)
  _      -> 0)

(define compute-indent-from-clause
   [[P <-- | Q]] -> (- (length Q) 1))
   
(define indents
  N -> (set *indent* (+ N (value *indent*))))
            
(define n-indents
  N -> ""   where (>= 0 N)
  N -> (cn "|" (n-indents (- N 1))))                                      
                          
(define arity-predicate
  [[[F | X] | _] | _] -> (length X))                                

(define timeout-clause
  Vs -> (protect (let Head (append Vs [Hyp Depth Max Prf])
                      Body [[when [timeout?]] ! [when false]]
                      (append Head [<--] Body [;]))))
                      
(define timeout?
  -> (> (get-time unix) (value *timeout*)))                      
                                                
(define depth-clause
  Vs -> (protect (let Head (append Vs [Hyp Depth Max Prf])
                      Body [[when [> Depth Max]] ! [when false]]
                      (append Head [<--] Body [;]))))

(define make-vs
  0 -> []
  N -> [(newv) | (make-vs (- N 1))]) 
  
(define hyp-clause
  F Vs -> (protect (let Head (append Vs [Hyp Depth Max [cons hyp []]])
                        Body [[ishyp (my-cons-form [F | Vs]) Hyp]
                              [showrule hyp]]
                        (append Head [<--] Body [;]))))
                        
(define loop-clause
  F Vs -> (protect (let Head (append Vs [Hyp _ _ _])
                        Body [[loop? (my-cons-form [F | Vs]) Hyp]
                              !
                              [when false]]
                        (append Head [<--] Body [;])))) 
                        
(defprolog loop?
  (- [F true | X]) (- [[F false | Y] | _]) <-- (when (= X Y));
  (- [F false | X]) (- [[F true | Y] | _]) <-- (when (= X Y));
  P [_ | Hyps] <-- (loop? P Hyps);)                                               
        
(define paramodulation-clause
  F [Boolean | Vs] -> (protect (let Head (append [Boolean | Vs] 
                                                 [Hyp Depth Max
                                                  (my-cons-form [useparamodulation [fork Prf1 Prf2]])])
                        NewVs (map (/. X (newv)) Vs)
                        Body [[when [value *=l?*]]
                              [is NotBoolean [not Boolean]]
                              (if (value *Horn?*)
                                  [is NewHyp Hyp]
                                  [is NewHyp [cons (my-cons-form [F NotBoolean | Vs]) Hyp]])
                              [=l (my-cons-form [F Boolean | Vs]) NewHyp [+ 2 Depth] Max Prf1 (my-cons-form Vs) (my-cons-form NewVs)]
                              [F Boolean | (append NewVs [NewHyp [+ Depth 2] Max Prf2])]]
                        (append Head [<--] Body [;]))))                                                                              
                          
(define predicate
  [[[F | _] | _] | _] -> F)                          
                          
(define compile-contrapositives-h
  [] -> []
  [[P <-- | Q] | Contrapositives] -> (let Rule     (make-string "~R" (pretty-rule [P <-- | Q]))
                                          PrfTerm  (prf-term (length Q))
                                          P*       (prep-head P Rule PrfTerm)
                                          Q*       (prep-body Q (length Q) (proof-vars PrfTerm))
                                          ShowRule [[showrule Rule]]
                                          NewHyp   [(new-hyp-code P)] 
                                          Code     (append P* [<--] ShowRule NewHyp Q* [;])
                                          (append Code (compile-contrapositives-h Contrapositives))))                                                 
                                          
(define pretty-rule
  [P <-- | Q] -> (format-prefix
                   (happy-variables (protect [X Y Z W V U])
                                  (shen.extract-vars [P Q])
                                  [(unsign P) <-- | (map (fn unsign) Q)])))
                                  
(define format-prefix
  [istype X Y] -> [X : Y]
  [eq X Y]   -> [X = Y]
  [X | Y]    -> (map (fn format-prefix) [X | Y])
  X          -> X)                                  
                                  
(define happy-variables
  [] _ Contrapositive -> Contrapositive
  _ [] Contrapositive -> Contrapositive
  [Happy | Happier] [Sad | Sadder] Contrapositive -> (happy-variables Happier Sadder 
                                                       (subst Happy Sad Contrapositive)))                                                                            
                                          
(define new-hyp-code
  _ ->               (protect [is NewHyp Hyp])   where (value *Horn?*)
  [F Boolean | X] -> (protect [is NewHyp [cons (my-cons-form [F (not Boolean) | X]) Hyp]]))  
                                          
(define prf-term
  0 -> []
  1 -> [(protect Prf)]
  N -> [fork | (make-prfs 1 N)])
  
(define make-prfs
  N N -> [(concat (protect Prf) N)]
  M N -> [(concat (protect Prf) M) | (make-prfs (+ M 1) N)]) 
  
(define proof-vars
  [fork | Vars] -> Vars
  Vars -> Vars)                                           
                                          
(define prep-head
  [F Boolean | X] Rule PrfTerm -> (let Terms [[- Boolean] | (map (fn my-cons-form) X)]
                                       Aux   (protect [Hyp Depth Max (my-cons-form [Rule | PrfTerm])])
                                       (append Terms Aux)))
                       
(define my-cons-form
  [X | Y] -> [cons (my-cons-form X) (my-cons-form Y)]
  X -> X)                       
                       
(define prep-body
  [] N Vars -> []
  [[Q | X] | Qs] N [Prf | Prfs] -> (let Terms (map (fn my-cons-form) X)
                                        Aux   (protect [NewHyp [+ N Depth] Max Prf])
                                        Call  [Q | (append Terms Aux)]
                                        [Call | (prep-body Qs N Prfs)]))

(defprolog =l
  P Hyp Depth Max ["=l" | Prf] (- [X | Xs]) [Y | Xs]                  
    <-- (notvar? X) 
        (showrule "=l") 
        (eq true Y X Hyp (+ 1 Depth) Max Prf) 
        (not-unify X Y);
   P Hyp Depth Max ["zeroing on term ..." | Prf] (- [[F | X] | Xs]) [[F | Y] | Xs] 
    <-- (=l P Hyp Depth Max Prf X Y);
  P Hyp Depth Max ["zeroing on terms ..." | Prf] (- [X | Xs]) [X | Ys]                  
    <-- (=l P Hyp Depth Max Prf Xs Ys);)
   
(defprolog not-unify
  X X <-- ! (when false);
  _ _ <--;)
  
(defprolog notvar?
  X <-- (var? X) ! (when false);
  _ <--;) 
  
(defprolog call-typechecker
  (- true) X Y Hyp Depth Max ["system-S"] <-- (shen.t* X Y (map (fn ch-type) Hyp));)
  
(define ch-type
  [istype X Y] -> [X : Y]
  P -> P) 
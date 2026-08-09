(package thorn [prop term <=> => ~ v & exists all f c x compiled kb-> <-kb unix]
   
(define defaults
 -> (do (set *depth* 20) 
        (set *time-allowed* 5)
        (set *rewrite?* false)
        (set *complexity* -1)
        set))

(set *predicates* [eq])
        
(defaults)        

(declare kb-> [[list prop] --> symbol])
(declare <-kb [prop --> boolean]) 
(declare defaults [--> symbol]) 
(declare depth [number --> number])
(declare timeout [number --> number])
(declare equality [boolean --> boolean])
(declare complex [number --> number]) 
(declare wipe-kb [--> symbol])

(define wipe-kb
  -> (do (set *predicates* []) (kb-> [])))  

(define depth
  N -> (set *depth* N))

(define timeout
  N -> (set *time-allowed* N)) 
  
(define equality
  X -> (set *rewrite?* X))
  
(define complex
  N -> (set *complexity* N))  

\\--------------------------------------- Query ----------------------------
 
(define <-kb
  P -> (let PrOut      (set *prout* (open "prf.txt" out))
            Equality?  (if (> (occurrences = P) 0) (equality true) skip)
            Store      (value shen.*infs*)  
            Initialise (do (set shen.*infs* 0) (set *timeout* (+ (get-time unix) (value *time-allowed*))))                                
            Prolog     (time (trap-error (prolog? (<-kb-h (receive P)))
                                  (/. E (do (pr (error-to-string E)) false))))
            Info       (output "~A inferences, equality = ~A~%depth = ~A, complexity = ~A, timeout = ~A secs~%" 
                             (inferences) (value *rewrite?*) (value *depth*) (value *complexity*) (value *time-allowed*))  
            Restore    (set shen.*infs* Store)  
            Close      (close PrOut)
            Message    (if (not Prolog) (output "~%~S is unproved~%" P) (output "~%~S is proved~%" P))
            Prolog))  
  
(defprolog <-kb-h
  P <-- (is Show (set *show?* false))
        (is RevskP (reverse-skolemise (desugar P)))
        !
        (solve RevskP Prf)
        (enable-proof)
        (show [] P "revsk" 0)
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
                                               (show [] [P & Q] "&r" 1) 
                                               !                                                        
                                               (solve P Prf1)
                                               ! 
                                               (solve Q Prf2);
      
  (- [P & Q]) [&r | [fork Prf1 Prf2]]  <-- !   (show [] [P & Q] "&r" 1)                                                         
                                               (solve P Prf1) 
                                               (solve Q Prf2);
                                                     
  (- [exists X P]) [eR | Prf]          <-- !   (show [] [exists X P] "eR" 0) 
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
                                                       (show [] Disjunction "hypdisj" 0)
                                                       (iterative-deepening New (sign P) Prf 0);
   Hyp (- [_ | Ps]) Disjunction Prf <-- (hypdisj Hyp Ps Disjunction Prf);)
   
(defprolog iterative-deepening
  _ _ _ Depth          <-- (when (depth-exceeded? Depth)) ! (when false);
  Hyp P [hyp | Prf] _  <-- (when (undefined? P)) ! (show Hyp P "hyp" -1) (ishyp P Hyp);  
  Hyp P [[depth Depth] | Prf] Depth      <-- (callF Hyp P Prf Depth);
  Hyp P Prf Depth      <-- (iterative-deepening Hyp P Prf (+ 1 Depth));)
  
(define depth-exceeded?
  Depth -> (> Depth (value thorn.*depth*)))   
  
(define undefined?
  [F | _] -> (not (element? F (value *predicates*))))    
   
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
   [call | X]  -> [call | X]
   [~ [F | X]] -> [F false | X] 
   [~ P]       -> [P false]
   [F | X]     -> [F true | X]   
   P           -> [P true]) 
                   
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
  Ps -> (let Equality?       (if (> (occurrences = Ps) 0) (equality true) (equality false))
             DeSugar         (desugar Ps)
             Predicates      (remember-predicates DeSugar)
             Clauses         (mapcan (fn clauses) [[all x [eq x x]] | DeSugar])
             Horn            (set *Horn?* (every? (fn horn?) Clauses))
             Contrapositives (remove-if (fn procedure-call?) (mapcan (fn contrapositives) Clauses))
             Signed          (map (fn sign-contrapositives)  Contrapositives)
             Groups          (partition (fn same-predicate?) Signed)
             Sort            (map (/. Group (sort (fn shorter-body?) Group)) Groups)
             Prolog          (map (fn compile-contrapositives) Sort)
             MacroExpand     (map (fn macroexpand) Prolog)
             Arities         (shen.find-arities MacroExpand)
             Compile         (map (fn eval) MacroExpand)
             compiled))
             
(define procedure-call?
  [[call | _] | _]     -> true
  [[~ [call | _]] | _] -> true
  _                    -> false)              
             
(define desugar
  [all X : A P]    -> (desugar [all X [[X : A] => P]])
  [exists X : A P] -> (desugar [exists X [[X : A] & P]])
  [X = Y]          -> [eq X Y]
  [X : A]          -> [typeof X A]
  [X | Y]          -> (map (fn desugar) [X | Y])
  X                -> X)
  
(define remember-predicates               
   Ps -> (let Predicates (mapf (fn predicates-in) Ps (fn union))
              (set *predicates* (union Predicates (value *predicates*)))))
              
(define predicates-in
   [all X P]    -> (predicates-in P)
   [exists X P] -> (predicates-in P)
   [P C Q]      -> (union (predicates-in P) (predicates-in Q))  where (element? C [v & => <=>])
   [~ P]        -> (predicates-in P)
   [F | _]      -> [F]
   _            -> [])
  
(define complexity
  [X | Y] -> (+ (complexity X) (complexity Y))
  _       -> 1)                   
             
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
                                (complexity-clause Vs)
                                (hyp-clause F Vs)
                                (loop-clause F Vs)
                                (compile-contrapositives-h Contrapositives)
                                (equality-clause F Vs))]))                                                     
                               
(defprolog show
  _ _ _  _          <-- (when (not (value *show?*))) !;
  Hyp P Rule Indent <-- (is Show (show-step Hyp P Rule Indent));) 

(define show-step
  Hyp P Rule Indent -> (let Step         (set *step* (+ (value *step*) 1))
                            IndentString (n-indents (value *indent*))
                            Seperator    (print-to-proof (cn IndentString "=============================c#10;")) 
                            Conclusion   (make-string "~AStep ~A~%~A~%~A? ~R~%~A~%" IndentString Step IndentString IndentString (sugar (unsign P)) IndentString)
                            PrintP       (print-to-proof Conclusion)
                            PrintHyps    (print-hyps 1 Hyp IndentString)
                            PrintRule    (print-rule Rule IndentString)
                            (set *indent* (+ Indent (value *indent*)))))
                            
(define sugar
  [eq X Y]     -> [X = Y]
  [~ [eq X Y]] -> [~ [X = Y]]
  [X | Y]      -> (map (fn sugar) [X | Y])
  P -> P)                            

(define print-to-proof
  X -> (pr X (value *prout*)))
    
(define n-indents
  N -> ""   where (>= 0 N)
  N -> (cn "|" (n-indents (- N 1))))    
  
(define print-hyps
  _ [] IndexString -> (print-to-proof (cn IndexString "c#10;"))
  N [P | Ps] IndentString -> (let PrintP (make-string "~A~A. ~R~%" IndentString N (sugar (unsign P)))
                                  Print  (print-to-proof PrintP)
                                  (print-hyps (+ N 1) Ps IndentString)))
                                  
(define print-rule
  [rewriteA X] IndentString -> (print-rule (make-string "rewriteA ~R" X) IndentString)
  [rewriteB X] IndentString -> (print-rule (make-string "rewriteB ~R" X) IndentString)
  Rule IndentString -> (let PrintRule (make-string "~A> ~A~%" IndentString Rule)                                   
                            (print-to-proof PrintRule)))                                           
                          
(define arity-predicate
  [[[F | X] | _] | _] -> (length X))                                

(define timeout-clause
  Vs -> (protect (let Head (append Vs [Hyp Depth Max Prf])
                      Body [[when [timeout?]] [is Err [error "timeout"]]]
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
                        P    (my-cons-form [F | Vs])
                        Body [[show Hyp P "hyp" -1]
                              [ishyp P Hyp]]
                        (append Head [<--] Body [;]))))
                        
(define complexity-clause
  Vs -> (protect (let Head  (append Vs [Hyp Depth Max [cons hyp []]])
                      Terms (my-cons-form Vs)
                      Body [[over-complex? Terms [value *complexity*]] ! [when false]]
                      (append Head [<--] Body [;]))))  
                      
(defprolog over-complex?
  Terms (- -1) <-- ! (when false);
  Terms N  <-- (when (> (complexity Terms) N));)                                            
                        
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

(define equality-clause
  F [Boolean | Vs] -> (protect (let Head (append [Boolean | Vs] 
                                                 [Hyp Depth Max Prf])
                                    RewriteA+B [rewriteA+B F [fn F] Boolean (my-cons-form Vs) [subterms (my-cons-form Vs)]
                                                     Hyp [+ 2 Depth] Max Prf]
                                    Guard   [when [value *rewrite?*]]                 
                                    (append Head [<-- Guard RewriteA+B ;])))) 
                                    
(defprolog rewriteA+B
   _ _ _ _ _ _ Depth Max _                                                          <-- (when (> Depth Max)) ! (when false);
   _ _ (- true) (- [X _]) _ _ _ _ _ <-- (var? X) ! (when false);
   _ _ (- true) (- [_ Y]) _ _ _ _ _ <-- (var? Y) ! (when false);
   F Fn Boolean Args (- [X | Y]) Hyps Depth Max [[rewriteA X Sub] [fork Prf1 Prf2]] <--  (not-var? X)
                                                                                         (show Hyps [F Boolean | Args] [rewriteA X] 1)
                                                                                         (eq true X Z Hyps Depth Max Prf1)
                                                                                         (not-is! X Z) 
                                                                                         (sub Z X Args Sub)
                                                                                         (callup (Fn Boolean) Sub Hyps Depth Max Prf2);
   F Fn Boolean Args (- [X | Y]) Hyps Depth Max [[rewriteB X Sub] [fork Prf1 Prf2]] <--  (not-var? X)
                                                                                         (show Hyps [F Boolean | Args] [rewriteB X] 1)
                                                                                         (eq true Z X Hyps Depth Max Prf1) 
                                                                                         (not-is! X Z) 
                                                                                         (sub Z X Args Sub)
                                                                                         (callup (Fn Boolean) Sub Hyps Depth Max Prf2);                                                                                     
   F Fn Boolean Args (- [_ | Y]) Hyps Depth Max Proof <-- (rewriteA+B F Fn Boolean Args Y Hyps Depth Max Proof);)
   
(defprolog not-var?
  X <-- (var? X) ! (when false);
  _ <--;)  
  
(defprolog not-is!
  X X <-- ! (when false);
  _ _ <--;)
  
(defprolog callup
  Fn (- []) Hyps Depth Max Prf      <-- (Fn Hyps Depth Max Prf);
  Fn (- [X | Y]) Hyps Depth Max Prf <-- (callup (Fn X) Y Hyps Depth Max Prf);)     
   
(defprolog sub
   X Y Y* X                 <-- (when (= Y Y*));
   X Y (- [W | Z]) [W* | Z] <-- (sub X Y W W*);
   X Y (- [W | Z]) [W | Z*] <-- (sub X Y Z Z*);)  

(define subterms
  Terms -> (mapf (fn terms) Terms (fn union)))                                                                   

(define terms
   [X | Y] -> [[X | Y] | (mapf (fn terms) Y (fn union))]
   X       -> [X])
                             
(define predicate
  [[[F | _] | _] | _] -> F)                          
                          
(define compile-contrapositives-h
  [] -> []
  [[P <-- | Q] | Contrapositives] -> (let Rule     (pretty-rule [P <-- | Q])
                                          PrfTerm  (prf-term (length Q))
                                          P*       (prep-head P Rule PrfTerm)
                                          Q*       (prep-body Q (length Q) (proof-vars PrfTerm))
                                          Show     [[show (protect Hyp) (my-cons-form P) Rule (- (length Q) 1)]]
                                          NewHyp   [(new-hyp-code P)] 
                                          Code     (append P* [<--] Show NewHyp Q* [;])
                                          (append Code (compile-contrapositives-h Contrapositives))))                                                 
                                          
(define pretty-rule
  [P <-- | Q] -> (let Vars   (shen.extract-vars [P Q])
                      Sugar  [(sugar (unsign P)) <-- | (map (/. X (sugar (unsign X))) Q)]
                      Happy  (happy-variables (protect [X Y Z W V U]) Vars Sugar)
                      Pretty (make-string "~R" Happy)
                      Pretty))
                                  
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
  [[call X] | Qs] N [Prf | Prfs] -> (let Terms (map (fn my-cons-form) X)
                                         Call  [call Terms]
                                         [Call | (prep-body Qs N Prfs)]) 
  [[Q | X] | Qs] N [Prf | Prfs] -> (let Terms (map (fn my-cons-form) X)
                                        Aux   (protect [NewHyp [+ N Depth] Max Prf])
                                        Call  [Q | (append Terms Aux)]
                                        [Call | (prep-body Qs N Prfs)])) )
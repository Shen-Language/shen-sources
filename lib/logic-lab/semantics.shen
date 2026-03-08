\\(package semantics (append (external stlib) [semantics axioms all exists => ~ & v
       \\                                      x y z x1 y1 z1 x2 y2 z2 x3 y3 z3])

(declare semantics [string --> string])
(declare axioms [symbol --> [list prop]])

(define semantics
  File -> (let KLFile       (bootstrap File)
               KL           (read-file KLFile)
               Axioms       (mapcan (fn axioms-from) KL)
               StringAxioms (map (/. Axiom (pretty-string (make-string "~R~%~%" Axiom)))
                                 Axioms)
               AxiomsFile   (file-extension File ".axioms")
               OpenAxioms   (open AxiomsFile out)   
               WriteAxioms  (map (/. String (pr String OpenAxioms)) StringAxioms)
               CloseAxioms  (close OpenAxioms)
               AxiomsFile))
               
(define axioms
  F -> (trap-error (get F axioms) (/. E [])))               
               
(define axioms-from
  [defun F X [cond | Y]] -> (let Type         (get-type F)
                                 Axiom        (axiom Type [defun F X [cond | Y]])
                                 Simplify     (fix (walk (fn simplify)) Axiom)
                                 TypeAxiom    (bindpoly Type (type-axiom Type F X X))
                                 Axioms       (if (= TypeAxiom skip)
                                                  (props Simplify)
                                                  [TypeAxiom | (props Simplify)])
                                 PrettyAxioms (map (fn pretty) Axioms)
                                 Store        (put F axioms PrettyAxioms)
                                 PrettyAxioms) 
  [defun F X Y] -> (axioms-from [defun F X [cond [true Y]]])
  _ -> [])
  
(define type-axiom 
  false     _ _       _  -> skip
  B         F []      Xs -> [[F | Xs] : B]
  [A --> B] F [X | Y] Xs -> (simplify [all X : A (type-axiom B F Y Xs)]))  
  
(define pretty
  P -> (pretty-h [x y z x1 y1 z1 x2 y2 z2 x3 y3 z3] P))
                       
(define pretty-h
  [V | Vs] [all X : A P] -> [all V : A (pretty-h Vs (subst V X P))]
  [V | Vs] [all X P] -> [all V (pretty-h Vs (subst V X P))] 
  [V | Vs] [exists X P] -> [exists V (pretty-h Vs (subst V X P))]
  Vs [P C Q]            -> [(pretty-h Vs P) C (pretty-h Vs Q)]
  Vs [~ P] -> [~ (pretty-h Vs P)]
  _ P -> P)             
  
(define props
  [P & Q] -> (append (props P) (props Q))
  P -> [P])  

(define axiom
  Type [defun F X Y]  -> (let Walk   (kl-logic-h (/. Z [[F | X] = Z]))
                              Matrix (fix (walk Walk) Y)
                              (bindpoly Type (quantify X Type Matrix))))
                                  
(define get-type
  F -> (let Type (shen.typecheck [fn F] (protect A))
            (prolog-vars Type Type)))
            
(define prolog-vars
  [[X | Y] | Z] Type -> (prolog-vars (append [X | Y] Z) Type)
  [X | Y] Type -> (let Z (newv)  
                       NewType (subst Z X Type)
                       (prolog-vars NewType NewType)) where (prolog? (var? (receive X)))
  [_ | Y] Type -> (prolog-vars Y Type)
  _ Type -> Type)
  
(define quantify
  [] _ Matrix               -> Matrix
  [X | Y] [A --> B] Matrix  -> [all X : A (quantify Y B Matrix)]
  [X | Y] false Matrix      -> [all X (quantify Y false Matrix)])                                                                                    
                                  
(define bindpoly
  [[X | Y] | Z] Matrix     -> (bindpoly (append [X | Y] Z) Matrix)
  [X | Y] Matrix           -> [all X (bindpoly (subst a X Y) Matrix)]  where (variable? X)
  [_ | Y] Matrix           -> (bindpoly Y Matrix)
  _ Matrix                 -> Matrix)
                                   
(define walk
  F [X | Y] -> (F (map (walk F) [X | Y]))
  F X -> (F X))                 
  
(define kl-logic-h 
  Eq [cond [true Q] | _]  -> (Eq Q) 
  Eq [cond [P Q] | R]     -> [[P => (Eq Q)] & [[~ P] => [cond | R]]]  
  _ [cons? P]             -> (let X (newv) 
                                  Y (newv)
                                  [exists X [exists Y [[cons X Y] = P]]])
  _ [and P Q]             -> [P & Q]
  _ [or P Q]              -> [P v Q]
  _ [if P Q R]            -> [[P => Q] & [[~ P] => R]]
  _ [not P]               -> [~ P]
  _ [= X Y]               -> [X = Y]
  _ X                     -> X)
  
(define simplify
  [all X : A P]       -> [all X [[X : A] => P]]
  [all X P]           -> P                       where (= (occurrences X P) 0)
  [all X : A P]       -> P                       where (= (occurrences X P) 0)
  [all X [P & Q]]     -> [[all X P] & [all X Q]]
  [~ [exists X P]]    -> [all X [~ P]]
  [~ [P & Q]]         -> [[~ P] v [~ Q]]
  [P => [Q => R]]     -> [[P & Q] => R]
  [P => [Q & R]]      -> [[P => Q] & [P => R]]
  [X = [P & Q]]       -> [[X = P] & [X = Q]]
  [X = [P => Q]]      -> [P => [X = Q]]
  [X = [P v Q]]       -> [[X = P] v [X = Q]]
  [X = [~ P]]         -> [~ [X = P]]
  P -> P)
  
(defprolog typeof
  (- true) X A Hyp _ _ [system-S] <-- (shen.system-S [X : A] Hyp);)\\)
  
  
(package list [prefix? suffix? subset? set=? set? permute nthhd 
               cartprod powerset subbag? bag=? n-times
               trim-right trim-left trim trim-right-if trim-left-if 
               trim-if assoc-if assoc-if-not infix? count-if count
               remove-duplicates foldr foldl find mapf remove-if
               some? every? mapc filter transitive-closure x->ascii
               take take-last drop drop-last index index-last insert
               splice sort partition]

(define assoc-if
  {(A --> boolean) --> (list (list A)) --> (list A)}
   _ [] -> []
   F [[X | Y] | _] -> [X | Y]   where (F X)
   F [_ | Y] -> (assoc-if F Y))
   
(define assoc-if-not
  {(A --> boolean) --> (list (list A)) --> (list A)}
   _ [] -> []
   F [[X | Y] | _] -> [X | Y]   where (not (F X))
   F [_ | Y] -> (assoc-if F Y)) 
   
(define drop
  {number --> (list A) --> (list A)}
   0 L -> L
   N [_ | Y] -> (drop (- N 1) Y)) 
   
(define drop-last
  {number --> (list A) --> (list A)}
   N L -> (reverse (drop N (reverse L)))) 
   
(define index
  {A --> (list A) --> number}
   X L -> (index-h X L 1))
   
(define index-h 
  {A --> (list A) --> number --> number}
   _ [] _ -> -1
   X [X | _] N -> N
   X [_ | Y] N -> (index-h X Y (+ N 1)))
   
(define index-last
  {A --> (list A) --> number}
   X L -> (let Len (length L)
               N (index X (reverse L))
               (if (= N -1) N (+ (- Len N) 1))))
               
(define insert
  {number --> A --> (list A) --> (list A)}
   _ X [] -> (error "cannot insert ~S into list: index out of range~%" X)
   1 X L -> [X | L]
   N X [Y | Z] -> [Y | (insert (- N 1) X  Z)])
   
(define remove-duplicates
  {(list A) --> (list A)}
   [] -> []
   [X | Y] -> (remove-duplicates Y) where (element? X Y)
   [X | Y] -> [X | (remove-duplicates Y)])   
               
(define trim-left-if
  {(A --> boolean) --> (list A) --> (list A)}
    _ [] -> []
    P [X | Y] -> (trim-left-if P Y) where (P X)
    _ L -> L)
    
(define trim-right-if
  {(A --> boolean) --> (list A) --> (list A)}
    P L -> (reverse (trim-left-if P (reverse L))))
    
(define trim-if
  {(A --> boolean) --> (list A) --> (list A)}
    P L -> (trim-right-if P (trim-left-if P L)))                       
               
(define trim-left
  {(list A) --> (list A) --> (list A)}
   _ [] -> []
   Trim [X | Y] -> (trim-left Trim Y) where (element? X Trim)
   _ L -> L)
   
(define trim-right
  {(list A) --> (list A) --> (list A)}
   Trim L -> (reverse (trim-left Trim (reverse L))))
   
(define trim
  {(list A) --> (list A) --> (list A)}
   Trim L -> (trim-right Trim (trim-left Trim L)))                     

(define prefix?
  {(list A) --> (list A) --> boolean}
   [] _ -> true
   [X | Y] [X | Z] -> (prefix? Y Z)
   _ _ -> false)
   
(define infix?
  {(list A) --> (list A) --> boolean}
    L1 L2 -> true         where (prefix? L1 L2)
    _ [] -> false
    L1 [_ | Y] -> (infix? L1 Y))   
   
(define suffix?
  {(list A) --> (list A) --> boolean}
   L1 L2 -> (prefix? (reverse L1) (reverse L2)))
   
(define subset?
  {(list A) --> (list A) --> boolean}
   [] _ -> true
   [X | Y] Z -> (subset? Y Z) where (element? X Z)
   _ _ -> false)
   
(define set=?
  {(list A) --> (list A) --> boolean}
   L1 L2 -> (and (subset? L1 L2) (subset? L2 L1)))
   
(define set?
  {(list A) --> boolean}
   [] -> true
   [X | Y] -> false   where (element? X Y)
   [_ | Y] -> (set? Y))
   
(define n-times
  {A --> number --> (list A)}
   X N -> (n-times-h N X []))
   
(define n-times-h
  {number --> A --> (list A) --> (list A)}
   0 X L -> L
   N X L -> (n-times-h (- N 1) X [X | L]))
   
(define subbag?
  {(list A) --> (list A) --> boolean}
   L1 L2 -> (every? (/. Z (= (count Z L1) (count Z L2))) L1))
   
(define bag=?
  {(list A) --> (list A) --> boolean}
   L1 L2 -> (and (subbag? L1 L2) (subbag? L2 L1)))  
   
(define mapc
  {(A --> B) --> (list A) --> (list C)}
  _ [] -> []
  F [X | Y] -> (mapc (do (F X) F) Y))
   
(define permute
  {(list A) --> (list (list A))}
  [] -> [[]]
  XS -> (mapcan (/. EL (map (/. P [EL | P])
                            (permute (remove EL XS))))
                 XS))                
                     
(define count-if
  {(A --> boolean) --> (list A) --> number}
   P L -> (length (mapcan (/. Z (if (P Z) [Z] [])) L)))
   
(define count
  {A --> (list A) --> number}
   X L -> (count-if (= X) L))   
   
(define some?
  {(A --> boolean) --> (list A) --> boolean}
   _ [] -> false
   P [X | _] -> true  where (P X)
   P [_ | Y] -> (some? P Y))
   
(define every?
  {(A --> boolean) --> (list A) --> boolean}
   _ [] -> true
   P [X | Y] -> (every? P Y)  where (P X)
   _ _ -> false)  
                                
(define sort
  {(A --> A --> boolean) --> (list A) --> (list A)}
    _ [] -> []
    _ [X] -> [X]
    R [X | Y] -> (let Less (mapcan (/. Z (if (R Z X) [Z] [])) Y)
                      More (mapcan (/. Z (if (not (R Z X)) [Z] [])) Y) 
                      (append (sort R Less) [X] (sort R More)))) 
                      
(define find
  {(A --> boolean) --> (list A) --> A}
   _ [] -> (error "find has found no element~%")
   P [X | _] -> X where (P X)
   P [_ | Y] -> (find P Y))                      

(define foldr
  {(A --> B --> B) --> B --> (list A) --> B}
   _ X [] -> X
   F X [Y | Z] -> (foldr F (F Y X) Z))  
   
(define foldl
   {(A --> B --> A) --> A --> (list B) --> A}
   _ X [] -> X
   F X [Y | Z] -> (foldl F (F X Y) Z))                          
                      
(define mapf
  {(A --> B) --> (list A) --> (B --> (list C) --> (list C)) --> (list C)}
   _ [] _ -> []
   F [X | Y] C -> (C (F X) (mapf F Y C)))  

(define filter
  {(A --> boolean) --> (list A) --> (list A)}
   _ [] -> []
   F [X | Y] -> (if (F X) [X | (filter F Y)] (filter F Y)))
   
(define remove-if
  {(A --> boolean) --> (list A) --> (list A)}
   _ [] -> []
   F [X | Y] -> (if (F X) (remove-if F Y) [X | (remove-if F Y)]))
   
(define reduce
  {(A --> B --> A) --> A --> (list B) --> A}
  F Z [] -> Z
  F Z [X | Xs] -> (reduce F (F Z X) Xs))
  
(define take
   {number --> (list A) --> (list A)}
    0 _ -> []
    _ [] -> []
    N [X | L] -> [X | (take (- N 1) L)])
    
(define take-last
  {number --> (list A) --> (list A)}
   N L -> (reverse (take N (reverse L))))
   
(define cartprod
  {(list A) --> (list A) --> (list (list A))}
   [] _ -> []
   [X | Y] Z -> (append (map (/. W [X W]) Z) (cartprod Y Z)))
   
(define powerset
  {(list A) --> (list (list A))}  
   [] -> [[]]
   [X | Y] -> (let P (powerset Y)
                   (append P (map (/. Z [X | Z]) P))))
                   
(define partition
   {(A --> A --> boolean) --> (list A) --> (list (list A))}
   _ [] -> []
   R [X | Y] -> (let EQ (mapcan (/. Z (if (R X Z) [Z] [])) [X | Y])
                     Remainder (difference [X | Y] EQ)
                     [EQ | (partition R Remainder)])
   _ _ -> (simple-error "partition equires a list"))                     

(define transitive-closure
  {(list (A * A)) -->  (list (A * A))}
   L -> (let T (transitive-pass L L)
               (if (= T L)
                   T
                   (transitive-pass T T))))
                    
(define transitive-pass
  {(list (A * A)) --> (list (A * A)) --> (list (A * A))}
   [] All -> All
   [(@p X Y) | L] All -> (let Trans (find-trans X Y All)
                               (union Trans (transitive-pass L All))))
                               
(define find-trans
  {A --> A --> (list (A * A)) --> (list (A * A))}
  _ _ [] -> []
  X Y [(@p Y Z) | All] -> [(@p X Z) | (find-trans X Y All)]
  X Y [_ | All] -> (find-trans X Y All)) 
  
(define x->ascii
  {A --> (list number)}
   X -> (map (fn string->n) (explode X)))
   
(define splice
  {number --> (list A) --> (list A) --> (list A)}
   1 L1 L2 -> (append L1 L2)
   N L [X | Y] -> [X | (splice (- N 1) L Y)])                          )
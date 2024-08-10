(package vector (append (external maths) [vector->list list->vector populated? dense? porous? 
                 vector.reverse vector.append vector.dfilter vector.element? sparse? vacant? vector.some? 
                 vector.map vector.dmap vector.every? overwrite
                 maths.lazyfor-and maths.lazyfor-or v-op1 v-op2
                 compress depopulate])

(define compress
  {(vector A) --> (vector A)}
   V -> (list->vector (vector->list V)))

(define copy
  {(vector A) --> (vector A)}
   V -> (let Limit (limit V)
             NewV (vector Limit)
             (for N = 1 (<= N Limit) (NewV[N] := V[N] overwrite))))
             
(define vector.reverse
  {(vector A) --> (vector A)}
   V -> (let Limit (limit V)
             NewV (vector Limit)
             For (for N = Limit (> N 0) (NewV[N] := V[(+ 1 (- Limit N))] overwrite) (/. X (- X 1)))
             NewV))               
             
(define vector.append
  {(vector A) --> (vector A) --> (vector A)}
   V1 V2 ->  (let Limit1 (limit V1)
                  Limit2 (limit V2)
                  Limit3 (+ Limit1 Limit2)
                  V3 (vector Limit3)
                  For1 (for N = 1 (<= N Limit1) (V3[N] := V1[N] overwrite))
                  For2 (for N = (+ Limit1 1) (<= N Limit3) (V3[N] := V2[N] overwrite))
                  V3)) 
                  
(define vector.dfilter
  {(A --> boolean) --> (vector A) --> (vector A)}
   F V -> (let Limit (limit V)
             For (for N = 1 (<= N Limit) (if (and (populated? V [N]) (F (:= V[N])))
                                           (V[N] := V[N])
                                           (depopulate V [N])))
             V))
             
(define vector.element?
  {A --> (vector A) --> boolean}   
   X V -> (let Limit (limit V)
               Verdict (for N = 1 (<= N Limit) (if (populated? V [N])
                                                   (= X (:= V [N]))
                                                    false) (+ 1) or)
               Verdict))                                                                  
                                    
(define vector.map
  {(A --> B) --> (vector A) --> (vector B)}
   F V -> (let Limit (limit V)
               NewV (vector Limit)
               For (for N = 1 (<= N Limit) (if (populated? V [N])
                                             (NewV[N] := (F (:= V[N])))
                                             (NewV[N] := NewV[N] overwrite)))
               NewV)) 
               
(define vector.dmap
  {(A --> A) --> (vector A) --> (vector A)}
    F V -> (let Limit (limit V)
                For (for N = 1 (<= N Limit) (if (populated? V [N])
                                              (V[N] := (F (:= V[N])))
                                              (V[N] := V[N] overwrite)))
                V)) 
                
(define vector.every?
  {(A --> boolean) --> (vector A) --> boolean}
    F V -> (let Limit (limit V)
                Verdict (for N = 1 (<= N Limit) (if (populated? V [N])
                                                    (F (:= V [N]))
                                                    true) (+ 1) and)
                Verdict))
                
(define vector.some?
  {(A --> boolean) --> (vector A) --> boolean}
    F V -> (let Limit (limit V)
                Verdict (for N = 1 (<= N Limit) (if (populated? V [N])
                                                    (F (:= V [N]))
                                                    false) (+ 1) or)
                Verdict))                                                                                                           
   
(define vector->list
  {(vector A) --> (list A) --> (list A)}
   V L -> (for N = 1
               (<= N (limit V))
               (if (populated? V [N]) [(<-vector V N)] L)
               (+ 1)
               (fn append)))
               
(define list->vector
  {(list A) --> (vector A)}
   L -> (list->vector-h L 1 (vector (length L))))
   
(define list->vector-h
  {(list A) --> number --> (vector A) --> (vector A)}
   [] _ V -> V
   [X | Y] N V -> (list->vector-h Y (+ N 1) (vector-> V N X)))               
                            
(define vacant?
  {(vector A) --> boolean}
   V -> (for N = 1 
             (<= N (limit V)) 
             (not (populated? V [N])) 
             (+ 1) 
             and))

(define dense? 
  {(vector A) --> boolean}
   V -> (for N = 1 
             (<= N (limit V)) 
             (populated? V [N]) 
             (+ 1) 
             and))
   
(define porous? 
  {(vector A) --> boolean}
   V -> (for N = 1 
             (<= N (limit V)) 
             (not (populated? V [N])) 
             (+ 1) 
             or))

(define sparse?
   {(vector A) --> boolean}
   V -> (let Limit (limit V)
             Pop (for N = 1 
                      (<= N (limit V)) 
                      (if (populated? V [N]) 1 0) 
                      (+ 1) 
                      (fn +))
             Unpop (- Limit Pop)
             (> Unpop Pop)))   
             
(define v-op1
  {((list A) --> (list A)) --> (vector A) --> (list A) --> (vector A)}
   F V L -> (list->vector (F (vector->list V L)))) 
   
(define v-op2
  {((list A) --> (list A) --> (list A)) --> (vector A) --> (vector A) --> (list A) --> (vector A)}
   F V1 V2 L -> (list->vector (F (vector->list V1 L) (vector->list V2 L))))   )           
                                                                      
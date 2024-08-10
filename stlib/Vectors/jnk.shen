(package vector [for error overwrite insert ignore depopulate populate vector->list v-op1 v-op2 array]

(defmacro vector-macros
  [:= V [cons I J]] -> [<-array V [cons I J]]
  [:= V [cons I J] insert X] -> [trap-error [<-array V [cons I J]] [/. (protect E) X]]
  [V [cons I [cons J K]] := | Rest] -> [vector-> V I [V [cons J K] := | Rest]]
  [V1 [cons I []] := V2 [cons J K]] -> [vector-> V1 I [<-array V2 [cons J K]]]  
  [V1 [cons I []] := V2 [cons J K] error] -> [vector-> V1 I [<-array V2 [cons J K]]]
  [V1 [cons I []] := X] -> [vector-> V1 I X]
  [V1 [cons I []] := X error] -> [vector-> V1 I X]
  [V1 [cons I []] := V2 [cons J K] ignore] -> [trap-error [vector-> V1 I [<-array V2 [cons J K]]] 
                                                          [/. (protect E) V1]]
  [V1 [cons I []] := X ignore] -> [trap-error [vector-> V1 I X] [/. (protect E) V1]]
  [V1 [cons I []] := V2 [cons J K] insert X] -> [vector-> V1 I [trap-error [<-array V2 [cons J K]] 
                                                                           [/. (protect E) X]]]
  [V1 [cons I []] := X insert Y] -> [trap-error [vector-> V1 I X] [trap-error X 
                                                                           [/. (protect E) Y]]]
  [V1 [cons I []] := V2 [J | K] overwrite] -> [trap-error [vector-> V1 I [<-array V2 [cons J K]]] 
                                                          [/. (protect E) [depopulate V1 I]]]
  [V1 [cons I []] := X overwrite] -> [trap-error [vector-> V1 I X] 
                                       [/. (protect E) [depopulate V1 I]]]
  [<-array V [cons I []]] -> [<-vector V I]
  [<-array V [cons I J]] -> [<-array [<-vector V I] J] 
  [array [cons I []]] -> [vector I]
  [array [cons I J]] -> (let N (protect K) 
                             V (protect V)
                             [let V [vector I]
                                  [for N = 1 [<= N I] [vector-> V N [array J]]]])                                   
  [vector->list V] -> [vector->list V []]
  [v-op1 F V] -> [v-op1 F V []]
  [v-op2 F V1 V2] -> [v-op2 F V1 V2 []])
  
(define depopulate
  V I -> (address-> V I (fail)))
  
(declare depopulate [[vector A] --> [number --> [vector A]]])
(declare populate [[number --> A] --> [number --> [vector A]]])

(define populate
  F I -> (let V (absvector (+ I 1))
              StV (address-> V 0 I)
              (for N = 1 (<= N (+ I 1)) (vector-> V N (F N)))))
 
                   )                    
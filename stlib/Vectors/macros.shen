(package vector [newv for overwrite insert ignore depopulate populate populated? 
                 vector->list v-op1 v-op2 array]

(defmacro vector-macros
  [:= V Is] -> (<-array V Is)
  [V Is := V* Is* | Key] -> (key V Is (array-> V Is (<-array V* Is*)) Key)
  [V Is := X | Key] -> (key V Is (array-> V Is X) Key)
  [array-> V Is X] -> (array-> V Is X) 
  [array Is] -> (build-array Is)
  [populate F [cons I Is]] -> (unfold-populate F [cons I Is])
  [vector->list V] -> [vector->list V []]
  [v-op1 F V] -> [v-op1 F V []]
  [v-op2 F V1 V2] -> [v-op2 F V1 V2 []])
  
(define key
  _ _ Assign [] -> Assign
  _ _ Assign [error] -> Assign
  V Is Assign [ignore] -> [trap-error Assign [/. (newv) V]]
  V Is Assign [insert X] -> [trap-error Assign [/. (newv) [V Is := X]]]
  V Is Assign [overwrite] -> [trap-error Assign [/. (newv) [depopulate V Is]]]
  _ _ _ Key -> (error "key not recognised ~A~%" Key)) 
  
(define build-array
  [cons I []] -> [vector I]
  [cons I J] -> (let N (newv) 
                     V (newv)
                     [let V [vector I]
                            [for N = 1 [<= N I] [vector-> V N (build-array J)]]])
  X -> (error "array cannot macro expand the dimensional argument ~R~%" X)) 
  
(define depopulate
  V [I] -> (address-> V I (fail))
  V [I | Is] -> (do (depopulate (<-vector V I) Is) V)
  _ X -> (error "depopulate cannot use the dimensional argument ~S~%" X))
  
(define populated?
  V [I] -> (not (= (<-address V I) (fail)))
  V [I | Is] -> (populated? (<-address V I) Is))  
  
(declare depopulate [[vector A] --> [[list number] --> [vector A]]])
(declare populated? [[vector A] --> [[list number] --> boolean]])
(declare populate [[number --> A] --> [number --> [vector A]]])

(define unfold-populate
  F [cons I []] -> [populate F I]
  F [cons I Is] -> [populate [/. (newv) (unfold-populate F Is)] I])  

(define populate
  F I -> (let V (absvector (+ I 1))
              StV (address-> V 0 I)
              (for N = 1 (<= N I) (address-> V N (F N)))))
              
(define <-array 
   V [cons I []] -> [<-vector V I]
   V [cons I Is] -> (<-array [<-vector V I] Is)
   _ Dims -> (error "cannot macro expand the dimensional argument ~R~%" Dims))              
              
(define array->
  V [cons I []] X -> [vector-> V I X]
  V Is X -> (let Original (newv)
                [let Original V
                     (unfold-vector-assignment Original Original Is X)]))
                 
(define unfold-vector-assignment
  Original V [cons I []] X ->  (let NewVector (newv)
                                    [let NewVector [vector-> V I X]
                                         Original])
  Original V [cons I J] X -> (let NewVector (newv)
                                  [let NewVector [<-vector V I]
                                       (unfold-vector-assignment Original NewVector J X)])
  _ _ Dims _ -> (error "cannot macro expand the dimensional argument ~R~%" Dims))   )
(package vector [newv array for to]

(defmacro vector-macros
  \\ read access
  [:= V [cons I []]] -> [<-vector V I]

  [:= V [cons I Is]] -> [:= [<-vector V I] Is]

  \\ write access
  [V [cons I []] := X] -> [vector-> V I X]

  [V [cons I Is] := X] -> (let V2 (newv)
                               [let V2 [<-vector V I]
                                       [V2 Is := X]])

  \\ array construction
  [array [cons Dim []]] -> [vector Dim]
  [array [cons Dim Dims]]
    -> (let V (newv)
            N (newv)
         [let V [vector Dim]
           [do [for N = 1 to Dim
                 [vector-> V N [array Dims]]]
               V]])))

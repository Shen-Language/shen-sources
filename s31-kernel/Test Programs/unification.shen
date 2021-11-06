(define unify
   X Y -> (unify-loop X Y []))

(define unify-loop
   X X MGU -> MGU
   X Y MGU -> [[X | Y] | MGU]    where (and (variable? X) (occurs-check? X Y))
   X Y MGU -> [[Y | X] | MGU]    where (and (variable? Y) (occurs-check? Y X))
   [X | Y] [W | Z] MGU -> (let NewMGU (unify-loop X W MGU)
                               (unify-loop (deref Y NewMGU)
                                           (deref Z NewMGU)
                                           NewMGU))
    _ _ _ ->  (error "unification failure"))

(define occurs-check?
   X X -> false
   X [Y | Z] -> (and (occurs-check? X Y) (occurs-check? X Z))
   _ _ -> true)

(define deref
   [X | Y] MGU -> (map (/. Term (deref Term MGU)) [X | Y])
   X MGU -> (let Binding (assoc X MGU)
                 (if (empty? Binding)
                     X
                     (deref (tl Binding) MGU))))

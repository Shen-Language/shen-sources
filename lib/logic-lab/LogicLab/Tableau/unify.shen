(package fol (fol-external-symbols)

(define deref-sequents
  {(list sequent) --> (list (term * term)) --> (list sequent)}
   Sequents MGU -> (map (/. X (deref-sequent X MGU)) Sequents))

(define deref-sequent
   {sequent --> (list (term * term)) --> sequent}
    (@p Hyp P) MGU -> (@p (map (/. X (deref-prop X MGU)) Hyp) P))

(define deref-prop
   {prop --> (list (term * term)) --> prop}
    [~ P] MGU -> [~ (deref-prop P MGU)]
    [P v Q] MGU -> [(deref-prop P MGU) v (deref-prop Q MGU)]
    [P & Q] MGU -> [(deref-prop P MGU) & (deref-prop Q MGU)]
    [F | X] MGU -> [F | (map (/. Y (deref Y MGU)) X)]  where (atomic? [F | X])
    P _ -> P)

(define unify
   {prop --> prop --> (list (term * term))}
   P P -> []
   [F | Ts] [F | Ts*] -> (trap-error (unify-terms Ts Ts* [])
                                     (/. E [(@p no unifier)]))   where (and (atomic? [F | Ts]) (atomic? [F | Ts*]))		
  _ _ -> [(@p no unifier)])

(define defined?
   {(list (term * term)) --> boolean}
   [(@p no unifier)] -> false
    _ -> true)

(define unify-terms 
  {(list term) --> (list term) --> (list (term * term)) --> (list (term * term))} 
   X X Mgu -> Mgu
   [X | Y] [W | Z] Mgu 
   -> (unify-terms Y Z (unify-term (deref X Mgu) (deref W Mgu) Mgu))
   _ _ _ -> (abort))

(define unify-term
  {term --> term --> (list (term * term)) --> (list (term * term))}     
   X X Mgu -> Mgu
   X Y Mgu -> [(@p X Y) | Mgu]   where (occurs-check? X Y)
   X Y Mgu -> [(@p Y X) | Mgu]   where (occurs-check? Y X)
   [F | Y] [F | Z] Mgu -> (unify-terms Y Z Mgu)
   _ _ _ -> (abort)) 

(define occurs-check?
   {term --> term --> boolean}
   X Y -> (and (variable? X) (= 0 (occurrences X Y))))

(define deref
  {term --> (list (term * term)) --> term}
   [X | Y] Mgu -> [X | (map (/. Z (deref Z Mgu)) Y)] 
   X Mgu -> (let Val (trap-error (snd (assocp X Mgu)) (/. E X))
                          (if (= Val X) X (deref Val Mgu)))) )

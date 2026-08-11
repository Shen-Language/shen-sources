(define deref-sequents
   {(list sequent) --> (list (term * term)) --> (list sequent)}
    Sequents MGU -> (map (/. Z (deref-sequent Z MGU)) Sequents))

(define deref-sequent
   {sequent --> (list (term * term))   --> sequent}
   (@p Hyp P) MGU -> (@p (deref-hyp Hyp MGU) (deref-prop P MGU)))

(define deref-hyp
   {(list prop) --> (list (term * term)) --> (list prop)}
   Hyp MGU -> (map (/. Z (deref-prop Z MGU)) Hyp))

(define deref-prop
    {prop --> (list (term * term)) --> prop}
    [Z : A] MGU -> [(deref Z MGU) : A]
    [W == Z] MGU -> [(deref W MGU) == (deref Z MGU)])
    
(define unify 
   {term --> term --> (list (term * term))}
    X Y -> (unify-term X Y []))

(define unify-terms 
  {(list term) --> (list term) --> (list (term * term)) --> (list (term * term))} 
   X X Mgu -> Mgu
   [X | Y] [W | Z] Mgu 
   -> (unify-terms Y Z (unify-term (deref X Mgu) (deref W Mgu) Mgu))
   _ _ _ -> [(@p unification failed)])

(define unify-term
  {term --> term --> (list (term * term)) --> (list (term * term))}     
   X X Mgu -> Mgu
   X Y Mgu -> [(@p X Y) | Mgu]   where (occurs-check? X Y)
   X Y Mgu -> [(@p Y X) | Mgu]   where (occurs-check? Y X)
   [F | Y] [F | Z] Mgu -> (unify-terms Y Z Mgu)
   _ _ _ -> [(@p unification failed)]) 

(define occurs-check?
   {term --> term --> boolean}
   X Y -> (and (variable? X) (= 0 (occurrences X Y))))

(define deref
  {term --> (list (term * term)) --> term}
   [X | Y] Mgu -> [(deref X Mgu) | (map (/. Z (deref Z Mgu)) Y)] 
   X Mgu -> (let Val (trap-error (snd (assocp X Mgu)) (/. E X))
                          (if (= Val X) X (deref Val Mgu))))
   
(define succeeds?
   {(list (term * term)) --> boolean}
   [(@p unification failed)] -> false
   _ -> true)
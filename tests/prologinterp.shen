(datatype atom

  F : symbol; X : (list term);
  ============================
  [F | X] : atom;)

(datatype term

  P : symbol;
  ___________
  P : term;

  P : number;
  ___________
  P : term;

  P : string;
  ___________
  P : term;

  P : boolean;
  ____________
  P : term;

  F : symbol; X : (list term);
  ============================
  [F | X] : term;)

(datatype horn-clause

   H : atom; B : (list atom);
   ==========================
   [H <= | B] : horn-clause;)

(define unify-atoms
  {atom --> atom --> (list (term * term))}
   P P -> []
   [F | X] [F | Y] -> (unify-terms X Y [ ])
   _ _ -> (error "unification failure!"))

(define unify-terms
  {(list term) --> (list term) --> (list (term * term)) --> (list (term * term))}
   X X Mgu -> Mgu
   [X | Y] [W | Z] Mgu
   -> (unify-terms Y Z (unify-term (dereference X Mgu)
                                   (dereference W Mgu)
                                   Mgu))
   _ _ _ -> (error "unification failure!"))

(define unify-term
  {term --> term --> (list (term * term)) --> (list (term * term))}
   X X Mgu -> Mgu
   X Y Mgu -> [(@p X Y) | Mgu]   where (occurs-check? X Y)
   X Y Mgu -> [(@p Y X) | Mgu]   where (occurs-check? Y X)
   [F | Y] [F | Z] Mgu -> (unify-terms Y Z Mgu)
   _ _ _ -> (error "unification failure!"))

(define occurs-check?
   {term --> term --> boolean}
   X Y -> (and (variable? X) (not (occurs? X Y))))

(define dereference
  {term --> (list (term * term)) --> term}
   [X | Y] Mgu -> [X | (map (/. Z (dereference Z Mgu)) Y)]
   X Mgu -> (let Val (lookup X Mgu)
                        (if (= Val X) X (dereference Val Mgu))))

(define lookup
  {term --> (list (term * term)) --> term}
   X [] -> X
   X [(@p X Y) | _] -> Y
   X [_ | Y] -> (lookup X Y))

(define occurs?
  {term --> term --> boolean}
   X X -> true
   X [Y | Z] -> (or (== X Y) (some (/. W (occurs? X W)) Z))
   _ _ -> false)

(define some
  {(A --> boolean) --> (list A) --> boolean}
    _ [] -> false
    F [X | Y] -> (or (F X) (some F Y)))

(define prolog
   {(list atom) --> (list horn-clause)  -->  boolean}
     Goals Program -> (prolog-help (insert-answer-literal Goals)
                                                    Program
                                                    Program))

(define insert-answer-literal
   {(list atom) --> (list atom)}
    Goals -> (append Goals
                     (answer-literal (mapcan (fn variables-in-atom) Goals))))

(define answer-literal
   {(list term) --> (list atom)}
    Vs -> [[answer | (answer-terms Vs)]])

(define answer-terms
   {(list term) --> (list term)}
    [] -> []
    [V | Vs] -> [(str V) V | (answer-terms (remove V Vs))])

(define prolog-help
   {(list atom) --> (list horn-clause) --> (list horn-clause) --> boolean}
    [] _ _ -> true
    [[answer | Terms]] _ _ -> (answer Terms)
    [P | Ps] [Clause | Clauses] Program
      -> (let StClause (standardise-apart Clause)
                H (hdcl StClause)
                B (body StClause)
                (or (trap-error
                       (let MGU (unify-atoms P H)
                             Goals (map (/. X (dereference-atom X MGU))
                                                (append B Ps))
                             (prolog-help Goals Program Program)) (/. E false))
                       (prolog-help [P | Ps] Clauses Program)))
    _ _ _ -> false)

(define hdcl
  {horn-clause --> atom}
  [H <= | _] -> H)

(define body
  {horn-clause --> (list atom)}
   [_ <= | Body] -> Body)

(define dereference-atom
  {atom --> (list (term * term)) --> atom}
   [F | Terms] MGU -> [F | (map (/. T (dereference T MGU)) Terms)])

(define answer
    {(list term) --> boolean}
    [ ] -> (not (y-or-n? "~%more? "))
    [String Value | Answer] -> (do (output "~%~A = ~S"  String Value) (answer Answer)))

(define standardise-apart
  {horn-clause --> horn-clause}
  Clause -> (st-all (variables-in-clause Clause) Clause))

(define variables-in-clause
   {horn-clause --> (list term)}
   [H <= | B] -> (append (variables-in-atom H) (mapcan (fn variables-in-atom) B)))

(define variables-in-atom
  {atom --> (list term)}
  [Predicate | Terms] -> (mapcan (fn variables-in-term) Terms))

(define variables-in-term
   {term --> (list term)}
    Term -> [Term]		where (variable? Term)
    [F | Terms] -> (mapcan (fn variables-in-term) Terms)
    _ -> [])

(define st-all
   {(list term) --> horn-clause --> horn-clause}
    [] Clause -> Clause
    [V | Vs] Clause -> (st-all (remove V Vs)
                               (replace-term-in-clause V (gensym (protect X)) Clause)))

(define replace-term-in-clause
   {term --> term --> horn-clause --> horn-clause}
    V NewV [H <= | B] -> [(replace-term-in-atom V NewV H) <=
                                          | (map (/. A (replace-term-in-atom V NewV A)) B)])

(define replace-term-in-atom
   {term --> term --> atom --> atom}
   V NewV [F | Terms] -> [F | (map (/. T (replace-term V NewV T)) Terms)])

(define replace-term
   {term --> term --> term --> term}
    V NewV V -> NewV
    V NewV [F | Terms] -> [F | (map (/. T (replace-term V NewV T)) Terms)]
    _ _ Term -> Term)
(package symbolic-evaluation [raise symeval -f +f -r +r]

(define raise
   File -> (let Code  (read-file File)
                Meta  (map (fn eval) (map (fn meta) Code))
                ok))

(define meta
  [define F | X] -> (let Skip (skip-signature X)
                         [define (concat meta- F)
                                 | (compile (fn <meta-rules>) [F | X])])
  X -> X)

(defcc <meta-rules>
  Meta-F <rule> <rules> := (mapcan (/. X (insert-meta-F Meta-F X)) [<rule> | <rules>]);)

(define insert-meta-F
  Meta-F [Patterns Action] -> [(cons-form [Meta-F | Patterns]) -> (cons-form Action)])

(define cons-form
  [X | Y] -> [cons (cons-form X) (cons-form Y)]
  X -> X)

(defcc <rules>
  <rule> <rules> := [<rule> | <rules>];
  <e> := [];)

(defcc <rule>
  shen.<patterns> -> Action             := [shen.<patterns> Action];)

(define skip-signature
  [{ } | X] -> X
  [{ _ | X] -> (skip-signature X)
  X -> X)

(define symeval
  X -r -f -> (symeval-h X)
  X +r -f -> (walk (fn symeval-h) X)
  X -r +f -> (fix (fn symeval-h) X)
  X +r +f -> (fix (/. Y (walk (fn symeval-h) Y)) X)
  _ Y Z   -> (error "~A and ~A is either +r or -r and +f or -f respectively~%" Y Z))

(define walk
  F [X | Y] -> (F (map (walk F) [X | Y]))
  F X -> (F X))

(define symeval-h
  [F | X] -> (trap-error ((fn (concat meta- F)) [F | X]) (/. E [F | X]))
  X -> X) )

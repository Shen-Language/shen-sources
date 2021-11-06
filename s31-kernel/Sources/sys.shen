\\           Copyright (c) 2010-2019, Mark Tarver

\\                  All rights reserved.

(package shen [update-lambda-table]

(define thaw
  F -> (F))

\\(define eval
 \\ X -> (eval-kl (shen->kl (macroexpand X))))

(define eval
  X -> (eval-kl (shen->kl (process-applications (macroexpand X) (find-types X)))))

(define external
  null -> []
  Package -> (trap-error (get Package external-symbols)
                         (/. E (error "package ~A does not exist.~%;" Package))))

(define internal
  null -> []
  Package -> (trap-error (get Package internal-symbols)
                         (/. E (error "package ~A does not exist.~%;" Package))))

(define fail-if
  F X -> (if (F X) (fail) X))

(define @s
  X Y -> (cn X Y))

(define tc?
  -> (value *tc*))

(define ps
  Name -> (trap-error (get Name source) (/. E (error "~A not found.~%" Name))))

(define stinput
  -> (value *stinput*))

(define vector
   N -> (let Vector (absvector (+ N 1))
             ZeroStamp (address-> Vector 0 N)
             Standard (if (= N 0) ZeroStamp (fillvector ZeroStamp 1 N (fail)))
             Standard))

(define fillvector
  Vector N N X -> (address-> Vector N X)
  Vector Counter N X -> (fillvector (address-> Vector Counter X) (+ 1 Counter) N X))

(define vector?
  X -> (and (absvector? X) (trap-error (>= (<-address X 0) 0) (/. E false))))

(define vector->
  Vector N X -> (if (= N 0)
                    (error "cannot access 0th element of a vector~%")
                    (address-> Vector N X)))

(define <-vector
  Vector N -> (if (= N 0)
                  (error "cannot access 0th element of a vector~%")
                  (let VectorElement (<-address Vector N)
                      (if (= VectorElement (fail))
                          (error "vector element not found~%")
                          VectorElement))))

(define posint?
  X -> (and (integer? X) (>= X 0)))

(define limit
  Vector -> (<-address Vector 0))

(define symbol?
  X -> false where (or (boolean? X) (number? X) (string? X) (cons? X) (empty? X) (vector? X))
  X -> true  where (element? X [{ } (intern ":") (intern ";") (intern ",")])
  X -> (trap-error (let String (str X)
                        (analyse-symbol? String)) (/. E false)))

(define analyse-symbol?
  (@s S Ss) -> (and (alpha? (string->n S))
                    (alphanums? Ss))
  _ -> (simple-error "implementation error in shen.analyse-symbol?"))

(define alphanums?
  "" -> true
  (@s S Ss) -> (let N (string->n S)
                    (and (or (alpha? N) (digit? N)) (alphanums? Ss)))
  _ -> (simple-error "implementation error in shen.alphanums?"))

(define variable?
  X -> false where (or (boolean? X) (number? X) (string? X))
  X -> (trap-error (let String (str X)
                        (analyse-variable? String)) (/. E false)))

(define analyse-variable?
  (@s S Ss) -> (and (uppercase? (string->n S))
                    (alphanums? Ss))
  _ -> (simple-error "implementation error in shen.analyse-variable?"))

(define gensym
  Sym -> (concat Sym (set *gensym* (+ 1 (value *gensym*)))))

(define concat
  S1 S2 -> (intern (cn (str S1) (str S2))))

(define @p
  X Y -> (let Vector (absvector 3)
              Tag (address-> Vector 0 tuple)
              Fst (address-> Vector 1 X)
              Snd (address-> Vector 2 Y)
              Vector))

(define fst
  X -> (<-address X 1))

(define snd
  X -> (<-address X 2))

(define tuple?
  X -> (trap-error (and (absvector? X) (= tuple (<-address X 0))) (/. E false)))

(define append
  [] X -> X
  [X | Y] Z -> [X | (append Y Z)]
  _ _ -> (simple-error "attempt to append a non-list"))

(define @v
  X Vector -> (let Limit (limit Vector)
                   NewVector (vector (+ Limit 1))
                   X+NewVector (vector-> NewVector 1 X)
                   (if (= Limit 0)
                       X+NewVector
                       (@v-help Vector 1 Limit X+NewVector))))

(define @v-help
  OldVector N N NewVector -> (copyfromvector OldVector NewVector N (+ N 1))
  OldVector N Limit NewVector -> (@v-help OldVector (+ N 1) Limit
                                     (copyfromvector OldVector NewVector N (+ N 1))))

(define copyfromvector
  OldVector NewVector From To -> (trap-error (vector-> NewVector To (<-vector OldVector From)) (/. E NewVector)))

(define hdv
  Vector -> (trap-error (<-vector Vector 1)
                        (/. E (error "hdv needs a non-empty vector as an argument~%"))))

(define tlv
  Vector -> (let Limit (limit Vector)
                 (cases (= Limit 0) (error "cannot take the tail of the empty vector~%")
                        (= Limit 1) (vector 0)
                        true (let NewVector (vector (- Limit 1))
                                  (tlv-help Vector 2 Limit (vector (- Limit 1)))))))

(define tlv-help
  OldVector N N NewVector -> (copyfromvector OldVector NewVector N (- N 1))
  OldVector N Limit NewVector -> (tlv-help OldVector (+ N 1) Limit
                                     (copyfromvector OldVector NewVector N (- N 1))))

(define assoc
  _ [] -> []
  X [[X | Y] | _] -> [X | Y]
  X [_ | Y] -> (assoc X Y)
  _ _ -> (error "attempt to search a non-list with assoc~%"))

(define boolean?
  true -> true
  false -> true
  _ -> false)

(define nl
  0 -> 0
  N -> (do (output "~%") (nl (- N 1))))

(define difference
  [] _ -> []
  [X | Y] Z -> (if (element? X Z) (difference Y Z) [X | (difference Y Z)])
  _ _ -> (error "attempt to find the difference with a non-list~%"))

(define do
  X Y -> Y)

(define element?
  _ [] -> false
  X [X | _] -> true
  X [_ | Z] -> (element? X Z)
  _ _ -> (error "attempt to find an element in a non-list~%"))

(define empty?
  [] -> true
  _ -> false)

(define fix
  F X -> (fix-help F X (F X)))

(define fix-help
  _ X X -> X
  F _ X -> (fix-help F X (F X)))

(define put
  X Pointer Y Vector -> (let N (hash X (limit Vector))
                             Entry (trap-error (<-vector Vector N) (/. E []))
                             Change (vector-> Vector N (change-pointer-value X Pointer Y Entry))
                             Y))

(define unput
  X Pointer Vector -> (let N (hash X (limit Vector))
                           Entry (trap-error (<-vector Vector N) (/. E []))
                           Change (vector-> Vector N (remove-pointer X Pointer Entry))
                           X))

(define remove-pointer
  X Pointer [] -> []
  X Pointer [[[X Pointer] | _] | Entry] -> Entry
  X Pointer [Z | Entry] -> [Z | (remove-pointer X Pointer Entry)]
  _ _ _ -> (simple-error "implementation error in shen.remove-pointer"))

(define change-pointer-value
  X Pointer Y [] -> [[[X Pointer] | Y]]
  X Pointer Y [[[X Pointer] | _] | Entry] -> [[[X Pointer] | Y] | Entry]
  X Pointer Y [Z | Entry] -> [Z | (change-pointer-value X Pointer Y Entry)]
  _ _ _ _ -> (simple-error "implementation error in shen.change-pointer-value"))

(define get
  X Pointer Vector -> (let N (hash X (limit Vector))
                           Entry (trap-error (<-vector Vector N)
                                      (/. E (error "~A has no attributes: ~S~%" X Pointer)))
                           Result (assoc [X Pointer] Entry)
                           (if (empty? Result)
                               (error "attribute ~S not found for ~S~%" Pointer X)
                               (tl Result))))

(define hash
  S Limit -> (let Hash (mod (hashkey S) Limit)
                  (if (= Hash 0)
                      1
                      Hash)))

(define hashkey
  S -> (let Ns (map (/. X (string->n X)) (explode S))
               (prodbutzero Ns 1)))

(define prodbutzero
  [] N -> N
  [0 | Ns] N -> (prodbutzero Ns N)
  [N1 | Ns] N -> (if (> N 1e10)
                     (prodbutzero Ns (+ N N1))
                     (prodbutzero Ns (* N N1))))

(define mod
  N Div -> (modh N (multiples N [Div])))

(define multiples
  N [M | Ms] ->  Ms   where (> M N)
  N [M | Ms] -> (multiples N [(* 2 M) M | Ms])
  _ _ -> (simple-error "implementation error in shen.multiples"))

(define modh
  0 _ -> 0
  N [] -> N
  N [M | Ms] -> (if (empty? Ms)
                    N
                    (modh N Ms))   where (> M N)
  N [M | Ms] -> (modh (- N M) [M | Ms])
  _ _ -> (simple-error "implementation error in shen.modh"))

(define sum
  [] -> 0
  [N | Ns] -> (+ N (sum Ns))
  _ -> (error "attempt to sum a non-list~%"))

(define head
  [X | _] -> X
  _ -> (error "head expects a non-empty list~%"))

(define tail
  [_ | Y] -> Y
  _ -> (error "tail expects a non-empty list~%"))

(define hdstr
  S -> (pos S 0))

(define intersection
  [] _ -> []
  [X | Y] Z -> (if (element? X Z) [X | (intersection Y Z)] (intersection Y Z))
  _ _ -> (error "attempt to find the intersection with a non-list~%"))

(define reverse
  X -> (reverse-help X []))

(define reverse-help
  [] R -> R
  [X | Y] R -> (reverse-help Y [X | R])
  _ _ -> (error "attempt to reverse a non-list~%"))

(define union
  [] X -> X
  [X | Y] Z -> (if (element? X Z) (union Y Z) [X | (union Y Z)])
  _ _ -> (error "attempt to find the union with a non-list~%"))

(define y-or-n?
  String -> (let Message (output String)
                 Y-or-N (output " (y/n) ")
                 Input (make-string "~S" (read (stinput)))
                 (cases (= "y" Input) true
                        (= "n" Input) false
                        true (do (output "please answer y or n~%")
                                 (y-or-n? String)))))

(define not
  X -> (if X false true))

(define abort
  -> (simple-error ""))

(define subst
  X Y Y -> X
  X Y [W | Z] -> [(subst X Y W) | (subst X Y Z)]
  _ _ Z -> Z)

(define explode
  X -> (explode-h (make-string "~A" X)))

(define explode-h
  "" -> []
  (@s S Ss) -> [S | (explode-h Ss)]
  _ -> (simple-error "implementation error in explode-h"))

(define cd
  Path -> (set *home-directory* (if (= Path "") "" (make-string "~A/" Path))))

(define map
  F X -> (map-h F X []))

(define map-h
  F [] Acc -> (reverse Acc)
  F [X | Y] Acc -> (map-h F Y [(F X) | Acc]))

(define length
  X -> (length-h X 0))

(define length-h
  [] N -> N
  X N -> (length-h (tl X) (+ N 1))
  _ _ -> (error "attempt to find the length of a non-list~%"))

(define occurrences
  X X -> 1
  X [Y | Z] -> (+ (occurrences X Y) (occurrences X Z))
  _ _ -> 0)

(define nth
  1 [X | _] -> X
  N [_ | Y] -> (nth (- N 1) Y)
  N X -> (error "nth applied to ~A, ~A~%" N X))

(define integer?
  N -> (and (number? N) (let Abs (abs N) (integer-test? Abs (magless Abs 1)))))

(define abs
  N -> (if (> N 0) N (- 0 N)))

(define magless
  Abs N -> (let Nx2 (* N 2)
                (if (> Nx2 Abs)
                    N
                    (magless Abs Nx2))))

(define integer-test?
  0 _ -> true
  Abs _ -> false    where (> 1 Abs)
  Abs N -> (let Abs-N (- Abs N)
                (if (> 0 Abs-N)
                    (integer? Abs)
                    (integer-test? Abs-N N))))

(define mapcan
  _ [] -> []
  F [X | Y] -> (append (F X) (mapcan F Y))
  _ _ -> (error "attempt to mapcan over a non-list~%"))

(define ==
  X X -> true
  _ _ -> false)

(define bound?
  Sym -> (and (symbol? Sym)
              (let Val (trap-error (value Sym) (/. E this-symbol-is-unbound))
                          (if (= Val this-symbol-is-unbound)
                              false
                              true))))

(define string->bytes
  "" -> []
  S -> [(string->n (pos S 0)) | (string->bytes (tlstr S))])

(define maxinferences
  N -> (set *maxinferences* N))

(define inferences
  -> (value *infs*))

(define protect
  X -> X)

(define stoutput
  -> (value *stoutput*))

(define string->symbol
  S -> (let Symbol (intern S)
          (if (symbol? Symbol)
              Symbol
              (error "cannot intern ~S to a symbol" S))))

(define optimise
  + -> (set *optimise* true)
  - -> (set *optimise* false)
  _ -> (error "optimise expects a + or a -.~%"))

(define os
  -> (value *os*))

(define language
  -> (value *language*))

(define version
  -> (value *version*))

(define port
  -> (value *port*))

(define porters
  -> (value *porters*))

(define implementation
  -> (value *implementation*))

(define release
  -> (value *release*))

(define package?
  null -> true
  Package -> (trap-error (do (external Package) true) (/. E false)))

(define fn
  F -> (let Assoc (assoc F (value *lambdatable*))
            (if (empty? Assoc)
                (error "~A has no lambda expansion~%" F)
                (tl Assoc))))

(define fail
  -> fail!)

(define enable-type-theory
  + -> (set *shen-type-theory-enabled?* true)
  - -> (set *shen-type-theory-enabled?* false)
  _ -> (error "enable-type-theory expects a + or a -~%"))

(define tc
  + -> (set *tc* true)
  - -> (set *tc* false)
  _ -> (error "tc expects a + or -"))

(define destroy
  F -> (do (unassoc F (value *sigf*)) F))

(define unassoc
  F SigF -> (let Assoc (assoc F SigF)
                 Remove (remove Assoc SigF)
                 (set *sigf* Remove)))

(define in-package
  Package -> (if (package? Package)
                 (set *package* Package)
                 (error "package ~A does not exist~%" Package)))

(define write-to-file
   File Text -> (let Stream (open File out)
                     String (if (string? Text)
                                (make-string "~A~%~%" Text)
                                (make-string "~S~%~%" Text))
                     Write (pr String Stream)
                     Close (close Stream)
                     Text))

(define fresh
  -> (freshterm (gensym t)))

(define update-lambda-table
    F Arity -> (let AssertArity (put F arity Arity)
                    LambdaEntry (shen.lambda-entry F)
                    Update (set shen.*lambdatable* [LambdaEntry | (value shen.*lambdatable*)])
                    F))

(define specialise
  F 0 -> (do (set *special* (remove F (value *special*))) (set *extraspecial* (remove F (value *extraspecial*))) F)
  F 1 -> (do (set *special* (adjoin F (value *special*))) (set *extraspecial* (remove F (value *extraspecial*))) F)
  F 2 -> (do (set *special* (remove F (value *special*))) (set *extraspecial* (adjoin F (value *extraspecial*))) F)
  F _ -> (error "specialise requires values of 0, 1 or 2~%")) )

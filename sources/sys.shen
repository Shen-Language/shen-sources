\*
Copyright (c) 2010-2015, Mark Tarver

All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
1. Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.
3. The name of Mark Tarver may not be used to endorse or promote products
   derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY Mark Tarver ''AS IS'' AND ANY
EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL Mark Tarver BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

*\

(package shen []

(define thaw
  F -> (F))

(define eval
  X -> (let Macroexpand (walk (/. Y (macroexpand Y)) X)
         (if (packaged? Macroexpand)
             (map (/. Z (eval-without-macros Z)) (package-contents Macroexpand))
             (eval-without-macros Macroexpand))))

(define eval-without-macros
  X -> (eval-kl (elim-def (proc-input+ X))))

(define proc-input+
  [input+ Type Stream] -> [input+ (rcons_form Type) Stream]
  [read+ Type Stream] -> [read+ (rcons_form Type) Stream]
  [X | Y] -> (map (/. Z (proc-input+ Z)) [X | Y])
  X -> X)

(define elim-def
  [define F | Rest] -> (shen->kl F Rest)
  [defmacro F | Rest] -> (let Default [(protect X) -> (protect X)]
                              Def (elim-def [define F | (append Rest Default)])
                              MacroAdd (add-macro F)
                            Def)
  [defcc F | X] -> (elim-def (yacc [defcc F | X]))
  [X | Y] -> (map (/. Z (elim-def Z)) [X | Y])
  X -> X)

(define add-macro
  F -> (let MacroReg (value *macroreg*)
            NewMacroReg (set *macroreg* (adjoin F (value *macroreg*)))
         (if (= MacroReg NewMacroReg)
             skip
             (set *macros* [(function F) | (value *macros*)]))))

(define packaged?
  [package P E | _] -> true
  _ -> false)

(define external
  Package -> (trap-error
              (get Package external-symbols)
              (/. E (error "package ~A has not been used.~%" Package))))

(define internal
  Package -> (trap-error
              (get Package internal-symbols)
              (/. E (error "package ~A has not been used.~%" Package))))

(define package-contents
  [package null _ | Contents] -> Contents
  [package P E | Contents] -> (let PackageNameDot (intern (cn (str P) "."))
                                   ExpPackageNameDot (explode PackageNameDot)
                                (packageh P E Contents ExpPackageNameDot)))

(define walk
  F [X | Y] -> (F (map (/. Z (walk F Z)) [X | Y]))
  F X -> (F X))

(define compile
  F X Err -> (let O (F [X []])
               (if (or (= (fail) O) (not (empty? (hd O))))
                   (Err O)
                   (hdtl O))))

(define fail-if
  F X -> (if (F X) (fail) X))

(define @s
  X Y -> (cn X Y))

(define tc?
  -> (value *tc*))

(define ps
  Name -> (trap-error
           (get Name source)
           (/. E (error "~A not found.~%" Name))))

(define stinput
  -> (value *stinput*))

(define vector
  N -> (let Vector (absvector (+ N 1))
            ZeroStamp (address-> Vector 0 N)
            Standard (if (= N 0) ZeroStamp (fillvector ZeroStamp 1 N (fail)))
          Standard))

(define fillvector
  Vector N N X -> (address-> Vector N X)
  Vector Counter N X -> (fillvector (address-> Vector Counter X)
                                    (+ 1 Counter) N X))

(define vector?
  X -> (and (absvector? X)
            (let X (trap-error (<-address X 0) (/. E -1))
              (and (number? X) (>= X 0)))))

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
  X -> false where (or (boolean? X) (number? X) (string? X))
  X -> (trap-error (let String (str X)
                     (analyse-symbol? String)) (/. E false)))

(define analyse-symbol?
  "" -> false
  (@s S Ss) -> (and (alpha? S)
                    (alphanums? Ss)))

(define alpha?
  S ->  (element? S ["A" "B" "C" "D" "E" "F" "G" "H" "I" "J" "K" "L" "M"
                     "N" "O" "P" "Q" "R" "S" "T" "U" "V" "W" "X" "Y" "Z"
                     "a" "b" "c" "d" "e" "f" "g" "h" "i" "j" "k" "l" "m"
                     "n" "o" "p" "q" "r" "s" "t" "u" "v" "w" "x" "y" "z"
                     "=" "*" "/" "+" "-" "_" "?" "$" "!" "@" "~" ">" "<"
                     "&" "%" "{" "}" ":" ";" "`" "#" "'" "."]))

(define alphanums?
  "" -> true
  (@s S Ss) -> (and (alphanum? S) (alphanums? Ss)))

(define alphanum?
  S -> (or (alpha? S) (digit? S)))

(define digit?
  S -> (element? S ["1" "2" "3" "4" "5" "6" "7" "8" "9" "0"]))

(define variable?
  X -> false where (or (boolean? X) (number? X) (string? X))
  X -> (trap-error (let String (str X)
                     (analyse-variable? String)) (/. E false)))

(define analyse-variable?
  (@s S Ss) -> (and (uppercase? S)
                    (alphanums? Ss)))

(define uppercase?
  S ->  (element? S ["A" "B" "C" "D" "E" "F" "G" "H" "I" "J" "K" "L" "M"
                     "N" "O" "P" "Q" "R" "S" "T" "U" "V" "W" "X" "Y" "Z"]))

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
  X -> (and (absvector? X)
            (= tuple (trap-error (<-address X 0) (/. E not-tuple)))))

(define append
  [] X -> X
  [X | Y] Z -> [X | (append Y Z)])

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
                                          (copyfromvector
                                           OldVector NewVector N (+ N 1))))

(define copyfromvector
  OldVector NewVector From To -> (trap-error
                                  (vector-> NewVector To
                                            (<-vector OldVector From))
                                  (/. E NewVector)))

(define hdv
  Vector -> (trap-error
             (<-vector Vector 1)
             (/. E (error "hdv needs a non-empty vector as an argument; not ~S~%" Vector))))

(define tlv
  Vector -> (let Limit (limit Vector)
              (cases (= Limit 0) (error "cannot take the tail of the empty vector~%")
                     (= Limit 1) (vector 0)
                     true (let NewVector (vector (- Limit 1))
                            (tlv-help Vector 2 Limit (vector (- Limit 1)))))))

(define tlv-help
  OldVector N N NewVector -> (copyfromvector OldVector NewVector N (- N 1))
  OldVector N Limit NewVector -> (tlv-help OldVector (+ N 1) Limit
                                           (copyfromvector
                                            OldVector NewVector N (- N 1))))

(define assoc
  _ [] -> []
  X [[X | Y] | _] -> [X | Y]
  X [_ | Y] -> (assoc X Y))

(define assoc-set
  Key Value [] -> [[Key | Value]]
  Key Value [[Key | _] | Rest] -> [[Key | Value] | Rest]
  Key Value [Z | Rest] -> [Z | (assoc-set Key Value Rest)])

(define assoc-rm
  Key [] -> []
  Key [[Key | _] | Rest] -> Rest
  Key [Z | Rest] -> [Z | (assoc-rm Key Rest)])

(define boolean?
  true -> true
  false -> true
  _ -> false)

(define nl
  0 -> 0
  N -> (do (output "~%") (nl (- N 1))))

(define difference
  [] _ -> []
  [X | Y] Z -> (if (element? X Z) (difference Y Z) [X | (difference Y Z)]))

(define do
  X Y -> Y)

(define element?
  _ [] -> false
  X [X | _] -> true
  X [_ | Z] -> (element? X Z))

(define empty?
  [] -> true
  _ -> false)

(define fix
  F X -> (fix-help F X (F X)))

(define fix-help
  _ X X -> X
  F _ X -> (fix-help F X (F X)))

(define put
  X Pointer Y Dict -> (let Curr (trap-error (<-dict Dict X) (/. E []))
                           Added (assoc-set Pointer Y Curr)
                           Update (dict-> Dict X Added)
                        Y))

(define unput
  X Pointer Dict -> (let Curr (trap-error (<-dict Dict X) (/. E []))
                         Removed (assoc-rm Pointer Curr)
                         Update (dict-> Dict X Removed)
                      X))

(define get
  X Pointer Dict -> (let Entry (trap-error (<-dict Dict X) (/. E []))
                         Result (assoc Pointer Entry)
                      (if (empty? Result)
                          (error "value not found~%")
                          (tl Result))))

(define hash
  S Limit -> (mod (sum (map (/. X (string->n X)) (explode S))) Limit))

(define mod
  N Div -> (modh N (multiples N [Div])))

(define multiples
  N [M | Ms] ->  Ms   where (> M N)
  N [M | Ms] -> (multiples N [(* 2 M) M | Ms]))

(define modh
  0 _ -> 0
  N [] -> N
  N [M | Ms] -> (if (empty? Ms)
                    N
                    (modh N Ms))
      where (> M N)
  N [M | Ms] -> (modh (- N M) [M | Ms]))

(define sum
  [] -> 0
  [N | Ns] -> (+ N (sum Ns)))

(define head
  [X | _] -> X
  _ -> (error "head expects a non-empty list"))

(define tail
  [_ | Y] -> Y
  _ -> (error "tail expects a non-empty list"))

(define hdstr
  S -> (pos S 0))

(define intersection
  [] _ -> []
  [X | Y] Z -> (if (element? X Z)
                   [X | (intersection Y Z)]
                   (intersection Y Z)))

(define reverse
  X -> (reverse_help X []))

(define reverse_help
  [] R -> R
  [X | Y] R -> (reverse_help Y [X | R]))

(define union
  [] X -> X
  [X | Y] Z -> (if (element? X Z)
                   (union Y Z)
                   [X | (union Y Z)]))

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

(define subst
  X Y Y -> X
  X Y Z -> (map (/. W (subst X Y W)) Z)  where (cons? Z)
  _ _ Z -> Z)

(define explode
  X -> (explode-h (make-string "~A" X)))

(define explode-h
  "" -> []
  (@s S Ss) -> [S | (explode-h Ss)])

(define cd
  Path -> (set *home-directory* (if (= Path "") "" (make-string "~A/" Path))))

(define for-each
  F [] -> true
  F [X | Xs] -> (let _ (F X)
                  (for-each F Xs)))

(define map
   _ [] -> []
   F [X | Y] -> [(F X) | (map F Y)]
   F X -> (F X))

(define length
  X -> (length-h X 0))

(define length-h
  [] N -> N
  X N -> (length-h (tl X) (+ N 1)))

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
  F [X | Y] -> (append (F X) (mapcan F Y)))

(define ==
  X X -> true
  _ _ -> false)

(define abort
  -> (simple-error ""))

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

(define sterror
  -> (value *sterror*))

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
  Package -> (trap-error (do (external Package) true) (/. E false)))

(define function
  F -> (lookup-func F))

(define lookup-func
  F -> (trap-error
        (get F lambda-form)
        (/. E (error "~A has no lambda expansion~%" F))))

)

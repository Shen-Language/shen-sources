\\           Copyright (c) 2010-2019, Mark Tarver

\\                  All rights reserved.

(package shen [shen]

(define shen->kl
  Shen -> (let KL (shen->kl-h Shen)
               (record-and-evaluate KL)))

(define record-and-evaluate
  [defun F Params Def] -> (let SysfuncChk (if (sysfunc? F)
                                              (error "~A is not a legitimate function name~%" F)
                                              skip)
                               Arity   (store-arity F (length Params))
                               Record  (record-kl F [defun F Params Def])
                               Eval    (eval-kl [defun F Params Def])
                               (fn-print F))
  KL -> KL)

(define shen->kl-h
  [define F | Def] -> (shendef->kldef F Def)
  [defun F Params Def] -> [defun F Params Def]
  [type X A] -> [type X (rcons_form A)]
  [input+ A S] -> [input+ (rcons_form A) S]
  [X | Y] -> (map (/. Z (shen->kl-h Z)) [X | Y])
  X -> X)

(define shendef->kldef
  F Def -> (compile (/. X (<define> X)) [F | Def]))

(defcc <define>
 <name> { <signature> } <rules> := (shendef->kldef-h <name> <rules>);
 <name> <rules> := (shendef->kldef-h <name> <rules>);)

(define shendef->kldef-h
  F Rules -> (let Ps (map (/. X (fst X)) Rules)
                  Arity (arity-chk F Ps)
                  FreeVarChk (map (/. R (free-var-chk F R)) Rules)
                  KL (factorise-code (compile-to-kl F Rules Arity))
                  KL))

(defcc <name>
  X := (if (and (symbol? X) (not (variable? X)))
           X
           (error "~A is not a legitimate function name.~%" X));)

(defcc <signature>
  X <signature> := [X | <signature>]  where (not (element? X [{ }]));
 <e> := [];)

(defcc <rules>
  <rule> <rules> := [(linearise <rule>) | <rules>];
  <!> := (if (empty? <!>) [] (error "Shen syntax error here:~% ~R~% ..." <!>));)

(define linearise
  (@p Ps A) -> (linearise-h Ps Ps [] A)
   _ -> (simple-error "implementation error in shen.linearise"))

(define linearise-h
  [] Ps _ A -> (@p Ps A)
  [[X | Y] | Z] Ps Vs A -> (linearise-h (append [X | Y] Z) Ps Vs A)
  [X | Y] Ps Vs A -> (if (element? X Vs)
                         (let Z (gensym (protect V))
                                (linearise-h Y (rep-X X Z Ps) Vs [where [= Z X] A]))
                         (linearise-h Y Ps [X | Vs] A))   where (variable? X)
  [_ | Y] Ps Vs A -> (linearise-h Y Ps Vs A)
  _ _ _ _ -> (simple-error "implementation error in shen.linearise-h"))

(defcc <rule>
  <patterns> -> Action where Guard := (@p <patterns> [where Guard Action]);
  <patterns> -> Action             := (@p <patterns> Action);
  <patterns> <- Action where Guard := (@p <patterns> [where Guard [choicepoint! Action]]);
  <patterns> <- Action             := (@p <patterns> [choicepoint! Action]);)

(defcc <patterns>
  <pattern> <patterns> := [<pattern> | <patterns>];
  <e> := [];)

(defcc <pattern>
  [<constructor> <pattern1> <pattern2>] := [<constructor> <pattern1> <pattern2>];
  [vector 0] := [vector 0];
  X := (constructor-error X) 	where (cons? X);
  <simple-pattern> := <simple-pattern>;)

(defcc <constructor>
  C := C where (constructor? C);)

(define constructor?
  C -> (element? C [cons @p @s @v]))

(define constructor-error
  X -> (error "~R is not a legitimate constructor~%" X))

(defcc <simple-pattern>
  X := (gensym (protect Y)) 	where (= X _);
  X := X 		        where (not (element? X [-> <-]));)

(defcc <pattern1>
  <pattern> := <pattern>;)

(defcc <pattern2>
  <pattern> := <pattern>;)

(define fn-print
  F -> (let V (absvector 2)
            Print (address-> V 0 printF)
            Named (address-> Print 1 (@s "(fn " (str F) ")"))
            Named))

(define printF
  V -> (<-address V 1))

(define arity-chk
  _ [P] -> (length P)
  F [P1 P2 | Ps] -> (arity-chk F [P2 | Ps])  where (= (length P1) (length P2))
  F _ -> (error "arity error in ~A~%" F))

(define free-var-chk
  Name (@p P A) -> (free-variable-error-message Name (find-free-vars (extract-vars P) A)))

(define free-variable-error-message
  Name FreeV -> (if (empty? FreeV)
                    skip
                    (do (output "free variables in ~A:" Name)
                        (map (/. X (output " ~A" X)) FreeV)
                        (nl)
                        (abort))))

(define extract-vars
  X -> [X]   where (variable? X)
  [X | Y] -> (union (extract-vars X) (extract-vars Y))
  _ -> [])

(define find-free-vars
  Bound [protect V] -> []
  Bound [let X Y Z] -> (union (find-free-vars Bound Y) (find-free-vars [X | Bound] Z))
  Bound [lambda X Y] -> (find-free-vars [X | Bound] Y)
  Bound [X | Y] -> (union (find-free-vars Bound X) (find-free-vars Bound Y))
  Bound V -> [V]    where (free-variable? V Bound)
  _ _ -> [])

(define free-variable?
  V Bound -> (and (variable? V) (not (element? V Bound))))

(define record-kl
  F KL -> (put F source KL))

(define compile-to-kl
  F Rules Arity -> (let Parameters (parameters Arity)
                        Body (scan-body F (kl-body Rules Parameters))
                        Defun [defun F Parameters (cond-form Body)]
                        Defun))

(define parameters
  0 -> []
  N -> [(gensym (protect V)) | (parameters (- N 1))])

(define cond-form
  [[true X] | _] -> X
  Body -> [cond | Body])

(define scan-body
  F [] -> [[true [f-error F]]]
  F [Case | Cases] -> (choicepoint F
                                  (gensym (protect Freeze))
                                  (gensym (protect Result))
                                  Case Cases)  where (choicepoint? Case)
  _ [[true X] | _] -> [[true X]]
  F [Case | Cases] -> [Case | (scan-body F Cases)]
  _ _ -> (simple-error "implementation error in shen.scan-body"))

(define choicepoint?
  [_ [choicepoint! _]] -> true
  _ -> false)

(define choicepoint
  F Freeze Result [Test [_ [fail-if F Action]]] Cases
  -> [[true [let Freeze [freeze [cond | (scan-body F Cases)]]
                 [if Test
                     [let Result Action
                              [if [F Result]
                                  [thaw Freeze]
                                  Result]]
                     [thaw Freeze]]]]]
  F Freeze Result [Test [_ Action]] Cases
  -> [[true [let Freeze [freeze [cond | (scan-body F Cases)]]
                 [if Test
                     [let Result Action
                        [if [= Result [fail]]
                            [thaw Freeze]
                            Result]]
                     [thaw Freeze]]]]]
  _ _ _ _ _ -> (simple-error "implementation error in shen.choicepoint"))

(define rep-X
  X V X -> V
  X V [Y | Z]-> (let Rep (rep-X X V Y)
                     (if (= Rep Y)
                         [Y | (rep-X X V Z)]
                         [Rep | Z]))
  X V Y -> Y)

(define kl-body
   Rules Parameters -> (map (/. R (triple-stack [] (fst R) Parameters (snd R))) Rules))

(define triple-stack
  Test [] [] [where P Continue] -> (triple-stack [P | Test] [] [] Continue)
  Test [] [] Continue -> [(rectify-test (reverse Test)) Continue]
  Test [Si | S] [Ti | T] Continue -> (triple-stack Test S T (beta Si Ti Continue))
                                                          where (variable? Si)
  Test [[C Sa Sb] | S] [Ti | T] Continue -> (triple-stack [[(op-test C) Ti] | Test]
                                                          [Sa Sb | S]
                                                          [[(op1 C) Ti] [(op2 C) Ti] | T]
                                                          (beta [C Sa Sb] Ti Continue))
  Test [Si | S] [Ti | T] Continue -> (triple-stack [[= Si Ti] | Test] S T Continue)
  _ _ _ _ -> (simple-error "implementation error in shen.triple-stack"))

(define rectify-test
  [] -> true
  [P] -> P
  [P Q | R] -> [and P (rectify-test [Q | R])]
  _ -> (simple-error "implementation error in shen.rectify-test"))

(define beta
  X Y X -> Y
  X _ [lambda X Y] -> [lambda X Y]
  X W [let X Y Z] -> [let X (beta X W Y) Z]
  X W [Y | Z] -> (map (/. V (beta X W V)) [Y | Z])
  _ _ X -> X)

(define op1
  cons -> hd
  @s -> hdstr
  @p -> fst
  @v -> hdv
  _ -> (simple-error "implementation error in shen.op1"))

(define op2
  cons -> tl
  @s -> tlstr
  @p -> snd
  @v -> tlv
  _ -> (simple-error "implementation error in shen.op2"))

(define op-test
  cons -> cons?
  @s -> +string?
  @p -> tuple?
  @v -> +vector?
  _ -> (simple-error "implementation error in shen.op-test"))

(define +string?
  "" -> false
  X -> (string? X))

(define +vector?
  X -> false        where (= X (vector 0))
  X -> (vector? X))

(define factorise
  + -> (set *factorise?* true)
  - -> (set *factorise?* false)
  _ -> (error "factorise expects a + or a -~%"))

(define factorise-code
  [defun F Params [cond | Cases]]
   -> [defun F Params (vertical Params Cases [f-error F])]  where (value *factorise?*)
  Code -> Code)

(define vertical
  _ [[true Result] | _] _ -> Result
  Free [] Exit -> Exit
  Free [[[and P Q] Result] | Cases] Exit
  -> (let Before+After (split-cases P [[[and P Q] Result] | Cases] [])
          (branch P Free Before+After Exit))
   Free [[Test Result] | Cases] Exit -> [if Test Result (vertical Free Cases Exit)]
   _ _ _ -> (simple-error "implementation error in shen.vertical"))

(define split-cases
  P [[[and P Ps] Result] | Cases] Before -> (split-cases P Cases [[Ps Result] | Before])
  P [[P Result] | Cases] Before -> (split-cases P Cases [[true Result] | Before])
  _ After Before -> [(reverse Before) After])

(define branch
  P Free [Before After] Exit
  -> (let Else (else Free After Exit)
          Then (then P Free Before Else)
          [if P Then Else]))

(define else
  Free After Exit -> (let Else (vertical Free After Exit)
                          (if (inline? Else)
                              Else
                              (procedure-call Free Else))))

(define procedure-call
  Free Code -> (let F (gensym else)
                    Used (remove-if-unused Free Code)
                    KL [defun F Used Code]
                    EvalKL (eval-kl KL)
                    Record (record-kl F KL)
                    [F | Used]))

(define remove-if-unused
  [] _ -> []
  [V | Vs] Code -> (if (occurs? V Code)
                       [V | (remove-if-unused Vs Code)]
                       (remove-if-unused Vs Code))
  _ _ -> (simple-error "implementation error in shen.remove-if-unused"))

(define then
  P Free Before Else -> (horizontal (selectors P Before) Free Before Else))

(define horizontal
  [] Free Before Else -> (vertical Free Before Else)
  [S | Ss] Free Before Else -> (let V (gensym (protect V))
                                  [let V S (horizontal Ss [V | Free] (subst V S Before) Else)])
  _ _ _ _ -> (simple-error "implementation error in shen.horizontal"))

(define selectors
  [C X] Before -> (let Op (op C)
                       Hd [(op1 Op) X]
                       Tl [(op2 Op) X]
                       RptedHd? (rpted? Hd Before)
                       RptedTl? (rpted? Tl Before)
                       (cases (and RptedHd? RptedTl?) [Hd Tl]
                              RptedHd? [Hd]
                              RptedTl? [Tl]
                              true []))  where (constructor? (op C))
  _ _ -> [])

(define rpted?
  X Y -> (> (occurrences X Y) 1))

(define inline?
  [X | Y] -> (and (atom? X) (inline? Y))
  X -> (atom? X))

(define op
  cons? -> cons
  +string? -> @s
  +vector? -> @v
  tuple? -> @p
  _ -> skip)  )
\* <program> := <statement> <program> | <statement>;
<statement> := <assignment> | <conditional> | <goto> | <tag>;
<assignment> := (<var> := <val>) | (++ <var>); (-- <var>);
<var> := any symbol;
<val> := any number
<conditional> := (if <test> <statement> <statement>);
<test> := (<var> <comp> <var); (<test> and <test>);
          (<test> or <test>) | (not <test>);
<comp> := > | < | =; *\

(synonyms program (list statement)
          env     (list (symbol * number)))

(datatype statement

  Var : symbol; Val : val;
  =========================
  [Var := Val] : statement;

  if (element? Op [++ --])
  Var : symbol;
  =====================
  [Op Var] : statement;

  Test : test; DoThis : statement; DoThat : statement;
  ====================================================
  [if Test then DoThis else DoThat] : statement;

  Tag : symbol;
  ======================
  [goto Tag] : statement;

  Message : string-or-val;
  ============================
  [print Message] : statement;

  Message : string;
  _________________
  Message : string-or-val;

  Message : val;
  _________________
  Message : string-or-val;

  Var : symbol;
  =========================
  [input Var] : statement;

  Tag : symbol;
  _____________
  Tag : statement;)

(datatype test

  if (element? Comp [= > <])
  Val1 : val; Val2: val;
  ======================
  [Val1 Comp Val2] : test;

  if (element? LogOp [and or])
  Test1 : test;
  Test2 : test;
  =============
  [Test1 LogOp Test2] : test;

  Test : test;
  ==================
  [not Test] : test;)


(datatype val

  ______________________________________
  (number? N) : verified >> N : number;


  _______________________________________
  (symbol? S) : verified >> S : symbol;

  Val : symbol;
  _______________
  Val : val;

  Val : number;
  _____________
  Val : val;)

\* The program that runs Minim programs is 56 lines of Qi and is given here. *\

(define run
  {program --> env}
  Program -> (run-loop Program Program []))

(define run-loop
  {program --> program --> env --> env}
  [] _ Env -> Env
  [nl | Ss] Program Env -> (do (output "~%") (run-loop Ss Program Env))
  [Tag | Ss] Program Env -> (run-loop Ss Program Env)      where (symbol? Tag)
  [[goto Tag] | _] Program Env -> (run-loop (go Tag Program) Program Env)
  [[Var := Val] | Ss] Program Env
  -> (run-loop Ss Program (change-env Var (compute-val Val Env) Env))
  [[++ Var] | Ss] Program Env
  -> (run-loop Ss Program (change-env Var (+ 1 (look-up Var Env)) Env))
  [[-- Var] | Ss] Program Env
  -> (run-loop Ss Program (change-env Var (- (look-up Var Env) 1) Env))
  [[if Test then DoThis else DoThat] | Ss] Program Env
  -> (if (perform-test? Test Env)
         (run-loop [DoThis | Ss] Program Env)
         (run-loop [DoThat | Ss] Program Env))
  [[print M] | Ss] Program Env -> (do (output "~A" (look-up M Env))
                                      (run-loop Ss Program Env))
  where (symbol? M)
  [[print M] | Ss] Program Env -> (do (output "~A" M)
                                      (run-loop Ss Program Env))
  [[input Var] | Ss] Program Env
  -> (run-loop Ss Program (change-env Var (input+ : number) Env)) )

(define compute-val
  {val --> env --> number}
  N _ -> N  where (number? N)
  Var Env -> (look-up Var Env)      where (symbol? Var))

(define go
  {symbol --> program --> program}
  Tag [Tag | Program] -> Program
  Tag [_ | Program] -> (go Tag Program)
  Tag _ -> (error "cannot go to tag ~A~%" Tag))

(define perform-test?
  {test --> env --> boolean}
  [Test1 and Test2] Env -> (and (perform-test? Test1 Env)
                                (perform-test? Test2 Env))
  [Test1 or Test2] Env -> (or (perform-test? Test1 Env)
                              (perform-test? Test2 Env))
  [not Test] Env -> (not (perform-test? Test Env))
  [V1 = V2] Env -> (= (compute-val V1 Env) (compute-val V2 Env))
  [V1 > V2] Env -> (> (compute-val V1 Env) (compute-val V2 Env))
  [V1 < V2] Env -> (< (compute-val V1 Env) (compute-val V2 Env)))

(define change-env
  {symbol --> number --> env --> env}
  Var Val [] -> [(@p Var Val)]
  Var Val [(@p Var _) | Env] -> [(@p Var Val) | Env]
  Var Val [Binding | Env] -> [Binding | (change-env Var Val Env)])

(define look-up
  {symbol --> env --> number}
  Var [] -> (error "~A is unbound.~%" Var)
  Var [(@p Var Val) | _] -> Val
  Var [_ | Env] -> (look-up Var Env))

\* (run [      [print "Add x and y"]
               nl
               [print "Input x: "]
               [input x]
               nl
               [print "Input y: "]
               [input y]
               main
               [if [x = 0] then [goto end] else [goto sub1x]]


      		 sub1x
       		[-- x]
       		[++ y]
       		[goto main]


       end
       nl
       [print "The total of x and y is "]
       [print y]
       nl] ) *\

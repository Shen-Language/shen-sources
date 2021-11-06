\\(package c- []

(synonyms preamble (list statement))

(datatype program

  Preamble : preamble; Main : main;
  =========================================
  [Preamble Main] : program;)

(datatype preamble

  ______________
  [] : preamble;

  [declare | Declaration] : declaration; Preamble : preamble;
  ===========================================================
  [[declare | Declaration] | Preamble] : preamble;

  [procedure | Proc] : procedure; Preamble : preamble;
  ====================================================
  [[procedure | Proc] | Preamble] : preamble;

  [assign | Assignment] : assignment; Preamble : preamble;
  ====================================================
  [[assign | Assignment] | Preamble] : preamble;)

(datatype main

  Statement : statement;
  ==========================
  [main [] Statement] : main;)

(datatype statement

     Statements : (list statement);
     ==================================
     [compound | Statements] : statement;

     [printf | Rest] : print;
     ===========================
     [printf | Rest] : statement;

     [assign | Rest] : assignment;
     =============================
     [assign | Rest] : statement;

     [assignref | Rest] : assignment;
     =============================
     [assignref | Rest] : statement;

     [if | Rest] : conditional;
     ==========================
     [if | Rest] : statement;

     [while | Rest] : while;
     ===========================
     [while | Rest] : statement;

     [declare | Rest] : declaration;
     ===============================
     [declare | Rest] : statement;

     E : expr;
     ======================
     [return E] : statement;)

(datatype assignment

  VectorRef : expr; Expr : expr;
  =====================================
  [assignref VectorRef Expr] : assignment;

  Variable : symbol; Expr : expr;
  =====================================
  [assign Variable Expr] : assignment;)

(datatype expr

   X : symbol;
   _______________
   X : expr;

  X : constant;
  _______________
  X : expr;

  Prefix : op; Exprs : (list expr);
  =================================
  [Prefix | Exprs] : expr;)

(datatype op

  Op : symbol;
  __________________
  Op : op;

  Op : infix;
  __________
  Op : op;

  if (element? Op [and or > < >= <= equals * + - /])
  ____________________________________________________
  Op : infix;)

(datatype conditional

  Test : expr; Statement1 : statement; Statement2 : statement;
  ============================================================
  [if Test then Statement1 else Statement2] : conditional;

  Test : expr; Statement : statement;
  ======================================
  [if Test then Statement] : conditional;)

(datatype constant

   C : string;
   ___________
   C : constant;

   C : number;
   _______________
   C : constant;)

(datatype integer

  if (integer? N)
   ____________
  N : integer;

  if (element? Op [+ - *])
  M : integer; N : integer;
  ___________________________
  (Op M N) : integer;

  N : integer;
  _____________________
  N : number;)

(datatype print

  String : string; Exprs : (list expr);
  =====================================
  [printf String | Exprs] : print;)

(datatype while

   Condition : expr; Do : statement;
   =================================
   [while Condition Do] : while;)

(datatype parameters

  __________________
  [] : parameters;

  Type : type; Variable : symbol; Parameters : parameters;
  ==============================================================
  [Type Variable | Parameters] : parameters;)

(datatype declaration

  Type : type; Variables : (list symbol);
  =============================================
  [declare Type Variables] : declaration;

  Type : type; Variable : symbol; Dim : integer;
  ===================================================
  [declare [vector Type] Variable Dim] : declaration;)

(datatype type

 if (element? T [int char float])
 ________________________
 T : type;)

(datatype procedure

  Type : type; Name : symbol; Parameters : parameters; Body : statement;
  ======================================================================
  [procedure Type Name Parameters Body] : procedure;)

(datatype parameters

  __________________
  [] : parameters;

  Type : type; Variable : symbol; Parameters : parameters;
  ========================================================
  [Type Variable | Parameters] : parameters;)

(define c-minus
  {string --> program}
   File -> (compile (fn <program>) (read-file-as-unit-strings File)))

(define read-file-as-unit-strings
  {string --> (list string)}
   File -> (map (fn n->string) (read-file-as-bytelist File)))

(defcc <program>
  {(list string) ==> program}
   <ws> <preamble> <ws> <main> <ws> := [<preamble> <main>];)

(defcc <preamble>
  {(list string) ==> preamble}
   <statements>;
   <e> := [];)

(defcc <main>
  {(list string) ==> main}
  ($ main) <ws> "(" <ws> ")" <ws> <statement> <ws> ";" <ws> := [main [] <statement>];)

(defcc <statement>
  {(list string) ==> statement}
  <atomic-statement>;
  <compound-statement>;)

(defcc <compound-statement>
  {(list string) ==> statement}
  <ws> "{" <ws> <statements> <ws> "}" <ws> := [compound | <statements>];)

(defcc <statements>
  {(list string) ==> (list statement)}
  <statement> <ws> ";" <ws> <statements> := [<statement> | <statements>];
  <statement> <ws> ";" := [<statement>];)

(defcc <atomic-statement>
  {(list string) ==> statement}
 \\ <procedure>;
  <declaration>;
  <print>;
  <assignment>;
  <conditional>;
  <while>;
  <return>;)

(defcc <assignment>
  {(list string) ==> statement}
   <vector-ref> <ws> "=" <ws> <expr> := [assignref <vector-ref> <expr>];
   <variable> <ws> "=" <ws> <expr> := [assign <variable> <expr>];)

(defcc <return>
  {(list string) ==> statement}
   <ws> ($ return) <ws> <expr> <ws> := [return <expr>];)

(defcc <conditional>
   {(list string) ==> statement}
   <ws> ($ if) <ws> <expr>
          <ws> ($ then) <ws> <statement1>
          <ws> ($ else) <ws> <statement2> <ws>
         := [if <expr> then <statement1> else <statement2>];
   <ws> ($ if) <ws> <expr> <ws> ($ then) <ws> <statement> <ws>
    := [if <expr> then <statement>];)

(defcc <statement1>
   {(list string) ==> statement}
   <statement>;)

(defcc <statement2>
  {(list string) ==> statement}
   <statement>;)

(defcc <exprs>
    {(list string) ==> (list expr)}
    <expr> <ws> "," <ws> <exprs> := [<expr> | <exprs>];
    <expr> := [<expr>];
    <e> := [];)

(defcc <expr>
   {(list string) ==> expr}
    <vector-ref>; <complex>; <variable>;  <constant>;)

(defcc <vector-ref>
   {(list string) ==> expr}
   <variable> <ws> <index> := [ref <variable> <index>];)

(defcc <index>
   {(list string) ==> expr}
   "[" <ws> <expr> <ws> "]" := <expr>;)

(defcc <complex>
  {(list string) ==> expr}
  <ws>  "(" <ws> <expr1> <ws> <infix> <ws> <expr2> ")" <ws>
     := [<infix> <expr1> <expr2>];
  <ws> <prefix> <ws> "(" <ws> <exprs> <ws> ")" <ws>
     := [<prefix> | <exprs>];)

(defcc <expr1>
    {(list string) ==> expr}
   <expr>;)

(defcc <expr2>
    {(list string) ==> expr}
    <expr>;)

(defcc <prefix>
  {(list string) ==> symbol}
  <alphanumeric> := (string->symbol <alphanumeric>);)

(defcc <infix>
  {(list string) ==> infix}
  "&" "&" := and;
  "|" "|" := or;
  ">" := >;
  "<" := <;
  ">" "=" := >=;
  "<" "=" := <=;
  "=" "=" := equals;
   "*" := *;
   "+" := +;
   "-" := -;
   "/" := /;)

(defcc <constant>
   {(list string) ==> constant}
   <float> := <float>;
   <int> := <int>;
   <char> := <char>;)

(defcc <float>
  {(list string) ==> number}
  <pre> "." <post> := (compute-float <pre> <post>);)

(defcc <pre>
  {(list string) ==> (list integer)}
   <int-h> := <int-h>;)

(defcc <post>
  {(list string) ==> (list integer)}
  <int-h> := <int-h>;)

(define compute-float
  {(list integer) --> (list integer) --> number}
   Pre Post -> (+ (compute-int Pre) (compute-fractional Post)))

(define compute-int
  {(list integer) --> integer}
  [] -> 0
  [N | Ns] -> (+ (* N (exptint 10 (intlength Ns))) (compute-int Ns)))

(define compute-fractional
  {(list integer) --> number}
   Post -> (compute-fractional-h Post 1))

(define compute-fractional-h
  {(list integer) --> integer --> number}
  [] _ -> 0
  [N | Ns] Expt -> (+ (/ N (exptint 10 Expt)) (compute-fractional-h Ns (+ Expt 1))))

(define exptint
  {integer --> integer --> integer}
   _ 0 -> 1
   M N -> (* M (exptint M (- N 1))))

(defcc <char>
  {(list string) ==> string}
   "'" C "'" := C;)

(defcc <int>
  {(list string) ==> integer}
  <int-h> := (compute-int <int-h>);)

(defcc <int-h>
  {(list string) ==> (list integer)}
  <numeric> <int-h> := [(digit <numeric>) | <int-h>];
  <numeric> := [(digit <numeric>)];)

(defcc <numeric>
  {(list string) ==> string}
  X := X        where (element? X ["0" "1" "2""3""4""5" "6" "7" "8" "9"]);)

(define digit
  {string --> integer}
  "0" -> 0
  "1" -> 1
  "2" -> 2
  "3" -> 3
  "4" -> 4
  "5" -> 5
  "6" -> 6
  "7" -> 7
  "8" -> 8
  "9" -> 9)

(define intlength
  {(list A) --> integer}
  [] -> 0
  [_ | Y] -> (+ 1 (intlength Y)))

(defcc <print>
  {(list string) ==> statement}
  <ws> ($ printf) <ws> "(" <ws> <string> <ws> <exprs> <ws> ")" <ws>
      := [printf <string> | <exprs>];)

(defcc <string>
  {(list string) ==> string}
  "c#34;" <stringstuff> "c#34;" := <stringstuff>;)

(defcc <stringstuff>
  {(list string) ==> string}
   "/" "n" <stringstuff> := (@s "c#13;" <stringstuff>);
   "/" "i" <stringstuff> := (@s "~A" <stringstuff>);
   <ndq> <stringstuff> := (@s <ndq> <stringstuff>);
   <e> := "";)

(defcc <ndq>
   {(list string) ==> string}
    X := X  	where (not (= "c#34;" X));)

(defcc <while>
   {(list string) ==> statement}
   <ws> ($ while) <ws> <expr> <ws> <statement> <ws>
   := [while <expr> <statement>];)

(defcc <declaration>
  {(list string) ==> statement}
  <ws> <type> <space> <ws> <variables> := [declare <type> <variables>];
  <ws> <type> <space> <ws> <variable> <ws> <dim>
  := [declare [vector <type>] <variable> <dim>];)

(defcc <dim>
 {(list string) ==> integer}
"[" <ws> <int> <ws> "]" := <int>;)

(defcc <type>
 {(list string) ==> type}
  ($ int) := int;
  ($ char) := char;
  ($ float) := float;)

(defcc <variables>
 {(list string) ==> (list symbol)}
 <variable> <ws> "," <ws> <variables> := [<variable> | <variables>];
 <variable> := [<variable>];)

(defcc <variable>
 {(list string) ==> symbol}
 <alphanumeric> := (string->symbol <alphanumeric>);)

(defcc <alphanumeric>
  {(list string) ==> string}
  <alpha> <alphanumeric-h> := (@s <alpha> <alphanumeric-h>);)

(defcc <alphanumeric-h>
  {(list string) ==> string}
  <alpha> <alphanumeric-h> := (@s <alpha> <alphanumeric-h>);
  <numeric> <alphanumeric-h> := (@s <numeric> <alphanumeric-h>);
  <e> := "";)

(defcc <alpha>
  {(list string) ==> string}
  S := S where (or (alpha*? S) (= "_" S));)

(define alpha*?
  {string --> boolean}
   S -> (let N (string->n S)
             (or (and (> N 96) (< N 123))
                 (and (> N 64) (< N 91)))))

(defcc <numeric>
  {(list string) ==> string}
  X := X          where (element? X ["0" "1" "2""3""4""5""6""7""8""9"]);)

(defcc <procedure>
  {(list string) ==> procedure}
  <ws> <type> <ws> <procname> <ws> "(" <params> ")" <ws> <statement> <ws> :=
    [procedure <type> <procname> <params> <statement>];)

(defcc <params>
  {(list string) ==> parameters}
  <ws> <type> <variable> <ws> "," <ws> <params> := [<type> <variable> | <params>];
  <ws> <type> <ws> <variable> <ws> := [<type> <variable>];
  <ws> := [];)

(defcc <procname>
  {(list string) ==> symbol}
  <alphanumeric> := a \\(string->symbol <alphanumeric>)   where (not (== <alphanumeric> main));)
    ;)
\\(defcc <params>
 \\ {(list string) ==> parameters}
 \\ <ws> <type> <variable> <ws> "," <ws> <params> := [<type> <variable> | <params>];
 \\ <ws> <type> <ws> <variable> <ws> := [<type> <variable>];
 \\ <ws> := [];)

(defcc <ws>
  {(list string) ==> symbol}
  <comment> <ws> := skip;
  <space> <ws> := skip;
  <tab> <ws> := skip;
  <newline> <ws> := skip;
  <e> := skip;)

(defcc <space>
  {(list string) ==> symbol}
  X := skip      where (= (string->n X) 32);)

(defcc <tab>
  {(list string) ==> symbol}
  X := skip      where (= (string->n X) 9);)

(defcc <newline>
  {(list string) ==> symbol}
  X := skip      where (element? (string->n X) [10 13]);)

(defcc <comment>
  {(list string) ==> symbol}
  "/" "*" <comment-body> := skip;)

(defcc <comment-body>
  {(list string) ==> symbol}
  "/" "*" := skip!;
  _ <comment-body> := skip;)
  \\)

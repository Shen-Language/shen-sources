(define assume
  {(list string) --> symbol}
   Files -> (kb-> (mapcan (fn tptp->props) Files)))
   
(define ask
  {string --> boolean}
   File -> (let Props (tptp->props File)
                Prop  (hd Props)
                (<-kb Prop)))  

(define tptp->props
  {string --> (list prop)}
   File -> (let ASCII (read-file-as-bytelist File)
                Props (compile (fn <axioms>) ASCII)
                Props))

(defcc <axioms>
  {(list number) ==> (list prop)}
  <comments> <axiom> <axioms>   := [<axiom> | <axioms>];
  <comments> <axiom> <comments> := [<axiom>];)

(defcc <comments>
  {(list number) ==> symbol}
  <comment> <comments> := skip;
  <ws>                 := skip;)      
  
(defcc <comment>  
  {(list number) ==> symbol}
  <percent> <linefeed> := skip;)

(defcc <percent>
  {(list number) ==> symbol}
  <ws> 37 := skip;)
    
(defcc <linefeed>
  <newline>    := skip;
  _ <linefeed> := skip;)
  
(defcc <newline>
  {(list number) ==> symbol}
   10 := skip;
   13 := skip;)     
  
(defcc <axiom> 
  {(list number) ==> prop}  
  <preamble> <formula> <right> <stop> := <formula>;)   
  
(defcc <preamble>
  {(list number) ==> symbol}
  <fof> <left> <name> <comma> <name> <comma> := skip;
  <cnf> <left> <name> <comma> <name> <comma> := skip;) 
  
(defcc <fof>
   {(list number) ==> symbol}
   <ws> 102 111 102 := skip;)
   
(defcc <cnf>
  {(list number) ==> symbol}
   <ws> 99 110 102 := skip;)   
   
(defcc <name>
  {(list number) ==> symbol}
  <ws> <alpha> <alphanums> := skip;)
  
(defcc <stop>
  {(list number) ==> symbol}
  <ws> 46 := skip;) 
    
(defcc <formula>
  {(list number) ==> prop}
  <quantifier> <variables> <colon> <formula>
   := (dist-quantifier <quantifier> <variables> <formula>);
  <left> <formula> <connective> <formulas> <right> := (fully-paren [<formula> <connective> | <formulas>]);
  <not> <formula> := [<not> <formula>];
  <atom> := <atom>;)
  
(define fully-paren
  [P & Q & R | S] -> (fully-paren [[P & Q] & R | S])
  [P v Q v R | S] -> (fully-paren [[P v Q] v R | S])
  P -> P)    
  
(define dist-quantifier
  Q [] P -> P
  Q [X | Y] P -> (dist-quantifier Q Y [Q X P]))  
  
(defcc <colon>
  <ws> 58 := skip;) 
  
(defcc <variables>
   <lsb> <variable-list> <rsb> := <variable-list>;)
  
(defcc <variable-list>
  <variable> <comma> <variable-list> := [<variable> | <variable-list>];
  <variable> := [<variable>];) 
  
(defcc <variable>
  <ws> <alpha> <alphanums> := (intern (cn <alpha> <alphanums>));)    
  
(defcc <lsb>
  {(list number) ==> skip}
  <ws> 91 := skip;)  
  
(defcc <rsb>
  {(list number) ==> skip}
  <ws> 93 := skip;)       
  
(defcc <quantifier>
  {(list number) ==> string}
    <universal>;
    <existential>;)
    
(defcc <universal>
  {(list number) ==> quantifier}
   <ws> 33  := all;)
   
(defcc <existential>
  {(list number) ==> quantifier}         
   <ws> 63 := exists;)
   
(defcc <connective>
   {(list number) ==> connective}
    <or>; <and>; <if>; <iff>;)
    
(defcc <or>
   {(list number) ==> connective}
    <ws> 124 := v;) 
    
(defcc <and>
   {(list number) ==> connective}
    <ws> 38 := &;) 
    
(defcc <if>
   {(list number) ==> connective}
    <ws> 61 62 := =>;)
    
(defcc <iff>
   {(list number) ==> connective}
    <ws> 60 61 62 := (intern "<=>");)         
         
(defcc <not>
   {(list number) ==> tilde}
    <ws> 126 := ~;)     
   
(defcc <formulas>
  {(list number) ==> prop}
  <formula> <connective> <formulas> := [<formula> <connective> | <formulas>];
  <formula> := [<formula>];)  
  
(defcc <atom>
  {(list number) ==> prop}
  <inequality>  := <inequality>;
  <equality>    := <equality>;
  <predicate> <left> <terms> <right> := [(intern <predicate>) | <terms>];
  <proposition> := <proposition>;)
  
(defcc <inequality>
  <term1> <!=> <term2> := [~ [<term1> = <term2>]];)
   
(defcc <equality>
  <term1> <=> <term2> := [<term1> = <term2>];)    
  
(defcc <proposition>
  <ws> <alpha> <alphanums> := (intern (cn <alpha> <alphanums>));)  
  
(defcc <term1>
  <term> := <term>;)
  
(defcc <term2>
  <term> := <term>;)
  
(defcc <term>
  <complex-term>;
  <simple-term> := (intern <simple-term>);) 
  
(defcc <complex-term>
  <functor> <left> <terms> <right> := [<functor> | <terms>];)
  
(defcc <terms>
  <term> <comma> <terms> := [<term> | <terms>];
  <term>                 := [<term>];)
  
(defcc <comma>
  {(list number) ==> symbol}
  <ws> 44 := skip;)           
  
(defcc <functor>
   {(list number) ==> string}
  <ws> <alpha> <alphanums> := (intern (cn <alpha> <alphanums>));)    
  
(defcc <simple-term>
  {(list number) ==> string}
  <ws> <alphanums> := <alphanums>;)     
  
(defcc <=>
  {(list number) ==> symbol}
    <ws> 61 X := skip  where (not (= X 62));)
    
(defcc <!=>
  {(list number) ==> symbol}
    <ws> 33 61 := skip;)      
    
(defcc <predicate>
  {(list number) ==> string}
  <ws> <alpha> <alphanums> := (cn <alpha> <alphanums>);)
  
(defcc <alphanums>
  {(list number) ==> string}
  <num> <alphanums>        := (cn <num> <alphanums>);
  <alpha> <alphanums>      := (cn <alpha> <alphanums>);
  <underscore> <alphanums> := (cn <underscore> <alphanums>);
  <e>                 := "";)
  
(defcc <num>
  {(list number) ==> string}
  Byte := (n->string Byte) where (interval? Byte 48 57);)
  
(define interval?
  {number --> number --> number --> boolean}
   N Lower Upper -> (and (>= N Lower) (<= N Upper)))
   
(defcc <alpha>
  {(list number) ==> string}
   Byte := (n->string Byte) where (or (interval? Byte 97 122)
                                      (interval? Byte 65 90));)      
  
(defcc <underscore>
  {(list number) ==> string}
  95 := "_";)
  
(defcc <left>
  {(list number) ==> symbol} 
  <ws> 40 := skip;) 
  
(defcc <right>
  {(list number) ==> symbol} 
  <ws> 41 := skip;)   
  
(defcc <ws>
  {(list number) ==> symbol}
  <space> <ws>   := skip;
  <newline> <ws> := skip;
  <tab> <ws>     := skip;
  <e>            := skip;)
  
(defcc <space>
  {(list number) ==> symbol}
   32 := skip;)
     
(defcc <tab>
  {(list number) ==> symbol}
  9 := skip;)          
  
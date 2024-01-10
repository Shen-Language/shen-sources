(defcc <sexprs>
  {(list number) ==> (list sexpr)}
   <sexpr> <wss> <sexprs> := [<sexpr> | <sexprs>];
   <e> := [];)

(defcc <sexpr>
  {(list number) ==> sexpr}
   <lparen> <sexprs> <rparen> := <sexprs>;
   <atom>;)

(defcc <lparen>
  {(list number) ==> symbol}
  40 := skip;)

(defcc <rparen>
  {(list number) ==> symbol}
  41 := skip;)

(defcc <wss>
  {(list number) ==> symbol}
  <ws> <wss> := skip;
  <e> := skip;)

(defcc <ws>
  {(list number) ==> symbol}
   9 := skip;
   10 := skip;
   13 := skip;
   32 := skip;)

(defcc <atom>
  {(list number) ==> atom}
  <string>; <symbol>; <number>;)

(defcc <string>
  {(list number) ==> string}
  <dquote> <contents> <dquote> := <contents>;)

(defcc <contents>
  {(list number) ==> string}
  <content> <contents> := (cn <content> <contents>);
  <e> := "";)

(defcc <content>
  {(list number) ==> string}
  Byte := (n->string Byte)   where (not (= Byte 34));)

(defcc <symbol>
  {(list number) ==> string}
  Byte := (n->string Byte)   where (not (= Byte 34));)


(datatype sexpr

 S : string;
 ____________
 S : sexpr;

 S : symbol;
 ___________
 S : sexpr;





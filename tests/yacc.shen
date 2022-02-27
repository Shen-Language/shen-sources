(defcc <sent>
 {(list symbol) ==> (list symbol)}
<np> <vp>;)

(defcc <det>
{(list symbol) ==> (list symbol)}
the; a;)

(defcc <np>
{(list symbol) ==> (list symbol)}
<det> <n>;
<name1>;)

(defcc <n>
 {(list symbol) ==> (list symbol)}
cat; dog;)

(defcc <name1>
{(list symbol) ==> (list symbol)}
 X := [X]	where (element? X [bill ben]);)

(defcc <vp>
{(list symbol) ==> (list symbol)}
<vtrans> <np>;)

(defcc <vtrans>
{(list symbol) ==> (list symbol)}
likes; chases;)

(defcc <des>
[<ds>] [<es>] := (append <ds> <es>);)

(defcc <ds>
  d <ds>;
  d;)

(defcc <es>
  e <es>;
  e;)

(defcc <sent'>
<np> <vp> := (question <np> <vp>);)

(define question
NP VP -> (append [is it true that your father] VP [?]))

(defcc <as->bs>
  a <a->bs> := [b | <a->bs>];
  a := [b];)

(defcc <find-digit>
  <digit> <morestuff> := <digit>;
  <digit> := <digit>;
  X <find-digit> := <find-digit>;)

(defcc <morestuff>
  X <morestuff>;
  X;)

(defcc <digit>
0; 1; 2; 3; 4; 5; 6; 7; 8; 9;)

(defcc <find-digit'>
  <digit> <morestuff>;
  <digit> := <digit>;
  X <find-digit'> := <find-digit'>;)

(defcc <asbscs>
  <as> <bs> <cs>;)

(defcc <as>
  a <as>;
  a;)

(defcc <bs>
b <bs>;
b;
<e>;)

(defcc <cs>
c <cs>;
c;)

(defcc <asbs'cs>
  <as> <bs'> <cs>;)

(defcc <bs'>
b <bs'>;
b;
<e>;)

(defcc <find-digit''>
  <digit''> <morestuff> := <digit''>;
  <digit''> := <digit''>;
  X <find-digit''> := <find-digit''>;)

(defcc <digit''>
  X := X  where (element? X [0 1 2 3 4 5 6 7 8 9]);)

(defcc <anbncn>
<as> <bs> <cs> := (appendall [<as> <bs> <cs>])
                       where (equal-length? [<as> <bs> <cs>]);)

(defcc <as>
a <as>;
a;)

(defcc <bs>
b <bs>;
b;)

(defcc <cs>
c <cs>;
c;)

(define equal-length?
[] -> true
[L] -> true
[L1 L2 | Ls] -> (and (= (length L1) (length L2)) (equal-length? [L2 | Ls])))

(define appendall
[] -> []
[L | Ls] -> (append L (appendall Ls)))

(defcc <a*s>
   [a] := a;)

 (defcc <b*>
  [b] b;)

 (defcc <c*>
   [<c*>] := [<c*>];
   c;)

 (defcc <d*>
    [<d*>] <d*> := [[<d*>] | <d*>];
    d <d*> := [d | <d*>];
    d := [d];)


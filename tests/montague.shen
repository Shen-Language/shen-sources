(datatype t

   if (not (element? t [~ v & => <=> e! a!]))
   T : symbol;
   ________
   T : t;
   _______________
   (gensym v) : t;)

(datatype f

  F : t; T : (list t);
  ____________________
  [F | T] : f;

 (not (= F ~)) : verified;
  F : t, T : t >> P;
 ___________________
 [F T] : f >> P;

 (not (element? C [v & => <=>])) : verified;
 (not (element? F [e! a!])) : verified;
  F : t, T1 : t, T2 : t >> P;
 ____________________________
 [F T1 T2] : f >> P;

 P : f;
 ==========
 [~ P] : f;

  if (element? C [v & => <=>])
  P : f; Q : f;
  =============
  [P C Q] : f;

  X : t; P : f;
  =============
  [e! X P] : f;

  X : t; P : f;
  =============
  [a! X P] : f;)

(defcc <sent>
  {(list t) ==> f}
  <np> <vp> := (<np> <vp>);)

(defcc <np>
  {(list t) ==> ((t --> f) --> f)}
  Name := (/. P (P Name))   where (name? Name);
  <det> <rcn> := (<det> <rcn>);
  <det> <cn> := (<det> <cn>);)

(define name?
  {t --> boolean}
   Name -> (variable? Name))

(defcc <cn>
   {(list t) ==> (t --> f)}
   CN := (/. X [CN X])     where (common-noun? CN);)

(define common-noun?
   {t --> boolean}
    CN -> (element? CN [girl boy dog cat]))

(defcc <rcn>
   {(list t) ==> (t --> f)}
   <cn> that <vp> := (/. X [(<cn> X) & (<vp> X)]);
   <cn> that <np> <trans> := (/. X [(<cn> X) & (<np> (/. Y (<trans> Y X)))]);)

(defcc <vp>
   {(list t) ==> (t --> f)}
   <intrans>;
   <trans> <np> := (/. X (<np> (/. Y (<trans> X Y))));)

(defcc <intrans>
  {(list t) ==> (t --> f)}
    Intrans := (/. X [Intrans X])   where (intrans? Intrans);)

(define intrans?
   {t --> boolean}
    Intrans -> (element? Intrans [runs jumps walks]))

(defcc <trans>
   {(list t) ==> (t --> t --> f)}
    Trans := (/. X Y [Trans X Y])   where (trans? Trans);)

(define trans?
   {t --> boolean}
   Trans -> (element? Trans [likes greets admires]))

(defcc <det>
  {(list t) ==> ((t --> f) --> ((t --> f) --> f))}
   some := (let V (type (gensym v) t) (/. P Q [e! V [(P V) & (Q V)]]));
   every := (let V (type (gensym v) t) (/. P Q [a! V [(P V) => (Q V)]]));
   no      := (let V (type (gensym v) t) (/. P Q [a! V [(P V) => [~ (Q V)]]]));)
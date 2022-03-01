(defprolog prop
  A C <-- (proph [[~  C] | A]);)

(defprolog proph
  A                       <-- (inconsistent A) !;
  A                       <-- (consistent A) ! (when false);
  (- [[P & Q] | A])       <-- ! (proph (append A [P Q]));
  (- [[P <=> Q] | A])     <-- ! (proph [[P => Q] [Q => P] | A]);
  (- [[P => Q] | A])      <-- ! (proph [[[~ P] v Q] | A]);
  (- [[P v Q] | A])       <-- ! (proph (append A [P])) ! (proph (append A [Q]));
  (- [[~ [~ P]] | A])     <-- ! (proph (append A [P]));
  (- [[~ [P v Q]] | A])   <-- ! (proph (append A [[~ P] [~ Q]]));
  (- [[~ [P & Q]] | A])   <-- ! (proph [[[~ P] v [~ Q]] | A]);
  (- [[~ [P => Q]] | A])  <-- ! (proph (append A [P [~ Q]]));
  (- [[~ [P <=> Q]] | A]) <-- ! (proph [[~ [[P => Q] & [Q => P]]] | A]);
  (- [P | Ps])            <-- ! (proph (append Ps [P]));)

(defprolog inconsistent
   [P | Ps] <-- (complement P NotP) (member NotP Ps) !;
   [_ | Ps] <-- (inconsistent Ps);)

(defprolog consistent
  [] <--;
  [P | Ps]     <-- (when (symbol? P)) ! (consistent Ps);
  [[~ P] | Ps] <-- (when (symbol? P)) (consistent Ps);)

(defprolog complement
  [~ P] P <-- !;
  P [~ P] <--;)

(defprolog member
  X (- [X | _]) <--;
  X (- [_ | Y]) <-- (member X Y);)
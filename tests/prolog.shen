(defprolog f
  a <--;)

(defprolog g
  a <-- ! (f b);
  X <-- (f a);)

(defprolog mem
  X [X | _] <--;
  X [Y | Z] <-- (mem X Z);)

(defprolog app
  [] X X <--;
  [X | Y] W [X | Z] <-- (app Y W Z);)

(defprolog rev
  [] [] <--;
  [X | Y] Z <-- (rev Y W) (app W [X] Z);)

(defprolog enjoys
  willi X <-- (enjoys mark X);
  mark chocolate <--;
  mark tea <--;) enjoys

(defprolog fads
  X <-- (findall Y [enjoys X Y] Friends) (return Friends);) fads

(defprolog prop
  A C <-- (proph [[~  C] | A]);) prop

(defprolog proph
  A <-- (mem [~ P] A) (mem P A) !;
  A <-- (consistent A) ! (when false);
  (mode [[P & Q] | A] -) <-- ! (proph [P Q | A]);
  (mode [[P <=> Q] | A] -) <-- ! (proph [[P => Q] [Q => P] | A]);
  (mode [[P => Q] | A] -) <-- ! (proph [[[~ P] v Q] | A]);
  (mode [[~ [P v Q]] | A] -)  <-- ! (proph [[~ P] [~ Q] | A]);
  (mode [[~ [P & Q]] | A] -) <-- ! (proph [[[~ P] v [~ Q]] | A]);
  (mode [[~ [P => Q]] | A] -) <-- ! (proph [P [~ Q] | A]);
  (mode [[~ [P <=> Q]] | A] -) <-- ! (proph [[~ [[P => Q] v [~ [Q => P]]]] | A]);
  (mode [[P & Q] | A] -) <-- !  (proph [P Q | A]);
  (mode [[P v Q] | A] -) <-- !  (proph [P | A]) ! (proph [Q | A]);
  (mode [P | Ps] -) <-- (app Ps [P] Qs) ! (proph Qs);)

(defprolog consistent
  [] <--;
  [P | Ps] <-- (when (symbol? P)) ! (consistent Ps);
  [[~ P] | Ps] <-- (when (symbol? P)) ! (consistent Ps);)

(defprolog app
  [] X X <--;
  (mode [X | Y] -) W [X | Z] <-- (app Y W Z);)

(defprolog mem
  X (mode [X | _] -) <--;
  X (mode [_ | Y] -) <-- (mem X Y);)

(defprolog mapit
  _  []  [] <--;
  Pred [X | Y] [W | Z] <-- (call [Pred X W])  (mapit Pred Y Z);)

(defprolog consit
  X [1 X] <--;)

(defprolog different
  X Y <--  (~ [identical X Y]);)

(defprolog ~
  P <-- (call P) ! (when false);
  _ <--;)

(defprolog likes
  john  X <-- (tall X)  (pretty X);)

(defprolog tall
  mary <--;)

(defprolog pretty
  mary <--;)

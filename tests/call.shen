(defprolog mapit
  _  [] [] <--;
  Pred [X | Y] [W | Z] <-- (call (Pred X W)) (mapit Pred Y Z);)

(defprolog consit
  X [1 X] <--;)

(defprolog different
  X Y <--  (not! (is X Y));)

(defprolog not!
  P <-- (call P) ! (when false);
  _ <--;)


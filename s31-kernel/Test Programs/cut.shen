(defprolog a
  X <-- (b X) (c X);)

(defprolog b
  1 <--;
  4 <--;)

(defprolog c
  X <-- (d X) ! (e* X);
  X <-- (f X);)

(defprolog d
  X <-- (g* X);
  X <-- (h X);)

(defprolog e*
  3 <--;)

(defprolog f
  4 <--;)

(defprolog g*
 2 <--;)

(defprolog h
 1 <--;)
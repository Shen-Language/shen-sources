
(defprolog g1
  a <--;)

(defprolog h
   b <--;)

(defprolog i
   a <--;
   b <--;)

(defprolog j
   b <--;)

(defprolog f
   X <-- (g1 X) (fork [(h X) (i X) (j X)]);)
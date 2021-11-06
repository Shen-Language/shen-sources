
(defprolog g
  a <--;)

(defprolog h
   b <--;)

(defprolog i
   a <--;
   b <--;)

(defprolog j
   b <--;)

(defprolog f
   X <-- (g X) (fork [(h X) (i X) (j X)]);)
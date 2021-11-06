(defprolog nreverse
  [] [] <--;
  [X | Y] R <-- (nreverse Y RY) (nappend RY [X] R);)

(defprolog nappend
  [] X X <--;
  [X | Y] Z [X | W] <-- (nappend Y Z W);)
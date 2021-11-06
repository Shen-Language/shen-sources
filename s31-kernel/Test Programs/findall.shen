(defprolog enjoys
  mark chocolate <--;
  mark tea <--;)

(defprolog fads
  X <-- (findall Y (enjoys X Y) Likes) (return Likes);)
(defprolog riddle
  <-- (house A) (house B) (house C) (house D) (house E) (is Houses [A B C D E])
       (member [brit _ _ _ red] Houses)
       (member [swede dog _ _ _] Houses)
       (member [dane _ _ tea _] Houses)
       (left [_ _ _ _ green] [_ _ _ _ white] Houses)
       (member [_ _ _ coffee green] Houses)
       (member [_ bird pallmall _ _] Houses)
       (member [_ _ dunhill _ yellow] Houses)
       (is C [_ _ _ milk _])
       (is A [norwegian _ _ _ _])
       (next [_ _ blends _ _] [_ cat _ _ _] Houses)
       (next [_ horse _ _ _] [_ _ dunhill _ _] Houses)
       (member [_ _ bluemaster beer _] Houses)
       (member [german _ prince _ _] Houses)
       (next [norwegian _ _ _ _] [_ _ _ _ blue] Houses)
       (next [_ _ blends _ _] [_ _ _ water _] Houses)
       (who-owns-the-fish? Nationality Houses);)

(defprolog member
   X (- [X | _]) <--;
   X (- [_ | Z]) <-- (member X Z);)

(defprolog house
   [Nationality Pet Cigarette Drink Colour] <--;)

(defprolog next
  X Y List <-- (left X Y List);
  X Y List <-- (left Y X List);)


(defprolog left
  L R (- [L R | _]) <--;
  L R (- [_ | Houses]) <-- (left L R Houses);)

(defprolog who-owns-the-fish?
  Nationality Houses <-- (member [Nationality fish _ _ _] Houses)
                         (return Nationality);)
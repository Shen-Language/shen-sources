(defprolog einsteins_riddle
  Fish_Owner <-- (einstein Houses Fish_Owner);)

(defprolog einstein
  Houses Fish_Owner
  <-- (unify Houses [[house norwegian _ _ _ _] _ [house _ _ _ milk _] _ _])
      (member [house brit _ _ _ red] Houses)
      (member [house swede dog _ _ _] Houses)
      (member [house dane _ _ tea _] Houses)
      (iright [house _ _ _ _ green] [house _ _ _ _ white] Houses)
      (member [house _ _ _ coffee green] Houses)
      (member [house _ bird pallmall _ _] Houses)
      (member [house _ _ dunhill _ yellow] Houses)
      (next_to [house _ _ dunhill _ _] [house _ horse _ _ _] Houses)
      (member [house _ _ _ milk _] Houses)
      (next_to [house _ _ marlboro _ _] [house _ cat _ _ _] Houses)
      (next_to [house _ _ marlboro _ _] [house _ _ _ water _] Houses)
      (member [house _ _ winfield beer _] Houses)
      (member [house german _ rothmans _ _] Houses)
      (next_to [house norwegian _ _ _ _] [house _ _ _ _ blue] Houses)
      (unify Houses [[house norwegian _ _ _ _] _ [house _ _ _ milk _] _ _])
      (member [house Fish_Owner fish _ _ _] Houses);)

(defprolog member
  X [X | _] <--;
  X [_ | Z] <-- (member X Z);)

(defprolog next_to
  X Y List <-- (iright X Y List);
  X Y List <-- (iright Y X List);)

(defprolog iright
  L R (mode [L | [R | _]] -) <--;
  L R (mode [_ | Rest] -) <-- (iright L R Rest);)

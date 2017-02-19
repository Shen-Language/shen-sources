(defprolog pparse
  S Grammar <-- (parsing [[s + 0] = [S + 0]] Grammar);)

(defprolog parsing
  [X = X] _ <--;
  [[X + Y] = [X + Z]] Grammar <-- ! (parsing [Y = Z] Grammar);
  [[[X + Y] + Z] = W] Grammar <-- ! (parsing [[X + [Y + Z]] = W] Grammar);
  [W = [[X + Y] + Z]] Grammar <-- ! (parsing [W = [X + [Y + Z]]] Grammar);
  [[X + Y] = Z] Grammar <-- (member [X = W] Grammar) (parsing [[W + Y] = Z] Grammar);)

(defprolog member
  X [X | _] <--;
  X [_ | Y] <-- (member X Y);)

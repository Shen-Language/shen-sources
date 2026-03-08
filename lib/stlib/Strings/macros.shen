(defmacro string-macros
  [s-op1 F S] -> [s-op1 F S [/. (protect X) (protect X)]]
  [s-op2 F S1 S2] -> [s-op2 F S1 S2 [/. (protect X) (protect X)]])

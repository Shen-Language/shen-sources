(package propositional-calculus (pc-external-symbols)

(datatype prop

  if (not (element? P [~ v & => <=>]))
  P : symbol;
  ___________
  P : prop;
  
  P : prop;
  =========
  [~ P] : prop;
  
  if (element? C [v & => <=>])
  P : prop; Q : prop;
  ===================
  [P C Q] : prop;))
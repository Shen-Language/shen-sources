(datatype binary

  if (element? X [0 1])
  _____________
  X : zero-or-one;

  X : zero-or-one;
  ________________
  [X] : binary;

  X : zero-or-one; Y : binary;
  ____________________________
  [X | Y] : binary;

  X : zero-or-one, [Y | Z] : binary >> P;
  ________________________________________
  [X Y | Z] : binary >> P;)

(define complement
  {binary --> binary}
  [0] -> [1]
  [1] -> [0]
  [1 N | X] -> [0 | (complement [N | X])]
  [0 N | X] -> [1 | (complement [N | X])])

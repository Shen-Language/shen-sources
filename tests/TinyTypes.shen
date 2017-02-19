(specialise defun)
(specialise lambda')

(datatype tiny_lisp_type_theory

  let Lambda (mk_lambda Xs Body)
  F : A >> Lambda : A;
  __________________
  (defun F Xs Body) : A;

  let X* (gensym &&x)
  let Y* (subst X* X Y)
  X* : A >> Y* : B;
  _____________________
  (lambda' (X) Y) : (A --> B);

  F : (A --> B); X : A;
  ________________
  (F X) : B;

  ____________________________
  lispif : (bool --> (A --> (A --> A)));

  ________________________
  equal : (A --> (A --> bool));

  ___________________________
  lispcons : (A --> ((list A) --> (list A)));

  ______________
  car : ((list A) --> A);

  _______________
  cdr : ((list A) --> (list A));

  if (element? F [succ prec])
  ____________________
  F : (number --> number);

  ___________
  (tee!) : bool;

  ____________
  (empty!) : (list A);

  ________
  (empty!) : bool;

  if (symbol? X)
  ____________
  (quote X) : symbol;)

(define mk_lambda
  [X] Body -> [lambda' [X] Body]
  [X | Y] Body -> [lambda' [X] (mk_lambda Y Body)])

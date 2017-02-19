(datatype num

  ____________________________________
  (number? X)  : verified >> X : number;)

(datatype primitive_object

  if (variable? X)
  _______________
  X : variable;

  X : variable;
  _____________
  X : primitive_object;

  X : symbol;
  ___________
  X : primitive_object;

  X : string;
  ___________
  X : primitive_object;

  X : boolean;
  ___________
  X : primitive_object;

  X : number;
  ___________
  X : primitive_object;

  _____________________
  [] : primitive_object;)

(datatype pattern

  X : primitive_object;
  ___________
  X : pattern;

  P1 : pattern; P2 : pattern;
  ===========================
  [cons P1 P2] : pattern;

  P1 : pattern; P2 : pattern;
  ===========================
  [@p P1 P2] : pattern;)

(datatype l_formula

  X : pattern;
  _____________
  X : l_formula;

  X : l_formula; Y : l_formula; Z : l_formula;
  =================================
  [if X Y Z] : l_formula;

  X : variable; Y : l_formula; Z : l_formula;
  ================================
  [let X Y Z] : l_formula;

  X : l_formula; Y : l_formula;
  ======================
  [cons X Y] : l_formula;

  X : l_formula; Y : l_formula;
  ======================
  [@p X Y] : l_formula;

  X : l_formula; Y : l_formula;
  ======================
  [where X Y] : l_formula;

  X : l_formula; Y : l_formula;
  ======================
  [= X Y] : l_formula;

  X : l_formula; Y : l_formula;
  ======================
  [X Y] : l_formula;

  Xn : (list l_formula);
  ===================
  [cases | Xn] : l_formula;

  P : pattern; X : l_formula;
  ===========================
  [/. P X] : l_formula;)

(define l_interpreter
  {A --> B}
  _ -> (read_eval_print_loop (output "~%L interpreter ~%~%~%~%l-interp --> ~A~%"
                                     (normal_form (input+ l_formula)))))

(define read_eval_print_loop
  {string --> A}
  _ -> (read_eval_print_loop
        (output "l-interp --> ~A~%"
                (normal_form (input+ l_formula)))))

(define normal_form
  {l_formula --> l_formula}
  X -> (fix (function ==>>) X))

(define ==>>
  {l_formula --> l_formula}
  [= X Y] -> (let X* (normal_form X)
               (let Y* (normal_form Y)
                 (if (or (eval_error? X*) (eval_error? Y*))
                     "error!"
                     (if (= X* Y*) true false))))
  [[/. P X] Y] -> (let Match (match P (normal_form Y))
                    (if (no_match? Match)
                        "no match"
                        (sub Match X)))
  [if X Y Z] -> (let X* (normal_form X)
                  (if (= X* true)
                      Y
                      (if (= X* false)
                          Z
                          "error!")))
  [let X Y Z] -> [[/. X Z] Y]
  [@p X Y] -> (let X* (normal_form X)
                (let Y* (normal_form Y)
                  (if (or (eval_error? X*) (eval_error? Y*))
                      "error!"
                      [@p X* Y*])))
  [cons X Y] -> (let X* (normal_form X)
                  (let Y* (normal_form Y)
                    (if (or (eval_error? X*) (eval_error? Y*))
                        "error!"
                        [cons X* Y*])))
  [++ X] -> (successor (normal_form X))
  [-- X] -> (predecessor (normal_form X))
\*[cases X1 | Xn] -> (let Case1 (normal_form X1)
                           (if (= Case1 "no match")
                               [cases | Xn]
                               Case1))
  [cases] -> "error!"
  [where X Y] -> [if X Y "no match"]
  [y-combinator [/. X Y]] -> (replace X [y-combinator [/. X Y]] Y)
  [X Y] -> (let X* (normal_form X)
             (let Y* (normal_form Y)
               (if (or (eval_error? X*) (eval_error? Y*))
                   "error!"
                   [X* Y*])))*\
  X -> X)

(define eval_error?
  {l_formula --> boolean}
  "error!" -> true
  "no match" -> true
  _ -> false)

(define successor
  {A --> l_formula}
  X -> (+ 1 X) where (number? X)
  _ -> "error!")

(define predecessor
  {A --> l_formula}
  X -> (- X 1) where (number? X)
  _ -> "error!")

(define sub
  {(list (pattern * l_formula)) --> l_formula --> l_formula}
  [] X -> X
  [(@p Var Val) | Assoc] X -> (sub Assoc (replace Var Val X)))

(define match
  {pattern --> l_formula --> (list (pattern * l_formula))}
  P X -> [] where (== P X)
  P X -> [(@p P X)]      where (variable? P)
  [cons P1 P2] [cons X Y] -> (let Match1 (match P1 X)
                               (if (no_match? Match1)
                                   Match1
                                   (let Match2 (match P2 Y)
                                     (if (no_match? Match2)
                                         Match2
                                         (append Match1 Match2)))))
  [@p P1 P2] [@p X Y] -> (let Match1 (match P1 X)
                           (if (no_match? Match1)
                               Match1
                               (let Match2 (match P2 Y)
                                 (if (no_match? Match2)
                                     Match2
                                     (append Match1 Match2)))))

  _ _ -> [(@p no matching)])

(define no_match?
  {(list (pattern * l_formula)) --> boolean}
  [(@p no matching)] -> true
  _ -> false)

(define replace
  {pattern --> l_formula --> l_formula --> l_formula}
  V W [let V* X Y] -> [let V* X Y]  where (== V V*)
  X Y X -> Y
  V W [= X Y] -> [= (replace V W X) (replace V W Y)]
  V W [/. P X] -> [/. P (replace V W X)] 		where (free? V P)
  V W [if X Y Z] -> [if (replace V W X) (replace V W Y) (replace V W Z)]
  V W [let X Y Z] -> [let X (replace V W Y) (replace V W Z)]
  V W [@p X Y] -> [@p (replace V W X) (replace V W Y)]
  V W [cons X Y] -> [cons (replace V W X) (replace V W Y)]
  V W [cases | Xn] -> [cases | (map (/. Xi (replace V W Xi)) Xn)]
  V W [where X Y] -> [where (replace V W X) (replace V W Y)]
  V W [X Y] -> [(replace V W X) (replace V W Y)]
  _ _ X -> X)

(define free?
  {pattern --> pattern --> boolean}
  P P -> false
  P [cons P1 P2] -> (and (free? P P1) (free? P P2))
  P [@p P1 P2] -> (and (free? P P1) (free? P P2))
  _ _ -> true)

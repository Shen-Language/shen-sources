(datatype num

 ____________________________________
 (number? X) : verified >> X : number;)

(datatype primitive-object

      if (variable? X)
      _______________
      X : variable;

      X : variable;
      _____________________
      X : primitive-object;

      X : symbol;
      _____________________
      X : primitive-object;

      X : string;
      _____________________
      X : primitive-object;

      X : boolean;
      _____________________
      X : primitive-object;

      X : number;
      _____________________
      X : primitive-object;

      _____________________
      [] : primitive-object;)

(datatype pattern

   X : primitive-object;
   _____________________
   X : pattern;

   P1 : pattern; P2 : pattern;
   ===========================
   [cons P1 P2] : pattern;

   P1 : pattern; P2 : pattern;
   ===========================
   [@p P1 P2] : pattern;)

  (datatype l-formula

   X : pattern;
   _____________
   X : l-formula;

   X : l-formula; Y : l-formula; Z : l-formula;
   ============================================
   [if X Y Z] : l-formula;

   X : variable; Y : l-formula; Z : l-formula;
   ===========================================
   [let X Y Z] : l-formula;

   X : l-formula; Y : l-formula;
   =============================
   [cons X Y] : l-formula;

   X : l-formula; Y : l-formula;
   =============================
   [@p X Y] : l-formula;

   X : l-formula; Y : l-formula;
   =============================
   [where X Y] : l-formula;

   X : l-formula; Y : l-formula;
   =============================
   [= X Y] : l-formula;

   X : l-formula; Y : l-formula;
   =============================
   [X Y] : l-formula;

   Xn : (list l-formula);
   =========================
   [cases | Xn] : l-formula;

   P : pattern; X : l-formula;
   ===========================
   [/. P X] : l-formula;)

(define normal-form
  {l-formula --> l-formula}
   X -> (fix (fn ==>>) X))

(define ==>>
   {l-formula --> l-formula}
   [= X Y] -> (let X* (normal-form X)
                   (let Y* (normal-form Y)
                        (if (or (eval-error? X*) (eval-error? Y*))
                            "error!"
                            (if (= X* Y*) true false))))
   [[/. P X] Y] -> (let Match (match P (normal-form Y))
                        (if (no-match? Match)
                            "no match"
                            (sub Match X)))
   [if X Y Z] -> (let X* (normal-form X)
                      (if (= X* true)
                          Y
                          (if (= X* false)
                              Z
                              "error!")))
   [let X Y Z] -> [[/. X Z] Y]
   [@p X Y] -> (let X* (normal-form X)
                    (let Y* (normal-form Y)
                         (if (or (eval-error? X*) (eval-error? Y*))
                             "error!"
                             [@p X* Y*])))
   [cons X Y] -> (let X* (normal-form X)
                      (let Y* (normal-form Y)
                           (if (or (eval-error? X*) (eval-error? Y*))
                               "error!"
                               [cons X* Y*])))
   [++ X] -> (successor (normal-form X))
   [-- X] -> (predecessor (normal-form X))
   [cases X1 | Xn] -> (let Case1 (normal-form X1)
                           (if (= Case1 "no match")
                               [cases | Xn]
                               Case1))
   [cases] -> "error!"
   [where X Y] -> [if X Y "no match"]
   [y-combinator [/. X Y]] -> (replace X [y-combinator [/. X Y]] Y)
   [X Y] -> (let X* (normal-form X)
               (let Y* (normal-form Y)
                  (if (or (eval-error? X*) (eval-error? Y*))
                      "error!"
                      [X* Y*])))
    X -> X)

(define eval-error?
  {l-formula --> boolean}
   "error!" -> true
   "no match" -> true
   _ -> false)

(define successor
  {A --> l-formula}
  X -> (+ 1 X) where (number? X)
  _ -> "error!")

(define predecessor
  {A --> l-formula}
  X -> (- X 1) where (number? X)
  _ -> "error!")

(define sub
  {(list (pattern * l-formula)) --> l-formula --> l-formula}
   [] X -> X
   [(@p Var Val) | Assoc] X -> (sub Assoc (replace Var Val X)))

(define match
   {pattern --> l-formula --> (list (pattern * l-formula))}
    P X -> [] where (== P X)
    P X -> [(@p P X)]      where (variable? P)
    [cons P1 P2] [cons X Y] -> (let Match1 (match P1 X)
                                    (if (no-match? Match1)
                                        Match1
                                        (let Match2 (match P2 Y)
                                            (if (no-match? Match2)
                                                Match2
						(append Match1 Match2)))))
    [@p P1 P2] [@p X Y] -> (let Match1 (match P1 X)
                                    (if (no-match? Match1)
                                        Match1
                                        (let Match2 (match P2 Y)
                                            (if (no-match? Match2)
                                                Match2
						(append Match1 Match2)))))

    _ _ -> [(@p no matching)])

(define no-match?
  {(list (pattern * l-formula)) --> boolean}
   [(@p no matching)] -> true
   _ -> false)

(define replace
   {pattern --> l-formula --> l-formula --> l-formula}
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
(datatype plan

  let L* (decons L)
  L : (list prop);
  P : prop;
  Series : (instructions-wrt L* P);
  ________________________________
  [L P (initialise-plan) | Series] : plan;

  P : prop;
  ____________________________________
  [(<-kb P) (end-of-plan)] : (instructions-wrt L P);

  let Q* (decons Q)
  Q : prop;
  [Instruction | Series] : (instructions-wrt (Q* | L) P);
  _________________________________________________________
  [(<-kb Q) Instruction | Series] : (instructions-wrt L P);

  Comment : string;
  Series : (instructions-wrt L P);
  _____________________________________________
  [(comment Comment) | Series] : (instructions-wrt L P);

  if (subset? (decons L*) L)
  L* : (list prop);
  Series : (instructions-wrt L P);
  _____________________________________________
  [(kb-> L*) | Series] : (instructions-wrt L P);)

(define decons
   [cons X Y] -> [(decons X) | (decons Y)]
   X -> X)

(defmacro let*-macro
   [let* G L | Local] -> [let | (subst L G Local)])

(define succeeds?
   [G P | Instructions] -> (succeeds-h? Instructions))

(define succeeds-h?
  [true]                    -> true
  [compiled | Instructions] -> (succeeds-h? Instructions)
  [true | Instructions]     -> (succeeds-h? Instructions)
  _                         -> false)

(declare succeeds? [plan --> boolean])

(define initialise-plan
   -> (do (thorn.wipe-kb)
          (set *prf* "")
          (write-to-file "prf.txt" "" )
          (thorn.defaults)
          true))

(define comment
  Comment -> (let Add        (@s (read-file-as-string "prf.txt") "c#13;" Comment "c#13;")
                  Set        (set *prf* (cn (value *prf*) Add))
                  true))

(define end-of-plan
  -> (do (write-to-file "prf.txt" (@s (value *prf*) "c#13;" (read-file-as-string "prf.txt"))) true))

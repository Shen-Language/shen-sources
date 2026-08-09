(datatype plan

  L : (list prop);
  P : prop;
  Series : (instructions-wrt L P);
  ________________________________
  [L P (initialise-plan) | Series] : plan;

  Comment : string;
  P : prop;
  ____________________________________
  [(lemma P Comment) (end-of-plan)] : (instructions-wrt L P);
  
  \\let L+Q [Q | L]
  Comment : string;
  Q : prop;
  [Instruction | Series] : (instructions-wrt (cons Q L)  P);
  _________________________________________________________
  [(lemma Q Comment) Instruction | Series] : (instructions-wrt L P);
  
  if (licensed? L* L) 
  L* : (list prop);
  Series : (instructions-wrt L P);
  _____________________________________________
  [(kb-> L*) | Series] : (instructions-wrt L P);
  
  N : number;
  Series : (instructions-wrt L P);
  ______________________________________________________
  [(thorn.timeout N) | Series] : (instructions-wrt L P);)

(defmacro lemma-macro
  [lemma P] -> [lemma P ""])

(defmacro let*-macro
  [let* X Y Z] -> (subst Y X Z)
  [let* X Y W Z | U] -> [let* X Y [let* W Z | U]])  
      
(define lemma
  {prop --> string --> boolean}
   P Comment -> (if (<-kb P)
                    (do (store-lemma Comment) true)
                    (error "lemma failed ~A~%" P)))  

(define store-lemma
  {string --> string}
  Comment -> (set *prf* (@s (value *prf*) "c#13;c#13;LEMMAc#13;c#13;" Comment "c#13;" (read-file-as-string "prf.txt"))))
   
\\(define licensed?
 \\ L L -> true
  \\[cons P Ps] L -> (and (element? P L) (licensed? Ps L))
  \\P [Q | L]     -> (licensed? P L)                   
  \\_ _ -> false)
  
(define licensed?
  L L -> true
  [] _ -> true
  [cons P Ps] L -> (and (found-in? P L) (licensed? Ps L))
  _ _ -> false)
  
(define found-in?
  P [cons P _] -> true
  P [cons _ Q] -> (found-in? P Q)
  _ _ -> false)    
    
(define initialise-plan
   -> (do (thorn.wipe-kb)
          (set *prf* "") 
          (write-to-file "prf.txt" "" )
          (thorn.defaults)
          true))
             
(define end-of-plan
  -> (do (write-to-file "prf.txt" (value *prf*)) true))                  
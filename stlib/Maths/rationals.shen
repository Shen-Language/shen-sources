(package rational (append [r-reduce r= r< r> r>= r<= r+ r- r* r/ r-expr +-inverse *-inverse 
                           r-expt r->n r->pair n->r maths.n->r r-approx maths.lcd-loop 
                           r-op1 r-op2] 
                          (external rational) 
                          (external maths))
                          
(define r-op1
  {(number --> number) --> rational --> rational}
   F R -> (n->r (F (r->n R)))) 
   
(define r-op2
  {(number --> number --> number) --> rational --> rational --> rational}
   F R1 R2 -> (n->r (F (r->n R1) (r->n R2))))                               
                          
(define r->n
  {rational --> number}
   R -> (/ (numerator R) (denominator R)))
   
(define r->pair
  {rational --> (number * number)}
   R -> (@p (numerator R) (denominator R)))
   
(define n->r
  {number --> rational}
   N -> (let Pair (maths.n->r N 1)
             (r# (fst Pair) (snd Pair))))                                

(define r-reduce
  {rational --> rational}
   R -> (r-reduce-help (numerator R) (denominator R)))

(define r-reduce-help   
  {number --> number --> rational}
   N D -> (let LCD (lcd N D)
               (if (= LCD 1) 
                   (r# N D)
                   (r-reduce-help (/ N LCD) (/ D LCD)))))
                   
(define r=
  {rational --> rational --> boolean}
   R1 R2 -> (let A (numerator R1)
                 B (denominator R1)
                 C (numerator R2)
                 D (denominator R2)
                 (= (* A D) (* B C))))
                 
(define r<
  {rational --> rational --> boolean}
   R1 R2 -> (let A (numerator R1)
                 B (denominator R1)
                 C (numerator R2)
                 D (denominator R2)
                 (< (* A D) (* B C))))
                 
(define r>
  {rational --> rational --> boolean}
  R1 R2 -> (not (or (r= R1 R2) (r< R1 R2))))
  
(define r>=
  {rational --> rational --> boolean}
  R1 R2 -> (or (r= R1 R2) (r> R1 R2)))
  
(define r<=
  {rational --> rational --> boolean}
  R1 R2 -> (or (r= R1 R2) (r< R1 R2)))
  
(define r+
  {rational --> rational --> rational}
   R1 R2 -> (let A (numerator R1)
                 B (denominator R1)
                 C (numerator R2)
                 D (denominator R2)
                 (r# (+ (* A D) (* B C)) (* B D))))
                 
(define r-
  {rational --> rational --> rational}
   R1 R2 -> (let A (numerator R1)
                 B (denominator R1)
                 C (numerator R2)
                 D (denominator R2)
                 (r# (- (* A D) (* B C)) (* B D))))
                 
(define r*
  {rational --> rational --> rational}
   R1 R2 -> (let A (numerator R1)
                 B (denominator R1)
                 C (numerator R2)
                 D (denominator R2)
                 (r# (* A C) (* B D))))
                 
(define +-inverse
  {rational --> rational}
   R -> (let A (numerator R)
             B (denominator R)
             (r# (~ A) B)))
             
(define *-inverse 
  {rational --> rational}
   R -> (let A (numerator R)
             B (denominator R)
             (r# B A)))

(define r/
  {rational --> rational --> rational}
   R1 R2 -> (r* R1 (*-inverse R2)))  
   
(define r-expt
  {rational --> number --> rational}
   R N -> (let A (numerator R)
               B (denominator R) 
               (r# (power A N) (power B N)))              where (natural? N)
   R N -> (let A (numerator R)
               B (denominator R) 
               (r# (power B (~ N)) (power A (~ N))))      where (and (integer? N) (negative? N))          
   _ N -> (error "cannot exponentiate a rational by a non-integer ~A~%" N)) 
   
(define r-approx
  {rational --> number --> rational}
   R D -> (approx-r-h (r->n R) D 0))
   
(define approx-r-h   
  {number --> number --> number --> rational}
  Value D N -> (r# N D)   where (> (/ N D) Value)
  Value D N -> (approx-r-h Value D (+ N 1)))
  
                           )       
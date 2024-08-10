(package maths [expt =r gcd lcd isqrt sqrt nthrt floor ceiling round mod lcm random min max
                reseed ~ positive? negative? natural? converge series odd? even? 
                cos sin tan radians pi e tan30 cos30 cos45 sin45 sqrt2 tan60 sin120
                tan120 sin135 cos135 cos150 tan150 cos210 tan210 sin225 cos225 sin240
                tan240 sin300 tan300 sin315 cos315 cos330 tan330 sinh cosh tanh sech 
                csch power factorial prime? unix div modf product summation set-tolerance tolerance
                coth for sq cube newv abs approx log log2 loge log10 g]


                  
(datatype maths

   _________________
   (value *seed*) : number;
   
   _______________________
   (value *tolerance*) : number;)  
   
(set *seed* 95795)   
(set *tolerance* .0001)

(define set-tolerance
  {number --> number}
   N -> (set *tolerance* N))
   
(define tolerance
  {--> number}
   -> (value *tolerance*))  
   
(define sq
  {number --> number}
   X -> (* X X))
   
(define cube
  {number --> number}
   X -> (* X X X)) 

(define for
  {number --> (number --> boolean) 
     --> (number --> A) --> (number --> number) 
       --> (A --> A --> A) --> A}
  Count Continue? Loop Inc Acc -> (for-h (Inc Count) Continue? Loop Inc Acc (Loop Count)))
  
(define for-h
  {number --> (number --> boolean) 
     --> (number --> A) --> (number --> number) --> (A --> A --> A) --> A --> A}
  Count Continue? _ _ _ Result -> Result     where (not (Continue? Count))
  Count Continue? Loop Inc Acc Result
  -> (for-h (Inc Count) Continue? Loop Inc Acc (Acc Result (Loop Count) )))  

(define lazyfor-and
  {number --> (number --> boolean) 
     --> (number --> boolean) --> (number --> number) --> boolean}
  Count Continue? _ _ -> true       where (not (Continue? Count))
  Count Continue? Loop Inc -> (lazyfor-and (Inc Count) Continue? Loop Inc)   where (Loop Count)
  _ _ _ _ -> false)  
  
(define lazyfor-or
  {number --> (number --> boolean) 
     --> (number --> boolean) --> (number --> number) --> boolean}
  Count Continue? Loop Inc -> false                       where (not (Continue? Count))
  Count _ Loop _ -> true      where (Loop Count) 
  Count Continue? Loop Inc -> (lazyfor-or (Inc Count) Continue? Loop Inc))   
    
(define max
  {number --> number --> number}
   M N -> N   where (> N M)
   M _ -> M)
   
(define min
  {number --> number --> number}
   M N -> N   where (< N M)
   M _ -> M)     

(define expt
  {number --> number --> number --> number}
   M N Tolerance -> (cases (= N 0) 1
                           (positive? N) (expt-h M (n->r N 1) Tolerance)
                            true (/ 1 (expt-h M (n->r (~ N) 1) Tolerance))))
                 
(define n->r
  {number --> number --> (number * number)}
   N D -> (@p N D)      where (integer? N)
   N D -> (n->r (* N 10) (* D 10)))
   
(define expt-h
  {number --> (number * number) --> number --> number}
   M (@p N D) Tolerance -> (power (nthrt M D Tolerance) N))

(define gcd
  {number --> number --> number}
   M N -> (if (and (integer? M) (integer? N))
              (let M* (abs M)
                   N* (abs N)
                   (if (> M* N*)
                       (gcd-help (- M* N*) N*)
                       (gcd-help M* (- N* M*))))
              (error "gcd expects integer inputs")))
              
(define gcd-help
  {number --> number --> number}
   M N -> (if (> M N) 
              (gcd-loop M N N)
              (gcd-loop M N M)))
   
(define gcd-loop
  {number --> number --> number --> number}
   _ _ 1 -> 1     
   M N Divisor -> Divisor     where (and (integer? (/ M Divisor)) (integer? (/ N Divisor)))
   M N Divisor -> (gcd-loop M N (- Divisor 1))) 
   
(define lcd
  {number --> number --> number}
   M N -> 2       where (and (even? M) (even? N))
   M N -> (lcd-loop M N (if (> M N) N M) 3))
  
(define lcd-loop
  {number --> number --> number --> number --> number}
   _ _ Max Divisor -> 1     where (> Divisor Max)
   M N _ Divisor -> Divisor     where (and (integer? (/ M Divisor)) (integer? (/ N Divisor)))
   M N Max Divisor -> (lcd-loop M N Max (+ 2 Divisor))) 
   
(define isqrt
  {number --> number}
   N -> (isqrt-loop N 0))
   
(define isqrt-loop
  {number --> number --> number}
   N Sqrt -> Sqrt   where (= (* Sqrt Sqrt) N)
   N Sqrt -> (- Sqrt 1)  where (> (* Sqrt Sqrt) N)
   N Sqrt -> (isqrt-loop N (+ Sqrt 1)))              

(define div
   {number --> number --> number}
    N D -> (floor (/ N D)))
    
(define modf
  {number --> (number * number)}
   N -> (let Floor (floor N) (@p Floor (- N Floor))))    
          
(define floor
  {number --> number}
   N -> (~ (ceiling (~ N)))   where (negative? N)
   N -> (rounding-loop floor N 15 0))
   
(define rounding-loop
  {symbol --> number --> number --> number --> number}
   _ N 0 N -> N
   K N 0 Guess -> (cases (= K floor) (- Guess 1) 
                         (= K ceiling) Guess
                         (= K round) (let Up (- Guess N)
                                          Down (- N (- Guess 1))
                                          (if (> Up Down)
                                              (- Guess 1)
                                              Guess)))   where (> Guess N)
   K N Exponent Guess -> (rounding-loop K N Exponent 
                                   (+ Guess (power 10 Exponent)))  where (> N Guess)
   K N Exponent Guess -> (rounding-loop K N (- Exponent 1) (- Guess (power 10 Exponent))))  

(define float->pair
  {number --> (number * number)}
   N -> (let Floor (floor N) (@p Floor (- N Floor))))
  
(define ceiling
  {number --> number}
   N -> (~ (floor (~ N)))   where (negative? N)
   N -> (rounding-loop ceiling N 15 0))
   
(define round
  {number --> number}
   N -> (~ (round (~ N)))   where (negative? N)
   N -> (rounding-loop round N 15 0))
   
(define mod
  {number --> number --> number}
   X Y -> (let Div (/ X Y)
               FloorDiv (floor Div)
               (if (and (integer? X) (integer? Y)) 
                   (round (* Y (- Div FloorDiv)))
                   (* Y (- Div FloorDiv)))))
                   
(define lcm
  {(list number) --> number}
   L -> (let Greatest (greatest L)
             (lcm-h Greatest Greatest L)))
             
(define greatest
  {(list number) --> number}
   [N] -> N
   [M N | Ns] -> (greatest [M | Ns])   where (> M N)
   [_ N | Ns] -> (greatest [N | Ns]))             
   
(define lcm-h
  {number --> number --> (list number) --> number}
   LCM Greatest L -> LCM  where (lcm? LCM L)
   LCM Greatest L -> (lcm-h (+ LCM Greatest) Greatest L))
   
(define lcm?
  {number --> (list number) --> boolean}
   _ [] -> true
   LCM [N | Ns] -> (and (integer? (/ LCM N)) (lcm? LCM Ns))) 

(define random
  {number --> number --> number}
   Lower Upper -> (let Random (bbs (value *seed*))
                       NewSeed (set *seed* Random)
                       Min (min Lower Upper)
                       (+ Min (mod NewSeed (abs (+ 1 (- Upper Lower)))))))
                       
(define min
  {number --> number --> number}
   X Y -> Y   where (> X Y)
   X _ -> X)
                     
(define reseed
  {--> number}
  -> (set *seed* (get-time unix)))                       
      
(define bbs
  {number --> number}     
   Xn -> (let M (* 1201 1213)
              (mod (* Xn Xn) M)))
                 
(define ~
  {number --> number}
   N -> (- 0 N)) 
   
(define positive?
  {number --> boolean}
   N -> (> N 0))
   
(define negative?
  {number --> boolean}
   N -> (< N 0))
   
(define natural?
  {number --> boolean}
   0 -> true
   N -> (and (integer? N) (positive? N)))   
  
(define converge 
   {A --> (A --> A) --> (A --> A --> boolean) --> A}
    X F R -> (converge-help F (F X) X R))

(define converge-help  
  {(A --> A) --> A --> A --> (A --> A --> boolean) --> A}
   _ New Old R -> New  where (R Old New)  
   F New _ R -> (converge-help F (F New) New R))
   
(define nthrt
  {number --> number --> number --> number}
   A Root Tolerance -> (converge A (/. Xk (compute-nthrt A Xk Root Tolerance)) (approx Tolerance)) where (positive? A)
   A _ _ -> (error "nthrt: negA must be a positive numberneg%" A))
   
(define sqrt
  {number --> number --> number}
   N Tolerance -> (nthrt N 2 Tolerance))   

(define compute-nthrt
  {number --> number --> number --> number --> number}
   A Xk N Tolerance -> (let Reciprocal (/ 1 N)
                            N-1Xk (* (- N 1) Xk)
                            Xk<n-1> (expt Xk (- N 1) Tolerance)
                            A/Xk<n-1> (/ A Xk<n-1>)
                            Add (+ N-1Xk A/Xk<n-1>)
                            (* Reciprocal Add)))
                   
(define approx
  {number --> (number --> number --> boolean)}
   N -> (/. X Y (let Z (- X Y) (>= N (abs Z)))))
   
(define abs
  {number --> number}
   N -> (if (>= N 0) N (- 0 N)))   

(define series
  {number --> (number --> number) --> number --> (number --> number --> number) --> number}
   Start TermF Tolerance Op -> (series-h (+ Start 1) Tolerance TermF (TermF Start) Op))
  
(define series-h
  {number --> number --> (number --> number) --> number --> (number --> number --> number) --> number}
  Count Tolerance TermF SoFar Op 
  -> (let Next (Op (TermF Count) SoFar)
          (if (<= (abs (- SoFar Next)) Tolerance)
              Next
              (series-h (+ Count 1)
                        Tolerance
                        TermF
                        Next
                        Op))))
                                                    
(define product
  {number --> (number --> number) --> number --> number}                                                            
   Start TermF Tolerance  -> (series Start TermF Tolerance (fn *)))
   
(define summation
  {number --> (number --> number) --> number --> number}                                                            
   Start TermF Tolerance -> (series Start TermF Tolerance (fn +)))  
                         
(define odd?
  {number --> boolean}
  N -> (and (integer? N) (not (integer? (/ N 2)))))  
  
(define even?
  {number --> boolean}
  N -> (and (integer? N) (integer? (/ N 2))))      
  
(define compute-sine
  {number --> number --> number}
  X N -> (let N*2+1 (+ (* 2 N) 1)
              Numerator (* (power -1 N) (power X N*2+1))
              Denominator (factorial N*2+1)
              (/ Numerator Denominator)))  
              
(define compute-cos
  {number --> number --> number}
  X N -> (let N*2 (* 2 N)
              Numerator (* (power -1 N) (power X N*2))
              Denominator (factorial N*2)
              (/ Numerator Denominator)))  
  
(define cos
  {number --> number --> number}
  Degrees Tolerance -> (let Radians (radians Degrees)
                          (summation 0 (compute-cos Radians) Tolerance)))                                 
                             
(define sin
  {number --> number --> number}
  Degrees Tolerance -> (let Radians (radians Degrees)
                          (summation 0 (compute-sine Radians) Tolerance)))                             
                          
(define tan
  {number --> number --> number}
   Degrees Tolerance -> (/ (sin Degrees Tolerance) (cos Degrees Tolerance)))                          
                          
(define radians
  {number --> number}
   Degrees -> (* (/ Degrees 180) (pi)))
   
(define g
  {--> number}
   -> 1.6180339887498)     
   
(define pi
  {--> number}
   -> 3.1415926535897)
   
(define e
  {--> number}
   -> 2.7182818284590) 
   
(define tan30
  {--> number}
   -> 0.5773502691896)
   
(define cos30
  {--> number}
   -> 0.8660254037844)

(define cos45
  {--> number}
   -> 0.70710678118651)   
   
(define sin45
  {--> number}
   -> 0.7071067811865) 
   
(define sqrt2
  {--> number}
   -> 1.4142135623731)  
   
(define tan60
  {--> number}
   -> 1.7320508075692)
   
(define sin60
  {--> number}
   -> 0.8660254037844)   
   
(define sin120
  {--> number}
   -> 0.8660254037844)
   
(define tan120
{--> number}
  -> -1.7320508075692)
   
(define sin135
{--> number}
   -> 0.7071067811865)
   
(define cos135
{--> number}
   -> -0.7071067811865)
   
(define cos150
{--> number}
   -> -0.8660254037844)
   
(define tan150
{--> number}
   -> -0.5773502691905)
   
(define cos210
  {--> number}
   -> -0.8660254037844)
   
(define tan210
{--> number}
   -> 0.5773502691905)
   
(define sin225
{--> number}
   -> -0.7071067811865)
   
(define cos225
{--> number}
   -> -0.7071067811865)
   
(define sin240
{--> number}
   -> -0.8660254037844)
   
(define tan240
{--> number}
   ->  1.7320508075692)
   
(define sin300
{--> number}
   -> -0.8660254037844)
   
(define tan300
{--> number}
   -> -1.7320508075692)
   
(define sin315
{--> number}
   -> -0.7071067811865)
   
(define cos315
{--> number}
   -> 0.7071067811865)
   
(define cos330
{--> number}
  -> 0.8660254037844)
   
(define tan330
{--> number}
   -> -0.5773502691905) 
   
(define coth
  {number --> number --> number}
   N Tolerance -> (let E (e)
                       E-2N (expt E (~ (* 2 N)) Tolerance)
                       (/ (+ 1 E-2N) (- 1 E-2N))))       

(define sinh
  {number --> number --> number}
   N Tolerance -> (let E (e)
                       EN (expt E N Tolerance)
                       E-N (expt E (~ N) Tolerance)
                       Diff (- EN E-N)
                       (/ Diff 2)))
             
(define cosh
  {number --> number --> number}
   N Tolerance -> (let E (e)
                       EN (expt E N Tolerance)
                       E-N (expt E (~ N) Tolerance)
                       Sum (+ EN E-N)
                       (/ Sum 2)))
             
(define tanh
  {number --> number --> number}
   N Tolerance -> (/ (sinh N Tolerance) (cosh N Tolerance)))
   
(define sech
  {number --> number --> number}
   N Tolerance -> (/ 1 (cosh N Tolerance)))
   
(define csch
  {number --> number --> number}
   N Tolerance -> (/ 1 (sinh N Tolerance)))
                                      
(define power
  {number --> number --> number}
   _ 0 -> 1
   N M -> (* N (power N (- M 1)))) 
   
(define factorial
   {number --> number}
    0 -> 1
    N -> (* N (factorial (- N 1))))
    
(define prime?
  {number --> boolean}
   2 -> true
   N -> false   where (even? N)
   N -> (prime-h N (isqrt N) 3))
   
(define prime-h
  {number --> number --> number --> boolean}
   _ Sqrt Div -> true   where (> Div Sqrt)
   N Sqrt Div -> false    where (integer? (/ N Div))
   N Sqrt Div -> (prime-h N Sqrt (+ Div 2)))  
   
(define sign
  {number --> number}
   0 -> 0
   N -> 1     where (positive? N)
   _ -> -1)
   
(define log
  {number --> number --> number --> number}
   N Base Tolerance -> (/ (log10 N Tolerance) (log10 Base Tolerance)))
   
(define loge
  {number --> number --> number}
   N Tolerance -> (log N (e) Tolerance))
   
(define log2
  {number --> number --> number}
   N Tolerance -> (log N 2 Tolerance))
    
(define log10
  {number --> number --> number}
   N Tolerance -> (if (>= N 1)
                      (log10+ N Tolerance)
                      (~ (log10+ (/ 1 N) Tolerance))))
                      
(define log10+
  {number --> number --> number} 
  Zero Tolerance -> 0       where (<= (abs Zero) Tolerance) 
  N Tolerance -> (+ 1 (log10+ (/ N 10) Tolerance))   where (>= N 10)
  N Tolerance -> (* 0.1 (log10+ (power N 10) (* 10 Tolerance))))
        
      )      
(package print (append (external maths)
                       [pps pprint pretty-string linelength indentation set-linelength set-indentation])

(datatype print
   
   _______________________________
   (value *indentation*) : number;
   
   _______________________________
   (value *linelength*) : number;)
   
(defmacro pprint-macro
  [pprint X] -> [pprint X [stoutput]]
  [pps F] -> [pps F [stoutput]])   
   
(set *indentation* 1)
(set *linelength* 60)
   
(define linelength
  {--> number}
  -> (value *linelength*))
  
(define indentation
  {--> number}
  -> (value *indentation*)) 
  
(define set-linelength
  {number --> number}
   N -> (set *linelength* N)  where (and (positive? N) (integer? N))
   N -> (error "line length must be a positive integer~%")) 
   
(define set-indentation
  {number --> number}
   N -> (set *indentation* N)  where (and (positive? N) (integer? N))
   N -> (error "indentation must be a positive integer~%")) 

(define pps
  {symbol --> (stream out) --> symbol}
  F Sink -> (let Code (ps F) 
                 Ugly (make-string "~R" Code)
                 Pretty (pretty-string Ugly)
                 PrettyPrint (pr Pretty Sink)
                 NL (nl)
                 F))
                 
(define pprint
  {A --> (stream out) --> A}
   X Stream -> (let Ugly (make-string "~S" X)
                    Pretty (pretty-string Ugly)
                    PrettyPrint (pr Pretty Stream)
                    NL (nl)
                    X))                  

(define pretty-string
  {string --> string}
   S -> (pretty-string-h S 0 0))

(define pretty-string-h
  {string --> number --> number --> string}
  "" _ _ -> ""
  (@s "[" Ss) Depth Length -> (@s (indent Depth) "[" (pretty-string-h Ss (+ Depth 1) 0))
  (@s "(" Ss) Depth Length -> (@s (indent Depth) "(" (pretty-string-h Ss (+ Depth 1) 0))
  (@s "]" Ss) Depth Length -> (@s "]"  (pretty-string-h Ss (- Depth 1) 0))
  (@s ")" Ss) Depth Length -> (@s ")"  (pretty-string-h Ss (- Depth 1) 0))
  (@s " " Ss) Depth Length -> (@s (indent Depth) (pretty-string-h Ss Depth 0))   where (> Length (linelength))
  (@s S Ss) Depth Length -> (@s S (pretty-string-h Ss Depth (+ Length 1))))
  
(define indent
  {number --> string}  
   0 -> ""
   N -> (@s "c#10;" (indent-h N)))
   
(define indent-h
  {number --> string}
   0 -> ""
   N -> (cn (n-space (indentation)) (indent-h (- N 1)))) 
   
 (define n-space
   {number --> string}
    0 -> ""
    N -> (cn " " (n-space (- N 1))))  
    
 (preclude [print]))   
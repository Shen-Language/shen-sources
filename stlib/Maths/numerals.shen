(package numerals [hex octal duodecimal binary
                   n-op2 n-op1 n+ n- n* n/
                   | (append (external numerals) (external maths))]

(defmacro numeral-macro
  [n-op2 Op M N] -> [n-op2 Op M N [radix M]]
  [n-op1 Op M] -> [n-op1 Op M [radix M]]
  [n+ M N] -> [n+ M N [radix M]] 
  [n- M N] -> [n- M N [radix M]]
  [n* M N] -> [n* M N [radix M]]
  [n/ M N] -> [n/ M N [radix M]])
  
(define n-op2
   {(number --> number --> number) --> numeral --> numeral --> number --> numeral}
    Op M N Base -> (n# (Op (n#->n M) (n#->n N)) Base))
    
(define n-op1
  {(number --> number) --> numeral --> number --> numeral}    
   Op M Base -> (n# (Op (n#->n M)) Base))
   
(define n+
   {numeral --> numeral --> number --> numeral}
    M N Base -> (n-op2 (fn +) M N Base))
    
(define n*
   {numeral --> numeral --> number --> numeral}
    M N Base -> (n-op2 (fn *) M N Base))
    
(define n-
   {numeral --> numeral --> number --> numeral}
    M N Base -> (n-op2 (fn -) M N Base))
    
(define n/
   {numeral --> numeral --> number --> numeral}
    M N Base -> (n-op2 (fn /) M N Base))
    
(define binary
  {number --> numeral}
   N -> (n# N 2))    
    
(define hex
  {number --> numeral}
   N -> (n# N 16))
   
(define octal
  {number --> numeral}
   N -> (n# N 8)) 
   
(define duodecimal
  {number --> numeral}
   N -> (n# N 12))
    
(define n->numeral
  {number --> number --> (list number)}
   N Base -> [N]     where (> Base N)
   N Base -> (let E (largest-expt N Base 0)
                  Unit (power Base E)
                  D (div N Unit)
                  Numeral [D | (n-zeros E)]
                  Remainder (- N (* D Unit))
                  (add Numeral (n->numeral Remainder Base) Base)))  
   
(define largest-expt
  {number --> number --> number --> number}
   N Base Expt -> (- Expt 1)    where (> (power Base Expt) N)
   N Base Expt -> (largest-expt N Base (+ Expt 1)))
               
(define n-zeros
  {number --> (list number)}
   0 -> []
   N -> [0 | (n-zeros (- N 1))])
   
(define add
  {(list number) --> (list number) --> number --> (list number)}
   L1 L2 Base -> (reverse (add-h (reverse L1) (reverse L2) Base 0)))
   
(define add-h
  {(list number) --> (list number) --> number --> number --> (list number)}   
   [] [] _ 0 -> []
   [] [] _ Carry -> [Carry]
   [] L2 Base Carry -> (add-h [0] L2 Base Carry)
   L1 [] Base Carry -> (add-h L1 [0] Base Carry)
   [N1 | L1] [N2 | L2] Base Carry -> (let M (+ N1 N2 Carry)
                                          (if (< M Base)
                                              [M | (add-h L1 L2 Base 0)]
                                              [(- Base M) | (add-h L1 L2 Base 1)])))  
                                              
                                           )
                                              
  
      
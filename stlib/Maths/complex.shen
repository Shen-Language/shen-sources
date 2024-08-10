(package complex (append [c+ c- c* c/] (external complex) (external maths))

  (define c+
    {complex --> complex --> complex}
      C1 C2 -> (let A (real C1)
                    B (imaginary C1)
                    C (real C2)
                    D (imaginary C2)
                    (c# (+ A C) (+ B D))))
                    
  (define c-
    {complex --> complex --> complex}
      C1 C2 -> (let A (real C1)
                    B (imaginary C1)
                    C (real C2)
                    D (imaginary C2)
                    (c# (- A C) (- B D))))                  
                    
  (define c*
    {complex --> complex --> complex}
      C1 C2 -> (let A (real C1)
                    B (imaginary C1)
                    C (real C2)
                    D (imaginary C2)
                    (c# (- (* A C) (* B D)) (+ (* B C) (* A D))))) 
                    
  (define c/
    {complex --> complex --> complex} 
     C1 C2 -> (let A (real C1)
                   B (imaginary C1)
                   C (real C2)
                   D (imaginary C2)
                   (c# (/ (+ (* A C) (* B D))
                          (+ (* C C) (* D D)))
                       (/ (- (* B C) (* A D))  
                          (+ (* C C) (* D D))))))
                          
                                    )                  
(package fol (append [autopc autofol.v1 autofol.v2 autofol.v3] (fol-external-symbols))

(define autopc  
   {step --> step}  
   S -> (fix (fn pc-rules) (indirect-proof S)))

(define pc-rules  
   {step --> step}  
   S -> (vl (&l (=>l (<=>l (dn (demorgan1 
                    (demorgan2 (~=> (~<=> (contradiction S)))))))))))          
                    
(define autofol.v1
   {step --> step}
   Step -> (let Clauses (clause-form (indirect-proof Step))
                 Procedure (/. X (vl (contradiction+ X)))
                 (fix Procedure Clauses)))
                
(define autofol.v2
   {step --> step}
   Step -> (let Clauses (clause-form (indirect-proof Step))
                        (trap-error (autofol-loop [Clauses]) (/. E Step))))

(define autofol-loop
   {(list step) --> step}
    [] -> (abort)                        
    [Step | _] -> Step   where (empty? Step)                 
    [Step | Steps] 
       -> (let Choices (contradiction+$ true (fix (fn vl) Step))
               (trap-error (autofol-loop Choices)
                           (/. E (autofol-loop Steps))))) 
                           
(define autofol.v3
   {step --> step}
   Step -> (autofol-amplify-loop 1 Step))
   
(define autofol-amplify-loop
  {number --> step --> step}
   N Step ->   (let Clauses (amplified-clause-form N (indirect-proof Step))
                     (trap-error (autofol-loop [Clauses]) 
                                 (/. E (autofol-amplify-loop (+ N 1) Step)))))  )

(package file [read-data eval-data]

(declare read-data [string --> [list unit]])
(declare eval-data [string -->[list unit]])

(define read-data
  File -> (let In (open File in) 
            (read-data-loop (trap-read In) In [])))
  
(define read-data-loop
  eof! In Acc -> (do (close In) (reverse Acc))
  Read In Acc -> (read-data-loop (trap-read In) In [Read | Acc]))
  
(define trap-read
  In -> (trap-error (read In) (/. E eof!))) 
  
(define eval-data
  File -> (let In (open File in) 
            (eval-data-loop (trap-eval In) In [])))
  
(define eval-data-loop
  eof! In Acc -> (do (close In) (reverse Acc))
  Read In Acc -> (eval-data-loop (trap-eval In) In [Read | Acc]))
  
(define trap-eval
  In -> (trap-error (eval (read In)) (/. E eof!))) )
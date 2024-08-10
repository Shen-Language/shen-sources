(define delete-file
  {string --> (list A)}
   File -> (cases (= (language) "Common Lisp") (lisp.delete-file File)
                  true (close (open File out))))  
                  
(declare delete-file [string --> [list A]])                                           
   
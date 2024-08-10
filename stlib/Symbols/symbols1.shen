(package symbol [concat*]

(define concat*
  S1 S2 -> (let S1+S2 (concat S1 S2)
                (if (symbol? S1+S2)
                    S1+S2
                    (error "'~A' is not a symbol~%" S1+S2))))
                    
(declare concat* [A --> [B --> symbol]]) )                   


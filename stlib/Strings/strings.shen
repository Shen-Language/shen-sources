(package string (append [s-op1 s-op2 string.reverse string.element?
                            string.infix? string.suffix? string.prefix? string.length string.difference
                            string.intersection string.nth whitespace?
                            lowercase? uppercase? digit? alpha? alphanum?
                            string.subset? string.set=? string.set? string.nth
                            string.trim string.trim-right string.trim-left
                            tokenise list->string string->list string.trim-left-if
                            string.trim-right-if string.trim-if uppercase lowercase
                            string.map file-extension strip-extension string.count
                            spell-number string>? string<? string>=? string<=?
                            string.some? string.every?] 
                            (external list))

(define string->list
  {string --> (list string)}
   "" -> []
   S -> (s->l-h S 1 (pos S 0) []))
   
(define s->l-h
  {string --> number --> string --> (list string) --> (list string)}
   S N "" L -> (reverse L)
   S N Char L -> (s->l-h S (+ N 1) (trap-error (pos S N) (/. E "")) [Char | L]))
   
(define list->string
  {(list string) --> string}
   [] -> ""
   [S | Ss] -> (cn S (list->string Ss)))   

(define s-op1
   {((list string) --> A) --> string --> (A --> B) --> B}
    F S C -> (C (F (string->list S))))
    
(define s-op2
   {((list string) --> (list string) --> A) --> string --> string --> (A --> B) --> B}
    F S1 S2 C -> (C (F (string->list S1) (string->list S2))))   
    
(define string.count
  {string --> string --> number}
   _ "" -> 0
   S (@s S Ss) -> (+ 1 (string.count S Ss))
   S (@s _ Ss) -> (string.count S Ss))     
      
(define string.reverse
   {string --> string}
    S -> (s-op1 (fn reverse) S (fn list->string)))

(define string.element?
  {string --> string --> boolean}
   Char S -> (s-op1 (/. X (element? Char X)) S))

(define string.prefix?
 {string --> string --> boolean}
  S1 S2 -> (s-op2 (fn prefix?) S1 S2))
  
(define string.infix?
 {string --> string --> boolean}
  S1 S2 -> (s-op2 (fn infix?) S1 S2))
  
(define string.suffix?
 {string --> string --> boolean}
  S1 S2 -> (s-op2 (fn suffix?) S1 S2))
  
(define string.subset?
  {string --> string --> boolean}
   S1 S2 -> (s-op2 (fn subset?) S1 S2))  
   
(define string.set=?
  {string --> string --> boolean}
   S1 S2 -> (s-op2 (fn set=?) S1 S2)) 
   
(define string.set?
  {string --> boolean}
   S -> (s-op1 (fn set?) S))  
   
(define file-extension
  {string --> string --> string}
   Path Extension -> (cn (strip-extension Path) Extension))
   
(define strip-extension
  {string --> string}
   "" -> ""
   (@s "." _) -> ""
   (@s S Ss) -> (@s S (strip-extension Ss))) 

(define string.length
  {string --> number}
   S -> (s-op1 (fn length) S))
   
(define string.trim
  {(list string) --> string --> string}
   L S -> (s-op1 (trim L) S (fn list->string)))
   
(define string.trim-if
  {(string --> boolean) --> string --> string}
   P S -> (s-op1 (trim-if P) S (fn list->string))) 
        
(define string.trim-right-if
  {(string --> boolean) --> string --> string}
   P S -> (s-op1 (trim-right-if P) S (fn list->string))) 
   
(define string.trim-left-if
  {(string --> boolean) --> string --> string}
   P S -> (s-op1 (trim-left-if P) S (fn list->string)))       

(define string.trim-right
  {(list string) --> string --> string}
   L S -> (s-op1 (trim-right L) S (fn list->string)))  
  
(define string.trim-left
  {(list string) --> string --> string}
   L S -> (s-op1 (trim-left L) S (fn list->string)))
   
(define string.some?
  {(string --> boolean) --> string --> boolean}
   _ "" -> false
   F (@s S Ss) -> (or (F S) (string.some? F Ss)))
   
(define string.every?
  {(string --> boolean) --> string --> boolean}
   _ "" -> true
   F (@s S Ss) -> (and (F S) (string.every? F Ss)))       
   
(define string.difference
  {string --> string --> string}
   S1 S2 -> (s-op2 (fn difference) S1 S2 (fn list->string)))
   
(define string.intersection
  {string --> string --> string}
   S1 S2 -> (s-op2 (fn intersection) S1 S2 (fn list->string))) 
   
(define string.nth
  {number --> string --> string}
   N S -> (pos S (+ N 1))) 
   
(define whitespace?
  {string --> boolean}
   (@s S _) -> (let N (string->n S) 
                    (element? N [9 10 13 32])))   
   
(define uppercase?
  {string --> boolean}
   (@s S _) -> (let N (string->n S)
                    (and (> N 64) (< N 91)))) 
                    
(define lowercase?
  {string --> boolean}
   (@s S _) -> (let N (string->n S)
                    (and (> N 96) (< N 123))))
                    
(define digit?
  {string --> boolean}
   (@s S _) -> (let N (string->n S)
                    (and (> N 47) (< N 58))))
                    
(define alpha?
  {string --> boolean}
   (@s S _) -> (let N (string->n S)                                                             
                    (or (and (> N 64) (< N 91))
                        (and (> N 96) (< N 123))))
   _ -> false)
                        
(define alphanum?
  {string --> boolean}
   (@s S _) -> (let N (string->n S)                                                             
                    (or (and (> N 64) (< N 91))
                        (and (> N 96) (< N 123))
                        (and (> N 47) (< N 58))))
   _ -> false)
                        
(define tokenise
  {(string --> boolean) --> string --> (list string)}
    P S -> (tokenise-h P S ""))
    
(define tokenise-h
  {(string --> boolean) --> string --> string --> (list string)}    
   _ "" S -> [S]
   P (@s S Ss) Token -> [Token | (tokenise-h P Ss "")]  where (P S)
   P (@s S Ss) Token -> (tokenise-h P Ss (@s Token S)))

(define uppercase
  {string --> string}
   (@s S Ss) -> (if (lowercase? S)
                    (@s (n->string (- (string->n S) 32)) Ss)
                    (@s S Ss)))
                    
(define lowercase
  {string --> string}
   (@s S Ss) -> (if (uppercase? S)
                    (@s (n->string (+ (string->n S) 32)) Ss)
                    (@s S Ss)))  
                    
(define string.map
  {(string --> string) --> string --> string}
   _ "" -> ""
   F (@s S Ss) -> (@s (F S) (string.map F Ss)))  
   
(define spell-number 
  {number --> string} 
   0 -> "zero" 
   N -> (scale (map (fn digits) (triples (explode N))))) 

(define digit 
  {string --> string} 
   "0" -> "" 
   "1" -> "one" 
   "2" -> "two" 
   "3" -> "three" 
   "4" -> "four" 
   "5" -> "five" 
   "6" -> "six" 
   "7" -> "seven" 
   "8" -> "eight" 
   "9" -> "nine") 
   
(define triples 
  {(list A) --> (list (list A))} 
  L -> (triples-h (reverse L) [])) 

(define triples-h 
  {(list A) --> (list (list A)) --> (list (list A))} 
  [W X Y | Z] Triples -> (triples-h Z [(reverse [W X Y]) | Triples]) 
  X Triples -> [(reverse X) | Triples]) 

(define digits 
  {(list string) --> string} 
   ["0" "0" "0"] -> "" 
   [N "0" "0"] -> (@s (digit N) " " "hundred") 
   ["0" "0" N] -> (@s "and" " " (digit N)) 
   ["0" N N'] -> (@s "and" " " (tens N N')) 
   [N "0" N'] -> (@s (digit N) " " "hundred" " " "and" " " (digit N')) 
   [N N' N''] -> (@s (digit N) " " "hundred" " " "and" " " (tens N' N'')) 
   [N N'] -> (tens N N') 
   [N] -> (digit N) 
   [] -> "") 

(define tens 
  {string --> string --> string} 
  "1" N -> (cases (= N "0") "ten" 
                  (= N "1") "eleven" 
                  (= N "2") "twelve" 
                  (= N "3") "thirteen" 
                  (= N "4") "fourteen" 
                  (= N "5") "fifteen" 
                  (= N "6") "sixteen" 
                  (= N "7") "seventeen" 
                  (= N "8") "eighteen" 
                  (= N "9") "nineteen") 
  "2" N -> (@s "twenty" " " (digit N)) 
  "3" N -> (@s "thirty"  " " (digit N)) 
  "4" N -> (@s "forty"  " " (digit N)) 
  "5" N -> (@s "fifty"  " " (digit N)) 
  "6" N -> (@s "sixty"  " " (digit N)) 
  "7" N -> (@s "seventy"  " " (digit N)) 
  "8" N -> (@s "eighty"  " " (digit N)) 
  "9" N -> (@s "ninety"  " " (digit N))) 

(define scale 
  {(list string) --> string} 
  [S] -> S 
  ["" | Ss] -> (scale Ss) 
  [S | Ss] -> (@s S (units (length [S | Ss])) (scale Ss))) 

(define units 
  {number --> string} 
  2 -> " thousand " 
  3 -> " million " 
  4 -> " billion " 
  5 -> " trillion "
  _ -> (error "this number has a magnitude beyond our text representation")) 
  
(define string>?
  {string --> string --> boolean}
  "" _ -> false
  _ "" -> true
  (@s S Ss) (@s S* S*s) -> (let SN (string->n S)
                                S*N (string->n S*)
                                (cases (> SN S*N) true
                                       (< SN S*N) false
                                       true (string>? Ss S*s))))

(define string<?
  {string --> string --> boolean}
  _ "" -> false
  "" _ -> true
  (@s S Ss) (@s S* S*s) -> (let SN (string->n S)
                                S*N (string->n S*)
                                (cases (< SN S*N) true
                                       (> SN S*N) false
                                       true (string<? Ss S*s))))
                                       
(define string>=?
  {string --> string --> boolean}
   S S* -> (or (= S S*) (string>? S S*)))
   
(define string<=?
  {string --> string --> boolean}
   S S* -> (or (= S S*) (string<? S S*)))                                            
                     )
                             
      
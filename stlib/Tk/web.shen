(package tk (external stlib)
              
(define wait-till-ready
  {string --> boolean}
  File -> true   where (check-completion? (read-file-as-bytelist File))
  File -> (wait-till-ready File))       
  
(define read-ascii
  {(list number) --> string --> (list number)}
  ASCII _ -> ASCII   where (check-completion? ASCII)
  ASCII In -> (read-ascii (read-file-as-bytelist In) In))
  
(define check-completion?
  {(list number) --> boolean}
  [101 111 116 | _] -> true
  [_ | X]           -> (check-completion? X)
  []                -> false)
  
(define url->text
  {(list number) --> (list string)}
  ASCII -> (clump (map (fn n->string) (remove-markup ASCII 1 [])) ""))
  
(define remove-markup
  {(list number) --> number --> (list number) --> (list number)}
  [] _ Rev       -> (reverse Rev)
  [62 | X] _ Rev -> (remove-markup X 1 Rev)
  [60 | X] _ Rev -> (remove-markup X 0 Rev)
  [_ | X] 0 Rev  -> (remove-markup X 0 Rev)
  [X | Y] N Rev  -> (remove-markup Y N [X | Rev]))
  
(define clump
  {(list string) --> string --> (list string)}
  [] "" -> []
  [] Word -> [Word]
  [WS | Strings] ""   -> (clump Strings "")           where (whitespace? WS)
  [WS | Strings] Word -> [Word | (clump Strings "")]  where (whitespace? WS)
  [Punctuation | Strings] ""   -> [Punctuation | (clump Strings "")]       where (not (alphanum? Punctuation)) 
  [Punctuation | Strings] Word -> [Word Punctuation | (clump Strings "")]  where (not (alphanum? Punctuation))                           
  [S | Strings] Word -> (clump Strings (cn Word S)))
  
(define text->sentences
  {(list string) --> number --> (list (list string))}
  Text Max -> (text->sentences-h Text [] Max))
  
(define text->sentences-h
  {(list string) --> (list string) --> number --> (list (list string))}
  [] Sentence _ -> [Sentence]
  Text Sentence Max -> (text->sentences-h Text [] Max) where (> (length Sentence) Max)
  ["." (@s Cap Letters) | Text] Sentence Max 
     -> (if (starts-in-uppercase? Sentence)
            [Sentence |  (text->sentences-h [(@s Cap Letters) | Text] [] Max)]  
            (text->sentences-h [(@s Cap Letters) | Text] [] Max))   where (uppercase? Cap)
  [Word | Text] Sentence Max -> (text->sentences-h Text (append Sentence [Word]) Max))
  
(define starts-in-uppercase?
  {(list string) --> boolean}
  [(@s Cap _) | _] -> (uppercase? Cap)
  _ -> false)

(define links
  {(list number) --> (list string)}
   ASCII -> (links-h ASCII 0 []))  
     
(define links-h
   {(list number) --> number --> (list number) --> (list string)}
    [] _ [] -> []
    [34 | ASCII] 1 Link                 -> [(implode Link) | (links-h ASCII 0 [])]
    [34 104 116 116 112 | ASCII] 0 Link -> (links-h ASCII 1 [104 116 116 112])
    [X | ASCII] 1 Link                  -> (links-h ASCII 1 (append Link [X]))
    [_ | ASCII] _ _                     -> (links-h ASCII 0 [])) 
    
(define implode
  {(list number) --> string}
   []      -> ""
   [X | Y] -> (cn (n->string X) (implode Y)))     )
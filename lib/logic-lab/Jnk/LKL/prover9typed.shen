(package lkl [fol.atomic? | (lkl-external-symbols)]

(define read-stream-to-string
   {(stream in) --> number --> string --> string}
   S -1 String -> String
   S Byte String -> (read-stream-to-string S (read-byte S) (cn String (n->string Byte))))

(define solution?
  {string --> boolean}
  "" -> false
  (@s "PROOF" _) -> true
  (@s _ Ss) -> (solution? Ss))

(define p9
   {prop --> string}
   P -> (@s (p9-h P) ".c#10;"))

(define p9-h
   {prop --> string}
   [all X P]    -> (@s "all " (str X) "(" (p9-h P) ")")
   [exists X P] -> (@s "exists " (str X) "(" (p9-h P) ")")
   [P => Q] -> (@s "(" (p9-h P) " -> " (p9-h Q) ")")
   [P & Q] -> (@s "(" (p9-h P) " & " (p9-h Q) ")")
   [P v Q] -> (@s "(" (p9-h P) " | " (p9-h Q) ")")
   [P <=> Q] -> (@s "(" (p9-h P) " <-> " (p9-h Q) ")")
   [~ P] -> (@s "(- (" (p9-h P) "))")
   [X = Y] -> (@s (p9-term X) " = " (p9-term Y))
   falsum -> "$F"
   [F] -> (str F)
   [F | X] -> (@s (str F) "(" (p9-terms X) ")")  where (fol.atomic? [F | X])
   P -> (str P))

(define p9-terms
  {(list term) --> string}
  [] -> ""
  [X] -> (p9-term X)
  [X Y | Z] -> (@s (p9-term X) "," (p9-terms [Y | Z])))

(define p9-term
  {term --> string}
  [] -> "nil"
  [X] -> (p9-term X)
  [X | Y] -> (@s (p9-term X) "(" (p9-terms Y) ")")
  X -> (str X))                        )

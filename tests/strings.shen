(define subst-string
  {string --> string --> string --> string}
  _ _ "" -> ""
  Rep (@s S Ss) (@s S Ss') <- (fail-if (= "failed!") (subst-string' Rep Ss Ss'))
  Rep Rem (@s S Ss) -> (@s S (subst-string Rep Rem Ss)))

(define subst-string'
  {string --> string --> string --> string}
  Rep "" Ss -> (@s Rep Ss)
  Rep (@s S Ss) (@s S Ss') -> (subst-string' Rep Ss Ss')
  _ _ _ -> "failed!")

(define rwilli
  {string --> string}
  "" -> ""
  (@s "Willi" Ss) -> (rwilli Ss)
  (@s _ Ss) -> (rwilli Ss))

(define strlen
  {string --> number}
  "" -> 0
  (@s _ S) -> (+ 1 (strlen S)))

(define trim-string-left
  {(list string) --> string --> string}
  _ "" -> ""
  Trim (@s S Ss) -> (@s S Ss)  where (not (element? S Trim))
  Trim (@s _ Ss) -> (trim-string-left Trim Ss))

(define trim-string-right
  {(list string) --> string --> string}
  Trim S -> (reverse-string (trim-string-left Trim (reverse-string S))))

(define trim-string
  {(list string) --> string --> string}
  Trim S -> (reverse-string (trim-string-left Trim (reverse-string (trim-string-left Trim S)))))

(define reverse-string
  {string --> string}
  "" -> ""
  (@s S Ss) -> (@s (reverse-string Ss) S))

(define alldigits?
  {string --> boolean}
  "" -> true
  (@s S Ss) -> (and (digit? S) (alldigits? Ss)))

(define digit?
  {string --> boolean}
  S -> (element? S ["0" "1" "2" "3" "4" "5" "6" "7" "8" "9"]))

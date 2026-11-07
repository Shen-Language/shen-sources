\\ A long let or do nests fully in one macro pass, with the same expansion.
(define long-forms.assert
  Label Expected Expected -> (output "[OK]    ~A~%" Label)
  Label Expected Actual -> (error "~A: expected ~R, got ~R" Label Expected Actual))

(define long-forms.var
  N -> (intern (cn "A" (str N))))

\\ [A1 [+ A0 1] A2 [+ A1 1] ... AN]
(define long-forms.let-args
  I N -> [(long-forms.var N)] where (> I N)
  I N -> [(long-forms.var I) [+ (long-forms.var (- I 1)) 1]
          | (long-forms.let-args (+ I 1) N)])

(define long-forms.nest-let
  [V X Body] -> [let V X Body]
  [V X | Rest] -> [let V X (long-forms.nest-let Rest)])

(define long-forms.nest
  F [X] -> X
  F [X Y | Z] -> [F X (long-forms.nest F [Y | Z])])

(define long-forms.numbers
  I N -> [] where (> I N)
  I N -> [I | (long-forms.numbers (+ I 1) N)])

(let N 300
     Args (long-forms.let-args 1 N)
     Numbers (long-forms.numbers 1 N)
  (do (long-forms.assert "long let" (long-forms.nest-let Args) (macroexpand [let | Args]))
      (long-forms.assert "long do" (long-forms.nest do Numbers) (macroexpand [do | Numbers]))
      (long-forms.assert "long +" (long-forms.nest + Numbers) (macroexpand [+ | Numbers]))
      (long-forms.assert "let without a body" [let a 1 [let b 2]] (macroexpand [let a 1 b 2]))
      (eval [define long-forms.long-let (long-forms.var 0) -> [let | Args]])
      (long-forms.assert "long let compiles" (+ 7 N) (long-forms.long-let 7))
      (long-forms.assert "long + compiles" (/ (* N (+ N 1)) 2) (eval [+ | Numbers]))))

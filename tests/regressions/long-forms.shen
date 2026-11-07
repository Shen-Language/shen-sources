\\ Long let and do forms, long string literals and byte conversions,
\\ which the kernel once handled in quadratic time.
(define long-forms.assert
  Label Expected Expected -> (output "[OK]    ~A~%" Label)
  Label Expected Actual -> (error "~A: expected ~R, got ~R" Label Expected Actual))

(define long-forms.var
  N -> (intern (cn "A" (str N))))

\\ [A1 [+ A0 1] A2 [+ A1 1] ...]
(define long-forms.bindings
  I N -> [] where (> I N)
  I N -> [(long-forms.var I) [+ (long-forms.var (- I 1)) 1]
          | (long-forms.bindings (+ I 1) N)])

(define long-forms.nest
  F [X] -> X
  F [X Y | Z] -> [F X (long-forms.nest F [Y | Z])])

(define long-forms.nest-let
  [V X Body] -> [let V X Body]
  [V X | Rest] -> [let V X (long-forms.nest-let Rest)])

(define long-forms.numbers
  I N -> [] where (> I N)
  I N -> [I | (long-forms.numbers (+ I 1) N)])

(define long-forms.ref-bytes
  "" -> []
  (@s S Ss) -> [(string->n S) | (long-forms.ref-bytes Ss)])

(define long-forms.repeat
  0 _ -> ""
  N S -> (cn S (long-forms.repeat (- N 1) S)))

(define long-forms.check
  -> (let N 300
          Body (long-forms.var N)
          Bindings (long-forms.bindings 1 N)
          Let [let | (append Bindings [Body])]
          Do [do | (long-forms.numbers 1 N)]
          Sum [+ | (long-forms.numbers 1 N)]
          Dbq (n->string 34)
          Esc (cn "c#" "65;")
          Piece (cn "x" (cn Esc "yz"))
          Literal (long-forms.repeat 400 Piece)
          Expected (long-forms.repeat 400 "xAyz")
          Unicode "héllo wörld ✓ λ"
     (do
      (long-forms.assert "long let nests fully" (long-forms.nest-let (append Bindings [Body]))
        (macroexpand Let))
      (long-forms.assert "long do nests fully" (long-forms.nest do (long-forms.numbers 1 N))
        (macroexpand Do))
      (long-forms.assert "long + nests fully" (long-forms.nest + (long-forms.numbers 1 N))
        (macroexpand Sum))
      (long-forms.assert "short let is unchanged" [let a 1 [let b 2 c]]
        (macroexpand [let a 1 b 2 c]))
      (long-forms.assert "let without a body keeps its shape" [let a 1 [let b 2]]
        (macroexpand [let a 1 b 2]))
      (eval [define long-forms.long-let (long-forms.var 0) -> Let])
      (long-forms.assert "long let compiles" (+ 7 N) (long-forms.long-let 7))
      (long-forms.assert "long do compiles" N (eval Do))
      (long-forms.assert "long + compiles" (/ (* N (+ N 1)) 2) (eval Sum))
      (long-forms.assert "shadowed let and lambda variables" [12 24 0 [6 2]]
        (long-forms.shadow 5))
      (long-forms.assert "long string literal with escapes" [Expected]
        (read-from-string (cn Dbq (cn Literal Dbq))))
      (long-forms.assert "string literal escapes at the ends" ["AbA"]
        (read-from-string (cn Dbq (cn Esc (cn "b" (cn Esc Dbq))))))
      (long-forms.assert "empty string literal" [""]
        (read-from-string (cn Dbq Dbq)))
      (long-forms.assert "str->bytes of the empty string" [] (shen.str->bytes ""))
      (long-forms.assert "str->bytes agrees with hdstr and tlstr"
        (long-forms.ref-bytes Unicode) (shen.str->bytes Unicode))
      (long-forms.assert "str->bytes of a long string agrees too"
        (long-forms.ref-bytes (long-forms.repeat 20 Unicode))
        (shen.str->bytes (long-forms.repeat 20 Unicode)))
      (long-forms.assert "bytes->string inverts str->bytes" Unicode
        (shen.bytes->string (shen.str->bytes Unicode)))
      (long-forms.assert "bytes->string of a long list" Expected
        (shen.bytes->string (shen.str->bytes Expected)))
      (long-forms.assert "bytes->string of the empty list" "" (shen.bytes->string [])))))

(define long-forms.shadow
  X -> (let X (+ X 1)
            Y (/. X (* X 2))
            X (Y X)
            Z (let X 0 X)
            P (let Q X b 2 [(/ Q 2) b])
         [X (Y X) Z P]))

(long-forms.check)

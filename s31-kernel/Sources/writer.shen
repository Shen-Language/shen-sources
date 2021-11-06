\\           Copyright (c) 2010-2019, Mark Tarver

\\                  All rights reserved.

(package shen []

(define print
  X -> (let String (insert X "~S")
            Print (pr String (stoutput))
            X))

(define pr
  String Stream -> (cases (value *hush*) String
                          (char-stoutput? Stream) (write-string String Stream)
                          true (write-chars String Stream (string->byte String 0) 1)))

(define string->byte
  String N -> (trap-error (string->n (pos String N)) (/. E eos)))

(define write-chars
  String Stream eos N -> String
  String Stream Byte N -> (write-chars String
                                       Stream
                                       (do (write-byte Byte Stream) (string->byte String N))
                                       (+ N 1)))

(define mkstr
  String Args -> (mkstr-l (proc-nl String) Args)   where (string? String)
  String Args -> (mkstr-r [proc-nl String] Args))

(define mkstr-l
  String [] -> String
  String [Arg | Args] -> (mkstr-l (insert-l Arg String) Args)
  _ _ -> (simple-error "implementation error in shen.mkstr-l"))

(define insert-l
  _ "" -> ""
  Arg (@s "~A" S) -> [app Arg S a]
  Arg (@s "~R" S) -> [app Arg S r]
  Arg (@s "~S" S) -> [app Arg S s]
  Arg (@s S Ss) -> (factor-cn [cn S (insert-l Arg Ss)])
  Arg [cn S Ss] -> [cn S (insert-l Arg Ss)]
  Arg [app S Ss Mode] -> [app S (insert-l Arg Ss) Mode]
  _ _ -> (simple-error "implementation error in shen.insert-l"))

(define factor-cn
  [cn S1 [cn S2 S3]] -> [cn (cn S1 S2) S3]  where (and (string? S1) (string? S2))
  Cn -> Cn)

(define proc-nl
 "" -> ""
 (@s "~%" Ss) -> (cn (n->string 10) (proc-nl Ss))
 (@s S Ss) -> (cn S (proc-nl Ss))
 _ -> (simple-error "implementation error in shen.proc-nl"))

(define mkstr-r
  String [] -> String
  String [Arg | Args] -> (mkstr-r [insert Arg String] Args)
  _ _ -> (simple-error "implementation error in shen.mkstr-r"))

(define insert
  Arg String -> (insert-h Arg String ""))

(define insert-h
  _ "" String -> String
  Arg (@s "~A" S) String -> (cn String (app Arg S a))
  Arg (@s "~R" S) String -> (cn String (app Arg S r))
  Arg (@s "~S" S) String -> (cn String (app Arg S s))
  Arg (@s S Ss) String -> (insert-h Arg Ss (cn String S))
  _ _ _ -> (simple-error "implementation error in shen.insert-h"))

(define app
  Arg String Mode -> (cn (arg->str Arg Mode) String))

(define arg->str
  F _ -> "..."	   		  where  (= F (fail))
  L Mode -> (list->str L Mode)    where (list? L)
  S Mode -> (str->str S Mode)  	  where (string? S)
  V Mode -> (vector->str V Mode)  where (absvector? V)
  At _ -> (atom->str At))

(define list->str
  L r -> (@s "(" (iter-list L r (maxseq)) ")")
  L Mode -> (@s "[" (iter-list L Mode (maxseq)) "]"))

(define maxseq
  -> (value *maximum-print-sequence-size*))

(define iter-list
  [] _ _ -> ""
  _ _ 0 -> "... etc"
  [X] Mode _ -> (arg->str X Mode)
  [X | Y] Mode N -> (@s (arg->str X Mode) " " (iter-list Y Mode (- N 1)))
  X Mode N -> (@s "| " (arg->str X Mode)))

(define str->str
  S a -> S
  S _ -> (@s (n->string 34) S (n->string 34)))

(define vector->str
  V Mode -> (cases (print-vector? V) ((fn (<-address V 0)) V)
                   (vector? V) (@s "<" (iter-vector V 1 Mode (maxseq)) ">")
                   true (@s "<<" (iter-vector V 0 Mode (maxseq)) ">>")))

(define print-vector?
  P -> (let Zero (<-address P 0)
                 (cases (= Zero tuple) true
                        (= Zero pvar) true
                        (not (number? Zero)) (fbound? Zero)
                        true false)))

(define fbound?
  F -> (not (= (arity F) -1)))

(define tuple
  P -> (make-string "(@p ~S ~S)" (<-address P 1) (<-address P 2)))

(define iter-vector
  _ _ _ 0 -> "... etc"
  V N Mode Max -> (let Item (trap-error (<-address V N) (/. E out-of-bounds))
                       Next (trap-error (<-address V (+ N 1)) (/. E out-of-bounds))
                       (cases (= Item out-of-bounds) ""
                              (= Next out-of-bounds) (arg->str Item Mode)
                              true (@s (arg->str Item Mode)
                                       " "
                                       (iter-vector V (+ N 1) Mode (- Max 1))))))

(define atom->str
  At -> (trap-error (str At) (/. E (funexstring))))

(define funexstring
  -> (@s "c#16;fune" (arg->str (gensym (intern "x")) a) "c#17;"))

(define list?
  X -> (or (empty? X) (cons? X)))		)
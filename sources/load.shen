\\           Copyright (c) 2010-2019, Mark Tarver

\\                  All rights reserved.

(package shen []

(define load
   File     -> (let TC?   (value *tc*)
                    Load  (time (load-help TC? (read-file File)))
                    Infs  (if TC? (output "~%typechecked in ~A inferences~%" (inferences)) skip)
                 loaded))

(define load-help
  false Code -> (eval-and-print Code)
  _ Code     -> (check-eval-and-print Code))

(define eval-and-print
  X -> (for-each (/. Y (output "~S~%" (eval-kl (shen->kl Y)))) X))

(define check-eval-and-print
  X -> (let Table (mapcan (/. Y (typetable Y)) X)
            Assume (trap-error (assumetypes Table) (/. E (unwind-types E Table)))
            (trap-error (work-through X)
                        (/. E (unwind-types E Table)))))

(define typetable
  [define F { | X] -> [F (rectify-type (type-F F X))]
  [define F | _]   -> (error "missing { in ~A~%" F)
  _ -> [])

(define type-F
  _ [} | _] -> []
  F [X | Y] -> [X | (type-F F Y)]
  F _ -> (error "missing } in ~A~%" F))

(define assumetypes
  [] -> []
  [F Type | Table] -> (do (declare F Type) (assumetypes Table))
  _ -> (simple-error "implementation error in shen.assumetype"))

(define unwind-types
  E [F _ | Table] -> (do (destroy F) (unwind-types E Table))
  E _ -> (simple-error (error-to-string E)))

(define work-through
  [] -> []
  [X Colon A | Y] -> (let Check (typecheck X A)
                     (if (= Check false)
                         (type-error)
                         (let Eval (eval-kl (shen->kl X))
                              Message (output "~S : ~R~%" Eval (pretty-type Check))
                              (work-through Y))))   where (= Colon (intern ":"))
  [X | Y] -> (work-through [X (intern ":") (protect A) | Y])
  _ -> (simple-error "implementation error in shen.work-through"))

(define pretty-type
  [[list A] --> [str [list A] B]] -> [[list A] ==> B]
  [X | Y] -> (map (/. Z (pretty-type Z)) [X | Y])
  A -> A)


(define type-error
  -> (error "type error~%"))

(define bootstrap
  File -> (let KLFile (klfile File)
               Code (read-file File)
               Open (open KLFile out)
               KL (map (/. X (partial (shen->kl-h X))) Code)
               Write (write-kl KL Open)
               KLFile))

(define partial
   [f-error F] -> [simple-error (cn "partial function " (str F))]
   [X | Y] -> (map (/. Z (partial Z)) [X | Y])
   X -> X)

(define write-kl
  [] Open -> (close Open)
  [KL | KLs] Open -> (write-kl KLs (do (write-kl-h KL Open)
                                       Open)) where (cons? KL)
  [_ | KLs] Open -> (write-kl KLs Open))

(define write-kl-h
 [defun fail [] _] Open -> (pr "(defun fail () shen.fail!)" Open)
 KL Open -> (pr (make-string "~R~%~%" KL) Open))

(define klfile
  "" -> ".kl"
  ".shen" -> ".kl"
  (@s S Ss) -> (@s S (klfile Ss)))

)

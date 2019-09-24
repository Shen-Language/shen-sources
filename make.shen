\\ LICENSE NOTE: This code is used to generate KLambda from Shen source
\\ under the 3-clause BSD license. The code may be changed but the contents
\\ of "LICENSE.txt" must be copied to the generated KLambda verbatim. The
\\ KLambda produced is a direct derivative of the Shen sources which are
\\ 3-clause BSD licensed. Please look at the file LICENSE.txt for an
\\ accompanying discussion.

\\ (c) Mark Tarver 2015, all rights reserved

(load "extensions/expand-dynamic.shen")

(define make ->
  (do
    (output "~%")
    (output "compiling *.shen to *.kl:~%")
    (map (function systemf) [internal receive <!> sterror *sterror* ,])
    (map (function make.unsystemf) [\* FOR TESTING: Add function names here to be able to redefine them *\])
    (let License (read-file-as-string "LICENSE.txt")
      (map
        (/. File (do (output "  - ~A~%" File) (make.make-file License File)))
        ["core"
         "declarations"
         "load"
         "macros"
         "prolog"
         "reader"
         "sequent"
         "sys"
         "dict"
         "t-star"
         "toplevel"
         "track"
         "types"
         "writer"
         "yacc"]))
    (output "compilation complete.~%")
    ()))

(define make.unsystemf
  Sym -> (put shen shen.external-symbols
              (remove Sym (get shen shen.external-symbols))))

\* Required to avoid errors when processing functions with system names *\
(defcc shen.<name>
  X := (if (symbol? X)
           X
           (error "~A is not a legitimate function name.~%" X)))

(define make.make-file
  License File ->
    (let ShenFile (make-string "sources/~A.shen" File)
         KlFile (make-string "klambda/~A.kl" File)
         ShenCode (read-file ShenFile)
         KlCode* (map (function make.make-kl-code) ShenCode)
         KlCode (shen.x.expand-dynamic.expand-dynamic KlCode*)
         KlString (make-string "c#34;~Ac#34;~%~%~A" License (make.list->string KlCode))
         Write (write-to-file KlFile KlString)
      KlFile))

(define make.make-kl-code
  [define F | Rules] -> (shen.elim-def [define F | Rules])
  [defcc F | Rules] -> (shen.elim-def [defcc F | Rules])
  Code -> Code)

(define make.list->string
  [] -> ""
  \* shen.fail! prints as "...", needs to be handled separately *\
  [[defun fail | _] | Y] -> (@s "(defun fail () shen.fail!)" (make.list->string Y))
  [X | Y] -> (@s (make-string "~R~%~%" X) (make.list->string Y)))

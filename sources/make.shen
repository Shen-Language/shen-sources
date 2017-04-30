\\ License Note:  this code is used to generate KLambda from Shen source under the 3-clause BSD license.  The code may be changed but
\\ the license attached to the generated KLambda may **not** be changed.  The KLambda produced is a direct derivative of the Shen sources
\\ which are 3 clause BSD licensed.  Please look at the file license.pdf for an accompanying discussion.
\\
\\ (c) Mark Tarver 2015, all rights reserved

(systemf internal)
(systemf receive)
(systemf <!>)
(systemf dict)
(systemf dict?)
(systemf dict-count)
(systemf dict->)
(systemf <-dict/or)
(systemf <-dict)
(systemf dict-rm)
(systemf dict-fold)
(systemf dict-keys)
(systemf dict-values)
(systemf <-vector/or)
(systemf <-address/or)
(systemf value/or)
(systemf get/or)
(systemf for-each)
(systemf fold-left)
(systemf fold-right)
(systemf filter)
(systemf exit)
(systemf sterror)
(systemf read-char-code)
(systemf read-file-as-charlist)
(systemf *sterror*)
(systemf *argv*)
(systemf command-line)

(define make
  -> (map (function make-file)
          ["core.shen" "declarations.shen" "load.shen" "macros.shen"
           "prolog.shen" "reader.shen" "sequent.shen" "sys.shen" "t-star.shen"
           "toplevel.shen"  "track.shen"  "types.shen" "writer.shen"
           "yacc.shen"]))

\* Required to avoid errors when processing functions with system names *\
(defcc shen.<name>
  X := (if (symbol? X)
           X
           (error "~A is not a legitimate function name.~%" X)))

\* Required so that older versions process get/or correctly *\
(define shen.put/get-macro
  [put X Pointer Y] -> [put X Pointer Y [value *property-vector*]]
  [get X Pointer] -> [get X Pointer [value *property-vector*]]
  [get/or X Pointer Or] -> [get/or X Pointer Or [value *property-vector*]]
  [unput X Pointer] -> [unput X Pointer [value *property-vector*]]
  X -> X)

(define make-file
  ShenFile -> (let Message (output "compiling ~A~%" ShenFile)
                   Shen (read-file ShenFile)
                   KL (map (function make-kl-code) Shen)
                   StringKL (@s (license) (list->string KL))
                   KLFile (klfile ShenFile)
                   Write (write-to-file KLFile StringKL)
                 KLFile))

(define make-kl-code
  [define F | Rules] -> (shen.elim-def [define F | Rules])
  [defcc F | Rules] -> (shen.elim-def [defcc F | Rules])
  Code -> Code)

(define klfile
  ".shen" -> ".kl"
  (@s S Ss) -> (@s S (klfile Ss)))

(define list->string
  [] -> ""
  \* Needed for 19.2, doesn't prefix `shen` correctly *\
  [[defun shen | Args] | Body] -> (list->string [[defun shen.shen | Args] | Body])
  \* shen.fail! prints as "...", needs to be handled separately *\
  [[defun fail | _] | Y] -> (@s "(defun fail () shen.fail!)" (list->string Y))
  [X | Y] -> (@s (make-string "~R~%~%" X) (list->string Y)))

\\_________________________________________________________________________________________________
\\ Note it is an offence to tamper with this section of code.  This code is **not** under BSD.

(define license
  -> "c#34;Copyright (c) 2015, Mark Tarver

All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
1. Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.
3. The name of Mark Tarver may not be used to endorse or promote products
   derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY Mark Tarver ''AS IS'' AND ANY
EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL Mark Tarver BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.c#34;

")



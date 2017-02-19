\*

Copyright (c) 2010-2015, Mark Tarver

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
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

*\

(package shen []

(define shen
  -> (do (credits) (loop)))

(define loop
  -> (do (initialise_environment)
         (prompt)
         (trap-error
          (read-evaluate-print)
          (/. E (pr (error-to-string E) (stoutput))))
         (loop)))

(define credits
  -> (do (output "~%Shen, copyright (C) 2010-2015 Mark Tarver~%")
         (output "www.shenlanguage.org, ~A~%" (value *version*))
         (output "running under ~A, implementation: ~A"
                 (value *language*) (value *implementation*))
         (output "~%port ~A ported by ~A~%" (value *port*) (value *porters*))))

(define initialise_environment
  -> (multiple-set [*call* 0 *infs* 0 *process-counter* 0 *catch* 0]))

(define multiple-set
  [] -> []
  [S V | M] -> (do (set S V) (multiple-set M)))

(define destroy
  F -> (declare F symbol))

(set *history* [])

(define read-evaluate-print
  -> (let Lineread (toplineread)
          History (value *history*)
          NewLineread (retrieve-from-history-if-needed Lineread History)
          NewHistory (update_history NewLineread History)
          Parsed (fst NewLineread)
       (toplevel Parsed)))

(define retrieve-from-history-if-needed
  (@p Line [C | Cs]) H -> (retrieve-from-history-if-needed (@p Line Cs) H)
      where (element? C [(space) (newline)])
  (@p _ [C1 C2]) [H | _] -> (let PastPrint (prbytes (snd H))
                               H)
      where (and (= C1 (exclamation)) (= C2 (exclamation)))
  (@p _ [C | Key]) H -> (let Key? (make-key Key H)
                             Find (head (find-past-inputs Key? H))
                             PastPrint (prbytes (snd Find))
                           Find)
      where (= C (exclamation))
  (@p _ [C]) H -> (do (print-past-inputs (/. X true) (reverse H) 0)
                      (abort))
      where (= C (percent))
  (@p _ [C | Key]) H -> (let Key? (make-key Key H)
                             Pastprint (print-past-inputs Key? (reverse H) 0)
                          (abort))
      where (= C (percent))
  Lineread _ -> Lineread)

(define percent
  -> 37)

(define exclamation
  ->  33)

(define prbytes
  Bytes -> (do (map (/. Byte (pr (n->string Byte) (stoutput))) Bytes)
               (nl)))

(define update_history
  Lineread History -> (set *history* [Lineread  | History]))

(define toplineread
  -> (toplineread_loop (read-byte (stinput)) []))

(define toplineread_loop
  Byte _ -> (error "line read aborted")  where (= Byte (hat))
  Byte Bytes -> (let Line (compile (/. X (<st_input> X)) Bytes (/. E nextline))
                     It (record-it Bytes)
                  (if (or (= Line nextline) (empty? Line))
                      (toplineread_loop (read-byte (stinput))
                                        (append Bytes [Byte]))
                      (@p Line Bytes)))
      where (element? Byte [(newline) (carriage-return)])
  Byte Bytes -> (toplineread_loop (read-byte (stinput)) (append Bytes [Byte])))

(define hat
  -> 94)

(define newline
  -> 10)

(define carriage-return
  -> 13)

(define tc
  + -> (set *tc* true)
  - -> (set *tc* false)
  _ -> (error "tc expects a + or -"))

(define prompt
  -> (if (value *tc*)
         (output  "~%~%(~A+) " (length (value *history*)))
         (output  "~%~%(~A-) " (length (value *history*)))))

(define toplevel
  Parsed -> (toplevel_evaluate Parsed (value *tc*)))

(define find-past-inputs
  Key? H -> (let F (find Key? H)
              (if (empty? F)
                  (error "input not found~%")
                  F)))

(define make-key
  Key H -> (let Atom (hd (compile (/. X (<st_input> X)) Key))
             (if (integer? Atom)
                 (/. X (= X (nth (+ Atom 1) (reverse H))))
                 (/. X (prefix? Key (trim-gubbins (snd X)))))))

(define trim-gubbins
  [C | X] -> (trim-gubbins X)  where (= C (space))
  [C | X] -> (trim-gubbins X)  where (= C (newline))
  [C | X] -> (trim-gubbins X)  where (= C (carriage-return))
  [C | X] -> (trim-gubbins X)  where (= C (tab))
  [C | X] -> (trim-gubbins X)  where (= C (left-round))
  X -> X)

(define space
  -> 32)

(define tab
  -> 9)

(define left-round
  -> 40)

(define find
  _ [] -> []
  F [X | Y] -> [X | (find F Y)]	where (F X)
  F [_ | Y] -> (find F Y))

(define prefix?
  [] _ -> true
  [X | Y] [X | Z] -> (prefix? Y Z)
  _ _ -> false)

(define print-past-inputs
  _ [] _ -> _
  Key? [H | Hs] N -> (print-past-inputs Key? Hs (+ N 1)) 	where (not (Key? H))
  Key? [(@p _ Cs) | Hs] N -> (do (output "~A. " N)
                                 (prbytes Cs)
                                 (print-past-inputs Key? Hs (+ N 1))))

(define toplevel_evaluate
  [X : A] true -> (typecheck-and-evaluate X A)
  [X Y | Z] Boolean -> (do (toplevel_evaluate [X] Boolean)
                           (nl)
                           (toplevel_evaluate [Y | Z] Boolean))
  [X] true -> (typecheck-and-evaluate X (gensym (protect A)))
  [X] false -> (let Eval (eval-without-macros X)
                 (print Eval)))

(define typecheck-and-evaluate
  X A -> (let Typecheck (typecheck X A)
           (if (= Typecheck false)
               (error "type error~%")
               (let Eval (eval-without-macros X)
                    Type (pretty-type Typecheck)
                 (output "~S : ~R" Eval Type)))))

(define pretty-type
  Type -> (mult_subst (value *alphabet*) (extract-pvars Type) Type))

(define extract-pvars
  X -> [X]  where (pvar? X)
  [X | Y] -> (union (extract-pvars X) (extract-pvars Y))
  _ -> [])

(define mult_subst
  [] _ X -> X
  _ [] X -> X
  [X | Y] [W | Z] A -> (mult_subst Y Z (subst X W A)))

)

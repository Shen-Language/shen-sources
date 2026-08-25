(package lkl [*home-directory* | (lkl-external-symbols)]

(declare prover9 [valid --> valid])

(d-rule prover9 ()

  if (prover9-soluble? Hypotheses P)
  _____________________________________
   P;)

(define prover9-soluble?
  Hyp P ->  (let CtxtP9 (map (function p9) Hyp)
                 PP9 (p9 P)
                 Solution? (send-to-prover9 CtxtP9 PP9)
                 Solution?))

(define send-to-prover9
  CtxtP9 PP9 -> (let P9Command (@s "if(Prover9).
                                      assign(max_seconds, 10).
                                     end_if.c#13;"
                                    "formulas(assumptions).c#13;"
                                   (list->string CtxtP9)
                                   "c#13;end_of_list.c#13;c#13;"
                                   "formulas(goals).c#13;"
                                   PP9
                                   "c#13;end_of_list.c#13;")
                     Write (write-to-file "Prover9.in" P9Command)
                     Prover9In (make-string "~A~A" (value *home-directory*) "Prover9.in")
                     Open (open-process-stream "C:/Program Files (x86)/Prover9-Mace4/bin-win32/prover9.exe"
                                               ["-f" Prover9In])
                     String (read-stream-to-string Open (read-byte Open) "")
                     Out (write-to-file "Prover9.out" String)
                     Close (close Open)
                     (solution? String)))                       )

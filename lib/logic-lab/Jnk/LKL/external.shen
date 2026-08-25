(define lkl-external-symbols
  {--> (list symbol)}
   -> (append (external stlib)
              (external fol)
              [fol.sub fol.subn fol.sub* fol.t-term?]
              [open-process-stream]
              [nat succ pred type def]
              [w x y z x1 x2 x3 y1 y2 y3 z1 z2 z3]
              [axiomatise mathind verum listind nn1 nn2 nn3 nn4 l1 l2 l3 l4 l5 l6 b1 t1 t2 t3 t4 t5 because beta semantics prover9]))

(define pc-external-symbols
  {--> (list symbol)}
  -> (append (external stlib) [~ v & => <=> prop d-rule hyp vr1 vr2 vl &r &l =>r =>l  
                               <=>r <=>l ~r ~l lemma lem exp thin swap falsum]))
  
(tc +)
(load "syntax.shen")
(load "derivation rules.shen")
(define backchain
  Conc Assumptions -> (backchain* Conc Assumptions Assumptions))

(define backchain*
  P [P | _] _ -> true
  [P & Q] _ Assumptions
  -> (and (backchain* P Assumptions Assumptions)
          (backchain* Q Assumptions Assumptions))
  P [[P <= Q] | _] Assumptions
  <- (fail-if (/. X (= X false)) (backchain* Q Assumptions Assumptions))
  P [_ | Rest] Assumptions -> (backchain* P Rest Assumptions)
  _ _ _ -> false)

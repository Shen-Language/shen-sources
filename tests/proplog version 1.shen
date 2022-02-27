(define backchain
  Conc Assumptions -> (backchain* [Conc] Assumptions Assumptions))

(define backchain*
  [] _ _ -> proved
  [[P & Q] | Goals] _ Assumptions
  -> (backchain* [P Q | Goals] Assumptions Assumptions)
  [P | Goals] [[P <= | Subgoal] | _] Assumptions
  <- (backchain* (append Subgoal Goals) Assumptions Assumptions)
  Goals [_ | Rest] Assumptions -> (backchain* Goals Rest Assumptions)
  _ _ _ -> (fail))

(let G (group-theory)
      P      [all x [[+ [inv x] x] = e]]
      Lemma  [all x [[inv [inv x]] = x]] 
      [G P (initialise-plan) 
           (kb-> G) 
           (lemma Lemma "Prove [all x [[inv [inv x]] = x]]") 
           (kb-> [Lemma | G]) 
           (lemma P "Prove [all x [[+ [inv x] x] = e]]") 
           (end-of-plan)])

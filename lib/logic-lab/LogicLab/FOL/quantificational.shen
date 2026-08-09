(package fol (fol-external-symbols)
     
    (define freshterm?
      {term --> (list prop) --> boolean}  
       Tm Props -> (and (t-term? Tm)
                        (= (occurrences Tm Props) 0)))

    (define t-term?
      {term --> boolean}
       Term -> (and (symbol? Term) (t-term-h? (x->ascii Term))))
       
     (define t-term-h? 
       {(list number) --> boolean}    
       [116 109 | _] -> true
       _ -> false)
       
    (define sub
        {term --> term --> prop --> prop}
        Tm V [all V P] -> [all V P]    
        Tm V [exists V P] -> [exists V P]  
        Tm V [all X Y] -> [all X (sub Tm V Y)]
        Tm V [exists X Y] -> [exists X (sub Tm V Y)]
        Tm V [P v Q] -> [(sub Tm V P) v (sub Tm V Q)]
        Tm V [P & Q] -> [(sub Tm V P) & (sub Tm V Q)]	
        Tm V [P => Q] -> [(sub Tm V P) => (sub Tm V Q)]
        Tm V [P <=> Q] -> [(sub Tm V P) <=> (sub Tm V Q)]
        Tm V [~ P] -> [~ (sub Tm V P)]
        Tm V [X = Y] -> [(sub* Tm V X) = (sub* Tm V Y)]
        Tm V [F | Terms] -> [F | (map (/. Term (sub* Tm V Term)) Terms)]  where (atomic? [F | Terms])
        _ _ P -> P)  
  
    (define sub*
      {term --> term --> term --> term}
      Tm V V -> Tm
      Tm V [lambda V X] -> [lambda V X]
      Tm V [Tm1 | Tms] -> [(sub* Tm V Tm1) 
                             | (map (/. Term (sub* Tm V Term)) Tms)]
      _ _ Term -> Term)
    
    (define subn
        {term --> term --> prop --> number --> prop}
        Tm _ [all V P] _ -> [all V P]    where (== Tm V)
        Tm _ [exists V P] _ -> [exists V P]  where (== Tm V)
        Tm V [all X Y] N -> [all X (subn Tm V Y N)]
        Tm V [exists X Y] N -> [exists X (subn Tm V Y N)]
        Tm V [P v Q] N -> (let OccN (occurrences V P)
                             (if (> N OccN) 
                                 [P v (subn Tm V Q (- N OccN))]
                                 [(subn Tm V P N) v Q]))
        Tm V [P & Q] N -> (let OccN (occurrences V P)
                             (if (> N OccN) 
                                 [P v (subn Tm V Q (- N OccN))]
                                 [(subn Tm V P N) & Q]))
        Tm V [P => Q] N -> (let OccN (occurrences V P)
                             (if (> N OccN) 
                                 [P v (subn Tm V Q (- N OccN))]
                                 [(subn Tm V P N) => Q]))
        Tm V [P <=> Q] N -> (let OccN (occurrences V P)
                             (if (> N OccN) 
                                 [P v (subn Tm V Q (- N OccN))]
                                 [(subn Tm V P N) <=> Q]))
        Tm V [~ P] N -> [~ (subn Tm V P N)]
        Tm V [X = Y] N -> (let OccN (occurrences V X)
                             (if (> N OccN)
                                 [X = (subn* Tm V Y (- N OccN))]
                                 [(subn* Tm V X N) = Y]))
        Tm V [F | Terms] N -> [F | (map (/. T (subn* Tm V T N)) Terms)] 
                                where (atomic? [F | Terms])
        _ _ P _ -> P)
        
    (define subn*
      {term --> term --> term --> number --> term}
      Tm V V 1 -> Tm
      Tm V [X | Y] N -> (let OccN (occurrences V X) 
                             (if (> N OccN)
                                 (addterm X (subn* Tm V Y (- N OccN)))
                                 [(subn* Tm V X N) | Y]))
      _ _ X _ -> X)  
      
    (define addterm
      {term --> term --> term}
       X [] -> [X]
       X [Y | Z] -> [X Y | Z])              

    (d-rule =r ()
      
       _______
       [X = X];)
        
      (d-rule =l (N : number)
      
       let PX/Y (subn X Y P N)
       [X = Y] >> PX/Y;
       ________________________
       [X = Y] >> P;)       
           
     (d-rule alll (T : term)
      
       let PX/T (sub T X P)
       PX/T, [all X P] >> Q;
       ________________________
       [all X P] >> Q;)
       
     (d-rule allr (T : term)
      
       if (freshterm? T [[all X P] | Hypotheses])
       let PX/T (sub T X P)
       PX/T;
       ________________________
       [all X P];)
       
      (d-rule existsl (T : term)
      
       if (freshterm? T [Q [exists X P] | Hypotheses])
       let PX/T (sub T X P)
       PX/T >> Q;
       ________________________
       [exists X P] >> Q;)
       
     (d-rule existsr (T : term)
      
       let PX/T (sub T X P)
       PX/T;
       ________________________
       [exists X P];) )
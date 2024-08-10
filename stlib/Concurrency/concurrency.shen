(package p (external p)

(define free-cores?
  {--> boolean}
   -> (> (- (cores) (processes)) 0))   
  
(define p.<-!
 {(sproc A) --> A}
 Process -> (p.<- Process) where (terminated? Process)
 Process -> (p.<-! Process))
 
(define p-and-rotate
  {(list (sproc boolean)) --> boolean}
  [] -> true
  [P | Ps] -> (if (p.<- P)  
                  (p-and-rotate Ps)
                  false)              where (terminated? P)
  [P | Ps] -> (p-and-rotate (append Ps [P]))) 
  
(define p-or-rotate
  {(list (sproc boolean)) --> boolean}
  [] -> false
  [P | Ps] -> (if (p.<- P)
                  true
                  (p-or-rotate Ps))   where (terminated? P)
  [P | Ps] -> (p-or-rotate (append Ps [P])))  
  
(define terminate-proc
 {(sproc A) --> thread}
  Proc -> (if (terminated? Proc)
              (thread-in Proc)
              (do (prccount-) (terminate (thread-in Proc)))))

(define p-and-rotate!
  {(list (sproc boolean)) --> boolean}
  [] -> true
  [P | Ps] -> (if (p.<- P)  
                  (p-and-rotate! Ps)
                  (do 
                   (map (fn terminate-proc) Ps)
                   false))            where (terminated? P)
  [P | Ps] -> (p-and-rotate! (append Ps [P]))) 

(define p-or-rotate!
  {(list (sproc boolean)) --> boolean}
  [] -> false
  [P | Ps] -> (if (p.<- P)
               (do (map (fn terminate-proc) Ps) 
                   true)
               (p-or-rotate! Ps))   where (terminated? P)
  [P | Ps] -> (p-or-rotate! (append Ps [P])))

(define p-cases-h
  {(list ((sproc boolean) * (lazy A))) --> A}
  [] -> (error "case failure")
  [(@p Proc Result) | Cases] 
  -> (if (p.<- Proc)
         (thaw Result)
         (p-cases-h Cases))         where (terminated? Proc)
    Cases -> (p-cases-h Cases))

(define terminate-case
   {((sproc A) * B) --> thread}
    (@p Proc _) -> (terminate-proc Proc))
    
(define p-anycases-h
 {(list ((sproc boolean) * (lazy A))) --> A}
 [] -> (error "case failure")
 [(@p Proc Result) | Cases] 
 -> (if (p.<- Proc)
          (thaw Result)
          (p-cases-h Cases))        where (terminated? Proc)
 [Case | Cases] -> (p-cases-h (append Cases [Case])))

(define p-cases-h!
 {(list ((sproc boolean) * (lazy A))) --> A}
 [] -> (error "case failure")
 [(@p Proc Result) | Cases] 
 -> (if (p.<- Proc)
        (do (map (fn terminate-case) Cases)
            (thaw Result))
            (p-cases-h! Cases))     where (terminated? Proc)
 Cases -> (p-cases-h! Cases))

(define p-anycases-h!
  {(list ((sproc boolean) * (lazy A))) --> A}
    [] -> (error "case failure")
  [(@p Proc Result) | Cases] 
  -> (if (p.<- Proc)
         (do (map (fn terminate-case) Cases) 
             (thaw Result))
         (p-cases-h! Cases)) 	      where (terminated? Proc)
    [Case | Cases] -> (p-anycases-h! (append Cases [Case]))) )
(define depth'
  {A --> (A --> (list A)) --> (A --> boolean) --> (A --> boolean) --> (list A)}
  State Successors Goal? Fail? -> (depth-help' [State] Successors Goal? Fail? []))

(define depth-help'
  {(list A) --> (A --> (list A)) --> (A --> boolean) --> (A --> boolean) --> (list A) --> (list A)}
  [State | _] _ Goal? _ Path -> (reverse [State | Path]) 	where (Goal? State)
  [State | _] _ _ Fail? _ -> [] 				where (Fail? State)
  [State | _] Successors Goal? Fail? Path
  <- (fail-if (function empty?)
              (depth-help' (Successors State)
                           Successors Goal? Fail? [State | Path]))
  [_ | States] Successors Goal? Fail? Path
  -> (depth-help' States Successors Goal? Fail? Path)
  _ _ _ _ _ -> [])

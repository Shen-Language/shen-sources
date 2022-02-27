(define bubble-sort
  \* bubble again if you need to *\
  X -> (bubble-again-perhaps (bubble X) X))

(define bubble
  [] -> []
  [X] -> [X]
  [X Y | Z] -> [Y | (bubble [X | Z])]   where    (> Y X)
  [X Y | Z] -> [X | (bubble [Y | Z])])

(define bubble-again-perhaps
  \* no change as a result of bubbling - then the job is done *\
  X X -> X
  \* else bubble again *\
  X _ -> (bubble-sort X))

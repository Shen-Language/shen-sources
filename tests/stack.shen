(declare empty-stack [A --> [stack B]])

(declare push [A --> [stack A] --> [stack A]])

(declare top [[stack A] --> A])

(declare pop [[stack A] --> [stack A]])

(define empty-stack
  _ -> (/.  X (if (or (= X pop) (= X top))
                  (error "this stack is empty~%")
                  (error "~A is not an operation on stacks.~%" X))))

(define push
  X S -> (/. Y (if (= Y pop)
                   S
                   (if (= Y top)
                       X
                       (error "~A is not an operation on stacks.~%" Y)))))

(define top
  S -> (S top))

(define pop
  S -> (S pop))

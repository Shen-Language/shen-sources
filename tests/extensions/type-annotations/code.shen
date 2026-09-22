(define type-annotations-tests.string=
  {string --> string --> boolean}
  X X -> true
  _ _ -> false)

(define type-annotations-tests.identity
  {A --> A}
  X -> X)

(define type-annotations-tests.list-head
  {(list A) --> A}
  [X | _] -> X)

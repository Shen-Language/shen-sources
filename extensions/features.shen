\* Copyright (c) 2019 Bruno Deferrari. *\
\* BSD 3-Clause License: http://opensource.org/licenses/BSD-3-Clause *\

\\ Documentation: docs/extensions/features.md

(package shen.x.features []

(defmacro cond-expand-macro
  [cond-expand] -> (error "Unfulfilled shen.x.features.cond-expand clause.")
  [cond-expand true Body]
    -> Body
  [cond-expand [and] Body | MoreClauses]
    -> Body
  [cond-expand [and Feature | MoreFeatures] Body | MoreClauses]
    -> [cond-expand
        Feature [cond-expand
                  [and | MoreFeatures] Body
                  | MoreClauses]
        | MoreClauses]
  [cond-expand [or] Body | MoreClauses]
    -> [cond-expand | MoreClauses]
  [cond-expand [or Feature | MoreFeatures] Body | MoreClauses]
    -> [cond-expand
        Feature Body
        true [cond-expand
               [or | MoreFeatures] Body
               | MoreClauses]]
  [cond-expand [not Feature] Body | MoreClauses]
    -> [cond-expand
        Feature [cond-expand | MoreClauses]
        true Body]
  [cond-expand Feature Body | MoreClauses]
    -> Body where (element? Feature (value *features*))
  [cond-expand Feature Body | MoreClauses]
    -> [cond-expand | MoreClauses])

(define initialise
  Features -> (set *features* Features))

(define add
  Feature -> (set *features* (adjoin Feature (value *features*))))

)

\* Copyright (c) 2019 Bruno Deferrari. *\
\* BSD 3-Clause License: http://opensource.org/licenses/BSD-3-Clause *\

\\ See docs at the end of the file

(package shen/feature-expand [feature-expand *features*]

(defmacro feature-expand-macro
  [feature-expand] -> (error "Unfulfilled feature-expand.")
  [feature-expand true Body]
    -> Body
  [feature-expand [and] Body | MoreClauses]
    -> Body
  [feature-expand [and Feature | MoreFeatures] Body | MoreClauses]
    -> [feature-expand
        Feature [feature-expand
                  [and | MoreFeatures] Body
                  | MoreClauses]
        | MoreClauses]
  [feature-expand [or] Body | MoreClauses]
    -> [feature-expand | MoreClauses]
  [feature-expand [or Feature | MoreFeatures] Body | MoreClauses]
    -> [feature-expand
        Feature Body
        true [feature-expand [or | MoreFeatures] Body | MoreClauses]]
  [feature-expand [not Feature] Body | MoreClauses]
    -> [feature-expand
        Feature [feature-expand | MoreClauses]
        true Body]
  [feature-expand Feature Body | MoreClauses]
    -> Body where (element? Feature (value *features*))
  [feature-expand Feature Body | MoreClauses]
    -> [feature-expand | MoreClauses])

)

\\ How to use:
\\
\\ Ports that want to support conditional expansion based on features
\\ have to set the global `*features*` variable to a list of feature
\\ symbols. As a minimum, the list should contain at least one symbol
\\ that uniquely identifies the port.
\\
\\ Examples:
\\
\\     (feature-expand
\\      feat1 (pr "has feat1c#10;") \\ prints this
\\      feat2 (pr "has feat2c#10;"))
\\
\\     (feature-expand
\\      no-feat (pr "has no-featc#10;")
\\      true (pr "doesn't have no-featc#10;")) \\ prints this
\\
\\     (feature-expand
\\      (and feat1 feat2) (pr "has feat1 and feat2c#10;") \\ prints this
\\      true (pr "doesn't have both feat1 and feat2c#10;"))
\\
\\     (feature-expand
\\      (or no-feat feat1 feat2) (pr "has no-feat or feat1 or feat2c#10;") \\ prints this
\\      true skip)
\\
\\     (feature-expand
\\      (not no-feat) (pr "doesn't have no-featc#10;") \\ prints this
\\      no-feat (pr "has no-featc#10;")
\\      true skip)
\\
\\     (feature-expand
\\      no-feat (pr "has no-featc#10;")) \\ raises error

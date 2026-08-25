(package logiclab [valid]

(define tactic
  -> (let Prompt   (output "~%> ")
          Read     (read)
          Tactic   (hd (read-from-string-unprocessed (it)))
          F        (cases (d-rule? Tactic)        [lambda (protect X) [let (protect Solutions)
                                                                           [Tactic false (protect X)]
                                                                           [if [empty? (protect Solutions)]
                                                                               (protect X)
                                                                               [head (protect Solutions)]]]]
                          (d-application? Tactic) [lambda (protect X) [let (protect Solutions)
                                                                           (append Tactic [false] [(protect X)])
                                                                           [if [empty? (protect Solutions)]
                                                                               (protect X)
                                                                               [head (protect Solutions)]]]]
                          (symbol? Tactic)        [lambda (protect X) [Tactic (protect X)]]
                          true                    Tactic)
          Check (shen.typecheck F [valid --> valid])
          (if (= Check false)
              (do (output "type error; expected an input of type valid --> valid~%") (tactic))
              (eval F))))

(define d-rule?
  F -> (element? F (value *d-rules*)))

(define d-application?
  [F | _] -> (d-rule? F)
  _ -> false)

(declare tactic [--> [valid --> valid]]))

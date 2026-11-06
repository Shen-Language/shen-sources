(load "extensions/expand-dynamic.shen")

(define expand-dynamic-tests.identity X -> X)
(define expand-dynamic-tests.four X Y Z -> X)

(define expand-dynamic-tests.literal
  [] -> []
  [X | Xs] -> [cons (expand-dynamic-tests.literal X) (expand-dynamic-tests.literal Xs)]
  X -> [protect X] where (and (symbol? X) (variable? X))
  X -> X)

(define expand-dynamic-tests.expand
  F Type -> (shen.x.expand-dynamic.expand-declare/checked
              [declare F (expand-dynamic-tests.literal Type)]))

(define expand-dynamic-tests.signature
  F -> (tl (assoc F (value shen.*sigf*))))

(define expand-dynamic-tests.invoke
  Signature Type -> (Signature Type (shen.prolog-vector)
                               (@v true (@v 0 (vector 0))) 0 (freeze success)))

(let Expanded (expand-dynamic-tests.expand expand-dynamic-tests.identity
                [(protect A) --> (protect A)])
  (do
    (extension-tests.assert-equal "expanded signature contains no eval-kl"
      (occurrences eval-kl Expanded) 0)
    (extension-tests.assert-equal "expanded declare preserves its return value"
      (eval-kl Expanded) expand-dynamic-tests.identity)))

(let Signature (expand-dynamic-tests.signature expand-dynamic-tests.identity)
  (do
    (extension-tests.assert-equal "shared type variables unify consistently"
      (expand-dynamic-tests.invoke Signature [number --> number]) success)
    (extension-tests.assert-equal "shared type variables reject distinct types"
      (expand-dynamic-tests.invoke Signature [number --> symbol]) false)
    (extension-tests.assert-equal "signature calls get fresh type variables"
      (expand-dynamic-tests.invoke Signature [symbol --> symbol]) success)))

(eval-kl (expand-dynamic-tests.expand expand-dynamic-tests.four
           [(protect A) --> [(protect B) --> [(protect C) --> (protect D)]]]))
(extension-tests.assert-equal "portable expansion handles more than three variables"
  (expand-dynamic-tests.invoke
    (expand-dynamic-tests.signature expand-dynamic-tests.four)
    [number --> [symbol --> [string --> boolean]]]) success)

(set expand-dynamic-tests.*signature* [number --> number])
(set expand-dynamic-tests.*effects* 0)
(let Original [declare expand-dynamic-tests.identity
                [do [set expand-dynamic-tests.*effects*
                         [+ 1 [value expand-dynamic-tests.*effects*]]]
                    [value expand-dynamic-tests.*signature*]]]
     Expanded (shen.x.expand-dynamic.expand-declare/checked Original)
  (do
    (extension-tests.assert-equal "computed signatures keep ordinary declare" Expanded Original)
    (extension-tests.assert-equal "expansion does not execute signature effects"
      (value expand-dynamic-tests.*effects*) 0)
    (set expand-dynamic-tests.*signature* [symbol --> symbol])
    (eval-kl Expanded)
    (extension-tests.assert-equal "computed signature is evaluated once at runtime"
      (value expand-dynamic-tests.*effects*) 1)
    (extension-tests.assert-equal "computed declaration uses the current signature"
      (expand-dynamic-tests.invoke
        (expand-dynamic-tests.signature expand-dynamic-tests.identity)
        [symbol --> symbol]) success)))

(define expand-dynamic-tests.capture
  F -> (let File "tests/extensions/expand-dynamic/warnings.tmp"
            Saved (value *stoutput*)
            Out (open File out)
            _ (set *stoutput* Out)
            Result (trap-error (thaw F)
                     (/. E (do (set *stoutput* Saved) (close Out)
                               (simple-error (error-to-string E)))))
            _ (set *stoutput* Saved)
            _ (close Out)
         (read-file-as-string File)))

(expand-dynamic-tests.capture
  (freeze (declare expand-dynamic-tests.identity [number --> number])))
(let Ordinary (expand-dynamic-tests.capture
                (freeze (declare expand-dynamic-tests.identity [symbol --> symbol])))
     Reset (expand-dynamic-tests.capture
             (freeze (declare expand-dynamic-tests.identity [number --> number])))
     Expanded (expand-dynamic-tests.expand expand-dynamic-tests.identity [symbol --> symbol])
     Checked (expand-dynamic-tests.capture (freeze (eval-kl Expanded)))
     ResetAgain (expand-dynamic-tests.capture
                  (freeze (declare expand-dynamic-tests.identity [number --> number])))
     Factory (expand-dynamic-tests.capture
               (freeze (shen.declare-with-signature expand-dynamic-tests.identity
                          [symbol --> symbol]
                          (freeze (do (output "factory~%")
                                      (eval-kl (shen.prolog-abstraction [symbol --> symbol])))))))
  (do
    (extension-tests.assert-equal "ordinary declaration performs a variancy check"
      (not (= Ordinary "")) true)
    (extension-tests.assert-equal "expanded declaration preserves variancy warnings"
      Checked Ordinary)
    (extension-tests.assert-equal "validation runs before the signature factory"
      Factory (cn Ordinary "factoryc#10;"))))

(expand-dynamic-tests.capture
  (freeze (declare expand-dynamic-tests.identity [number --> number])))
(extension-tests.assert-error "signature factory failures remain catchable"
  (freeze (shen.declare-with-signature expand-dynamic-tests.identity
             [symbol --> symbol] (freeze (simple-error "signature factory failure")))))
(extension-tests.assert-equal "failed factories preserve the old signature"
  (expand-dynamic-tests.invoke
    (expand-dynamic-tests.signature expand-dynamic-tests.identity)
    [number --> number]) success)

(set expand-dynamic-tests.*names* 0)
(let Name [do [set expand-dynamic-tests.*names* [+ 1 [value expand-dynamic-tests.*names*]]]
              expand-dynamic-tests.identity]
     Expanded (expand-dynamic-tests.expand Name [number --> number])
  (do
    (extension-tests.assert-equal "expansion does not evaluate the declared name"
      (value expand-dynamic-tests.*names*) 0)
    (extension-tests.assert-equal "computed names retain declaration return values"
      (eval-kl Expanded) expand-dynamic-tests.identity)
    (extension-tests.assert-equal "computed names are evaluated once"
      (value expand-dynamic-tests.*names*) 1)))

(delete-file "tests/extensions/expand-dynamic/warnings.tmp")

\\ Source-form hooks are kernel APIs; no namespace extension is needed here.

(set source-tests.*initial-handlers* (value shen.*source-form-handlers*))

(define source-tests.sequence
  [_ | Forms] -> Forms)

(define source-tests.callable
  F -> (fn F))

(define source-tests.message
  Thunk -> (trap-error (do (thaw Thunk) no-error) (/. E (error-to-string E))))

(extension-tests.assert-equal "hooks do not belong to the system-function external list"
  (map (/. F (element? F (external shen)))
    [shen.register-source-form shen.unregister-source-form])
  [false false])
(extension-tests.assert-equal "qualified hooks are preserved by normal package processing"
  (read-from-string "(package source-tests.naming [] shen.register-source-form shen.unregister-source-form)")
  [shen.register-source-form shen.unregister-source-form])

(extension-tests.assert-equal "registration hook has callable arity metadata"
  (arity shen.register-source-form) 2)
(extension-tests.assert-equal "registration hook has a type"
  (not (= [] (assoc shen.register-source-form (value shen.*sigf*)))) true)
(extension-tests.assert-equal "removal hook has a type"
  (not (= [] (assoc shen.unregister-source-form (value shen.*sigf*)))) true)

((source-tests.callable shen.register-source-form)
  source-tests.sequence (fn source-tests.sequence))

(extension-tests.assert-equal "source sequence preserves order"
  (read-from-string "(source-tests.sequence (+ 1 2) (- 8 3))")
  [[+ 1 2] [- 8 3]])

(extension-tests.assert-equal "empty expansion is allowed"
  (read-from-string "(source-tests.sequence)") [])

(extension-tests.assert-equal "raw reader does not expand source forms"
  (read-from-string-unprocessed "(source-tests.sequence (+ 1 2))")
  [[source-tests.sequence [+ 1 2]]])

(extension-tests.assert-equal "file reading uses the hook"
  (read-file "tests/extensions/source-forms/fixtures/input.shen") [[+ 20 22]])

(let Stream (open "tests/extensions/source-forms/fixtures/input.shen" in)
     Forms (lineread Stream)
     Closed (close Stream)
  (extension-tests.assert-equal "line reading at EOF uses the hook" Forms [[+ 20 22]]))

(let Stream (open "tests/extensions/source-forms/fixtures/input.shen" in)
     Form (read Stream)
     Closed (close Stream)
  (extension-tests.assert-equal "single-form reading uses the hook" Form [+ 20 22]))

(extension-tests.assert-equal "arity discovery sees all expanded definitions"
  (read-from-string "(source-tests.sequence (define source-tests.caller X -> (source-tests.later X 2)) (define source-tests.later X Y -> (+ X Y)))")
  [[define source-tests.caller X -> [source-tests.later X 2]]
   [define source-tests.later X Y -> [+ X Y]]])

(shen.register-source-form source-tests.package
  (/. Form [[package source-tests.owner [] [define f X -> X]]]))
(extension-tests.assert-equal "handler results may contain packages"
  (read-from-string "(source-tests.package)") [[define source-tests.owner.f X -> X]])

(shen.register-source-form source-tests.failure (/. Form (simple-error "source handler failed")))
(extension-tests.assert-equal "handler error propagates from string reader"
  (source-tests.message (freeze (read-from-string "(source-tests.failure)")))
  "source handler failed")
(extension-tests.assert-equal "handler error propagates from file reader"
  (source-tests.message (freeze (read-file "tests/extensions/source-forms/fixtures/error.shen")))
  "source handler failed")
(let Stream (open "tests/extensions/source-forms/fixtures/error.shen" in)
     Message (source-tests.message (freeze (lineread Stream)))
     Closed (close Stream)
  (extension-tests.assert-equal "handler error is not incomplete interactive input"
    Message "source handler failed"))

(set source-tests.*empty-calls* 0)
(shen.register-source-form source-tests.empty
  (/. Form (do (set source-tests.*empty-calls* (+ 1 (value source-tests.*empty-calls*))) [])))
(let Stream (open "tests/extensions/source-forms/fixtures/empty.shen" in)
     Empty (lineread Stream)
     Next (lineread Stream)
     Closed (close Stream)
  (do (extension-tests.assert-equal "empty expansion consumes exactly its own line" Empty [])
      (extension-tests.assert-equal "following line remains unread" Next [42])
      (extension-tests.assert-equal "empty handler is not retried" (value source-tests.*empty-calls*) 1)))

(shen.register-source-form source-tests.sequence (/. Form [42]))
(extension-tests.assert-equal "register replaces the existing exact head"
  (read-from-string "(source-tests.sequence)") [42])
(extension-tests.assert-equal "qualified head is not confused with an unqualified one"
  (shen.source-form-handler [sequence] (value shen.*source-form-handlers*)) [])

(shen.register-source-form source-tests.invalid (/. Form [1 | 2]))
(extension-tests.assert-error "improper handler output is rejected"
  (freeze (read-from-string "(source-tests.invalid)")))
(extension-tests.assert-error "package cannot be replaced"
  (freeze (shen.register-source-form package (fn source-tests.sequence))))
(extension-tests.assert-error "variable heads are rejected"
  (freeze (shen.register-source-form (protect X) (fn source-tests.sequence))))

(map (fn shen.unregister-source-form)
  [source-tests.sequence source-tests.package source-tests.failure source-tests.invalid source-tests.empty])
(shen.unregister-source-form source-tests.sequence)
(extension-tests.assert-equal "unregister is idempotent and restores the initial registry"
  (value shen.*source-form-handlers*) (value source-tests.*initial-handlers*))

\\ Exercise source initialisation separately from generated KLambda metadata.
(unput shen.register-source-form shen.lambda-form)
(unput shen.unregister-source-form shen.lambda-form)
(shen.build-lambda-table [])
(extension-tests.assert-equal "source initialisation installs the registration callable without externals"
  ((source-tests.callable shen.register-source-form) source-tests.sequence (fn source-tests.sequence))
  source-tests.sequence)
(extension-tests.assert-equal "source initialisation installs the removal callable without externals"
  ((source-tests.callable shen.unregister-source-form) source-tests.sequence)
  source-tests.sequence)

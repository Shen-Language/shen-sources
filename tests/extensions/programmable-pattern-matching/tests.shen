(load "tests/extensions/programmable-pattern-matching/setup.shen")
(load "tests/extensions/programmable-pattern-matching/code.shen")
(tc +)
(load "tests/extensions/programmable-pattern-matching/typed-code.shen")
(tc -)

(extension-tests.assert-equal
  "register-handler has a type"
  (shen.typecheck
    [shen.x.programmable-pattern-matching.register-handler ppm.two-handler]
    symbol)
  symbol)

(extension-tests.assert-equal
  "unregister-handler has a type"
  (shen.typecheck
    [shen.x.programmable-pattern-matching.unregister-handler ppm.two-handler]
    symbol)
  symbol)

(extension-tests.assert-equal
  "registration can be sequenced with do"
  (shen.typecheck
    [do
      [shen.x.programmable-pattern-matching.register-handler ppm.two-handler]
      ppm.two-handler]
    symbol)
  symbol)

(extension-tests.assert-equal
  "simple custom pattern"
  (ppm.match-simple (@p 1 2))
  [1 2])

(extension-tests.assert-equal
  "repeated variable success"
  (ppm.match-repeat (@p 1 1))
  same)

(extension-tests.assert-equal
  "repeated variable failure"
  (ppm.match-repeat (@p 1 2))
  different)

(extension-tests.assert-equal
  "nested custom pattern"
  (ppm.match-nested (@p (@p 1 2) 3))
  [1 2 3])

(extension-tests.assert-equal
  "typed custom pattern uses its surface form"
  (ppm.match-typed-surface (@p 1 "x"))
  true)

(extension-tests.assert-equal
  "typed custom pattern binds its component type"
  (ppm.match-typed-binding (@p 1 "x"))
  1)

(extension-tests.assert-equal
  "nested typed custom pattern"
  (ppm.match-typed-nested (@p (@p 1 "x") true))
  1)

(extension-tests.assert-equal
  "typed binary custom pattern"
  (ppm.match-typed-binary (@p 1 2))
  true)

(extension-tests.assert-equal
  "typed nullary custom pattern"
  (ppm.match-typed-nullary nothing)
  true)

(extension-tests.assert-equal
  "typed nullary custom pattern fallback"
  (ppm.match-typed-nullary something-else)
  false)

(let Invalid (hd (read-file
                   "tests/extensions/programmable-pattern-matching/typed-invalid.shen"))
  (extension-tests.assert-error
    "typed custom pattern rejects an incompatible binding type"
    (freeze (shen.typecheck Invalid (protect A)))))

(extension-tests.assert-equal
  "built-in cons pattern still works"
  (ppm.match-cons [1 2 3])
  [1 [2 3]])

(extension-tests.assert-equal
  "built-in literal list pattern still works"
  (ppm.match-literal-list [1 2])
  yes)

(extension-tests.assert-equal
  "unregister handler"
  (shen.x.programmable-pattern-matching.unregister-handler ppm.two-handler)
  ppm.two-handler)

(extension-tests.assert-equal
  "unregister nullary handler"
  (shen.x.programmable-pattern-matching.unregister-handler ppm.nothing-handler)
  ppm.nothing-handler)

(extension-tests.assert-equal
  "unregister typed handler"
  (shen.x.programmable-pattern-matching.unregister-handler ppm.first-handler)
  ppm.first-handler)

(extension-tests.assert-error
  "custom pattern definition fails after unregister"
  (freeze
    (eval [define ppm.disabled-after-unregister
            [two A B] -> ok
            _ -> no])))

(load "tests/extensions/programmable-pattern-matching/setup.shen")
(load "tests/extensions/programmable-pattern-matching/code.shen")

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

(extension-tests.assert-error
  "custom pattern definition fails after unregister"
  (freeze
    (eval [define ppm.disabled-after-unregister
            [two A B] -> ok
            _ -> no])))

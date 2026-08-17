(load "tests/extensions/harness.shen")

(extension-tests.reset)

(load "tests/extensions/features/tests.shen")
(load "tests/extensions/programmable-pattern-matching/tests.shen")

(extension-tests.finish)

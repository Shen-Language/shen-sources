(load "tests/extensions/harness.shen")

(extension-tests.reset)

(load "tests/extensions/features/tests.shen")
(load "tests/extensions/programmable-pattern-matching/tests.shen")
(load "tests/extensions/type-annotations/tests.shen")

(load "tests/extensions/source-forms/tests.shen")
(load "tests/extensions/namespaces/tests.shen")

(extension-tests.finish)

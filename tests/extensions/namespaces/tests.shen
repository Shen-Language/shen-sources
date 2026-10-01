(load "extensions/namespaces.shen")
(shen.x.namespaces.initialise)
(load "tests/extensions/namespaces/macros.shen")
(load "tests/extensions/namespaces/code.shen")

(define namespace-tests.record-vocabulary
  Name ->
    (do (set namespace-tests.*vocabulary-order*
             [Name | (value namespace-tests.*vocabulary-order*)])
        [Name]))

\\ Generated extensions need not retain their own source package metadata.
(extension-tests.assert-equal "namespace is not an extension external"
  (element? namespace (trap-error (external shen.x.namespaces) (/. E []))) false)
(extension-tests.assert-equal "unqualified namespace has no source handler"
  (shen.source-form-handler [namespace] (value shen.*source-form-handlers*)) [])
(extension-tests.assert-equal "namespace remains an ordinary package-local name"
  (read-from-string "(package namespace-tests.naming [] namespace)")
  [namespace-tests.naming.namespace])
(extension-tests.assert-equal "qualified namespace syntax survives package processing"
  (read-from-string "(package namespace-tests.naming [] shen.x.namespace)")
  [shen.x.namespace])

(extension-tests.assert-equal "record macros see qualified names even in macro-generated containers"
  (reverse (value namespace-tests.*record-names*))
  [namespace-tests.model.box namespace-tests.generated-owner.box])
(extension-tests.assert-equal "scoped assembly vocabulary preserves embedded alias resolution"
  (namespace-tests.client.compute-value 42) 42)
(extension-tests.assert-equal "use without renaming preserves full owner references"
  (namespace-tests.client.full-reference 37) 37)
(extension-tests.assert-equal "generated accessor need not exist in the owner's internal list"
  (element? namespace-tests.model.box.value (internal namespace-tests.model)) false)
(extension-tests.assert-equal "aliased symbol has the same identity as data"
  (namespace-tests.client.reference) namespace-tests.model.box.value)
(extension-tests.assert-equal "namespace externals preserve data symbols"
  (namespace-tests.model.tag) boxed)
(extension-tests.assert-equal "namespace externals permit global definitions"
  (namespace-tests-global-twice 7) 14)
(extension-tests.assert-equal "multiple files or blocks share local ownership"
  (namespace-tests.client.second 7) 7)
(extension-tests.assert-equal "division keeps its ordinary meaning"
  (namespace-tests.client.arithmetic 8) 4)
(extension-tests.assert-equal "ordinary macro can produce a namespace containing a local scope"
  (namespace-tests.generated-owner.box.value (namespace-tests.generated-owner.box.new 9)) 9)

(extension-tests.assert-equal "scoped vocabulary does not affect a same-named local function"
  (namespace-tests.client.call-local 7) 8)
(extension-tests.assert-equal "fully qualified locals remain callable within a vocabulary scope"
  (namespace-tests.client.qualified-from-scope 7) 8)
(extension-tests.assert-equal "scoped externals preserve dotted data symbols"
  (namespace-tests.client.scoped-label) local.label)
(extension-tests.assert-equal "scoped externals do not escape into sibling definitions"
  (namespace-tests.client.outside-label) namespace-tests.client.local.label)
(extension-tests.assert-equal "scoped externals take precedence over aliases"
  (namespace-tests.client.preserved-reference) model.box.value)
(extension-tests.assert-equal "scopes inherit namespace externals"
  (namespace-tests.client.inherited-external) shared)
(extension-tests.assert-equal "nested scopes extend and then restore the outer vocabulary"
  (namespace-tests.client.nested-scopes)
  [outer.token [outer.token inner.token] namespace-tests.client.inner.token])

(extension-tests.assert-equal "local names use existing package metadata"
  (element? namespace-tests.client.mov (internal namespace-tests.client)) true)
(extension-tests.assert-equal "namespace externals are recorded"
  (element? namespace-tests-global-twice (external namespace-tests.client)) true)
(extension-tests.assert-equal "scoped externals are not published as namespace externals"
  (element? mov (external namespace-tests.client)) false)
(extension-tests.assert-equal "scoped syntax does not create spurious internal names"
  (element? namespace-tests.client.asm (internal namespace-tests.client)) false)
(extension-tests.assert-equal "foreign references are not recorded as local names"
  (element? namespace-tests.client.model.box.value (internal namespace-tests.client)) false)
(extension-tests.assert-equal "normalization agrees with equivalent package source"
  (read-from-string "(shen.x.namespace namespace-tests.compare (use namespace-tests.model => model) (externals [boxed]) (define f X -> (model.box.value X)) (define tag -> boxed))")
  (read-from-string "(package namespace-tests.compare [namespace-tests.model.box.value boxed] (define f X -> (namespace-tests.model.box.value X)) (define tag -> boxed))"))
(extension-tests.assert-equal "explicit members do not require existing owner metadata"
  (read-from-string "(shen.x.namespace namespace-tests.compare (use namespace-tests.future => future) (define ref -> future.record.field))")
  [[define namespace-tests.compare.ref -> namespace-tests.future.record.field]])
(extension-tests.assert-equal "undeclared dotted prefixes remain local"
  (read-from-string "(shen.x.namespace namespace-tests.compare (define ref -> missing.value))")
  [[define namespace-tests.compare.ref -> namespace-tests.compare.missing.value]])
(extension-tests.assert-equal "prefix matches require a dot and a member"
  (read-from-string "(shen.x.namespace namespace-tests.compare (use foreign => model) (define ref -> [model modelx.value model.]))")
  [[define namespace-tests.compare.ref ->
    [cons namespace-tests.compare.model
      [cons namespace-tests.compare.modelx.value [cons namespace-tests.compare.model. []]]]]])
(extension-tests.assert-equal "the most specific use wins in either declaration order"
  (read-from-string "(shen.x.namespace namespace-tests.compare (use outer => model) (use inner => model.part) (define ref -> model.part.value))")
  (read-from-string "(shen.x.namespace namespace-tests.compare (use inner => model.part) (use outer => model) (define ref -> model.part.value))"))
(extension-tests.assert-equal "the most specific use selects the nested owner"
  (read-from-string "(shen.x.namespace namespace-tests.compare (use outer => model) (use inner => model.part) (define ref -> model.part.value))")
  [[define namespace-tests.compare.ref -> inner.value]])
(extension-tests.assert-equal "namespace externals take precedence over aliases"
  (read-from-string "(shen.x.namespace namespace-tests.compare (use foreign => model) (externals [model.value]) (define ref -> model.value))")
  [[define namespace-tests.compare.ref -> model.value]])
(extension-tests.assert-equal "scope removal preserves the surrounding expression"
  (read-from-string "(shen.x.namespace namespace-tests.compare (define ref -> (cons (with-externals [plain] plain) [plain])))")
  [[define namespace-tests.compare.ref -> [cons plain [cons namespace-tests.compare.plain []]]]])
(extension-tests.assert-equal "a scope keyword in argument position is ordinary data"
  (read-from-string "(shen.x.namespace namespace-tests.compare (define ref -> (f with-externals [] x)))")
  (read-from-string "(package namespace-tests.compare [] (define ref -> (f with-externals [] x)))"))
(extension-tests.assert-equal "an empty scope leaves qualification unchanged"
  (read-from-string "(shen.x.namespace namespace-tests.compare (define ref -> (with-externals [] item)))")
  [[define namespace-tests.compare.ref -> namespace-tests.compare.item]])
(extension-tests.assert-equal "literal cons notation is accepted for externals"
  (read-from-string "(shen.x.namespace namespace-tests.compare (externals (cons plain ())) (define ref -> plain))")
  [[define namespace-tests.compare.ref -> plain]])

(extension-tests.assert-equal "external expressions compose shared vocabularies like package"
  (read-from-string "(shen.x.namespace namespace-tests.compare (externals (append (namespace-tests.vocabulary) [extra])) (define names -> [plain shared extra local]))")
  (read-from-string "(package namespace-tests.compare (append (namespace-tests.vocabulary) [extra]) (define names -> [plain shared extra local]))"))
(extension-tests.assert-equal "scoped expressions compose vocabulary without escaping"
  (read-from-string "(shen.x.namespace namespace-tests.compare (define names -> (cons (with-externals (append (namespace-tests.vocabulary) [extra]) extra) [extra])))")
  [[define namespace-tests.compare.names -> [cons extra [cons namespace-tests.compare.extra []]]]])
(extension-tests.assert-equal "existing package metadata can supply external symbols"
  (read-from-string "(shen.x.namespace namespace-tests.compare (externals (external namespace-tests.model)) (define tag -> boxed))")
  [[define namespace-tests.compare.tag -> boxed]])
(extension-tests.assert-equal "external expressions run before use aliases rewrite their names"
  (read-from-string "(shen.x.namespace namespace-tests.compare (use missing => namespace-tests) (externals (namespace-tests.vocabulary)) (define item -> plain))")
  [[define namespace-tests.compare.item -> plain]])
(extension-tests.assert-equal "scoped expressions run before use aliases rewrite their names"
  (read-from-string "(shen.x.namespace namespace-tests.compare (use missing => namespace-tests) (define item -> (with-externals (namespace-tests.vocabulary) shared)))")
  [[define namespace-tests.compare.item -> shared]])

(set namespace-tests.*vocabulary-order* [])
(extension-tests.assert-equal "evaluated scopes inherit their enclosing vocabularies"
  (read-from-string "(shen.x.namespace namespace-tests.evaluation (externals (namespace-tests.record-vocabulary first)) (externals (namespace-tests.record-vocabulary second)) (define item -> (with-externals (namespace-tests.record-vocabulary outer) (with-externals (namespace-tests.record-vocabulary inner) [first second outer inner]))))")
  [[define namespace-tests.evaluation.item ->
    [cons first [cons second [cons outer [cons inner []]]]]]])
(extension-tests.assert-equal "vocabulary expressions evaluate once in source order"
  (reverse (value namespace-tests.*vocabulary-order*)) [first second outer inner])
(extension-tests.assert-equal "evaluated namespace vocabulary is recorded"
  (element? first (external namespace-tests.evaluation)) true)
(extension-tests.assert-equal "evaluated scoped vocabulary stays out of namespace metadata"
  (element? outer (external namespace-tests.evaluation)) false)

(extension-tests.assert-error "external expressions must produce lists"
  (freeze (read-from-string "(shen.x.namespace a (externals (hd [42])))")))
(extension-tests.assert-error "external expressions must produce proper lists"
  (freeze (read-from-string "(shen.x.namespace a (externals (cons plain tail)))")))
(extension-tests.assert-error "external expressions must produce symbols"
  (freeze (read-from-string "(shen.x.namespace a (externals (append [plain] [42])))")))
(extension-tests.assert-error "computed variables cannot be external symbols"
  (freeze (read-from-string "(shen.x.namespace a (externals [(intern c#34;Variablec#34;)]))")))
(extension-tests.assert-error "scoped expressions must produce symbol lists"
  (freeze (read-from-string "(shen.x.namespace a (with-externals (append [plain] [42]) plain))")))
(extension-tests.assert-equal "external expression errors propagate unchanged"
  (trap-error (read-from-string "(shen.x.namespace a (externals (simple-error c#34;vocabulary failedc#34;)))")
              (/. E (error-to-string E)))
  "vocabulary failed")
(extension-tests.assert-equal "scoped expression errors propagate unchanged"
  (trap-error (read-from-string "(shen.x.namespace a (with-externals (simple-error c#34;vocabulary failedc#34;) plain))")
              (/. E (error-to-string E)))
  "vocabulary failed")

(extension-tests.assert-error "duplicate aliases are rejected"
  (freeze (read-from-string "(shen.x.namespace a (use b => x) (use c => x))")))
(extension-tests.assert-error "unrenamed and renamed uses cannot claim the same prefix"
  (freeze (read-from-string "(shen.x.namespace a (use b) (use c => b))")))
(extension-tests.assert-error "owners must be non-variable symbols"
  (freeze (read-from-string "(shen.x.namespace a (use Owner))")))
(extension-tests.assert-error "aliases must be non-variable symbols"
  (freeze (read-from-string "(shen.x.namespace a (use b => Alias))")))
(extension-tests.assert-error "malformed use headers are rejected"
  (freeze (read-from-string "(shen.x.namespace a (use b x))")))
(extension-tests.assert-error "directives must precede the body"
  (freeze (read-from-string "(shen.x.namespace a (define f -> 1) (use b))")))
(extension-tests.assert-error "externals must precede the body"
  (freeze (read-from-string "(shen.x.namespace a (define f -> 1) (externals [plain]))")))
(extension-tests.assert-error "variables cannot be external symbols"
  (freeze (read-from-string "(shen.x.namespace a (externals [X]))")))
(extension-tests.assert-error "variables cannot be scoped external symbols"
  (freeze (read-from-string "(shen.x.namespace a (with-externals [X] X))")))
(extension-tests.assert-error "with-externals requires an enclosed form"
  (freeze (read-from-string "(shen.x.namespace a (with-externals [foo]))")))
(extension-tests.assert-error "with-externals accepts exactly one enclosed form"
  (freeze (read-from-string "(shen.x.namespace a (with-externals [foo] foo bar))")))

(shen.unregister-source-form shen.x.namespace)

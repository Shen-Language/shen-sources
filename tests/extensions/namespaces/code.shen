(shen.x.namespace namespace-tests.model
  (externals [boxed])
  (with-externals [defrecord] (defrecord box))
  (define make X -> (box.new X))
  (define tag -> boxed))

(shen.x.namespace namespace-tests.client
  (use namespace-tests.model)
  (use namespace-tests.model => model)
  (externals (append (namespace-tests.vocabulary) [namespace-tests-global-twice]))

  (define compute-value X ->
    (with-externals (append [asm mov] [return])
      (asm (mov R (model.box.value (model.make X))) (return R))))
  (define full-reference X ->
    (namespace-tests.model.box.value (namespace-tests.model.make X)))
  (define reference -> model.box.value)
  (define local.field X -> X)
  (define arithmetic X -> (/ X 2))
  (define namespace-tests-global-twice X -> (+ X X))

  (define mov X -> (+ X 1))
  (define call-local X -> (mov X))
  (define qualified-from-scope X ->
    (with-externals [asm mov return]
      (asm (mov R (namespace-tests.client.mov X)) (return R))))
  (define scoped-label -> (with-externals [local.label] local.label))
  (define outside-label -> local.label)
  (define preserved-reference -> (with-externals [model.box.value] model.box.value))
  (define inherited-external -> (with-externals [local.label] shared))
  (define nested-scopes ->
    (with-externals [outer.token]
      (cons outer.token
        (cons (with-externals [inner.token] [outer.token inner.token])
              [inner.token])))))

(shen.x.namespace namespace-tests.client
  (define second X -> (local.field X)))

(namespace-tests.generated)

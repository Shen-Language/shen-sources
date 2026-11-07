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

\\ Exports, imports and shadowing.
(shen.x.namespace namespace-tests.shape
  (export make area side => width tag)
  (define make S -> [tag S])
  (define side [tag S] -> S)
  (define area Shape -> (* (side Shape) (side Shape)))
  (define hidden -> secret))

(shen.x.namespace namespace-tests.facade
  (use namespace-tests.shape => s)
  (export s.make => square s.area => area))

(shen.x.namespace namespace-tests.user
  (use namespace-tests.shape => s)
  (use namespace-tests.facade => f)
  (import namespace-tests.shape make area => size)
  (shadow length)
  (define length Shape -> (s.width Shape))
  (define sized X -> (size (make X)))
  (define via-facade X -> (f.area (f.square X)))
  (define measure X -> (length (s.make X)))
  (define tag-of -> s.tag))

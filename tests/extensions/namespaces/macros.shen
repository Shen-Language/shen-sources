\\ Deliberately small consumers of qualification-before-expansion.
(set namespace-tests.*record-names* [])

(define namespace-tests.vocabulary -> [plain shared])

(package namespace-tests [defrecord asm mov return]

(defmacro record
  [defrecord Name] ->
    (do (set namespace-tests.*record-names*
             [Name | (value namespace-tests.*record-names*)])
      [package null [] [define (intern (@s (str Name) ".new")) (protect X) -> [cons (protect X) []]]
        [define (intern (@s (str Name) ".value")) (protect R) -> [hd (protect R)]]]))

(defmacro assembly
  [asm [mov Name Value] [return Name]] -> [let Name Value Name])

)

(defmacro namespace-tests.generated
  [namespace-tests.generated] ->
    [shen.x.namespace namespace-tests.generated-owner
      [with-externals [cons defrecord []] [defrecord box]]])

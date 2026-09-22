(load "extensions/type-annotations.shen")

(tc +)
(load "tests/extensions/type-annotations/code.shen")
(tc -)

(define type-annotations-tests.compound-annotation?
  [defun type-annotations-tests.list-head [X]
    [cond
      [[cons? [type X [list A]]] _]
      [_ _]]]
  -> (variable? A)
  _ -> false)

(extension-tests.assert-equal
  "concrete parameter types are added"
  (shen.x.type-annotations.annotate-kl
    [defun type-annotations-tests.string= [x y] [= x y]])
  [defun type-annotations-tests.string=
    [x y]
    [= [type x string] [type y string]]])

(extension-tests.assert-equal
  "polymorphic parameters remain unannotated"
  (shen.x.type-annotations.annotate-kl
    [defun type-annotations-tests.identity [x] x])
  [defun type-annotations-tests.identity [x] x])

(extension-tests.assert-equal
  "known applications annotate literals"
  (shen.x.type-annotations.annotate-kl [+ 1 2])
  [+ [type 1 number] [type 2 number]])

(extension-tests.assert-equal
  "unknown signatures are left alone"
  (shen.x.type-annotations.annotate-kl
    [defun type-annotations-tests.unknown [x] [unknown x]])
  [defun type-annotations-tests.unknown [x] [unknown x]])

(let Once (shen.x.type-annotations.annotate-kl
            [defun type-annotations-tests.string= [x y] [= x y]])
  (extension-tests.assert-equal
    "existing annotations are preserved"
    (shen.x.type-annotations.annotate-kl Once)
    Once))

(extension-tests.assert-equal
  "compound polymorphic types use Shen variables"
  (type-annotations-tests.compound-annotation?
    (shen.x.type-annotations.annotate-kl
      (ps type-annotations-tests.list-head)))
  true)

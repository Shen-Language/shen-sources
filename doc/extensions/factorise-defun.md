# factorise-defun

This extension implements a transformation for functions that
do pattern matching, that can in some cases (like when the
patterns go deep into structures, or when the function has
too many similar patterns) lead to big performance improvements.

The transformation is not a complete one, the port has to take
care of the final step and convert the new constructs generated
by the transformation into code that performs well when
executed by the underlying platform.

Not all platforms may be able to express that code in
a way that makes the transformed code more efficient than
the original one. In such cases, this transformation should
not be used.

## The problem

The way Shen compiles pattern matching code to Klambda can result
in too many repeated tests and selectors, which is suboptimal.
Since there isn't a reliable way for Shen to solve this portably,
the task is deferred to the port.

The first step is to process the `cond` construct at the root
of the function definition, and rebuild it as an if-else
tree, with all the duplicated tests merged into one.
But this results in code duplication, because this restructuring
of the code forces the bodies of the false branches to be
duplicated.

The solution to this is to remove the duplication by binding
a continuation using this code, and to generate a jump to this
continuation in the false branches. This requires that the underlying
platform supports this efficiently through direct jumps, like for
example with GOTO, of zero-overhead tail-calls.

The other part of the optimization involves finding duplicate
instances of selectors, binding the result of the selector
to a variable on the outer scope, and replacing all instances
of such selector with a reference to this variable.

## How to use

The transformation is performed by calling the `shen.x.factorise-cond.factorise-defun`
passing it a `defun` expression.

The return value will be the transformed `defun`, on which these two new special
forms will show up:

`(%%let-label [LabelName | LabelVars] LabelBody CodeBody)` declares a label.

- `CodeBody` is code on which jumps to the label being declared will show up.
- `LabelBody` is the body of the code that has to be executed when a jump to this label happens.
- `LabelName` is the namame of the label, and will be referenced inside `CodeBody` by instances of the `%%goto-label` form.
- `LabelVars` is a list of free variables inside `LabelBody`. Added as a convenience for platforms on which this is useful (one without GOTO, but with very efficient tail-calls).

and

`(%%goto-label LabelName LabelVars)` represents a jump to a previously declared label.

- `LabelName` is the name of a label bound by `%%let-label`
- `LabelVars` is the list of variables that are passed to that label. On platforms with support for GOTO this can be ignored, but is useful on platforms where GOTO's are represented by tail-calls.

`(%%return Expression)` marks a place where the function should return. If the natural flow of code would stop naturally at that point for the underlying platform (normal in expression-oriented languages like Scheme for example), it can be replaced by `Expression`. Other platforms will probably want to insert a return there, `(return Expression)` in Common Lisp, or a `return Result;` in languages like C and Javascript (with `Result` being a variable containing the result of evaluating `Expression`).

The port has to convert these constructs to something suitable for the underlying platform.

### Optimization of custom selectors

If the `programmable-pattern-matching` extension is used to add new patterns that generate selectors different from the ones used by core datatypes, it is possible to extend the factoriser to make it handle those new selectors by registering a selector handling function by passing its name to the `shen.x.factorise-defun.register-selector-handler` function.

A selector handling function needs to match an expression that recognizes the value on which the selectors work, and return a list containing expressions for all the relevant selectors.

```shen
(define mycons-selector-handler
  [mycons? X] -> [[myhd X] [mytl X]]
  _ -> (fail))

(shen.x.factorise-defun.register-selector-handler mycons-selector-handler)
```

Handlers can be removed with the `shen.x.factorise-defun.deregister-selector-handler` function:

```shen
(shen.x.factorise-defun.deregister-selector-handler mycons-selector-handler)
```

## Example

The following function:

```shen
(define example
  [1 X | Xs] 1 -> X
  [1 X | Xs] 2 -> Xs
  [2 X | Xs] _ -> X)
```

When compiled to klambda will look like this (**tip:** In Shen/CL you can pretty-print code with `lisp.pprint`):

```shen
\\ Output of `(lisp.pprint (ps example))`
(defun example (V1345 V1346)
 (cond
  ((and (cons? V1345)
        (and (= 1 (hd V1345)) (and (cons? (tl V1345)) (= 1 V1346))))
   (hd (tl V1345)))
  ((and (cons? V1345)
        (and (= 1 (hd V1345)) (and (cons? (tl V1345)) (= 2 V1346))))
   (tl (tl V1345)))
  ((and (cons? V1345) (and (= 2 (hd V1345)) (cons? (tl V1345))))
   (hd (tl V1345)))
  (true (shen.f_error example))))
```

After being factorised with `(shen.x.factorise-defun.factorise-defun (ps example))` it looks like:

```shen
\\ Output of `(lisp.pprint (shen.x.factorise-defun.factorise-defun (ps example)))`
(defun example (V1345 V1346)
 (%%let-label (%%label1347) (%%return (shen.f_error example))
  (if (cons? V1345)
      (let V1345/hd (hd V1345)
        (let V1345/tl (tl V1345)
          (%%let-label (%%label1348 V1345/hd V1345/tl)
           (if (and (= 2 V1345/hd) (cons? V1345/tl))
               (%%return (hd V1345/tl))
               (%%goto-label %%label1347))
           (if (and (= 1 V1345/hd) (cons? V1345/tl))
               (if (= 1 V1346)
                   (%%return (hd V1345/tl))
                   (if (= 2 V1346)
                       (%%return (tl V1345/tl))
                       (%%goto-label %%label1348 V1345/hd V1345/tl)))
               (%%goto-label %%label1348 V1345/hd V1345/tl)))))
      (%%goto-label %%label1347))))
```

The above code, when compiled by Shen/Scheme (which uses tail-calls as a GOTO) results in:

```scheme
;; Output of (scm.pretty-print (_scm.kl->scheme (ps example)))
(define (kl:example V1345 V1346)
  (define (%%label1347) (kl:shen.f_error 'example))
  (define (%%label1348 V1345/hd V1345/tl)
    (if (and (kl:= 2 V1345/hd) (pair? V1345/tl))
        (car V1345/tl)
        (%%label1347)))
  (if (pair? V1345)
      (let* ([V1345/hd (car V1345)]
             [V1345/tl (cdr V1345)])
        (if (and (kl:= 1 V1345/hd) (pair? V1345/tl))
            (if (kl:= 1 V1346)
                (car V1345/tl)
                (if (kl:= 2 V1346)
                    (cdr V1345/tl)
                    (%%label1348 V1345/hd V1345/tl)))
            (%%label1348 V1345/hd V1345/tl)))
      (%%label1347)))
```

Shen/Scheme does a bit of extra work and hoists the labels into `define`s
at the root of the function to reduce nesting and increase readability of
the resulting code, but the following, simpler transformation would
also work:

```scheme
(define (kl:example V1345 V1346)
  (let ((%%label1347 (lambda () (kl:shen.f_error 'example))))
    (if (pair? V1345)
        (if (pair? V1345)
      (let* ([V1345/hd (car V1345)]
             [V1345/tl (cdr V1345)])
        (let ((%%label1348 (lambda (V1345/hd V1345/tl)
                             (if (and (kl:= 2 V1345/hd) (pair? V1345/tl))
                                 (car V1345/tl)
                                 (%%label1347)))))
          (if (and (kl:= 1 V1345/hd) (pair? V1345/tl))
              (if (kl:= 1 V1346)
                  (car V1345/tl)
                  (if (kl:= 2 V1346)
                      (cdr V1345/tl)
                      (%%label1348 V1345/hd V1345/tl)))
              (%%label1348 V1345/hd V1345/tl))))
      (%%label1347)))))
```

The conversion here is very simple. The tree is walked and:

```shen
(%%let-label (<label> ...<args>) <label-body> <body>)
```

gets translated to:

```scheme
(let ((<label> (lambda (...<args>)
                 <label-body>))
  <body>))
```

and `(%%goto-label <label> ...<args>)` to `(<label> ...<args>)`.

In Common Lisp the job is easier, because it provides a GOTO-like construct.
`(%%return <exp>)` translates directly to `(return <exp>)`,
`(%%goto-label <label> ...<args>)` to `(go <label>)`,
and `(%%let-label (<label> ...<args>) <label-body> <body>)` to
`(tagbody <body> <label> <label-body>)`.
Then the whole function body is wrapped in `(block nil ...)` so that `(return ...)` expressions work.

```lisp
(DEFUN example (V1345 V1346)
  (BLOCK NIL
    (TAGBODY
      (IF (CONSP V1345)
          (LET ((V1345/hd (CAR V1345)))
            (LET ((V1345/tl (CDR V1345)))
              (TAGBODY
                (IF (AND (EQL V1345/hd 1) (CONSP V1345/tl))
                    (IF (EQL V1346 1)
                        (RETURN (CAR V1345/tl))
                        (IF (EQL V1346 2)
                            (RETURN (CDR V1345/tl))
                            (GO %%label1348)))
                    (GO %%label1348))
               %%label1348
                (IF (AND (EQL V1345/hd 2) (CONSP V1345/tl))
                    (RETURN (CAR V1345/tl))
                    (GO %%label1347)))))
          (GO %%label1347))
     %%label1347
      (RETURN (shen.f_error 'example)))))
```

## Possibly useful properties of the generated code

- For a given `LabelName`, `%%goto-label` forms that reference it will always show up inside the `CodeBody` of a `%%let-label` that declares `LabelName`, never before, and never inside `LabelBody`.
- Labels are only declared if there are at least two or more instances of `%%goto-label` referencing that label.
- The order of `LabelVars` in a `%%let-label` declaration and a `%%goto-label` with matching label names always matches.

# Type annotations

This extension restores the KLambda type-annotation transformation that was
provided by older Shen kernels.  It is an explicit, non-evaluating
transformation: it neither changes the supplied value nor replaces the
recorded definition.

## How to use

Load `extensions/type-annotations.shen`, then pass KLambda to
`shen.x.type-annotations.annotate-kl`:

```shen
(tc +)

(define string=
  {string --> string --> boolean}
  X X -> true
  _ _ -> false)

(shen.x.type-annotations.annotate-kl (ps string=))
```

When given a `defun`, the transformation obtains its declared type from the
current type-signature table, associates concrete argument types with the
function parameters, and annotates its body.  Signatures of functions called
by the body are used in the same way.  Polymorphic argument types are left
unannotated unless their use establishes a concrete or compound type.

The function can also transform an individual KLambda expression.  In that
case there is no enclosing function signature, but literals and applications
of functions with known signatures can still be annotated.

Missing signatures are not errors.  Existing `type` forms are preserved, so
applying `annotate-kl` repeatedly produces the same result.

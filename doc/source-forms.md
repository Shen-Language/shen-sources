# Source-form expanders

Source-form handlers expand top-level containers before macros process their
bodies. They can resolve names or produce a sequence of declarations.

Register a handler before reading files that use it:

```shen
(define expand-group
  [_ | Forms] -> Forms)

(shen.register-source-form group (fn expand-group))
```

A consumer file can then contain:

```shen
(group
  (define first X -> (second X 1))
  (define second X Y -> (+ X Y)))
```

`load` reads a whole file before evaluating it, so registration must happen in
an earlier setup step.

## API

- `(shen.register-source-form Head Transformer)` registers a one-argument
  function under the exact symbol `Head`, replacing any previous handler.
  `Head` must be a non-variable symbol other than `package`.
- `(shen.unregister-source-form Head)` removes its handler, if present.
  Both functions return `Head`; registrations apply across subsequent reads.

The transformer receives the original form and returns a proper list of
replacement forms, processed recursively in order. Return `[]` to omit the
input. Handler errors propagate; improper result lists are rejected.

## Expansion

Handlers run before macros traverse their containers. Ordinary macros can
also produce containers for the reader to expand. Arity and type discovery
follow expansion of the complete source sequence.

Containers belong at source level. A surrounding `package` still qualifies
its contents, so it must preserve names intended for the handler.

`read-file`, `read-from-string`, `read`, and `lineread` use this processing.
`read` returns the first expanded form and requires at least one.
`read-from-string-unprocessed` bypasses expansion. `macroexpand` preserves
containers without invoking their handlers; `eval` does not expand them.

See the [namespace extension](extensions/namespaces.md) for an implementation
and the [port upgrade guide](port-upgrades.md) for integration requirements.

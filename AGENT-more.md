# Shen Agent Guide: Advanced Notes

This is a companion to `AGENT.md`.

The main guide should stay focused on everyday Shen coding. This file is for
implementation-oriented details that matter when reasoning about the reader,
compiler, bootstrap, and precompiled modules.

## 1. Front-end pipeline reality

`read-file` is not a raw parser. It already performs several compilation-facing
steps before returning forms:

1. parse bytes into S-expressions
2. process `package`
3. macroexpand top-level forms
4. discover arities
5. discover inline type signatures
6. normalize applications and currying

Important consequence:

- tools built on `read-file` do not see original source structure
- if you need pre-macroexpansion information, `read-file` is already too late

## 2. `package` is reader-time, not eval-time

`package` is handled in the reader pipeline, where symbols are rewritten and
package tables are recorded.

Important consequence:

- `eval` does not provide full source-loading behavior for packaged code
- replaying raw top-level forms through `eval` is not enough to simulate a file
  load if `package` matters

## 3. Normal source loading pre-registers functions

When source is read, Shen does a pre-pass over `define` forms and records:

- `arity`
- `lambda-form`

This happens before later evaluation of the file.

Important consequence:

- a compiled artifact that only emits function bodies is not equivalent to
  loading the original Shen file
- later compilation, `fn`, and partial application can depend on this metadata

## 4. Current bootstrap is intentionally lossy

`bootstrap` writes KLambda from the output of `read-file`, not from raw source.

That means source-level constructs that were consumed earlier are not preserved
as such in the output.

The important ones are:

- `package`
- `defmacro`
- `datatype`
- `synonyms`
- inline `define { ... }` signatures

This is fine for the kernel boot path in `sources/`, but it matters if you want
precompiled artifacts that behave like source loads.

## 5. Explicit `declare` and inline signatures are not operationally identical

Explicit top-level `declare` updates the type environment directly.

Inline `define { ... }` signatures are different:

- they are available to the typed loading path
- they are not automatically equivalent to an unconditional `declare`

Important consequence:

- when preserving type metadata in compiled artifacts, decide explicitly whether
  you want strict load equivalence or stronger metadata preservation

## 6. Macro-time side effects matter

Some Shen constructs are not just syntax sugar; they mutate compiler/runtime
state during loading.

Key examples:

- `defmacro` updates `*macros*`
- `datatype` updates datatype registries and creates predicates
- `synonyms` updates type demodulation state

Important consequence:

- preserving only executable function code is insufficient for source-equivalent
  precompilation

## 7. Source-equivalent precompiled modules need initialization

If the goal is "replace a `.shen` file with a pure KL artifact", the artifact
needs more than compiled function code.

In practice it needs an initializer that restores at least:

- package `external-symbols`
- package `internal-symbols`
- arity metadata
- lambda-form metadata
- `source` metadata for `ps`
- `*userdefs*`
- type-related metadata
- macro-related metadata
- datatype-related metadata

Good mental model:

- source loading = code + environment mutation
- code-only bootstrap is not enough for module equivalence

## 8. Best preservation boundary

If you want to preserve metadata for richer compilation, the most useful
intermediate form is:

- after package processing
- before macroexpansion

Why:

- before package processing is too raw
- after macroexpansion is too late for `defmacro`, `datatype`, and `synonyms`

## 9. Datatypes are the awkward case

Macros are comparatively straightforward to preserve ahead of time.

Datatypes are harder because their compilation:

- expands into generated logic code
- creates runtime definitions through nested evaluation
- updates datatype registries

Important consequence:

- a first implementation of richer compilation may reasonably replay datatype
  declarations during module initialization rather than fully compiling them
  ahead of time

## 10. Existing `.kl` artifacts show the preservation problem

Current repo output like `klambda/stlib.kl` is more advanced than the older
per-file `.kl` artifacts shipped in some Shen distributions, because it carries
explicit initialization code as well as executable definitions.

But the general lesson is the same:

- plain executable KL is not enough for source-equivalent modules
- the missing piece is restoration of the surrounding Shen environment

## 11. Top-level KL needs hoisting, not blind embedding

If you compile arbitrary top-level Shen forms to KL and then stuff the result
straight into an initializer, you can generate invalid KL.

Why:

- a compiled top-level form may come back as a top-level `do`
- that `do` may contain one or more `defun`s
- embedding that whole expression inside another `defun` creates nested
  `defun`s, which are not valid

Practical rule:

- when compiling top-level forms for module initialization, split top-level
  `do` chains, hoist any `defun`s back to the module top level, and only leave
  non-`defun` expressions in the initializer buckets

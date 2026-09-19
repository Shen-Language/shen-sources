# Port Upgrade Guide

As changes are made and new versions of the Shen kernel are released, ports
might require modifications to adapt. These adaptations may be necessary for a
port to continue working, or they may allow a port to remove old workarounds or
take advantage of new optimisation hooks.

This document runs parallel to the [changelog](../CHANGELOG.md), but is not a
second changelog. It only lists releases which require action from a port
maintainer or provide a port-specific opportunity. Unreleased changes are
listed under [Unreleased](#unreleased), as in the changelog.

## Unreleased

## 42.0

### Factorised Code

The factoriser now factors repeated selectors inside recognisers which could
not be grouped by the outer pivot. This produces more compact KLambda while
using the same `let`/`freeze`/`thaw` representation introduced in 37.0.

**Minimum Requirements**

None: there are no new primitives or integration steps. A port with a generic
KLambda implementation receives the change by replacing the kernel files.

**Optimisation Opportunities**

- Ports which recognise particular factorised-code shapes can extend those
  optimisations to the newly factorised selectors.

### Lambda-form Metadata

`update-lambda-table` now replaces callable lambda forms without duplicating
the function name and removes a stale `lambda-form` property when a function is
redefined with zero or unknown arity.

**Minimum Requirements**

- Ports which replace or cache Shen's function metadata must invalidate the
  cached callable form when a definition changes to zero or unknown arity.
  `(fn F)`, partial application, and dynamic application must observe the new
  definition.

**Optimisation Opportunities**

None.

## 41.3

### `input+` Macro

`input+` now treats its type argument as syntax and expands before evaluation.
For example:

```shen
(macroexpand [input+ number])
```

produces:

```shen
[shen.input-h+ number [stinput]]
```

The macro converts compound type syntax to its list representation and accepts
an explicit stream as a second argument. The kernel still registers `input+`
as a two-place function, so a higher-order use such as `(fn input+)` refers to
`input+` directly instead of going through the macro.

**Minimum Requirements**

- A port which replaces the Shen source reader or handles `input+` specially
  must implement the new macro expansion. It must not evaluate `Type` as an
  ordinary argument.
- A port must keep higher-order uses such as `(fn input+)` working. Ports which
  do not otherwise retain an `input+` function can provide a two-place function
  which delegates to `shen.input-h+`. Shen/Scheme required this compatibility
  definition when it upgraded to 41.3.

  ```shen
  (define input+
    Type Stream -> (shen.input-h+ Type Stream))
  ```

**Optimisation Opportunities**

None: ports consuming the released KLambda see calls to `shen.input-h+` after
macro expansion.

## 41.1

### Precompiled Standard Library

The core standard library can now be distributed as `klambda/stlib.kl`. Loading
this file defines the library functions. Calling `stlib.initialise` then
installs its package information, arities, lambda forms, macros, synonyms,
datatypes, types, and source metadata.

The library sources also moved from `stlib/` to `lib/`. The core library is in
`lib/stlib/`; optional libraries such as `lib/tk/`, `lib/concurrency/`, and
`lib/ide/` are siblings.

**Minimum Requirements**

- None for ports which distribute only the kernel.
- A port which distributes `klambda/stlib.kl` must load it after the kernel and
  call `stlib.initialise` after loading it.
- Packaging which distributes the library sources must use the new `lib/`
  layout.

**Optimisation Opportunities**

- Ports can bundle the precompiled StLib artifact instead of loading and
  compiling the individual library source files.

## 39.0

### Zero-place Functions and `fn`

`fn` is now defined for zero-place functions. For a zero-place function `F`,
`(fn F)` invokes `(F)` and returns its result. Positive arities still produce a
callable value.

**Minimum Requirements**

- Ports which override `fn`, construct function values in the host, or perform
  their own arity-directed application must implement the zero-place case.

**Optimisation Opportunities**

None.

## 37.0

### Defun Factorisation

The defun factoriser no longer extracts shared branches into separate `defun`s.
It keeps a shared fallback branch in a local zero-place continuation instead:

```shen
(let Go (freeze Else)
  (if Test
      Then
      (thaw Go)))
```

This replaces the `shen.eval-factorised-branch` representation introduced in
33.1.1.

**Minimum Requirements**

- Ports which special-cased the old factorised branch functions must accept the
  new `let`/`freeze`/`thaw` form. An override of
  `shen.eval-factorised-branch` is no longer used by generated code.

**Optimisation Opportunities**

- A compiler can implement the continuation as an ordinary closure, or lower
  it to labels and jumps when doing so preserves its lexical scope.
- An interpreter can provide fast paths for the `freeze` and `thaw` pair used
  by factorised code.

## 36.0

### Prolog Memory

Each Prolog call now allocates its own binding vector. `prolog-memory` records
the size to use for future calls instead of replacing a shared
`*prolog-vector*`.

**Minimum Requirements**

- Ports which replace Prolog storage or `prolog-memory` must preserve the new
  per-call isolation. The configured size is global; the mutable bindings are
  not.

**Optimisation Opportunities**

- Ports which replace the dynamic Prolog implementation can mirror the new
  recycling of internal function names used by `assert` and `retract` instead
  of retaining a new function for every update.

## 33.1.2

### Representation Predicates

The definitions of `pvar?`, `tuple?`, and `vector?` were reorganised so their
basic type and tag checks are easier for a backend to recognise and replace.

**Minimum Requirements**

None.

**Optimisation Opportunities**

- These predicates can be replaced with native host checks. An override must
  still agree with the kernel representations and return `false` for malformed
  or unrelated absolute vectors.

## 33.1.1

### Factorised Branch Functions

The factoriser used by this kernel calls `shen.eval-factorised-branch` whenever
it generates an internal function for a shared branch. Its default definition
evaluates the generated KLambda function.

**Minimum Requirements**

None: the default implementation works without port support.

**Optimisation Opportunities**

- Compilers can override `shen.eval-factorised-branch` to collect the generated
  branch and emit it as a local function, label, jump, or another efficient
  host construct. Shen/Scheme used this hook to embed branch functions in their
  parent definition.
- This hook applies only through 36.0. Release 37.0 replaced this generated
  representation with local `freeze`/`thaw` continuations.

### Native Call Hook Removed

The `shen.*platform-native-call-check*` hook was removed in favour of the
`foreign` form added in 33.1.

**Minimum Requirements**

- Ports which used the hook to recognise host calls must mark those calls with
  `foreign` instead.

**Optimisation Opportunities**

- The port no longer needs to run a predicate on every application while Shen
  source is processed.

## 33.1

### `foreign` Source Form

`(foreign F)` marks `F` as a host-native function. The Shen source processor
does not curry or otherwise transform that application, and removes the marker
from the generated KLambda call.

For example, a port-specific source call can be written as:

```shen
((foreign host-function) X)
```

The generated KLambda contains an ordinary call to `host-function`; `foreign`
is not a new KLambda primitive.

**Minimum Requirements**

- Port-specific Shen sources which directly call host functions should mark
  them with `foreign`.
- A port which compiles Shen source with a customised reader must preserve the
  marker's source-processing behaviour. Ports which only consume the released
  KLambda do not need to implement it.

**Optimisation Opportunities**

- Native calls no longer need naming conventions or a port-specific callback
  to keep the source processor from currying them.

## 32.0

### S-kernel Integration

This release replaced the previous kernel with the S-kernel. It is a complete
kernel upgrade rather than an incremental addition to the 22.x files.

Application processing is now performed by Shen before KLambda reaches the
backend. Partial and over-applications are expressed explicitly with lambdas
and nested applications. Pattern matching factorisation is also part of the
kernel rather than the old `factorise-defun` extension.

The reader and writer can distinguish byte streams from host character streams
through `shen.char-stinput?` and `shen.char-stoutput?`.

**Minimum Requirements**

- Replace the complete set of generated KLambda files. Do not combine S-kernel
  files with files or initialisation data from the 22.x kernel.
- Remove backend transformations which independently curry known partial or
  over-applications. Compile the application structure emitted in KLambda;
  applying an additional arity pass can change the program.
- Stop loading the old `factorise-defun` extension as the kernel's
  factorisation step.
- Define `shen.char-stinput?` and `shen.char-stoutput?`. A byte-oriented port
  can return `false` for both, as Shen/Scheme does. A port which returns `true`
  must also provide `shen.read-unit-string` for input or `shen.write-string`
  for output.
- Recheck all host overrides against the new kernel names and behaviour. In
  particular, do not carry a replacement forward only because the old kernel
  had a function with the same name.

**Optimisation Opportunities**

- Backend code which previously discovered arities and constructed partial
  application closures can be removed.
- Hosts with native character streams can use the stream capability predicates
  to avoid encoding character I/O as byte-at-a-time operations.

## 22.3

### Extensions

**New extensions in this release**:

- **programmable-pattern-matching**: experimental extension which adds hooks to
  extend how the Shen compiler handles pattern matching clauses.

### Benchmark Suite

A basic benchmark suite for primitive operations was added.

**Minimum Requirements**

None.

**Optimisation Opportunities**

- Porters can use the benchmarks to locate inefficient primitive operations in
  their port.

## 22.1

### Extensions

**New extensions in this release**:

- **factorise-defun**: pattern matching factorisation optimisation for
  `defun`s.

**Minimum Requirements**

None.

**Optimisation Opportunities**

- Ports on hosts with an efficient `GOTO`, local labels, or optimised tail calls
  can use the extension to speed up pattern matching.
- This extension is historical. The S-kernel integrated its own factoriser, so
  ports upgrading to 32.0 or later should stop loading it for this purpose.

## 22.0

### Kernel Initialisation Function

`make.shen` now moves all top-level non-`defun` statements into `init.kl`, where
they are grouped in a new function called `shen.initialise`. Calling
`shen.initialise` sets the global symbols and prepares stateful data structures
such as `*property-vector*`. Nothing else in the kernel can be expected to work
before this function has been called.

The default entry point `shen.shen` was renamed to `shen.repl`.

Because all top-level forms are grouped in `shen.initialise`, the other KLambda
files no longer need to be loaded in a particular order. They must all be
loaded before initialisation.

**Minimum Requirements**

- Include `init.kl` as part of the kernel.
- Call `shen.initialise` after all kernel `defun`s have been defined and before
  any user code is run.
- Overrides can be defined before `shen.initialise`, but not when defining them
  depends on running Shen code.
- Change calls to the old `shen.shen` entry point to `shen.repl`.

**Optimisation Opportunities**

- A port can compile the statements in `shen.initialise` into its native image
  or startup path instead of retaining the function in its generated form.
- The kernel loading process can be simplified because inter-file load order no
  longer matters.

### Dynamic Code Expansion

Calls to the declaration functions in `types.shen` and the initialisation of
lambda forms are now performed by `make.shen` to improve startup time.

**Minimum Requirements**

None: this does not change kernel behaviour, though it may make an existing
port optimisation redundant.

**Optimisation Opportunities**

- A port build which performed the same expansion can remove that step and use
  the generated initialisation code.

### Extensions

Starting with this release, the Shen kernel distribution includes optional
extensions which ports can use. See [Extensions](extensions.md).

**New extensions in this release**:

- **features**: conditional code expansion at read time based on platform
  features.
- **launcher**: command-line handling for running scripts, evaluating
  expressions, loading files, or launching the REPL.
- **expand-dynamic**: enabled by default during the kernel build; performs the
  dynamic code expansion described above.

## 21.2

### Test Suite Pass/Fail Counters

`tests.shen` no longer resets pass/fail counters when a test suite finishes.

**Minimum Requirements**

None: this does not change kernel behaviour.

**Optimisation Opportunities**

- Port test harnesses can remove workarounds for the old call to
  `(shen-test.reset)`.

## 21.1

### `map` Function

`(map F X)` now returns `(F X)` when `X` is neither a cons nor the empty list.

**Minimum Requirements**

- A port which overrides `map` must implement this behaviour.

**Optimisation Opportunities**

None beyond the existing opportunity to replace `map` with a conforming native
implementation.

## 21.0

### Dictionary Functions Renamed

All functions in `dict.kl` were moved into the `shen` package and now have the
`shen.` prefix.

**Minimum Requirements**

- Rename overrides of dictionary functions to use their `shen.`-qualified
  names.

**Optimisation Opportunities**

None: this is a rename.

## 20.0

### Dictionaries

This release introduced a general dictionary interface and rebuilt facilities
such as `*property-vector*`, `get`, `put`, and runtime function lookup on it.

**Minimum Requirements**

- Include `dict.kl` as part of the kernel.
- Reconsider port-specific overrides of `*property-vector*`, `get`, `put`, and
  `unput`. A native dictionary implementation must replace the related
  operations consistently, not just the constructor.
- A native `hash` must allow zero as a valid result.

**Optimisation Opportunities**

- The functions in `dict.kl` can be overridden to use a native dictionary or
  map type. The constructor, predicates, accessors, mutation, folding, keys,
  and values operations must all agree on that representation.

### Standard Error Output

The kernel now includes `*sterror*` and `(sterror)`. `*sterror*` has the same
output-stream interface as `*stoutput*`, but is intended for error messages.

**Minimum Requirements**

None: `*sterror*` defaults to `*stoutput*`. Ports targeting the 20.x series
should use 20.1 or later, which correctly registers `*sterror*` as external.

**Optimisation Opportunities**

- A port can install the host's standard-error stream in `*sterror*` before
  kernel initialisation so diagnostics remain separate when standard output is
  piped.

### Character-based I/O

The new functions `read-char-code` and `read-file-as-charlist` allow the 20.x
reader to handle multibyte character encodings.

**Minimum Requirements**

None: the default implementations use the byte-based operations and therefore
assume an ASCII-compatible stream.

**Optimisation Opportunities**

- Override `read-char-code` to decode the host stream's character encoding.
- Override `read-file-as-charlist` to read a complete file efficiently rather
  than recursing one character at a time.

# Port Upgrade Guide

As changes are made and new versions of the Shen kernel are released, ports might require modifications to adapt. These adaptations might be necessary in order to continue working - there may be new requirements for the port to satisfy, or there may be impacts on overriden/optimised behavior.

This document runs parallel to changes mentioned in the [changelog](../CHANGELOG.md). Versions without notable changes pertinent to upgrading are excluded. Unreleased changes are listing under the [Unreleased](#unreleased) section just like in the changelog.

## Unreleased

## 22.1

### Extensions

**New extensions in this release**:

  - **factorise-defun**: pattern matching factorisation optimisation for defuns.

**Optimisation Opportunities**

  - Ports running on top of platforms providing a GOTO-like construct or optimised tail-calls may be able to take advantage of the `factorise-defun` extension to speed-up pattern matching.

## 22.0

### Kernel Initialisation Function

`make.shen` now moves all top-level non-`defun` statements into a separate file called `init.kl`. In there, they grouped in a new function called `shen.initialise`. Calling `shen.initialise` sets all of the global symbols and prepares stateful data structures like the `*property-vector*`. Nothing else in the kernel can be expected to work before this function has been called.

The default entry point `shen.shen` has been renamed to `shen.repl`.

Because all of the toplevel forms are grouped in `shen.initialise`, it is no longer necessary to load the klambda files in any particular order, they just all have to be loaded before initialisation.

**Minimum Requirements**

  - Port must include `init.kl` as part of the kernel.
  - When creating a Shen environment, `shen.initialise` must be called after all of the `defun`s have been defined and before any user code is run.
  - Overrides can be defined before `shen.initialise` is called, but not if defining them depends on running any Shen code.
  - The call to the entry point `shen.shen` has been renamed to `shen.repl`.

**Optimisation Opportunities**

  - Port may wish to take this `shen.initialise` function, remove it in its default form and build out the individual statements somehow.
  - Compilation/loading process can be simplified as load order is no longer important.

### Dynamic Code Expansion

Calls to the `declare` functions in `types.shen` and the initialisation of the lambda forms are done by `make.shen` now to improve kernel startup time.

**Minimum Requirements**

None: this change doesn't alter kernel behavior and shouldn't break anything a port depends on. It might make some existing port optimisations unnecessary, though.

**Optimisation Opportunities**

  - If port's build process was doing anything similar, that step can be removed as the kernel build does this itself.

### Extensions

Starting with these release, the Shen Kernel distribution includes some optional extensions that ports can make use of.

Please refer to `doc/extensions.md`.

**New extensions in this release**:

  - **features**: conditional code expansion at read-time based on platform features.
  - **launcher**: default behaviour command-line handling, with the option of running scripts, evaluating expressions, and loading files in addition to launching the REPL.
  - **expand-dynamic**: enabled by default, this extension takes care of the dynamic code expansion mentioned in the previous section.

## 21.2

### Test Suite Pass/Fail Counters

`tests.shen` no longer resets pass/fail counters when test suite is finished. Not a kernel change, but port may have testing code built around addressing this reset.

**Minimum Requirements**

None: this change doesn't alter kernel behavior.

**Optimisation Opportunities**

  - If port's test suite was doing anything to work around the untimely call to `(shen-test.reset)`, it should not need to do that anymore.

## 21.1

### `map` Function

The `(map F X)` function has been redefined to return `(F X)` when `X` is not a list (not a cons or empty list).

**Minimum Requirements**

  - If `map` was overriden with an optimised version, it will need to be updated to provide this behavior.

**Optimisation Opportunities**

No additional optimisation: if port was overriding `map`, then override needs to be updated, otherwise ignore this change.

## 21.0

### Dictionary Functions Renamed

All of the functions in `dict.kl` have been put in the `shen` package and now have the `shen.` prefix.

**Minimum Requirements**

  - If your port override any of the dictionary functions, those overrides will have to be re-named with the `shen.` prefix.

**Optimisation Opportunities**

None: this is just a rename.

## 20.0

### Dictionaries

This version saw the introduction of multiple new features, including a generlised interface and default implementation for dictionaries, for example, `*property-vector*`.

**Minimum Requirements**

  - Port must include `dict.kl` as part of the kernel.
  - Any port-specific overrides or optimisations related to `*property-vector*`, `get`, `put` and `unput` need to be reconsidered.

**Optimisation Opportunities**

  - Functions defined in `dict.kl` can be overriden to use a dictionary or "map" object type native to the host platform. However, if one function is changed, like `(dict Capacity)` which creates a new dictionary, then multiple other functions will need to be changed to deal with the native object type instead of the default implementation.

### Standard Error Output

The kernel now includes `*sterror*` and a `(sterror)` function to access it. `*sterror*` is an output stream with the same interface as `*stouput*`, but prints to standard error so error messages can be filtered out when piping standard output to another process.

**Minimum Requirements**

None: `*sterror*` defaults to `*stoutput*` if `*sterror*` is not defined.

**Optimisation Opportunities**

  - Port can set `*sterror*` when creating the primitive environment to a standard error stream provided by the host environment. This will result in the desired piping behavior.

### Character-Based I/O

Additional functions `read-char-code` and `read-file-as-charlist` are defined which allow the kernel to handle multi-byte character encodings. This was the case with SBCL >= 1.1.2 on Windows and could be the case with other platforms. If the REPL is behaving strangely, it is a sign that overriding these functions with port-specific behavior may be necessary.

**Minimum Requirements**

None: the character-based functions just default to the same behavior as the byte-based ones and assume an ASCII character encoding.

**Optimisation Opportunities**

  - Override `read-char-code` with a version that can handle multi-byte characters. It can refer to metadata attached to the native stream type indentifying the character encoding.
  - Override `read-file-as-charlist` with a version that can "gulp" the entire file at once, avoiding character-at-a-time recursion, and possibly adding better error handling.

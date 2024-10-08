# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)

## [Unreleased]

## [39.0] - 2024-08-10

### Changed

- `fn` defined for 0 place functions.

## [38.3] - 2024-05-13

### Fixed

- Removed unnecesary external symbols, arities and duplicated definitions
- Recover dynamic `demod` funcionality so that it is not updated through an `eval` that redefines it.

## [38.2] - 2024-05-12

### Fixed

- Bug in the handling of % and ! in the REPL.

## [38.1] - 2024-03-19

### Fixed

- More portable code for the application of user-defined macros

## [38.0] - 2024-03-09

### Changed

- Shen macros factorised resulting in a 2X faster reader.
- Use Shen/Scheme as the default implementation for building klambda.

## [37.1] - 2024-01-12

### Fixed

- Redundant factorisation eliminated.

## [37.0] - 2024-01-12

### Changed

- Replaced factorisation algorithm with a simplified, improved version.

## [36.0] - 2024-01-10

### Changed

- Prolog calls run in their own memory space.
- `assert` and `retract` recycle memory.

## [35.0] - 2024-01-10

### Changed

- Type `==>` simplified for YACC.

## [34.6] - 2024-01-10

### Changed

- Tweaks for Yggdrasil

## [34.5] - 2023-08-19

### Added

- `assert` and `retract` functions restored.

## [34.4] - 2023-07-02

### Fixed

- Type of `==>`.
- Type of `destroy`.
- `(protect X)` now works inside `defcc` forms.

### Removed

- Old unused prolog code.

## [34.3] - 2023-04-02

### Fixed

- Bug in `destroy` function caused by duplicate `unassoc` definition.

## [34.2] - 2022-12-10

### Added

- Support for polymorphic types in YACC functions.

## [34.1] - 2022-11-27

### Fixed

- Correctness bug in the typechecker.

## [34.0] - 2022-11-27

### Added

- `assert` and `retract`: https://shenlanguage.org/TBoS/assert&retract.html

### Fixed

- Bug in compilation of shadowed pattern match variables.

## [33.1.2] - 2022-10-09

### Changed

- Made `pvar?`, `tuple?` and `vector?` more optimizable by backends (like in the pre-S-kernel versions).

## [33.1.1] - 2022-10-09

### Changed

- When factorising `defun` definitions, abstract evaluation of branch functions in a `shen.eval-factorised-branch` function that ports can override to customize behavior.

### Removed

- `shen.*platform-native-call-check*` variable for customizing the check for native calls got removed (not needed anymore with the addition of `foreign`).

## [33.1] - 2022-09-10

### Added

- `foreign` form for marking native platform functions.

### Fixed

- Support for % and ! in the REPL in platforms that don't normalize line-endings.

## [32.3] - 2022-07-31

### Fixed

- Fixed bug in the compilation of mode forms in sequent calculus.
- Fixed compilation of lambda forms in Shen prolog code.

## [32.1] - 2022-05-21

### Fixed

- Function overapplication.

## [32.0] - 2022-03-06

### Changed

- Integrated changes from the new S-kernel series.

## [22.4] - 2020-03-07

### Fixed

- Fixed compilation of empty vector pattern matching.

## [22.3] - 2020-02-23

### Added

- New experimental `programmable-pattern-matching` extension.
- Extensible selector rules on `factorise-defun` extension.
- Benchmarks.

### Fixed

- Fixed bug in typechecking function that made user-defined typechecking rules for lambdas to never run.
- Fixed handling of prolog cuts in some corner cases.
- The t* algorithm now respects user-defined rules for lambdas.

## [22.2] - 2019-10-11

### Fixed

- `factorise-defun` extension: Avoid generating unnecessary labels for `%%return` expresions for literal values or variable references.

## [22.1] - 2019-09-29

### Added

- New `factorise-defun` extension that performs a pattern matching factorisation optimization on defuns.

### Changed

- Split initialisation function into many.

## [22.0] - 2019-09-26

### Added

- Premature expansion of some dynamic code when generating `.kl` files so that it doesn't have to be evaluated during startup. Some ports should see a huge speedup in startup times from this change.
- Extensions (see `doc/extensions.md`).
- New document with instructions for porters on how to upgrade to new kernel releases (see `doc/port-upgrade.md`).

### Changed

- `shen.shen` has been renamed to `shen.repl`.
- A new file `init.kl` has been added and it needs to be included along the other `.kl` files.
- A new `shen.initialise` function has been added. This function has to be called before anything else.
- Load order of `.kl` files doesn't matter anymore.

## [21.2] - 2019-09-17

### Fixed

- variables that shadow a pattern match variable no longer get ebr'd.
- `print-vector?` will now handle empty absvectors, returning `false`.
- Removed `<>` from initialisation of `shen.external-symbols`.
- Fix `preclude*` and `include*` not working for datatypes defined inside packages.

### Changed

- `tests.shen` no longer resets pass/fail counters when test suite is finished.

## [21.1] - 2018-10-06

### Added

- Support for cons syntax in type signatures (via Mark).

### Fixed

- Make prolog's `call` work with properly with pvars.

### Changed

- `prolog?` macro now expands code inline like in SP instead of using `defprolog` (via Mark).
- `(map F X)` now returns `(F X)` when `X` is not a list. The type signature of `map` remains unchanged. Matches SP's behaviour.
- `map` is no longer tail-recursive. Matches SP's behaviour.

## [21.0] - 2018-02-17

### Added

- Moved code that prints errors at the toplevel to the `shen.toplevel-display-exception` function that can be overrided by ports to customize printing of errors (to for example, include error location).

### Removed

- `command-line` function and `*argv*` variable.
- `fold-right` and `fold-left`.
- `get/or`, `value/or`, `<-address/or`, `<-vector/or` and `<-dict/or`.
- `filter`.
- `exit`.
- Handling of EOF in the REPL.

### Changed

- `for-each` was made internal to the `shen` package.
- `dict`, `dict?`, `dict-count`, `dict->`, `<-dict`, `dict-rm`, `dict-fold`, `dict-keys` and `dict-values` made internal to the `shen` package.

### Fixed

- Remove repetition from code generated by `defcc` which made some cases very slow to compile and run.
- Fixed the expansion of non-null packages generated by macros.
- Increased space allocated for prolog, fixes issues in bigger programs.
- Made `,` external.
- Fixes `nth` for cases where the element is not on the list or invalid arguments are passed.

## [20.1] - 2017-05-01

### Added

- `(command-line)` function that returns a list of command line fragments. By default it returns `["shen"]`, ports can override this function or set the value of the `*argv*` variable on startup.

### Fixed

- Fixed `dict-fold`.
- Handle integer overflows in prolog's complexity calculation function. Solves issues in ports with 32bit integers.
- In the 20.0 release, `*sterror*` was not properly set as external in `make.shen`, fixed now.

## [20.0] - 2017-04-23

### Added

- Documentation for system functions (`doc/system-functions.md`).
- Character based I/O, makes Shen work on environments where I/O streams are multibyte encoded (SBCL >= 1.1.2 on Windows).
- Dict datatype with API:
  - `(dict Size)` — returns dictionary object.
  - `(dict? Dict)` — predicate.
  - `(dict-count Dict)` — returns dictionary items count.
  - `(dict-> Dict Key Value)` — stores value.
  - `(<-dict Dict Key)` — retrieves value if it exists or throws an error.
  - `(<-dict/or Dict Key OrDefault)` — like `<-dict` but returns the result of thawing `OrDefault` instead of throwing an error when the key is missing.
  - `(dict-rm Dict Key)` — removes value from a dictionary.
  - `(dict-fold F Dict Acc)` — walks the dictionary, calling `(F Key Value Acc)` for each item in it. The result of each call is the new value of `Acc`, once no more items are left, the final value of `Acc` is returned.
  - `(dict-keys Dict)` — Returns  a list containing all keys in `Dict`.
  - `(dict-values Dict)` — Returns a list containing all values in `Dict`.
- Added `get/or`, `value/or`, `<-address/or` and `<-vector/or`. These work like their `/or`-less counterparts, but accept as an extra argument a continuation (`(freeze ...)`). Whenever their original versions would raise an exception, these variants will instead `thaw` the continuation and return it's result.
- Added `(fold-left F Acc List)`. Calls `(F Acc Elt)` for every `Elt` element in `List`. The result of each call to `F` is used as the new `Acc` for the next call. The final result is the return value of the last call to `F`.
- Added `(fold-right F List Acc)`. Calls `(F Elt Acc)` for every `Elt` element in `List`. The result of each call to `F` is used as the new `Acc` for the next call. The final result is the return value of the last call to `F`.
- Added `(for-each F List)`. Calls `F` on every element of `List` (in order), ignoring the results.
- Added `(filter Predicate List)`. Returns a new lost with all elements to which `(Predicate Elt)` returns true.
- Added `(exit ExitCode)`. Exits the program using the specified error code. The default implementation just ends the REPL loop, ports have to override `exit` if they want the exit code to have any effect.
- Added `*sterror*` and `(sterror)`, STDERR port. Defaults to an alias of `*stoutput*`.
- Added `(read-char-code Stream)`. Reads a character from a stream, and returns its numeric value.
- Added `(read-file-as-charlist Name)`. Reads the contents of a file as a sequence of characters. The result if a list of numeric character codes.

### Changed

- Reader is now built on top of `read-char-code` instead of `read-byte`. As a result, Shen's REPL now works on multibyte environments, like SBCL >= 1.1.2 on Windows.
- Reimplemented `put` and `get` on top of dicts.
- Reimplemented runtime function lookup using `put` and `get`.
- Changed `hash` so that 0 is a valid return value.
- Changed `make.shen` so that 19.2 can correctly compile the new version without needing two passes.
- Ctrl+D (EOF) in the REPL when the line is empty, exits Shen.

### Fixed

- Declared arity for system functions that were missing it.
- Fixed package prefix handling for internal package symbols.

## [19.3.1] - 2017-02-19

### Added

- New `CHANGELOG.md` file with new format.

### Changed

- Whitespace cleanup and code reformatting.

## [19.3] - 2017-02-17

### Fixed

- Fixed Prolog tests.
- Fixed `untrack` function.
- Made `<!>` external and declared arity.
- `*home-directory*` is not set anymore if it already has a value.

## [19.2] - 2015-05-07

### Fixed

- `receive` made external.
- Call failure in `shen.next-50` corrected.

## [19.1] - 2015-04-28

### Fixed

- `lambda` introduced as exception for `ebr`.

## [19] - 2015-04-02

### Added

- `EQL` introduced in Common Lisp backend.
- `internal` introduced.

## [18.1] - 2015-03-31

### Changed

- Kl sources recompiled through Shen 18.

## [18] - 2015-03-31

### Changed

- `function` designed to work with symbol table.

### Fixed

- Dynamic binding for `function` fixed.
- `abort` and `absvector?` given arities.

## [17.3] - 2015-03-01

### Fixed

- Changed `function` macro to not use `freeze`.

## [17.2] - 2015-02-23

### Fixed

- Fixed `result-type`.

## [17.1] - 2015-02-11

### Added

- `function` introduced into standard tests.

## [17] - 2015-02-02

### Added

- BSD license.
- Easy source install (`make.shen`).
- Shen standard dot notation native Lisp interface code introduced.
- Non-left linear type checker.
- `SVREF` fast vector access introduced for CL.
- `speed 3` compiler setting for CL.
- Shen standard dot notation native Lisp interface code introduced.

### Removed

- `intprolog` and dependent code removed.

### Changed

- `sum` made systemf (totals a list).
- `quit warn macro *macros* strong-warning ==>` removed as systemf.
- `unput package?` added to system functions.
- `systemf` returns its argument.
- Macro list no longer requires symbol disambiguation.

### Fixed

- `protect` not stripped properly - fixed.
- `((* 7 8)) = 56` in Lisp backend fixed.
- Bugfix in YACC.

## 16

- `(it)` introduced

## 15.1

- `subst` debugged
- read accepts ^ gracefully
- type given correct arity
- expt'l code removed from type checker
- optimise.lsp restored - `shen.` not `shen-`
- new CL backend

## 15

- kill reinstituted
- synonyms becomes a complete demod

## 14.2

- arity error in YACC fixed

## 14.1

- read-byte becomes optional 0-place (bugfix)
- profiler debugged
- read+ removed

## 14
- prolog? fixed
- YACC handles lists
- kill removed

## 13.2
- 'type' fixed
- os, port, porters, implementation, version, language introduced as 0-place
- exec in SBCL

## 13.1
- tc? is 0 place
- write-to-file corrected
- variable sharing bug eliminated in type checker

## 13
- system becomes byte based
- input/input+/read become relative to streams
- BNF for numbers corrected in spec

## 12
- kill added to Shen-YACC
- defmacro returns unit to type checker
- equal?, greater? ... etc. placed in shen package

## 10.1
- preclude etc. fixed
- defcc works in packages

## 10
- \\ single line comments enabled
- intern, tlstr given arities
- ?x removed from YACC

## 9.2
- absvector given arity
- in systemfed
- absvector redefined for CL
- pr redefined for CL
- duplicated rcons form removed

## 9.1
- read-error fixed
- type checking demodulation fixed
- type checker refactored

## 9
- ps given a type
- concat has no type
- string->symbol introduced
- stinput, stoutput, inferences 0 place
- Shen-YACC II brought in - types and guards
- compiler warnings and print hangs removed from SBCL
- printer refactored

## 8
- zero place functions brought in
- read-from-string brought in

## 7.1
- write-file corrected
- get-time given arity
- unix systemfed

## 7
- stoutput corrected
- str prints streams and closures
- hush removed
- failure object printed as ...
- `*dump*` removed
- all globals initialised in declare.shen

## 6
- ?x introduced for YACC
- stinput type corrected
- stoutput introduced
- stoutput type introduced
- fill-vector corrected
- `<!>` introduced
- $ for strings introduced
- UNIX time introduced

## 5
- type of intern corrected
- adjoin given a type
- protect introduced for free variables
- \ removed as escape character
- str changed STRINGP for ATOM

## 4.2
- T can be used as a variable
- vectors do not print in reverse
- *standard-output* works
- map and remove tail recursive

## 4.1
- y-or-n? fixed
- compiler warnings suppressed in CLisp

[Unreleased]: https://github.com/Shen-Language/shen-sources/compare/shen-39.0...HEAD
[39.0]: https://github.com/Shen-Language/shen-sources/compare/shen-38.3...shen-39.0
[38.3]: https://github.com/Shen-Language/shen-sources/compare/shen-38.2...shen-38.3
[38.2]: https://github.com/Shen-Language/shen-sources/compare/shen-38.1...shen-38.2
[38.1]: https://github.com/Shen-Language/shen-sources/compare/shen-38.0...shen-38.1
[38.0]: https://github.com/Shen-Language/shen-sources/compare/shen-37.1...shen-38.0
[37.1]: https://github.com/Shen-Language/shen-sources/compare/shen-37.0...shen-37.1
[37.0]: https://github.com/Shen-Language/shen-sources/compare/shen-36.0...shen-37.0
[36.0]: https://github.com/Shen-Language/shen-sources/compare/shen-35.0...shen-36.0
[35.0]: https://github.com/Shen-Language/shen-sources/compare/shen-34.6...shen-35.0
[34.6]: https://github.com/Shen-Language/shen-sources/compare/shen-34.5...shen-34.6
[34.5]: https://github.com/Shen-Language/shen-sources/compare/shen-34.4...shen-34.5
[34.4]: https://github.com/Shen-Language/shen-sources/compare/shen-34.3...shen-34.4
[34.3]: https://github.com/Shen-Language/shen-sources/compare/shen-34.2...shen-34.3
[34.2]: https://github.com/Shen-Language/shen-sources/compare/shen-34.1...shen-34.2
[34.1]: https://github.com/Shen-Language/shen-sources/compare/shen-34.0...shen-34.1
[34.0]: https://github.com/Shen-Language/shen-sources/compare/shen-33.1.2...shen-34.0
[33.1.2]: https://github.com/Shen-Language/shen-sources/compare/shen-33.1.1...shen-33.1.2
[33.1.1]: https://github.com/Shen-Language/shen-sources/compare/shen-32.1...shen-33.1.1
[33.1]: https://github.com/Shen-Language/shen-sources/compare/shen-32.3...shen-33.1
[32.3]: https://github.com/Shen-Language/shen-sources/compare/shen-32.1...shen-32.3
[32.1]: https://github.com/Shen-Language/shen-sources/compare/shen-32...shen-32.1
[32.0]: https://github.com/Shen-Language/shen-sources/compare/shen-22.4...shen-32
[22.4]: https://github.com/Shen-Language/shen-sources/compare/shen-22.3...shen-22.4
[22.3]: https://github.com/Shen-Language/shen-sources/compare/shen-22.2...shen-22.3
[22.2]: https://github.com/Shen-Language/shen-sources/compare/shen-22.1...shen-22.2
[22.1]: https://github.com/Shen-Language/shen-sources/compare/shen-22.0...shen-22.1
[22.0]: https://github.com/Shen-Language/shen-sources/compare/shen-21.2...shen-22.0
[21.2]: https://github.com/Shen-Language/shen-sources/compare/shen-21.1...shen-21.2
[21.1]: https://github.com/Shen-Language/shen-sources/compare/shen-21.0...shen-21.1
[21.0]: https://github.com/Shen-Language/shen-sources/compare/shen-20.1...shen-21.0
[20.1]: https://github.com/Shen-Language/shen-sources/compare/shen-20.0...shen-20.1
[20.0]: https://github.com/Shen-Language/shen-sources/compare/shen-19.3.1...shen-20.0
[19.3.1]: https://github.com/Shen-Language/shen-sources/compare/shen-19.3...shen-19.3.1
[19.3]: https://github.com/Shen-Language/shen-sources/compare/shen-19.2...shen-19.3
[19.2]: https://github.com/Shen-Language/shen-sources/compare/shen-19.1...shen-19.2
[19.1]: https://github.com/Shen-Language/shen-sources/compare/shen-19...shen-19.1
[19]: https://github.com/Shen-Language/shen-sources/compare/shen-18.1...shen-19
[18.1]: https://github.com/Shen-Language/shen-sources/compare/shen-18...shen-18.1
[18]: https://github.com/Shen-Language/shen-sources/compare/shen-17.3...shen-18
[17.3]: https://github.com/Shen-Language/shen-sources/compare/shen-17.2...shen-17.3
[17.2]: https://github.com/Shen-Language/shen-sources/compare/shen-17.1...shen-17.2
[17.1]: https://github.com/Shen-Language/shen-sources/compare/shen-17...shen-17.1
[17]: https://github.com/Shen-Language/shen-sources/commit/bd5379837b7c8e94509879430dea7ff3067b6079

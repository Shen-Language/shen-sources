# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)

## [Unreleased]

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

## Older releases

For changes in older releases (pre-BSD) please see `bugfixes.txt`.

[Unreleased]: https://github.com/Shen-Language/shen-sources/compare/shen-20.0...HEAD
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

# Shen Agent Guide (repo-derived)

This guide is for an automated coding agent working in this repo. It focuses on
what matters to read, edit, and reason about Shen code quickly and safely.

## 1. Agent workflow

- Find definitions fast: use `rg "(define"`, `rg "(defprolog"`, `rg "(defcc"`.
- Source of truth: `sources/` (kernel), `lib/stlib/` (core standard library),
  `lib/` (optional libraries), and `tests/` (executable examples and idioms).
- When unsure about expansion, use `ps` on a function in the REPL to see its
  recorded definition.
- Prefer examples from `tests/` when guessing usage or expected results.
- If types are involved, toggle with `(tc +)` and use `(include [...])` to
  enable datatypes used by a test or module.
- Wrap risky evaluation with `trap-error` so failures do not crash the loop.

## 2. Reader and syntax essentials

- Prefix application: `(f x y)`.
- Lists use brackets and `|` for head/tail: `[]`, `[X | Y]`.
- Variables start uppercase; lowercase symbols are constants or function names.
- `_` is a wildcard in patterns (rewritten to a fresh variable).
- Strings are double-quoted. Tuples, vectors, and strings have constructors:
  `@p`, `@v`, `@s`.
- Comments: line `\\`, block `\* ... *\`.
- `<>` is read as `(vector 0)`.

## 3. Core data and pattern matching

- Lists: `[a b c]`, `cons`, `hd`, `tl`.
- Tuples: `(@p X Y)`, selectors `fst`, `snd`.
- Strings: `@s` for pattern/build, `cn` for concatenation.
- Vectors: `(vector N)`, `@v` conses to front, `<-vector` reads.

Pattern matching is the default in `define` rules and is ordered top to bottom.

```shen
(define head
  [X | _] -> X)
```

Guards use `where`:

```shen
(define prime*
  X Max Div -> false  where (integer? (/ X Div))
  X Max Div -> true   where (> Div Max)
  X Max Div -> (prime* X Max (+ 1 Div)))
```

## 4. Functions, application, and control flow

- `define` supports multiple clauses; `defun` is the compiled form.
- Auto-currying: `(f a)` returns a function if `f` expects more args.
- Pass named functions with `fn` or `function`; lambdas use `/.`.

```shen
(map (fn reverse) [[1 2] [3 4]])
(map (/. X (+ X 1)) [1 2 3])
```

Control/binding forms:

- `if` (3-arg function)
- `cases` (macro for nested `if`)
- `let` (multiple bindings)
- `do` (sequence, returns last)

## 5. Types and datatypes

- `declare` for explicit types; signatures can be embedded in `define`.
- `datatype` declares inference rules.
- Toggle type checking with `(tc +)` / `(tc -)`.
- Control the active datatype set with `include` and `preclude-all-but`.
- Use `synonyms` to install type synonyms / demodulation rules.

```shen
(define complement
  {binary --> binary}
  [0] -> [1]
  [1] -> [0])
```

## 6. Macros, parsers, and Prolog

- `defmacro` defines macros; `macroexpand` shows expansion.
- `defcc` defines a grammar; `compile` runs a nonterminal on token lists.
- `defprolog` defines predicates; `prolog?` runs queries.
- `!` is cut; `return` extracts answers.
- Code is data: build lists and use `eval` to execute, `read-from-string` to parse.

```shen
(defprolog parent
  "Ada" "Bob" <--;)

(prolog? (parent "Ada" X) (return X))
```

## 7. State, effects, and laziness

- Global state: `(set *x* ...)`, `(value *x*)`.
- Symbol properties: `put`, `get`, `unput`.
- Dictionaries: `dict`, `dict->`, `<-dict`.
- I/O: `read-file`, `read-file-as-string`, `write-to-file`, `output`, `print`.
- Loading: `(load "file.shen")` evaluates a Shen source file.
- Laziness: `freeze` and `thaw`.
- Packages: `package` declares exports; `in-package` switches the active package.

## 8. Debugging and profiling

- `ps` shows stored definitions.
- `track`/`untrack` traces calls.
- `step` and `spy` toggle tracing modes.
- `profile` and `profile-results` measure runtime.
- `trap-error` is the standard error boundary.

## 9. Standard library quick map (lib/stlib)

Load modules explicitly when needed:

- Lists: `lib/stlib/Lists/lists.shen`
- Strings: `lib/stlib/Strings/strings.shen`
- IO: `lib/stlib/IO/files.shen`, `lib/stlib/IO/prettyprint.shen`
- Maths: `lib/stlib/Maths/maths.shen`
- Vectors: `lib/stlib/Vectors/vectors.shen`

Minimal examples:

```shen
(load "lib/stlib/Lists/lists.shen")
(prefix? [1 2] [1 2 3])

(load "lib/stlib/Strings/strings.shen")
(string.length "abc")

(load "lib/stlib/IO/files.shen")
(write-to-file "tmp.txt" "hi")

(load "lib/stlib/Maths/maths.shen")
(gcd 12 16)
```

## 10. Cookbook patterns (agent-ready)

List accumulator:

```shen
(define sum-acc
  [] Acc -> Acc
  [X | Y] Acc -> (sum-acc Y (+ X Acc)))
```

String prefix pattern:

```shen
(define starts-with-a?
  (@s "a" _) -> true
  _ -> false)
```

Vector head:

```shen
(define vhead
  (@v X _) -> X)
```

Dictionary get with default:

```shen
(define dict-get-or
  Key Default Dict
  -> (trap-error (<-dict Dict Key) (/. _ Default)))
```

Parsing:

```shen
(defcc <digit>
  0; 1; 2; 3; 4; 5; 6; 7; 8; 9;)

(compile (fn <digit>) [a b 7 c])
```

## 11. Gotchas

- Variables must start uppercase; lowercase symbols are constants.
- In code-as-data list literals inside a `define`, uppercase names are still
  treated as variables, not inert symbols. Use lowercase binders in generated
  forms like `[let external ...]`, or explicitly protect/construct the symbol.
- `_` is a wildcard and is always replaced by a fresh variable.
- `|` is only valid inside list brackets.
- Auto-currying can hide arity bugs; use `arity` or `ps` if unsure.
- `@v` copies vectors; prefer lists for iterative growth.
- Vectors are 1-based for `<-vector` and `vector->`.
- `protect` prevents a symbol from being treated as a variable during
  evaluation; `(protect X)` evaluates to the symbol `X`, not the value bound
  to `X`.
- `fail` is just a symbol unless used in backtracking contexts.
- `output` supports `~A`, `~S`, `~R`, `~%` formatting directives.

## 12. Repo map and example entry points

- `sources/`: core language, reader, macros, type system, Prolog engine.
- `tests/`: runnable examples and idioms (see `tests/kerneltests.shen`).
- `lib/stlib/`: core standard library modules.
- `lib/`: library bundle root, including `tk`, `concurrency`, and `ide`.

Useful tests to learn behavior quickly:

- `tests/cartprod.shen`: list recursion and `append` usage.
- `tests/binary.shen`: `datatype` and typed `define`.
- `tests/call.shen`: `defprolog`, cut, and `prolog?`.
- `tests/yacc.shen`: `defcc` grammar usage.
- `tests/streams.shen`: tuples and lazy progression.

# Optimising a Shen Port

The Shen kernel is written to be portable. Apart from the KLambda primitives,
it assumes very little about the host platform. As a result, it contains many
functions implemented in deliberately general Shen code even though most host
languages provide a much faster equivalent.

A port is expected to replace suitable kernel definitions with host-specific
versions, provided that their Shen-visible behaviour is preserved. This is
often more important than low-level tuning: functions such as `hash`,
`integer?`, and the dictionary operations occur on important execution paths,
so an inefficient portable implementation is multiplied across the whole
system. Other candidates have narrower benefits. For example, `variable?` is a
compilation-path optimisation: making it faster improves source processing but
does not speed up ordinary programs after they have been compiled.

Throughout this guide, we use
[Shen/Scheme](https://github.com/tizoc/shen-scheme) as a concrete example
because it combines three complementary forms of optimisation:

* kernel overrides implemented with Scheme and Chez Scheme operations;
* direct translation of KLambda operations into Scheme; and
* compiler rewrites that select a cheaper operation when the source expression
  provides enough information.

The same ideas apply to interpreted and compiled ports in languages such as
Python, Ruby, Rust, JavaScript, Java, and the Lisp family. The appropriate
mechanism may be a host function, a compiler intrinsic, a specialised bytecode,
or a small runtime type, but the optimisation opportunity is the same.

## Host representations

Choose representations that make Shen's common operations natural in the host
language. Avoid wrapping host values unless the wrapper is required to preserve
Shen semantics.

### Booleans

Represent Shen `true` and `false` as host booleans when possible. They should
not be ordinary interned symbols internally.

Shen/Scheme maps them to Scheme `#t` and `#f`. Its compiler emits boolean
literals directly, uses Scheme conditionals, and records which expressions are
known to produce booleans. This makes `if`, `and`, `or`, `not`, and `boolean?`
ordinary host operations while preserving Shen's boolean checks.

The reader and `intern` implementation must still map the textual names
`"true"` and `"false"` to those boolean values, and `str` must print them as
Shen expects.

### Numbers

Use the host's ordinary integer and floating-point values when their semantics
are suitable. In particular, do not heap-allocate a wrapper for every small
integer if the host already represents it efficiently.

Arithmetic and numeric comparisons should map directly to host operations.
`number?` and `integer?`, however, must implement Shen's numeric categories,
which may not be identical to the host's type hierarchy. For example, Python
booleans are instances of `int` and must still be excluded from Shen numbers;
conversely, a host may distinguish an integral floating-point value from an
integer type even where Shen `integer?` treats it as numerically integral.

The portable definition of `integer?` performs a lengthy numeric computation
because it cannot assume that the host provides the required predicate. Most
hosts can implement the same semantics much more directly, but the replacement
must test Shen integrality rather than merely the nearest host storage type.

### Symbols

Symbols should normally be interned objects. Interning permits cheap identity
comparison and avoids storing the same symbol name repeatedly.

Keep symbols distinct from strings even on hosts where both are represented by
strings. A tagged string, intern table entry, enum-like value, or dedicated
symbol object can provide that distinction.

The KLambda primitive `intern` should use the same canonical symbol table. It
must also preserve the kernel's special treatment of the textual names `true`
and `false`, along with any other behaviour required by the kernel version.

### Lists and pairs

Map Shen lists to the host's natural linked-pair representation when it has one.
On hosts without pairs, a small pair object with `head` and `tail` fields is
usually preferable to copying arrays for `cons` and `tl`.

The empty list should have one canonical representation. That permits an
identity or tag check for `[]` while non-empty list patterns use a pair test and
direct field access.

### Vectors and tuples

The portable kernel represents Shen vectors using an underlying absolute
vector. Slot zero contains the Shen limit, and the remaining slots are
initialised with `(fail)`. A port can retain this layout or use a dedicated
vector type, but it must preserve the behaviour of `vector`, `vector?`,
`limit`, `vector->`, and `<-vector`.

Tuples have a fixed two-element shape. The portable `@p` builds a tagged
three-slot absolute vector. A host record, a small tuple type, or a directly
initialised three-slot vector is more efficient than general vector creation
followed by repeated generic stores. `fst`, `snd`, and `tuple?` should then be
simple field or slot operations.

### Strings

Use the host string representation directly when it can implement Shen string
semantics. Operations such as `cn`, `pos`, `hdstr`, `tlstr`, `n->string`, and
`string->n` should not decompose strings into Shen lists or repeatedly allocate
one-character strings unless the public result requires one.

The port's byte, character, and indexing operations must implement the string
semantics required by the Shen/KLambda version being ported. The internal
representation may use bytes, code points, or host characters, but that choice
must not silently alter the observable behaviour of `pos`, `string->n`, or
character I/O. This is especially important on hosts whose strings use a
multibyte encoding.

## Direct translation of KLambda

KLambda primitives and special forms should translate to the closest host
construct rather than become calls to a generic Shen dispatcher.

Typical direct translations include:

| KLambda | Host operation |
| --- | --- |
| `if`, `and`, `or`, `cond` | host control flow with short-circuit evaluation |
| `let`, `do` | local binding and sequencing |
| `lambda`, `freeze`, `thaw` | host functions or closures |
| `+`, `-`, `*`, `/`, `<`, `>`, `<=`, `>=` | host arithmetic and comparison |
| `cons`, `hd`, `tl`, `cons?` | pair construction, field access, and pair test |
| `number?`, `string?`, `absvector?` | host type tests |
| `cn` | host string concatenation |
| `absvector`, `<-address`, `address->` | host array allocation, indexing, and update |
| `n->string`, `string->n`, `pos`, `tlstr` | host character and string operations |
| `intern`, `str` | symbol interning and Shen-compatible conversion to text |
| `value`, `set` | global binding lookup and update |
| `simple-error`, `trap-error` | the host's error and exception mechanism |

This applies equally to source-generating ports and interpreters. An interpreter
can give these forms dedicated evaluation cases or bytecodes rather than
looking them up and applying them as ordinary functions.

Host exceptions need a Shen-compatible boundary. `simple-error` must construct
an error whose value can be passed to a `trap-error` handler, and errors raised
by KLambda primitives must participate in the same mechanism. Avoid treating
unrelated process-control events, such as host interrupts or exits, as ordinary
Shen errors. Likewise, do not let the host exception used to implement Shen
errors escape `trap-error` merely because its concrete class differs from an
accessor or arithmetic failure.

## Function application and currying

Most calls generated by the Shen kernel name a known function and supply its
full arity. Those calls should use the host's ordinary multi-argument calling
convention.

Do not curry every call into a chain of one-argument calls. That creates
unnecessary closures and intermediate calls, and can interfere with tail-call
optimisation. Instead:

* call a known function directly when all arguments are present;
* create a closure only for a real partial application;
* for over-application, call the known saturated part and apply the remaining
  arguments to its result; and
* use the fully dynamic apply path only when the function value or effective
  arity is not known.

The kernel maintains arity and lambda-form information specifically to support
these cases. Ports should keep this metadata cheap to access and must update it
correctly when functions are defined or redefined.

Calls through higher-order arguments still require full Shen application
semantics. Optimising known calls must not break first-class functions, partial
applications, over-applications, or redefinition. A direct call bypasses the
general currying/apply path; it does not necessarily bypass a replaceable
function binding. On hosts where a direct reference would permanently bind the
old definition, call through a mutable global binding or function cell. A port
may direct-bind implementation-owned functions only when that restriction is
part of its documented semantics or compilation mode.

## Tail calls

Shen and KLambda rely heavily on tail recursion. A host with proper tail calls,
such as Scheme, can normally use its ordinary call mechanism. On a host without
them, translating tail calls as ordinary recursion eventually exhausts the host
stack in kernel functions that are intended to run in constant space.

Such ports must turn tail calls into iteration. Common representations include:

* a loop for self-tail recursion;
* a trampoline for general calls between functions;
* an interpreter loop that replaces the current expression and environment;
  or
* a compiler transformation that emits jumps or state-machine transitions.

This should apply to multi-argument functions without forcing all functions
through one-argument currying. Static currying can hide the tail position behind
closure calls and defeat the host's optimiser. Shen/Scheme relies on Chez
Scheme's proper tail calls, including the calls to local failure continuations
produced by the S-kernel's pattern factorisation.

## Expand dynamic code before loading

Some portable kernel code constructs work at startup that could instead be
performed while the kernel is generated. The
[`expand-dynamic`](extensions/expand-dynamic.md) extension does this for
several important cases. It pre-expands `declare` forms, produces explicit
lambda-form table entries from known arities, separates top-level `defun`s from
initialisation expressions, and allows the remaining initialisation to be
wrapped in an ordinary function.

This matters even to ports that interpret KLambda. It avoids repeatedly using
`eval-kl` and the type and lambda-form machinery merely to reconstruct data and
functions already known when the kernel was built. On ahead-of-time or
source-generating ports it is more valuable still: kernel definitions remain
visible as static functions to the host compiler, while the genuinely dynamic
work is isolated in a small initialisation function. That enables direct calls,
normal host optimisation, and faster startup.

The distributed KLambda is generated with `expand-dynamic` enabled. A port
that generates KLambda for additional Shen sources should apply the same
expansion when those sources contain declarations or other supported dynamic
forms. This is a staging optimisation, not a semantic change: forms whose
effects are genuinely required at runtime must remain in initialisation order.

## Equality

Shen `=` is structural and can compare values of any type. Calling the complete
structural equality routine for every comparison is unnecessary.

The compiler or evaluator can choose a specialised comparison when either
operand reveals its type:

* interned symbol literals, booleans, `[]`, and `(fail)` can normally use
  identity or a direct tag comparison;
* numeric literals can select numeric equality;
* string literals can select host string equality; and
* values of unknown or compound type use general structural equality.

Shen/Scheme performs these selections while translating KLambda. Its generic
equality routine also begins with identity equality, then handles numbers,
pairs, strings, and vectors. The identity test makes equal symbols, booleans,
the empty list, and identical compound objects return immediately.

A port must not replace structural equality with identity equality in the
general case. Independently constructed equal lists, strings, tuples, and
vectors must continue to compare as required by Shen.

## Kernel functions worth overriding

The following functions are good general-purpose override targets. Some can be
handled by compiler translation instead; what matters is that the portable Shen
algorithm does not remain on the common path.

### Hashing

#### `hash`

The portable implementation converts a value to a printable form, explodes it,
maps characters to numbers, combines them recursively, and implements modulus
in Shen. It is intentionally portable but much slower than a host hash.

Use a host structural hash consistent with the equality used for dictionary
keys. Equal Shen values must produce the same hash for the same bound. The
function has type `A --> number --> number`; for a positive `Bound`, its result
must be a non-negative integer no greater than `Bound`. Normalise hosts that can
produce negative hash codes before applying the bound.

Replacing `hash` alone can substantially improve the portable dictionary even
when the rest of that implementation is retained.

### Dictionaries

The portable dictionary is an absolute vector of buckets, with association
lists used for collisions. Most hosts provide a substantially better hash table
or map implementation.

Override the dictionary family as a unit:

* `shen.dict` — construct a dictionary; the size must be a positive integer and
  invalid sizes must raise the expected error. A valid size is an initial
  capacity hint and may be ignored if the host has no equivalent;
* `shen.dict?` — recognise the port's dictionary representation;
* `shen.dict-count` — return the number of entries;
* `shen.dict->` — associate a key with a value and return the value;
* `shen.<-dict` — retrieve a value or raise the expected missing-key error;
* `shen.dict-rm` — remove a key and return the key;
* `shen.dict-fold` — call `(F Key Value Accumulator)` for every entry;
* `shen.dict-keys` — return the keys as a Shen list; and
* `shen.dict-values` — return the values as a Shen list.

`shen.dict-keys` and `shen.dict-values` can remain defined in terms of
`shen.dict-fold`, but direct host implementations may avoid intermediate work.

The host dictionary's key semantics must match Shen. A host table that compares
keys only by identity is not sufficient when structurally equal Shen values are
valid interchangeable keys. Hosts that cannot directly hash lists or vectors
need a Shen-aware hash/equality adapter or a custom dictionary wrapper.

Dictionaries are especially important because the kernel uses them internally
for properties and metadata. Improving them speeds up compilation, loading,
typechecking, and user dictionary operations.

### Booleans and numeric predicates

#### `boolean?`

Replace the two-clause portable recogniser with a direct host boolean test or
tag test.

#### `not`

Map it to the host boolean negation operation while preserving Shen's
requirement that conditional values are booleans.

#### `integer?`

Replace the portable arithmetic test with a direct implementation of Shen
integrality. A host integer predicate is sufficient only when it accepts and
rejects exactly the same values. This is one of the clearest high-value
overrides in the kernel.

### Symbols and variables

The performance importance of these predicates is not uniform. `symbol?` is a
general predicate and may occur in ordinary programs. In contrast, the
kernel's calls to `variable?` and `shen.analyse-variable?` occur while treating
Shen forms as source code: compiling definitions, rewriting applications,
expanding macros, compiling Prolog, and processing Yacc and sequent syntax.
They are therefore targets for improving source-loading and compilation speed,
not the execution speed of an ordinary already-compiled program.

#### `variable?`

The portable implementation converts its argument using `str` and invokes the
general symbol-name analyser. Once the argument is known to be a valid,
non-empty symbol, a Shen variable can be recognised by checking whether the
first character of its name is uppercase.

Perform that check directly on the interned symbol name. Avoid allocating a new
string or scanning the entire name on every call. This is worthwhile for ports
where compilation speed matters, but it should not be presented or measured as
a general program-execution optimisation. It affects regular program execution
only when the program itself calls `variable?` or invokes Shen's compilation
machinery.

#### `symbol?`

Use the host symbol tag or the port's dedicated symbol representation, then
apply Shen's symbol-name validity rules. Booleans must not be reported as
symbols when they use a distinct host representation.

#### `shen.analyse-symbol?` and `shen.analyse-variable?`

Scan the host string directly with character predicates. The portable versions
recursively split the string into one-character pieces. A single indexed scan
avoids many allocations and calls.

### Reader character operations

#### `shen.digit?` or `shen.numbyte?`

Kernel versions use one of these names for the reader's digit test. Implement
it as a direct character test or the numeric range check `48 <= N <= 57`.

#### `shen.byte->digit`

Implement it as subtraction of the code for `0`, normally `N - 48`.

These operations are tiny but occur repeatedly while reading numbers and source
text. They improve parsing and source-loading speed rather than the execution of
ordinary code after it has been loaded.

### Prolog variables

#### `shen.pvar?`

The portable definition tests for an absolute vector, attempts to read its tag
under `trap-error`, and compares the tag with `pvar`. A port that controls the
representation should use a direct type or tag test.

This predicate is extremely frequent in Prolog execution and typechecking. A
cheap `shen.pvar?` also improves the Shen implementations of `shen.lazyderef`,
`shen.deref`, `shen.lzy=`, and `shen.lzy=!` without requiring those algorithms
to be rewritten in the host language. Its effect is therefore concentrated in
Prolog, typechecking, and compilation workloads rather than general arithmetic
or list-processing programs.

### Tuples

#### `@p`, `fst`, `snd`, and `tuple?`

Use a fixed-size host record, tuple object, or directly initialised tagged
vector. Accessors should be field reads rather than general Shen vector access.

Tuple construction and matching occur frequently in compiler and type-system
code, so avoiding general vector initialisation and repeated stores can have a
visible effect.

### Vectors

#### `vector`

The portable definition allocates an absolute vector and recursively fills
every element with `(fail)`. Use the host's filled-array constructor or a loop
implemented at the host level.

#### `vector?`, `limit`, `vector->`, and `<-vector`

These are worth direct implementations when the port has a dedicated vector
representation or when the portable definitions cause exception handling and
several generic calls per access. Preserve the special treatment of index zero,
uninitialised elements, bounds, return values, and error behaviour.

### String helpers

#### `hdstr`

Implement as direct access to the first character rather than another general
Shen call when function-call overhead is significant.

The underlying `cn`, `pos`, and `tlstr` operations are KLambda primitives, not
kernel overrides. Their host implementations must nevertheless be efficient
because the portable reader and symbol functions build other operations from
them. If `hdstr` compiles to a direct `pos` operation with negligible call
overhead, a separate override is unnecessary.

### File and stream I/O

#### `read-file-as-bytelist`

The portable implementation calls `read-byte` once per byte and builds a
reversed list. Read the file in one operation or in large blocks, then construct
the required Shen list efficiently.

#### `read-file-as-string`

The portable implementation reads one byte at a time and repeatedly appends to
a growing string. Use the host's whole-file or buffered text-reading facility.
Preserve the encoding semantics required by the kernel version, along with its
`*home-directory*` handling.

#### `read-char-code` and `read-file-as-charlist`

Override these on hosts where byte input is not equivalent to character input,
especially for multibyte encodings. `read-file-as-charlist` should use bulk
input rather than character-at-a-time Shen recursion.

#### `pr`

Use the host's buffered string output rather than writing one byte at a time.
Preserve `*hush*`, textual versus binary streams, flushing behaviour, and the
required return value.

## Property access

The kernel implements `get`, `put`, and `unput` over dictionaries containing
association lists. A host dictionary override removes much of their cost, so
optimise dictionaries first.

If property access remains important, a port may provide a more direct
implementation of:

* `get`;
* `put`; and
* `unput`.

The replacement must preserve missing-property errors, return values, and the
relationship with `*property-vector*`. Because these functions are visible to
Shen programs and used by the compiler, changing their observable data model is
not safe merely for speed.

## Other possible kernel overrides

Shen/Scheme does not need to replace most ordinary list functions because Chez
Scheme compiles their recursion and pair operations efficiently. Interpreted
ports, and ports on hosts without proper tail calls, may benefit from host loops
for frequently used functions such as:

* `map`;
* `append`;
* `reverse`;
* `length`;
* `element?`; and
* `assoc`, `assoc-set`, and `assoc-rm`.

These replacements must preserve structural equality, improper-list errors,
callback application, and the exact behaviour of the kernel version being
ported. In particular, `map` behaviour for a non-list argument has changed
between Shen releases, so an override must follow the corresponding source
definition rather than assume the host's `map` semantics.

`explode` and string/list conversion helpers may also be worthwhile on hosts
that can traverse a string directly. Their main effect is normally on reading,
printing, symbol processing, and compilation rather than steady-state numeric
or data-structure code.

## Avoid exceptions for ordinary absence checks

Portable Shen sometimes uses `trap-error` to ask whether an operation would
fail. Exception handling is expensive on many hosts, including common Python,
Ruby, Java, and JavaScript implementations.

For recognised kernel expressions whose handler simply returns a default, a
port can perform the corresponding presence or bounds check directly. Useful
cases include:

* `(value Symbol)` — test whether the global is bound;
* `(get Object Property Dictionary)` — test whether the property exists;
* `(<-address Vector Index)` — test the raw vector bounds; and
* `(<-vector Vector Index)` — test the Shen-vector bounds and whether the slot
  contains `(fail)`.

Shen/Scheme applies this transformation only while compiling trusted kernel
sources. That restriction matters: replacing a general `trap-error` is not safe
when evaluating an operand can raise another error, when the handler uses the
error object, or when the checked version changes type errors or evaluation
order.

Predicates such as `vector?`, `tuple?`, and `shen.pvar?` are even better served
by direct representation tests, avoiding both the accessor and the exception.

## Pattern matching

The KLambda produced for several pattern clauses can repeat the same type tests
and selectors in every clause. The S-kernel factorises this code, but the form
of its output depends on the kernel release. Porters should not confuse its two
built-in factorisation schemes.

Earlier S-kernel releases generated additional `defun`s for shared failure
branches. Each helper accepted the values it needed as explicit arguments, and
the parent function called it by name. From S33.1.1, creation of a branch
definition passed through `shen.eval-factorised-branch`, allowing a port to
retain the helper definition instead of immediately evaluating it.

Shen/Scheme used that hook to collect the branch `defun`s while compiling their
parent. It then emitted the helpers as internal Scheme definitions inside the
parent procedure. Their identities did not escape, their calls had statically
known targets, and required state was passed explicitly. Chez could therefore
compile tail calls to those helpers as direct jumps without allocating
closures. This is the multiple-`defun` mechanism used by S-kernel releases
through 36.

S37 replaced that factoriser with the simplified algorithm used by the current
kernel. It shares repeated selectors but represents a shared failure branch in
KLambda approximately as:

```shen
[let Go [freeze Else]
  [if Test Then [thaw Go]]]
```

A direct Shen/Scheme translation turns this into the equivalent of:

```scheme
(let ([go (lambda () else)])
  (if test then (go)))
```

This form also need not allocate a closure. `go` never escapes, its identity is
statically known, and its calls are in tail position. Shen/Scheme preserves
that local binding and those direct calls; Chez can eliminate the closure and
compile the calls as jumps. This is a different lowering from the earlier
multiple-`defun` mechanism even though both are intended to give the host
compiler equivalent non-escaping control flow.

That optimisation depends on the host compiler. [Chez
10.0](https://cisco.github.io/ChezScheme/release_notes/v10.0/release_notes.html)
added consistent procedure lifting: when a local procedure has only known call
sites, captures only immutable variables, and is called within the scope of
those variables, Chez can turn the captured values into extra arguments and
rewrite the calls automatically. Earlier Chez versions did not do this
consistently. To guarantee closure-free code with those versions,
Shen/Scheme's earlier factorisation path gave each internal helper explicit
parameters for the values used by its failure branch.

A port whose host does not eliminate the capturing zero-argument procedure can
perform the same lambda lifting itself. For example, it can lower the effective
shape

```scheme
(let ([go (lambda () (else x y))])
  (if test then (go)))
```

to

```scheme
(let ([go (lambda (x y) (else x y))])
  (if test then (go x y)))
```

Here `x` and `y` stand for the free values actually used by the branch. Passing
a superset of the values in scope—often all parameters of the containing
function—is a simpler conservative strategy, but passing only the used free
values reduces argument traffic. Either form makes the helper closed and gives
even a less aggressive host compiler a direct call target without an
environment allocation. Preserve the original tail position and evaluation
order when applying this transformation.

Other ports should preserve the same property. A compiler can lower the local,
non-escaping continuation to a label, a direct local call, or a state-machine
transition. An interpreter can represent it as an internal code location and
environment rather than constructing a general first-class closure each time
the containing function runs. The exact lowering is host-specific, but the
shared failure path should not become repeated generic function application or
heap allocation.

By the ordinary KLambda backend stage, source patterns have already become
predicates, equality checks, and selectors. The backend should ensure that the
resulting operations map efficiently to its chosen representations:

* list tests and selectors become empty/pair tests and direct head/tail access;
* tuple tests and selectors become one tag test and direct field reads;
* vector tests reuse representation and length information where safe; and
* string tests use host length, indexing, or prefix operations.

The S-kernel's factorisation exposes repeated tests, selectors, and failure
paths explicitly. A port integrated earlier in the Shen compiler may perform
equivalent work before KLambda is emitted. Once a shape has been checked, avoid
repeating the same predicate or using a generic accessor that checks it again
unless correctness requires it.

## Globals and function metadata

When the name in `value` or `set` is a literal, a source-generating port can
usually refer directly to a host global cell. An interpreter can resolve or
cache the corresponding binding instead of repeating a symbol-table lookup.
Computed names still require the general symbol-to-binding path.

Shen/Scheme uses direct host bindings for a set of frequently accessed kernel
globals. This avoids a dictionary lookup while retaining the dynamic path for
computed names.

Function arity and lambda-form metadata are updated by `update-lambda-table` and
`shen.update-lambdatable`. Ports with a host function representation may
override these operations or store the same information directly on function
objects, but must preserve redefinition and higher-order application semantics.

## What Shen/Scheme overrides

Shen/Scheme provides a practical baseline for other ports, but its literal
kernel overrides should be distinguished from work performed by its compiler.

### Kernel overrides

Excluding port-specific stream and error-display behaviour, Shen/Scheme
replaces:

* `hash`;
* `not`, `boolean?`, and `integer?`;
* `variable?` (for source-processing and compilation throughput), `symbol?`,
  and `shen.analyse-symbol?`;
* `shen.pvar?`;
* `shen.numbyte?` and `shen.byte->digit`;
* the complete `shen.dict` family;
* `read-file-as-bytelist` and `read-file-as-string`;
* `pr`;
* `@p`; and
* `vector`.

### Compiler translations and rewrites

The Shen/Scheme compiler additionally:

* represents Shen booleans as Scheme booleans;
* translates arithmetic, comparisons, pair operations, type predicates,
  strings, and absolute-vector operations directly to Scheme;
* emits ordinary multi-argument Scheme calls for known functions;
* specialises equality from literal and type information;
* compiles selected literal globals as direct bindings;
* replaces safe kernel accessor/`trap-error` patterns with checked operations;
* lowers the S-kernel's factorised failure continuations to non-escaping local
  procedures: it collected generated branch `defun`s on older kernels and
  preserves the current kernel's local `freeze`/`thaw` structure, allowing Chez
  to compile the calls as direct jumps without allocating closures; and
* consumes the statically expanded kernel produced by `expand-dynamic`, rather
  than reconstructing known declarations and lambda forms at startup.

Not every port needs a literal override for every function on this list. For
example, if `hdstr` compiles to `pos` and `pos` is already a direct host string
operation, the portable one-line definition may be sufficiently efficient.
Likewise, a small Shen predicate may be cheap when the host compiler inlines it.
The important question is whether the common operation reaches an efficient
host implementation without repeated allocation, generic dispatch, string
decomposition, or exception handling.

## Semantic requirements

All overrides and compiler specialisations must remain observationally
equivalent to the kernel definitions. In particular, preserve:

* structural equality and compatible dictionary hashing;
* the distinction between booleans, symbols, strings, and numbers;
* exact success values and required errors;
* left-to-right evaluation where it is observable;
* short-circuit behaviour;
* proper and improper list behaviour;
* function redefinition, arity changes, and first-class functions;
* partial and over-application;
* tail calls required by recursive kernel code; and
* the vector, tuple, dictionary, and Prolog-variable behaviour expected by other
  kernel functions.

Portable Shen code defines the behaviour. A good override removes work that the
host can perform more directly; it does not define a different language.

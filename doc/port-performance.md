# Optimising a Shen Port

The Shen kernel is written to be portable. Apart from the KLambda primitives,
it assumes very little about the host platform. As a result, it contains many
functions implemented in deliberately general Shen code even though most host
languages provide a much faster equivalent.

Many ports replace suitable kernel definitions with host-specific versions
while preserving their Shen-visible behaviour. This is often more important
than low-level tuning: functions such as `hash`,
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

## Contents

* [Host representations](#host-representations)
  * [Booleans](#booleans)
  * [Numbers](#numbers)
  * [Symbols](#symbols)
  * [Lists and pairs](#lists-and-pairs)
  * [Vectors and tuples](#vectors-and-tuples)
  * [Strings](#strings)
  * [Sentinels and native representations](#sentinels-and-native-representations)
* [Efficient KLambda execution](#efficient-klambda-execution)
  * [Direct translation of KLambda](#direct-translation-of-klambda)
  * [Function application and currying](#function-application-and-currying)
  * [Sealed implementation code](#sealed-implementation-code)
  * [Tail calls](#tail-calls)
* [Static knowledge and specialisation](#static-knowledge-and-specialisation)
  * [Expand dynamic code before loading](#expand-dynamic-code-before-loading)
  * [Equality](#equality)
  * [Exception-based absence checks](#exception-based-absence-checks)
  * [Pattern matching](#pattern-matching)
  * [Literal global access](#literal-global-access)
* [Kernel functions worth overriding](#kernel-functions-worth-overriding)
  * [Hashing](#hashing)
  * [Dictionaries](#dictionaries)
  * [Booleans and numeric predicates](#booleans-and-numeric-predicates)
  * [Symbols and variables](#symbols-and-variables)
  * [Reader character operations](#reader-character-operations)
  * [Prolog variables](#prolog-variables)
  * [Tuples](#tuples)
  * [Vectors](#vectors)
  * [String helpers](#string-helpers)
  * [File and stream I/O](#file-and-stream-io)
  * [Property access](#property-access)
  * [Other possible kernel overrides](#other-possible-kernel-overrides)
* [Shen/Scheme optimisation summary](#shenscheme-optimisation-summary)
  * [Kernel overrides](#kernel-overrides)
  * [Compiler translations and rewrites](#compiler-translations-and-rewrites)
* [Benchmarks](#benchmarks)
* [Semantic requirements](#semantic-requirements)

## Host representations

Representations that make Shen's common operations natural in the host language
usually perform best. Wrapping host values adds cost and is useful mainly when
it is needed to preserve Shen semantics.

### Booleans

Host booleans are usually a better representation for Shen `true` and `false`
than ordinary interned symbols.

Shen/Scheme maps them to Scheme `#t` and `#f`. Its compiler emits boolean
literals directly, uses Scheme conditionals, and records which expressions are
known to produce booleans. This makes `if`, `and`, `or`, `not`, and `boolean?`
ordinary host operations while preserving Shen's boolean checks.

Using host control flow does not mean adopting host truthiness. Python and
Ruby, for example, accept many non-boolean conditions, and Python and
JavaScript `and`/`or` expressions can return an operand rather than a boolean.
Shen's boolean checks, short-circuit evaluation, and boolean results remain
observable even when they compile to small host operations.

This representation still requires the reader and `intern` to map the textual
names `"true"` and `"false"` to those values, while `str` retains Shen's
expected printed form.

### Numbers

The host's ordinary integer and floating-point values are generally suitable
when their semantics match Shen's. A wrapper around every small integer, for
example, adds allocation without benefit when the host already has an efficient
representation.

Direct host arithmetic and comparison operations avoid general dispatch, though
the host operator itself is not always semantically suitable: integer division
may truncate, fixed-width arithmetic may wrap, and a host may preserve exact
rational results that Shen does not expose.
Shen/Scheme maps most arithmetic directly but wraps Scheme `/` so an integral
result remains an integer and a non-integral exact result becomes inexact.

Shen's numeric categories may not be identical to the host's type hierarchy.
For example, Python booleans are instances of `int` but are not Shen numbers;
conversely, a host may distinguish an integral floating-point value from an
integer type even where Shen `integer?` treats it as numerically integral.

The portable definition of `integer?` performs a lengthy numeric computation
because it cannot assume that the host provides the required predicate. Most
hosts can implement the same semantics much more directly. The relevant test is
Shen integrality rather than merely the nearest host storage type.

### Symbols

Interned objects are usually an effective representation for symbols. Interning
permits cheap identity comparison and avoids storing the same symbol name
repeatedly.

Shen distinguishes symbols from strings even on hosts where both might
otherwise use strings. A tagged string, intern table entry, enum-like value, or
dedicated symbol object can preserve that distinction.

The KLambda primitive `intern` normally shares this canonical symbol table. Its
semantics include the kernel's special treatment of the textual names `true`
and `false`, along with any other behaviour required by the kernel version.
Shen/Scheme also recognises supported numeric strings in `intern`. The exact
contract of the chosen kernel version therefore matters; not every input
necessarily becomes a symbol.

A source-generating port can evaluate `(intern "literal")` while compiling and
emit the canonical value directly. This removes an intern-table lookup from
runtime code, provided that the compile-time implementation applies exactly the
same boolean, number, and symbol rules as runtime `intern`.

### Lists and pairs

A host's natural linked-pair representation is a good match for Shen lists when
one exists. On hosts without pairs, a small pair object with `head` and `tail`
fields is usually less costly than copying arrays for `cons` and `tl`.

A canonical representation for the empty list permits an identity or tag check
for `[]`, while non-empty list patterns can use a pair test and direct field
access.

### Vectors and tuples

The portable kernel represents Shen vectors using an underlying absolute
vector. Slot zero contains the Shen limit, and the remaining slots are
initialised with `(fail)`. A port can retain this layout or use a dedicated
vector type. Either representation still exposes the behaviour of `vector`,
`vector?`, `limit`, `vector->`, and `<-vector`.

Tuples have a fixed two-element shape. The portable `@p` builds a tagged
three-slot absolute vector. A host record, a small tuple type, or a directly
initialised three-slot vector is more efficient than general vector creation
followed by repeated generic stores. It also allows `fst`, `snd`, and `tuple?`
to become simple field or slot operations.

### Strings

A direct host string representation can make `cn`, `pos`, `hdstr`, `tlstr`,
`n->string`, and `string->n` inexpensive. Decomposing strings into Shen lists or
repeatedly allocating one-character strings creates avoidable work unless the
public result requires it.

The relevant string semantics come from the Shen/KLambda version being ported.
An internal representation based on bytes, code points, or host characters can
have different indexing behaviour, especially on hosts with multibyte strings;
that difference is observable through `pos`, `string->n`, and character I/O.

### Sentinels and native representations

Distinct canonical representations for `[]`, `(fail)`, and private
missing-value markers make identity fast paths unambiguous. Reusing a common
host value such as `null` or `None` can also make a stored dictionary value
indistinguishable from a failed lookup.

A native record or collection may replace a portable vector encoding, but the
new representation remains observable through operations such as `=`, `hash`,
`str`, predicates, and accessors. Those relationships form part of the semantic
cost of adopting a specialised representation.

## Efficient KLambda execution

The KLambda layer determines how often ordinary Shen execution reaches the
host's efficient operations and calling conventions. The following choices
apply to interpreters as well as source-generating and ahead-of-time compilers.

### Direct translation of KLambda

KLambda primitives and special forms are natural candidates for translation to
the closest host construct. This avoids routing fundamental operations through
a generic Shen dispatcher.

"Closest" refers to executed work, not merely spelling. A host construct that
uses truthiness, truncating division, unchecked wraparound, a different string
indexing unit, or a different error convention still needs a small adapter or
an explicit check to implement the KLambda operation.

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

Host exceptions need a Shen-compatible boundary: `simple-error`, errors raised
by primitives, and values passed to `trap-error` all participate in the same
observable error semantics.

### Function application and currying

Most calls generated by the Shen kernel name a known function and supply its
full arity. The host's ordinary multi-argument calling convention handles these
calls without the overhead of general currying.

Currying every call into a chain of one-argument calls creates unnecessary
closures and intermediate calls and can interfere with tail-call optimisation.
A typical application strategy therefore distinguishes these cases:

* a known function with all arguments present becomes a direct call;
* a real partial application creates a closure;
* over-application calls the known saturated part and applies the remaining
  arguments to its result; and
* the fully dynamic apply path remains for cases where the function or effective
  arity is not known.

Calls through higher-order arguments still require full Shen application
semantics. Direct calls are simplest for sealed definitions. Open definitions
need an indirection or invalidation strategy so that first-class functions,
partial and over-application, and redefinition—including an arity change—retain
their Shen behaviour.

#### Function metadata

The kernel maintains arity and lambda-form information specifically to support
these distinctions. Cheap access to that metadata benefits every dynamic call,
and definitions and redefinitions need to keep it current.

The standard kernel updates this information through `update-lambda-table` and
`shen.update-lambdatable`. A host function object, side table, or interpreter
entry can represent the same facts; what matters is that dynamic application
and redefinition observe them consistently.

### Sealed implementation code

Kernel and implementation-owned code can be compiled as a closed unit. Calls
between definitions in that unit then have fixed targets and known arities, so
they do not need a global function lookup, redefinition check, arity dispatch,
or general currying path when the call is saturated. Higher-order calls and
real partial applications still require their normal Shen semantics.

Shen/Scheme uses this arrangement for its kernel. The generated kernel and
runtime definitions are compiled together inside the `(shen-scheme runtime)`
library, and calls within that library resolve to its own bindings. Port
overrides selected while building the library replace the corresponding
portable definitions before it is sealed. Where redefinition is permitted, a
later definition visible to user code can replace or shadow the exported name,
but it does not rewrite the kernel's internal call graph. Such a runtime
override affects open calls made by user code, not calls already bound inside
the kernel.

An interpreter can use the same distinction without compiling a closed library.
Kernel calls can resolve to private implementation entries or fixed indices,
while calls from open user code continue through the namespace in which
redefinition is visible. This removes repeated lookup and redefinition handling
from internal kernel calls for the same reason that sealing helps compiled code.

This boundary is observable and belongs in a port's documentation. Kernel,
primitive, and implementation-owned definitions are natural candidates for a
sealed unit, whereas ordinary user code normally retains Shen's redefinition
behaviour. Some ports may expose both open and sealed compilation modes.

### Tail calls

Shen and KLambda rely heavily on tail recursion. A host with proper tail calls,
such as Scheme, can normally use its ordinary call mechanism. On a host without
them, translating tail calls as ordinary recursion eventually exhausts the host
stack in kernel functions that are intended to run in constant space.

Such ports need an iterative representation for tail calls. Common choices
include:

* a loop for self-tail recursion;
* a trampoline for general calls between functions;
* an interpreter loop that replaces the current expression and environment;
  or
* a compiler transformation that emits jumps or state-machine transitions.

The same issue applies to multi-argument functions; forcing all calls through
one-argument currying can hide the tail position behind closure calls and defeat
the host's optimiser. Shen/Scheme relies on Chez
Scheme's proper tail calls, including the calls to local failure continuations
produced by the S-kernel's pattern factorisation.

## Static knowledge and specialisation

Information already present in an expression can often select a cheaper but
equivalent operation. These transformations complement efficient
representations and kernel overrides; they do not depend on one particular
host-language compilation model.

### Expand dynamic code before loading

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

The distributed KLambda is generated with `expand-dynamic` enabled. Applying
the same expansion to additional Shen sources exposes their declarations and
other supported dynamic forms to equivalent static optimisation. This is a
staging optimisation rather than a semantic change; genuinely dynamic effects
remain in runtime initialisation order.

### Equality

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

Identity equality is not a replacement for structural equality in the general
case. Independently constructed equal lists, strings, tuples, and vectors still
compare as required by Shen.

### Exception-based absence checks

Portable Shen sometimes uses `trap-error` to ask whether an operation would
fail. Exception handling is expensive on many hosts, including common Python,
Ruby, Java, and JavaScript implementations.

When a recognised kernel expression uses `trap-error` only to return a default,
a direct presence or bounds check can be equivalent and much cheaper. Examples
include:

* `(value Symbol)` — test whether the global is bound;
* `(get Object Property Dictionary)` — test whether the property exists;
* `(<-address Vector Index)` — test the raw vector bounds; and
* `(<-vector Vector Index)` — test the Shen-vector bounds and whether the slot
  contains `(fail)`.

This is a specialisation of a recognised expression, not a general replacement
for `trap-error`. It is valid only when other errors, use of the error value,
types, and evaluation order remain unchanged.

Predicates such as `vector?`, `tuple?`, and `shen.pvar?` often reduce further to
direct representation tests, avoiding both the accessor and the exception.

### Pattern matching

The KLambda produced for several pattern clauses can repeat the same type tests,
selectors, and failure paths. The S-kernel factorises this code, although the
representation has changed between kernel generations.

#### Explicit helper procedures through S36

S-kernel releases through 36 generated additional `defun`s for shared failure
branches. In schematic form, the parent called a generated helper with all the
state used by the branch:

```shen
[defun Parent [X Y] ... [Failure X Y]]
[defun Failure [X Y] Else]
```

Shen/Scheme collected those generated definitions while compiling the parent
and emitted an internal Scheme procedure:

```scheme
(define (parent x y)
  (define (failure x y)
    ;; translated Else expression using x and y
    else)
  ...
  (failure x y))
```

Because `failure` has no free variables, does not escape, and has statically
known call sites, even Chez versions without consistent procedure lifting can
compile the tail calls as direct jumps without allocating a closure.

#### Capturing continuations from S37

From S37, the factoriser instead represents a shared failure branch
approximately as:

```shen
[let Go [freeze Else]
  [if Test Then [thaw Go]]]
```

A direct Shen/Scheme translation turns this into the equivalent of:

```scheme
(let ([go (lambda ()
            ;; translated Else expression capturing x and y
            else)])
  (if test then (go)))
```

Here `go` is a zero-argument procedure that captures any values used by `else`.
[Chez 10.0](https://cisco.github.io/ChezScheme/release_notes/v10.0/release_notes.html)
introduced consistent procedure lifting for local procedures with known call
sites and immutable captured values. It can therefore transform the effective
shape into something equivalent to:

```scheme
(let ([go (lambda (x y)
            ;; the same translated Else expression
            else)])
  (if test then (go x y)))
```

This recovers the important property of the older factorisation: captured state
becomes ordinary arguments and the tail call can become a jump. Older Chez
versions, and other hosts without equivalent closure optimisation, can obtain
the same result by lambda-lifting the continuation explicitly. Passing every
value in scope is conservative; passing only its free variables reduces
argument traffic.

#### Labels, interpreter continuations, and selectors

A backend with labels can express the same shared failure path without a local
procedure:

```text
if not test_1: goto failure
...
if not test_2: goto failure
...
goto done

failure:
    ... else, using x and y from the surrounding frame ...

done:
```

An interpreter can represent `failure` as an internal program location plus the
existing environment. These are different implementations of the same useful
facts: the continuation does not escape, its destination is known, its calls
are in tail position, and it does not require general function application or
a freshly allocated closure.

By the ordinary KLambda stage, source patterns have already become predicates,
equality checks, and selectors. Their cost then follows from the port's chosen
representations:

* list tests and selectors become empty/pair tests and direct head/tail access;
* tuple tests and selectors become one tag test and direct field reads;
* vector tests reuse representation and length information where safe; and
* string tests use host length, indexing, or prefix operations.

The factorised code exposes repeated tests, selectors, and failure paths. A port
integrated earlier in the Shen compiler can make equivalent choices before
KLambda is emitted; a later implementation can still reuse a successful shape
test rather than immediately repeating it through a generic accessor.

### Literal global access

When the name in `value` or `set` is a literal, a source-generating port can
often refer directly to a host global cell. An interpreter can resolve or cache
the corresponding binding instead of repeating a symbol-table lookup. Computed
names still require the general symbol-to-binding path.

Shen/Scheme uses direct host bindings for a set of frequently accessed kernel
globals. This avoids a dictionary lookup while retaining the dynamic path for
computed names.

## Kernel functions worth overriding

The following functions are good general-purpose override targets. Some can be
handled by compiler translation instead; what matters is that the portable Shen
algorithm does not remain on the common path.

### Hashing

#### `hash`

The portable implementation converts a value to a printable form, explodes it,
maps characters to numbers, combines them recursively, and implements modulus
in Shen. It is intentionally portable but much slower than a host hash.

A host structural hash can replace this work when it is consistent with the
equality used for dictionary keys. Equal Shen values produce the same hash for
the same bound. The function has type `A --> number --> number`; for a positive
`Bound`, its result is a non-negative integer no greater than `Bound`.

Replacing `hash` alone can substantially improve the portable dictionary even
when the rest of that implementation is retained.

### Dictionaries

The portable dictionary is an absolute vector of buckets, with association
lists used for collisions. Most hosts provide a substantially better hash table
or map implementation.

The dictionary family is best treated as a unit:

* `shen.dict` — construct a dictionary from a positive integer size, with the
  expected error for invalid sizes. The size is an initial capacity hint and
  may be ignored if the host has no equivalent;
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

The callback passed to `shen.dict-fold` remains a Shen function value with the
argument order `Key`, `Value`, `Accumulator`; a native map does not turn it into
an ordinary host callback with different application semantics.

Dictionary key semantics are significant because structurally equal Shen values
are interchangeable keys. A host table based only on identity is therefore not
sufficient; hosts that cannot directly hash lists or vectors need Shen-aware
hashing and equality around the native table.

Dictionaries are especially important because the kernel uses them internally
for properties and metadata. Improving them speeds up compilation, loading,
typechecking, and user dictionary operations.

### Booleans and numeric predicates

#### `boolean?`

A direct host boolean or tag test avoids the two-clause portable recogniser.

#### `not`

Host boolean negation is sufficient when it preserves Shen's requirement that
conditional values are booleans.

#### `integer?`

The portable arithmetic test can usually become a direct test of Shen
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

Checking the interned symbol name directly avoids allocating a new string or
scanning the entire name on every call. This matters for compilation speed, not
for ordinary program execution unless that program invokes `variable?` or
Shen's compilation machinery. The direct check still has to preserve the
portable result for values outside the normal compiler path.

#### `symbol?`

A host symbol tag or dedicated symbol representation makes the initial test
cheap; Shen's symbol-name validity rules still determine the result. Booleans
remain distinct from symbols when represented by host booleans.

#### `shen.analyse-symbol?` and `shen.analyse-variable?`

The portable versions recursively split the string into one-character pieces.
A single indexed scan over the host string avoids many allocations and calls.

### Reader character operations

#### `shen.digit?` or `shen.numbyte?`

Kernel versions use one of these names for the reader's digit test. A direct
character test or numeric range check replaces several Shen calls.

#### `shen.byte->digit`

Its host implementation is normally a subtraction of the code for `0`.

These operations are tiny but occur repeatedly while reading numbers and source
text. They improve parsing and source-loading speed rather than the execution of
ordinary code after it has been loaded.

### Prolog variables

#### `shen.pvar?`

The portable definition tests for an absolute vector, attempts to read its tag
under `trap-error`, and compares the tag with `pvar`. A direct type or tag test
removes that exception-based path when the port controls the representation.

This predicate is extremely frequent in Prolog execution and typechecking. A
cheap `shen.pvar?` also improves the Shen implementations of `shen.lazyderef`,
`shen.deref`, `shen.lzy=`, and `shen.lzy=!` without requiring those algorithms
to be rewritten in the host language. Its effect is therefore concentrated in
Prolog, typechecking, and compilation workloads rather than general arithmetic
or list-processing programs.

A specialised Prolog-variable representation can go further, particularly for
dereferencing and binding chains. Its benefit and complexity extend across the
whole group of functions that construct and inspect Prolog variables, rather
than `shen.pvar?` alone.

### Tuples

#### `@p`, `fst`, `snd`, and `tuple?`

A fixed-size host record, tuple object, or directly initialised tagged vector
turns the accessors into field or slot reads rather than general Shen vector
operations.

Tuple construction and matching occur frequently in compiler and type-system
code, so avoiding general vector initialisation and repeated stores can have a
visible effect.

### Vectors

#### `vector`

The portable definition allocates an absolute vector and recursively fills
every element with `(fail)`. A host filled-array constructor or host-level loop
performs the same work with much less dispatch.

#### `vector?`, `limit`, `vector->`, and `<-vector`

These are worth direct implementations when the port has a dedicated vector
representation or when the portable definitions cause exception handling and
several generic calls per access. Their semantics include the special treatment
of index zero, uninitialised elements, bounds, return values, and errors.

### String helpers

#### `hdstr`

Direct access to the first character can avoid another general Shen call when
function-call overhead is significant.

The underlying `cn`, `pos`, and `tlstr` operations are KLambda primitives, not
kernel overrides. Their performance still matters because the portable reader
and symbol functions build other operations from them. If `hdstr` compiles to a
direct `pos` operation with negligible call overhead, a separate override is
unnecessary.

### File and stream I/O

#### `read-file-as-bytelist`

The portable implementation calls `read-byte` once per byte and builds a
reversed list. Whole-file or block input removes most of that per-byte overhead
before the required Shen list is constructed.

#### `read-file-as-string`

The portable implementation reads one byte at a time and repeatedly appends to
a growing string. Whole-file or buffered host input avoids the resulting
quadratic copying while retaining the kernel's encoding and path semantics.

#### `read-char-code` and `read-file-as-charlist`

Some older kernels also define these character-oriented functions. Where they
are present, bulk host input has the same advantage over character-at-a-time
Shen recursion.

#### `pr`

Buffered host string output avoids writing one byte at a time. Its observable
behaviour still includes `*hush*`, stream mode, flushing, and the return value.

### Property access

The kernel implements `get`, `put`, and `unput` over dictionaries containing
association lists. A host dictionary override removes much of their cost before
any separate property-operation optimisation is considered.

If property access remains important, a port may provide a more direct
implementation of:

* `get`;
* `put`; and
* `unput`.

Missing-property errors, return values, and the relationship with
`*property-vector*` are observable parts of these operations. Their use by both
Shen programs and the compiler makes a purely internal change safer than a
different public data model.

### Other possible kernel overrides

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

Their host equivalents are useful only when they retain the kernel version's
structural equality, error, and callback-application semantics.

`explode` and string/list conversion helpers may also be worthwhile on hosts
that can traverse a string directly. Their main effect is normally on reading,
printing, symbol processing, and compilation rather than steady-state numeric
or data-structure code.

## Shen/Scheme optimisation summary

Shen/Scheme provides a practical baseline for other ports. Its literal kernel
overrides are distinct from the work performed by its compiler.

### Kernel overrides

Excluding port-specific stream and error-display behaviour, Shen/Scheme
replaces:

* `hash`;
* `not`, `boolean?`, and `integer?`;
* `variable?` (for source-processing and compilation throughput), `symbol?`,
  and `shen.analyse-symbol?`;
* `shen.pvar?`;
* `shen.numbyte?` on older kernels and `shen.byte->digit`; the current
  `shen.digit?` is already inexpensive when its numeric comparisons translate
  directly;
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
* resolves literal `intern` expressions while compiling;
* specialises equality from literal and type information;
* compiles selected literal globals as direct bindings;
* replaces safe kernel accessor/`trap-error` patterns with checked operations;
* compiles the kernel and runtime as one closed library, keeping internal calls
  bound to the implementation definitions even when a user-visible name is
  later replaced or shadowed;
* preserves the S-kernel's factorised failure continuations as non-escaping
  local procedures, allowing Chez to compile their calls as direct jumps
  without allocating closures; and
* consumes the statically expanded kernel produced by `expand-dynamic`, rather
  than reconstructing known declarations and lambda forms at startup.

Not every port needs a literal override for every function on this list. For
example, the portable definition of `hdstr` is already cheap if it reaches a
direct host `pos` operation, and a host compiler may inline other small Shen
predicates. The relevant question is whether a common operation reaches an
efficient host implementation without repeated allocation, generic dispatch,
string decomposition, or exception handling.

## Benchmarks

The repository includes a portable benchmark suite in
[`benchmarks/`](../benchmarks/), documented in the
[`benchmarks` guide](benchmarks.md). Its entry point is
[`benchmarks/benchmarks.shen`](../benchmarks/benchmarks.shen), which can be run
as a script or loaded and invoked through `run-all-benchmarks`.

The suite contains focused measurements for data operations, control flow,
equality, pattern matching, and Shen compilation. Ports can use these cases to
find expensive primitives and kernel paths, compare alternative
representations or overrides, and check whether an optimisation affects the
workload it is intended to improve. Benchmark results complement rather than
replace the test suite: a faster result is useful only when the port continues
to implement the same Shen behaviour.

## Semantic requirements

Overrides and compiler specialisations remain observationally equivalent to the
kernel definitions. Important invariants include:

* structural equality and compatible dictionary hashing;
* the distinction between booleans, symbols, strings, and numbers;
* boolean validation rather than host truthiness;
* numeric division, comparison, and overflow behaviour;
* exact success values and required errors;
* Shen error values and handling behaviour;
* left-to-right evaluation where it is observable;
* short-circuit behaviour;
* proper and improper list behaviour;
* function redefinition, arity changes, and first-class functions;
* the documented boundary between sealed implementation calls and open
  user-visible bindings;
* partial and over-application;
* tail calls required by recursive kernel code; and
* the vector, tuple, dictionary, and Prolog-variable behaviour expected by other
  kernel functions.

Portable Shen code defines the behaviour. A good override removes work that the
host can perform more directly; it does not define a different language.

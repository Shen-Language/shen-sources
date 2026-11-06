# expand-dynamic

This exstention takes care of pre-evaluating some code ahead of
time so that the runtime doesn't have to do it during startup.

Most ports should benefit from this, in particular, ports that
implement an interpreter, and ports on which `eval-kl` is expensive.

## How to use

This extension is enabled by default when generating the `.kl` files
from the Shen sources, but ports that include their own `.shen` files
may want to process them too.

The useful functions are:

### shen.x.expand-dynamic.initialise

Has to be invoked first to set up the global state used by the following
functions. Takes no inputs.

### shen.x.expand-dynamic.expand-dynamic

Useful to pre-expand some code that may be expensive to execute
at load time, like `declare` expressions.

**Input:** A list of top-level expressions.

**Output:** A new list of top-level expresions, with `declare`
expresions pre-expanded.

### shen.x.expand-dynamic.split-defuns

Useful to extract all top-level expressions that are not defuns
so that they can all be put into a single initialization function.

**Input:** A list of top-level expresions.

**Output:** A tuple, with all the `defun`s as the first element,
and everything else as the second element.

### shen.x.expand-dynamic.wrap-in-defun

Useful to generate a function with the result of
`shen.x.expand-dynamic.split-defuns`

**Input:** A function name, a list of parameters and a list of expressions
to wrap.

**Output:** The input expressions, converted into a single expression with `do`,
and wrapped into a defun of the given name.

### shen.x.expand-dynamic.expand-declare/checked

Pre-expand one top-level KLambda declaration while retaining runtime
validation. This is the path used by the stlib builder.

**Input:** One top-level KLambda expression.

**Output:** A literal `declare` is replaced by a call to the kernel's
`shen.declare-with-signature`, carrying a factory for the precompiled signature
function. Other expressions, including computed signatures, are unchanged.

The factory is invoked after the usual type rectification and variancy check.
The declaration still returns its name. Its generated signature function uses
the ordinary Prolog allocation and cleanup code, including fresh variables on
each call. There is no limit on the number of type variables.

Literal signatures are the `cons`/`protect` expressions produced by the
compiler. Apply this function before wrapping initializer expressions in a
`defun`; it does not analyze lexical scopes in arbitrary function bodies.
Rebuild the kernel and stlib together: the checked expansion uses the new
kernel helper in `types.kl`.

The existing trusted kernel expansion continues to omit runtime validation.
Use the checked path for metadata that must preserve source-loading checks.

See [precompiled startup signatures](../startup-signatures.md) for the
stlib integration and rebuild requirements.

### shen.x.expand-dynamic.expand-initializer

Expand one trusted initializer expression or `defun` in standard KLambda.

**Input:** The expression and a list of function names provided by the build.

**Output:** Literal declarations use checked, precompiled signatures. Literal
`update-lambda-table` calls for known functions carry a precompiled adapter
factory and a `shen.precompiled-function?` check. Unknown functions and computed
registrations retain their original path.

The pass tracks `defun`, `lambda`, and `let` bindings and handles `cond` clauses
as expressions. Quoted data and Scheme escape forms are opaque. Declarations
with lexical signature dependencies or shadowed helper names remain dynamic.
Apply it before lowering KL into a host language; it is not a walker for
arbitrary host syntax or a general optimization of user code. Reapplying it to
an expanded arity registration leaves the registration unchanged.

The kernel and stlib builders use this pass. Port builders can use it for
port-specific initializer code as well.

### Compiled-adapter binding policy

`shen.precompiled-function?` defaults to `false`. This keeps runtime lookup,
forward references, and function redefinition intact on an unconfigured port.
A port may override or lower this hook when it can prove that the emitted
adapter has the same function-binding behavior as ordinary runtime compilation.

For example, a host with immutable imported functions and mutable top-level
shadows must verify that the visible binding is the original immutable one.
Hosts whose compiled named calls already follow the required mutable binding
can opt in for those calls. The hook must return a Boolean; deciding only from
an arity or a function name is insufficient on hosts that capture bindings.

The portable `shen.update-lambda-table/precompiled` helper installs arity and
lambda-form metadata when the check succeeds. Otherwise it calls ordinary
`update-lambda-table` without invoking the supplied adapter factory. Ports do
not need their own metadata installer or adapter generator.

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

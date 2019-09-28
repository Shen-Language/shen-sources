# factorise-defun

This extension implements a transformation for functions that
do pattern matching, that can in some cases (like when the
patterns go deep into structures, or when the function has
too many similar patterns) lead to big performance improvements.

The transformation is not a complete one, the port has to take
care of the final step and convert the new constructs generated
by the transformation into code that performs well when
executed by the underlying platform.

Not all platforms may be able to express that code in
a way that makes the transformed code more efficient than
the original one. In such cases, this transformation should
not be used.

## The problem

The way Shen compiles pattern matching code to Klambda can result
in too many repeated tests and selectors, which is suboptimal.
Since there isn't a reliable way for Shen to solve this portably,
the task is deferred to the port.

The first step is to process the `cond` construct at the root
of the function definition, and rebuild it as an if-else
tree, with all the duplicated tests merged into one.
But this results in code duplication, because this restructuring
of the code forces the bodies of the false branches to be
duplicated.

The solution to this is to remove the duplication by binding
a continuation using this code, and to generate a jump to this
continuation in the false branches. This requires that the underlying
platform supports this efficiently through direct jumps, like for
example with GOTO, of zero-overhead tail-calls.

The other part of the optimization involves finding duplicate
instances of selectors, binding the result of the selector
to a variable on the outer scope, and replacing all instances
of such selector with a reference to this variable.

## How to use

The transformation is performed by calling the `shen.x.factorise-cond.factorise-defun`
passing it a `defun` expression.

The return value will be the transformed defun, on which these two new special
forms will show up:

`(%%let-label [LabelName | LabelVars] LabelBody CodeBody)`

and

`(%%goto-label %%labelNNNN LabelVars)`
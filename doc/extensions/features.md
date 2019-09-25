# Features

This extension lets a port define a list of "features" that programs
and libraries can query to provide alternative implementations of
their functionality. This is done through a `cond`-like construct
that conditionally expands to different code blocks depending
on the presence (or lack) of specific features, allowing for easier
authoring of code portable across multiple Shen implementations.

It is highly recommended for ports to include this one extension in
particular.

## How to use

Ports that want to support conditional expansion based on features
have to call the initialization function `shen.x.features.initialise`
with a list of symbols representing the features it provides.
As a minimum, the list should contain at least one symbol
that uniquely identifies the port. The return value is the previous
list of features.

Shen/CL, in it's SBCL version for example could include these
symbols: `[shen/cl shen/cl.sbcl]`, while the CLisp version would
include these: `[shen/cl shen/cl.clisp]`.
Shen/Scheme: `[shen/scheme shen/scheme.chez]`.

In addition to this, it is a good idea to also include a symbol
for the operating system:

- `windows` for Windows.
- `linux` for Linux.
- `osx` for OS X.

Adding a new feature to the list (let's say, provided by a library),
is done by calling the `shen.x.features.add` function. It takes
a single input, a symbol representing the feature, and returns
the list of features as it was before the new addition.

When none of the clause matches, an error will be raised. For
the expansion of code when none of the clause matches, a `true`
clause needs to be added at the end.

Examples:

    \\ Initialise to the list containing features `feat1` and `feat2`
    (shen.x.features.initialise [feat1 feat2])

    (shen.x.features.cond-expand
     feat1 (pr "has feat1c#10;") \\ prints this
     feat2 (pr "has feat2c#10;"))

    (shen.x.features.cond-expand
     no-feat (pr "has no-featc#10;")
     true (pr "doesn't have no-featc#10;")) \\ prints this

    (shen.x.features.cond-expand
     (and feat1 feat2) (pr "has feat1 and feat2c#10;") \\ prints this
     true (pr "doesn't have both feat1 and feat2c#10;"))

    (shen.x.features.cond-expand
     (or no-feat feat1 feat2) (pr "has no-feat or feat1 or feat2c#10;") \\ prints this
     true skip)

    (shen.x.features.cond-expand
     (not no-feat) (pr "doesn't have no-featc#10;") \\ prints this
     no-feat (pr "has no-featc#10;")
     true skip)

    (shen.x.features.cond-expand
     no-feat (pr "has no-featc#10;")) \\ raises error

    \\ A library providing `no-feat` is loaded, and it adds it to the list
    (shen.x.features.add no-feat)

    (shen.x.features.cond-expand
     no-feat (pr "has no-featc#10;")) \\ prints this

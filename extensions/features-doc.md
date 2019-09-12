# Features

This extension lets a port define a list of "features" it supports. It
provides a macro that adds support for conditional expansion depending
on the presence (or lack) of specific features, allowing for easier
authoring of code portable across multiple Shen implementations.

It is highly recommended for ports to include this one extension in
particular.

## How to use

Ports that want to support conditional expansion based on features
have to call the initialization function `shen/features.initialize`
with a list of symbols representing the features it provides.
As a minimum, the list should contain at least one symbol
that uniquely identifies the port.

Shen/CL, in it's SBCL version for example could include these symbols: `[shen/cl shen/sbcl]`.
Shen/Scheme: `[shen/scheme shen/chez]`

Examples:

    (shen/features.cond-expand
     feat1 (pr "has feat1c#10;") prints this
     feat2 (pr "has feat2c#10;"))

    (shen/features.cond-expand
     no-feat (pr "has no-featc#10;")
     true (pr "doesn't have no-featc#10;")) prints this

    (shen/features.cond-expand
     (and feat1 feat2) (pr "has feat1 and feat2c#10;") prints this
     true (pr "doesn't have both feat1 and feat2c#10;"))

    (shen/features.cond-expand
     (or no-feat feat1 feat2) (pr "has no-feat or feat1 or feat2c#10;") prints this
     true skip)

    (shen/features.cond-expand
     (not no-feat) (pr "doesn't have no-featc#10;") prints this
     no-feat (pr "has no-featc#10;")
     true skip)

    (shen/features.cond-expand
     no-feat (pr "has no-featc#10;")) raises error

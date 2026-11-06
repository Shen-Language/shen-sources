# Precompiled startup signatures

`declare` normally constructs a Prolog signature function through `eval-kl`.
The stlib builder uses `expand-declare/checked` to generate functions for
literal signatures at build time, avoiding their compilation during startup.
Computed signatures continue to use ordinary dynamic declarations.

The generated initializer calls `shen.declare-with-signature` with a factory
for the precompiled function. This helper performs type rectification and the
variancy check before invoking the factory and installing its result. It
preserves declaration results and warnings. Generated signature functions
retain ordinary Prolog variable allocation, sharing, and cleanup on each call.

The checked expansion applies to top-level KLambda expressions before they
are wrapped in initializer functions. The existing trusted kernel expansion
continues to omit runtime declaration checks.

Ports must rebuild the kernel and stlib together: the generated initializer
depends on the helper supplied by the kernel. No new host primitive is needed.
This optimization does not remove runtime compilation for other dynamic code.

See [expand-dynamic](extensions/expand-dynamic.md) for the extension API.

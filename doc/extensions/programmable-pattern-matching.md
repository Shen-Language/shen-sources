# Programmable pattern matching

This extension provides hooks to augment Shen's compiler compilation of
pattern matching in functions, allowing for new patterns to be matched
over in addition to what is supported natively.

## How to use

Before using this extension, it has to be initialised (only once) by calling the 0-place `shen.x.programmable-pattern-matching.initialise` function:

```shen
\\ Ideally the port already comes with this extension loaded
\\ and initialised, but if it is being use as a library,
\\ then this step is required
(shen.x.programmable-pattern-matching.initialise)
```

Supporting new patterns is done by the definition and registration of
"pattern handler" functions.

Pattern handling functions take as input 4 arguments:

1. An object that represents a reference to the value being matched over. It is used when building expressions that have to reference the object.
2. A 1-place function that registers the expression that will be used to test if the value being matched over is of the kind of value the pattern can handle. The argument to this function is a sexp that represents the expression to be used.
3. A 2-place function that binds a vaiable in the pattern to an expression that will obtain its value. It takes as input the variable and the expression it will be bound to.
4. The pattern that is being compiled.

If the function cannot handle this pattern, it *MUST* return `(fail)`, so that another
pattern handler can be tried.

The following example shows how pattern matching over lists and tuples could
be implemented if the compiler didn't support it already:

```shen
(define cons-pattern-handler
  \\ 1    2     3      4
  Self AddTest Bind [cons H T]
  -> (do (AddTest [cons? Self]) \\ (cons? X) checks if it is a cons
         (Bind H [hd Self])     \\ (hd X) gets you H
         (Bind T [tl Self]))    \\ (tl X) gets you T
  \\ The function *MUST* return (fail) if it will not handle this pattern
  _ _ _ _ -> (fail))

(define tuple-pattern-handler
  \\ 1     2     3      4
  Self AddTest Bind [@p Fst Snd]
  -> (do (AddTest [tuple? Self]) \\ (tuple? X) checks if it is a cons
         (Bind Fst [fst Self])   \\ (fst X) gets you Fst
         (Bind Snd [snd Self]))  \\ (snd X) gets you Snd
  \\ The function *MUST* return (fail) if it will not handle this pattern
  _ _ _ _ -> (fail))
```

Once a pattern handler function has been defined, it can be registered and enabled by passing its name to the `shen.x.programmable-pattern-matching.register-handler` function:

```shen
(shen.x.programmable-pattern-matching.register-handler cons-pattern-handler)
(shen.x.programmable-pattern-matching.register-handler tuple-pattern-handler)
```

A handler can be disabled by passing its name to the `shen.x.programmable-pattern-matching.unregister-handler` function:

```shen
(shen.x.programmable-pattern-matching.unregister-handler cons-pattern-handler)
(shen.x.programmable-pattern-matching.unregister-handler tuple-pattern-handler)
```

### Notes:

- It is not mandatory to bind all the variables in the pattern, some of the inputs may be used by the pattern handler to decide how such pattern should be compiled.
- It is not mandatory to register a test expression, but in such cases matching of values with such patterns will always succeed. Such kind of patterns are only safe to use in typed functions.
- The order of calling the `AddTest` and `Bind` functions doesn't matter.

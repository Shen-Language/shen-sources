# Shen doc 19 - The Official Shen Standard

## Acknowledgements

This document benefited from discussions with Vasil Diadov, Kian Wilcox, Carl Shapiro, Willi Riha and Brian Spilsbury.

## Shen and Qi

Shen was directly derived from Qi. Qi is a hypermodern functional language that offers many features not currently available under other functional platforms.

Qi was written solely to run under Common Lisp. The motive for Shen came from the observation that the implementation of Qi used only 15% of the system functions described in *Common Lisp: the Language*.

The Shen mission was to develop an ultra-portable version of Qi that can run under a wide variety of platforms and which incorporates missing features in Qi such as streams. This approach involved rewriting and redesigning Qi to fit within the smallest feasible instruction set.

## Kl

The means of achieving this involves developing a small fast Lisp called Kl which is rich enough to encode Qi, but small enough to be easily mapped into other platforms or implemented as a standalone.

In terms of design, Kl reflects the following design criteria.

1. It should be powerful enough to express Qi.
2. It should be minimal, with very few primitives and so easy to implement. No macros, optional arguments etc. because Shen can support all these things already.
3. It is not designed as a language to compete against Common Lisp; deliberately. It is a Lisp assembly language for a higher level language. The minimalism is deliberate.
4. It should be clean; i.e. it should support partial applications, lexical scoping and tail recursion optimisation.
5. It should be fast; it should support type declarations.

Some comparable small Lisps to Kl are [PicoLisp](http://software-lab.de/radical.pdf), [FemtoLisp](http://code.google.com/p/femtolisp/), [TinyScheme](http://tinyscheme.sourceforge.net/) and [SmallLisp](http://www.uv.es/tung/smlisp/smlisp-ref.pdf).

Unlike Common Lisp, Kl is very portable over different platforms. In place of Common Lisp's 1150 pages of specification, Kl requires only 46 system functions. It is much easier to develop a stand-alone implementation of Kl than to build a complete version of CL. Even more significantly, it is possible to map Kl into popular existing platforms such as Clojure, Python as well as Common Lisp.

The implementation, Shen, attached to this document runs Qi on this reduced instruction set and, in terms of primitives required, has nearly 1/3 of the footprint of Qi II. **Shen is entirely defined in Kl**. Hence Shen is no more difficult to port than Kl itself. All that needs to be done is to map the simple reduced instruction set of Kl into the chosen platform. Our distribution in fact contains one such mapping - of Kl to Common Lisp; and this is done in 250 lines of code.

Kl misses many of the features of bigger Lisps (like macros) because Shen effectively incorporates many of these features. Even LIST and QUOTE are missing from Kl because they are not needed for Shen and Qi has never needed or missed them. Similarly we do not impose a comment convention on Kl because we do not consider that people need to or should write in Kl. The emphasis is on devising an absolutely efficient minimal set needed to port Qi which is easy for people to code in other languages.

However anybody who implements Kl, and wants to write directly in this notation, can add extra features to their implementation to Kl. This does not affect the standard; just as a CL which includes (e.g.) threads does not cease to be a CL even though it incorporates a non-standard feature. **However the systems code for Shen will not rely on extra features outside the standard.** It is intentionally minimal.

## The Motivation for Shen

The development of Shen was motivated by the desire to use Qi outside the ambit of Common Lisp. Though Common Lisp is a very powerful language, it's usage and libraries do not compare well with other languages such as Python. It is, for example, difficult to find providers who support Common Lisp, though many providers will offer Python as part of their services. Hence Shen was devised as the solution. Shen is Qi packaged to run under many platforms.

People have asked why Shen is called 'Shen' . There is a deep reason.

The words 'qi' and 'shen' are part of the Taoist vocabulary. The concept of shen belongs to a triad; jing, qi, shen. They represent stages in the refinement of energy. Jing is the sexual essence; it is the most hormonal and least refined of the life energies but important in the alchemical transformation of our energy into spirit. Qi is better known as life-force or vitality, which accumulates when jing is conserved and our kidney and natal energy is nourished. Shen is the spiritual energy that shows in shining eyes and an alert mind. In Taoist alchemy, the transmutation of jing into qi, and qi into shen is the nature of the highest Taoist practice which leads to seperation of the shen from the corporeal form, immortality and liberation from the wheel of life and death. For this reason shen is translated as 'spirit'

In terms of this process, Qi was nourished within the physical body of a specific platform which was Common Lisp. Having nurtured it to become strong, the goal must be now to seperate Qi from conceptual dependence on Common Lisp to be able to exist as a spirit that can run on any LISP. Hence the process of our work mirrors the ancient Taoist alchemists.

## Future Development of Shen

Shen is that of a RISC version of Qi II with extensions to incorporate streams; it is Qi running on a reduced instruction set and that reduced instruction set defines (much of) Kl. However this release and the accompanying language definition are by no means the final word. We are actively developing standards for other aspects of a modern programming language beyond what exists here.

The release of Shen follows this convention: all spec changes increment the leading digit; all patches increment the number following the point.

## The Basic Types in Shen and Kl

There are 12 basic types in Shen.

1. symbols - `abc`, `hi-there`, `The_browncow_jumped_over_the_moon`
2. strings - any characters enclosed in `"`s
3. numbers - all objects closed under `+`, `/`, `-`, `*` 
4. booleans - `true`, `false`
5. streams
6. exceptions 
7. vectors
8. functions
9. lists
10. tuples
11. closures
12. continuations

Note that the last two categories can merge depending on the platform.

Any symbol, string, number or boolean is an **atom**. Booleans are `true` and `false`. Atoms are self-evaluating. As in Qi, booleans are not counted as symbols (in Shen they have their own type). All symbols apart from those used to apply functions are treated as implicitly quoted.

The type system of Shen differs from Qi II in not placing variables and symbols into different types. This arises mainly from dropping rule closures that appeared in Qi II. The type stream is now inbuilt since several primitives use this concept.

## The Primitive Functions of Kl

The following set represents the set of 46 primitive functions which Shen requires and which are used in Kl. All other functions are included in the Shen sources. The CL definitions are given to explain the semantics of these functions. Note in some cases these primitives can be reduced still further (e.g `and` in terms of `if` etc). In fact lambda alone is sufficient, but impractical. The instruction set is therefore a balance between economy of primitives (easy to implement but inefficient in execution) and practicality (more difficult to implement but possibly faster).

Kl uses strict applicative order evaluation except for the boolean operations etc. which follow the usual pattern. NIL is just a symbol with no special status. `()` denotes the empty list.

| Function/Form | Description | Type |
|---------------|-------------|------|
| if | boolean test | `boolean --> A --> A --> A` |
| and | boolean and | `boolean --> boolean --> boolean` |
| or | boolean or | `boolean --> boolean --> boolean` |
| cond | case form | |
| intern | maps a string containing a symbol to a symbol | `string --> symbol` |
| pos | given a natural number 0 ...n and a string S returns the nth unit string in S | string --> number --> string |
| tlstr | returns all but the first unit string of a string | string --> string |
| cn | concatenates two strings | string --> string --> string |
| str | maps any atom to a string | A --> string |
| string? | test for strings | A --> boolean |
| n->string | maps a code point in decimal to the corresponding unit string | number --> string |
| string->n | maps a unit string to the corresponding decimal | string --> number |
| set | assigns a value to a symbol | `(value X) : A;` `X : symbol;` `Y : A;` `______` `(set X Y) : A;` |
| value | retrieves the value of a symbol |
| simple-error | prints an exception | string --> A |
| trap-error | evaluates its first argument A; if it is not an exception returns the normal form, returns A else applies its second argument to the  |exception	A --> (exception --> A) --> A |
| error-to-string | maps an exception to a string | exception --> string |
| cons | add an element to the front of a list | A --> (list A) --> (list A) |
| hd | take the head of a list | |
| tl | return the tail of a list | (list A) --> (list A) |
| cons? | test for non-empty list | A --> boolean |
| defun | basic Lisp function definer | |
| lambda | lambda function | X : A >> Y : B; (lambda X Y) : (A --> B); |
| let | local assignment | Y : B; X : B >> Z : A; (let X Y Z ) : A |
| = | equality | A --> A --> boolean |
| eval-kl | evaluation function |  |
| freeze | creates a continuation | A --> (lazy A) |
| type | labels the type of an expression | X : A; (type X A) : A; |
| absvector | create a vector in the native platform |  |
| address-> | destructively assign a value to a vector address |  |
| <-address | retrieve a value from a vector address |  |
| absvector? |  | A --> boolean |
| write-byte | write an unsigned 8 bit byte to a stream | number --> (stream out) --> number |
| read-byte | read an unsigned 8 bit byte from a stream | (stream in) --> number |
| open | open a stream | Path : string; (open P D) : (stream D); |
| close | close a stream | (stream A) --> (list B) |
| get-time | get the run/real time | symbol --> number |
| + | addition | number --> number --> number |
| - | subtraction | number --> number --> number |
| * | multiplication | number --> number --> number |
| / | division | number --> number --> number |
| `>` | greater than | number --> number --> boolean |
| `<` | less than | number --> number --> boolean |
| `>=` | greater than or equal to | number --> number --> boolean |
| `<=` | less than or equal to | number --> number --> boolean |
| number? | number test | A --> boolean |

## The Syntax of Kl

is very simple and conforms to a Lisp. Well-formed sentences of Kl are symbolic expressions (s-exprs).

  1. Any symbol, boolean, string or number is an atom.
  2. Any atom is an s-expr as is ().
  3. Any abstraction (lambda X Y) is an s-expr if X is a symbol and Y is an s-expr.
  4. Any local assignment (let X Y Z) is an s-expr if X is a symbol and Y and Z are s-exprs.
  5. Any definition (defun F X Y) is an s-expr if F is a symbol and X is a (possibly empty) list of symbols (formal parameters) and Y is an s-expr.
  6. Any application (X1 ... Xn) is an s-expr if X1, ... Xn are s-exprs.

## Notes on the Implementation of Kl

These notes are for programmers wishing to implement Kl.

Tail recursion optimisation is a must and part of the Kl standard. Quite of few of the reader routines for Shen will not work in a language like Python which lacks it. In such a case, a platform provider working to move Shen to a non-TCO language has to consider how to port tail recursive Kl code.

Kl uses lexical scoping. This is pretty standard now. Qi II actually used dynamic scoping in its implementation of Prolog to implement variable binding but in Shen this is now done with vectors.

Kl follows applicative order evaluation. Except for the following constructions: `cond`, `and`, `or`, `if`, `freeze`, `let`, `defun`.

Kl follows a dual namespace model. A classic model for a Lisp views `defun` and `set` as interchangable.  Both are thought of as asserting a math'l identity so that  `(defun f (x y) y)` is sugar for `(set 'f (lambda x (lambda y y)))`.  This model supposes a single namespace for functions and variables. You have this in Python.

So in the classic model `defun` and `set` together are logically superfluous. It is more reasonable to regard `set` as logically prior since incrementing a global variable is much more easily carried out through `set` than `defun`. Incrementing should be very fast - function compilation is generally very slow.

In a dual namespace model, the `defun` and `set` are regarded as creating an association between the symbol and something else; it is a mapping not an assertion of identity.

Generally Qi and Shen require a dual namespace for symbols.  The reason for this is to do with the Qi evaluation strategy for symbols which is that symbols are self-evaluating.  In Qi the symbol 'f' evaluates to itself.  If we want to get at the value associated with `f`, we type `(value f)`.  Hence f is not thought of as shorthand for a value, but is merely a symbol to which objects (definitions, global assignments etc) can be attached.

Generally, if we had a single namespace, we would have a convention of a different kind. For instance if `(set f 6)` entailed that `f` really meant (was just a shorthand for) 6, then we would expect that typing in 'f' to the REPL would return 6.  In Python that's exactly what happens with symbols.

```python
>>> f = 9
>>> f
9
>>> def f (): return(9)
...
>>> f
<function f at 0x024574F0>
But Qi does not work that way.  Allowing symbols as self-evaluating really points away from this model.  Hence Kl and Shen are committed to the dual namespace approach.  
```

Partial applications are mandatory. Thus `(defun f (x y) ....)` and `(defun f (x) (lambda y ...))` are equivalent. There are efficient techniques for compiling Kl into languages which don't respect this rule (like CL) - see the document on porting.

Note in Shen 8.0, typed zero place functions were introduced. Here is pi as a constant.

```shen
(define pi {--> number}
  -> 3.142)
```

In Kl

```shen
(defun pi () 3.142)
```

## Kl and the Shen Evaluator

The Shen evaluator compiles Shen into Kl and Kl into native code. The Shen evaluator accepts S-exprs as legal input and since Kl expressions are such, any Kl expression is a legal input to Shen. Note that if a Kl expression is typed into Shen, that special constructions such as the list/string/vectors constructors in Shen which are outside the Kl spec (see the sections below) will actually work within such expressions because they are compiled into legal Kl. Thus the function;

A. `(defun list-all (x y z) [x y z])`

is not legal Kl and would have to be written as follows to be legal Kl

B. `(defun list-all (x y z) (cons x (cons y (cons z ()))))`

However expression A. will be accepted and compiled by Shen into expression B. Hence hybrid programming will work in Shen. We don't actually recommend this style, because Kl is not designed for the purposes of programming, but for easy porting and implementation. However you can write Kl code in Shen which is as compact as Common Lisp.

## Boolean Operators

The list of boolean operators contains some logical redundancy. Logically only if is required to define the rest. However even ANSI C contains a version of the basic repertoire if, and, or, not and the cond is trivially compilable into a nested if. Because Kl does not contain macros and uses strict applicative order evaluation outside boolean operations, these are not efficiently interdefinable in the language itself. Note that in Kl a cond that fails in all its cases does not deliver NIL (as in CL) but an error.

Shen includes a cases statement which has the syntax

(cases
  test-a result-a
  test-b result-b
  ...)

and which is equivalent to `(if test-a result-a (if test-b result-b ...))`. If no cases apply an error is returned.

## The Syntax of Symbols

In Shen an atom is either a symbol, boolean, string or number. All atoms, thus including symbols, are self-evaluating. The empty list is not counted as an atom but is also self-evaluating. Hence there is no quote in Kl or Shen. Mapping into CL which does use quote is trivial. The function symbol? is the recognisor for symbols; their BNF is as follows.

```
<symbol> := <alpha> <symbolchars> | <alpha>
<symbolchars> := <alpha> <symbolchars> | <digit> <symbolchars> | <alpha> | <digit>

<alpha> := a | b | c | d | e | f | g | h | i | j | k | l | m | n | o | p | q | r | s | t | u | v | w | x | y | z 
<alpha> := A | B | C | D | E | F | G | H | I | J | K | L | M | N | O | P | Q | R | S | T | U | V | W | X | Y | Z
<alpha> := = | - | * | / | + | _ | ? | $ | ! | @ | ~ | . | > | < | & | % | ' | #| ` | ; | : | { | }

<digit> := 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9
```

A symbol is a variable if it begins in an uppercase letter.

## The Semantics of Symbols in Shen and Kl

Qi II and Common Lisp are all members of the Lisp family of languages. In Lisp, symbols are often semantically context sensitive; that is, the interpretation of a symbol may depend on the context in which it occurs. For example in this Common Lisp expression; (list 'John 'put 'the 'car 'into 'reverse), or in Qi II [John put the car into reverse], the symbol 'reverse' denotes a symbol. But in Common Lisp the expressions (reverse '(1 2 3)) (in Qi II (reverse [1 2 3])) and (mapcar 'reverse '((1 2) (2 3) (3 4))), (in Qi II (map reverse [[1 2] [2 3] [3 4]])), the symbol reverse actually denotes a function.

That means in the Lisp family, symbols are semantically context sensitive. At the head of an application they can only denote a function and there is no ambiguity; but within the body of the application they can denote either a function or the symbol quoted. Lets us say a symbol is idle in Qi if it is used without naming anything.

To help reading, Common Lisp includes the expression function which disambiguates idle symbols from the other kind; the expression (mapcar (function reverse) '((1 2) (2 3) (3 4))) does what (mapcar 'reverse '((1 2) (2 3) (3 4))) does but the semantics of reverse is clarified to show that the programmer is referring to the function not the symbol itself.

Qi I and Qi II followed Common Lisp in making symbols semantically context sensitive, relying on the Common Lisp compiler to decipher the ambiguity and make the correct choice. Being specifically tailored for multiplatform development, Shen can make no such assumption. It is quite possible that the native platform does not support symbols as data objects in the manner of Lisp; in which case it is possible to construct a simulation of Lisp symbols by using tagged 2 element vectors (one element a tag to show it is impersonating a symbol, the other to hold a string representation of the symbol; see Coping with Missing Symbols in the document of porting).

However the problem arises of the context sensitivity of symbols; when should a symbol should be 'vectorised' in a non-Lisp language and when not? For instance, if the symbol reverse is vectorised in the context (map reverse [[1 2] [2 3] [3 4]]), then the map function will crash, since it receives a vector and not a function as an argument. But in the context [John put the car into reverse], it is right to vectorise the symbol reverse because it is not calling a function. How does one proceed?

There are several solutions to this problem. One is to simply avoid idle symbols and insist that strings do all the work of idle symbols. This follows the path of languages like ML where idle symbols do not exist. It would mean that in Shen, [p & q] could not be written; only ["p" "&" "q"]. However this would probably not appeal to those Lispers, like myself, who enjoy the convenience of working with idle symbols.

The second is to treat all non-variable symbols in the body of an application (apart from the leading symbol which must denote a function or procedure of some form) as idle, thus vectorising them. In this case, to prevent any higher-order function H from failing, H must, when applying any vectorised symbol S, look for the function F associated with S and use F instead. This introduces a delay into the execution of H and moreover means that native higher-order functions in the platform, which are not set up to interface to vectorised symbols, will still fail in the manner described above.

The third solution is to provide 'function' as a means of disambiguation and this is what Shen does. Hence any symbol S which is an argument to an application is treated as idle. But if S is enclosed as in '(function S)', the whole expression denotes a function. Hence to write portable Shen; one should avoid writing an expression like '(map reverse [[1 2] [2 3] [3 4]])' and write '(map (function reverse) [[1 2] [2 3] [3 4]])'. The former construction will certainly work under a Common Lisp platform, but the latter will run under Common Lisp and platforms outside the Lisp family.

Note in version 18 and after, function is statically compiled away where possible in favour of a lambda form ((function union) is (/. X Y (union X Y))). When this is not possible, because function is used dynamically, a lookup table is used to find the appropriate lambda form. zero-place functions are not admissable arguments to function.

## Packages

Packages exist to avoid the usual danger of overwriting when two programmers accidently choose the same symbols in their programs to identify different values. The polyadic function package has the form (package S L E1 ... En) where

1. S is a symbol beginning in lowercase which is the name of a package; (e.g mypackage).
2. A list L (possibly empty) of non-variable symbols. 
3. E1 ... En are a series of Shen expressions.

The Shen reader prepends the package symbol S followed by dot (.) before all the symbols when evaluating E1 ... En apart from those symbols which are external, which are

(a) symbols listed as belonging to the system (such as ->, define, cons, append etc) or ... These are in fact the external symbols of the Shen package in which Shen is coded and may be called up by the expression (external shen). 
(b) symbols which are variables or ...
(c) ... symbols which are listed in L or .....
(d) ... symbols internal to the Shen package (shen) or ....
(e) ... symbols consisting entirely of underscores or entirely of equals signs.
(f) ... symbols already packaged under S (a rule introduced in Shen 19).

Symbols which are prepended we say are internal (to the package). Symbols which are not are external.

Hence (package mypackage [main] (define main ...) ....) will cause Shen to make all user functions read in its scope to be internal to mypackage apart from the symbol main which will be external.

The philosophy of Shen is that once a programmer has decided a symbol is internal to a package and is hidden from view that decision cannot be overridden except by changing the definition of the package. Hence the complexities of IMPORT and EXPORT found in Common Lisp are not reproduced in Shen. You cannot be 'in' a package in Shen within the REPL. It is possible to declare a package in a package.

The null package written (package null ....) has no effect on its contents. This used in certain advanced applications involving reader macros.

The function external takes a package name and returns the list of all those symbols which have been declared external to that package at the point the function is called. If the package does not exist, an error is raised.

The function internal takes a package name and returns the list of all those symbols which have been found to be internal to that package at the point the function is called. If the package does not exist, an error is raised. This function was introduced in Shen 19.

Note that Shen will allow you to reference symbols that are internal to a package by citing the package name (e.g. mypackage.foo).

Symbols which are external to the Shen package may not be redefined; the user cannot redefine append for instance. The function systemf of type symbol --> symbol applied to any symbol gives that symbol the authority of an external symbol of the Shen package and the functional definition attached to that symbol cannot thereafter be overwritten. From version 17, systemf returns its argument.

Version 17 introduced package? of type symbol --> boolean which returns true when the package exists and false otherwise.

## Prolog

Shen contains a Prolog, just as Qi II, but the m-prolog syntax has been dropped. The main reason for this was that embedding executable code in a string (to preserve conformancy with Edinburgh syntax) generated awkward anomalies with respect of the rest of the system. For example a special string searching routine had to be developed for m-prolog declarations embedded in a package; symbol overloading had to be used because Edinburgh Prolog uses '=' to mean something different from simple equality; you cannot insert comments inside an m-prolog program and searching in an m-prolog program is more difficult since the structure is in a string not a list. To compensate Qi developed a low level s-prolog convention in which Prolog programs were s-exprs.

In place of the awkward dual convention, Shen has one Prolog notation consistent with the rest of Shen which uses defprolog. Here are the member, reverse and append functions in Shen Prolog.

```shen
(defprolog member
  X [X | _] <--;
  X [_ | Y] <-- (member X Y);)

(defprolog rev
  [] [] <--;
  [X | Y] Z <-- (rev Y W) (conc W [X] Z);)

(defprolog conc
  [] X X <--;
  [X | Y] Z [X | W] <-- (conc Y Z W);)
```

The following functions are found in Shen Prolog

| predicate | arity | description |
|-----------|-------|-------------|
| unify | 2 | unifies terms |
| unify! | 2 | unifies terms with an occurs check |
| identical | 2 | succeeds if the terms are identical |
| is | 2 | binds the variable which is the first term to the result of evaluating the second. All variables in the second are completely dereferenced. |
| bind | 2 | as 'is' except all variables in the second term are dereferenced only so far as to derive a non-variable result. |
| findall | 3 | takes a variable X , a literal (list) L and a variable Y and finds all values for X in L for which L is provable and binds the list of these values to Y. |
| when | 1 | the term is evaluated to true or false and the call succeeds if it is true. All variables in the term are completely dereferenced. |
| fwhen | 1 | the term is evaluated to true or false and the call succeeds if it is true. All variables in the term are dereferenced only so far as to derive a non-variable result. |
| call | 1 | apply the predicate at the head of the list to the terms of the tail. (Prolog apply) |
| return | 1 | terminate Prolog returning the dereferenced value of the term. |
| ! | 0 | Prolog cut |
| receive | 1 | Bind a variable to a value outside of Prolog |

receive was introduced in version 14 to allow Prolog to be called with a variable whose binding is made outside Prolog. Thus (foo a) in

```shen
(define foo
  X -> (prolog? (receive X) (bar X X)))
```

will call `(bar a a)` inside Prolog.

## Shen-YACC II

Shen contains a YACC, just as Qi II, but the syntax was modified in 9.0 to bring it closer to Shen. This section briefly describes the differences.

The `-*-` (ditto `-s-` and `-o-`) indicating the head of the input stream is gone from YACC II and just as in Shen variables mark the position of isolated elements. This makes for a more powerful and flexible notation. The use of (fail) in a semantic action to trigger backtracking is dropped in favour of a guard. Thus the following tests a list of numbers to determine if the list is binary

```shen
(defcc <binary?>
  X <binary?> := true where (element? X [0 1]);
  X := true where (element? X [0 1]);
  <e> := false;)
```

`<!>` consumes the remaining input.

```shen
(defcc <tl>
  _ <!> := <!>;)
```

returns the tail of a list. Shen-YACC II recognises lists in the input.

```shen
(defcc <asbs>
  [a b] <asbs>;
  [a b];)
```

recognises lists of the form `[[a b]], [[a b] [a b]], ....`

## Strings, Bytes and Unicode

A string in Shen begins with " and ends with ". The basic functions for strings are cn - which concatenates two strings together, pos, which takes a non-negative number N (starting from zero) and returns the Nth unit string of the string and tlstr which returns all of the string apart from its leading unit string. The function str places an atom into a string (effectively enclosing it in quotes).

The action of str within the domain of atoms is as follows (^ is the concatenation sign).

  1. For a symbol S, str returns the string "^S^" that results from enclosing it in quotes.

  2. For a number N, str returns a string "^M^" whose contents M are such that (= M N) is true in Shen. str applied to a large floating point number may return a string whose contents are in e number notation.

  3. For a string S, str returns a string that when printed off reads as "^S^". However the internal representation of the string may and probably will differ from its print representation.

  4. For the failure object, str returns `...`.

In earlier versions of Shendoc (< 6.1) the question of the print representation of streams and closures was not determined. In fact these objects are sent to str in the course of printing and hence the print representation of streams and closures depends directly on their string representation under str. In point of fact it is frequently impossible to recover the original expression that evaluated to the stream/closure and so generally their print representation is not readable. In these cases str should use the platform representation unless this is totally confusing.

A more general function make-string will place any Shen object into a string, preserving the appearance in a way that makes it conformant to Shen printing conventions (see printing). string? recognises all and only strings.

The Shen reader reads unsigned 8 bit bytes into unit strings and parses these strings into other tokens as required. By default the list of acceptable unsigned bytes is a subset of the ASCII code points between 0 and 127, including all the points from 32 to 126 and the points 9,10 and 13. The function n->string maps a code point to the corresponding unit string. It is consistent with the Shen specification to extend the domain of this function to incorporate extended ASCII or Unicode, but the mentioned code points must be supported. The function string->n is the inverse of n->string.

The $ notation as in ($ hello) is read in by the reader by exploding its argument. ($ hello) is read in as "h" "e" "l" "l" "o"; this was introduced as a convenient shorthand for writing string handling programs. Note $ is not a function.

Shen uses decimal notation for reading bytes and for character codes. The character string "c#67;" will be printed as "C".

## Strings and Pattern Matching

The polyadic function @s can be used to concatenate n (n >= 2) strings. The polyadicity is a syntactic fiction maintained by the Shen reader. (@s "a" "b" "c") is parsed as (@s "a" (@s "b" "c")) exactly in the manner of @p.

The Shen reader parses (@s "123" "456") in a special way; as (@s "1" (@s "2" (@s "3" "456"))). The leading argument, if a string, is decomposed into a series of concatenations of unit strings. The significance of this is realised in the use of @s for pattern-matching over strings.

@s is not a fast operation because many platforms represent strings as vectors and in these cases @s runs in linear time in respect of the size of the arguments.

Within a function @s may be used for pattern-matching. For example; the following removes all occurences of my Christian name from a string.

```shen
(define remove-my-name {string --> string}
  "" -> ""
  (@s "Mark" Str) -> (remove-my-name Str)
  (@s S Str) -> (@s S (remove-my-name Str)))
```

which is parsed into the following.

```shen
(define remove-my-name {string --> string}
  "" -> ""
  (@s "M" (@s "a" (@s "r" (@s "k" Str)))) -> (remove-my-name Str)
  (@s S Str) -> (@s S (remove-my-name Str)))
```

## Lists

In Shen as in Qi, a list consists of a series of items, seperated by whitespace, and flanked by [ and ] to the left and right. [] is the empty list as is (). Note that Kl does not understand [...] and that the Shen reader translates this idiom into Kl. The basic constructors are cons, hd and tl and cons? corresponding to CONS, CAR and CDR, and CONSP in Lisp.

It is an error to apply hd or tl to anything but a list.

There is the question of how to treat the application of hd to the empty list []. Ideally this should produce an error. In Common Lisp the CAR of the empty list is the empty list. Actually coding hd so that it returns an error in Common Lisp requires encoding a non-empty list test into the definition of hd. This is generally unnecessarily expensive in such a heavily utilised function, because often the programmer knows before applying hd that the list is non-empty. Hence in Shen hd does not presuppose a non-empty list test and the result of applying hd to the empty list is platform dependent. For implementors building Kl from scratch we recommend raising an error, as applying hd to the empty list is a deprecated operation.

For that reason in Shen, hd is not given a type since its behaviour is type unpredictable. There is a function head of type (list A) --> A in Shen which is well-behaved and which does make a non-empty list test and which raises an error if applied to the empty list.

Similar observations apply to tl which if applied to the empty list in Common Lisp produces an empty list. In other languages, an error may arise. Hence by parity of reasoning, the result of (tl ()) is platform dependent and there is no type for tl. There is a function tail of type (list A) --> (list A) in Shen which is well-behaved and which does make a non-empty list test and which raises an error if applied to the empty list.

Note that cons applied to X and Y where Y is not a list provides a result which is called a dotted pair. This form of application is needed in Shen in the internals of Shen Prolog. In Shen cons does have a type because the type checker is capable of failing dotted pair applications as type insecure. Hence the type of cons is A --> (list A) --> (list A). In Shen, the dotted pair (cons a b) is printed off as [a | b].

## Characters

Shen does not incorporate characters as a data type. The failure object is no longer #\Escape as in Qi, but (fail). The exact identity of the failure object in a platform is not determined but it should be some unique object within the type symbol.

## Streams

Streams in Shen were introduced to encode some of the functions that were hard-wired into Qi II like write-file and read-file. The goal was to capture just as much in the way of primitives as is necessary to reproduce the functionality of Qi II. From Shen 13 onwards only byte streams are supported by the standard. Any other kind of stream will be found in a library.

The basic functions for streams are

open
close
read-byte
write-byte
stinput
stoutput

The function open creates a stream and the first argument is a string designating the file which is the basis of the stream and the second argument is either in or out determines whether the resulting stream is a source or sink . Material written to a file overwrites the contents already in it. The function close closes a stream and returns the empty list.

The open function works in hand with the cd command in Shen which fixes the home directory. All files are opened relative to the value for the home directory, which is held in the global *home-directory*. The value of this global is changed by the cd function common to Qi and Shen.

Every Shen stream is read in or written to as a series of unsigned 8 bit bytes. read-byte takes a source stream as an argument and returns a byte as a decimal number between 0 and 255. If the stream is empty then read-byte returns -1. Having such base reader, it is possible to build any reader on top of it. A UTF-8, UTF-16 or UTF-32 stream reader may be built from 8 bit bytes stream reader. read-byte is a polyadic function which can appear with no arguments; in that case the stream read is the standard input (terminal) stream (stinput).

(stinput) returns the standard input as a byte source. If read-byte is applied to the standard input then the user's input is echoed to the terminal under the printing convention that the character printed has the same code point as the byte (as in UTF-8). Effectively this means that (stinput) may handle extended ASCII, although only ASCII is required of the Shen reader.

write-byte writes a byte as a number n from 0 to 255 to a stream and returns n as a value. If the stream is omitted then write-byte defaults to the standard output. If write-byte is applied to the standard output then the user's input is echoed to the terminal under the printing convention that the character printed has the same code point as the byte. (stoutput) returns the standard output.

The type stream is a parametric type in Shen and has only two possible parameters - in or out. The type of the open function is a dependent type which cannot be given a type in arrow notation but requires the following sequent calculus definition.

File : string; 
(open File Direction) : (stream Direction);

where the values of Direction are 'in' and 'out'.

In Shen 16 the zero-place function it was introduced; (it) returns the last (unevaluated) expression entered to the standard input as a string. The type of it is (--> string).

## Reader Macros

The Shen reader sits on top of the primitive bytes stream reader and reads from either a file (using open) or the input stream. The reader is programmable just as in Qi II, but uses the defmacro construction, which is actually cleaner and easier to use than the Qi II sugar function. However internally, the defmacro construction is handled using similar techniques as for sugar functions. A macro in Shen is a 1-place function that is used by the reader to parse the user input. Here for instance is a macro used for benchmarking Shen.

```shen
(defmacro exec-macro
  [exec Expr] -> [trap-error [time Expr] [/. E failed]])
```

The action of this macro is to macroexpand every instance of (exec Expr) as typed or loaded into the top level by the macroexpansion of (trap-error (time Expr) (/. E failed)). There is no need to include a default X -> X at the bottom of a macro (as is needed in Qi II) - this is inserted automatically. Shen macros are tied into the Shen eval function (see eval below). The function macroexpand applies the list of current macros to the top level of an expression.

The mode of operation of macroexpand within the reader and within eval is as follows.

  1. Within the reader: the list of macros is composed to a fixpoint on every read token t (i.e. atom or list of atoms). If the token t is changed to t' where t <> t', the process is repeated on every subterm of t'.

  2. Within eval; the list of macros is composed on every subterm (i.e. atom or list of atoms) to a fixpoint.

## Vectors

In Kl and Shen, (1 dimensional) vectors fulfil all the tasks of arrays. In Kl there are only 4 primitive functions concerned with vectors.

1. absvector - which creates an absolute (platform) vector with N addresses.
2. address-> - which destructively places an element E into a vector address N in vector V and returns the resultant vector.
3. <-address - which extracts an element from a vector address N in vector V.
4. absvector? which recognises a vector.

All of these functions are accessible from Shen but only the last has a type, since Kl vectors may have elements of any type. It is an error to try to access an address beyond the limit of the vector or to supply any number which is not a whole number between 0 and the limit of the vector.

Note that absvector? plugs into the native vector recognition routine. It is possible for this function to return true to objects which are not vectors under other platfroms. In Lisp for instance, strings are vectors of characters and the default representation of tuples in Shen is by use of vectors. The function vector? (see below) is better behaved in this respect.

Vectors are numbered from 0; so (absvector 100) creates a vector with addresses from 0 to 99.

If a vector V is created and nothing has been stored address V(N) then the result returned by (<-address V N) is platform dependent.

In Shen absolute vectors are partioned into standard and non-standard vectors. In Shen, by convention, when a standard vector V is created two operations are performed.

1. The 0th element of V is allocated a positive integer which indicates the size (limit) of the vector. 
2. Every other address is allocated the failure object designated by the expression (fail).

The function vector of type number --> (vector A) creates such a vector. If the 0th element of V is not a non-negative integer then the vector is non standard. Hence access to the user contents of the standard vector begins with the index N = 1.

The shortest standard vector is created by expression (vector 0) which creates a standard vector which contains one element whose contents are zero. This called the empty vector and is significant in pattern-matching over vectors (see next section). It is impossible to write to the empty vector in a type secure way and hence under type security, the empty vector is immutable. Shen permits the user to write <> as shorthand for the empty vector. The type of the empty vector is (vector A).

In Kl the primitive function <-address in (<-address N V) accesses the Nth element of the vector V including the 0th element which indicates the limit of the vector. This function has no type because the 0th element of a standard vector V will be an integer irrespective of the rest of the vector.

The type secure version of <-address is the function <-vector of type (vector A) --> number --> A, which accesses the contents of the standard vector. The operation (<-vector V 0) results in an error. If <-vector accesses the failure object then an exception is returned as an error message. Otherwise <-vector behaves exactly as does <-address. The function limit has the type (vector A) --> number and accesses the 0th element of a standard vector V. Both are simply defined in terms of <-address.

A 2-dimensional array is simply a vector of vectors and therefore has a type which is an instance of (vector (vector A)). Note that a vector of vectors may incorporate vectors of different sizes (the result is called a jagged array).

For changing the contents of a vector, the function address-> in (address-> X N V) places X in the Nth element of V. The function vector-> is type secure version of address-> of type ((vector A) --> number --> A --> (vector A) and raises an error for N = 0.

The function vector? returns true iff the argument is a standard vector.

## Standard Vectors and Pattern Matching

The polyadic function @v can be used to add elements to a vector or to create a vector. The vector consisting of the numbers 1, 2 and 3 can be created by (@v 1 2 3 <>). The polyadicity is a syntactic fiction maintained by the Shen reader. (@v 1 2 3 <>) is parsed as (@v 1 (@ v 2 (@v 3 <>))) exactly in the manner of @p.

The semantics of @v is as follows: given (@v X Y), if Y is a standard vector of size N, then @v creates and outputs a new vector V of size N+1 and places X in the first position of V, copying the Ith element of Y to the I+1 element of V.

Shen accepts pattern-matching using @v. The following function adds 1 to every element of a vector

```shen
(define add1 {(vector number) --> (vector number)}
  <> -> <>
  (@v X Y) -> (@v (+ X 1) (add1 Y)))
```

(@v X Y) matches the Y to the tail of the vector - so that matching (@v X Y) to <1 2> matches Y to <2> not 2. Note because @v uses copying, pattern-directed vector manipulation is non-destructive but slow.

## Non Standard Vectors and Tuples

A non-standard vector is a vector where the 0th element is not a non-negative integer. The utility of non-standard vectors is that they can be used to construct other data types like tuples.

Tuples in Shen are not primitive to Kl but are represented in the Shen sysfile code as non-standard three element vectors where the 0th element is a tag tuple indicating that the vector represents a tuple and the next two elements are the first and second elements of that tuple. The basic operations such as @p, fst and snd are easily definable as is the recognisor tuple?.

Because tuples are defined internally using Kl primitives as non-standard vectors, the type system of Shen does not recognise them as standard vectors and hence, though they can be manipulated using vector operations they cannot be manipulated like this in a type secure way (i.e. with type checking enabled). Only @p, fst and snd can be used. The significance of this is that with type checking enabled, tuples are immutable objects; that is they cannot be destructively changed with address-> or vector->, merely interrogated for their parts or combined into other data structures.

The identity of tuples with non-standard vectors is purely one of convenience. In platforms which support tuples as a native type, the native type may be used. However the following equations must hold.

  1. The recognisor tuple? returns 'true' to tuples, but not to any other type checked Shen datatype.
  2. The tuple (@p 1 2) is printed off as such.
  3. @p is a two place function which associates to the right; (@p a b c) is just (@p a (@p b c)).
  4. (fst (@p a b)) = a and (snd (@p a b)) = b for all a and b.

## Equality

`=` tests for equality between objects, returning either true or false. Note unlike Qi II, = will work on all vectors generally; two vectors V1 and V2 are equal iff for all I (<-address V1 I) = (<-address V2 I) . However comparison of closures or streams will return false under =. Lists, atoms, tuples and vectors are the proper range of this function. Kl is case sensitive, (= a A) returns false.

## I/O

Used to define all printing in Shen, is write-byte which takes a byte and a sink S and writes the byte to S. Higher level is pr which takes a string and a stream and prints the string to the stream and returns the string. If the stream argument in either case is omitted then the stream defaults to standard output.

As with Qi, Shen includes the print, error and output statements in much the same way as in Qi II; they are explained here http://www.lambdassociates.org/Book/page042.htm. print prints its argument exactly as it appears and returns that argument, output prints a string using slots if needed and returns a string. Note in Shen, the slot ~S is supported as well as ~A. The effect of ~S (as in Common Lisp) is that string quoting is preserved. ~% forces a new line. Thus (output "~A" "hello there") prints hello there but (output "~S" "hello there") prints "hello there".

Note that output returns a string as a value which is the same string that it prints.

Shen provides an extra formatting command ~R, which prints the argument using ()s rather than []s, which is useful for printing logical and mathematical formulae.

All three functions depend on make-string which builds a string from a template and a series of arguments. Thus (make-string "~A loves ~A and ~A" John Mary Tim) returns "John loves Mary and Tim". Use make-string to coerce an arbitrary object into a string. To write to a stream, you can use pr and make-string combined as in (pr (make-string "~A loves ~A and ~A" John Mary Tim) `stream`).

There is also a function `(nl N)` which prints off N new lines and returns zero. If the argument is omitted, then `(nl)` prints off a single new line.

Note that print, error, output and make-string are all polyadic and that therefore they are syntactic fictions which are represented by internal functions of a fixed arity.

Vectors and lists are printed off using <...>. The vector whose elements from address 1 to the end are 1, 2 and 3 is printed off as <1 2 3>. Vectors or lists of more than 20 elements have the remaining elements printed off under 'etc' e.g a standard vector of the first 100 positive integers would be printed off as

`<1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20... etc>`

The global *maximum-print-sequence-size* controls this feature and should always be set to a positive whole number.

Non-standard vectors are printed off in a special manner. For example, in porting Shen to a platform which lacked symbols as a basic datatype, the programmer can define symbol as a new immutable datatype comprised of a non-standard vector whose zeroth address holds a tag indicating that the vector represents a symbol and whose first address holds a string representing the symbol.

In this case the programmer can indicate in the non-standard vector itself how the object is supposed to be printed off by making the tag into a print function. This is called a print vector in Shen. Thus the representation of the tuple (@p a b) in Shen is:

`tuple a b`

The Shen printer, when confronted with a non-standard vector V whose 0th address contains a non positive integer F, uses F as as a formatting function - the function that determines how the non-standard vector is printed. This formatting function tells Shen how the print representation of V is to be bundled into the string which is eventually printed off and hence how that print vector will appear when printed. Hence the tuple function will map the tuple to a string. In Shen it is defined as follows.

```shen
(define tuple 
  X -> (make-string "(@p ~S ~S)" (fst X) (snd X)))
```

If the non-standard vector has no associated print function then it is printed off as a normal vector but with the 0th element included.

The print representation of the failure object is ... (three dots).

The global variable *hush* is set by default to false. If set to true then all messages printed from output and print are disabled, through messages using pr will still be printed to the target stream. Effectively this disables system reports from Shen and all printing is then driven by the user. This feature was suggested by Ramil Farkshatov as an aid to diagnostics.

The functions lineread, input, input+, read are in part adapted from Qi where they were all fixed to standard input. In version 13 of Shen these were made polyadic and relativised to an input stream. If no stream is chosen then Shen chooses standard input. The qualities of these functions are as follows.

lineread reads in a line of Shen tokens terminated by a new line.

read reads the first available Shen token

input reads the first available Shen token and evaluates it returning a normal form

input+ receives a type T and a stream S and reads the first token off S, evaluates it and returns the normal form if that token is of type T. If the token is not of type T then an error is returned. Note that after Shen 13, (input+ : number) is just written as (input+ number).

All these functions return an error empty stream if the stream is empty.

## Generic Functions

This section deals with the generic functions; defun, let, lambda, eval-kl, freeze and thaw.

defun

defun in Kl requires little explanation except to note that all functions defined using it must sustain currying and that the namespace model is dual (see the document on porting for more on this). There is no necessity to support nested definitions in the manner of Scheme. defun is a top level construction and there is no obligation to support the evaluation of defun within an expression; this also holds true of define unless it is used in a package.

lambda

lambda in Kl is deliberately spartan; following lambda calculus in defining an abstraction that accepts only one argument. let is strictly otiose being definable by the equation.

(let X Y Z) = ((lambda X Z) Y)

However this form is less natural and less familiar than the traditional local assignment and is not definable except by a macro. Note that in Shen (lambda X X) is legal.

eval-kl

eval-kl evaluates a Kl expression. It is generally not used within applications programming. The function eval is not a primitive in Kl, but eval-kl is.

eval in Shen applied to an an expression E returns the expression E' that results from evaluating the expression E'' where E'' results from E by the replacement of all the square brackets in E' by round ones (see www.lambdassociates.org/Book/page131.htm). Thus (eval [+ 1 2]) evaluates to what (+ 1 2) evaluates to - which is 3.

freeze and thaw

The function freeze freezes the computation represented by its argument which is not evaluated. Effectively freeze returns a continuation; defined by Wikipedia as "[the reification of] an instance of a computational process at a given point in the process's execution". The counterpart to freeze is the function thaw which unfreezes the computation and returns the evaluated result. thaw is not primitive being readily defined in Kl as

`(defun thaw (F) (F))`

## Type Declarations

The primitive type is used to annotate any s-expression. The notation is

```shen
(type S-expr type)
```

as in (type (+ 1 2) number). This is not in any sense a normal function since the type `type` is discarded in evaluation (i.e. (type S-expr type) evaluates to the normal form of <S-expr>. The type declaration is not ignored by the type checker which actually expects the expression to have the type attached to it and will signal an error if this is not so.

The degree to which any implementation of Kl uses the information provided by this annotation will depend on the platform and the implementation. Shen 11 and later will, if required, automatically generate copious type annotations in Kl which can be used by Kl implementors or platform providers of Shen to optimise the resultant code. The command (optimise +) enables this feature. The default is `(optimise -)`.

Optimisation of the type declarations in a type checked Shen function F is expected to preserve the I/O features of F only with respect to type secure input. Thus

```shen
(define =n {number --> number}
  N N -> true
  _ _ -> false)
```

may return an error on non-numeric inputs when optimised.

## External Global Variables

The following variables are external to the Shen package. The variable *language* is bound to a string which indicates the platform under which Shen is running. For Common Lisp this is "Common Lisp". The global *implementation* is bound to the implementation; e.g. "CLisp" and *release* to the release of the platform e.g. 2.45. *port* and *porters* are bound to the port version on that platform and the authors of the port. The variable *stinput* is bound to the standard input stream and *stoutput* to the standard output stream. *home-directory* is bound to a string which denotes the directory relative to which all files are read or written. *version* is bound to a string detailing the release of Shen. *maximum-print-sequence-size* determines the maximum size to which a sequence is fully printed. *macros* contains the list of current macros. *hush* is bound to a boolean, by default false, and regulates printing.

## Property Vectors and Hashing

Like Qi, Shen includes property lists. However they are not implemented using CL property lists, but instead rely on a hashing function into a standard vector *property-vector* which is internal to the Shen package and by default set to hold 20,000 elements.

The expression (put Mark sex male) creates a pointer sex from Mark to the object male. The expression (get Mark sex) retrieves male. If no pointer exists from the object then get returns an error.

The functions put and get index into the vector by converting their first argument A into a number via the hashing function (see below) that involves summing the code point values of constituent components of A. This hashing function h may be a many-one function, hence *property-vector* is a vector of lists and a list search is used at position (h A) in V to locate the correct value. Current performance for hash coding an object is 16,000 hashes per second under CLisp using a 1.3 Ghz Pentium for a 10-character object. This function is subject to any improvements and changes that are consistent with the language specification (see optimising the system functions in the document on porting).

In Qi, get-prop was a 3-place function (get-prop X P Y) where the third argument was returned if no pointer P existed from X. In Shen, if no pointer exists then an error is returned. Using exception handling, assuming X and P are well-defined, get-prop is easily defined in Shen.

(get-prop X P Y) = (trap-error (get X P) (/. E Y))

Unline CL, arguments to get and put can be objects of any type provided their constituents are representable within the default string set. If the hash value (h A) of the argument A exceeds the limit of the property list vector, the modulus M of (h A) to the size of the vector is taken and the data is placed in the Mth address of the vector.

put and get are actually polyadic functions which appear as such by the grace of the Shen reader. There is an optional final argument which should be a standard vector; thus (put Mark sex male (value *myvector*)) will use the vector *myvector* as the hashing table. If the optional argument is missing then *property-vector* is used.

In version 17 unput was introduced which cancels the effect of put. (unput Mark sex) will remove the pointer. Again this function allows for an optional vector argument which defaults unless specified otherwise to the property vector.

The hash function hash takes as arguments a Shen object X and a positive number N (which need not be whole) and returns a number M between zero and N, where M represents the hash value of X within that interval.

## Error Handling

The basic error function is simple-error which takes a string and returns it as an exception. A more useful version is error which, as in Qi II, shares the same syntax as output, except that object returned is an exception. Shen includes a basic type secure exception handling mechanism drawn from the Qi library called trap-error. trap-error receives two arguments, an expression E and a function F. If E evaluates to normal form E', then E' is returned. If an exception C is raised it is sent to F and (F C) is returned. The function error-to-string allows exceptions to be turned into strings and printed or examined. This function is defined only for exceptions and should return an error for any other type of object.

Note that trap-error is type secure and its type is A --> (exception --> A) --> A.

Some examples

(trap-error (/ 1 0) (/. E -1)) gives -1 : number

(trap-error (/ 1 0) (/. E (error-to-string E))) gives the error message as a string "division by zero".

## Numbers

The numbers in Shen are as follows.

1. Numbers may be positive or negative or zero.
2. Numbers are either integers or floats; there are no rationals or complex numbers.
3. E number notation is allowed. They are not part of Kl but are parsed by the Shen reader to integers or floats.
4. +,-,/,* are 2-place and operate on floats and integers. / applied to two integers A and B produces an integer if B is a divisor of A otherwise a float.
5. >=, <, <=, >, = operate over all numbers (> 3.5 3) is meaningful and true. (= 1 1.0) is true.
6. The maximum size of any integer or float and the precision of the arithmetic is implementation dependent.

The BNF is

<number> := <integer> | <float> | <e-number> | <sign> <number>
<integer> := <digit> | <digit> <integer>
<digit> := 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 0
<float> := <integer> . <integer> | . <integer>
<e-number> := <integer> e <integer> | <float> e <integer> | <integer> e -<integer> | <float> e -<integer> 
<sign> := + | - | + <sign> | - <sign>

This is deliberately kept simple. There is no distinction between bignums, fixnums etc. There is already a standard maths library developed by Dr Willi Riha which will load in a range of numeric functions including trigonometric functions. There may be packages which offer a richer range of types for numbers (fixnum and bignum etc.) with much greater scope for optimisation within the compiler and which are platform specific. However these will be plugins, not in the language standard or in the standard maths library.

Shen uses simple cancellation when reading signs; thus --3 is read as 3 and ---3 as -3. +3 is just 3. Note (- 3) returns a closure that subtracts its argument from 3. Any fronting number is treated as a token; so for instance [f 5a] will be parsed as [f 5 a] (since 5a cannot be a symbol).

The maximum size of any number and the precision of the arithmetic are platform dependent. However the minimum of double precision is strongly recommended.

For users running Shen on other platforms, it is highly likely that the platform has already defined `>`, +, -, `*`, /, <, >=, =, etc. in a way that is inconsistent with the semantics allotted to these symbols in Kl. The .kl sources use these symbols in their native dress because implementors wishing to implement Kl will want to use `*` for multiply etc. But platform providers compiling .kl sources to another language and who experience a name clash with a native function, should read carefully the notes on porting in the porting document.

## Floats and Integers

Division between integers in Shen will yield a float if the divisor is not a whole divisor of the numerator. In some languages, e.g. Python, (/ 3 2) gives 1 (integer division) and not 1.5. It was argued as to whether Shen should follow suit. It was felt that in such cases it was more intuitive to return an answer with a fractional component - most people would consider 3/2 = 1 as false and for people using Shen to do wages calculations etc. 'street' division is more appealing. Integer division has been placed in the standard maths library.

An interesting question concerns the comparison of floats and integers is (= 1 1.0) true or not? Mathematically the decimal notation is simply a shorthand for a sum.

i.e. 1.0 = (1 x 100) + (0 x 10-1) = 1

Therefore if = represents identity then (= 1 1.0) is true. In Shen (= 1 1.0) is true (as in Common Lisp, (= 1 1.0) returns T) and 1.0 entered to the top level is returned as 1. Effectively a float is parsed as a sum of products i.e. 1.23 = (1 x 100) + (2 x 10-1) + (3 x 10-2).

E numbers are parsed similarly i.e. 1.23e2 = ((1 x 100) + (2 x 10-1) + (3 x 10-2)) x 102

A contrary approach is taken in Prolog where '1 = 1.0' is false. In ML the comparison is meaningless (returns an error) because 1.0 and 1 belong to different types - real and int. This is wrong. Computing has fogged the issues here and committed the traditional error of confusing use and mention in its treatment of integers and floats, in other words, between numbers and the signs we use to represent them. We should not confuse the identity of two numbers with the identity of their representation. If we want to say that 1.0 is not an integer and 1 is, we commit an error, because 1.0 = 1; unless we mean by 'integer' an expression which is applied to the representation itself (as in the BNF above) i.e. '1.0'. In which case the expression 'integer' is predicated of something which is a numeral, in computing terms, a string. In Shen, the integer? test is taken as predicating of numbers and 1.0 is treated as an integer.

The integer test in Shen runs in log time and is predicated on the following 'equations'

integer - integer = integer
non-integer - integer = non-integer

These 'equations', though mathematically true, can fail outside a certain range (commonly beyond 15 digits) which depends on the precision of the platform and therefore the accuracy of this test depends on the precision of the arithmetic. Thus we recommend that Shen be installed with at least double precision which gives accuracy up to 15 digits.

## The Timer

The get-time function is a 1 place function that returns a floating point number. The range of arguments supported by this function is implementation dependent as are the results.

For the argument real it should return a value representing real time i.e. two invocations of this function on real time should be seperated by an amount of time equal to the difference of their values. As such get-time can be used to measure the wall time elapsed between calls. The exact value of the results returned is implementation dependent as are the number of places used but the basic unit of measure should be seconds.

It is optional to set this function to record not real time, but run time; that is the actual CPU time. The argument run should return a value that is implementation dependent, but the difference between the two invocations of this function on run time should be seperated by an amount of time equal to the CPU time expended by Shen between the two calls. The exact value of the results returned is implementation dependent as are the number of places used.

The argument unix should return a number representing UNIX time in seconds i.e. the time elapsed since midnight January 1st 1970.

Note that not all platforms may support both run and real but either run or real should be supported. In either case the timer function built into Shen should reflect in the information provided whether run time or real time is being measured. If an argument is not supported then an appropriate error should be raised.

## Comments in Shen

One flaw in Qi II and Qi I was that comments were made using `\` ..... `\` which meant that comments could not themselves be commented out and the syntax clashed with that for characters which also used `\`. Shen follows the convention of starting comments with `\*` and ending with `*\`.

Version 10 allows for single line comments `-\\` will blank out all the input before the next RETURN or newline.

## Special Forms

The following are all special forms in Shen and have their own hard-coded type rules; they are not type checked in curried form and do not sustain type secure currying.

@p @s @v cons lambda let type where input+ define defmacro datatype /. synonyms open

copyright (c) 2013, Dr Mark Tarver
dr.mtarver@gmail.com

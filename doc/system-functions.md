## abort

**Type:** *none*

Raises an error with an empty message.


## absvector

**Type:** *none*

Given a non-negative integer returns a vector in the native platform.

**Required:** returns **true** for a native vector and an unspecified boolean for other types.

**Optional:** In some platforms, strings are coded as native vectors (e.g. CL) and **absvector?** may return **true** for strings.


## absvector?

**Type:** **`A --> boolean`**

Recognises native vectors.

**Required:** works for any vector created by **absvector**.


## address->

**Type:** *none*

Given a native vector *A*, a positive integer *i* and a value *V* places *V* in the *A[i]*th position.

**Required:** works for any vector created by **absvector**.


## <-address

**Type:** *none*

Given an absolute vector *A*, a positive integer *i* retrieves *V* from the *A[i]*th position.


## adjoin

**Type:** **`A --> (list A) --> (list A)`**

Conses an object to a list if it is not already an element.


## and

**Type:** **`boolean --> boolean --> boolean`**

Boolean and.


## append

**Type:** **`(list A) --> (list A) --> (list A)`**

Appends two lists into one list.


## arity

**Type:** **`A --> number`**

Given a Shen function, returns its arity otherwise -1.


## assoc

**Type:** **`A --> (list (list A)) --> (list A)`**

Given an object *x* and an **association list** *l*, returns the first list inside *l* with a head equal to *x*, or the empty list if no match is found.


## boolean?

**Type:** **`A --> boolean`**

Recognises booleans.


## bound?

**Type:** **`symbol --> boolean`**

Returns **true** if the variable is globally bound.


## cd

**Type:** **`string --> string`**

Changes the home directory. `(cd "Prog")` causes `(load "hello_world.txt")` to load `Prog/hello_world.txt`. `(cd "")` is the default.


## close

**Type:** **`(stream A) --> (list B)`**

Closes a stream returning the empty list.


## cn

**Type:** **`string --> string --> string`**

Concatenates two strings.


## compile

**Type:** **`(A ==> B) --> A --> (A --> B) --> B`**

Given a **Shen-YACC** non-terminal *y*, an input *x* and an (optional) error continuation *e*, invokes *y* with *x* as the input. In the case of a failure, the continuation *e* is called with the result.


## concat

**Type:** *none*

Concatenates two symbols or booleans.


## cons

**Type:** *none*

A special form that takes an object *e* of type *A* and a list *l* of type *(list A)* and produces a list of type *(list A)* by adding *e* to the front of *l*.


## cons?

**Type:** **`A --> boolean`**

Returns **true** iff the input is a non-empty list.


## declare

**Type:** *none*

Takes a function name *f* and a type *t* expressed as a list and gives *f* the type *t*.


## define

**Type:** *none*

Top level form for Shen definitions.


## defmacro

**Type:** *none*

Top level form for Shen macros.


## defprolog

**Type:** *none*

Top level form for Shen Prolog definitions.


## destroy

**Type:** **`(A --> B) --> symbol`**

Receives the name of a function and removes it and its type from the environment.


## difference

**Type:** **`(list A) --> (list A) --> (list A)`**

Subtracts the elements of the second list from the first.


## do

**Type:** **`A --> A --> A`**

Returns its last argument; polyadic courtesy of the reader.


## element?

**Type:** **`A --> (list A) --> boolean`**

Returns **true** iff the first input is an element in the second.


## empty?

**Type:** **`A --> boolean`**

Returns **true** iff the input is [ ].


## error

**Type:** *none*

A special form: takes a string followed by n (n >= 0) expressions. Prints error string.


## error-to-string

**Type:** **`exception --> string`**

Maps an error message to the corresponding string.


## eval

**Type:** *none*

Evaluates the input.


## eval-kl

**Type:** *none*

Evaluates the input as a KLambda expression.


## explode

**Type:** **`A --> (list string)`**

Explodes an object to a list of strings.


## external

**Type:** **`symbol --> (list symbol)`**

Given a package name, returns the list of symbols external to that package.


## fail

**Type:** *none*

Constructor for the **failure object**.


## fail-if

**Type:**: **`(symbol --> boolean) --> symbol --> symbol)`**

Given a function *f* and an object *x*. If the result of `(f x)` is **true** then the **failure object** is returned, otherwise *x* is returned.


## fix

**Type:** **`(A --> A) --> (A --> A)`**

Applies a function to generate a fixpoint.


## freeze

**Type:** **`A --> (lazy A)`**

Returns a frozen version of its input.


## fst

**Type:** **`(A * B) --> A`**

Returns the first element of a tuple.


## function

**Type:** **`(A --> B) --> (A --> B)`**

Maps a symbol to the function which it denotes.


## gensym

**Type:** **`symbol --> symbol`**

Generates a fresh symbol or variable from a symbol.


## get-time

**Type:** **`symbol --> number`**

For the argument run or real returns a number representing the real or run time elapsed since the last call. One of these options must be supported. For the argument unix returns the Unix time.


## get

**Type:** *none*

Takes a symbol *S*, a pointer *P* and optionally a vector *V* and returns the value in *V* pointed by *P* from *S* (if one exists) or an error otherwise. If *V* is omitted the global property vector is used.


## hash

**Type:** **`A --> number --> number`**

Returns a hashing of the first argument subject to the restriction that the encoding must not be greater than the second argument.


## head

**Type:** **`(list A) --> A`**

Returns the first element of a list; if the list is empty returns an error.


## hd

**Type:** **`(list A) --> A`**

Returns the first element of a list; if the list is empty returns an unspecified object.


## hdstr

**Type:** **`string --> string`**

Returns the first element of a string.


## hdv

**Type:** **`(vector A) --> A`**

Returns the first element of a standard vector.


## if

**Type:** **`boolean --> A --> A --> A`**

takes a boolean *b* and two expressions *x* and *y* and evaluates *x* if *b* evaluates to **true** and evaluates *y* if *b* evaluates to **false**.


## implementation

**Type:** **`--> string`**

Returns a string denoting the implementation on which Shen is running (SBCL etc).


## include

**Type:** **`(list symbol) --> (list symbol)`**

Includes the datatype theories or synonyms for use in type checking.


## include-all-but

**Type:** **`(list symbol) --> (list symbol)`**

Includes all loaded datatype theories and synonyms for use in type checking apart from those entered.


## inferences

**Type:** **`A --> number`**

The input is ignored. Returns the number of logical inferences executed since the last call to the top level.


## input

**Type:** *none*

0-place function. Takes a user input *i* and returns the normal form of *i*.


## input+

**Type:** *none*

Special form. Takes inputs of the form : **&lt;expr&gt;**. Where *d*(**&lt;expr&gt;**) is the type denoted by the choice of expression (e.g. ‘number’ denotes the type number). Takes a user input *i* and returns the normal form of *i* given *i* is of the type *d*(**&lt;expr&gt;**).


## integer?

**Type:** **`A --> boolean`**

Recognises integers.


## intern

**Type:** *none*

Extracts a symbol or boolean from a string.

**Required:** **intern** satisfies the equation

forall _x_ (_x_: boolean v _x_ : symbol) => (intern (str _x_)) = _x_

**Optional:** In some platforms **intern** will also map an embedded number to a number; i.e. `(intern "123")` = **123**. Note that Shen reads certain symbols of special significance (viz. { } ; , :) by inserting whitespace; `{a --> b}` is read as `{ a --> b }` and `foo;` as `foo ;`. It may be possible to use intern to create composite objects containing these characters which do not qualify as Shen symbols.


## internal

**Type:** **`symbol --> (list symbol)`**

Given a package name, returns the list of symbols internal to that package.


## intersection

**Type:** **`(list A) --> (list A) --> (list A)`**

Computes the intersection of two lists.


## it

**Type:** **`--> string`**

Returns the last input to standard input embedded in a string.


## kill

**TODO**


## lambda

**Type:** *none*

Builds a lambda expression from a variable and an expression.


## language

**Type:** **`--> string`**

Returns a string denoting the language on which Shen is running.


## length

**Type:** **`(list A) --> number`**

Returns the number of elements in a list.


## limit

**Type:** **`(vector A) --> number`**

Returns the maximum index of a vector.


## lineread

**Type:** *none*

Top level reader of read-evaluate-print loop. Reads elements into a list. lineread terminates with carriage return when brackets are balanced. **^** aborts lineread.


## load

**Type:** **`string --> symbol`**

Takes a file name and loads the file, returning loaded as a symbol.


## macroexpand

**Type:** *none*

Expand an expression by the available macros.


## map

**Type:** **`(A --> B) --> (list A) --> (list B)`**

The first input is applied to each member of the second input and the results consed into one list.


## mapcan

**Type:** **`(A --> (list B)) --> (list A) --> (list B)`**

The first input is applied to each member of the second input and the results appended into one list.


## make-string

**Type:** *none*

A special form: takes a string followed by n (n >= 0) well-typed expressions; assembles and returns a string.


## maxinferences

**Type:** **`number --> number`**

Returns the input and as a side-effect, sets a global variable to a number that limits the maximum number of inferences that can be expended on attempting to type check a program. The default is 106.


## nl

**Type:** **`number --> number`**

Prints *n* new lines.


## not

**Type:** **`boolean --> boolean`**

Boolean not.


## nth

**Type:** **`number --> (list A)--> A`**

Gets the nth element of a list numbered from 1.


## number?

**Type:** **`A --> boolean`**

Recognises numbers.


## n->string

**Type:** **`number --> string`**

Given a number *n* returns a unit string whose ASCII number is *n*.


## occurrences

**Type:** **`A --> B --> number`**

Returns the number of times the first argument occurs in the second.


## occurs-check

**Type:** **`symbol --> boolean`**

Receives either **+** or **-** and enables/disables occur checking in Prolog, datatype definitions and rule closures. The default is **+**.


## open

**Type:** *none*

Takes two arguments; the location from which it is drawn and the direction (**in**
or **out**) and creates either a source or a sink stream.


## optimise

**Type:** **`symbol --> boolean`**

Receives either **+** or **–** and respectively enables/disables type annotations in the generated KLambda code. The default is **-**.


## or

**Type:** **`boolean --> boolean --> boolean`**

Boolean or.


## os

**Type:** **`--> string`**

Returns a string denoting the operating system on which Shen is running.


## output

**Type:** *none*

A special form: takes a string followed by n (n >= 0) well-typed expressions; prints a message to the screen and returns an object of type string (the string "done").


## package

**Type:** *none*

Takes a symbol, a list of symbols and any number of expressions and places them in a package.


## package?

**Type:** **`symbol --> boolean`**

Returns **true** when the package exists and **false** otherwise.


## port

**Type:** **`--> string`**

Returns a string denoting the version of the port on which Shen is running.


## porters

**Type:** **`--> string`**

Returns a string denoting the name(s) of the author(s) of the port on which Shen is running.


## pos

**Type:** **`string --> number --> string`**

Given a string and a natural number *n* returns the *n*th unit string numbering from zero.


## pr

**Type:** **`string --> (stream out) --> string`**

Takes a string, a sink object and prints the string to the sink, returning the string as a result. If no stream is supplied defaults to the standard output.


## preclude

**Type:** **`(list symbol) --> (list symbol)`**

Removes the mentioned datatype theories and synonyms from use in type checking.


## preclude-all-but

**Type:** **`(list symbol) --> (list symbol)`**

Removes all the datatype theories and synonyms from use in type checking apart from the ones given.


## print

**Type:** **`A --> A`**

Takes an object and prints it, returning it as a result.


## profile

**Type:** **`(A --> B) --> (A --> B)`**

Takes a function represented by a function name and inserts profiling code returning the function as an output.


## profile-results

**Type:** **`(A --> B) --> ((A --> B) * number)`**

Takes a profiled function *f* and returns the total run time expended on *f* since profile-results was last invoked.


## ps

**Type:** *none*

Receives a symbol denoting a Shen function and prints the KLambda source code associated with the function.


## put

**Type:** *none*

3-place function that takes a symbol *S*, a pointer *P* (a string symbol or number), and an expression *E*. The pointer *P* is set to point from *S* to the normal form of *E* which is then returned.


## read

**Type:** **`(stream in) --> unit`**

Takes a stream and reads off the first Shen token; defaults with zero arguments to standard input.


## read-byte

**Type:** **`(stream in) --> number`**

Takes a source and reads the first byte off it; defaults with zero arguments to standard input.


## read-file

**Type:** **`string --> (list unit)`**

Returns the contents of an ASCII file designated by a string. Returns a list of units, where unit is an unspecified type.


## read-file-as-bytelist

**Type:** **`string --> (list number)`**

Returns the contents of an ASCII file designated by a string as a list of bytes.


## read-file-as-string

**Type:** **`string --> string`**

Returns the string contents of an ASCII file designated by a string.


## read-from-string

**Type:** **`string --> (list unit)`**

Reads a list of expressions from a string.


## remove

**Type:** **`A --> (list A) --> (list A)`**

Removes all occurrences of an element from a list.


## reverse

**Type:** **`(list A) --> (list A)`**

Reverses a list.


## set

**Type:**

```
S : symbol; (value S) : A; X : A;
_________________________________
(set S X) : A;
```

Assigns a value to an object.

**Required:** **set** satisfies the equation

forall _s_: symbol forall _v_ (_v_ is defined) =>  (set _s_ _v_)  = (value _s_) = _v_

**Optional:** In some platforms **set** will also associate non-symbol objects .e.g.  `(set true 0)`.  In a dual namespace model, the **defun** and **set** are regarded as creating an association between the symbol and something else; it is not an assertion of identity. Shen requires a dual namespace for symbols because the Shen evaluation strategy for symbols is that symbols are self-evaluating.  In Shen the symbol **f** evaluates to itself.  If we want to get at the value associated with **f**, we type `(value f)`. Hence **f** is not thought of as shorthand for a value, but is merely a symbol to which objects (definitions, global assignments etc) can be attached.

Since **set** is not asserting identity but simply setting up an association between its argument and something else which is retrieved by **value** there is no logical reason why one should restrict the domain of arguments to **value** to symbols.  Generally precedent and implementations do make this restriction even in dual namespace languages, and under type checking Shen does make this restriction.  It is essential that KLambda be able to set the value of any symbol.  What it does beyond that is a matter of choice.


## simple-error

**Type:** **`string --> A`**

Given a string, raises it as an error message.


## snd

**Type:** **`(A * B) --> B`**

Returns the second element of a tuple.


## specialise

**Type:** **`symbol --> symbol`**

Receives the name of a function and turns it into a special form. Special forms are not curried during evaluation or compilation.


## spy

**Type:** **`symbol --> boolean`**

Receives either **+** or **–** and respectively enables/disables tracing the operation of T*.


## step

**Type:** **`symbol --> boolean`**

Receives either **+** or **–** and enables/disables stepping in the trace.


## stinput

**Type:** **`--> (stream in)`**

Returns the standard input stream.


## stoutput

**Type:** **`--> (stream out)`**

Returns the standard output stream.


## str

**Type:** **`A --> string`**

Given an atom (boolean, symbol, string, number) flanks it in quotes. For other inputs an
error may be returned.


## string?

**Type:** **`A --> boolean`**

Recognises strings.


## string->n

**Type:** **`string --> number`**

Maps a unit string to its code point.


## string->symbol

**Type:** **`string --> symbol`**

Extracts a symbol from a string. Raises an error if the passed string cannot be mapped to a valid symbol.


## subst

**Type:** *none*

Given `(subst x y z)` replaces *y* by *x* in *z* where *z* is a list or an atom.


## sum

**Type:** **`(list number) --> number`**

Sums a list of numbers.


## symbol?

**Type:** **`A --> boolean`**

Recognises symbols.


## systemf

**Type:** **`symbol --> symbol`**

Gives the symbol the status of an identifier for a system function; its definition may not be overwritten. Returns its argument.


## tail

**Type:** **`(list A) --> (list A)`**

Returns all but the first element of a non-empty list.


## tc

**Type:** **`symbol --> boolean`**

Receives either **+** or **–** and respectively enables/disables static typing.


## tc?

**Type:** **`A --> boolean`**

Returns **true** iff typechecking is enabled.


## thaw

**Type:** **`(lazy A) --> A`**

Receives a frozen input and evaluates it to get the unthawed result.


## time

**Type:** *none*

Prints the run time for the evaluation of its input and returns its normal form.


## tl

**Type:** *none*

Returns the tail of a list; for **[]** the result is platform dependent.


## tlstr

**Type:** **`string --> string`**

Returns the tail of a string.


## tlv

**Type:** **`(vector A) --> (vector A)`**

Returns the tail of a non-empty vector.


## track

**Type:** **`symbol --> symbol`**

Tracks the I/O behaviour of a function.


## trap-error

**Type:** **`A --> (exception --> A) --> A`**

Tracks the I/O behaviour of a function.


## tuple?

**Type:** **`A --> boolean`**

Recognises tuples.


## type

**Type:** *none*

Used under type checking; takes an expression *e* and a type *A*; *e* is evaluated only if *e* inhabits *A*.


## undefmacro

**Type:** **`symbol --> symbol`**

Removes a macro.


## union

**Type:** **`(list A) --> (list A) --> (list A)`**

Forms the union of two lists.


## unprofile

**Type:** **`(A --> B) --> (A --> B)`**

Unprofiles a function.


## unput

**Type:** *none*

2-place function that takes a symbol *S*, and a pointer *P* (a string symbol or number). The value at *P* (if any) is removed, making *P* point to nothing.

## unspecialise

**Type:** **`symbol --> symbol`**

Receives the name of a function and deletes its special form status.


## untrack

**Type:** **`symbol --> symbol`**

Untracks a function.


## value

**Type:** *none*

Applied to a symbol, returns the global value assigned to it.


## variable?

**Type:** **`A --> boolean`**

Applied to a variable, returns **true**.


## version

**Type:** **`string --> string`**

Changes the version string displayed on startup.


## vector

**Type:** **`number --> (vector A)`**

Creates a vector of size *n*.


## vector?

**Type:** **`A --> boolean`**

Recognises a standard vector.


## vector->

**Type:** **`(vector A) --> number -->  A --> (vector A)`**

Given a vector *V* and an index *i* and object *o*, assigns *o* to *V[i]*.


## <-vector

**Type:** **`(vector A) --> number -->  A`**

Given a vector *V* and an index *i*, retrieves the value stored in *V[i]*.


## write-byte

**Type:** **`number --> (stream out) --> number`**

Takes a byte as an integer *n* between 0 and 255 and writes the corresponding byte to the stream returning *n*.


## write-to-file

**Type:** **`string --> A --> A`**

Writes the second input into a file named in the first input. If the file does not exist, it is created, else it is overwritten. If the second input is a string then it is written to the file without the enclosing quotes. The second input is returned.


## y-or-n?

**Type:** **`string --> boolean`**

Prints the string as a question and returns **true** for *y* and **false** for *n*.


## @p

**Type:** *none*

Takes n (n > 1) inputs and forms the tuple.


## @s

**Type:** *none*

Takes n (n > 1) strings and forms their concatenation


## @v

**Type:** *none*

Takes *n* inputs, the last being a vector *V* and forms a vector of these elements appended to the front of *V*.


## $

**Type:** *none*

Used by the reader; the argument is read in as an exploded list of unit strings.


## +

**Type:** **`number --> number --> number`**

Number addition.


## -

**Type:** **`number --> number --> number`**

Number subtraction.


## *

**Type:** **`number --> number --> number`**

Number multiplication.


## /

**Type:** **`number --> number --> number`**

Number division.


## /.

**Type:** *none*

Abstraction builder, receives n variables and an expression; does the job of a (nested) *lambda* in the lambda calculus.


## >

**Type:** **`number --> number --> boolean`**

Greater than.


## <

**Type:** **`number --> number --> boolean`**

Less than.


## =

**Type:** **`A --> A --> boolean`**

Equal to.


## ==

**Type:** **`A --> B --> boolean`**

Equal to.


## >=

**Type:** **`number --> number --> boolean`**

Greater than or equal to.


## <=

**Type:** **`number --> number --> boolean`**

Less than or equal to.

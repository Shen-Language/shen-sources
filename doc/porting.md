# Porting Shen

The document you are reading is in the folder Porting Instructions. This document explains what you need to do to port Shen to your platform.

## Table of Contents

  * [What is in your Download](#what-is-in-your-download)
  * [Step by step guide](#step-by-step-guide)
  * [Setting Up the Primitive Instruction Set](#setting-up-the-primitive-instruction-set)
  * [Coping with Innocent Symbols](#coping-with-innocent-symbols)
  * [Unwelcome Symbols](#unwelcome-symbols)
  * [Compiling into Single Namespace Languages](#compiling-into-single-namespace-languages)
  * [Tail Recursion Optimisation](#tail-recursion-optimisation)
  * [Currying and Partial Applications](#currying-and-partial-applications)
  * [Optimising your Port](#optimising-your-port)

## What is in Your Download

When you download Shen you will see a directory like this.

  * Test Programs - programs for testing your port
  * Benchmarks - programs for benchmarking your port
  * Shen Sources - sources for Shen in Shen
  * Porting - how to port Shen
  * Platforms - various versions of Shen under different platforms
  * License - the license in full
  * K Lambda - Kl code files

## Step by step guide

### 1. Create a Folder for your Work

Open the folder Platforms and see first if your platform is supported. As of August 2011, only CLisp is supported, but you may find when you open this folder there are many more platforms. If yours is one of them, your task ends here. If not, create a folder named after your platform which we will call Blub. This is your work folder.

### 2. Create and/or Copy the KLambda Files

The folder KLambda contains all the Kl files for building Shen. Copy these files into your Blub folder.

### 3. Create a File of Blub Code: 'primitives.blub'

Your task is to map the code in the Kl files into the Blub language. Copy the Kl files into the Blub folder. Your first task is to encode the primitives of Shen and Kl. Create a file primitives.blub to do that and place your encoding in it.

### 4. Create a File for Mapping Kl to Blub: 'backend.blub'

Create a Blub file which maps any Kl expression into Blub; this is your backend. Call it backend.blub.

### 5. Generate the Blub Files Using the Backend

Now generate the Blub files by running the Kl files through your backend.

### 6. Create an Installation File

Create a file install.blub which loads the primitives.blub file and the generated Blub files into Blub. If Blub allows you to save a working image after installation then save it. This is convenient for the user. If not, then the user will have to run the installation program to call up Shen under Blub.

This is a good place to set some platform-specific values. By convention we distinguish between different releases of Shen and different releases on the same platform. This is important because changes in Shen source occur independently from changes to the port which may only involve backend changes to improve performance and eliminate errors. If you wish to distribute your version, you may from time to time, have to update the release to accomodate the latest features.

To name your version, create the globals `*implementation*`, `*language*`, `*port*` and `*porters*` in your installation routine and set them as follows.

1. `*language*` to a string naming your native host e.g. "Scheme", "Python" etc.
2. `*implementation*` to the string naming your specific implementation of the language "CLisp", "SBCL", "Chicken Scheme" etc.
3. `*port*` to the version of your port. For the first port, "1.0" would be an obvious choice.
4. `*porters*` to you and your coworkers; e.g. "Uncle Tom Cobbley and All"

Leave the `*version*` global alone; it reflects the actual version of Shen used.

### 7. Test Your Port and Benchmark it

The folder Test Programs contains a test suite for your port. Use it to check it works. Use the Benchmark folder to test your performance.

### 8. Create a README File

Supposing the port is good, create a README file detailing anything the user needs to know e.g. how to install Shen under Blub. Put your name on this folder.

### 9. Clean Up the Blub Folder

Remove all the Kl files from the Blub folder and anything not needed to run the installation. Don't forget to include the Shen license file in your folder and on your code.

### 10. Send it to Us if You Want

If you want to share the code, send it to me at Lambda Associates (dr.mtarver@gmail.com).

That's all there is to it. What follows is advice.

## Setting Up the Primitive Instruction Set

Finding correlates for Kl primitives is the first step in porting. There are currently 46 primitive functions needed to implement Kl.

With luck, all of these primitives will find a direct expression in your platform. If not you can still get through by taking advantage of the interdefinability of some of these operations.

All the boolean operations are reducible to a single operation of which perhaps the most obvious is if. Here are the definitions.

```shen
(or P Q) = (if P true Q)
(and P Q) = (if P Q false)
(cond (P Q) ... R ...) = (if P Q (cond ... R ...))
(cond) = (simple-error "condition failure")
```

The definitions cannot be represented by a `defun` since these operations depend essentially on call-by-need evaluation and not strict applicative evaluation that is the Shen/Kl default. Hence they are not defined in the Shen source code. However, if you wish, you can get reduce this set by compiling out the ors, ands, and conds in your backend in favour of if. This reduces your requirement to 1 primitive boolean operation and the target size to 37 functions.

The next interdefinable group is `freeze`, `let` and `lambda`. The pivot here is lambda which can be used to define the other two.

```shen
(let X Y Z) = ((lambda X Z) Y)
(freeze Z) = (lambda V Z) where V is fresh
```

Again these definitions cannot be defined in Kl because they require non-applicative evaluation; but again these definitions can be used in your backend to compile away references to local assignments and freezing. Note if you use the second definition then the definition of `thaw` is

```shen
(define thaw 
  X -> (X 0))
```

(the zero is discarded). If your platform supports zero-place lambda functions then (freeze Z) = (lambda () Z) and the source code definition of thaw can be used. This reduces your requirement to 35 functions.

The maths section can be pruned. In principle one can get down to +, - and > since all the rest are definable in an obvious way. > is not easily definable if floating numbers are involved and needs to be primitive. + and - can themselves be defined in terms of a primitive successor function but this is very inefficient.

One trick for pruning the primitives number?, cons?, string? is to use **characteristic** functions to serve as the basis for recognisors. A function f is characteristic for a set S if f is a total function on S and for all x, if ~ (x e S) then (f x) is undefined. A example is multiplication by 1, which is characteristic for numbers. This leads to a simple recognisor r for S; namely (r x) = true if (f x) is defined and (r x) = false if (f x) is not defined. Thus for `cons?` (non-empty list test) the definition is

```shen
(define cons?
  [] -> false
  X -> (trap-error (do (hd X) true) (/. E false)))
```

The approach is elegant but is predicated on exception handling which many platforms do not support efficiently. Hence although this model was pursued in an prerelease version of Shen, it was not continued.

So in principle Kl can be captured in less than 35 functions. Whether or not you use these equivalences really depends on the resources of your platform.

## Coping with Innocent Symbols

Languages from the Lisp family - which includes Common Lisp, Scheme, New Lisp, Qi and Clojure - support symbols as first class data-objects that can be passed as arguments to functions and returned as values. In languages like Python, there are no symbols in this role, whatever is done by symbols must be done by strings.

Read carefully the section on the semantics of symbols in the Shen spec.

We refer to symbols that are used to self-denote, rather than to refer to functions or other values, as innocent symbols. Thus in the list [John put the car into reverse] the symbol `reverse` is innocent, but in `(map reverse [[1 2] [3 4]])`, the symbol denotes a function. If the platform language does not follow the Lisp tradition of allowing symbols to have semantic ambiguity depending on context, then innocent symbols must be created or simulated in the platform language. There are two challenges.

1. How to represent innocent symbols?
2. How to recognise when a symbol should be treated as innocent and when not?

Let us deal with these issues in turn.

If a symbol occurs immediately after an opening parenthesis, it must denote a function and should be parsed as such. If it occurs within a list or as an argument to a function it should be parsed as an innocent symbol.

You should read up in the Shen specification about non-standard vectors and print vectors. Essentially if innocent symbols are missing from the platform language, we recommend using print vectors to encode them. An innocent symbol is therefore representable as a print vector composed of two elements; a function called (e.g) print-symbol and a string representation of the symbol.

## Unwelcome Symbols

An unwelcome symbol is a symbol which is couched in a character set that the platform will not accept. For instance in many languages, including ML and Prolog, the minus sign is an unwelcome character - it cannot be used within a function name although the underscore _ can be used. How should these symbols be handled?

The unwelcome symbol must be mapped into a welcome symbol. This is best done by uniformly replacing the unwelcome characters by some other characters by reprogramming the intern function. If you intern "element?" to element_question_mark, then the user who types [element?] will return [element_question_mark]. You should program the printer to disguise this shift by programming it to print "element_question_mark" as "element?". Look at the file printer.shen for an example of how this is done for Common Lisp.

Note that you may have to change some of the recognisors in the Shen code. Shen-YACC for instance expects < ... > to flank non-terminals. Similarly you will have to work through the Kl files and replace the offending symbols according to your scheme. You will of course, not do that by hand, but write a program to do that.

A similar technique can be used to **name clashes**; these occur when the identifier used to name a system function in Shen is the same as one used to name a different function in the platform. The trick is, of course, to capture these clashes and rename the offending symbol to the internal version which is used. This can be done either by the backend or within the intern function.

Again you should program the printer to disguise this shift.

## Compiling into Single Namespace Languages

As observed, Shen and Kl are dual namespace languages. This creates a problem when compiling into single namespace languages. In general there is no observable difference between the two unless the user enters a global with the same identifier as a function or vice versa. In that case in a single namespace language, overwriting occurs and in a dual it does not.

In general single and dual namespace languages are observationally equivalent as long as the space of function identifiers and global identifiers are kept disjoint. Such a regime is easily maintained in 99% of all cases by simply checking to see if the identifier is bound to a function (fbound? function test in Shen) if it is to be used as a global or a global (bound? function test in Shen) if used as a function and issuing an error if this is the case.

Rather more difficult are the 1% of cases where the global assignment is dynamically made and the identity of the global is not known at compile time. This function does exactly that.

```shen
(define dynamically-set 
  X Y -> (set X Y))
```

Here (dynamically-set (hd [hd]) 0) will set hd to 0. In a dual namespace this will cause no problem, but in a single namespace it will raise an error or likely cause the system to crash. Let us then consider how Shen and Kl can be compiled into a single namespace language.

If the language does not support innocent symbols then the likeliest strategy is to parse innocent symbols into print vectors in the manner described in the previous section. In this case the expression (set *global* 0) will assign the value zero to the print vector. Now since print vectors cannot actually have values, the evaluation of this expression must call upon the native assignment operation (other conventions can be imagined but this is prima facie the most logical). Let us suppose that assign! does the job of assignment in Blub. In this case, 'set' will be defined as

```shen
(define set
  Symbol Value -> (if (function-identifier? Symbol) 
                      (error "~A is a function.~%" Symbol) 
                      (assign! (get-global-symbol Symbol) Value)))
```

Here the semantics of `set` prevents the user from overwriting a function by a global assignment. The function `get-global-symbol` actually extracts the platform global variable which is updated. A similar strategy can be used for `define`.

The only disadvantage of this strategy is that it is slow in execution, since every global assignment must first pass a test and then be mapped before any assignment is made. Practically however, you can arrange for this to be avoided in your backend. In 99% of cases the identity of the global is known in advance and hence you can perform these tests and mappings at compile time and hence compile them out. Only in the rare cases where the assignment is made using dynamically generated variables, do you need to retain the code in the original form.

If you are compiling into a language like Scheme, where you do not need to use print vectors for innocent symbols, the procedure is the same, except that `get-global-symbol` will not be needed.

## Tail Recursion Optimisation

Kl and Shen both expect tail recursion optimisation and this is heavily used in the Shen source. Certain platforms like Python do not support this feature. Hence you may find that your code will not run under such a platform.

In these cases, the platform generally expects the programmer to write in a iterative style and provides some mechanism for doing that; either FOR, WHILE, DO, LOOP etc. You have to learn how to map tail recursive functions into this idiom to make the port work. There are no more words of advice here.

## Currying and Partial Applications

Qi II, Kl and Shen all respect the lambda calculus and therefore support and expect currying and partial applications. Some languages, like Common Lisp, do not support currying. Generally, even with such platforms, currying is no problem if you can statically recognise that the application is a partial one. For example, knowing that 'append' is a 2-place function enables your backend to generate the appropriate closure.

However if the function is higher-order, then the problem is more difficult since the partial application may be made at run time. The case you have to consider is one where there is an application of an input to another part of the input.

```shen
(define reduce
  _ [] Base -> Base
  C [X] Base -> (C X Base)
  C [X Y | Z] Base -> (reduce C [(C X Y) | Z] Base))
```

Here `(reduce + L 0)` totals a list `L` of numbers.

Here we discuss three approaches to writing your backend to cope with currying in higher-order functions - dynamic currying, static currying and currying on demand.

Qi I and II were written in Lisp and used dynamic currying. This meant that if an application was made by a higher-order function during run time, Qi II would pause to see if a partial application was made and if necessary it would dynamically generate a closure based on calculating the arity of the partially applied function. This was rather slow even with hash table lookup.

An alternative is static currying. In static currying, all functions are curried at compile time and hence, apart from a few functions declared as special (i.e. not to be curried), all functions are 1-place functions. This solves the overload of dynamic currying but raises significant problems of its own.

In CLisp, tail recursive functions of an arity > 1, do not compile with tail recursion optimisation when static currying is applied. Therefore programs may crash which rely on TRO in the compilation of these functions. The significance can be seen in the n queens program in the Test Programs folder which crashed under static currying with (n-queens 6) (platform CLisp) but which ran fine under dynamic currying.

An alternative to both approaches is currying on demand.

Currying on demand is used for higher-order functions in the CL port of Shen. The function argument is applied in an uncurried form and 99% of the time this is the correct application. If the function is intended to be used in a partial application, then an error will be raised. This error should be trapped and in that case dynamic currying is used. For those who understand Lisp, here is the Shen map (MAPCAR) function.

```lisp
(DEFUN map (V1593 V1594)
  (COND
  	((NULL V1594)
  	 NIL)
    ((CONSP V1594)
     (CONS (trap-error (FUNCALL V1593 (CAR V1594))
                       (lambda E (FUNCALL (nest-lambda V1593)
                                          (CAR V1594)))) 
           (map V1593 (CDR V1594))))
    (T
     (shen_sysf_error 'map))))
```

Here the uncurried call is made (green) and if an error is raised, then it is trapped and the nest-lambda function constructs a closure based on the arity of the function (red) and repeats the application. Extra security can be gained by examining the error (E) using error-to-string and verifying it is an arity error before currying.

We strongly recommend this approach over static or dynamic currying in platforms that do not provide partial application (like CL). The following table compares the three methods.

| Static Currying | Dynamic Currying | Currying on Demand |
|--|--|--|
| Higher-order functions run quickly | Higher-order functions run slowly | Higher-order functions run quickly |
| Never requires arity lookup | Always requires arity lookup | Hardly ever requires arity lookup |
| Makes TRO fail in some platforms | TRO never fails because of this method | TRO never fails because of this method |

## Optimising your Port

The performance of Shen is as much dependent on the nature of the port as it is on the platform it is ported to. The difference between a naive port and an optimised one can amount to two orders of magnitude. In general, understanding how to get the fastest port will revolve on understanding the bottlenecks and optimisations inherent in your chosen platform. What follows here is therefore, by necessity, quite general.

Basically there are two forms of optimisation: **peephole optimisation** and **backend optimisation**.

**Peephole optimisation** occurs when the native platform offers an inbuilt system function which is faster than the canned version that comes with Shen. The implementation of Shen follows a 'batteries included' model wherein nothing is assumed of the platform once the primitives in Kl are defined. Hence the source code includes definitions of standard functions which may be less efficient than easily accessible platform specific versions.

The Shen license allows the platform developer to replace these definitions provided the spec of the function is not changed i.e. the performance is improved but the behaviour still remains conformant to the standard. In that case it is feasible to use the system version and the Shen definition should be replaced by the new version but the old name should be retained i.e. the body of the definition of the Shen version should be changed to point to the system version. In this way the resulting port conforms to the Shen standard. This sort of code should be put into a file overwrite.blub in your port folder.

Peephole optimisation can be very significant for oft-used low level functions. See for instance the file overwrite.lsp in the CL directory which replaces slow Shen generic functions by fast CL ones.

**Backend optimisation** occurs through the backend which compiles Kl to native code. For instance, Kl contains no provision for distinguishing EQUAL and EQ. This is deliberate. In my opinion, such optimisations are the province of the compiler and the Common Lisp Qi actually performed these optimisations automatically on compiling into Common Lisp. Backend optimisation is deeply dependent on the platform. A special case of this is pattern factorisation. Pattern factorisation removes repeated tests in Kl code generated from overlapping patterns in a Shen function definition (see www.lambdassociates.org/Book/page235.htm for an explanation). Performing this efficiently requires a JUMP or GOTO to be supported by the platform. At current time (July 2011) this is yet not used in the Lisp port of Shen.

# Port implementation performance recommendations

## Currying and partial applications

**TODO**

## Equality checks

**TODO**

## Peephole optimizations

### Dictionaries

ShenOS 20 introduced the dictionary datatype to the kernel. A default implementation in pure Shen is provided, but ports can make it perform better in two ways, depending on what the underlying platform makes available.

Making dictionaries perform better will not only make uses of dictionaries faster, but the compiler itself, because the ShenOS kernel uses them internally for various features.

#### Option 1: Overriding `hash` with a native implementation that performs better

The `hash` function provided by Shen is very slow compared to native hash functions on the underlying platform. Ports that are able to do so should override it and use a native version because it is going to have a big impact on the performance of dictionaries. It is an easy way to get a performance bump without the need to provide the other dictionary functions.

The type of `hash` is `A --> number --> number`. The first argument is the object being hashed, the second argument is an upper bound and the resulting integer has to be a number between 0 and that upper bound.

#### Option 2: Overriding the various dictionary functions

Ports that don't have access to a native hash function have no choice but to override the dictionary functions and replace them with native ones:

- `(dict Size)`: constructor. Size is a positive integer greater than zero. It is a hint for how big the backing storage should be, and can be safely ignored if the underlying platform has no use for it.
- `(dict? Dict)`: predicate. Should return true if the argument represents a dictionary, false otherwise.
- `(dict-count Dict)`: given a dictionary, return the amount of items in it.
- `(dict-> Dict Key Value)`: setter, sets the binding of `Key` in `Dict` to be `Value`.
- `(<-dict Dict Key)`: getter, retrieves the value bound ot `Key` in `Dict`.
- `(<-dict/or Dict Key OrDefault)`: like `<-dict` but returns the result of thawing `OrDefault` instead of throwing an error when `Key` has no binding in `Dict`.
- `(dict-rm Dict Key)`: deleter, removes the binding of `Key` in `Dict`, if any.
- `(dict-fold F Dict Acc)`: walks the dictionary calling `(F Key Value Acc)` for each item in it. The result of each call is the new value of `Acc`, once no more items are left, the final value of `Acc` is returned.
- `(dict-keys Dict)` : given a dictionary, returns  a list containing all keys container in it.
- `(dict-values Dict)`: given a dictionary, returns  a list containing all values container in it.

If dicts native to the platform are provided, the list of functions to be overriden is: `dict`, `dict?`, `dict-count`, `dict->`, `<-dict/or`, `dict-rm`,`dict-fold`.

The rest are optional. By default `<-dict` is implemented on top of `<-dict/or` and `dict-keys` and `dict-values` on top of `dict-fold`. 

### File I/O

Some I/O functions implemented in Shen that are good candidates to override with native versions:

- `(read-file-as-bytelist Filename)`
- `(read-file-as-string Filename)`

The implementations in Shen read the file bytes one by one using `read-byte`, but most platforms probably have the possibility of reading the whole file in big chunks.

### Exception-less `*/or` functions

ShenOS 20 adds some new functions with names ending in `/or`. These functions are variants of their regular versions that raise an error when they fail. The `/or` versions instead, take an extra parameter (a frozen expression), and thaw it to get the result instead of raising an error.

In platforms whith expensive exception handling, these exception-less variants will be faster, but some have to be implemented natively to become faster because by default they are implemented on top of their exception-raising counterparts.

- `get/or`: doesn't need to be implemented natively, and `get` is implemented on top of it.
- `value/or`: implemented on top of `value`, needs to be implemented natively to be fast.
- `<-address/or`: implemented on top of `<-address`, needs to be implemented natively to be fast.
- `<-vector/or`: doesn't need to be implemented natively.

These functions are used internally by the kernel, on platforms with expensive exception handling, providing faster versions of these functions will improve the performance of other parts of the system.

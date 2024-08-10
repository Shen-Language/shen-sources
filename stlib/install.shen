(tc -)
(load "Symbols/symbols1.shen")
(tc +)
(load "Symbols/symbols2.shen")
(tc +)
(load "Maths/macros.shen")
(load "Maths/maths.shen")
(tc -)
(load "Maths/rationals.dtype")
(tc +)
(load "Maths/rationals.shen")
(tc -)
(load "Maths/complex.dtype")
(tc +)
(load "Maths/complex.shen")
(tc -)
(load "Maths/numerals.dtype")
(tc +)
(load "Maths/numerals.shen")
(load "Lists/lists.shen")
(load "Strings/macros.shen")
(load "Strings/strings.shen")
(tc -)
(load "Strings/smart.shen")
(load "Vectors/macros.shen")
(load "Encrypt/encrypt.shen")
(tc +)
(load "Vectors/vectors.shen")
(load "IO/prettyprint.shen")
(tc -)
(load "IO/delete-file.shen")
(tc +)
(load "IO/files.shen")
(load "Tuples/tuples.shen")
(load "package-stlib.shen")
(tc -)

(cd "Lib/Tk")
(load "loadme.shen")

(tc -)
(cd "Lib/Concurrency")
(load "concurrency.dtype")
(tc +)
(load "concurrency.shen")

(tc -)
(cd "Lib/IDE")
(load "idedec.shen")
(tc +)
(load "ide.shen")
(tk.types -)  

\\ all external functions of the standard library are declared as system functions
(let External  (external stlib)
     ExternalF (filter (/. X (> (arity X) -1)) External)
     Systemf   (map (fn systemf) ExternalF)
     ok)
    
(preclude-all-but [])
(tc -)
(set shen.*userdefs* [])
(cd "") 

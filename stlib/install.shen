(tc -)
(if (= (language) "Scheme") (load "patches-scheme.shen") skip)

(cd "Lib/StLib")
(load "install.shen")

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

(preclude-all-but [])
(set shen.*userdefs* [])
(cd "")
(tc -)
(if (= (language) "Scheme") (ide.myIDE) skip)


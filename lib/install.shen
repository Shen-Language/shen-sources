(tc -)
(cd "lib")
(if (= (language) "Scheme") (load "patches-scheme.shen") skip)

(cd "lib/stlib")
(load "install.shen")

(cd "lib/tk")
(load "loadme.shen")

(tc -)
(cd "lib/concurrency")
(load "concurrency.dtype")
(tc +)
(load "concurrency.shen")

(tc -)
(cd "lib/ide")
(load "idedec.shen")
(tc +)
(load "ide.shen")
(tk.types -)

(preclude-all-but [])
(set shen.*userdefs* [])
(cd "")
(tc -)
(if (= (language) "Scheme") (ide.myIDE) skip)


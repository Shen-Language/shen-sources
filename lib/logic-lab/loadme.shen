(tc -)
(map (fn load) ["macros.shen" "compiler.shen"])
(tc +)
(load "gpa.shen")
(if (= (arity tk-input) -1)
    skip
    (load "gui.shen"))
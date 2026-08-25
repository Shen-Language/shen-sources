(package logic [step ok .gpa .gpa.tactics .gpa.tactics.menu | (external tk)]

(define gui
 -> (let	Window (tk.widget .gpa window)
      MenuButton (tk.widget .gpa.tactics menubutton -text "Tactics" -menu .gpa.tactics.menu)
      Menu (tk.widget .gpa.tactics.menu menu)
      Pack (tk.pack [MenuButton])
      Tactics (value *tactics*)
      Fill (map (/. X (tk.menuitem Menu add -label (str X) -command (freeze (set *gpa-read* X)))) Tactics)
      ok))

(define gpa-read
  -> (let Value (value *gpa-read*)
          Set (set *gpa-read* "")
          Print (print Value)
          NL (nl)
          Value)                  where (not (= "" (value *gpa-read*)))
  -> (gpa-read))

(set *gpa-read* "")

(declare gpa-read [--> [step --> step]]) )

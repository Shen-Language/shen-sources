(package calc (external calc)

(declare evaluate-display [label --> [string --> string]])

(define evaluate-display
  Display DisplayText -> (let Result (str (eval (read-from-string DisplayText)))
                              (tk.putw Display -text Result))) )
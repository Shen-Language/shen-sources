(package calc (external calc)

(define show
   {label --> string --> string}
   Display Text -> (let DisplayText (tk.getw Display -text)
                        (cases (digit? Text)                     (tk.putw Display -text (cn DisplayText Text))
                               (= "(" Text)                      (tk.putw Display -text (cn DisplayText Text))
                               (= ")" Text)                      (tk.putw Display -text (cn DisplayText Text))
                               (= "." Text)                      (tk.putw Display -text (cn DisplayText Text))
                               (element? Text ["+" "-" "*" "/"]) (tk.putw Display -text (@s DisplayText " " Text " "))
                               (= Text "sqrt")                   (tk.putw Display -text (cn "sqrt " DisplayText))
                               (= Text "=")                      (evaluate-display Display DisplayText)
                               (= Text "cancel")                 (tk.putw Display -text ""))))
                              
(defmacro infix   
  [M Op N] -> [Op M N]   where (element? Op [+ / - *]))                                                 
                       
(define calculator
  {--> symbol}
   -> (let F1Text       (tk.putw .below.f1 -text "Calculator")
           F1Width      (tk.putw .below.f1 -width 20)
           F1Command    (tk.putw .below.f1 -command (freeze (call-calculator)))
           ok))

(define call-calculator
  {--> symbol}
  -> (let Window      (tk.widget .calculator window -bg (ide.bg))
          Frame       (tk.widget .calculator.buttons frame)
          Display     (tk.widget .calculator.display label -width 25 -text "")
          MakeButton  (/. Button Text (tk.widget Button button 
                                                 -text Text
                                                 -bg (ide.bg)
                                                 -fg "white"
                                                 -relief flat 
                                                 -width 5
                                                 -command (freeze (show Display Text))))          
          B0          (MakeButton .calculator.buttons.b0 "0")
          B1          (MakeButton .calculator.buttons.b1 "1")
          B2          (MakeButton .calculator.buttons.b2 "2")
          B3          (MakeButton .calculator.buttons.b3 "3")
          B4          (MakeButton .calculator.buttons.b4 "4")
          B5          (MakeButton .calculator.buttons.b5 "5")
          B6          (MakeButton .calculator.buttons.b6 "6")
          B7          (MakeButton .calculator.buttons.b7 "7")
          B8          (MakeButton .calculator.buttons.b8 "8")
          B9          (MakeButton .calculator.buttons.b9 "9")
          BDot        (MakeButton .calculator.buttons.bdot ".") 
          B+          (MakeButton .calculator.buttons.+ "+")
          B-          (MakeButton .calculator.buttons.- "-")
          B*          (MakeButton .calculator.buttons.* "*")
          B/          (MakeButton .calculator.buttons./ "/")
          Sqrt        (MakeButton .calculator.buttons.sqrt "sqrt")
          BC          (MakeButton .calculator.buttons.cancel "cancel")
          BLParen     (MakeButton .calculator.buttons.lparen "(")
          BRParen     (MakeButton .calculator.buttons.rparen ")")
          B=          (MakeButton .calculator.buttons.= "=")
          PackB       (tk.grid [[B0 B1 B2 B3 B4]
                                [B5 B6 B7 B8 B9]
                                [B+ B- B* B/ BDot]
                                [Sqrt BLParen BRParen BC B=]])
          Pack        (tk.pack [Display Frame] -side top -pady 10)
          ok))  )
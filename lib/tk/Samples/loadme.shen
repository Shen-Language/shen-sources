(package calc 
   
   (append (external tk) (internal tk)
                      [ide.bg .below.f1 .calculator .calculator.buttons .calculator.display 
                      .calculator.buttons.b0 .calculator.buttons.b1 .calculator.buttons.b2 
                      .calculator.buttons.b3 .calculator.buttons.b4 .calculator.buttons.b5 
                      .calculator.buttons.b6 .calculator.buttons.b7 .calculator.buttons.b8 
                      .calculator.buttons.b9 .calculator.buttons.bdot .calculator.buttons.+ 
                      .calculator.buttons.- .calculator.buttons.* .calculator.buttons./ 
                      .calculator.buttons.sqrt .calculator.buttons.cancel .calculator.buttons.lparen 
                      .calculator.buttons.rparen .calculator.buttons.=])

(tc -)
(load "C:/Users/shend/OneDrive/Desktop/Shen/S39/Lib/Tk/Samples/wo-types.shen")
(tk.types +)
(tc +)
(load "C:/Users/shend/OneDrive/Desktop/Shen/S39/Lib/Tk/Samples/calculator.shen")
(tk.types -))
(tc +)
(tk.types +)
(tk.widget .b button)
(tk.pack [.b])
(tk.putw .b -text "Hello World")
(tk.putw .b -command (freeze (pr "Hello World")))
(tk.tcl->shen)
(tk.widget .b1 button 
        -text "Drink Me" 
        -fg "green" 
        -bg "yellow" 
        -command (freeze (pr "I'm shrinking!")))
        
(tk.widget .b2 button 
        -text "Bang" 
        -height 50 
        -width 50 
        -command (freeze (pr "bang!")))
        
(tk.pack [.b1 .b2])
(tk.tcl->shen)
(tk.tcl->shen)
(tk.unpack [.b1 .b2])

(define mycheckbutton
  {symbol --> button}
  Widget -> (let Button  (tk.widget Widget button)
                 Relief  (tk.putw Button -relief sunken)
                 BG      (tk.putw Button -bg "white")
                 Text    (tk.putw Button -text " ")
                 Command (tk.putw Button -command (freeze (toggle Button)))
                 Button))
  
(define toggle
  {button --> string}
  Widget -> (if (= (tk.getw Widget -text) " ")
                (tk.putw Widget -text "X")
                (tk.putw Widget -text " ")))

(mycheckbutton .b6)
(tk.pack [.b6])
(tk.tcl->shen)

(tk.widget .e entry)
(tk.pack [.e])
(tk.getw .e -text)
(tk.putw .e -text "David")
(tk.unpack [.e])

(tk.widget .t text)
(tk.pack [.t])
(tk.getw .t -text)
(tk.putw .t -text "hello world")
(tk.unpack [.t])

(tk.image shenlogo "C:/Users/shend/OneDrive/Desktop/Shen Website/logo3.gif")
(tk.widget .l label -image shenlogo)
(tk.pack [.l])
(tk.unpack [.l])

(tk.font mybigfont -family "Courier" -size 20)
(tk.widget .l label -font mybigfont -text "Wow!")
(tk.pack [.l]) 

(tk.messagebox -title "Overwrite?" 
               -type yesnocancel 
               -icon warning 
               -message "Overwrite file?")
                        
(tk.messagebox -type ok 
               -title "Query Result" 
               -message "Found 1000 matches") 
               
(tk.menu .mymenu 4) 

(tk.putw .mymenu.b1 -text "Selection 1")
(tk.putw .mymenu.b1 -command (freeze (pr "1")))

(tk.putw .mymenu.b2 -text "Selection 2")
(tk.putw .mymenu.b2 -command (freeze (pr "2")))

(tk.putw .mymenu.b3 -text "Selection 3")
(tk.putw .mymenu.b3 -command (freeze (pr "3")))

(tk.putw .mymenu.b4 -text "Selection 4")
(tk.putw .mymenu.b4 -command (freeze (pr "4"))) 

(tk.widget .c canvas -height 200 -width 200)
(tk.pack [.c])
(tk.draw .c line [0 0 100 100 150 105])
(tk.draw .c arc [10 20 50 50] -fill "maroon")  

(tk.widget .b1 button -text "1")
(tk.widget .b2 button -text "2")
(tk.widget .b3 button -text "3")
(tk.widget .b4 button -text "4")
(tk.grid [[.b1 .b2] [.b3 .b4]] -padx 10 -pady 10) 

(tk.widget .f1 frame -relief groove -borderwidth 10 -background "orange")
   
(tk.widget .f1.b1 button -text "Inside frame f1")
(tk.widget .f1.b2 button -text "Also inside frame f1")
  
(tk.pack [.f1.b1 .f1.b2] -side left)
(tk.pack [.f1])
  
(tk.widget .b1 button -text "Outside frame f1")
(tk.widget .b2 button -text "Also outside frame f1")
  
(tk.pack [.b1 .b2])
  
(time (tk.url "https://shenlanguage.org/")) 
(time (let ASCII (tk.url "https://shenlanguage.org/")
             Text   (tk.url->text ASCII)
             Text))
(time (let ASCII     (tk.url "https://en.wikipedia.org/wiki/Leeds")
             Text      (tk.url->text ASCII)
             Sentences (tk.text->sentences Text 50)
             Sentences)) 
(time (tk.links (tk.url "https://shenlanguage.org/")))
   
(tk.widget .hello button -text "Hello World" -command (freeze (output "hello world~%")))
(tk.widget .abort button -text "Abort" -command (freeze (error "aborted")))
(tk.pack [.hello .abort])
(tk.event-loop)                                                         
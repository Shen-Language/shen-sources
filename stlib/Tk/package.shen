(package tk

  [-foreground -background -highlightthickness -type yesnocancel -activebackground -highlightcolor -cursor 
-anchor n ne e se s sw w nw -state normal active disabled -overrelief -compound center -insertofftime -insertontime 
-outline -color -arrow both first last -start -extent -wrap none char word -spacing1 -spacing2 -spacing3 -rmargin 
-overstrike -offset -underline -fg -command -text button label -selectbackground -selectborderwidth hollow
entry text canvas line oval arc rectangle polygon -bg groove -activeforeground -disabledforeground
cursor sunken flat raised side -fill -color left right top bottom x y -padx -pady -ipadx -takefocus solid
-ipady -height -width -borderwidth -bd -repeatdelay -repeatinterval -justify -underline -wraplength -relief -family 
frame window -side -variable -font -label -message grey -image -size -bitmap -show -selectforeground
(protect X_cursor) arrow based_arrow_down based_arrow_up boat bogosity bottom_left_corner rescale state 
-multiple -slant italic bold bottom_right_corner bottom_side bottom_tee box_spiral center_ptr circle clock 
coffee_mug cross cross_reverse crosshair diamond_cross dot dotbox double_arrow -setgrid -xscrollcommand exists
draft_large draft_small draped_box exchange fleur gobbler gumby hand1 hand2 heart icon iron_cross left_ptr left_side 
left_tee leftbutton ll_angle lr_angle man middlebutton mouse pencil pirate plus question_arrow right_ptr right_side 
right_tee rightbutton rtl_logo sailboat sb_down_arrow sb_h_double_arrow sb_left_arrow sb_right_arrow sb_up_arrow 
sb_v_double_arrowshuttle sizing spider spraycan star target tcross top_left_arrow top_left_corner top_right_corner 
top_side top_tee trek ul_angle umbrella ur_angle watch xterm -title -icon -yscrollcommand -autoseparators
-blockcursor -endline -inactiveselectbackground -insertunfocussed -maxundo -tabstyle -undo tabular wordprocessor
-closeenough -confine -scrollregion -xscrollincrement -yscrollincrement -colormap -screen -use -after -before
-expand -in -column -columnspan -row -rowspan -sticky -weight -slant roman italic scrollbar eot . tk.destroy]
 
 (declare url           [string --> [list number]])
 (declare require       [string --> symbol])
 (declare tcl->shen     [--> unit])
 (declare shen->tcl     [string --> string])
 (declare event-loop    [--> A])
 (declare types         [symbol --> [list symbol]])
 (declare my-pack       [[list widget] --> [[options pack] --> [list widget]]]) 
 (declare my-grid       [[list [list widget]] --> [[options grid] --> [list [list widget]]]])
 (declare unpack        [[list widget] --> [list widget]])
 (declare exit          [--> symbol]) 
 (declare widgetclass   [symbol --> symbol])
 (declare putw          [A --> [[attribute A B] --> [B --> B]]])
 (declare getw          [A --> [[attribute A B] --> B]])
 (declare my-image      [symbol --> [string --> [[options image] --> image]]])
 (declare my-font       [symbol --> [[options font] --> font]])
 (declare my-messagebox [[options messagebox] --> string])
 (declare menu          [symbol --> [number --> [window * [canvas * [list button]]]]])
 (declare root          [--> window])
 (declare my-openfile   [[options openfile] --> string])
 (declare winfo         [symbol --> [[attribute winfo A] --> A]])
 (declare tk.destroy    [symbol --> symbol])        
             )
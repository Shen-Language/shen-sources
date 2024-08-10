toplevel .see -bg "#00486A"
frame .see.tx -bg "#00486A"
scrollbar .see.tx.v_scroll -command ".see.tx.text yview" -bg "#00486A"
text .see.tx.text -wrap none -yscrollcommand ".see.tx.v_scroll set" -bg "#00486A" -height 50
button .see.tx.text.b1 -text "1" -fg white -bg "#00486A" -relief flat
button .see.tx.text.b2 -text "2" -fg white -bg "#00486A" -relief flat
button .see.tx.text.b3 -text "3" -fg white -bg "#00486A" -relief flat
button .see.tx.text.b4 -text "4" -fg white -bg "#00486A" -relief flat
button .see.tx.text.b5 -text "5" -fg white -bg "#00486A" -relief flat
button .see.tx.text.b6 -text "6" -fg white -bg "#00486A" -relief flat
button .see.tx.text.b7 -text "7" -fg white -bg "#00486A" -relief flat
button .see.tx.text.b8 -text "8" -fg white -bg "#00486A" -relief flat
button .see.tx.text.b9 -text "9" -fg white -bg "#00486A" -relief flat
button .see.tx.text.b10 -text "10" -fg white -bg "#00486A" -relief flat
button .see.tx.text.b11 -text "11" -fg white -bg "#00486A" -relief flat
button .see.tx.text.b12 -text "12" -fg white -bg "#00486A" -relief flat
button .see.tx.text.b13 -text "13" -fg white -bg "#00486A" -relief flat
button .see.tx.text.b14 -text "14" -fg white -bg "#00486A" -relief flat
button .see.tx.text.b15 -text "15" -fg white -bg "#00486A" -relief flat
button .see.tx.text.b16 -text "16" -fg white -bg "#00486A" -relief flat
button .see.tx.text.b17 -text "17" -fg white -bg "#00486A" -relief flat
button .see.tx.text.b18 -text "18" -fg white -bg "#00486A" -relief flat
button .see.tx.text.b19 -text "19" -fg white -bg "#00486A" -relief flat
button .see.tx.text.b20 -text "20" -fg white -bg "#00486A" -relief flat
button .see.tx.text.b21 -text "21" -fg white -bg "#00486A" -relief flat

pack .see.tx.text.b1 \
     .see.tx.text.b2 \
     .see.tx.text.b3 \
     .see.tx.text.b4\
     .see.tx.text.b5 \
     .see.tx.text.b6 \
     .see.tx.text.b7 \
     .see.tx.text.b8 \
     .see.tx.text.b9 \
     .see.tx.text.b10 \
     .see.tx.text.b11 \
     .see.tx.text.b12 \
     .see.tx.text.b13 \
     .see.tx.text.b14 \
     .see.tx.text.b15 \
     .see.tx.text.b16 \
     .see.tx.text.b17 \
     .see.tx.text.b18 \
     .see.tx.text.b19 \
     .see.tx.text.b20 .see.tx.text.b21 -fill x
pack .see.tx.v_scroll -side right -fill y
pack .see.tx.text -side left
pack .see.tx -side top
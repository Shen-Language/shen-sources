(package tk (external tk)

(defmacro tk-macro  
  [widget Widget Class | Slots] -> [my-widget Widget Class (shen.cons-form Slots)]
  [pack Widgets | Options]      -> [my-pack Widgets (shen.cons-form Options)]
  [grid Widgets | Options]      -> [my-grid Widgets (shen.cons-form Options)]
  [openfile | Options]          -> [my-openfile (shen.cons-form Options)] 
  [opencolour | Options]        -> [my-opencolour (shen.cons-form Options)]          
  [savefile | Options]          -> [my-savefile (shen.cons-form Options)]
  [messagebox | Options]        -> [my-messagebox (shen.cons-form Options)]
  [draw Canvas Shape Coordinates | Options] -> [my-draw Canvas Shape Coordinates (shen.cons-form Options)]
  [tk-input+ Type]              -> [my-tk-input+ (shen.cons-form Type)]
  [image Symbol Path | Options] -> [my-image Symbol Path (shen.cons-form Options)]
  [font Font | Options]         -> [my-font Font (shen.cons-form Options)]))
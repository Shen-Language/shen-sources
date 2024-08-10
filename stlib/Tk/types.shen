(package tk (external tk)

(datatype general

    S : symbol; Widget : widgetclass; Options : (options Widget);
    _____________________________________________________________ 
    (my-widget S Widget Options) : Widget;
    
    _________________
    [] : (options Widget);
    
    Attribute : (attribute Widget A);
    Value : A; 
    Options : (options Widget);
    ______________________________________________
    [Attribute Value | Options] : (options Widget);
   
    if (element? Widget [button frame label entry text canvas window button])
    _________________________________________________________________________
    Widget : widgetclass;
     
    Canvas : canvas; Shape : shape; Coor : (list number); Options : (options Shape);
    ________________________________________________________________________________
    (my-draw Canvas Shape Coor Options) : symbol;
    
    if (element? Shape [line arc rectangle oval polygon])
    _____________________________________________________
    Shape : shape;
    
    if (color? C)
    _______________
    C : color;
    
    if (image? I)
    _____________
    I : image;
    
    if (font? F)
    ____________
    F : font;
    
    if (element? State [normal active disabled])
    ____________________________________________
    State : state;
    
    if (cursor? C)
    _______________
    C : cursor;  
    
    if (element? R [raised sunken flat groove])
    ___________________________________________
    R : relief;
    
    if (element? C [none bottom top left right center])
    ___________________________________________________
    C : compound;
    
    if (element? X/Y [x y none both])
    _________________________________
    X/Y : fill;
    
    if (element? S [left right top bottom])
    _______________________________________
    S : side;
    
    if (element? J [right left center])
    ___________________________________
    J : justify;
    
    if (family? Family)
    ___________________
    Family : family;
    
    if (element? Anchor [n ne e se s sw w nw center])
    _________________________________________________
    Anchor : anchor;
    
    if (element? Binary [0 1])
    _________________________
    Binary : binary;
    
    if (element? W [none char word])
    ________________________________
    W : wrap;
    
    if (element? W [none hollow solid])
    ________________________________
    I : insertion;
    
    if (element? T [tabular wordprocessor])
    ________________________________________
    T : tabstyle;
    
    if (element? W [normal bold])
    ______________________________
    W : weight;
    
    if (element? S [roman italic])
    ____________________________________
    S : slant;
    
    if (element? A [both first last none])
    ______________________________________
    A : arrow;)
    
(datatype buttons

    if (= button (widgetclass B))
    _____________________________    
    B : button;
    
    W : button;
    ___________
    W : widget; 
    
    _______________________________
    -fg : (attribute button color); 
         
    _______________________________
    -bg : (attribute button color);
    
    ___________________________________
    -foreground : (attribute button color);
    
    _______________________________________
    -background : (attribute button color);
    
    _______________________________________
    -command : (attribute button (lazy A));
    
    _______________________________________
    -image : (attribute button image);  
    
    _____________________________________
    -underline : (attribute button number);
    
    ________________________________
    -padx : (attribute button number);
    
     _________________________________
    -pady : (attribute button number);
    
     _________________________________
    -ipadx : (attribute button number);
    
     _________________________________
    -ipady : (attribute button number);
    
    ___________________________________
    -relief : (attribute button relief);
    
     ____________________________________
    -justify : (attribute button justify);
    
     _______________________________________
    -wraplength : (attribute button number);
    
    ________________________________________________
    -highlightthickness : (attribute button number); 
    
    ____________________________________
    -height : (attribute button number);
    
    ___________________________________
    -width : (attribute button number);
    
    ___________________________________
    -text : (attribute button string);      
        
    ___________________________________
    -font : (attribute button font);
    
    _____________________________________________
    -activebackground : (attribute button color);
    
    _____________________________________________
    -activeforeground : (attribute button color);
    
    ___________________________________________
    -highlightcolor : (attribute button color);
    
    _________________________________________
    -repeatdelay : (attribute button number);    
    
    __________________________________________
    -repeatinterval : (attribute button number);
    
    ____________________________________
    -anchor : (attribute button anchor);
    
    _____________________________________
    -state : (attribute button state); 
    
    ________________________________________
    -overrelief : (attribute button relief); 
        
    _________________________________________    
    -compound : (attribute button compound);
    
    _________________________________________
    -borderwidth : (attribute button number);
    
    ________________________________
    -bd : (attribute button number);
    
    ____________________________________
    -cursor : (attribute button cursor);
    
    ______________________________________________    
    -disabledforeground : (attribute button color);
    
    ______________________________________
    -takefocus : (attribute button binary);
    
    _____________________________________
    -bitmap : (attribute button bitmap);)   
     
(datatype labels

    if (= label (widgetclass L))
    _____________________________    
    L : label;
    
    W : label;
    ___________
    W : widget; 
    
    _______________________________
    -fg : (attribute label color); 
         
    _______________________________
    -bg : (attribute label color);
    
    ___________________________________
    -foreground : (attribute label color);
    
    _______________________________________
    -background : (attribute label color);
    
    ________________________________
    -image : (attribute label image);  
    
    _____________________________________
    -underline : (attribute label number);
    
    ________________________________
    -padx : (attribute label number);
    
     _________________________________
    -pady : (attribute label number);
    
     _________________________________
    -ipadx : (attribute label number);
    
     _________________________________
    -ipady : (attribute label number);
    
    ___________________________________
    -relief : (attribute label relief);
    
     ____________________________________
    -justify : (attribute label justify);
    
     _______________________________________
    -wraplength : (attribute label number);
    
    ________________________________________________
    -highlightthickness : (attribute label number); 
    
    ____________________________________
    -height : (attribute label number);
    
    ___________________________________
    -width : (attribute label number);
    
    ___________________________________
    -text : (attribute label string);      
        
    ___________________________________
    -font : (attribute label font);
    
    _____________________________________________
    -activebackground : (attribute label color);
    
    _____________________________________________
    -activeforeground : (attribute label color);
    
    ___________________________________________
    -highlightcolor : (attribute label color);
    
    ___________________________________
    -anchor : (attribute label anchor);
    
    _____________________________________
    -state : (attribute label state); 
     
    _________________________________________    
    -compound : (attribute label compound);
    
    _________________________________________
    -borderwidth : (attribute label number);
    
    _______________________________
    -bd : (attribute label number);
    
    ___________________________________
    -cursor : (attribute label cursor);
    
    ______________________________________________    
    -disabledforeground : (attribute label color);
    
    ______________________________________
    -takefocus : (attribute label binary);
    
    _____________________________________
    -bitmap : (attribute label bitmap);)
    
(datatype entries
    
    if (= entry (widgetclass E))
    _____________________________    
    E : entry;
    
    W : entry;
    ___________
    W : widget; 
    
    _______________________________
    -fg : (attribute entry color); 
         
    _______________________________
    -bg : (attribute entry color);
    
    ___________________________________
    -foreground : (attribute entry color);
    
    _______________________________________
    -background : (attribute entry color);
    
    ___________________________________
    -relief : (attribute entry relief);
    
     ____________________________________
    -justify : (attribute entry justify);
    
    ________________________________________________
    -highlightthickness : (attribute entry number);
    
    ___________________________________
    -width : (attribute entry number);
    
    ___________________________________
    -text : (attribute entry string);      
        
    ___________________________________
    -font : (attribute entry font);
    
    _____________________________________________
    -activebackground : (attribute entry color);
    
    _________________________________________
    -highlightcolor : (attribute entry color);
       
    _____________________________________
    -state : (attribute entry state);      
        
    _________________________________________
    -borderwidth : (attribute entry number);
    
    _______________________________
    -bd : (attribute entry number);
    
    ____________________________________
    -cursor : (attribute entry cursor);
    
    ______________________________________________    
    -disabledforeground : (attribute entry color);
    
    ______________________________________
    -takefocus : (attribute entry focus);
    
    _____________________________________
    -show : (attribute entry binary);) 
    
 (datatype texts
    
    if (= text (widgetclass E))
    _____________________________    
    E : text;
    
    W : text;
    ___________
    W : widget; 
    
    _______________________________
    -fg : (attribute text color); 
         
    _______________________________
    -bg : (attribute text color);
    
    ___________________________________
    -foreground : (attribute text color);
    
    _______________________________________
    -background : (attribute text color);
    
    ___________________________________
    -relief : (attribute text relief);
    
    ________________________________________________
    -highlightthickness : (attribute text number);
    
    __________________________________
    -height : (attribute text number);
    
    ___________________________________
    -width : (attribute text number);
    
    ________________________________
    -text : (attribute text string);      
        
    ______________________________
    -font : (attribute text font);    
       
    _________________________________________
    -highlightcolor : (attribute text color);
       
    _____________________________________
    -state : (attribute text state);      
        
    _________________________________________
    -borderwidth : (attribute text number);
    
    _______________________________
    -bd : (attribute text number);
    
    ____________________________________
    -cursor : (attribute text cursor);    
        
    ______________________________________
    -takefocus : (attribute text focus);    
     
    _________________________________
    -wrap : (attribute text wrap);
    
    _____________________________________
    -spacing1	: (attribute text number);
    
    _____________________________________
    -spacing2	: (attribute text number);
    
    _____________________________________
    -spacing3	: (attribute text number);

    _____________________________________
    -offset : (attribute text number);
    
    _________________________________________
    -selectbackground : (attribute text color);
    
    ___________________________________________
    -selectborderwidth : (attribute text number);
    
    ___________________________________________
    -selectforeground : (attribute text color);
    
    ___________________________________
    -setgrid : (attribute text binary);
    
    _______________________________________
    -autoseparators : (attribute text binary);
    
    _______________________________________
    -blockcursor : (attribute text binary);
    
    ___________________________________
    -endline : (attribute text number);
    
    ___________________________________________________
    -inactiveselectbackground : (attribute text color);

    _______________________________________________
    -insertunfocussed : (attribute text insertion);
    
    ___________________________________
    -maxundo : (attribute text number);
    
    _______________________________________
    -tabstyle : (attribute text tabstyle);

    ________________________________
    -undo : (attribute text binary);)      
    
(datatype frames

    if (= frame (widgetclass F))
    _____________________________    
    F : frame;
    
    W : frame;
    ___________
    W : widget; 
    
    ______________________________
    -bg : (attribute frame color);
    
    _______________________________________
    -background : (attribute frame color);
    
    ________________________________
    -padx : (attribute frame number);
    
     _________________________________
    -pady : (attribute frame number);
    
     ___________________________________
    -relief : (attribute frame relief);
    
     ______________________________________________
    -highlightthickness : (attribute frame number); 
    
    ____________________________________
    -height : (attribute frame number);
    
    ___________________________________
    -width : (attribute frame number);
    
    ___________________________________________
    -highlightcolor : (attribute frame color);
    
    _________________________________________
    -borderwidth : (attribute frame number);
    
    _______________________________
    -bd : (attribute frame number);
    
    ____________________________________
    -cursor : (attribute frame cursor);
    
    ______________________________________
    -takefocus : (attribute frame binary);)
    
(datatype canvases

   if (= canvas (widgetclass C))
    _____________________________    
    C : canvas;
    
    W : canvas;
    ___________
    W : widget; 
    
    _______________________________________
    -background : (attribute canvas color);
    
    ________________________________
    -bg : (attribute canvas color);
       
     ___________________________________
    -relief : (attribute canvas relief);
    
     ______________________________________________
    -highlightthickness : (attribute canvas number); 
    
    ____________________________________
    -height : (attribute canvas number);
    
    ___________________________________
    -width : (attribute canvas number);
    
    ___________________________________________
    -highlightcolor : (attribute canvas color);
    
    _________________________________________
    -borderwidth : (attribute canvas number);
    
    _______________________________
    -bd : (attribute canvas number);
    
    ____________________________________
    -cursor : (attribute canvas cursor);
    
    ______________________________________
    -takefocus : (attribute canvas binary);
    
    ___________________________________________
    -insertofftime : (attribute canvas number);

    __________________________________________
    -insertontime : (attribute canvas number);
   
    _________________________________________
    -insertwidth : (attribute canvas number);

    _________________________________________
    -selectbackground : (attribute canvas color);

    ______________________________________________
    -selectborderwidth : (attribute canvas number);

    _________________________________________________
    -selectforeground : (attribute canvas color);

    _________________________________________
    -closeenough : (attribute canvas number);

    ____________________________________
    -confine : (attribute canvas binary);

    ______________________________________
    -scrollregion : (attribute canvas (list number));

    _________________________________________________
    -xscrollincrement : (attribute canvas number);
    
    _________________________________________________
    -yscrollincrement : (attribute canvas number);)        
    
(datatype windows
       
    if (= window (widgetclass B))
    _____________________________    
    W : window;            
        
    W : window;
    ___________
    W : widget;    
        
   _______________________________________
    -background : (attribute window color);
    
    _______________________________________
    -bg : (attribute window color);
    
    ___________________________________
    -height : (attribute window number);
    
     ___________________________________
    -width : (attribute window number);
    
    _______________________________________________
    -highlightthickness : (attribute window number);
    
    ___________________________________________
    -highlightcolor : (attribute window color);       
       
    _________________________________________
    -cursor : (attribute window cursor);
    
    ________________________________________________
    -highlightbackground : (attribute window color);
    
    ________________________________
    -padx : (attribute window number);
    
    _______________________________
    -pady : (attribute window number);
    
    ______________________________________
    -container : (attribute window binary);
    
    ______________________________________
    -takefocus : (attribute window binary);
    
    ______________________________________
    -colormap : (attribute window symbol);
    
    ___________________________________
    -screen : (attribute window symbol);
    
    _________________________________
    -use : (attribute window string);)
    
(datatype packing
      
    _______________________________
    -padx : (attribute pack number);     
    
    _______________________________
    -pady : (attribute pack number); 
    
    _______________________________
    -ipadx : (attribute pack number);  
    
    _______________________________
    -ipady : (attribute pack number);
    
    ______________________________
    -side : (attribute pack side);    
    
    ______________________________
    -fill : (attribute pack fill);
    
    ______________________________
    -after : (attribute pack window);
    
    _________________________________
    -anchor : (attribute pack anchor);
    
     ______________________________
    -before : (attribute pack window);
    
     ______________________________
    -expand : (attribute pack binary);
    
    ______________________________
    -in : (attribute pack window);)
    
(datatype grids
      
    _______________________________
    -padx : (attribute grid number);     
    
    _______________________________
    -pady : (attribute grid number); 
    
    _______________________________
    -ipadx : (attribute grid number);  
    
    _______________________________
    -ipady : (attribute grid number);
    
    ______________________________
    -in : (attribute grid window);
    
    __________________________________
    -column : (attribute grid number);
    
    _____________________________________
    -columnspan : (attribute grid number);
    
    _______________________________
    -row : (attribute grid number);
    
     __________________________________
    -rowspan : (attribute grid number);
    
    __________________________________
    -sticky : (attribute grid string);)
    
(datatype fonts

    __________________________________
    -family : (attribute font family);
    
    ________________________________
    -size : (attribute font number);   
         
    ________________________________
    -weight : (attribute font weight);
    
    ________________________________
    -slant : (attribute font slant);
    
    ________________________________
    -underline : (attribute font binary);
    
    ________________________________
    -overstrike : (attribute font binary);)
    
(datatype messageboxes
    
    _________________________________________
    -message : (attribute messagebox string);
    
    _______________________________________
    -title : (attribute messagebox string);
    
    ______________________________________
    -type : (attribute messagebox symbol);
    
    ______________________________________
    -icon : (attribute messagebox symbol);)
    
(datatype drawing
    
    ______________________________
    -fill : (attribute arc color);
    
    __________________________________
    -outline : (attribute draw color);
    
    ________________________________
    -color : (attribute draw color);
    
    ________________________________
    -arrow : (attribute draw arrow);    
        
    _________________________________
    -start : (attribute draw number);
    
    _________________________________
    -extent : (attribute draw number);)
    
(datatype winfos

   _________________________________
   exists : (attribute winfo number);)    
   
(define widgetclass
  W -> (trap-error (get W class) (/. E void)))  
  
(define image?
  I -> (= image (widgetclass I))) 
  
(define font?
  F -> (= font (widgetclass F)))   
    
(set *colors* 

["alice blue" "AliceBlue" "antique white" "AntiqueWhite" "AntiqueWhite1" "AntiqueWhite2" "AntiqueWhite3" 
      "AntiqueWhite4" "aquamarine" "aquamarine1" "aquamarine2" "aquamarine3" "aquamarine4" "azure" "azure1" 
      "azure2" "azure3" "azure4" "beige" "bisque" "bisque1" "bisque2"  "bisque3" "bisque4" "black" 
      "blanched almond" "BlanchedAlmond" "blue" "blue" "violet" "blue1"  "blue2" "blue3" "blue4" "BlueViolet" 
      "brown" "brown1" "brown2" "brown3" "brown4" "burlywood"  "burlywood1" "burlywood2" "burlywood3" 
      "burlywood4" "cadet blue" "CadetBlue" "CadetBlue1"  "CadetBlue2" "CadetBlue3" "CadetBlue4" "chartreuse" 
       "chartreuse1" "chartreuse2"  "chartreuse3" "chartreuse4" "chocolate" "chocolate1" "chocolate2" "chocolate3" 
       "chocolate4"  "coral" "coral1" "coral2" "coral3" "coral4" "cornflower"  "blue" "CornflowerBlue" "cornsilk"  
       "cornsilk1" "cornsilk2" "cornsilk3" "cornsilk4" "cyan" "cyan1"  "cyan2" "cyan3" "cyan4" "dark blue" 
       "dark cyan" "dark goldenrod" "dark gray" "dark green"  "dark grey" "dark khaki" "dark magenta" "dark olive green" 
       "dark orange" "dark orchid" "dark red" "dark salmon" "dark sea green" "dark slate blue" "dark slate gray" 
       "dark slate grey" "dark turquoise" "dark violet" "DarkBlue" "DarkCyan"
       "DarkGoldenrod" "DarkGoldenrod1" "DarkGoldenrod2" "DarkGoldenrod3" "DarkGoldenrod4" "DarkGray" "DarkGreen" 
       "DarkGrey" "DarkKhaki"  "DarkMagenta" "DarkOliveGreen" "DarkOliveGreen1" "DarkOliveGreen2" "DarkOliveGreen3"  
       "DarkOliveGreen4" "DarkOrange" "DarkOrange1" "DarkOrange2" "DarkOrange3" "DarkOrange4"  "DarkOrchid" 
       "DarkOrchid1" "DarkOrchid2" "DarkOrchid3" "DarkOrchid4" "DarkRed" "DarkSalmon"  "DarkSeaGreen" 
       "DarkSeaGreen1" "DarkSeaGreen2" "DarkSeaGreen3" "DarkSeaGreen4"  "DarkSlateBlue" "DarkSlateGray" 
       "DarkSlateGray1" "DarkSlateGray2" "DarkSlateGray3"  "DarkSlateGray4" "DarkSlateGrey" "DarkTurquoise" 
       "DarkViolet" "deep pink" "deep sky blue"  "DeepPink" "DeepPink1" "DeepPink2" "DeepPink3" "DeepPink4" 
       "DeepSkyBlue" "DeepSkyBlue1"  "DeepSkyBlue2" "DeepSkyBlue3" "DeepSkyBlue4" "dim gray" "dim grey" "DimGray" 
       "DimGrey" "dodger blue" "DodgerBlue" "DodgerBlue1" "DodgerBlue2" "DodgerBlue3" "DodgerBlue4" "firebrick" 
       "firebrick1" "firebrick2" "firebrick3" "firebrick4" "floral white" "FloralWhite" "forest green" 
       "ForestGreen" "gainsboro" "ghost white" "GhostWhite" "gold" "gold1" "gold2" "gold3" "gold4" "goldenrod" 
       "goldenrod1" "goldenrod2" "goldenrod3" "goldenrod4" "gray" "gray0" "gray1" "gray2" "gray3" "gray4" 
       "gray5" "gray6" "gray7" "gray8" "gray9" "gray10"  "gray11" "gray12" "gray13" "gray14"  "gray15" 
       "gray16" "gray17" "gray18" "gray19" "gray20" "gray21"  "gray22" "gray23" "gray24" "gray25" "gray26" 
       "gray27" "gray28" "gray29" "gray30" "gray31" "gray32" "gray33" "gray34" "gray35" "gray36" "gray37" 
       "gray38" "gray39" "gray40" "gray41" "gray42" "gray43"  "gray44" "gray45" "gray46" "gray47" "gray48" 
       "gray49" "gray50" "gray51" "gray52" "gray53" "gray54"  "gray55" "gray56" "gray57" "gray58" "gray59" 
       "gray60" "gray61" "gray62" "gray63" "gray64" "gray65"  "gray66" "gray67" "gray68" "gray69" "gray70" 
       "gray71" "gray72" "gray73" "gray74" "gray75" "gray76" "gray77" "gray78" "gray79" "gray80" "gray81" 
       "gray82" "gray83" "gray84" "gray85" "gray86" "gray87"  "gray88" "gray89" "gray90" "gray91" "gray92" 
       "gray93" "gray94" "gray95"  "gray96" "gray97" "gray98"  "gray99" "gray100" "green" "green" "yellow" 
       "green1" "green2" "green3" "green4" "GreenYellow"  "grey" "grey0" "grey1" "grey2" "grey3" "grey4" 
       "grey5" "grey6" "grey7" "grey8" "grey9" "grey10"  "grey11" "grey12" "grey13" "grey14" "grey15" "grey16" 
       "grey17" "grey18" "grey19" "grey20" "grey21"  "grey22" "grey23" "grey24" "grey25" "grey26" "grey27" 
       "grey28" "grey29" "grey30" "grey31" "grey32"  "grey33" "grey34" "grey35" "grey36" "grey37" "grey38" 
       "grey39" "grey40" "grey41" "grey42" "grey43"  "grey44" "grey45" "grey46" "grey47" "grey48" "grey49" 
       "grey50" "grey51" "grey52" "grey53" "grey54"  "grey55" "grey56" "grey57" "grey58" "grey59" "grey60" 
       "grey61" "grey62" "grey63" "grey64" "grey65"  "grey66" "grey67" "grey68" "grey69" "grey70" "grey71" 
       "grey72" "grey73" "grey74" "grey75" "grey76" "grey77" "grey78" "grey79" "grey80" "grey81" "grey82" 
       "grey83" "grey84" "grey85" "grey86" "grey87"  "grey88" "grey89" "grey90" "grey91" "grey92" "grey93" 
       "grey94" "grey95" "grey96" "grey97" "grey98"  "grey99" "grey100" "honeydew" "honeydew1" "honeydew2" 
       "honeydew3" "honeydew4" "hot pink"  "HotPink" "HotPink1" "HotPink2" "HotPink3" "HotPink4" "indian red" 
       "IndianRed" "IndianRed1"  "IndianRed2" "IndianRed3" "IndianRed4" "ivory" "ivory1" "ivory2" "ivory3" 
       "ivory4" "khaki"  "khaki1" "khaki2" "khaki3" "khaki4" "lavender" "lavender blush" "LavenderBlush" 
       "LavenderBlush1" "LavenderBlush2" "LavenderBlush3" "LavenderBlush4" "lawn green"  "LawnGreen"  
       "lemon chiffon" "LemonChiffon" "LemonChiffon1" "LemonChiffon2"  "LemonChiffon3" "LemonChiffon4" 
       "light blue" "light coral" "light cyan" "light goldenrod"  "light goldenrod yellow" "light gray" 
       "light green" "light grey" "light pink" "light salmon" "light sea green" "light sky blue" 
       "light slate blue" "light slate gray" "light slate grey" "light steel blue" "light yellow" "LightBlue" 
       "LightBlue1" "LightBlue2"  "LightBlue3" "LightBlue4" "LightCoral" "LightCyan" "LightCyan1" "LightCyan2" 
       "LightCyan3"  "LightCyan4" "LightGoldenrod" "LightGoldenrod1" "LightGoldenrod2" "LightGoldenrod3"  
       "LightGoldenrod4" "LightGoldenrodYellow" "LightGray" "LightGreen" "LightGrey" "LightPink"  "LightPink1" 
       "LightPink2" "LightPink3" "LightPink4" "LightSalmon" "LightSalmon1"  "LightSalmon2" "LightSalmon3" 
       "LightSalmon4" "LightSeaGreen" "LightSkyBlue"  "LightSkyBlue1" "LightSkyBlue2" "LightSkyBlue3" 
       "LightSkyBlue4" "LightSlateBlue"  "LightSlateGray" "LightSlateGrey" "LightSteelBlue" "LightSteelBlue1" 
       "LightSteelBlue2"  "LightSteelBlue3" "LightSteelBlue4"  "LightYellow" "LightYellow1" "LightYellow2"  
       "LightYellow3" "LightYellow4" "lime green" "LimeGreen" "linen"
       "magenta" "magenta1"  "magenta2" "magenta3" 
       "magenta4" "maroon" "maroon1" "maroon2" "maroon3" "maroon4" "medium"  "aquamarine" "medium blue" 
       "medium orchid"  "medium purple" "medium sea green" "medium slate blue" "medium spring green" 
       "medium turquoise"  "medium violet red"  "MediumAquamarine" "MediumBlue" "MediumOrchid" "MediumOrchid1" 
       "MediumOrchid2"   "MediumOrchid3" "MediumOrchid4" "MediumPurple" "MediumPurple1" "MediumPurple2"  
       "MediumPurple3" "MediumPurple4" "MediumSeaGreen" "MediumSlateBlue" "MediumSpringGreen" "MediumTurquoise"  
       "MediumVioletRed" "midnight blue" "MidnightBlue" "mint cream" "MintCream" "misty rose" "MistyRose"  
       "MistyRose1" "MistyRose2" "MistyRose3" "MistyRose4"  "moccasin" "navajo white" "NavajoWhite" "NavajoWhite1" 
       "NavajoWhite2"  "NavajoWhite3"  "NavajoWhite4" "navy" "navy blue" "NavyBlue" "old lace" "OldLace"  
       "olive drab" "OliveDrab"  "OliveDrab1" "OliveDrab2" "OliveDrab3" "OliveDrab4" "orange" "orange red" 
       "orange1"  "orange2" "orange3" "orange4" "OrangeRed" "OrangeRed1" "OrangeRed2" "OrangeRed3" "OrangeRed4" 
       "orchid" "orchid1" "orchid2" "orchid3" "orchid4" "pale goldenrod" "pale green" "pale turquoise" 
       "pale violet red" "PaleGoldenrod" "PaleGreen" "PaleGreen1" "PaleGreen2" "PaleGreen3" "PaleGreen4" 
       "PaleTurquoise" "PaleTurquoise1" "PaleTurquoise2"  "PaleTurquoise3" "PaleTurquoise4" "PaleVioletRed" 
       "PaleVioletRed1" "PaleVioletRed2"  "PaleVioletRed3" "PaleVioletRed4" "papaya whip" "PapayaWhip" 
       "peach puff" "PeachPuff"  "PeachPuff1" "PeachPuff2" "PeachPuff3" "PeachPuff4" "peru pink" "pink1" 
       "pink2" "pink3" "pink4" "plum" "plum1" "plum2" "plum3" "plum4" "powder blue" "PowderBlue" "purple" 
       "purple1" "purple2"  "purple3" "purple4" "red" "red1" "red2" "red3" "red4" "rosy brown" "RosyBrown"
       "RosyBrown1"  "RosyBrown2" "RosyBrown3" "RosyBrown4" "royal blue" "RoyalBlue" "RoyalBlue1" "RoyalBlue2"  
       "RoyalBlue3" "RoyalBlue4" "saddle brown" "SaddleBrown" "salmon" "salmon1" "salmon2" "salmon3"  
       "salmon4" "sandy brown" "SandyBrown" "sea green" "SeaGreen" "SeaGreen1" "SeaGreen2"  "SeaGreen3" 
       "SeaGreen4" "seashell" "seashell1" "seashell2" "seashell3" "seashell4" "sienna"  "sienna1" "sienna2"
       "sienna3" "sienna4" "sky blue" "SkyBlue" "SkyBlue1" "SkyBlue2" "SkyBlue3" "SkyBlue4" "slate blue" 
       "slate gray" "slate grey" "SlateBlue" "SlateBlue1" "SlateBlue2"  "SlateBlue3" "SlateBlue4" "SlateGray"
       "SlateGray1" "SlateGray2" "SlateGray3" "SlateGray4"  "SlateGrey" "snow" "snow1" "snow2" "snow3" "snow4" 
       "spring green" "SpringGreen" "SpringGreen1"  "SpringGreen2" "SpringGreen3" "SpringGreen4" "steel blue"
       "SteelBlue" "SteelBlue1"  "SteelBlue2" "SteelBlue3" "SteelBlue4" "tan" "tan1" "tan2" "tan3" "tan4" 
       "thistle" "thistle1"  "thistle2" "thistle3" "thistle4" "tomato" "tomato1" "tomato2" "tomato3" "tomato4"
       "turquoise"  "turquoise1" "turquoise2" "turquoise3" "turquoise4" "violet" "violet red" "VioletRed" 
       "VioletRed1" "VioletRed2" "VioletRed3" "VioletRed4" "wheat" "wheat1" "wheat2" "wheat3" "wheat4" 
       "white" "white smoke" "WhiteSmoke" "yellow" "yellow green" "yellow1" "yellow2" "yellow3" "yellow4" 
       "YellowGreen"])              

(define family?
  F -> (element? F (value *families*)))
  
(set *families* 

  ["System" "Terminal" "Fixedsys" "Roman" "Script" "Modern" "Small Fonts" 
  "MS Serif" "WST_Czec" "WST_Engl" "WST_Fren" "WST_Germ" "WST_Ital" "WST_Span"
 "WST_Swed" "Courier" "MS Sans Serif" "Marlett" "Arial" "Arial CE" "Arial CYR"
 "Arial Greek" "Arial TUR" "Arial Baltic" "Courier New" "Courier New CE"
 "Courier New CYR" "Courier New Greek" "Courier New TUR" "Courier New Baltic"
 "Lucida Console" "Lucida Sans Unicode" "Times New Roman" "Times New Roman CE"
 "Times New Roman CYR" "Times New Roman Greek" "Times New Roman TUR"
 "Times New Roman Baltic" "Wingdings" "Symbol" "Verdana" "Arial Black"
 "Comic Sans MS" "Impact" "Georgia" "Franklin Gothic Medium" 
 "Palatino Linotype" "Tahoma" "Trebuchet MS" "Webdings" "Estrangelo Edessa"
 "Gautami" "Latha" "Mangal" "MV Boli" "Raavi" "Shruti" "Tunga" "Sylfaen"
 "Microsoft Sans Serif" "Agency FB" "Arial Narrow" "Arial Rounded MT Bold"
 "Blackadder ITC" "Bodoni MT" "Bodoni MT Black" "Bodoni MT Condensed" 
 "Book Antiqua" "Bookman Old Style" "Bradley Hand ITC" "Calisto MT" 
 "Castellar" "Century Gothic" "Century Schoolbook" "Copperplate Gothic Bold"
 "Copperplate Gothic Light" "Curlz MT" "Edwardian Script ITC" "Elephant"
 "Engravers MT" "Eras Bold ITC" "Eras Demi ITC" "Eras Light ITC" 
 "Eras Medium ITC" "Felix Titling" "Forte" "Franklin Gothic Book"
 "Franklin Gothic Demi" "Franklin Gothic Demi Cond" "Franklin Gothic Heavy"
 "Franklin Gothic Medium Cond" "French Script MT" "Garamond" "Gigi"
 "Gill Sans MT Ext Condensed Bold" "Gill Sans MT" "Gill Sans MT Condensed"
 "Gill Sans Ultra Bold" "Gill Sans Ultra Bold Condensed"
 "Gloucester MT Extra Condensed" "Goudy Old Style" "Goudy Stout"
 "Haettenschweiler" "Imprint MT Shadow" "Lucida Sans" "Lucida Sans Typewriter"
 "MS Outlook" "Maiandra GD" "Monotype Corsiva" "OCR A Extended"
 "Palace Script MT" "Papyrus" "Perpetua" "Perpetua Titling MT" "Pristina"
 "Rage Italic" "Rockwell" "Rockwell Condensed" "Rockwell Extra Bold"
 "Script MT Bold" "Tw Cen MT" "Tw Cen MT Condensed" "Wingdings 2" "Wingdings 3"
 "Bookshelf Symbol 7" "MS Reference Sans Serif" "MS Reference Specialty"
 "Tw Cen MT Condensed Extra Bold" "Berling Antiqua" "Bookdings"
 "Frutiger Linotype"]) 

(define cursor?
  C -> (element? C (value *cursors*)))
   
(set *cursors*

[X_cursor arrow based_arrow_down based_arrow_up boat bogosity bottom_left_corner 
 bottom_right_corner bottom_side bottom_tee box_spiral center_ptr circle clock 
 coffee_mug cross cross_reverse crosshair diamond_cross dot dotbox double_arrow 
 draft_large draft_small draped_box exchange fleur gobbler gumby hand1 hand2 heart 
 icon iron_cross left_ptr left_side left_tee leftbutton ll_angle lr_angle man middlebutton 
 mouse pencil pirate plus question_arrow right_ptr right_side right_tee rightbutton rtl_logo 
 sailboat sb_down_arrow sb_h_double_arrow sb_left_arrow sb_right_arrow sb_up_arrow 
 sb_v_double_arrowshuttle sizing spider spraycan star target tcross top_left_arrow 
 top_left_corner top_right_corner top_side top_tee trek ul_angle umbrella ur_angle watch xterm])
 
(define color?
  C -> (or (element? C (value *colors*))
           (rgb? C))  where (string? C)
  _ -> false)
  
(define opencolor
  -> (opencolour)) 
  
(define rgb?
  (@s "#" D1 D2 D3 D4 D5 D6) -> (and (hex? D1) (hex? D2) (hex? D3) (hex? D4) (hex? D5) (hex? D6))
  _ -> false)
  
(define hex?
  D -> (element? D [($ "ABCDEF1234567890")]))
  
(define types
  +  -> (include [general buttons labels frames windows entries texts 
                  packing grids canvases messageboxes fonts drawing winfos])
  -  -> (preclude [general buttons labels frames windows entries texts 
                   packing grids canvases messageboxes fonts drawing winfos]))
  
 )
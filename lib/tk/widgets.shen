(package tk [.canvas .scrollbar .frame .b min | (external tk)]

(define my-widget
  Widget Class Slots -> (let WidgetString  (if (= window Class)
                                               (make-string "toplevel ~A" Widget)
                                               (make-string "~A ~A" Class Widget))
                             Record        (put Widget class Class)
                             CreateWidget  (shen->tcl WidgetString)
                             Error         (check-error)
                             SetAttributes (put-all Widget Slots)
                             Widget))

(define my-image
  Image File Options -> (let String (make-string "package require Img; image create photo ~A -file ~S ~A"
                                               Image File (concat-slots Options))
                             Talk   (shen->tcl String)
                             Error  (check-error)
                             Record (put Image class image)
                             Image))

(define concat-slots
  [] -> ""
  [X | Y] -> (@s (str X) " " (concat-slots Y)))

(define put-all
  Widget [] -> Widget
  Widget [Attribute Value | Slots] -> (let Set    (putw Widget Attribute Value)
                                           Record (put Widget Attribute Value)
                                           (put-all Widget Slots))
  Widget Options -> (error "widget options not recognised ~A~%" (concat-slots Options)))

(define getw
  Widget -text     -> (get-entry Widget)          where (entry? Widget)
  Widget -text     -> (get-text Widget)           where (textbox? Widget)
  Widget Attribute -> (get Widget Attribute))

(define get-entry
  Entry -> (let String  (make-string "mysend [format c#34;%c%s%cc#34; 34 [~A get] 34]" Entry)
                Talk    (shen->tcl String)
                Suspend (suspend)
                Listen  (tcl->shen)
                Resume  (resume)
                Listen))

(define get-text
  TextBox
   -> (let String  (make-string "mysend [format c#34;%c%s%cc#34; 34 [~A get 1.0 end] 34]" TextBox)
           Talk    (shen->tcl String)
           Suspend (suspend)
           Listen  (tcl->shen)
           Resume  (resume)
           Listen))

(define putw
  Widget -command Value         -> (command-configure Widget Value)
  Widget -postcommand Value     -> (postcommand-configure Widget Value)
  Widget -text Value            -> (entry-configure Widget Value)       where (entry? Widget)
  Widget -text Value            -> (textbox-configure Widget Value)     where (textbox? Widget)
  Widget Attribute Value        -> (default-configure Widget Attribute Value))

(define textbox?
  Widget -> (= (get Widget class) text))

(define entry?
  Widget -> (= (get Widget class) entry))

(define command-configure
  Widget Value
  -> (let String (make-string "~A configure -command ~A" Widget (button-command Widget))
          Store  (put Widget -command Value)
          Talk   (shen->tcl String)
          Error  (check-error)
          Value))

(define button-command
  Widget -> (make-string "{mysend {(thaw (get ~A -command))}}" Widget))

(define entry-configure
  Widget Value -> (let Store   (put Widget -text Value)
                       String  (make-string "~A delete 0 end; ~A insert 0 {~A}" Widget Widget Value)
                       Talk    (shen->tcl String)
                       Error   (check-error)
                       Value))

(define textbox-configure
  Widget Value -> (let Store  (put Widget -text Value)
                       String (make-string "~A delete 1.0 end; ~A insert 1.0 {~A}" Widget Widget Value)
                       Talk   (shen->tcl String)
                       Error  (check-error)
                       Value))

(define default-configure
  Widget Attribute Value
   -> (let String (make-string "~A configure ~A ~S" Widget Attribute Value)
           Store  (put Widget Attribute Value)
           Talk   (shen->tcl String)
           Error  (check-error)
           Value))

(define my-openfile
  Options -> (let String "mysend [format c#34;%c%s%cc#34; 34 [tk_getOpenFile] 34]"
                  Suspend (suspend)
                  Talk    (shen->tcl String)
                  Listen  (tcl->shen)
                  Resume  (resume)
                  Listen))

(define my-opencolour
   Options -> (let String "mysend [format c#34;%c%s%cc#34; 34 [tk_chooseColor] 34]"
                   Suspend (suspend)
                   Talk    (shen->tcl String)
                   Listen  (tcl->shen)
                   Resume  (resume)
                   Listen))

(define my-savefile
  Options -> (let String "mysend [format c#34;%c%s%cc#34; 34 [tk_getSaveFile] 34]"
                  Suspend (suspend)
                  Talk    (shen->tcl String)
                  Listen  (tcl->shen)
                  Resume  (resume)
                  Listen))

(define my-messagebox
  Options -> (let String  (make-string "mysend [format c#34;%c%s%cc#34; 34 [tk_messageBox ~A] 34]"
                            (concat-slots Options))
                  Suspend (suspend)
                  Talk    (shen->tcl String)
                  Listen  (tcl->shen)
                  Resume  (resume)
                  Listen))

(define bell
   -> (let Talk (shen->tcl "bell")
           bell))

(define my-pack
  [] _ -> (error "cannot pack an empty list of widgets~%")
  Widgets Options
  -> (let String (make-string "pack ~A" (concat-slots (append Widgets Options)))
          Pack (shen->tcl String)
          Error  (check-error)
          Widgets))

(define my-grid
  Grid Options -> (my-grid-help Grid Options 0))

(define my-grid-help
 [] _ _ -> []
 [Row | Rows] Options RowN -> [(grid-row Row Options RowN 0)
                               | (my-grid-help Rows Options (+ 1 RowN))])

(define grid-row
  [] _ _ _ -> []
  [Widget | Widgets] Options RowN ColN
  -> [(callgrid Widget RowN ColN Options) | (grid-row Widgets Options RowN (+ 1 ColN))]
  X _ _ _ -> (error "~A is not a list~%" X))

(define callgrid
  Widget Row Column Options
-> (let String (make-string "mysend [grid configure ~A -column ~A -row ~A ~A]"
                            Widget Column Row (concat-slots Options))
        Talk   (shen->tcl String)
        Error  (check-error)
        Widget))

(define unpack
  Widgets -> (let String (make-string "pack forget ~A" (concat-slots Widgets))
                  Talk   (shen->tcl String)
                  Error  (check-error)
                  Widgets))

(define my-draw
  Canvas Shape Coordinates Options
  -> (let String (make-string "mysend [~A create ~A ~A  ~A]"
                        Canvas
                        Shape
                        (concat-slots Coordinates)
                        (concat-slots Options))
          Talk   (shen->tcl String)
          Error  (check-error)
          Tag    (find-tag Options)
          Tag))

(define find-tag
  [-tag Tag | _] -> Tag
  [_ | Options] -> (find-tag Options))

(define package-strings
  S -> (@s "{" S "}") where (string? S)
  X -> X)

(define menu
  Menu N -> (let  Window        (tk.widget Menu window)
                  Size          (min (* N 30) 500)
                  Canvas        (tk.widget (concat Window .canvas) canvas -width 100 -height Size)
                  ScrollBar     (do (tk.shen->tcl (make-string "scrollbar ~A.scrollbar -orient vertical -command c#34;~A yviewc#34;"
                                                         Window Canvas))
                                  (concat Window .scrollbar))
                  Frame         (tk.widget (concat Canvas .frame) frame)
                  Buttons       (reverse (create-buttons Frame N))
                  Comm1         (tk.shen->tcl (make-string "~A create window 0 0 -anchor nw -window ~A" Canvas Frame))
                  Comm2         (tk.shen->tcl (make-string "~A configure -scrollregion c#34;[~A bbox all]c#34;" Canvas Canvas))
                  Comm3         (tk.shen->tcl (make-string "~A configure -yscrollcommand c#34;~A setc#34;" Canvas ScrollBar))
                  PackScroll    (tk.pack [ScrollBar] -side right -fill y)
                  PackCanvas    (tk.pack [Canvas] -side left -fill both -expand 1)
                  FrameSize     (tk.shen->tcl (make-string "bind ~A <Configure> {
                                             ~A configure -scrollregion c#34;0 0 200 [winfo reqheight %W]c#34;
                                             }" Frame Canvas))
                  WinSize       (tk.shen->tcl (make-string "wm maxsize ~A 250 ~A" Window Size))
                  (@p Menu Canvas Buttons)))

(define create-buttons
  Frame 0 -> []
  Frame N -> [(create-button Frame N) | (create-buttons Frame (- N 1))])

(define create-button
  Frame N -> (let Name   (concat Frame (concat .b N))
                  Button (tk.widget Name button -relief flat)
                  Pack   (tk.pack [Button] -side bottom -fill x)
                  Button))

(define image
  Image File -> (let String (make-string "package require Img; image create photo ~A -file ~S"
                                               Image File)
                             Talk   (shen->tcl String)
                             Error  (check-error)
                             Record (put Image class image)
                             Image))

(define my-font
   Font Options -> (let String (make-string "font create ~A ~A" Font (concat-slots Options))
                        Talk   (shen->tcl String)
                        Error  (check-error)
                        Record (put Font class font)
                        Font))

(define url
  URL -> (let Suspend (suspend)
              String  (make-string "url ~S" URL)
              Talk    (shen->tcl String)
              \\Error   (check-error)
              ASCII   (read-ascii (read-file-as-bytelist (value *in*)) (value *in*))
              Flush   (flush)
              Resume  (resume)
              ASCII))

(define require
  URL -> (let Suspend (suspend)
              String  (make-string "url ~S" URL)
              Talk    (shen->tcl String)
              \\Error   (check-error)
              Wait    (wait-till-ready (value *in*))
              Load    (load (value *in*))
              Flush   (flush)
              Resume  (resume)
              Load))

(define winfo
  Window Attribute -> (let Suspend (suspend)
                           String  (make-string "mysend [winfo ~A ~A]" Attribute Window)
                           Talk    (shen->tcl String)
                           Info    (tcl->shen)
                           Resume  (resume)
                           Info))

(define tk.destroy
  Window -> (let String (make-string "destroy ~A" Window)
                 Talk   (shen->tcl String)
                 Window))

(define root
  -> .)

(define bindkey
  Widget Event Command -> (let WidgetEvent (concat Widget Event)
                               Put         (put WidgetEvent -command Command)
                               TCLCommand  (make-string "{mysend {(thaw (get ~A -command))}}" WidgetEvent)
                               Bind        (make-string "bind ~A ~A ~A" Widget Event TCLCommand)
                               Send        (tk.shen->tcl Bind)
                               Command))

(define wipe
  Canvas Tag ->  (let TCLCommand (make-string "~A delete ~A" Canvas Tag)
                      Send       (tk.shen->tcl TCLCommand)
                      Tag))                                            )
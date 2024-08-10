(package ide (append (external tk) (internal tk) (external stlib)
                     [titlefont splogo .above .above.right .below
                      .above.right.top .top.load .top.plugins
                      .top.track .top.types .top.settings .below.
                      .top.settings .top.help .above.right.bottom
                      .bottom.d .bottom.tc .bottom.spy .bottom.step
                      .bottom.exit .above.right.title .d1 .d2 .d3 .above.left
                      .above.left.logo f1 f2 f3 f4 f5 f6 f7 f8 f9 f10                      
                      .settings .settings.tcl .settings.tclb .settings.spy 
                      .settings.spyb .settings.step .settings.stepb 
                      .settings.occurs .settings.occursb .settings.mem 
                      .settings.memb .settings.pr .settings.prb thread
                      .settings.ind  .settings.indb .settings.ll 
                      .settings.llb .settings.ok .settings.cancel
                      .settings.fact .settings.factb .settings.cores .settings.coresb
                      .settings.opt .settings.optb .settings.hush .settings.hushb 
                      .settings.system-S .settings.system-Sb .settings.blank
                      .settings.tol .settings.tolb .settings.ll .settings.llb
                      .settings.maxp .settings.maxpb .tracking .datatypes .help
                      .help.header .help.version .warn .warn.exclaim .warn.warning 
                      .plugins p.cores .exit .exit.warning .exit.ok .exit.cancel])                       
                 
(define myIDE
 {--> symbol}
  -> (let Window                (tk.putw (tk.root) -bg (bg))
          Font                  (tk.font titlefont -family "Impact" -size 15)
          Image                 (tk.image splogo "logo3.png")
          Above                 (tk.widget .above frame -bg (bg))
	        AboveRight            (tk.widget .above.right frame -bg (bg))
	        AboveRightTop         (tk.widget .above.right.top frame -bg (bg))
          Load 		              (rb .top.load "Load" (freeze (loadme)))
					Plugins               (rb .top.plugins "Plugins" (freeze (plugins)))
					Track 		            (rb .top.track "Track" (freeze (tracking)))
					Types  	              (rb .top.types "Types" (freeze (userdatatypes)))
					Settings              (rb .top.settings "Settings" (freeze (settings)))
					Help 		              (rb .top.help "Help" (freeze (help)))
					PackAboveRightTop     (tk.pack [Load Plugins Track Types Settings Help] -side left)
					AboveRightBottom      (tk.widget .above.right.bottom frame -bg (bg)) 
					Dummy                 (dummy .bottom.d)
					TC 			              (rb .bottom.tc "tc" (freeze skip))
					Command               (tk.putw TC -command (freeze (do (toggle-tc TC) (nl) (shen.prompt))))
					Spy 			            (rb .bottom.spy "spy" (freeze skip))
					Command               (tk.putw Spy -command (freeze (toggle-spy Spy)))
					Step 		              (rb .bottom.step "step" (freeze skip))
					Command               (tk.putw Step -command (freeze (toggle-step Step)))
					Exit 		              (rb .bottom.exit "exit" (freeze skip))
					Command               (tk.putw Exit -command (freeze (exit)))
					Title                 (tk.widget .above.right.title label 
					                                                    -text (@s "Shen/tk " (version) "/2") 
					  				                                          -font Font 
										                                          -bg (bg) 
										                                          -fg (fg))
					PackAboveRightBottom  (tk.pack [Dummy Dummy Dummy Dummy Dummy TC Spy Step Exit] -side left)
					PackAboveRight        (tk.pack [Title AboveRightTop 
					                                (dummy .d1) (dummy .d2) (dummy .d3) 
					                                AboveRightBottom] -fill y)
          AboveLeft         		(tk.widget .above.left frame -bg (bg))
          Logo            			(tk.widget .above.left.logo label -image Image -bg (bg))
          PackAboveLeft         (tk.pack [Logo])
          PackAbove         		(tk.pack [AboveLeft AboveRight] -side left)
          Below               	(tk.widget .below frame -bg "#003E5B")
          F1 	                  (f-button f1 "F1")
          F2 	                  (f-button f2 "F2")
          F3 	                  (f-button f3 "F3")
          F4 	                  (f-button f4 "F4")
          F5 	                  (f-button f5 "F5")
          F6 	                  (f-button f6 "F6")
          F7 	                  (f-button f7 "F7")
          F8 	                  (f-button f8 "F8")
          F9 	                  (f-button f9 "F9")
          F10 	                (f-button f10 "F10")
          PackBottom            (tk.pack [F1 F2 F3 F4 F5 F6 F7 F8 F9 F10] -side left)
          PackAll               (tk.pack [Above Below] -fill x -pady 5)
          EventLoop             (thread (freeze (event-loop)))
          done))
          
(define exit
  {--> symbol}
  -> (let Window  (tk.widget .exit window -bg (ide.bg))
          Warning (tk.widget .exit.warning label
                                           -text "This will cleanly disconnect TCL/tk. Are you sure you want to do this?" 
                                           -height 5
                                           -fg (ide.fg)
																	         -bg (ide.bg))
          OK      (tk.widget .exit.ok button
                                      -text "OK" 
                                      -fg (ide.fg)
																	    -bg (ide.bg)
																	    -relief flat
																	    -width 30
																	    -command (freeze (do (tk.destroy .exit) (tk.exit))))
          Cancel  (tk.widget .exit.cancel button
                                          -text "CANCEL" 
                                          -fg (ide.fg)
																	        -bg (ide.bg)
																	        -relief flat
																	        -width 30
																	        -command (freeze (tk.destroy .exit)))
		      Pack    (tk.pack [Warning])	
		      Pack    (tk.pack [OK Cancel] -side left)
		      ok))              

(define loadme
  {--> symbol}
   -> (let File (tk.openfile)
          (if (= File "")
              abort
              (do (load File) (nl) (shen.prompt) loaded))))
                       
(define settings
  {--> symbol}
   -> (let Window         (tk.widget .settings window -bg (bg))
   
           TCLabel        (my-label .settings.tcl "tc")
           TCButton       (cb .settings.tclb)
           Command        (tk.putw TCButton -command (freeze (toggle TCButton)))
           
           SpyLabel       (my-label .settings.spy "spy")
           SpyButton      (cb .settings.spyb)
           Command        (tk.putw SpyButton -command (freeze (toggle SpyButton)))
           
           StepLabel      (my-label .settings.step "step")
           StepButton     (cb .settings.stepb)
           Command        (tk.putw StepButton -command (freeze (toggle StepButton)))
           
           OccursLabel    (my-label .settings.occurs "occurs")
           OccursButton   (cb .settings.occursb)
           Command        (tk.putw OccursButton -command (freeze (toggle OccursButton)))
           
           FactLabel      (my-label .settings.fact "factorise")
           FactButton     (cb .settings.factb)
           Command        (tk.putw FactButton -command (freeze (toggle FactButton)))
           
           OptLabel       (my-label .settings.opt "optimise")
           OptButton      (cb .settings.optb)
           Command        (tk.putw OptButton -command (freeze (toggle OptButton)))
           
           HushLabel      (my-label .settings.hush "hush")
           HushButton     (cb .settings.hushb)
           Command        (tk.putw HushButton -command (freeze (toggle HushButton)))
           
           SLabel         (my-label .settings.system-S "system S")
           SButton        (cb .settings.system-Sb)
           Command        (tk.putw SButton -command (freeze (toggle SButton)))
           
           MemLabel       (my-label .settings.mem "Prolog memory")
           MemEntry       (tk.widget .settings.memb entry -width 3)
           
           InfLabel       (my-label .settings.pr "max inferences")
           InfEntry       (tk.widget .settings.prb entry -width 3)
           
           IndLabel       (my-label  .settings.ind "indent")
           IndEntry       (tk.widget .settings.indb entry -width 1)
           
           TolLabel       (my-label  .settings.tol "tolerance")
           TolEntry       (tk.widget .settings.tolb entry -width 5)
           
           LineLabel      (my-label .settings.ll "line length")
           LineEntry      (tk.widget .settings.llb entry -width 2)
           
           MaxPLabel      (my-label .settings.maxp "max print")
           MaxPEntry      (tk.widget .settings.maxpb entry -width 5)
           
           CoresLabel     (my-label  .settings.cores "cores")
           CoresEntry     (tk.widget .settings.coresb entry -width 5)
           
           Blank          (tk.widget .settings.blank label -bg (bg) -height 3)
           
           OK             (tk.widget .settings.ok button 
																	   -text "OK"
																	   -fg (fg)
																	   -bg (bg)
																	   -relief flat
																	   -command (freeze (ok TCButton 
                                                          SpyButton 
                                                          StepButton 
                                                          OccursButton 
                                                          FactButton
                                                          OptButton
                                                          SButton
                                                          HushButton
                                                          MemEntry  
                                                          InfEntry        
                                                          IndEntry
                                                          TolEntry      
                                                          LineEntry
                                                          MaxPEntry 
                                                          CoresEntry)))
           CANCEL         (tk.widget .settings.cancel button 
																	   -text "CANCEL"
																	   -fg (fg)
																	   -bg (bg)
																	   -relief flat
																	   -command (freeze (tk.destroy .settings)))
           Pack           (tk.grid [ [TCLabel TCButton MemLabel MemEntry] 
                                     [SpyLabel SpyButton InfLabel InfEntry] 
                                     [StepLabel StepButton IndLabel IndEntry] 
                                     [OccursLabel OccursButton TolLabel TolEntry] 
                                     [FactLabel FactButton LineLabel LineEntry]
                                     [OptLabel OptButton MaxPLabel MaxPEntry]
                                     [SLabel SButton CoresLabel CoresEntry]
                                     [HushLabel HushButton Blank Blank]
                                     [OK Blank Blank CANCEL]] -padx 5 -pady 3)
           Compute        (compute-settings TCButton 
                                            SpyButton 
                                            StepButton 
                                            OccursButton 
                                            FactButton
                                            OptButton 
                                            SButton 
                                            HushButton 
                                            MemEntry  
                                            InfEntry        
                                            IndEntry      
                                            TolEntry
                                            LineEntry
                                            MaxPEntry 
                                            CoresEntry)                           
           done))
 
(define compute-settings
   {button --> button --> button --> button --> button --> button --> button --> button -->
      entry --> entry --> entry --> entry --> entry --> entry --> entry --> symbol}
    TCButton SpyButton StepButton OccursButton FactButton OptButton SButton HushButton 
    MemEntry InfEntry IndEntry TolEntry LineEntry MaxPEntry CoresEntry
       -> (do (if (tc?) (tk.putw TCButton -text "true") (tk.putw TCButton -text "false"))
              (if (spy?) (tk.putw SpyButton -text "true") (tk.putw SpyButton -text "false"))   
              (if (step?) (tk.putw StepButton -text "true") (tk.putw StepButton -text "false"))
              (if (occurs?) (tk.putw OccursButton -text "true") (tk.putw OccursButton -text "false"))
              (if (factorise?) (tk.putw FactButton -text "true") (tk.putw FactButton -text "false"))
              (if (hush?) (tk.putw HushButton -text "true") (tk.putw HushButton -text "false"))
              (if (optimise?) (tk.putw OptButton -text "true") (tk.putw OptButton -text "false"))
              (if (system-S?) (tk.putw SButton -text "true") (tk.putw OptButton -text "false"))
              (tk.putw MemEntry -text (log10s (prolog-memory -1)))
              (tk.putw InfEntry -text (log10s (maxinferences -1)))
              (tk.putw IndEntry -text (str (indentation)))
              (tk.putw TolEntry -text (str (tolerance)))
              (tk.putw LineEntry -text (str (linelength)))
              (tk.putw MaxPEntry -text "20")
              (tk.putw CoresEntry -text (str (p.cores)))
              done)) 

(define log10s
  {number --> string}
  N -> (log10sh N 0))
  
(define log10sh
  {number --> number --> string}
  N Log -> (cn "1e" (str (- Log 1)))  where (> (power 10 Log) N)
  N Log -> (log10sh N (+ 1 Log))) 
             
(define ok
   {button --> button --> button --> button --> button --> button --> button --> button -->
      entry --> entry --> entry --> entry --> entry --> entry --> entry --> symbol}
    TCButton SpyButton StepButton OccursButton FactButton OptButton SButton HushButton 
    MemEntry InfEntry IndEntry TolEntry LineEntry MaxPEntry CoresEntry
       -> (do (if (= (tk.getw TCButton -text) "true") (tc +) (tc -))
              (if (= (tk.getw SpyButton -text) "true") (spy +) (spy -))   
              (if (= (tk.getw StepButton -text) "true") (step +) (step -))
              (if (= (tk.getw OccursButton -text) "true") (occurs-check +) (occurs-check -))
              (if (= (tk.getw FactButton -text) "true") (factorise +) (factorise -))
              (prolog-memory (read-number (tk.getw MemEntry -text) (prolog-memory -1)))
              (maxinferences (read-number (tk.getw InfEntry -text) (maxinferences -1)))
              (set-indentation (read-number (tk.getw IndEntry -text) (indentation)))
              (set-tolerance (read-number (tk.getw TolEntry -text)   (tolerance)))
              (set-linelength (read-number (tk.getw LineEntry -text) (linelength)))
              (tk.destroy .settings)
              done))               
              
(define my-label
  {symbol --> string --> label}
   Name Text -> (tk.widget Name label -text Text -bg (bg) -fg (fg)))
                                                
(define bg
  {--> tk.color}
  -> "#00486A")

(define fg
  {--> tk.color}
  -> "white")
  
(define cb
  {symbol --> button}  
    Name -> (tk.widget Name button -fg "white" -bg "#003E5B" -text "" -width 4))
    
(define toggle
  {button --> string}
   Button -> (if (= (tk.getw Button -text) "true")
                 (tk.putw Button -text "false")
                 (tk.putw Button -text "true")))   
    
(define rb
  {symbol --> string --> (lazy A) --> button}
  Name Text Command -> (let Button (concat* .above.right Name)
													 (tk.widget Button button 
																	 -text Text
																	 -fg (fg)
																	 -bg (bg)
																	 -relief flat
																	 -command Command)))

(define dummy
  {symbol --> label}
  Name -> (tk.widget (concat* .above.right Name) label -bg (bg) -width 20))

(define f-button
  {symbol --> string --> button}
	Name Text -> (let Button (concat* .below. Name)
									 (tk.widget Button button 
												 -text Text
												 -fg (fg)
												 -bg "#003E5B"
                         -width 4
												 -relief flat))) 
												 
(define toggle-tc
  {button --> boolean}
  Button -> (if (tc?)
                (do (tk.putw Button -bg (bg)) (tc -))
                (do (tk.putw Button -bg "orange4") (tc +))))	
         
(define toggle-spy
  {button --> boolean}
  Button -> (if (spy?)
                (do (tk.putw Button -bg (bg)) (spy -))
                (do (tk.putw Button -bg "orange4") (spy +))))
         
(define toggle-step
  {button --> boolean}
  Button -> (if (step?)
                (do (tk.putw Button -bg (bg)) (step -))
                (do (tk.putw Button -bg "orange4") (step +))))
 
(define tracking
  {--> symbol}
   -> (let UserDefs (sort (fn symbol<?) (remove-if (fn shenfn?) (userdefs)))
           (if (empty? UserDefs) 
               (warn "  there are no user functions to track  ") 
               (let MenuXCanvasXButtons (tk.menu .tracking (length UserDefs))
                    Menu                (fst MenuXCanvasXButtons)
                    Canvas              (fst (snd MenuXCanvasXButtons))
                    Buttons             (snd (snd MenuXCanvasXButtons))
                    MenuBG              (tk.putw Menu -bg (bg))
                    CanvasBG            (tk.putw Canvas -bg (bg))
                    CanvasWidth         (tk.putw Canvas -width 150)  
                    ButtonsXSymbols     (associate Buttons UserDefs)
                    BuildMenu           (build-tracking-menu ButtonsXSymbols)
                    done))))
                              
(define warn
  {string --> symbol}
   Warning -> (let Exists?     (tk.winfo .warn exists)
                   Destroy     (if (= Exists? 1) (tk.destroy .warn) skip)
                   Create      (tk.widget .warn window -bg (bg))
                   Message     (tk.widget .warn.warning label -bg (bg) -fg "white" -height 3 -text Warning)
                   Pack        (tk.pack [Message])
                   done))        
           
(define shenfn?
  {symbol --> boolean}
   Symbol -> (string.prefix? "shen." (str Symbol)))           
           
(define build-tracking-menu
  {(list (button * symbol)) --> (list button)}
  ButtonsXSymbols -> (mapc (fn build-tracking-button) ButtonsXSymbols))
  
(define build-tracking-button
  {(button * symbol) --> button}
   (@p Button Symbol) -> (let Tracked? (element? Symbol (tracked))
                              Colour   (if Tracked? (type "orange4" tk.color) (bg))
                              BG       (tk.putw Button -bg Colour)
                              FG       (tk.putw Button -fg "white")
                              Text     (tk.putw Button -text (str Symbol))
                              Command  (tk.putw Button -command (freeze (toggle-track Button Symbol)))
                              Button))      

(define toggle-track 
  {button --> symbol --> symbol}
   Button Symbol -> (if (element? Symbol (tracked))
                        (do (tk.putw Button -bg (bg)) (untrack Symbol)) 
                        (do (tk.putw Button -bg "orange4") (track Symbol))))
                                                         
(define associate
  {(list A) --> (list B) --> (list (A * B))}
   [] [] -> []
   [X | Xs] [Y | Ys] -> [(@p X Y) | (associate Xs Ys)])           
             
(define symbol<?
  {symbol --> symbol --> boolean}
   S1 S2 -> (string<? (str S1) (str S2))) 

(define userdatatypes
  {--> symbol}
   -> (let DataTypes           (sort (fn symbol<?) (datatypes))
           MenuXCanvasXButtons (tk.menu .datatypes (length DataTypes))
           Menu                (fst MenuXCanvasXButtons)
           Canvas              (fst (snd MenuXCanvasXButtons))
           Buttons             (snd (snd MenuXCanvasXButtons))
           MenuBG              (tk.putw Menu -bg (bg))
           CanvasBG            (tk.putw Canvas -bg (bg))
           CanvasWidth         (tk.putw Canvas -width 150)
           ButtonsXSymbols     (associate Buttons DataTypes)
           BuildMenu           (build-datatypes-menu ButtonsXSymbols)
           done))           

(define build-datatypes-menu
  {(list (button * symbol)) --> (list button)}
  ButtonsXSymbols -> (mapc (fn build-datatypes-button) ButtonsXSymbols))
  
(define build-datatypes-button
  {(button * symbol) --> button}
   (@p Button Symbol) -> (let Included? (element? Symbol (included))
                              Colour    (if Included? (type "orange4" tk.color) (bg))
                              BG        (tk.putw Button -bg Colour)
                              FG        (tk.putw Button -fg "white")
                              Text      (tk.putw Button -text (str Symbol))
                              Command   (tk.putw Button -command (freeze (toggle-datatype Button Symbol)))
                              Button))      

(define toggle-datatype 
  {button --> symbol --> (list symbol)}
   Button Symbol -> (if (element? Symbol (included))
                        (do (tk.putw Button -bg (bg)) (preclude [Symbol])) 
                        (do (tk.putw Button -bg "orange4") (include [Symbol])))) 
                        
(define help
  {--> symbol}
   -> (let Window (tk.widget .help window -bg (bg))
           Header (@s "\nCopyright (c) Mark Tarver 2024 \n"
                       "3 clause BSD License \n \n"
                       "For help on this IDE, see https://shenlanguage.org/Shentk.html#ide \n \n")
           Version    (@s "Version: "  (version) "\n"
                       "Language: "  (language) "\n"
                       "Port: "  (port)   "\n"
                       "Porters: "  (porters))            
           HeaderLabel  (tk.widget .help.header label
                                  -bg (bg) 
                                  -fg "white" 
                                  -text Header
                                  -height 5
                                  -padx   10)
           VersionLabel (tk.widget .help.version label
                                  -bg (bg) 
                                  -fg "white" 
                                  -text Version
                                  -height 5
                                  -padx   10
                                  -justify left
                                  -anchor w)                      
           Pack   (tk.pack [HeaderLabel VersionLabel] -fill x)
           done))
 
(define plugins
    {--> symbol}
   -> (let PluginCode             (tk.require "https://shenlanguage.org/plugins.txt")
           Plugins                (pluginlist)
           MenuXCanvasXButtons    (tk.menu .plugins (length Plugins))
           Menu                   (fst MenuXCanvasXButtons)
           Canvas                 (fst (snd MenuXCanvasXButtons))
           Buttons                (snd (snd MenuXCanvasXButtons))
           MenuBG                 (tk.putw Menu -bg (bg))
           CanvasBG               (tk.putw Canvas -bg (bg))
           CanvasWidth            (tk.putw Canvas -width 150)
           ButtonsXTitlesXURL     (associate Buttons Plugins)
           BuildMenu              (build-plugins-menu ButtonsXTitlesXURL)
           Prompt                 (shen.prompt)
           done))
           
(define build-plugins-menu
  {(list (button * string * (list string))) --> (list button)}
  ButtonsXTitlesXURL -> (mapc (fn build-plugins-button) ButtonsXTitlesXURL))
  
(define build-plugins-button
  {(button * string * (list string)) --> button}
   (@p Button Title URLs) -> (let Colour    (bg)
                                 BG        (tk.putw Button -bg Colour)
                                 FG        (tk.putw Button -fg "white")
                                 Text      (tk.putw Button -text Title) 
                                 Command   (tk.putw Button -command (freeze (do (mapc (fn tk.require) URLs) 
                                                                                (shen.prompt))))
                                 Button))
                                
(define event-loop
  {--> A}
   -> (trap-error (tk.event-loop) (/. E (do (warn (error-to-string E)) (event-loop))))) )
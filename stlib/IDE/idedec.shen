(package ide [tk.font titlefont tk.class tk.putw tk.root -bg]

(declare read-number [string --> [number --> number]])
(declare shen.prompt [--> string])
(declare pluginlist [--> [list [string * [list string]]]])

(define read-number
  S N -> (let M (trap-error (hd (read-from-string S)) (/. E skip))
              (if (number? M)
                  M
                  N)))
                  
(put titlefont tk.class tk.font)
                    
(define toplevel
   -> (do (myIDE) (tk.putw (tk.root) -bg (bg)) (shen.shen)))                 )
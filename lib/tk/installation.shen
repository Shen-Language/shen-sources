(package tk (external tk)

(define build-tk-files 
  {--> string}
  -> (transaction-files (transaction-directory)))
             
\\(define transaction-directory
 \\ {--> string}
 \\ -> (do (output "Enter the absolute path of the directory in you wish the Shen/tk transaction files to be stored.~%~%")
  \\       (output "This directory needs to be freely writable, enter the path as a string ending in /~%~%") 
    \\     (output "e.g. c#34;C:/Users/drmta/OneDrive/Documents/ShenTk/c#34; is my answer to this prompt~%~%")
     \\    (output "Go ahead: ")
      \\   (trap-error (input+ string) (/. E (transaction-directory)))))

(define transaction-directory
   {--> string}
    -> "C:/Users/drmta/OneDrive/Documents/ShenTk/")  
                        
(define transaction-files
  {string --> symbol}
  Path -> (let Root     (set *root* (cn Path "root.tcl"))
               Out      (set *out* (cn Path "shen-to-tcl.txt"))
               In       (set *in* (cn Path "tcl-to-shen.txt"))
               AbsRoot  (absolute Root)
               AbsOut   (absolute Out)
               AbsIn    (absolute In)
               CopyRoot (copy-file-with-subs Path "root.tcl" Root)
               CopyOut  (copy-file "shen-to-tcl.txt" Out)  
               CopyIn   (copy-file "tcl-to-shen.txt" In) 
               ok))  
               
(define copy-file-with-subs
  {string --> string --> string}
   Dir File Root -> (let Source         (read-file-as-string File)
                         ChangeSource   (rectify-source Source Dir)
                         (write-to-file Root ChangeSource)))
  
(define rectify-source
  {string --> string --> string}
   (@s "{??in??}" Ss) Dir -> (@s "{" Dir "shen-to-tcl.txt" "}" (rectify-source Ss Dir))
   (@s "{??out??}" Ss) Dir -> (@s "{" Dir "tcl-to-shen.txt" "}" Ss)
   (@s S Ss) Dir -> (@s S (rectify-source Ss Dir)))    
         
(build-tk-files)         )                                                    
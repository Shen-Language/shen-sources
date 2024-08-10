(package file [append-files append-files-with-open-stream mapc
                copy-file file-size reopen errout copy-file-with-open-stream 
                file-exists? newv ascii]
                
(defmacro file-macro
  [errout X Default ErrFile] -> (let  Err (newv)
                                      Open (newv)
                                      Record (newv)
                                      Close (newv)
                                      E (newv)
                                      [trap-error X [/. E [let  Err [error-to-string E]
                                                                Open [trap-error [reopen ErrFile] [/. E [open ErrFile out]]]
                                                                Record [pr Err Open]
                                                                Close [close Open]
                                                                Default]]]))
  
(define append-files
  {(list string) --> string --> string}
   Files File -> (let Stream (append-files-with-open-stream Files File)
                      Close (close Stream)
                      File))
                         
(define append-files-with-open-stream
  {(list string) --> string --> (stream out)}
   Files File -> (error "cannot read and write to ~A at the same time~%" File)   where (element? File Files)
   Files File -> (let OutStream (open File out)
                      Write (mapc (/. F (read&write (open F in) OutStream)) Files)
                      OutStream))
                      
(define read&write
  {(stream in) --> (stream out) --> number}
   In Out -> (read&write-h (read-byte In) In Out))
   
(define read&write-h
  {number --> (stream in) --> (stream out) --> number}
  -1 In Out -> -1
  Byte In Out -> (read&write-h (read-byte In) In (do (write-byte Byte Out) Out)))                            
                       
(define reopen
  {string --> (stream out)}
   File -> (let ByteList (read-file-as-bytelist File)
                Open (open File out)
                Write (mapc (/. Byte (write-byte Byte Open)) ByteList)
                Open))
                                                            
(define copy-file
  {string --> string --> string}
  InFile OutFile -> (append-files [InFile] OutFile))                                                                
                                                          
(define copy-file-with-open-stream
  {string --> string --> (stream out)}
  InFile OutFile -> (append-files-with-open-stream [InFile] OutFile))
  
(define file-exists?
  {string --> boolean}
   File -> (trap-error (do (close (open File in)) true) (/. E false)))  
                                                                                   
(define file-size
  {string --> number}
  File -> (let Stream (open File in)
               Size (file-size-loop Stream 0 (read-byte Stream))
               Close (close Stream)
               Size))
  
(define file-size-loop
  {(stream in) --> number --> number --> number}
  _ Size -1 -> Size
  Stream Size _ -> (file-size-loop Stream (+ 1 Size) (read-byte Stream))) 
  
(define ascii
  {number --> number --> string --> string}
  Min Max File -> (let Bytes (read-file-as-bytelist File)
                       (scan-bytes Min Max Bytes "")))
               
(define scan-bytes
  {number --> number --> (list number) --> string --> string}
   Min Max [] S -> S
   Min Max [N | Ns] S 
    -> (scan-bytes Min Max Ns (cn S (n->string N)))
                   where (and (>= N Min) (<= N Max))
   Min Max [N | _] S -> (error "character has code ~A: parsed to here~%~%~A" N S)) )
        
                        
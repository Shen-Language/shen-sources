(package encrypt [e-> <-e ignore populate created random mapc tokenise whitespace? url]

(define load-and-decrypt-from-web
  URL TC? -> (shen.load-help TC? (read-and-decrypt-from-web URL)))
  
(define read-and-decrypt-from-web
  URL -> (let Crypted (url URL)
              CryptedBytes (string->listnum Crypted)
              DecryptedBytes (map (fn decrypt-byte) CryptedBytes)
              Data (bytes->shen DecryptedBytes)
              Data)) 
              
(define decrypt-from-web-and-read-to-string
  URL -> (let Crypted (url URL)
              CryptedBytes (string->listnum Crypted)
              DecryptedBytes (map (fn decrypt-byte) CryptedBytes)
              Data (bytes->string DecryptedBytes)
              Data))
              
(define bytes->string
  [] -> ""
  [Byte | Bytes] -> (cn (n->string Byte) (bytes->string Bytes)))                                        

(define string->listnum
  S -> (map (/. X (hd (read-from-string X))) (tokenise (fn whitespace?) S)))
  
(define decrypt-byte
  Byte -> (<-vector (value *decrypt*) Byte))
  
(define bytes->shen    
   ByteList -> (let S-exprs (trap-error (compile (/. X (shen.<s-exprs> X)) ByteList)
                                        (/. E (shen.print-residue (value shen.*residue*))))
                    Process (shen.process-sexprs S-exprs)
                    Process))
                    
(define e-> 
   File -> (let Encrypt (map (fn encrypt-byte) (read-file-as-bytelist File))
                (write-procedure File Encrypt encryption)))
                
(define <-e 
   File -> (let Decrypt (map (fn decrypt-byte) (read-file File))
                (write-procedure File Decrypt decryption)))             
                
(define write-procedure
  File Encrypt/Decrypt Flag -> (let OutFile (cn File ".txt")
                                    Stream (open OutFile out)
                                    Write (if (= Flag encryption)
                                              (mapc (/. X (pr (cn (str X) " ") Stream)) Encrypt/Decrypt)
                                              (mapc (/. X (pr (n->string X) Stream)) Encrypt/Decrypt))
                                    Close (close Stream)
                                    OutFile)) 
                    
(define encrypt-byte
  Byte -> (let Bytes (<-vector (value *encrypt*) Byte)
               N (length Bytes)
               Random (random 1 N)
               Encrypt (nth Random Bytes)    
               Encrypt))
               
(define key
  File -> (let Bytes       (read-file-as-bytelist File)
               Encrypt     (populate (/. E []) [256])
               FillEncrypt (set *encrypt* (fill-encrypt-vector Bytes Encrypt 1))
               Decrypt     (vector (length Bytes))
               FillDecrypt (set *decrypt* (fill-decrypt-vector Decrypt FillEncrypt 1))
               created))
               
(define fill-encrypt-vector
  [] Encrypt _ -> Encrypt
  [Byte | Bytes] Encrypt N -> (fill-encrypt-vector Bytes
                                                   (augment-vector Byte Encrypt N)
                                                   (+ N 1)))
                                                  
(define augment-vector
  Byte Encrypt N -> (let Ns (<-vector Encrypt Byte) (vector-> Encrypt Byte [N | Ns])))                                                    
                                                  
(define fill-decrypt-vector
  Decrypt <> _ -> Decrypt
  Decrypt (@v E Encrypt) N -> (fill-decrypt-vector (fill-decrypt-vector-h Decrypt E N) Encrypt (+ N 1)))
  
(define fill-decrypt-vector-h
  Decrypt [] _ -> Decrypt
  Decrypt [Byte | Bytes] N -> (fill-decrypt-vector-h (Decrypt[Byte] := N) Bytes N)) 
  
(key "Encrypt/tbos.txt")

)
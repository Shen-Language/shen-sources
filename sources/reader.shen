\*                                                   

Copyright (c) 2010-2015, Mark Tarver

All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
1. Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.
3. The name of Mark Tarver may not be used to endorse or promote products
   derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY Mark Tarver ''AS IS'' AND ANY
EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL Mark Tarver BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.c#34;



*\

(package shen []

(define read-file-as-bytelist
 File -> (let Stream (open File in)
               Byte (read-byte Stream)
               Bytes (read-file-as-bytelist-help Stream Byte [])
               Close (close Stream)
               (reverse Bytes)))  

(define read-file-as-bytelist-help
  Stream -1 Bytes -> Bytes
  Stream Byte Bytes -> (read-file-as-bytelist-help Stream (read-byte Stream) [Byte | Bytes]))

(define read-file-as-string
   File -> (let Stream (open File in) 
               (rfas-h Stream (read-byte Stream) "")))
               
(define rfas-h
  Stream -1 String -> (do (close Stream) String)
  Stream N String -> (rfas-h Stream (read-byte Stream) (cn String (n->string N))))  

(define input
  Stream -> (eval-kl (read Stream)))

(define input+ 
  Type Stream -> (let Mono? (monotype Type)
                      Input (read Stream)                      
                      (if (= false (typecheck Input (demodulate Type)))
                          (error "type error: ~R is not of type ~R~%" Input Type)
                          (eval-kl Input))))

(define monotype
  [X | Y] -> (map (/. Z (monotype Z)) [X | Y])
  X -> (if (variable? X) (error "input+ expects a monotype: not ~A~%" X) X))

(define read
  Stream -> (hd (read-loop Stream (read-byte Stream) [])))
  
(define it 
  -> (value *it*))  

(define read-loop
  _ 94 Bytes -> (error "read aborted")
  _ -1 Bytes -> (if (empty? Bytes)
                    (simple-error "error: empty stream")
                    (compile (/. X (<st_input> X)) Bytes (/. E E)))
  Stream Byte Bytes -> (let AllBytes (append Bytes [Byte])
                            It (record-it AllBytes)
                            Read (compile (/. X (<st_input> X)) AllBytes (/. E nextbyte))
                            (if (or (= Read nextbyte) (empty? Read))
                                (read-loop Stream (read-byte Stream) AllBytes)
                                Read))    where (terminator? Byte) 
  Stream Byte Bytes -> (read-loop Stream (read-byte Stream) (append Bytes [Byte])))   
  
(define terminator?
  Byte -> (element? Byte [9 10 13 32 34 41 93]))           

(define lineread
  Stream -> (lineread-loop (read-byte Stream) [] Stream))

(define lineread-loop
  -1 Bytes Stream -> (if (empty? Bytes)
                         (simple-error "empty stream")
                         (compile (/. X (<st_input> X)) Bytes (/. E E)))
  Byte _ Stream -> (error "line read aborted")  where (= Byte (hat))
  Byte Bytes Stream -> (let Line (compile (/. X (<st_input> X)) Bytes (/. E nextline))
                            It (record-it Bytes)
                            (if (or (= Line nextline) (empty? Line))
                                (lineread-loop (read-byte Stream) (append Bytes [Byte]) Stream)
                                Line))	where (element? Byte [(newline) (carriage-return)])
  Byte Bytes Stream -> (lineread-loop (read-byte Stream) (append Bytes [Byte]) Stream))

(define record-it
  Bytes -> (let TrimLeft (trim-whitespace Bytes)
                TrimRight (trim-whitespace (reverse TrimLeft))
                Trimmed (reverse TrimRight)
                (record-it-h Trimmed)))
                
(define trim-whitespace
  [Byte | Bytes] -> (trim-whitespace Bytes)   where (element? Byte [9 10 13 32])
  Bytes -> Bytes)               
                
(define record-it-h
  Bytes -> (do (set *it* (cn-all (map (/. X (n->string X)) Bytes))) Bytes))

(define cn-all
  [] -> ""
  [S | Ss] -> (cn S (cn-all Ss)))

(define read-file
  File -> (let Bytelist (read-file-as-bytelist File)
               (compile (/. X (<st_input> X)) Bytelist (/. X (read-error X)))))

(define read-from-string
  S -> (let Ns (map (/. X (string->n X)) (explode S))
            (compile (/. X (<st_input> X)) 
                     Ns 
                     (/. X (read-error X)))))

(define read-error
  [[Byte | Bytes] _] -> (error "read error here:~%~% ~A~%" (compress-50 50 [Byte | Bytes]))
  _ -> (error "read error~%"))

(define compress-50
  _ [] -> ""
  0 _ -> ""
  N [Byte | Bytes] -> (cn (n->string Byte) (compress-50 (- N 1) Bytes)))

(defcc <st_input>
  <lsb> <st_input1> <rsb> <st_input2> 
    := [(macroexpand (cons_form <st_input1>)) | <st_input2>];
  <lrb>  <st_input1> <rrb> <st_input2> 
   := (package-macro (macroexpand <st_input1>) <st_input2>);
  <lcurly> <st_input> := [{ | <st_input>];
  <rcurly> <st_input> := [} | <st_input>];    
  <bar> <st_input> := [bar! | <st_input>];  
  <semicolon> <st_input> := [; | <st_input>];
  <colon> <equal> <st_input> := [:= | <st_input>];
  <colon> <minus> <st_input> := [:- | <st_input>];
  <colon> <st_input> := [: | <st_input>];
  <comma> <st_input> := [(intern ",") | <st_input>];
  <comment> <st_input> := <st_input>;
  <atom> <st_input> := [(macroexpand <atom>) | <st_input>];
  <whitespaces> <st_input> := <st_input>;
  <e> := [];)
  
(defcc <lsb>
   91 := skip;)  
   
(defcc <rsb>
   93 := skip;)     
  
(defcc <lcurly>
  123 := skip;)
  
(defcc <rcurly>
  125 := skip;)
  
(defcc <bar>
  124 := skip;)  
  
(defcc <semicolon>
  59 := skip;) 
  
(defcc <colon>
  58 := skip;)     
      
(defcc <comma>
  44 := skip;)  
  
(defcc <equal>
  61 := skip;)     
   
(defcc <minus>
  45 := skip;)      
  
(defcc <lrb>
  40 := skip;)
  
(defcc <rrb>
  41 := skip;)   
  
(defcc <atom>
  <str> := (control-chars <str>); 
  <number> := <number>; 
  <sym> := (if (= <sym> "<>")
               [vector 0]
               (intern <sym>));)

(define control-chars
  [] -> ""
  ["c" "#" | Ss]
   -> (let CodePoint (code-point Ss)
           AfterCodePoint (after-codepoint Ss)
           (@s (n->string (decimalise CodePoint)) (control-chars AfterCodePoint)))  
  [S | Ss] -> (@s S (control-chars Ss)))
                          
(define code-point
  [";" | _] -> ""
  [S | Ss] -> [S | (code-point Ss)]  
                     where (element? S ["0" "1" "2" "3" "4" "5" "6" "7" "8" "9" "0"])
  S -> (error "code point parse error ~A~%" S))                          
                          
(define after-codepoint
   [] -> []
   [";" | Ss] -> Ss
   [_ | Ss] -> (after-codepoint Ss))                          
                          
(define decimalise
  S -> (pre (reverse (digits->integers S)) 0))

(define digits->integers
  ["0" | S] -> [0 | (digits->integers S)]
  ["1" | S] -> [1 | (digits->integers S)]
  ["2" | S] -> [2 | (digits->integers S)]
  ["3" | S] -> [3 | (digits->integers S)]
  ["4" | S] -> [4 | (digits->integers S)]
  ["5" | S] -> [5 | (digits->integers S)]
  ["6" | S] -> [6 | (digits->integers S)]
  ["7" | S] -> [7 | (digits->integers S)]
  ["8" | S] -> [8 | (digits->integers S)]
  ["9" | S] -> [9 | (digits->integers S)]
   _ -> [])

(defcc <sym>
  <alpha> <alphanums> := (@s <alpha> <alphanums>);)

(defcc <alphanums>
   <alphanum> <alphanums> := (@s <alphanum> <alphanums>);
   <e> := "";)  
   
(defcc <alphanum>
    <alpha> := <alpha>;
    <num> := <num>;) 	

(defcc <num>
  Byte := (n->string Byte)    where (numbyte? Byte);)

(define numbyte?
  48 -> true
  49 -> true
  50 -> true
  51 -> true 
  52 -> true
  53 -> true 
  54 -> true 
  55 -> true
  56 -> true 
  57 -> true
  _ -> false)
   
(defcc <alpha>
  Byte := (n->string Byte)	  where (symbol-code? Byte);)

(define symbol-code?
  N -> (or (= N 126)
           (and (> N 94) (< N 123))
           (and (> N 59) (< N 91))
           (and (> N 41) (< N 58) (not (= N 44)))
           (and (> N 34) (< N 40))
           (= N 33)))
  
(defcc <str>
  <dbq> <strcontents> <dbq> := <strcontents>;)
  
(defcc <dbq>
  Byte := Byte	where (= Byte 34);)    
  
(defcc <strcontents>
  <strc> <strcontents> := [<strc> | <strcontents>];
  <e> := [];)
  
(defcc <byte>
  Byte := (n->string Byte);)  
  
(defcc <strc>
  Byte := (n->string Byte)	where (not (= Byte 34));)
  
(defcc <number>
   <minus> <number> := (- 0 <number>);
   <plus> <number> := <number>;
   <predigits> <stop> <postdigits> <E> <log10> 
   := (* (expt 10 <log10>) (+ (pre (reverse <predigits>) 0) (post <postdigits> 1)));
   <digits> <E> <log10> := (* (expt 10 <log10>) (pre (reverse <digits>) 0));
   <predigits> <stop> <postdigits> 
   := (+ (pre (reverse <predigits>) 0) (post <postdigits> 1));
   <digits> := (pre (reverse <digits>) 0);)

(defcc <E>
   101 := skip;)

(defcc <log10>
  <minus> <digits> := (- 0 (pre (reverse <digits>) 0));
  <digits> := (pre (reverse <digits>) 0);)
   
(defcc <plus>
  Byte := Byte 	where (= Byte 43);)
  
(defcc <stop>
  Byte := Byte 	where (= Byte 46);)      
   
(defcc <predigits>
    <digits> := <digits>;
    <e> := [];)
    
(defcc <postdigits>
  <digits> := <digits>;)

(defcc <digits>
   <digit> <digits> := [<digit> | <digits>];
   <digit> := [<digit>];)
 
(defcc <digit>
  X := (byte->digit X)  where (numbyte? X);)
  
(define byte->digit  
  48 -> 0   
  49 -> 1  
  50 -> 2  
  51 -> 3  
  52 -> 4  
  53 -> 5  
  54 -> 6
  55 -> 7   
  56 -> 8   
  57 -> 9)
  
(define pre
  [] _ -> 0
  [N | Ns] Expt -> (+ (* (expt 10 Expt) N) (pre Ns (+ Expt 1))))
  
(define post
  [] _ -> 0
  [N | Ns] Expt -> (+ (* (expt 10 (- 0 Expt)) N) (post Ns (+ Expt 1)))) 
    
(define expt
  _ 0 -> 1
  Base Expt -> (* Base (expt Base (- Expt 1)))  where (> Expt 0)
  Base Expt -> (* 1.0 (/ (expt Base (+ Expt 1)) Base)))  
  
(defcc <st_input1>
  <st_input> := <st_input>;)

(defcc <st_input2>
  <st_input> := <st_input>;)

(defcc <comment>
  <singleline> := skip;
  <multiline> := skip;)

(defcc <singleline>
  <backslash> <backslash> <anysingle> <return> := skip;)

(defcc <backslash>
  92 := skip;)

(defcc <anysingle>
   <non-return> <anysingle> := skip;
   <e> := skip;)

(defcc <non-return>
   X :=  skip   where (not (element? X [10 13]));)

(defcc <return>
  X  := skip  where (element? X [10 13]);)
 
(defcc <multiline>
  <backslash> <times> <anymulti> := skip;)

(defcc <times>
  42 := skip;)       

(defcc <anymulti>
  <comment> <anymulti> := skip;
  <times> <backslash> := skip;
  X <anymulti> := skip;)

(defcc <whitespaces>
  <whitespace> <whitespaces> := skip;
  <whitespace> := skip;)

(defcc <whitespace>
  X := skip     where (let Case X
                      (or (= Case 32) 
                          (= Case 13) 
                          (= Case 10) 
                          (= Case 9)));)                      

(define cons_form
  [] -> []
  [X Bar Y] -> [cons X Y]	  where (= Bar bar!)
  [X | Y] -> [cons X (cons_form Y)])  
 
(define package-macro
    [$ S] Stream -> (append (explode S) Stream)
    [package null _ | Code] Stream -> (append Code Stream)
    [package PackageName Exceptions | Code] Stream
     -> (let ListofExceptions (eval-without-macros Exceptions)
             External (record-exceptions ListofExceptions PackageName)
             PackageNameDot (intern (cn (str PackageName) "."))
             ExpPackageName (explode PackageName)
             Packaged (packageh PackageNameDot ListofExceptions Code ExpPackageName) 
             Internal (record-internal PackageName (internal-symbols ExpPackageName Packaged))
             (append Packaged Stream))
    X Stream -> [X | Stream])  

(define record-exceptions 
  ListofExceptions PackageName 
   -> (let CurrExceptions (trap-error (get PackageName external-symbols) (/. E []))
           AllExceptions (union ListofExceptions CurrExceptions)
           (put PackageName external-symbols AllExceptions))) 

(define record-internal
  PackageName Internal -> (put PackageName internal-symbols (union Internal (trap-error (get PackageName internal-symbols) (/. E [])))))

(define internal-symbols
  ExpPackageName PackageSymbol -> [PackageSymbol]  where (and (symbol? PackageSymbol) (prefix? ExpPackageName (explode PackageSymbol)))
  ExpPackageName [X | Y] -> (union (internal-symbols ExpPackageName X) (internal-symbols ExpPackageName Y))
  _ _ -> [])
       
(define packageh
    PackageNameDot Exceptions [X | Y] ExpPackageName
      -> [(packageh PackageNameDot Exceptions X ExpPackageName) | (packageh PackageNameDot Exceptions Y ExpPackageName)]
    PackageNameDot Exceptions X ExpPackageName -> X  
                 where (or (sysfunc? X) 
                           (variable? X) 
                           (element? X Exceptions)
                           (doubleunderline? X) 
                           (singleunderline? X))                           
    PackageNameDot Exceptions X ExpPackageName -> (concat PackageNameDot X)                                                          
             where (and (symbol? X) 
                        (let ExplodeX (explode X)
                             (and (not (prefix? [($ shen.)] ExplodeX))
                                  (not (prefix? ExpPackageName ExplodeX)))))
    _ _ X _ -> X) 

        )


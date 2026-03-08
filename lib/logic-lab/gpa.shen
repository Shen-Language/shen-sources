\* 

Copyright (c) 2010-2021, Mark Tarver

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
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *\
 
 (package logiclab (append (external stlib) 
                          [sequent proof thm prop thm back d-rule step])

(synonyms sequent ((list prop) * prop)
          proof   (list (step * string))
          tactics (list tactic)
          strings (list string)
          tactic  (step --> step))
          
(datatype step  
  
  _____________________________________
  add-thm : (prop --> step --> step);
  
  X : step;
  __________________
  X : (list sequent);) 
  
(d-rule thm (Path : string)

  let Hypotheses (get-theorem Path Hypotheses)
  P;
  __________
  P;)
  
(define get-theorem
  {string --> (list prop) --> (list prop)}
   File Hyps -> (trap-error
                (let Open    (open File in)
                     Problem (input+ sequent Open)
                     IsThm?  (empty? (fst Problem))
                     Thm     (snd Problem)
                     Tactics (input+ tactics Open)
                     Intro   (type (intro [Problem]) step)
                     Close   (close Open)
                     (cases  (not IsThm?) Hyps
                             (can-prove? Tactics Intro) [Thm | Hyps]
                             true Hyps)) (/. E (do (pr (error-to-string E))
                                                   (nl)
                                                   Hyps))))
                             
(define add-thm
  {prop --> (list sequent) --> (list sequent)}
  Thm [(@p Hyps P) | Sequents] -> [(@p [Thm | Hyps] P) | Sequents])

(define can-prove?
  {(list (step --> step)) --> step --> boolean}
   [] Step -> (empty? Step)
   [Tactic | Tactics] Step -> (can-prove? Tactics (Tactic Step)))           
  
(defmacro gpa-macro
  [gpa] -> [gpa ""])  

(define gpa
  {string --> boolean}
    "" -> (let Sequent (enter-sequent)
               Step   (intro [Sequent])
               (gpa-loop Step []))
    File -> (recover-proof File)) 
 
(define recover-proof
  {string --> boolean}
  File ->   (let Open (open File in)
                 Sequent (input+ sequent Open)
                 Tactics (input+ tactics Open)
                 Strings (input+ strings Open)
                 Close (close Open)
                 Step (intro [Sequent])
                 (reconstruct Strings Tactics Step [])))            
                 
(define reconstruct
  {(list string) --> (list (step --> step)) --> step --> proof --> boolean}
   [] [] Step Proof -> (gpa-loop Step Proof)
   [String | Strings] [Tactic | Tactics] Step Proof 
    -> (reconstruct Strings Tactics (Tactic Step) [(@p Step String) | Proof])) 
     
(define enter-sequent
  {--> sequent} 
     -> (let NL (nl)
              Ctxt (input-assumptions 1) 
              P (read-conclusion)
              Sequents (@p Ctxt P)
              Sequents))
              
(define read-conclusion
  {--> prop}
   -> (let Prompt (output "~%>> ")
           (trap-error (read-prop) 
                 (/. E (let Str (error-to-string E)
                            (if (= Str "read aborted") 
                                (abort)
                                (do (pr Str) (read-conclusion)))))))) 
                                
(define input-assumptions
   {number --> (list prop)}
   N -> (let Prompt (output "~A. " N)
              (trap-error [(read-prop) | (input-assumptions (+ N 1))] 
                 (/. E (let Str (error-to-string E)
                            (if (= Str "read aborted") 
                                []
                                (do (pr Str)
                                    (nl)
                                    (input-assumptions N))))))))
                                    
(define read-prop
  {--> prop}
   -> (input+ prop))
 
(define gpa-loop
  {step --> proof --> boolean}
   Step Proof -> (do (save-proof-to-file (ask-for-file) (reverse Proof)) true)  where (empty? Step)
   Step Proof -> (let Show     (pr (format-sequent (view-step Step) (length Proof)))
                       AutoSave (save-proof-to-file "tempprf" (reverse Proof))
                       Tactic (trap-error (tactic) (/. E (error-routine E)))
                       (if (= (trimwsp (it)) "back") 
                           (rollback (n-steps) Step Proof)
                           (gpa-loop (Tactic Step) [(@p Step (it)) | Proof]))))
                           
(define trimwsp
  {string --> string}
   X -> (string.trim-if (fn whitespace?) X))                           
                                    
(define save-proof-to-file
  {string --> proof --> string}
  "" _ -> ""
  _ [] -> ""
  Filename Proof -> (let  SavePrf  (save-prf (cn Filename ".prf") Proof)
                          SaveVPrf (save-vprf (cn Filename ".vprf") Proof)
                          Filename))
                          
(define save-prf
  {string --> proof --> (list A)}                         
   Filename Proof -> (let Open (open Filename out)
                          (print-steps Proof 0 Open)))  
                          
(define print-steps
  {proof --> number --> (stream out) --> (list A)}
   [] _ Open -> (close Open)
   [(@p Step Tactic) | Proof] N Open -> (let Sequents (step->sequents Step)
                                              Format   (format-sequent Sequents N)
                                              Write1   (pr Format Open)
                                              Write2   (pr "c#13;> " Open)
                                              Write3   (pr Tactic Open)
                                              Write4   (pr "c#13;" Open)
                                              (print-steps Proof (+ N 1) Open)))                                                         
                                          
(define save-vprf
  {string --> proof --> string}
   Filename Proof -> (let Sequent (get-problem Proof)
                          Tactics (map (fn snd) Proof)
                          Open (open Filename out)
                          Write1 (pr Sequent Open)
                          Return (pr "c#13;c#13;" Open)
                          Write2 (pr "[" Open)
                          Write3 (map (/. X (do (pr X Open) (pr "c#13;" Open))) Tactics)
                          Write4 (pr "]" Open)
                          Return (pr "c#13;c#13;" Open)
                          Write5 (pr "[" Open)
                          Write6 (map (/. X (do (pr (str X) Open) (pr "c#13;" Open))) Tactics)
                          Write7 (pr "]" Open)
                          Return (pr "c#13;c#13;" Open)
                          Close  (close Open)                          
                          Filename))
  
(define atom-call?
  {string --> boolean}
   (@s "(" _) -> false
   _ -> true)                          
                          
(define get-problem
  {proof --> string}
   [(@p Step Tactic) | _] -> (make-string "~S" (head (step->sequents Step))))
   
(define step->sequents
  {step --> (list sequent)}
   Step -> Step)                                
                             
(define error-routine
  {exception --> (step --> step)}
   E -> (/. X X)              where (= (trimwsp (it)) "back")
   E -> (let Print (pr (error-to-string E))
             NL    (nl)
             Question (y-or-n? "do you wish to abort this proof?")
             (if Question (abort) (trap-error (tactic) (/. E (error-routine E))))))                      
                             
(define n-steps
  {--> number}
  -> (let Prompt (pr "how many steps? ") 
          N (trap-error (input+ number) (/. E (do (output "~A~%" (error-to-string E)) (n-steps)))) 
          (if (natural? N) N (n-steps))))                                                      
                         
(define rollback
  {number --> step --> proof --> boolean}
  0 Step Proof              -> (gpa-loop Step Proof)
  1 _ [(@p Step _) | Proof] -> (gpa-loop Step Proof)
  N _ [(@p Step _) | Proof] -> (rollback (- N 1) Step Proof)
  _ Step Proof  -> (gpa-loop Step Proof))
   
(define ask-for-file
  {--> string}
   -> (do (pr "save to ") (trap-error (input+ string) (/. E "")))) 
                
(define view-step
  {step --> (list sequent)}
   S -> S)                     
                     
(define format-sequent
  {(list sequent) --> number --> string}
    [(@p Ctxt P) | Sequents] N
         -> (let Line (make-string "=========================~%Step ~A [~A]~%~%" 
                             N
                             (length [(@p Ctxt P) | Sequents]))
               C (make-string "?- ~S~%~%" P)
               A (enumerate 1 Ctxt)
               (@s Line C A)))
 
(define enumerate 
  {number --> (list prop) --> string}    
   _ [] -> " "
   N [P | Ps] -> (cn (make-string "~A. ~A~%" N P)
                     (enumerate (+ N 1) Ps)))
                            
(define tactic
  {--> tactic}
  -> (let Prompt   (output "~%> ")
          (input+ tactic)))                                      ) 
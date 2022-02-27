\\           Copyright (c) 2010-2019, Mark Tarver

\\                  All rights reserved.

(package shen []

(define f-error
  F -> (do (output "partial function ~A;~%" F)
           (if (and (not (tracked? F))
                    (y-or-n? (make-string "track ~A? " F)))
               (track-function (ps F))
               ok)
           (simple-error "aborted")))

(define tracked?
  F -> (element? F (value *tracking*)))

(define track
  F -> (let Source (ps F)
            (track-function Source)))

(define track-function
  [defun F Params Body]
   -> (let KL [defun F Params (insert-tracking-code F Params Body)]
           Ob (eval-kl KL)
           Tr (set *tracking* [Ob | (value *tracking*)])
           Ob)
   _ -> (simple-error "implementation error in shen.track-function")        )

(define insert-tracking-code
  F Params Body -> [do [set *call* [+ [value *call*] 1]]
                       [do [input-track [value *call*] F (cons-form (prolog-track Body Params))]
                           [do [terpri-or-read-char]
                        [let (protect Result) Body
                             [do [output-track [value *call*] F (protect Result)]
                                 [do [set *call* [- [value *call*] 1]]
                                     [do [terpri-or-read-char]
                                         (protect Result)]]]]]]])

(define prolog-track
  Body Params -> Params   where (= (occurrences incinfs Body) 0)
  Body Params -> (vector-dereference Params (vector-parameter Params)))

(define vector-parameter
  [] -> []
  [Vector Lock Key Continuation] -> Vector
  [_ | Parameters] -> (vector-parameter Parameters))

(define vector-dereference
  Parameters [] ->  Parameters
  [Vector Lock Key Continuation] _ -> [Vector Lock Key Continuation]
  [Parameter | Parameters] Vector -> [[deref Parameter Vector] | (vector-dereference Parameters Vector)])

(define step
  + -> (set *step* true)
  - -> (set *step* false)
  _ -> (error "step expects a + or a -.~%"))

(define spy
  + -> (set *spy* true)
  - -> (set *spy* false)
  _ -> (error "spy expects a + or a -.~%"))

(define terpri-or-read-char
  -> (if (value *step*)
         (check-byte (read-byte (value *stinput*)))
         (nl)))

(define check-byte
  94 -> (error "aborted")
  _ -> true)

(define input-track
  N F Args
  -> (do (output "~%~A<~A> Inputs to ~A ~%~A" (spaces N) N F (spaces N) Args)
         (recursively-print Args)))

(define recursively-print
  [] -> (output " ==>")
  [X | Y] -> (do (print X) (do (output ", ") (recursively-print Y)))
  _ -> (simple-error "implementation error in shen.recursively-print"))

(define spaces
 0 -> ""
 N -> (cn " " (spaces (- N 1))))

(define output-track
  N F Result -> (output "~%~A<~A> Output from ~A ~%~A==> ~S" (spaces N) N F (spaces N) Result))

(define untrack
  F -> (do (set *tracking* (remove F (value *tracking*)))
           (trap-error (eval (ps F)) (/. E F))))

(define remove
  X Y -> (remove-h X Y []))

(define remove-h
  _ [] X -> (reverse X)
  X [X | Y] Z -> (remove-h X Y Z)
  X [Y | Z] W -> (remove-h X Z [Y | W])
  _ _ _ -> (simple-error "implementation error in shen.remove-h"))

(define profile
  Func -> (do (set *profiled* [Func | (value *profiled*)])
              (profile-help (ps Func))))

(define profile-help
  [defun F Params Code]
   -> (let G (gensym f)
           Profile [defun F Params (profile-func F Params [G | Params])]
           Def [defun G Params (subst G F Code)]
           CompileProfile (eval-kl Profile)
           CompileG (eval-kl Def)
           F)
  _ -> (error "Cannot profile.~%"))

(define unprofile
  F -> (do (set *profiled* (remove F (value *profiled*)))
           (trap-error (eval (ps F)) (/. E F))))

(define profiled?
  F -> (element? F (value *profiled*)))

(define profile-func
  F Params Code -> [let (protect Start) [get-time run]
                     [let (protect Result) Code
                       [let (protect Finish) [- [get-time run] (protect Start)]
                         [let (protect Record)
                              [put-profile F [+ [get-profile F] (protect Finish)]]
                              (protect Result)]]]])

(define profile-results
   F -> (let Results (get-profile F)
             Initialise (put-profile F 0)
             (@p F Results)))

(define get-profile
  F -> (trap-error (get F profile) (/. E 0)))

(define put-profile
  F Time -> (put F profile Time)))
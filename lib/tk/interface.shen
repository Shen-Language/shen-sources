(package tk (external tk)

\\(set *out* "C:/Program Files/ShenTk/shen-to-tcl.txt")
\\(set *in* "C:/Program Files/ShenTk/tcl-to-shen.txt")

\\(absolute (value *out*))
\\(absolute (value *in*))

(set *suspend?* false)

(define shen->tcl
  String -> (let Sink    (open (value *out*) out)
                 Write   (pr (cn String " eot") Sink)
                 Close   (close Sink)
                 String)                 where (ready?)
  String -> (shen->tcl String))

(define ready?
  -> (empty? (read-file (value *out*))))

(define tcl->shen
  -> (tcl->shen-loop (tcl->shen-no-hang)))

\\(define tcl->shen-loop
  \\skip -> (tcl->shen-loop (tcl->shen-no-hang))
  \\X    -> (eval X))

(define tcl->shen-loop
  skip -> (tcl->shen-loop (tcl->shen-no-hang))
  X    -> (trap-error
            (eval X)
            (/. E
               (let Message (error-to-string E)
                    (if (= Message "TCL/tk exit")
                        (pr "TCL/tk exit you may close the window")
                        (pr Message))))))

(define tcl->shen-no-hang
  -> (let Command (strip-eot (read-file (value *in*)))
          (if (empty? Command)
              skip
              (let Flush (flush)
              Command))))

(define flush
  -> (let Sink  (open (value *in*) out)
          Write (pr "" Sink)
          (close Sink)))

(define event-loop
  -> (event-loop-help (tcl->shen)))

(define event-loop-help
  _       -> (event-loop-help skip)     where (value *suspend?*)
  _       -> (event-loop-help (tcl->shen)))

(define suspend
  -> (set *suspend?* true))

(define resume
  -> (set *suspend?* false))

(define strip-eot
  [X eot] -> X
  _ -> [])

(define check-error
  -> (check-error-loop (ready?)))

(define check-error-loop
  true -> (check-error-message (tcl->shen-no-hang))
  _    -> (check-error-loop (ready?)))

(define check-error-message
  [simple-error S] -> (simple-error S)
  _         -> skip)

(define exit
  ->  (do (shen->tcl "global myloop; set myloop 0") (error "TCL/tk exit")))  )
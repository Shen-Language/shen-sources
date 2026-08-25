(DEFUN open-process-stream (CMD &OPTIONAL ARGUMENTS)
   (LET ((PROCESS (SB-EXT::RUN-PROGRAM CMD ARGUMENTS
                    :WAIT      NIL
                    :INPUT     :STREAM
                    :OUTPUT    :STREAM)))
     (MAKE-TWO-WAY-STREAM  (SB-EXT::PROCESS-OUTPUT PROCESS)
     (SB-EXT::PROCESS-INPUT PROCESS))))

(update-lambda-table 'open-process-stream 2)

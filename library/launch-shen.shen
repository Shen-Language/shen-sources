\* Copyright (c) 2019 Bruno Deferrari. *\
\* BSD 3-Clause License: http://opensource.org/licenses/BSD-3-Clause *\

\\ See docs at the end of the file

(package launch-shen [*argv* success error launch-repl show-help unknown-arguments]

(define quiet-load
  File -> (let Contents (read-file File)
            (map (/. X (shen.eval-without-macros X)) Contents)))

(define version-string
  -> (make-string "~A ~R~%"
                  (version)
                  [port [(language) (port)]
                   implementation [(implementation) (release)]]))

(define help-text
  Exe -> (make-string
"Usage: ~A [--version] [--help] <COMMAND> [<ARGS>]

commands:
    repl
        Launches the interactive REPL.
        Default action if no command is supplied.

    script <FILE> [<ARGS>]
        Runs the script in FILE. *argv* is set to [FILE | ARGS].

    eval <ARGS>
        Evaluates expressions and files. ARGS are evaluated from
        left to right and can be a combination of:
            -e, --eval <EXPR>
                Evaluates EXPR and prints result.
            -l, --load <FILE>
                Reads and evaluates FILE.
            -q, --quiet
                Silences interactive output.
            -s, --set <KEY> <VALUE>
                Evaluates KEY, VALUE and sets as global.
            -r, --repl
                Launches the interactive REPL after evaluating
                all the previous expresions." Exe))

(define execute-all
  [] -> [success]
  [Continuation | Rest] -> (do (thaw Continuation)
                               (execute-all Rest)))

(define eval-string
  Code -> (eval (head (read-from-string Code))))

(define eval-flag-map
  "-e" -> "--eval"
  "-l" -> "--load"
  "-q" -> "--quiet"
  "-s" -> "--set"
  "-r" -> "--repl"
  _ -> false)

(define eval-command-h
  [] Acc -> (execute-all (reverse Acc))
  ["--eval" Code | Rest] Acc -> (eval-command-h
                                 Rest
                                 [(freeze (output "~A~%" (eval-string Code))) | Acc])
  ["--load" File | Rest] Acc -> (eval-command-h
                                 Rest
                                 [(freeze (load File)) | Acc])
  ["--quiet" | Rest] Acc -> (eval-command-h
                             Rest
                             [(freeze (set *hush* true)) | Acc])
  ["--set" Key Value | Rest] Acc -> (eval-command-h
                                     Rest
                                     [(freeze (set (eval-string Key)
                                                   (eval-string Value)))
                                      | Acc])
  ["--repl" | Args] Acc -> (do (eval-command-h [] Acc)
                               [launch-repl | Args])
  [Short | Rest] Acc <- (let Long (eval-flag-map Short)
                          (if (= false Long)
                              (fail)
                              (eval-command-h [Long | Rest] Acc)))
  [Unknown | _] _ -> [error (make-string "Invalid eval argument: ~A" Unknown)])

(define eval-command
  Args -> (eval-command-h Args []))

(define script-command
  Script Args -> (do (set *argv* [Script | Args])
                     (quiet-load Script)
                     [success]))

(define launch-shen
  [Exe] -> [launch-repl]
  [Exe "--help" | Args] -> [show-help (help-text Exe)]
  [Exe "--version" | Args] -> [success (version-string)]
  [Exe "repl" | Args] -> [launch-repl | Args]
  [Exe "script" Script | Args] -> (script-command Script Args)
  [Exe "eval" | Args] -> (eval-command Args)
  [Exe UnknownCommandOrFlag | Args] -> [unknown-arguments Exe UnknownCommandOrFlag | Args])

(define default-handle-launch-shen-result
  [success] -> done
  [success Message] -> (output "~A~%" Message)
  [error Message] -> (output "ERROR: ~A~%" Message)
  [launch-repl | _] -> (shen.shen)
  [show-help HelpText] -> (output "~A~%" HelpText)
  [unknown-arguments Exe UnknownCommandOrFlag | Args]
  -> (output "ERROR: Invalid argument: ~A~%Try `~A --help' for more information.~%"
             UnknownCommandOrFlag
             Exe))

)

\\ How to use:
\\
\\ Instead of using `shen.shen` as an entry point, use `launch-shen.launch-shen`.
\\
\\ `launch-shen.launch-shen` accepts as an argument a list containing
\\ all the command line arguments, with the program name as the first argument.
\\ For example:
\\     my-shen eval -e "(+ 1 2)"
\\ should be represented by the list:
\\     ["my-shen" "eval" "-e" "(+ 1 2)"]
\\ and:
\\     /path/to/shen repl
\\ by the list:
\\     ["/path/to/shen" "repl"]
\\
\\ The possible results `(launch-shen.launch-shen ArgList)` are the lists:
\\ - [success]
\\       All arguments processed without errors.
\\ - [success Message]
\\       Success, but with a message to print.
\\ - [error Message]
\\       There was an error (described by Message) when processing
\\       the arguments. The port should print this error and exit with
\\       an error status code if the platform supports it.
\\ - [launch-repl | Args]
\\       Request to launch the repl, can be done by invoking `(shen.shen)`.
\\       `Args` are extra arguments the port may want to do something with.
\\ - [show-help HelpText]
\\       Request to print the help text. HelpText contains the default
\\       help text, the port may add more.
\\ - [unknown-arguments Exe UnknownCommandOrFlag | Args]
\\       Returned when there are arguments that could not be processed.
\\       The port can handle those arguments if it knows how, otherwise
\\       it should let the user know aand exit with an error status code
\\       if the platform supports it.
\\
\\ The `launch-shen.default-handle-launch-shen-result` implements a portable
\\ default behaviour for these results. Ports can use this directly or
\\ process the results they are interested in and pass the rest to
\\ this function.
\\
\\ Example (default behaviour with correct exit codes):
\\
\\     (define my-handle-result
\\       [error Message] -> (do (launch-shen.default-handle-launch-shen-result [error Message])
\\                              (scm.exit 1))
\\       [unknown-arguments | Rest]
\\       -> (do (launch-shen.default-handle-launch-shen-result [unknown-arguments | Rest])
\\              (scm.exit 1))
\\       Other -> (launch-shen.default-handle-launch-shen-result Other))
\\
\\     (my-handle-result (launch-shen.launch-shen ["my-shen" "eval" "-e" "(+ 1 2)"]))

\\ Copyright (c) 2019 Bruno Deferrari.
\\ BSD 3-Clause License: http://opensource.org/licenses/BSD-3-Clause

\\ Documentation: docs/extensions/launcher.md

(package shen.x.launcher [*argv* success error launch-repl show-help unknown-arguments]

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

(define default-handle-result
  [success] -> done
  [success Message] -> (output "~A~%" Message)
  [error Message] -> (output "ERROR: ~A~%" Message)
  [launch-repl | _] -> (shen.repl)
  [show-help HelpText] -> (output "~A~%" HelpText)
  [unknown-arguments Exe UnknownCommandOrFlag | Args]
  -> (output "ERROR: Invalid argument: ~A~%Try `~A --help' for more information.~%"
             UnknownCommandOrFlag
             Exe))

(define main
  Argv -> (default-handle-result (launch-shen Argv)))

)

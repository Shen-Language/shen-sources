# Launcher

This extension provides an alternative entry point for Shen. The alternative
entry point handles command line arguments, providing defaults for some
common cases, ports can choose to extend the list of accepted arguments.
Compared to the default entry-point provided in the kernel (`shen.repl`,
which launches the REPL), the entry-point in this extension implements
basic script running, expression evaluation and file loading.

## Instructions

Instead of using `shen.repl` as an entry point, use either `shen.x.launcher.main`
or `shen.x.launcher.launch-shen` if more control is wanted.

`shen.x.launcher.main` accepts as an argument a list containing
all the command line arguments, with the program name as the first argument.
It provides default behaviour for processing those arguments and handling the
result.

For example:

    my-shen eval -e "(+ 1 2)"

should be represented by the list:

    ["my-shen" "eval" "-e" "(+ 1 2)"]

and:

    /path/to/shen repl

by the list:

    ["/path/to/shen" "repl"]

`shen.x.launcher.launch-shen` takes the same input as `shen.x.launcher.main`
but returns a value so that the caller is able perform custom actions
(like for example processing extra arguments, or extending the help
message).

`(shen.x.launcher.launch-shen ArgList)` will return one of the following lists:

- `[success]`:
    All arguments processed without errors.
- `[success Message]`:
    Success, but with a message to print.
- `[error Message]`:
    There was an error (described by Message) when processing
    the arguments. The port should print this error and exit with
    an error status code if the platform supports it.
- `[launch-repl | Args]`:
    Request to launch the repl, can be done by invoking `(shen.repl)`.
    `Args` are extra arguments the port may want to do something with.
- `[show-help HelpText]`:
    Request to print the help text. HelpText contains the default
    help text, the port may add more.
- `[unknown-arguments Exe UnknownCommandOrFlag | Args]`:
    Returned when there are arguments that could not be processed.
    The port can handle those arguments if it knows how, otherwise
    it should let the user know aand exit with an error status code
    if the platform supports it.

The `shen.x.launcher.default-handle-result` implements a portable
default behaviour for these results. Ports can use this directly or
process the results they are interested in and pass the rest to
this function.

Example (default behaviour with correct exit codes):

    (define my-handle-result
      [error Message] -> (do (shen.x.launcher.default-handle-result
                                [error Message])
                             (scm.exit 1))
      [unknown-arguments | Rest]
      -> (do (shen.x.launcher.default-handle-result
                [unknown-arguments | Rest])
             (scm.exit 1))
      Other -> (shen.x.launcher.default-handle-result Other))

    (my-handle-result (shen.x.launcher.launch-shen
                          ["my-shen" "eval" "-e" "(+ 1 2)"]))

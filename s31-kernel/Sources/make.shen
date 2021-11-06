\\           Copyright (c) 2010-2019, Mark Tarver
\\                  All rights reserved.

(set *maximum-print-sequence-size* 10000)

(define make
  -> (map (fn bootstrap)
          ["yacc.shen" "core.shen" "declarations.shen" "load.shen" "macros.shen"
           "prolog.shen" "reader.shen" "sequent.shen" "sys.shen" "t-star.shen"
           "toplevel.shen" "track.shen" "types.shen" "writer.shen" "backend.shen"]))
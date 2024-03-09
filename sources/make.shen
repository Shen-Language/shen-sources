\\           Copyright (c) 2010-2019, Mark Tarver
\\                  All rights reserved.

(define make
  -> (let ResePrintSize (set *maximum-print-sequence-size* 10000)
          ResetGensym   (set shen.*gensym* 0)
          MainBoot      (map (fn bootstrap)
                             ["yacc.shen" "core.shen" "declarations.shen" "load.shen"
                              "prolog.shen" "reader.shen" "sequent.shen" "sys.shen" "t-star.shen"
                              "toplevel.shen" "track.shen" "types.shen" "writer.shen" "backend.shen"])
          Factor+       (factorise +)
          MacroBoot     (bootstrap "macros.shen")
          Factor-       (factorise -)
          ResePrintSize (set *maximum-print-sequence-size* 20)
          done))
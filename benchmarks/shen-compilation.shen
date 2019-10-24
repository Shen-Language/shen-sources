\\ Copyright (c) 2019 Bruno Deferrari.
\\ BSD 3-Clause License: http://opensource.org/licenses/BSD-3-Clause

(define shen-compilation-control-loop
  _ 0 -> ok
  C N -> (shen-compilation-control-loop C (- N 1)))


(define loop-shen.pvar?
  _ 0 -> ok
  V N -> (loop-shen.pvar? (do (shen.pvar? V) V) (- N 1)))

(define loop-variable?
  _ 0 -> ok
  V N -> (loop-variable? (do (variable? V) V) (- N 1)))

(define loop-symbol?
  _ 0 -> ok
  V N -> (loop-symbol? (do (symbol? V) V) (- N 1)))


(benchmark "compilation control loop"
  (shen-compilation-control-loop 0)
  8)

(benchmark "shen.pvar? (true)"
  (loop-shen.pvar? (@v 1 <>))
  8)
(benchmark "shen.pvar? (false)"
  (loop-shen.pvar? (@v 1 <>))
  8)

(benchmark "variable? (true)"
  (loop-variable? Variable)
  8)
(benchmark "variable? (false)"
  (loop-variable? [not a variable])
  8)

(benchmark "symbol? (true)"
  (loop-symbol? symbol)
  7)
(benchmark "symbol? (false)"
  (loop-symbol? [not a symbol])
  8)

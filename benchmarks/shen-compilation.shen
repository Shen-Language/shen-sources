\\ Copyright (c) 2019 Bruno Deferrari.
\\ BSD 3-Clause License: http://opensource.org/licenses/BSD-3-Clause

(define shen-compilation-control-loop
  _ 0 -> ok
  C N -> (shen-compilation-control-loop C (- N 1)))

(define loop-shen.pvar?
  _ R 0 -> R
  V _ N -> (loop-shen.pvar? V (shen.pvar? V) (- N 1)))

(define loop-variable?
  _ R 0 -> R
  V _ N -> (loop-variable? V (variable? V) (- N 1)))

(define loop-symbol?
  _ R 0 -> R
  V _ N -> (loop-symbol? V (symbol? V) (- N 1)))

(define loop-sysfunc?
  _ R 0 -> R
  V _ N -> (loop-sysfunc? V (shen.sysfunc? V) (- N 1)))

(add-benchmark shen-compilation
  "compilation control loop"
  (shen-compilation-control-loop 0)
  8)

(add-benchmark shen-compilation
  "shen.pvar? (true)"
  (loop-shen.pvar? (@v 1 <>) true)
  8)
(add-benchmark shen-compilation
  "shen.pvar? (false)"
  (loop-shen.pvar? (@v 1 <>) false)
  8)

(add-benchmark shen-compilation
  "variable? (true)"
  (loop-variable? Variable true)
  8)
(add-benchmark shen-compilation
  "variable? (false)"
  (loop-variable? [not a variable] false)
  8)

(add-benchmark shen-compilation
  "symbol? (true)"
  (loop-symbol? symbol true)
  7)
(add-benchmark shen-compilation
  "symbol? (false)"
  (loop-symbol? [not a symbol] false)
  8)

(add-benchmark shen-compilation
  "shen.sysfunc? (true)"
  (loop-sysfunc? cons true)
  5)
(add-benchmark shen-compilation
  "shen.sysfunc? (false)"
  (loop-sysfunc? not-a-sysfunc false)
  5)

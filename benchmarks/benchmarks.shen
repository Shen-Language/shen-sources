\\ Copyright (c) 2019 Bruno Deferrari.
\\ BSD 3-Clause License: http://opensource.org/licenses/BSD-3-Clause

(define power
  N 1 -> N
  N Power -> (* N (power N (- Power 1))))

(define benchmark
  Description F RunsPower
  -> (let _ (output "Running: ~S (10^~S runs)~%" Description RunsPower)
          Runs (power 10 RunsPower)
          Start (get-time run)
          Result (F Runs)
          End (get-time run)
          _ (output "run time: ~S secs~%" (- End Start))
       done))

(load "benchmarks/data.shen")
(load "benchmarks/control-flow.shen")
(load "benchmarks/shen-compilation.shen")

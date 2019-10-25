\\ Copyright (c) 2019 Bruno Deferrari.
\\ BSD 3-Clause License: http://opensource.org/licenses/BSD-3-Clause

(define power
  N 1 -> N
  N Power -> (* N (power N (- Power 1))))

(set *benchmarks* [])

(define add-benchmark
  Tag Description F RunsPower -> (do (set *benchmarks* [[Tag Description F RunsPower] | (value *benchmarks*)])
                                     done))

(define run-benchmark
  Report [Tag Description F RunsPower]
  -> (let _ (Report start [Tag Description RunsPower])
          Runs (power 10 RunsPower)
          Start (get-time run)
          Result (F Runs)
          End (get-time run)
          _ (Report end [Tag Description RunsPower Start End])
       done))

(define stoutput-report
  start [Tag Description RunsPower] -> (output "Measuring 10^~S runs of: ~A~%" RunsPower Description)
  end [Tag Description RunsPower Start End] -> (output "run time: ~S secs~%" (- End Start)))

(define run-all-benchmarks
  Report -> (let Benchmarks (reverse (value *benchmarks*))
                 Results (map (run-benchmark Report) Benchmarks)
              done))

(load "benchmarks/data.shen")
(load "benchmarks/control-flow.shen")
(load "benchmarks/shen-compilation.shen")
(load "benchmarks/pattern-matching.shen")
(load "benchmarks/equality-check.shen")

(if (bound? *argv*)
    (run-all-benchmarks (function stoutput-report))
    skip)
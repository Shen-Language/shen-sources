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
  -> (let _ (Report begin [Tag Description RunsPower])
          Runs (power 10 RunsPower)
          Start (get-time run)
          Result (F Runs)
          End (get-time run)
          _ (Report finish [Tag Description RunsPower Start End])
       done))

(define stoutput-report
  setup _ -> skip
  cleanup _ -> skip
  begin [_ Description RunsPower] -> (output "Measuring 10^~S runs of: ~A~%" RunsPower Description)
  finish [_ _ _ Start End] -> (output "run time: ~S secs~%" (- End Start)))

(define save-report
  setup _ -> (set *benchmark-results* [])
  cleanup _ -> skip
  begin _ -> skip
  finish Data -> (set *benchmark-results* [Data | (value *benchmark-results*)]))

(define run-all-benchmarks
  Report -> (let Benchmarks (reverse (value *benchmarks*))
                 Setup (Report setup Benchmarks)
                 Results (map (run-benchmark Report) Benchmarks)
                 Cleanup (Report cleanup Benchmarks)
              done))

(set *hush* true)
(load "benchmarks/data.shen")
(load "benchmarks/control-flow.shen")
(load "benchmarks/shen-compilation.shen")
(load "benchmarks/pattern-matching.shen")
(load "benchmarks/equality-check.shen")
(set *hush* false)

(if (bound? *argv*)
    (run-all-benchmarks (function stoutput-report))
    skip)
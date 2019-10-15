\\ Copyright (c) 2019 Bruno Deferrari.
\\ BSD 3-Clause License: http://opensource.org/licenses/BSD-3-Clause

(define benchmark
  Description F Runs -> (let _ (output "Running: ~S (~S runs)~%" Description Runs)
                             Start (get-time run)
                             Result (F Runs)
                             End (get-time run)
                             _ (output "run time: ~S secs~%" (- End Start))
                          done))

(load "benchmarks/data.shen")
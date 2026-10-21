\\ Validate benchmark registration and results without running timed suites.
\\ Use eval in a fresh process; script mode would run the benchmark harness.
(if (bound? *argv*)
    (simple-error "Load this check with eval, not script")
    ready)
(load "benchmarks/benchmarks.shen")

(define benchmark-coverage.expected
  "list traversal (32 items)" _ _ -> 528
  "list length (32 items)" _ _ -> 32
  "recursive list rebuild (32 items)" Xs _ -> Xs
  "append (32 + 32 items)" Xs _ -> (append Xs Xs)
  "reverse (32 items)" Xs _ -> (reverse Xs)
  "list membership (first item)" _ _ -> true
  "list membership (last item)" _ _ -> true
  "list membership (absent item)" _ _ -> false
  "nested list pattern (matching)" _ _ -> 6
  "nested list pattern (early mismatch)" _ _ -> no-match
  "nested list pattern (late mismatch)" _ _ -> no-match
  "distinct list equality (32 items, equal)" _ _ -> true
  "list equality (early mismatch)" _ _ -> false
  "list equality (late mismatch)" _ _ -> false
  "distinct nested tree equality" _ _ -> true
  "distinct vector equality (32 items, equal)" _ _ -> true
  "vector equality (last element mismatch)" _ _ -> false
  "numeric equality (integer/fractional)" _ _ -> false
  "addition (integers)" _ _ -> 3
  "addition (integer/fractional)" _ _ -> 3.5
  "multiply (integers)" _ _ -> 21
  "multiply (integer/fractional)" _ _ -> 7.5
  "returning call (zero managed survivors)" Xs _ -> [marker marker marker | Xs]
  "returning call (one managed survivor)" Xs _ -> [[a] marker marker | Xs]
  "returning call (three managed survivors)" _ Live -> Live
  "allocating recursive call (three managed survivors)" _ Live -> Live
  "captured returning call (three managed values)" _ Live -> Live
  "list allocation (three live generations)" Xs _ -> [Xs Xs Xs]
  "closure allocation (three live generations)" Xs _ -> [Xs Xs Xs]
  _ _ _ -> unlisted-benchmark)

(define benchmark-coverage.select
  [] -> []
  [[Tag Description F Power] | Rest] ->
    (if (= unlisted-benchmark (benchmark-coverage.expected Description [] []))
        (benchmark-coverage.select Rest)
        [[Tag Description F Power] | (benchmark-coverage.select Rest)]))

(define benchmark-coverage.all
  [] _ _ -> true
  [[Tag Description F Power] | Rest] Xs Live ->
    (let Expected (benchmark-coverage.expected Description Xs Live)
      (if (and (element? Tag [data control-flow pattern-matching equality-check arithmetic])
               (element? Power [5 6])
               (= Expected (F 1))
               (= Expected (F 3)))
          (benchmark-coverage.all Rest Xs Live)
          (error "Benchmark failed: ~A~%" Description))))

(define benchmark-coverage.unique?
  [] -> true
  [X | Xs] -> (and (not (element? X Xs)) (benchmark-coverage.unique? Xs)))

(define benchmark-coverage.run
  -> (let Xs [32 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17
              16 15 14 13 12 11 10 9 8 7 6 5 4 3 2 1]
          Cases (benchmark-coverage.select (value *benchmarks*))
       (if (and (= 29 (length Cases))
                (benchmark-coverage.unique? (map (/. Case (hd (tl Case))) Cases))
                (benchmark-coverage.all Cases Xs [[a] [b] [c] | Xs]))
           benchmark-coverage-ok
           (simple-error "Benchmark registration failed"))))

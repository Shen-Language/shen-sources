\\ Copyright (c) 2019 Bruno Deferrari.
\\ BSD 3-Clause License: http://opensource.org/licenses/BSD-3-Clause

(define control-flow-control-loop
  _ 0 -> ok
  C N -> (control-flow-control-loop C (- N 1)))

(define control-flow-helper
  false -> ok
  true -> (simple-error "error"))

(define control-flow-make-dict
  -> (let Dict (shen.dict 1000)
          _ (shen.dict-> Dict "exists" 1)
       Dict))

(define thaw-test
  _ R 0 -> R
  F _ N -> (thaw-test F (thaw F) (- N 1)))

(define lambda/one-arg
  _ R 0 -> R
  Lambda _ N -> (lambda/one-arg Lambda (Lambda 1) (- N 1)))

(define lambda/many-args
  _ R 0 -> R
  Lambda _ N -> (let Result (Lambda 1 2 3 4 5 6 7 8 9)
                  (lambda/many-args Lambda Result (- N 1))))

(define trap-error/basic
  _ R 0 -> R
  Raise _ N -> (let Result (trap-error (control-flow-helper Raise) (/. E N))
                 (trap-error/basic Raise Result (- N 1))))

(define trap-error/value
  _ R 0 -> R
  Sym _ N -> (let Result (trap-error (value Sym) (/. E default))
               (trap-error/value Sym Result (- N 1))))

(define trap-error/value-using-error
  _ R 0 -> R
  Sym _ N -> (let Result (trap-error (value Sym) (/. E E))
               (trap-error/value-using-error Sym Result (- N 1))))

(define trap-error/get
  _ _ R 0 -> R
  Sym Prop _ N -> (let Result (trap-error (get Sym Prop) (/. E default))
                    (trap-error/get Sym Prop Result (- N 1))))

(define trap-error/get-using-error
  _ _ R 0 -> R
  Sym Prop _ N -> (let Result (trap-error (get Sym Prop) (/. E E))
                    (trap-error/get-using-error Sym Prop Result (- N 1))))

(define trap-error/<-dict
  _ _ R 0 -> R
  Dict Key _ N -> (let Result (trap-error (shen.<-dict Dict Key) (/. E default))
                    (trap-error/<-dict Dict Key Result (- N 1))))

(define trap-error/<-dict-using-error
  _ _ R 0 -> R
  Dict Key _ N -> (let Result (trap-error (shen.<-dict Dict Key) (/. E E))
                    (trap-error/<-dict-using-error Dict Key Result (- N 1))))

(define trap-error/<-address
  _ _ R 0 -> R
  Vec Idx _ N -> (let Result (trap-error (<-address Vec Idx) (/. E default))
                   (trap-error/<-address Vec Idx Result (- N 1))))

(define trap-error/<-address-using-error
  _ _ R 0 -> R
  Vec Idx _ N -> (let Result (trap-error (<-address Vec Idx) (/. E E))
                   (trap-error/<-address-using-error Vec Idx Result (- N 1))))

(define trap-error/<-vector
  _ _ R 0 -> R
  Vec Idx _ N -> (let Result (trap-error (<-vector Vec Idx) (/. E default))
                   (trap-error/<-vector Vec Idx Result (- N 1))))

(define trap-error/<-vector-using-error
  _ _ R 0 -> R
  Vec Idx _ N -> (let Result (trap-error (<-vector Vec Idx) (/. E E))
                   (trap-error/<-vector-using-error Vec Idx Result (- N 1))))

(add-benchmark control-flow
  "control flow control loop"
  (control-flow-control-loop 0)
  6)

(add-benchmark control-flow
  "thaw"
  (thaw-test (freeze 1) unit)
  6)

(add-benchmark control-flow
  "lambda with one argument"
  (lambda/one-arg (/. X X) unit)
  6)

(add-benchmark control-flow
  "lambda with many arguments"
  (lambda/many-args (/. A B C D E F G H X X) unit)
  6)

(add-benchmark control-flow
  "trap-error basic (no error raised)"
  (trap-error/basic false unit)
  6)

(add-benchmark control-flow
  "trap-error basic (error raised)"
  (trap-error/basic true unit)
  6)

(set exists 1)

(add-benchmark control-flow
  "trap-error with value and handler to return default (no error raised)"
  (trap-error/value exists unit)
  6)

(add-benchmark control-flow
  "trap-error with value and handler to return default (error raised)"
  (trap-error/value doesnt-exist unit)
  6)

(add-benchmark control-flow
  "trap-error with value and handler that uses error (no error raised)"
  (trap-error/value-using-error exists unit)
  6)

(add-benchmark control-flow
  "trap-error with value and handler that uses error (error raised)"
  (trap-error/value-using-error doesnt-exist unit)
  6)

(put exists exists 1)

(add-benchmark control-flow
  "trap-error with get and handler to return default value (no error raised)"
  (trap-error/get exists exists unit)
  6)

(add-benchmark control-flow
  "trap-error with get and handler to return default value (error raised)"
  (trap-error/get exists doesnt-exist unit)
  6)

(add-benchmark control-flow
  "trap-error with get and handler that uses error (no error raised)"
  (trap-error/get-using-error exists exists unit)
  6)

(add-benchmark control-flow
  "trap-error with get and handler that uses error (error raised)"
  (trap-error/get-using-error exists doesnt-exist unit)
  6)

(add-benchmark control-flow
  "trap-error with shen.<-dict and handler to return default value (no error raised)"
  (trap-error/<-dict (control-flow-make-dict) "exists" unit)
  6)

(add-benchmark control-flow
  "trap-error with shen.<-dict and handler to return default value (error raised)"
  (trap-error/<-dict (control-flow-make-dict) "doesnt-exists" unit)
  6)

(add-benchmark control-flow
  "trap-error with shen.<-dict and handler that uses error (no error raised)"
  (trap-error/<-dict-using-error (control-flow-make-dict) "exists" unit)
  6)

(add-benchmark control-flow
  "trap-error with shen.<-dict and handler that uses error (error raised)"
  (trap-error/<-dict-using-error (control-flow-make-dict) "doesnt-exists" unit)
  6)

(add-benchmark control-flow
  "trap-error with <-address and handler to return default value (no error raised)"
  (trap-error/<-address (@v 1 2 3 4 <>) 3 unit)
  6)

(add-benchmark control-flow
  "trap-error with <-address and handler to return default value (error raised)"
  (trap-error/<-address (@v 1 2 3 4 <>) 10 unit)
  6)

(add-benchmark control-flow
  "trap-error with <-address and handler that uses error (no error raised)"
  (trap-error/<-address-using-error (@v 1 2 3 4 <>) 3 unit)
  6)

(add-benchmark control-flow
  "trap-error with <-address and handler that uses error (error raised)"
  (trap-error/<-address-using-error (@v 1 2 3 4 <>) 10 unit)
  6)

(add-benchmark control-flow
  "trap-error with <-vector and handler to return default value (no error raised)"
  (trap-error/<-vector (@v 1 2 3 4 <>) 3 unit)
  6)

(add-benchmark control-flow
  "trap-error with <-vector and handler to return default value (error raised)"
  (trap-error/<-vector (@v 1 2 3 4 <>) 10 unit)
  6)

(add-benchmark control-flow
  "trap-error with <-vector and handler that uses error (no error raised)"
  (trap-error/<-vector-using-error (@v 1 2 3 4 <>) 3 unit)
  6)

(add-benchmark control-flow
  "trap-error with <-vector and handler that uses error (error raised)"
  (trap-error/<-vector-using-error (@v 1 2 3 4 <>) 10 unit)
  6)

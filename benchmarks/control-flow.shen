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

(define trap-error/basic
  _ 0 -> ok
  Raise N -> (let Result (trap-error (control-flow-helper Raise) (/. E N))
               (trap-error/basic Raise (- N 1))))

(define trap-error/value
  _ 0 -> ok
  Sym N -> (let Result (trap-error (value Sym) (/. E default))
             (trap-error/value Sym (- N 1))))

(define trap-error/value-using-error
  _ 0 -> ok
  Sym N -> (let Result (trap-error (value Sym) (/. E E))
             (trap-error/value Sym (- N 1))))

(define trap-error/get
  _ _ 0 -> ok
  Sym Prop N -> (let Result (trap-error (get Sym Prop) (/. E default))
                  (trap-error/get Sym Prop (- N 1))))

(define trap-error/get-using-error
  _ _ 0 -> ok
  Sym Prop N -> (let Result (trap-error (get Sym Prop) (/. E E))
                  (trap-error/get Sym Prop (- N 1))))

(define trap-error/<-dict
  _ _ 0 -> ok
  Dict Key N -> (let Result (trap-error (shen.<-dict Dict Key) (/. E default))
                  (trap-error/<-dict Dict Key (- N 1))))

(define trap-error/<-dict-using-error
  _ _ 0 -> ok
  Dict Key N -> (let Result (trap-error (shen.<-dict Dict Key) (/. E E))
                  (trap-error/<-dict Dict Key (- N 1))))

(define trap-error/<-address
  _ _ 0 -> ok
  Vec Idx N -> (let Result (trap-error (<-address Vec Idx) (/. E default))
                 (trap-error/<-address Vec Idx (- N 1))))

(define trap-error/<-address-using-error
  _ _ 0 -> ok
  Vec Idx N -> (let Result (trap-error (<-address Vec Idx) (/. E E))
                 (trap-error/<-address Vec Idx (- N 1))))

(define trap-error/<-vector
  _ _ 0 -> ok
  Vec Idx N -> (let Result (trap-error (<-vector Vec Idx) (/. E default))
                 (trap-error/<-vector Vec Idx (- N 1))))

(define trap-error/<-vector-using-error
  _ _ 0 -> ok
  Vec Idx N -> (let Result (trap-error (<-vector Vec Idx) (/. E E))
                 (trap-error/<-vector Vec Idx (- N 1))))

(benchmark "control flow control loop"
  (control-flow-control-loop 0)
  1000000)

(benchmark "trap-error basic (no error raised)"
  (trap-error/basic false)
  1000000)

(benchmark "trap-error basic (error raised)"
  (trap-error/basic true)
  1000000)

(set exists 1)

(benchmark "trap-error with value and handler to return default (no error raised)"
  (trap-error/value exists)
  1000000)

(benchmark "trap-error with value and handler to return default (error raised)"
  (trap-error/value doesnt-exist)
  1000000)

(benchmark "trap-error with value and handler that uses error (no error raised)"
  (trap-error/value-using-error exists)
  1000000)

(benchmark "trap-error with value and handler that uses error (error raised)"
  (trap-error/value-using-error doesnt-exist)
  1000000)

(put exists exists 1)

(benchmark "trap-error with get and handler to return default value (no error raised)"
  (trap-error/get exists exists)
  1000000)

(benchmark "trap-error with get and handler to return default value (error raised)"
  (trap-error/get exists doesnt-exist)
  1000000)

(benchmark "trap-error with get and handler that uses error (no error raised)"
  (trap-error/get-using-error exists exists)
  1000000)

(benchmark "trap-error with get and handler that uses error (error raised)"
  (trap-error/get-using-error exists doesnt-exist)
  1000000)

(benchmark "trap-error with shen.<-dict and handler to return default value (no error raised)"
  (trap-error/<-dict (control-flow-make-dict) "exists")
  1000000)

(benchmark "trap-error with shen.<-dict and handler to return default value (error raised)"
  (trap-error/<-dict (control-flow-make-dict) "doesnt-exists")
  1000000)

(benchmark "trap-error with shen.<-dict and handler that uses error (no error raised)"
  (trap-error/<-dict-using-error (control-flow-make-dict) "exists")
  1000000)

(benchmark "trap-error with shen.<-dict and handler that uses error (error raised)"
  (trap-error/<-dict-using-error (control-flow-make-dict) "doesnt-exists")
  1000000)

(benchmark "trap-error with <-address and handler to return default value (no error raised)"
  (trap-error/<-address (@v 1 2 3 4 <>) 3)
  1000000)

(benchmark "trap-error with <-address and handler to return default value (error raised)"
  (trap-error/<-address (@v 1 2 3 4 <>) 10)
  1000000)

(benchmark "trap-error with <-address and handler that uses error (no error raised)"
  (trap-error/<-address-using-error (@v 1 2 3 4 <>) 3)
  1000000)

(benchmark "trap-error with <-address and handler that uses error (error raised)"
  (trap-error/<-address-using-error (@v 1 2 3 4 <>) 10)
  1000000)

(benchmark "trap-error with <-vector and handler to return default value (no error raised)"
  (trap-error/<-vector (@v 1 2 3 4 <>) 3)
  1000000)

(benchmark "trap-error with <-vector and handler to return default value (error raised)"
  (trap-error/<-vector (@v 1 2 3 4 <>) 10)
  1000000)

(benchmark "trap-error with <-vector and handler that uses error (no error raised)"
  (trap-error/<-vector-using-error (@v 1 2 3 4 <>) 3)
  1000000)

(benchmark "trap-error with <-vector and handler that uses error (error raised)"
  (trap-error/<-vector-using-error (@v 1 2 3 4 <>) 10)
  1000000)

\\ TODO
\\ thaw
\\ freeze
\\ dynamic call: (F 1)

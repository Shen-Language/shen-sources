(define newtons-method
  N -> (fix (/. M (specialised-run-newtons-method N M)) (/ N 2.0)))

(define specialised-run-newtons-method
  M N -> (round-to-2-places (average N (/ M N))))

(define round-to-2-places
  M -> (/ (round (* 100.0 M)) 100.0))

(define average
  M N -> (/ (+ M N) 2.0))

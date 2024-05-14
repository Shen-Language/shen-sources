\\ Copyright (c) 2021 Bruno Deferrari.
\\ BSD 3-Clause License: http://opensource.org/licenses/BSD-3-Clause

(package shen []

(define dict
  Size -> (error "invalid initial dict size: ~S" Size) where (< Size 1)
  Size -> (let D (absvector (+ 3 Size))
               Tag (address-> D 0 dictionary)
               Capacity (address-> D 1 Size)
               Count (address-> D 2 0)
               Fill (fillvector D 3 (+ 2 Size) [])
             D))

(define dict?
  X -> (and (absvector? X)
            (= (trap-error (<-address X 0) (/. E not-dictionary))
               dictionary)))

(define dict-capacity
  Dict -> (<-address Dict 1))

(define dict-count
  Dict -> (<-address Dict 2))

(define dict-count->
  Dict Count -> (address-> Dict 2 Count))

(define <-dict-bucket
  Dict N -> (<-address Dict (+ 3 N)))

(define dict-bucket->
  Dict N Bucket -> (address-> Dict (+ 3 N) Bucket))

(define dict-update-count
  Dict OldBucket NewBucket -> (let Diff (- (length NewBucket)
                                           (length OldBucket))
                                (dict-count->
                                 Dict (+ Diff (dict-count Dict)))))

(define dict->
  Dict Key Value -> (let N (hash Key (dict-capacity Dict))
                         Bucket (<-dict-bucket Dict N)
                         NewBucket (assoc-set Key Value Bucket)
                         Change (dict-bucket-> Dict N NewBucket)
                         Count (dict-update-count Dict Bucket NewBucket)
                      Value))

(define <-dict
  Dict Key -> (let N (hash Key (dict-capacity Dict))
                   Bucket (<-dict-bucket Dict N)
                   Result (assoc Key Bucket)
                (if (empty? Result)
                    (error "value ~A not found in dict~%" Key)
                    (tl Result))))

(define dict-rm
  Dict Key -> (let N (hash Key (dict-capacity Dict))
                   Bucket (<-dict-bucket Dict N)
                   NewBucket (assoc-rm Key Bucket)
                   Change (dict-bucket-> Dict N NewBucket)
                   Count (dict-update-count Dict Bucket NewBucket)
                 Key))

(define dict-fold
  F Dict Acc -> (let Limit (dict-capacity Dict)
                  (dict-fold-h F Dict Acc 0 Limit)))

(define dict-fold-h
  F Dict Acc End End -> Acc
  F Dict Acc Counter End -> (let B (<-dict-bucket Dict Counter)
                                 Acc (bucket-fold F B Acc)
                              (dict-fold-h F Dict Acc (+ 1 Counter) End)))

(define bucket-fold
  F [] Acc -> Acc
  F [[K | V] | Rest] Acc -> (F K V (bucket-fold F Rest Acc)))

(define dict-keys
  Dict -> (dict-fold (/. K _ Acc [K | Acc]) Dict []))

(define dict-values
  Dict -> (dict-fold (/. _ V Acc [V | Acc]) Dict []))

)
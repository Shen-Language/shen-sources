\*

Copyright (c) 2010-2015, Mark Tarver

All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
1. Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.
3. The name of Mark Tarver may not be used to endorse or promote products
   derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY Mark Tarver ''AS IS'' AND ANY
EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL Mark Tarver BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

*\

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
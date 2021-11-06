\\           Copyright (c) 2010-2019, Mark Tarver

\\                  All rights reserved.

(package shen []

(define shen.shen
 -> (do (credits)
         (loop)))

(define loop
   -> (do (initialise_environment)
          (prompt)
          (trap-error (read-evaluate-print)
                      (/. E (do (pr (error-to-string E) (stoutput)) (nl 0))))
          (loop)))

(define credits
 -> (do (output "~%Shen, www.shenlanguage.org, copyright (C) 2010-2021, Mark Tarver~%")
        (output "version: S~A, language: ~A, platform: ~A ~A~%"
           (value *version*) (value *language*) (value *implementation*) (value *release*))
        (output "port ~A, ported by ~A~%~%" (value *port*) (value *porters*))))

(define initialise_environment
  -> (do (set *call* 0) (set *infs* 0)))

(define prompt
  -> (if (value *tc*)
         (output  "~%(~A+) " (length (value *history*)))
         (output  "~%(~A-) " (length (value *history*)))))

(define read-evaluate-print
  -> (let Package (value *package*)
          Lineread (package-user-input Package (lineread))
          History (update-history)
          (evaluate-lineread Lineread History (value *tc*))))

(define package-user-input
  null Lineread -> Lineread
  Package Lineread -> (let Str (str Package)
                           External (external Package)
                           (map (/. X (pui-h Str External X)) Lineread)))

(define pui-h
  Package External [fn F] -> (if (internal? F Package External)
                                 [fn (intern-in-package Package F)]
                                 [fn F])
  Package External [F | X] -> (cases (internal? F Package External)  [(intern-in-package Package F) | (map (/. Y (pui-h Package External Y)) X)]
                                     (cons? F) (map (/. Y (pui-h Package External Y)) [F | X])
                                     true [F | (map (/. Y (pui-h Package External Y)) X)])
  _ _ X -> X)

(define update-history
  -> (set *history* [(it) | (value *history*)]))

(define evaluate-lineread
  [X] ["!!" S | History] TC -> (let Y (read-from-string S)
                                    NewHistory (set *history* [S S | History])
                                    Print (output "~A~%" S)
                                    (evaluate-lineread Y NewHistory TC))
  [X] [(@s "%" S) | History] TC -> (let Read (hd (read-from-string S))
                                        Peek (peek-history Read S History)
                                        NewHistory (set *history* History)
                                        (abort))
  [X] [(@s "!" S) | History] TC -> (let Read (hd (read-from-string S))
                                        Match (use-history Read S History)
                                        Print (output "~A~%" Match)
                                        Y (read-from-string Match)
                                        NewHistory (set *history* [Match | History])
                                        (evaluate-lineread Y NewHistory TC))
  [X] [(@s "%" S) | History] TC -> (let Read (hd (read-from-string S))
                                        Peek (peek-history Read S History)
                                        NewHistory (set *history* History)
                                        (abort))
  X _ true -> (check-eval-and-print X)
  X _ false -> (eval-and-print X)
  _ _ _ -> (simple-error "implementation error in shen.evaluate-lineread"))

(define use-history
  Read S History -> (cases (integer? Read) (nth (+ 1 Read) (reverse History))
                           (symbol? Read)  (string-match S History)
                           true (error "! expects a number or a symbol~%")))

(define peek-history
  Read S History -> (cases (integer? Read) (output "~%~A" (nth (+ 1 Read) (reverse History)))
                           (or (= S "") (symbol? Read))  (recursive-string-match 0 S (reverse History))
                           true (error "% expects a number or a symbol~%")))

(define string-match
  _ [] -> (error "~%input not found")
  S [S* | _] -> S*  where (string-prefix? S S*)
  S [_ | History] -> (string-match S History)
  _ _ -> (simple-error "implementation error in shen.string-match"))

(define string-prefix?
  "" _ -> true
  (@s W Ss) S* -> (string-prefix? Ss S*)     where (whitespace? (string->n W))
  Ss (@s W S*) -> (string-prefix? Ss S*)     where (whitespace? (string->n W))
  S (@s "(" S*) -> (string-prefix? S S*)
  (@s S Ss) (@s S Ss*) -> (string-prefix? Ss Ss*)
  _ _ -> false)

(define recursive-string-match
  _ _ [] -> skip
  N S [S* | History] -> (do (if (string-prefix? S S*) (output "~A. ~A~%" N S*) skip)
                            (recursive-string-match (+ N 1) S History))
  _ _ _ -> (simple-error "implementation error in shen.recursive-string-match"))   )
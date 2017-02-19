\*     					Standard Test Suite 1.0

This is the test harness for Shen.  Assuming your port to Blub is in the directory Platforms/Blub; do the
following.

(cd "../../Test Programs")
(load "README.shen")
(load "tests.shen")

*\

(package test-harness [report reset ok passed failed]

(define reset
  -> (set *passed* (set *failed* 0)))

(defmacro exec-macro
  [exec Name Expr Prediction]
  -> [trap-error [let (protect Output) [output "~%~A: ~R = ~S" Name (rcons Expr) Prediction]
                   (protect Result) [time Expr]
                   [if [= (protect Result) Prediction]
                       [passed]
                       [failed (protect Result)]]]
                 [/. (protect E) [err (protect E)]]])

(define rcons
  [X | Y] -> [cons (rcons X) (rcons Y)]
  X -> X)

(define passed
  -> (do (trap-error
          (set *passed* (+ 1 (value *passed*)))
          (/. E (set *passed* 1)))
         (print passed)))

(define failed
  Result -> (let Fail+ (trap-error
                        (set *failed* (+ 1 (value *failed*)))
                        (/. E (set *failed* 1)))
                 ShowResult (output "~S returned~%" Result)
              (if (y-or-n? "failed; continue?") ok (error "kill"))))

(define err
  E -> (error "")  where (= (error-to-string E) "kill")
  E -> (do (trap-error
            (set *failed* (+ 1 (value *failed*)))
            (/. E (set *failed* 1)))
           (output "~%failed with error ~A~%" (error-to-string E))))

(defmacro report-results-macro
  [report Name | Tests] -> (let NewTests (create-tests Name Tests)
                             [do | NewTests]))

(define create-tests
  Name [] -> [[results] ok]
  Name [Test Prediction | Tests] -> [[exec Name Test Prediction] | (create-tests Name Tests)])

(define results
  -> (let Passed (trap-error (value *passed*) (/. E 0))
          Failed (trap-error (value *failed*) (/. E 0))
          Percent (* (/ Passed (+ Passed Failed)) 100)
       (output "~%passed ... ~A~%failed ...~A~%pass rate ...~A%~%~%"
               Passed Failed Percent))))

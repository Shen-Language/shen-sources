\* Non-interactive harness for optional extension tests. *\

(define extension-tests.reset
  -> (do (set extension-tests.*passed* 0)
         (set extension-tests.*failed* 0)
         ok))

(define extension-tests.pass
  Label
  -> (do (set extension-tests.*passed*
               (+ 1 (value extension-tests.*passed*)))
         (output "ok - ~A~%" Label)
         ok))

(define extension-tests.fail
  Label Detail
  -> (do (set extension-tests.*failed*
               (+ 1 (value extension-tests.*failed*)))
         (output "not ok - ~A~%" Label)
         (output "  ~A~%" Detail)
         ok))

(define extension-tests.assert-equal
  Label Actual Expected
  -> (extension-tests.pass Label) where (= Actual Expected)
  Label Actual Expected
  -> (extension-tests.fail
       Label
       (make-string "expected ~R, got ~R" Expected Actual)))

(define extension-tests.assert-error
  Label Thunk
  -> (extension-tests.pass Label)
     where (trap-error (do (thaw Thunk) false)
                       (/. E true))
  Label _
  -> (extension-tests.fail Label "expected an error"))

(define extension-tests.finish
  -> (let Passed (value extension-tests.*passed*)
          Failed (value extension-tests.*failed*)
       (do (output "~%passed ... ~A~%" Passed)
           (output "failed ... ~A~%~%" Failed)
           (if (= Failed 0)
               ok
               (simple-error
                 (make-string "extension test failures: ~A" Failed))))))

\\ Explicit cond need not end with a true clause, even when factorised.
(define factoriser-cond.assert
  Label Expected Expected -> (output "[OK]    ~A~%" Label)
  Label Expected Actual -> (error "~A: expected ~R, got ~R" Label Expected Actual))

(define factoriser-cond.check
 -> (let X (intern "X") (do
  (factoriser-cond.assert "empty clause list becomes a runtime error"
    [simple-error "condition failure"]
    (shen.factor-recognisors []))
  (eval [define factoriser-cond.probe X ->
          [cond [[= X 1] a] [[= X 2] b]]])
  (factoriser-cond.assert "first clause" a (factoriser-cond.probe 1))
  (factoriser-cond.assert "later clause" b (factoriser-cond.probe 2))
  (factoriser-cond.assert "unmatched input raises at runtime"
    "condition failure"
    (trap-error (factoriser-cond.probe 3) (/. E (error-to-string E))))
  (eval [define factoriser-cond.guarded X ->
          [cond [[and [number? X] [= X 1]] a]
                [[and [number? X] [= X 2]] b]]])
  (factoriser-cond.assert "shared recognisor first branch" a
    (factoriser-cond.guarded 1))
  (factoriser-cond.assert "shared recognisor later branch" b
    (factoriser-cond.guarded 2))
  (factoriser-cond.assert "shared recognisor exhausted tail"
    "condition failure"
    (trap-error (factoriser-cond.guarded 3) (/. E (error-to-string E))))
  (factoriser-cond.assert "shared recognisor false"
    "condition failure"
    (trap-error (factoriser-cond.guarded other) (/. E (error-to-string E))))
  (eval [define factoriser-cond.default X ->
          [cond [[= X 1] a] [true b]]])
  (factoriser-cond.assert "explicit default still works" b
    (factoriser-cond.default 2)))))

(let Saved (factorise?)
  (do (factorise +)
      (trap-error
        (let Result (factoriser-cond.check)
          (do (set shen.*factorise?* Saved) Result))
        (/. E (do (set shen.*factorise?* Saved)
                  (simple-error (error-to-string E)))))))

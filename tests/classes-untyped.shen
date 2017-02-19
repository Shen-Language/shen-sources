(define defclass
  Class Attributes
  -> (let Assoc (map (/. Attribute [Attribute | fail]) Attributes)
          ClassDef [[class | Class] | Assoc]
          Store (put Class classdef ClassDef)
        Class))

(define make-instance
  Class -> (let ClassDef (trap-error (get Class classdef) (/. E []))
             (if (empty? ClassDef)
                 (error "class ~A does not exist~%" Class)
                 ClassDef)))

(define get-value
  Attribute Instance -> (let LookUp (assoc Attribute Instance)
                          (get-value-test LookUp)))

(define get-value-test
  [ ] -> (error "no such attribute!~%")
  [_ | fail] -> (error "no such value!~%")
  [_ | Value] -> Value)

(define has-value?
  Attribute Instance -> (let LookUp (assoc Attribute Instance)
                          (has-value-test LookUp)))

(define has-value-test
  [ ] -> (error "no such attribute!~%")
  [_ | fail] -> false
  _ -> true)

(define has-attribute?
  Attribute Instance -> (let LookUp (assoc Attribute Instance)
                          (not (empty? LookUp))))

(define change-value
  _ class _ -> (error "cannot change the class of an instance!~%")
  [ ] _ _ -> (error "no such attribute!~%")
  [[Attribute | _] | Instance] Attribute Value
  -> [[Attribute | Value] | Instance]
  [Slot | Instance] Attribute Value
  -> [Slot | (change-value Instance Attribute Value)])

(define instance-of
  [[class | Class] | _] -> Class
  _ -> (error "not a class instance!"))

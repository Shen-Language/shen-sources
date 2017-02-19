(datatype class

  Slots : [slot];
  _______________________________________
  (defclass Class Slots) : (class Class);

  Attribute : symbol; Type : symbol;
  ===================================
  (@p Attribute Type) : slot;

  Default : Type; Attribute : symbol; Type : symbol;
  ==================================================
  (@p Attribute Type Default) : slot;)

(define defclass
  Class ClassDef -> (let Attributes (map fst ClassDef)
                         Types (record-attribute-types Class ClassDef)
                         Assoc (map assign-values ClassDef)
                         NewClassDef [[class | Class] | Assoc]
                         Store (put-prop Class classdef NewClassDef)
                         RecordClass (axiom Class Class [class Class])
                       Class))

(define assign-values
  (@p Attribute _ Value) -> [Attribute | Value]
  (@p Attribute _) -> [Attribute | fail!])

(define axiom
  DataType X A -> (eval [datatype DataType
                          ________
                          X : A;]))

(define record-attribute-types
  _ [] -> []
  Class [(@p Attribute Type _) | ClassDef]
  -> (let DataTypeName (concat Class Attribute)
          DataType (axiom DataTypeName Attribute [attribute Class Type])
       (record-attribute-types Class ClassDef))
  Class [(@p Attribute Type) | ClassDef]
  -> (let DataTypeName (concat Class Attribute)
          DataType (axiom DataTypeName Attribute [attribute Class Type])
       (record-attribute-types Class ClassDef)))

(declare make-instance [[class Class] --> [instance Class]])

(define make-instance
  Class -> (let ClassDef (get-prop Class classdef [])
             (if (empty? ClassDef)
                 (error "class ~A does not exist~%" Class)
                 ClassDef)))

(declare get-value [[attribute Class A] --> [instance Class] --> A])

(define get-value
  Attribute Instance -> (let LookUp (assoc Attribute Instance)
                          (get-value-test LookUp)))

(define get-value-test
  [ ] -> (error "no such attribute!~%")
  [_ | fail!] -> (error "no such value!~%")
  [_ | Value] -> Value)

(declare has-value? [[attribute Class A] --> [instance Class] --> boolean])

(define has-value?
  Attribute Instance -> (let LookUp (assoc Attribute Instance)
                          (has-value-test LookUp)))

(define has-value-test
  [ ] -> (error "no such attribute!~%")
  [_ | fail!] -> false
  _ -> true)

(declare has-attribute? [symbol --> [instance Class] --> boolean])

(define has-attribute?
  Attribute Instance -> (let LookUp (assoc Attribute Instance)
                          (not (empty? LookUp))))

(declare change-value [[instance Class] --> [attribute Class A] --> A --> [instance Class]])

(define change-value
  _ class _ -> (error "cannot change the class of an instance!~%")
  [ ] _ _ -> (error "no such attribute!~%")
  [[Attribute | _] | Instance] Attribute Value
  -> [[Attribute | Value] | Instance]
  [Slot | Instance] Attribute Value
  -> [Slot | (change-value Instance Attribute Value)])

(declare instance-of [[instance Class] --> [class Class]])

(define instance-of
  [[class | Class] | _] -> Class
  _ -> (error "not a class instance!"))

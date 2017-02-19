(define defstruct
  Name Slots
  -> (let Attributes (map (function fst) Slots)
          Types (map (function snd) Slots)
          Selectors (selectors Name Attributes)
          Constructor (constructor Name Attributes)
          Recognisor (recognisor Name)
          ConstructorType (constructor-type Name Types)
          SelectorTypes (selector-types Name Attributes Types)
          RecognisorType (recognisor-type Name)
          Name))

(define selector-types
  _ [] [] -> (gensym (protect X))
  Name [Attribute | Attributes] [Type | Types]
  -> (let Selector (concat Name (concat - Attribute))
          SelectorType [Name --> Type]
          TypeDecl (declare Selector SelectorType)
       (selector-types Name Attributes Types)))

(define recognisor-type
  Name -> (let Recognisor (concat Name ?)
            (declare Recognisor [Name --> boolean])))

(define constructor-type
  Name Types -> (let Constructor (concat make- Name)
                     Type (assemble-type Types Name)
                  (declare Constructor Type)))

(define assemble-type
  [ ] Name -> Name
  [Type | Types] Name -> [Type --> (assemble-type Types Name)])

(declare defstruct [symbol --> [list [symbol * symbol]] --> symbol])

(define selectors
  Name Attributes -> (map (/. A (selector Name A)) Attributes))

(define selector
  Name Attribute
  -> (let SelectorName (concat Name (concat - Attribute))
       (eval [define SelectorName
               (protect Structure) -> [let (protect LookUp) [assoc Attribute (protect Structure)]
                                        [if [empty? (protect LookUp)]
                                            [error "~A is not an attribute of ~A.~%"
                                                   Attribute Name]
                                            [tail (protect LookUp)]]]])))

(define constructor
  Name Attributes
  -> (let ConstructorName (concat make- Name)
          Parameters (params Attributes)
       (eval [define ConstructorName |
               (append Parameters
                       [-> [cons [cons structure Name]
                                 (make-association-list Attributes
                                                        Parameters)]])])))

(define params
  [] -> []
  [_ | Attributes] -> [(gensym (protect X)) | (params Attributes)])

(define make-association-list
  [] [] -> []
  [A | As] [P | Ps] -> [cons [cons A P] (make-association-list As Ps)])

(define recognisor
  Name -> (let RecognisorName (concat Name ?)
            (eval [define RecognisorName
                    [cons [cons structure Name] _] -> true
                    _ -> false])))

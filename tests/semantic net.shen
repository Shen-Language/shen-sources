(define query
  [is Object Concept] -> (if (belongs? Object Concept) yes no))

(define belongs?
  Object Concept -> (element? Concept (fix (fn spread-activation) [Object])))

(define spread-activation
  [] -> []
  [Vertex | Vertices] -> (union (accessible-from Vertex)
                                (spread-activation Vertices)))

(define accessible-from
  Vertex -> [Vertex | (union (is_links Vertex) (type_links Vertex))])

(define is_links
  Vertex -> (get-prop Vertex is_a []))

(define type_links
  Vertex -> (get-prop Vertex type_of []))

(define assert
  [Object is_a Type] -> (put Object is_a [Type | (is_links Object)])
  [Type1 type_of Type2] -> (put Type1 type_of [Type2 | (type_links Type1)]))

(define get-prop
  Ob Pointer Default -> (trap-error (get Ob Pointer) (/. E Default)))

(define clear
  Ob -> (put Ob is_a (put Ob type_of [])))

(define parse
  Sentence -> (let Parse (sent [Sentence []])
                (if (parsed? Parse)
                    (output_parse Parse)
                    ungrammatical)))

(define parsed?
  [[] _] -> true
  _ -> false)

(define output_parse
  [_ Parse_Rules] -> (reverse Parse_Rules))

(define sent
  [Input Output] <- (vp (np [Input [[sent --> np vp] | Output]]))
  _ -> (fail))

(define np
  [Input Output] <- (n (det [Input [[np --> det n] | Output]]))
  [Input Output] <- (name [Input [[np --> name] | Output]])
  _ -> (fail))

(define name
  [["John" | Input] Output] -> [Input [[name --> "John"] | Output]]
  [["Bill" | Input] Output] -> [Input [[name --> "Bill"] | Output]]
  _ -> (fail))

(define det
  [["the" | Input] Output] -> [Input [[det --> "the"] | Output]]
  [["a" | Input] Output] -> [Input [[det --> "a"] | Output]]
  [["that" | Input] Output] -> [Input [[det --> "that"] | Output]]
  [["this" | Input] Output] -> [Input [[det --> "this"] | Output]]
  _ -> (fail))

(define n
  [["boy" | Input] Output] -> [Input [[n --> "boy"] | Output]]
  [["girl" | Input] Output] -> [Input [[n --> "girl"] | Output]]
  _ -> (fail))

(define vp
  [Input Output] <- (np (vtrans [Input [[vp --> vtrans np] | Output]]))
  [Input Output] <- (vp [Input [[vp --> vintrans] | Output]])
  _ -> (fail))

(define vtrans
  [["kicks" | Input] Output] -> [Input [[vtrans --> "kicks"] | Output]]
  [["likes" | Input] Output] -> [Input [[vtrans --> "likes"] | Output]]
  _ -> (fail))

(define vintrans
  [["jumps" | Input] Output] -> [Input [[vintrans --> "jumps"] | Output]]
  _ -> (fail))

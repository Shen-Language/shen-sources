(define axiomsEng
  {--> (list prop)}
  -> [[all x [[sat x "bald"] <=> [bald x]]]
      [all x [all y [all z [[[name x] & [[copEng y] & [adjEng z]]]
                <=> [[istrueEng [cn x [cn y z]]] <=> [sat [den x] z]]]]]]
      [all p [all q [[istrueEng [cn p [cn "and" q]]] <=> [[istrueEng p] & [istrueEng q]]]]]
      [[den "Tom"] = tom]
      [[den "Jerry"] = jerry]
      [name "Tom"]
      [name "Jerry"]
      [all x [[call [adjEng? x (protect Hyp)]] => [adjEng x]]] \\ procedural attachment
      [copEng "is"]])
      
(defprolog adjEng?
  X <-- (when (element? X (value *EngAdj*)));)      

(define axiomsFr
  {--> (list prop)}
  -> [[all x [[sat x "chauve"] <=> [bald x]]]
      [all x [all y [all z [[[name x] & [[copFr y] & [adjFr z]]]
                <=> [[istrueFr [cn x [cn y z]]] <=> [sat [den x] z]]]]]]
      [all p [all q [[istrueFr [cn p [cn "et" q]]] <=> [[istrueFr p] & [istrueFr q]]]]]   
      [adjFr "chauve"]
      [copFr "est"]])
      
(set *EngAdj* ["bald"])      
      
(kb-> (append (axiomsEng) (axiomsFr)))      

(thorn.complex 21)
(thorn.depth 20)

(<-kb [[istrueEng [cn "Tom" [cn "is" "bald"]]] <=> [bald tom]])
(<-kb [[istrueFr [cn "Tom" [cn "est" "chauve"]]] <=> [bald tom]])
(<-kb [[istrueEng [cn [cn "Tom" [cn "is" "bald"]] 
            [cn "and" [cn "Jerry" [cn "is" "bald"]]]]]
     <=> [istrueFr [cn [cn "Tom" [cn "est" "chauve"]] 
              [cn "et" [cn "Jerry" [cn "est" "chauve"]]]]]]) 

          
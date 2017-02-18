(define parse
  D Sentence -> (let Parse (D [Sentence []])
                  (if (parsed? Parse)
                      (output_parse Parse)
                      ungrammatical)))

(define parsed?
  [[] Output] -> true
  _ -> false)

(define output_parse
  [_ Output] -> Output)

(define generate_parser
  Grammar -> (map (/. X (compile_rules X))
                  (group_rules (parenthesise_rules Grammar))))

(define parenthesise_rules
  [S --> | Rest] -> (parenthesise_rules1 [S -->] Rest))

(define parenthesise_rules1
  Rule [] -> [Rule]
  Rule [S --> | Rest] -> [Rule | (parenthesise_rules1 [S -->] Rest)]
  Rule [X | Y] -> (parenthesise_rules1 (append Rule [X]) Y))

(define group_rules
  Rules -> (group_rules1 Rules []))

(define group_rules1
  [] Groups -> Groups
  [Rule | Rules] Groups -> (group_rules1 Rules (place_in_group Rule Groups)))

(define place_in_group
  Rule [] -> [[Rule]]
  Rule [Group | Groups] -> [[Rule | Group] | Groups]
      where (belongs-in? Rule Group)
  Rule [Group | Groups] -> [Group | (place_in_group Rule Groups)])

(define belongs-in?
  [S | _] [[S | _] | _] -> true
  _ _ -> false)

(define compile_rules
  Rules -> (if (lex? Rules)
               (generate_code_for_lex Rules)
               (generate_code_for_nonlex Rules)))

(define lex?
  [[S --> Terminal] | _] -> (string? Terminal)
  _ -> false)

(define generate_code_for_nonlex
  Rules -> (eval (append [define (get_characteristic_non_terminal Rules)
                                   | (mapapp (function gcfn_help) Rules)]
                         [(protect X) -> [fail]])))

(define mapapp
  _ [] -> []
  F [X | Y] -> (append (F X) (mapapp F Y)))

(define get_characteristic_non_terminal
  [[CNT | _] | _] -> CNT)

(define gcfn_help
   Rule -> [(protect Parameter)
            <-
            (apply_expansion Rule
                             [listit [head (protect Parameter)]
                                     [cons [listit | Rule]
                                           [head [tail (protect Parameter)]]]])])

(define apply_expansion
   [CNT --> | Expansion] Parameter -> (ae_help Expansion Parameter))

(define ae_help
   [] Code -> Code
   [NT | Expansion] Code -> (ae_help Expansion [NT Code]))

(define generate_code_for_lex
  Rules -> (eval (append
                  [define (get_characteristic_non_terminal Rules)
                    (protect X) -> [fail]  where [= (protect X) [fail]]
                    | (mapapp (function gcfl_help) Rules)]
                  [(protect X) -> [fail]])))

(define gcfl_help
  [CNT --> Terminal]
  -> [[cons [cons Terminal (protect P)] [cons (protect Parse) []]]
      -> [listit (protect P) [cons [listit CNT --> Terminal] (protect Parse)]]])

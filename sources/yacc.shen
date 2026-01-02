\\           Copyright (c) 2010-2019, Mark Tarver

\\                  All rights reserved.

(package shen []

(define compile
  F L -> (let Compile (F L)
           (cases (parse-failure? Compile)         (error "parse failure~%")
                  (partial-parse-failure? Compile) (do (set *residue* (in-> Compile))
                                                       (raise-syntax-error (value *residue*)))
                  true                             (<-out Compile))))

(define raise-syntax-error
  Residue -> (error (cn "syntax error here: "
                     (syntax-error-message (value *maximum-print-sequence-size*) 0 Residue))))

(define syntax-error-message
  _ _ [] -> "c#10;"
  Max Max _ -> "...etc c#10;"
  Max N [X | Y] -> (cn (make-string "~S " X) (syntax-error-message Max (+ N 1) Y)))

(define parse-failure?
  X -> (= X (fail)))

(define partial-parse-failure?
  Compile -> (cons? (in-> Compile)))

(define objectcode
   [_ ObjectCode] -> ObjectCode
   X -> (error "~S is not a YACC stream~%" X))

(define yacc->shen
   YACC -> (compile (/. X (<yacc> X)) YACC))

(defcc <yacc>
   F <yaccsig> <c-rules> := (let Input (gensym (protect S))
                                 Def    (append [define F]
                                                <yaccsig>
                                                [Input -> (c-rules->shen <yaccsig> Input <c-rules>)])
                                 Def);)

(defcc <yaccsig>
  LC [list A] ==> B RC := [{ [list A] --> [str [list A] B] }]
                            where (and (= { LC) (= } RC));
  <e> := [];)

(defcc <c-rules>
   <c-rule> <c-rules> := [<c-rule> | <c-rules>];
   <!> := (if (empty? <!>) [] (error "YACC syntax error here:~% ~R~% ..." <!>));)

(defcc <c-rule>
   <syntax> <semantics> <sc>  := [<syntax> <semantics>];
   <syntax> <sc>              := [<syntax> (autocomplete <syntax>)];)

(define autocomplete
  [SyntaxItem] -> SyntaxItem    where (non-terminal? SyntaxItem)
  [SyntaxItem | Syntax] -> [append SyntaxItem (autocomplete Syntax)]  where (non-terminal? SyntaxItem)
  [SyntaxItem | Syntax] -> [cons (autocomplete SyntaxItem) (autocomplete Syntax)]
  SyntaxItem -> SyntaxItem)

(define non-terminal?
  SyntaxItem -> (and (symbol? SyntaxItem)
                     (let Explode (explode SyntaxItem)
                         (compile (/. X (<non-terminal?> X)) Explode))))

(defcc <non-terminal?>
  <packagenames> <non-terminal-name> := true;
  <non-terminal-name> := true;
  <!> := false;)

(defcc <packagenames>
  <packagename> "." <packagenames>  := skip;
  <packagename> "." := skip;)

(defcc <packagename>
  <packagechar> <packagename> := skip;
  <e> := skip;)

(defcc <packagechar>
   X := skip           where (not (= X "."));)

(defcc <non-terminal-name>
  "<" <!> := skip  where (let Reverse (reverse <!>)
                              (and (cons? Reverse) (= (hd Reverse) ">")));)

(define semicolon?
  X -> (= X (intern ";")))

(defcc <colon-equal>
  X := skip  where (colon-equal? X);)

(define colon-equal?
  X -> (= (intern ":=") X))

(defcc <syntax>
   <syntax-item> <syntax> := [<syntax-item> | <syntax>];
   <syntax-item> := [<syntax-item>];)

(defcc <syntax-item>
   X := X    where (syntax-item? X);)

(define syntax-item?
   X           -> false  where (colon-equal? X)
   X           -> false  where (semicolon? X)
   X           -> true	  where (atom? X)
   [cons X Y]  -> (and (syntax-item? X) (syntax-item? Y))
   _           -> false)

(defcc <semantics>
  <colon-equal> Semantics where Guard := [where Guard Semantics] where (not (semicolon? Semantics));
  <colon-equal> Semantics             := Semantics               where (not (semicolon? Semantics));)

(define c-rules->shen
  _ Input [] -> [parse-failure]
  Type Input [CRule | CRules]
   -> (combine-c-code (c-rule->shen Type CRule Input)
                      (c-rules->shen Type Input CRules))
  _ _ _ -> (error "implementation error in shen.c-rules->shen~%"))

(define parse-failure
  -> (fail))

(define combine-c-code
  CRuleShen CRulesShen -> [let (protect Result) CRuleShen
                               [if [parse-failure? (protect Result)]
                                   CRulesShen
                                   (protect Result)]])

(define c-rule->shen
  Type [Syntax Semantics] Input -> (yacc-syntax Type Input Syntax Semantics)
   _ _ _ -> (error "implementation error in shen.c-rule->shen~%"))

(define yacc-syntax
  Type Input [] [where P Semantics] -> [if (process-yacc-semantics P)
                                           (yacc-syntax Type Input [] Semantics)
                                           [parse-failure]]
  Type Input [] Semantics -> (yacc-semantics Type Input Semantics)
  Type Input [SyntaxItem | Syntax] Semantics
   -> (cases (non-terminal? SyntaxItem) (non-terminalcode Type Input SyntaxItem Syntax Semantics)
             (variable? SyntaxItem)     (variablecode Type Input SyntaxItem Syntax Semantics)
             (= _ SyntaxItem)           (wildcardcode Type Input SyntaxItem Syntax Semantics)
             (atom? SyntaxItem)         (terminalcode Type Input SyntaxItem Syntax Semantics)
             (cons? SyntaxItem)         (conscode Type Input SyntaxItem Syntax Semantics)
             true                       (error "implementation error in shen.yacc-syntax~%"))
  _ _ _ _ -> (error "implementation error in shen.yacc-syntax~%"))

(define non-terminalcode
  Type Input NonTerminal Syntax Semantics
    -> (let TryParse         (concat (protect Parse) NonTerminal)
            Act              (concat (protect Action) NonTerminal)
            Remainder        (concat (protect Remainder) NonTerminal)
        [let TryParse [NonTerminal Input]
          [if [parse-failure? TryParse]
              [parse-failure]
              (let Continue [let Remainder [in-> TryParse]
                                 (yacc-syntax Type Remainder Syntax Semantics)]
                   (if (or (occurs-check? NonTerminal Semantics) (occurs-check? Act Semantics))
                       [let Act [<-out TryParse] Continue]
                       Continue))]]))


(define variablecode
  Type Input Variable Syntax Semantics
    -> (let Remainder (gensym (protect Remainder))
         [if [cons? Input]
             (let Continue [let Remainder [tail Input]
                             (yacc-syntax Type Remainder Syntax Semantics)]
                  (if (occurs-check? Variable Semantics)
                      [let Variable [head Input] Continue]
                      Continue))
             [parse-failure]]))

(define wildcardcode
  Type Input Variable Syntax Semantics
    -> (let Remainder (gensym (protect Remainder))
         [if [cons? Input]
             [let Remainder [tail Input]
               (yacc-syntax Type Remainder Syntax Semantics)]
             [parse-failure]]))

(define terminalcode
  Type Input Terminal Syntax Semantics
    -> (let Remainder (gensym (protect Remainder))
         [if [hds=? Input Terminal]
             [let Remainder [tail Input]
               (yacc-syntax Type Remainder Syntax Semantics)]
             [parse-failure]]))

(define hds=?
  [X | _] X -> true
  _ _ -> false)

(define conscode
  Type Input Cons Syntax Semantics
    -> (let Remainder (gensym (protect Remainder))
            Head      (gensym (protect Hd))
            Tail      (gensym (protect Tl))
        [if [ccons? Input]
            [let Head [head Input]
                 Tail [tail Input]
              (yacc-syntax Type Head (append (decons Cons) [<end>])
                  [processed (yacc-syntax Type Tail Syntax Semantics)])]
            [parse-failure]]))

(define ccons?
  [[_ | _] | _] -> true
  _ -> false)

(define decons
  [cons X Y] -> [X | (decons Y)]
  X -> X)

(define comb
  X Y -> [X Y])

(define yacc-semantics
  _ _ [processed Semantics] -> Semantics
  Type Input Semantics -> (let Process (process-yacc-semantics Semantics)
                               Annotate (use-type-info Type Process)
                            [comb Input Annotate]))

(define use-type-info
  [{ [list A] --> [str [list A] B] }] Semantics -> [type Semantics B]
      where (monomorphic? B)
  _ Semantics -> Semantics)

(define monomorphic?
  X -> false  where (variable? X)
  [X | Y] -> (and (monomorphic? X) (monomorphic? Y))
  _ -> true)

(define process-yacc-semantics
  [protect NonTerminal] -> NonTerminal    where (non-terminal? NonTerminal)
  [X | Y] -> (map (/. Z (process-yacc-semantics Z)) [X | Y])
  NonTerminal -> (concat (protect Action) NonTerminal)  where (non-terminal? NonTerminal)
  X -> X)

(define <-out
  [_ X] -> X
  X -> (hd (tl X)))

(define in->
  X -> (hd X))

(define <!>
  X -> [[] X])

(define <e>
  X -> [X []])

(define <end>
  [] -> [[] []]
  _ -> (parse-failure))

)

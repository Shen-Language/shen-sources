\\           Copyright (c) 2010-2019, Mark Tarver

\\                  All rights reserved.

(package shen []
  
  (define compile
    F L -> (let Compile (F [L no-action])
                (if (parsed? Compile)
                    (objectcode Compile)
                    (error "parse failure~%"))))
                                 
  (define parsed?
    X -> false       where (parse-failure? X)  
    [[X | Y] | _] -> (do (set *residue* [X | Y])
                         (error "syntax error here: ~R~% ..." [X | Y]))
    _ -> true)
    
  (define parse-failure?
    X -> (= X (fail)))  
    
  (define objectcode
     [_ ObjectCode] -> ObjectCode
     X -> (error "~S is not a YACC stream~%" X))   
     
  (define yacc->shen
     YACC -> (compile (/. X (<yacc> X)) YACC))
  
  (defcc <yacc>
     F <yaccsig> <c-rules> := (let Stream (gensym (protect S))
                                   Def    (append [define F]
                                                  <yaccsig>
                                                  [Stream -> (c-rules->shen <yaccsig> Stream <c-rules>)])
                                   Def);) 
     
   (defcc <yaccsig>
     LC [list A] ==> B RC := (let C (protect (gensym C))
                               [{ [str [list A] (protect C)] --> [str [list A] B] }])
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
     _ Stream [] -> [parse-failure]
     Type Stream [CRule | CRules] 
      -> (combine-c-code (c-rule->shen Type CRule Stream) 
                         (c-rules->shen Type Stream CRules))
     _ _ _ -> (error "implementation error in shen.c-rules->shen~%"))
                         
   (define parse-failure
     -> (fail))                      
                          
   (define combine-c-code
     CRuleShen CRulesShen -> [let (protect Result) CRuleShen
                                  [if [parse-failure? (protect Result)]
                                      CRulesShen
                                      (protect Result)]])                                                         
    
   (define c-rule->shen
     Type [Syntax Semantics] Stream -> (yacc-syntax Type Stream Syntax Semantics)
      _ _ _ -> (error "implementation error in shen.c-rule->shen~%"))
                                           
   (define yacc-syntax 
     Type Stream [] [where P Semantics] -> [if (process-yacc-semantics P) 
                                               (yacc-syntax Type Stream [] Semantics) 
                                               [parse-failure]]
     Type Stream [] Semantics -> (yacc-semantics Type Stream Semantics)
     Type Stream [SyntaxItem | Syntax] Semantics
      -> (cases (non-terminal? SyntaxItem) (non-terminalcode Type Stream SyntaxItem Syntax Semantics)
                (variable? SyntaxItem)     (variablecode Type Stream SyntaxItem Syntax Semantics)
                (= _ SyntaxItem)           (wildcardcode Type Stream SyntaxItem Syntax Semantics)
                (atom? SyntaxItem)         (terminalcode Type Stream SyntaxItem Syntax Semantics)
                (cons? SyntaxItem)         (conscode Type Stream SyntaxItem Syntax Semantics)
                true                       (error "implementation error in shen.yacc-syntax~%"))
     _ _ _ _ -> (error "implementation error in shen.yacc-syntax~%"))
                
   (define non-terminalcode
     Type Stream NonTerminal Syntax Semantics 
       -> (let ApplyNonTerminal (concat (protect Parse) NonTerminal)
           [let ApplyNonTerminal [NonTerminal Stream] 
               [if [parse-failure? ApplyNonTerminal]
                   [parse-failure]
                   (yacc-syntax Type ApplyNonTerminal Syntax Semantics)]]))
                           
   (define variablecode
     Type Stream Variable Syntax Semantics
       -> (let NewStream (gensym (protect News))
               [if [non-empty-stream? Stream]
                   [let Variable [hds Stream]
                        NewStream [tls Stream] 
                        (yacc-syntax Type NewStream Syntax Semantics)]
               [parse-failure]]))
               
   (define wildcardcode
     Type Stream Variable Syntax Semantics
       -> (let NewStream (gensym (protect News))
              [if [non-empty-stream? Stream]
                  [let NewStream [tls Stream] 
                       (yacc-syntax Type NewStream Syntax Semantics)]
                  [parse-failure]]))
                
   (define terminalcode
     Type Stream Terminal Syntax Semantics 
       -> (let NewStream (gensym (protect News))
               [if [=hd? Stream Terminal]              
                   [let NewStream [tls Stream] 
                        (yacc-syntax Type NewStream Syntax Semantics)]
                   [parse-failure]])) 
    
    (define conscode
      Type Str Cons Syn Sem -> [if [ccons? Str]
                                   [let (protect SynCons) [comb [hds Str] [<-out Str]]
                                        (yacc-syntax Type 
                                                (protect SynCons)
                                                (append (decons Cons) [<end>])
                                                [pushsemantics [tlstream Str] Syn Sem])]
                                   [parse-failure]])  

    (define decons
      [cons X Y] -> [X | (decons Y)]
      X -> X)
       
    (define ccons?
      [[X | _] _] -> (cons? X)
      _ -> false)                  
              
    (define non-empty-stream?
     [[_ | _] | _] -> true
     _ -> false)
     
   (define hds
     Stream -> (hd (hd Stream)))
      
    (define hdstream
      [[X | _] Y] -> [X Y]
      _ -> (error "implementation error in shen.hdstream~%"))  
      
    (define comb
      X Y -> [X Y])  
      
    (define tlstream
      [[_ | Y] Z] -> [Y Z]
      _ -> (error "implementation error in shen.tlstream~%"))                     
              
    (define =hd?
      [[X | _] | _] X -> true
      _ _ -> false)
      
    (define tls
      [[_ | Y] Z] -> [Y Z]
      _ -> (error "implementation error in shen.tls~%"))      
                            
    (define yacc-semantics
      Type _ [pushsemantics Stream Syntax Semantics] -> (yacc-syntax Type Stream Syntax Semantics)
      Type Stream Semantics -> (let Process (process-yacc-semantics Semantics)
                                    Annotate (use-type-info Type Process)
                                    [comb [in-> Stream] Annotate]))
    
    (define use-type-info
     [{ [str [list A] C] --> [str [list A] B] }] Semantics -> [type Semantics B]
     _ Semantics -> Semantics)    
       
    (define process-yacc-semantics
      [X | Y] -> (map (/. Z (process-yacc-semantics Z)) [X | Y])
      NonTerminal -> [<-out (concat (protect Parse) NonTerminal)]  where (non-terminal? NonTerminal)
      X -> X)
      
     (define <-out
       [_ X] -> X
       _ -> (error "implementation error in shen.<-out~%"))
       
     (define in->
       [X _] -> X
       _ -> (error "implementation error in shen.in->~%"))  
       
     (define <!>
      [X _] -> [[] X]
      _ -> (error "implementation error in <!>~%"))
       
     (define <e>
       [X _] -> [X []]
       _ -> (error "implementation error in <e>~%"))
       
     (define <end>
       [[] X] -> [[] X]
       _ -> (parse-failure)))
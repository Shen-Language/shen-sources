\*

Copyright (c) 2010-2015, Mark Tarver

All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
1. Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.
3. The name of Mark Tarver may not be used to endorse or promote products
   derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY Mark Tarver ''AS IS'' AND ANY
EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL Mark Tarver BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

*\

(package shen []

(define yacc
  [defcc S | CC_Stuff] -> (yacc->shen S CC_Stuff))

(define yacc->shen
  S CC_Stuff -> (let CCRules (split_cc_rules true CC_Stuff [])
                     CCBody (map (/. X (cc_body X)) CCRules)
                     YaccCases (yacc_cases CCBody)
                  [define S (protect Stream) -> (kill-code YaccCases)]))

(define kill-code
  YaccCases -> (protect [trap-error YaccCases [lambda E [analyse-kill E]]])
      where (> (occurrences kill YaccCases) 0)
  YaccCases -> YaccCases)

(define kill
  -> (simple-error "yacc kill"))

(define analyse-kill
  Exception -> (let String (error-to-string Exception)
                 (if (= String "yacc kill")
                     (fail)
                     Exception)))

(define split_cc_rules
  _ [] [] -> []
  Flag [] RevRule -> [(split_cc_rule Flag (reverse RevRule) [])]
  Flag [; | CC_Stuff] RevRule
  -> [(split_cc_rule Flag (reverse RevRule) [])
      | (split_cc_rules Flag CC_Stuff [])]
  Flag [X | CC_Stuff] RevRule -> (split_cc_rules Flag CC_Stuff [X | RevRule]))

(define split_cc_rule
  _ [:= Semantics] RevSyntax -> [(reverse RevSyntax) Semantics]
  _ [:= Semantics where Guard] RevSyntax
  -> [(reverse RevSyntax) [where Guard Semantics]]
  Flag [] RevSyntax
  -> (do (semantic-completion-warning Flag RevSyntax)
         (split_cc_rule Flag [:= (default_semantics (reverse RevSyntax))]
                        RevSyntax))
  Flag [Syntax | Rule] RevSyntax -> (split_cc_rule Flag Rule [Syntax | RevSyntax]))

(define semantic-completion-warning
  true RevSyntax -> (do (output "warning: ")
                        (map (/. X (output "~A " X)) (reverse RevSyntax))
                        (output "has no semantics.~%"))
  _ _ -> skip)

(define default_semantics
  [] -> []
  [S] -> S						  where (grammar_symbol? S)
  [S | Syntax] -> [append S (default_semantics Syntax)]	  where (grammar_symbol? S)
  [S | Syntax] -> [cons S (default_semantics Syntax)])

(define grammar_symbol?
  S -> (and (symbol? S)
            (let Cs (strip-pathname (explode S))
              (and (= (hd Cs) "<") (= (hd (reverse Cs)) ">")))))

(define yacc_cases
  [Case] -> Case
  [Case | Cases] -> (let P (protect YaccParse)
                      [let P Case
                        [if [= P [fail]]
                            (yacc_cases Cases)
                            P]]))

(define cc_body
  [Syntax Semantics] -> (syntax Syntax (protect Stream) Semantics))

(define syntax
  [] Stream [where Guard Semantics] -> [if (semantics Guard)
                                           [pair [hd Stream] (semantics Semantics)]
                                           [fail]]
  [] Stream Semantics -> [pair [hd Stream] (semantics Semantics)]
  [S | Syntax] Stream Semantics
  -> (cases (grammar_symbol? S) (recursive_descent [S | Syntax] Stream Semantics)
            (variable? S) (variable-match [S | Syntax] Stream Semantics)
            (jump_stream? S) (jump_stream [S | Syntax] Stream Semantics)
            (terminal? S) (check_stream [S | Syntax] Stream Semantics)
            (cons? S) (list-stream (decons S) Syntax Stream Semantics)
            true (error "~A is not legal syntax~%" S)))

(define list-stream
  S Syntax Stream Semantics
  -> (let Test [and [cons? [hd Stream]] [cons? [hd [hd Stream]]]]
          Placeholder (gensym place)
          RunOn (syntax Syntax [pair [tl [hd Stream]] [hd [tl Stream]]] Semantics)
          Action (insert-runon RunOn Placeholder
                               (syntax S
                                       [pair [hd [hd Stream]] [hd [tl Stream]]]
                                       Placeholder))
       [if Test
           Action
           [fail]]))

(define decons
  [cons X []] -> [X]
  [cons X Y] -> [X | (decons Y)]
  X -> X)

(define insert-runon
  Runon Placeholder [pair _ Placeholder] -> Runon
  Runon Placeholder [X | Y] -> (map (/. Z (insert-runon Runon Placeholder Z)) [X | Y])
  _ _ X -> X)

(define strip-pathname
  Cs -> Cs 		where (not (element? "." Cs))
  [_ | Cs] -> (strip-pathname Cs))

(define recursive_descent
  [S | Syntax] Stream Semantics
  -> (let Test [S Stream]
          Action (syntax Syntax
                         (concat (protect Parse_) S) Semantics)
          Else [fail]
       [let (concat (protect Parse_) S) Test
         [if [not [= [fail] (concat (protect Parse_) S)]]
             Action
             Else]]))

(define variable-match
  [S | Syntax] Stream Semantics
  -> (let Test [cons? [hd Stream]]
          Action [let (concat (protect Parse_) S) [hd [hd Stream]]
                   (syntax Syntax [pair [tl [hd Stream]]
                                        [hdtl Stream]] Semantics)]
          Else [fail]
       [if Test Action Else]))

(define terminal?
  [_ | _] -> false
  X -> false  where (variable? X)
  _ -> true)

(define jump_stream?
  X -> true  where (= X _)
  _ -> false)

(define check_stream
  [S | Syntax] Stream Semantics
  -> (let Test [and [cons? [hd Stream]] [= S [hd [hd Stream]]]]
          Action (syntax Syntax [pair [tl [hd Stream]]
                                      [hdtl Stream]] Semantics)
          Else [fail]
       [if Test Action Else]))

(define jump_stream
  [S | Syntax] Stream Semantics
  -> (let Test [cons? [hd Stream]]
          Action (syntax Syntax [pair [tl [hd Stream]]
                                      [hdtl Stream]] Semantics)
          Else [fail]
       [if Test Action Else]))

(define semantics
  [] -> []
  S -> [hdtl (concat (protect Parse_) S)] 	where (grammar_symbol? S)
  S -> (concat (protect Parse_) S) 	where (variable? S)
  [X | Y] -> (map (/. Z (semantics Z)) [X | Y])
  X -> X)

(define snd-or-fail
  [_ Y] -> Y
  _ -> (fail))

(define fail
  -> fail!)

(define pair
  X Y -> [X Y])

(define hdtl
  X -> (hd (tl X)))

(define <!>
  [X _] -> [[] X]
  _ -> (fail))

(define <e>
  [X _] -> [X []])

)

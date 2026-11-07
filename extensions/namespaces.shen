\\ Copyright (c) 2026 Bruno Deferrari. All rights reserved.
\\ BSD 3-Clause License: http://opensource.org/licenses/BSD-3-Clause

\\ Experimental source extension. See doc/extensions/namespaces.md.

(package shen.x.namespaces [use => externals with-externals import export shadow]

(define initialise
  -> (shen.register-source-form shen.x.namespace (fn expand)))

(define expand
  [shen.x.namespace Name | Forms] -> (header Name Forms [] [] [] []) where (name? Name)
  Form -> (error "invalid namespace: ~S~%" Form))

\\ Uses maps alias prefixes to owners, Imports maps local names to the symbols they stand
\\ for, and Exports pairs a name as written here with the name it is published under.
(define header
  Name [[use Owner] | Forms] Uses Imports Exports Externals ->
    (header Name Forms (add-use Owner Owner Uses) Imports Exports Externals)
  Name [[use Owner => Alias] | Forms] Uses Imports Exports Externals ->
    (header Name Forms (add-use Owner Alias Uses) Imports Exports Externals)
  Name [[import Owner | Names] | Forms] Uses Imports Exports Externals ->
    (header Name Forms Uses (add-imports (imports Owner (renames Names)) Imports)
            Exports Externals)
      where (name? Owner)
  Name [[shadow | Names] | Forms] Uses Imports Exports Externals ->
    (header Name Forms Uses (add-imports (shadows (str Name) Names) Imports)
            Exports Externals)
  Name [[export | Names] | Forms] Uses Imports Exports Externals ->
    (header Name Forms Uses Imports (append Exports (renames Names)) Externals)
  Name [[externals Expression] | Forms] Uses Imports Exports Externals ->
    (header Name Forms Uses Imports Exports
            (union (external-symbols (eval Expression)) Externals))
  _ [[Directive | Args] | _] _ _ _ _ ->
    (error "invalid namespace directive: ~S~%" [Directive | Args])
      where (directive? Directive)
  Name Forms Uses Imports Exports Externals ->
    (let Owner (str Name)
         Scope (@p Uses Imports)
         Body (body-forms Forms)
         Check (do (check-imports Imports Externals)
                   (check-definitions Body Owner Imports Externals))
         Publish (publish Name (published Exports Owner Scope Externals))
         Qualified (qualify-list Body Owner Scope Externals)
      (do (shen.record-external Name Externals)
          (shen.record-internal Name [] (snd Qualified))
          (fst Qualified))))

(define directive?
  Directive -> (element? Directive [use import export shadow externals]))

(define add-use
  Owner Prefix Uses -> [[Prefix | Owner] | Uses]
    where (and (name? Owner) (name? Prefix) (empty? (assoc Prefix Uses)))
  Owner Prefix _ -> (error "invalid or duplicate namespace use: ~S => ~S~%" Owner Prefix))

\\ a b => c gives [[a | a] [b | c]]: a name as its source has it, then the name it takes.
(define renames
  [] -> []
  [From => To | Names] -> [[From | To] | (renames Names)] where (and (name? From) (name? To))
  [Name | Names] -> [[Name | Name] | (renames Names)] where (and (name? Name) (not (= Name =>)))
  Names -> (error "invalid namespace names: ~S~%" Names))

(define imports
  _ [] -> []
  Owner [[Public | Local] | Names] -> [[Local | (exported Owner Public)] | (imports Owner Names)])

\\ A shadowed name is imported from the namespace itself, so it may be a system name.
(define shadows
  _ [] -> []
  Owner [Name | Names] -> [[Name | (shen.intern-in-package Owner Name)] | (shadows Owner Names)]
    where (name? Name)
  _ Names -> (error "invalid namespace names: ~S~%" Names))

(define add-imports
  [] Imports -> Imports
  [[Local | Symbol] | New] Imports -> (add-imports New [[Local | Symbol] | Imports])
    where (empty? (assoc Local Imports))
  [[Local | _] | _] _ -> (error "~S is imported or shadowed twice~%" Local))

(define check-imports
  [] _ -> skip
  [[Local | _] | _] Externals -> (error "~S is both external and imported~%" Local)
    where (element? Local Externals)
  [_ | Imports] Externals -> (check-imports Imports Externals))

\\ Top-level definitions only. A datatype labelled with a system name would stay global,
\\ and a second namespace using that label would replace its rules.
(define check-definitions
  [] _ _ _ -> skip
  [[datatype Label | _] | _] _ Imports Externals ->
    (error "datatype label ~S is a system name: shadow it~%" Label)
      where (and (shen.sysfunc? Label)
                 (not (element? Label Externals))
                 (empty? (assoc Label Imports)))
  [[Head F | _] | _] Owner Imports _ -> (error "~S is imported and cannot be defined here~%" F)
    where (and (element? Head [define defmacro defprolog defcc datatype])
               (imported? F Owner Imports))
  [_ | Forms] Owner Imports Externals -> (check-definitions Forms Owner Imports Externals))

(define imported?
  F Owner Imports -> (let Entry (assoc F Imports)
                       (and (cons? Entry)
                            (not (= (tl Entry) (shen.intern-in-package Owner F))))))

(define body-forms
  [[Directive | _] | _] ->
    (error "namespace directive after body: ~S~%" Directive)
      where (directive? Directive)
  [Form | Forms] -> [Form | (body-forms Forms)]
  [] -> [])

(define name?
  Name -> (and (symbol? Name) (not (variable? Name))))

\\ Like package, evaluate externals before qualification; validate the result.
(define external-symbols
  [] -> []
  [Symbol | Rest] -> [Symbol | (external-symbols Rest)] where (name? Symbol)
  X -> (error "externals expects a list of non-variable symbols: ~S~%" X))

\\ An interface maps each published name to the symbol it stands for. An owner without
\\ one is open: not read yet, a package, or a namespace that exports nothing.
(define interface
  Owner -> (trap-error (get Owner exports) (/. E [])))

(define exported
  Owner Member -> (let Table (interface Owner)
                       Entry (assoc Member Table)
                    (cases (cons? Entry) (tl Entry)
                           (empty? Table) (shen.intern-in-package (str Owner) Member)
                           true (error "~A does not export ~A~%" Owner Member))))

\\ The left of an export resolves as the body's names do, so a namespace can re-export.
\\ Through a use prefix it needs a name of its own, as the prefix means nothing elsewhere.
(define published
  [] _ _ _ -> []
  [[From | From] | _] Owner Scope Externals ->
    (error "export ~S needs a name of its own: ~S => Name~%" From From)
      where (through-use? From Owner Scope Externals)
  [[From | Public] | Exports] Owner Scope Externals ->
    [[Public | (fst (qualify From Owner Scope Externals))]
     | (published Exports Owner Scope Externals)])

(define through-use?
  From Owner (@p Uses Imports) Externals -> (and (shen.internal? From Owner Externals)
                                                 (empty? (assoc From Imports))
                                                 (cons? (use-name From Uses))))

\\ Blocks of a namespace add to its interface, but a name is published one way only.
(define publish
  _ [] -> skip
  Name Table -> (put Name exports (merge-exports Table (interface Name))))

(define merge-exports
  [] Old -> Old
  [Entry | New] Old -> (merge-exports New Old) where (element? Entry Old)
  [[Public | _] | _] Old -> (error "~S is already exported as something else~%" Public)
    where (cons? (assoc Public Old))
  [Entry | New] Old -> (merge-exports New [Entry | Old]))

\\ Return the qualified form and the original local names for package metadata.
\\ Scoped externals affect this walk only; they are not published as externals.
\\ They take precedence over imports and use prefixes, as namespace externals do.
(define qualify
  [with-externals Expression Form] Owner Scope Externals ->
    (qualify Form Owner Scope (union (external-symbols (eval Expression)) Externals))
  [with-externals | Args] _ _ _ -> (error "invalid with-externals: ~S~%" Args)
  [X | Xs] Owner Scope Externals -> (qualify-list [X | Xs] Owner Scope Externals)
  X _ (@p _ Imports) Externals -> (@p (tl (assoc X Imports)) [])
    where (and (cons? (assoc X Imports)) (not (element? X Externals)))
  X Owner (@p Uses _) Externals ->
    (let Use (use-name X Uses)
      (if (cons? Use)
          (@p (exported (hd (tl Use)) (intern (tl (tl Use)))) [])
          (@p (shen.intern-in-package Owner X) [X])))
      where (shen.internal? X Owner Externals)
  X _ _ _ -> (@p X []))

(define qualify-list
  [Form | Forms] Owner Scope Externals ->
    (let First (qualify Form Owner Scope Externals)
         Rest (qualify-list Forms Owner Scope Externals)
      (@p [(fst First) | (fst Rest)] (union (snd First) (snd Rest))))
  X Owner Scope Externals -> (qualify X Owner Scope Externals))

\\ Match complete dotted prefixes; the most specific declared prefix wins, and only its
\\ member is looked up: [Prefix Owner | Member].
(define use-name
  _ [] -> []
  Symbol [[Prefix | Owner] | Uses] ->
    (let Found (use-name Symbol Uses)
         Member (member-after (str Prefix) (str Symbol))
      (if (and (string? Member)
               (or (empty? Found) (shen.internal-to-P? (str (hd Found)) (str Prefix))))
          [Prefix Owner | Member]
          Found)))

(define member-after
  "" (@s "." Member) -> Member where (not (= Member ""))
  (@s C Prefix) (@s C Name) -> (member-after Prefix Name)
  _ _ -> false)

)

\\ Copyright (c) 2026 Bruno Deferrari. All rights reserved.
\\ BSD 3-Clause License: http://opensource.org/licenses/BSD-3-Clause

\\ Experimental source extension. See doc/extensions/namespaces.md.

(package shen.x.namespaces [use => externals with-externals]

(define initialise
  -> (shen.register-source-form shen.x.namespace (fn expand)))

(define expand
  [shen.x.namespace Name | Forms] -> (header Name Forms [] []) where (name? Name)
  Form -> (error "invalid namespace: ~S~%" Form))

(define header
  Name [[use Owner] | Forms] Uses Externals ->
    (header Name Forms (add-use Owner Owner Uses) Externals)
  Name [[use Owner => Alias] | Forms] Uses Externals ->
    (header Name Forms (add-use Owner Alias Uses) Externals)
  Name [[externals Expression] | Forms] Uses Externals ->
    (header Name Forms Uses (union (external-symbols (eval Expression)) Externals))
  _ [[Directive | Args] | _] _ _ ->
    (error "invalid namespace directive: ~S~%" [Directive | Args])
      where (element? Directive [use externals])
  Name Forms Uses Externals ->
    (let Body (qualify-list (body-forms Forms) (str Name) Uses Externals)
      (do (shen.record-external Name Externals)
          (shen.record-internal Name [] (snd Body))
          (fst Body))))

(define add-use
  Owner Prefix Uses -> [[Prefix | Owner] | Uses]
    where (and (name? Owner) (name? Prefix) (empty? (assoc Prefix Uses)))
  Owner Prefix _ -> (error "invalid or duplicate namespace use: ~S => ~S~%" Owner Prefix))

(define body-forms
  [[Directive | _] | _] ->
    (error "namespace directive after body: ~S~%" Directive)
      where (element? Directive [use externals])
  [Form | Forms] -> [Form | (body-forms Forms)]
  [] -> [])

(define name?
  Name -> (and (symbol? Name) (not (variable? Name))))

\\ Like package, evaluate externals before qualification; validate the result.
(define external-symbols
  [] -> []
  [Symbol | Rest] -> [Symbol | (external-symbols Rest)] where (name? Symbol)
  X -> (error "externals expects a list of non-variable symbols: ~S~%" X))

\\ Return the qualified form and the original local names for package metadata.
\\ Scoped externals affect this walk only; they are not published as externals.
(define qualify
  [with-externals Expression Form] Owner Uses Externals ->
    (qualify Form Owner Uses (union (external-symbols (eval Expression)) Externals))
  [with-externals | Args] _ _ _ -> (error "invalid with-externals: ~S~%" Args)
  [X | Xs] Owner Uses Externals -> (qualify-list [X | Xs] Owner Uses Externals)
  X Owner Uses Externals ->
    (let Import (import-name X Uses)
      (if (cons? Import)
          (@p (tl Import) [])
          (@p (shen.intern-in-package Owner X) [X])))
      where (shen.internal? X Owner Externals)
  X _ _ _ -> (@p X []))

(define qualify-list
  [Form | Forms] Owner Uses Externals ->
    (let First (qualify Form Owner Uses Externals)
         Rest (qualify-list Forms Owner Uses Externals)
      (@p [(fst First) | (fst Rest)] (union (snd First) (snd Rest))))
  X Owner Uses Externals -> (qualify X Owner Uses Externals))

\\ Match complete dotted prefixes; the most specific declared prefix wins.
(define import-name
  _ [] -> []
  Symbol [[Prefix | Owner] | Uses] ->
    (let Found (import-name Symbol Uses)
         Member (member-after (str Prefix) (str Symbol))
      (if (and (string? Member)
               (or (empty? Found) (shen.internal-to-P? (str (hd Found)) (str Prefix))))
          [Prefix | (shen.intern-in-package (str Owner) (intern Member))]
          Found)))

(define member-after
  "" (@s "." Member) -> Member where (not (= Member ""))
  (@s C Prefix) (@s C Name) -> (member-after Prefix Name)
  _ _ -> false)

)

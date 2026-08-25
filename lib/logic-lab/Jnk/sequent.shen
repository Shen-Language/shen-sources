(package logic [sequent prop s-rule back kill save]

(set *tactics* [back kill save])

(defcc <sequent>
  shen.<sides> shen.<prems> shen.<sng> shen.<conc> shen.<sc>
   := [shen.<sides> shen.<prems> shen.<conc>];)

(defmacro s-rulemacro
  [s-rule Name Params | Sequent] -> (let Internal (compile (fn <sequent>) Sequent)
                                          (rule->shen Name Params Internal)))

(define rule->shen
  Name Params [S P [As R]] -> (linked-process- Name Params R As S P (protect Hypotheses)))

(define linked-process-
  Name Params R As S P Hyp
  ->  (let F (gensym f)
           Sequents (protect Sequents)
           Constraints [cons R []]
           Compile (compile-assumptions F As S P Hyp Params Constraints Sequents)
           Head (append (process-params Params) [[cons [@p Hyp R] Sequents]])
           Body (append [F Hyp []] (process-params Params) [Constraints [cons [@p Hyp R] Sequents]])
           Rule (append Head [->] [[trap-error Body [/. (intern "E") [cons [@p Hyp R] Sequents]]]])
           Default (default Params)
           Type (append (param-type Params) [[list sequent] --> [list sequent]])
           Shen (append [define Name {] Type [}] Rule Default)
           Declare (set *tactics* (adjoin Name (value *tactics*)))
           Code (reverse [Shen | Compile])
           [package null [] | Code]))

(define default
  Params -> (append (process-params Params) [(protect Sequents) -> (protect Sequents)]))

(define process-params
  [X : A | Params] -> [X | (process-params Params)]
  X -> X)

(define param-type
  [] -> []
  [X : A | Params] -> [A --> | (param-type Params)])

(define compile-assumptions
  F [] S P Hyp Params Constraints Sequents -> [(compile-after- F S P Hyp Params Constraints Sequents)]
  F [A | As] S P Hyp Params Constraints Sequents
  -> (let NewF (gensym f)
          CompileA (compile-assumption F NewF A Hyp Params Constraints Sequents)
          CompileAs (compile-assumptions NewF As S P Hyp Params [cons A Constraints] Sequents)
          [CompileA | CompileAs]))

(define compile-assumption
  F NewF A Hyp Params Constraints Sequents
  -> (let Processed (gensym (protect Past))
          Err (err-case Processed (process-params Params) Constraints Sequents)
          Base (foundit!- NewF A Hyp Processed (process-params Params) Constraints Sequents)
          Recursive (keep-looking- F Hyp Processed (process-params Params) Constraints Sequents)
          Type (append [{] [[list prop] --> [list prop] -->] (param-type Params)
                        [[list prop] --> [list sequent] --> [list sequent]]
                        [}])
          (append [define F] Type Err Base Recursive)))

(define err-case
  Processed Params Constraints Sequents
  -> (let Head (append [[] Processed] (process-params Params) [Constraints Sequents])
          Body [[abort]]
          Rule (append Head [->] Body)
          Rule))

(define foundit!-
  NewF A Hyp Processed Params Constraints Sequents
  -> (let Head (append [[cons A Hyp] Processed] (process-params Params) [Constraints Sequents])
          Body [(append [NewF [append Processed Hyp] []]
                        (process-params Params)
                        [[cons A Constraints] Sequents])]
          Rule (append Head [->] Body)
          Rule))

(define keep-looking-
  F Hyp Processed Params Constraints Sequents
  -> (let X (gensym (protect V))
          Head (append [[cons X Hyp] Processed] (process-params Params) [Constraints Sequents])
          Body [(append [F Hyp [cons X Processed]] (process-params Params) [Constraints Sequents])]
          Rule (append Head [->] Body)
          Rule))

(define compile-after-
  F S P Hyp Params Constraints Sequents
  -> (let Head (append [Hyp _] (process-params Params) [Constraints Sequents])
          Body (compile-side-conditions S P Hyp Sequents)
          Rule (append Head [->] [Body])
          Type (append [{ [list prop] --> [list prop] -->]
                           (param-type Params)
                           [[list prop] --> [list sequent] --> [list sequent]}])
          (append [define F] Type Rule)))

(define compile-side-conditions
  [[let X Y] | S] P Hyp Sequents -> (let OldStack
                                       (compile-side-conditions S P Hyp Sequents)
                                       (subst OldStack (protect Stack) Y))  where (= X (protect Stack))
  [[let X Y] | S] P Hyp Sequents -> [let X Y (compile-side-conditions S P Hyp Sequents)]
  [[if X] | S] P Hyp Sequents -> [if X (compile-side-conditions S P Hyp Sequents) Sequents]
  S P Hyp Sequents -> (compile-premises S P Hyp Sequents))

(define compile-premises
  [] [] _ Sequents -> [tail Sequents]
  [] [[As R] | P] Hyp Sequents -> [cons (compile-premise (reverse As) R Hyp)
                                        (compile-premises [] P Hyp Sequents)])

(define compile-premise
  [] R Hyp -> [@p Hyp R]
  [A | As] R Hyp -> (compile-premise As R [cons A Hyp])))

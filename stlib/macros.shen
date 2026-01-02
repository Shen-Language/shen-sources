(package stlib [prefix? suffix? subset? set=? set? permute nthhd cartprod powerset
 subbag? bag=? n-times trim-right trim-left trim trim-right-if
 trim-left-if trim-if assoc-if assoc-if-not infix? count-if count
 remove-duplicates foldr foldl find mapf remove-if some? every?
 mapc filter transitive-closure x->ascii take take-last drop drop-last
 index index-last insert splice sort partition render-file render
 s-op1 s-op2 string.reverse string.element? string.infix? string.suffix?
 string.prefix? string.length string.difference string.intersection
 string.nth whitespace? lowercase? uppercase? digit? alpha? alphanum?
 string.subset? string.set=? string.set? string.nth string.trim
 string.trim-right string.trim-left tokenise list->string string->list
 string.trim-left-if string.trim-right-if string.trim-if uppercase
 lowercase string.map file-extension strip-extension string.count
 spell-number string>? string<? string>=? string<=? string.some?
 string.every? prefix? suffix? subset? set=? set? permute nthhd
 cartprod powerset subbag? bag=? n-times trim-right trim-left trim
 trim-right-if trim-left-if trim-if assoc-if assoc-if-not infix?
 count-if count remove-duplicates foldr foldl find mapf remove-if
 some? every? mapc filter transitive-closure x->ascii take take-last
 drop drop-last index index-last insert splice sort partition expt
 =r gcd lcd isqrt sqrt nthrt floor ceiling round mod lcm random
 min max reseed ~ positive? negative? natural? converge series
 odd? even? cos sin tan radians pi e tan30 cos30 cos45 sin45 sqrt2
 tan60 sin120 tan120 sin135 cos135 cos150 tan150 cos210 tan210
 sin225 cos225 sin240 tan240 sin300 tan300 sin315 cos315 cos330
 tan330 sinh cosh tanh sech csch power factorial prime? unix div
 modf product summation set-tolerance tolerance coth for sq cube
 newv abs approx log log2 loge log10 g expt =r gcd lcd isqrt sqrt
 nthrt floor ceiling round mod lcm random min max reseed ~ positive?
 negative? natural? converge series odd? even? cos sin tan radians
 pi e tan30 cos30 cos45 sin45 sqrt2 tan60 sin120 tan120 sin135
 cos135 cos150 tan150 cos210 tan210 sin225 cos225 sin240 tan240
 sin300 tan300 sin315 cos315 cos330 tan330 sinh cosh tanh sech
 csch power factorial prime? unix div modf product summation set-tolerance
 tolerance coth sq cube abs approx log log2 loge log10 g list->vector
 dense? porous? vector.reverse vector.append vector.dfilter vector.element?
 sparse? vacant? vector.some? vector.map vector.dmap vector.every?
 maths.lazyfor-and maths.lazyfor-or compress newv for overwrite
 insert ignore depopulate populate populated? vector->list v-op1
 v-op2 array newv concat* pairoff assocp cartprodp assocp-if assocp-if-not
 append-files append-files-with-open-stream mapc copy-file file-size
 reopen errout copy-file-with-open-stream file-exists? newv ascii
 expt =r gcd lcd isqrt sqrt nthrt floor ceiling round mod lcm random
 min max reseed ~ positive? negative? natural? converge series
 odd? even? cos sin tan radians pi e tan30 cos30 cos45 sin45 sqrt2
 tan60 sin120 tan120 sin135 cos135 cos150 tan150 cos210 tan210
 sin225 cos225 sin240 tan240 sin300 tan300 sin315 cos315 cos330
 tan330 sinh cosh tanh sech csch power factorial prime? unix div
 modf product summation set-tolerance tolerance coth for sq cube
 newv abs approx log log2 loge log10 g pps pprint pretty-string
 linelength indentation set-linelength set-indentation]

 (defmacro stlib-macros

  \\ maths macros
  [log10 N] -> [log10 N [tolerance]]
  [log2 N] -> [log2 N [tolerance]]
  [loge N] -> [loge N [tolerance]]
  [log M N] -> [log M N [tolerance]]
  [sin N] -> [sin N [tolerance]]
  [tan N] -> [tan N [tolerance]]
  [cos N] -> [cos N [tolerance]]
  [tanh N] -> [tanh N [tolerance]]
  [cosh N] -> [cosh N [tolerance]]
  [sinh N] -> [sinh N [tolerance]]
  [sech N] -> [sech N [tolerance]]
  [csch N] -> [csch N [tolerance]]
  [coth N] -> [coth N [tolerance]]
  [nthrt N Root] -> [nthrt N Root [tolerance]]
  [sqrt N] -> [sqrt N [tolerance]]
  [expt M N] -> [expt M N [tolerance]]
  [max W X Y | Z] -> [max W [max X Y | Z]]
  [min W X Y | Z] -> [min W [min X Y | Z]]
  [tolerance N] -> [tolerance=n N]
  [for X = N Loop Do Step and]
    -> (let LBind (/. X Y (if (> (occurrences X Y) 0) [/. X Y] Y))
         [lazyfor-and N (LBind X Loop) (LBind X Do) Step])
  [for X = N Loop Do Step or]
    -> (let LBind (/. X Y (if (> (occurrences X Y) 0) [/. X Y] Y))
         [lazyfor-or N (LBind X Loop) (LBind X Do) Step])
  [for X = N Loop Do Step Acc] -> (let LBind (/. X Y (if (> (occurrences X Y) 0) [/. X Y] Y))
                                      [for N (LBind X Loop) (LBind X Do) Step Acc])
  [for X = N Loop Do Step] -> (let LBind (/. X Y (if (> (occurrences X Y) 0) [/. X Y] Y))
                                   [for N (LBind X Loop) (LBind X Do) Step [fn do]])
  [for X = N Loop Do] -> (let LBind (/. X Y (if (> (occurrences X Y) 0) [/. X Y] Y))
                           [for N (LBind X Loop) [/. X Do] [+ 1] [fn do]])

  \\ vector macros

  [:= V Is] -> (<-array V Is)
  [V Is := V* Is* | Key] -> (key V Is (array-> V Is (<-array V* Is*)) Key)
  [V Is := X | Key] -> (key V Is (array-> V Is X) Key)
  [array-> V Is X] -> (array-> V Is X)
  [array Is] -> (build-array Is)
  [populate F [cons I Is]] -> (unfold-populate F [cons I Is])
  [vector->list V] -> [vector->list V []]
  [v-op1 F V] -> [v-op1 F V []]
  [v-op2 F V1 V2] -> [v-op2 F V1 V2 []]

  \\ string macros

  [s-op1 F S] -> [s-op1 F S [/. (protect X) (protect X)]]
  [s-op2 F S1 S2] -> [s-op2 F S1 S2 [/. (protect X) (protect X)]]                         ))
(package maths [expt =r gcd lcd isqrt sqrt nthrt floor ceiling round mod lcm random min max
                reseed ~ positive? negative? natural? converge series odd? even? 
                cos sin tan radians pi e tan30 cos30 cos45 sin45 sqrt2 tan60 sin120
                tan120 sin135 cos135 cos150 tan150 cos210 tan210 sin225 cos225 sin240
                tan240 sin300 tan300 sin315 cos315 cos330 tan330 sinh cosh tanh sech 
                csch power factorial prime? unix div modf product summation set-tolerance tolerance
                coth for sq cube newv abs approx log log2 loge log10 g]
                
(defmacro maths-macro
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
                           [for N (LBind X Loop) [/. X Do] [+ 1] [fn do]]))  )
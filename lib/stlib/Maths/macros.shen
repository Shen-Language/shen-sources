(package maths [expt =r gcd lcd isqrt sqrt nthrt floor ceiling round mod lcm random min max
                reseed ~ positive? negative? natural? converge series odd? even?
                cos sin tan radians pi e tan30 cos30 cos45 sin45 sqrt2 tan60 sin120
                tan120 sin135 cos135 cos150 tan150 cos210 tan210 sin225 cos225 sin240
                tan240 sin300 tan300 sin315 cos315 cos330 tan330 sinh cosh tanh sech
                csch power factorial prime? unix div modf product summation set-tolerance tolerance
                coth for sq cube newv abs approx log log2 loge log10 g
                to stop step constructor end done]

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
  [for X = Val stop Stop | Options+Procedure] -> [upto Val Stop | (process-options X Options+Procedure)]
  [for X = Val to N | Options+Procedure] -> [upto Val [< N] | (process-options X Options+Procedure)])

(define process-options
  X O+P -> (append (step-option O+P)
                   (constructor-option O+P)
                   (end-option O+P)
                   (process X O+P)))

(define step-option
  [] -> [[+ 1]]
  [step Step | _] -> [Step]
  [_ | O+P] -> (step-option O+P))

(define constructor-option
  [] -> [[fn do]]
  [constructor C | _] -> [C]
  [_ | O+P] -> (constructor-option O+P))

(define end-option
  [] -> [done]
  [end End | _] -> [End]
  [_ | O+P] -> (end-option O+P))

(define process
  X [Process] -> [[/. X Process]]
  X [_ | O+P] -> (process X O+P)))

\\ Copyright (c) 2016, Mark Tarver
 
(package calendar [now internal-date unix gmt]

(datatype globals

   _______________
   (value *gmt*) : (symbol * number * number * number);)

(define gmt
  {symbol --> number --> number --> number --> (symbol * number * number * number)}
   Plus/Minus Hours Minutes Seconds 
    -> (set *gmt* (@p Plus/Minus Hours Minutes Seconds))  
        where (validate-gmt? Plus/Minus Hours Minutes Seconds)
   _ _ _ _ -> (error "error in GMT setting~%"))     
        
(define validate-gmt?
  {symbol --> number --> number --> number --> boolean}
  Plus/Minus Hours Minutes Seconds 
    -> (cases (not (element? Plus/Minus [+ -])) false
              (not (and (integer? Hours) (integer? Minutes) (integer? Seconds))) false
              (= Hours 12) (and (= Minutes 0) (= Seconds 0))
              (and (>= Hours 0) 
                   (<= Hours 11)
                   (>= Minutes 0) 
                   (<= Minutes 59)
                   (>= Seconds 0) 
                   (<= Seconds 59)) true
              true false))           

(gmt + 0 0 0)
  
(define now
  {number --> string}
   Days -> (internal-date->string (internal-date Days)))  
  
(define internal-date
 {number --> (list number)}
  Days -> (let UnixDate (+ (* 24 3600 Days) 
                             (get-time unix) 
                             (gmt-time (value *gmt*)))
               (if (> 0 UnixDate)
                   (error "cannot regress date before 1970~%")              
                   (internal-date-h 
                      UnixDate
                      (- 0 (* 24 3600)) 
                      1970 
                      year 
                      [])))  where (integer? Days)
  _ -> (error "internal-date requires an integer~%"))

(define gmt-time
  {(symbol * number * number * number) --> number}
   (@p - Hours Minutes Seconds) -> (- 0 (+ (* 3600 Hours) (* 60 Minutes) Seconds))
   (@p + Hours Minutes Seconds) -> (+ (* 3600 Hours) (* 60 Minutes) Seconds)) 
  
(define internal-date-h
  {number --> number --> number --> symbol --> (list number) --> (list number)}
  Now Now Count _ Date -> [Count | Date]
  Now Then Count Interval Date 
  -> (let Then' (+ (seconds-in Count Interval Date) Then)
          (if (> Then' Now)
              (let NextInterval (next-interval Interval)
                   Start (start-interval NextInterval)
                   (internal-date-h Now Then Start NextInterval [Count | Date])) 
              (internal-date-h Now Then' (+ Count 1) Interval Date))))
              
(define start-interval
  {symbol --> number}
   month -> 1
   day -> 0
   hour -> 0
   minute -> 0
   second -> 0)              
              
(define seconds-in
   {number --> symbol --> (list number) --> number}
   Count year _ -> (if (leap? Count) 
                       (* 366 24 3600) 
                       (* 365 24 3600)) 
   2 month [Year] -> (* 29 24 3600)  where (leap? Year)
   Count month _ -> (* (days-in-month Count) 24 3600)
   _ day _ -> (* 24 3600)
   _ hour _ -> 3600
   _ minute _ -> 60
   _ second _ -> 1)
   
(define next-interval
  {symbol --> symbol}
   year -> month
   month -> day
   day -> hour
   hour -> minute
   minute -> second)      
   
(define days-in-month
  {number --> number}
  1 -> 31
  2 -> 28
  3 -> 31
  4 -> 30
  5 -> 31
  6 -> 30
  7 -> 31
  8 -> 31
  9 -> 30
  10 -> 31
  11 -> 30
  12 -> 31)                          
                        
(define leap?
  {number --> boolean}
   Year -> (cases (integer? (/ Year 400)) true
                  (integer? (/ Year 100)) false
                  (integer? (/ Year 4)) true
                  true false)) 
                  
(define internal-date->string
  {(list number) --> string}
   [Seconds Minutes Hours Days Months Year] 
    -> (make-string "~A:~A:~A, ~A~A ~A, ~A ~A" 
         (pad Hours) (pad Minutes) (pad Seconds)
            Days (postfix-day Days) (month Months) Year (gmt-string (value *gmt*))))
    
(define gmt-string
  {(symbol * number * number * number) --> string}
  (@p Plus/Minus Hours Minutes Seconds) 
   -> (make-string "~AGMT ~A:~A:~A" Plus/Minus (pad Hours) (pad Minutes) (pad Seconds)))
            
(define pad
  {number --> string}
   N -> (make-string "~A" N) where (> N 9)
   N -> (make-string "0~A" N))            
         
(define postfix-day
  {number --> string}
   1 -> "st"
   21 -> "st"
   31 -> "st"
   2 -> "nd"
   22 -> "nd"
   3 -> "rd"
   23 -> "rd"
   _ -> "th")
   
(define month
  {number --> string}
    1 -> "January"
    2 -> "February"
    3 -> "March"
    4 -> "April"
    5 -> "May"
    6 -> "June"
    7 -> "July"
    8 -> "August"
    9 -> "September"
    10 -> "October"
    11 -> "November"
    12 -> "December"))
    

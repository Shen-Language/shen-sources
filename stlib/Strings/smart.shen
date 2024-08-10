(package string [render-file render string->list file-extension whitespace?]

(declare render [string --> string])
(declare render-file [string --> [string --> string]])

(define render-file
  File Extension -> (let Bytes (read-file-as-bytelist File)
                         Strings (bytes->strings Bytes [])
                         Render (compile (fn <render>) Strings)
                         Out (file-extension File Extension)
                         Write (write-to-file Out Render)
                         Out))
                         
(define bytes->strings
  [] Strings -> (reverse Strings)
  [Byte | Bytes] Strings -> (bytes->strings Bytes [(n->string Byte) | Strings]))                         

(define render
  String -> (compile (fn <render>) (string->list String)))                     
  
(define rendered?
  "" -> true
  (@s "{" _) -> false
  (@s _ S) -> (rendered? S)) 

(defcc <render>
  "{" <fn> <ws> <args> "}" <render> := (cn (recapply (fn (intern <fn>)) <args>) <render>);
  "{" <fn> "}" <render> := (cn ((intern <fn>)) <render>);
  <renderchar> <render> := (cn <renderchar> <render>);
  <e> := "";)
  
(defcc <renderchar>
  S := S           where (and (not (= S "}")) (not (= S "\")));)  
  
(define recapply
  X [] -> X
  Fn [X | Y] -> (recapply (Fn X) Y))   
  
(defcc <args>
  <arg> "\" <args> := [<arg> | <args>];
  <arg> := [<arg>];)
  
(defcc <arg>
  <render>;)
  
(defcc <argchar>
  Char := Char   where (and (not (= Char "}")) 
                            (not (= Char "\")));)      
  
(defcc <ws>
  W := skip  where (whitespace? W);)

(defcc <fn>
  <fnchar> <fn> := (cn <fnchar> <fn>);
  <e> := "";)
  
(defcc <fnchar>
  Char := Char  where (and (not (= Char "}")) 
                           (not (= Char "\")) 
                           (not (whitespace? Char)));))
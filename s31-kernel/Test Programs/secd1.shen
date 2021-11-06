(synonyms 	stack (list ob)
          	environment (list (symbol * ob))
          	control (list ob)
          	dump (list (stack * environment * control)))

(datatype ob

 E : environment; X : symbol; Y : ob;
  ====================================
  [closure E X Y] : ob;

  X : symbol; Y : ob;
  ===================
  [lambda X Y] : ob;

  X : ob; Y : ob;
  ===============
  [X Y] : ob;

  X : symbol;
  ___________
  X : ob;)

(define evaluate
  {ob --> ob}
  X -> (secd [] [] [X] []))

(define secd
  {stack --> environment --> control --> dump --> ob}
  [V] E [] [] -> V
  [V] _ [] [(@p S E C) | D] -> (secd [V | S] E C D)
  S E [[lambda X Y] | C] D -> (secd [[closure E X Y] | S] E C D)
  S E [[X Y] | C] D -> (secd S E [Y X @ | C] D)
  [[closure E* X Y] Z | S] E [@ | C] D -> (secd [] [(@p X Z) | E*] [Y] [(@p S E C) | D])
  S E [X | C] D ->(if (bnd? X E) (secd [(lookup X E) | S] E C D)  (secd [X | S] E C D)))

(define bnd?
  {ob --> environment --> boolean}
   X [] -> false
   X [(@p Y _) | _] -> true  where (== X Y)
   X [_ | Y] -> (bnd? X Y))

(define lookup
  {ob --> environment --> ob}
   X [] -> X
   X [(@p Y Z) | _] -> Z  where (== X Y)
   X [_ | Y] -> (lookup X Y))


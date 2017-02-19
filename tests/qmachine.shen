(datatype progression

	X : A; S : (A --> A); E : (A --> boolean);
	==========================================
	[X S E] : (progression A);)

(define force
  {(progression A) --> A}
  [X S E] -> X)

(define delay
  {(progression A) --> (progression A)}
  [X S E] -> [(S X) S E])

(define end?
  {(progression A) --> boolean}
  [X S E] -> (E X))

(define push
  {A --> (progression A) --> (progression A)}
  X [Y S E] -> [X (/. Z (if (= Z X) Y (S Z))) E])

(define forall
  {(progression A) --> (A --> boolean) --> boolean}
  [X S E] P -> (if (E X) true (and (P X) (forall [(S X) S E] P))))

(define exists
  {(progression A) --> (A --> boolean) --> boolean}
  [X S E] P -> (if (E X) false (or (P X) (exists [(S X) S E] P))))

(define super
  {(progression A) --> (A --> B) --> (B --> C --> C) --> C --> C}
  [X S E] P F Y -> (if (E X) Y (F (P X) (super [(S X) S E] P F Y))))

(define forall
  {(progression A) --> (A --> boolean) --> boolean}
  Progression P -> (super Progression P (function and) true))

(define exists
  {(progression A) --> (A --> boolean) --> boolean}
  Progression P -> (super Progression P (function or) false))

(define for
  {(progression A) --> (A --> B) --> number}
  Progression P -> (super Progression P (function progn) 0))

(define progn
  {A --> B --> B}
  X Y -> Y)

(define filter
  {(progression A) --> (A --> boolean) --> (list A)}
  Progression P -> (super Progression (/. X (if (P X) [X] [])) append []))

(define next-prime
  {number --> number}
  N -> (if (prime? (+ N 1)) (+ N 1) (next-prime (+ N 1))))

(define prime?
  {number --> boolean}
  X -> (prime-help X (/ X 2) 2))

(define prime-help
  {number --> number --> number --> boolean}
  X Max Div -> false 		where (integer? (/ X Div))
  X Max Div -> true 		where (> Div Max)
  X Max Div -> (prime-help X Max (+ 1 Div)))

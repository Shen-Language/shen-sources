(synonyms
 card (rank * suit)
 cscore number
 pscore number )

(datatype rank

  if (element? Rank [2 3 4 5 6 7 8 9 10 11 12 13 14])
  ___________________________________________________
  Rank : rank;

  Rank : rank;
  ___________
  Rank : number;)

(datatype suit

  if (element? Suit [c d h s])
  ____________________________
  Suit : suit;)

(datatype lead

  if (element? L [player computer])
  _________________________________
  L : lead;)

(define whist
  {lead --> string}
  Lead -> (whist-loop (deal-whist 13 (deck _) (@p [] [])) 0 0 Lead))

(define deck
  {A --> (list card)}
  _ -> (cartprod [2 3 4 5 6 7 8 9 10 11 12 13 14]  [c d h s]))

(define cartprod
  {(list A) --> (list B) --> (list (A * B))}
  [] _ -> []
  [X | Y] Z -> (append (map (/. W (@p X W)) Z) (cartprod Y Z)))

(define deal-whist
  {number --> (list card) --> ((list card) * (list card)) -->  ((list card) * (list card))}
  0 _ (@p Computer Player) -> (@p Computer Player)
  N Deck  (@p Computer Player)
  -> (let CCard (deal-card Deck)
          Deck-1 (remove CCard Deck)
          PCard (deal-card Deck-1)
          Deck-2  (remove PCard Deck-1)
       (deal-whist (- N 1) Deck-2 (@p [CCard | Computer] [PCard | Player]))))

(define deal-card
  {(list card) --> card}
  Cards -> (nth (+ (random (length Cards)) 1) Cards))

(define random
  {A --> A}
  X -> X)

(define whist-loop
  {((list card) * (list card)) --> cscore --> pscore --> lead --> string}
  Hands Cscore Pscore _
  -> (if (> Cscore Pscore)
         (output "~%Computer tricks: ~A, Player tricks: ~A; ~%Computer wins!~%"
                 Cscore Pscore)
         (output "~%Computer tricks: ~A, Player tricks: ~A; ~%You win!~%"
                 Cscore Pscore))
      where (game-over? Hands)
  (@p Computer Player) Cscore Pscore computer
  -> (let Ccard (computer-shows (play-computer-lead Computer))
          Pcard (determine-legal (play-player Player) Ccard Player)
          Winner (return-winner (determine-winner Ccard Pcard computer))
          Computer-1 (remove Ccard Computer)
          Player-1 (remove Pcard Player)
       (if (= Winner computer)
           (whist-loop (@p Computer-1 Player-1)
                       (+ 1 Cscore)
                       Pscore
                       computer)
           (whist-loop (@p Computer-1 Player-1)
                       Cscore
                       (+ Pscore 1)
                       player)))
  (@p Computer Player) Cscore Pscore player
  -> (let Pcard (play-player Player)
          Ccard (computer-shows (play-computer-follow Computer Pcard))
          Winner (return-winner (determine-winner Ccard Pcard player))
          Computer-1 (remove Ccard Computer)
          Player-1 (remove Pcard Player)
       (if (= Winner computer)
           (whist-loop (@p Computer-1 Player-1)
                       (+ 1 Cscore)
                       Pscore
                       computer)
           (whist-loop (@p Computer-1 Player-1)
                       Cscore
                       (+ Pscore 1)
                       player))))

(define determine-legal
  {card --> card --> (list card) --> card}
  Pcard Ccard Player -> Pcard		where (legal? Pcard Ccard Player)
  _ Ccard Player -> (do (output "You must follow suit!" [])
		                    (determine-legal (play-player Player)
                                         Ccard
                                         Player)))

(define legal?
  {card --> card --> (list card) --> boolean}
  (@p _ Suit) (@p _ Suit) _ -> true
  _  (@p _ Suit) Player -> (void-of-suit? Suit Player))

(define void-of-suit?
  {suit --> (list card) --> boolean}
  Suit Player -> (empty? (same-suit Player Suit)))

(define same-suit
  {(list card) --> suit --> (list card)}
  [] _ -> []
  [(@p Rank Suit) | Cards] Suit -> [(@p Rank Suit) | (same-suit Cards Suit)]
  [_ | Cards] Suit -> (same-suit Cards Suit))

(define determine-winner
  {card --> card --> lead --> lead}
  (@p Rank1 Suit) (@p Rank2 Suit) _ -> (if (> Rank1 Rank2) computer player)
  _ _ Lead -> Lead)

(define return-winner
  {lead --> lead}
  computer -> (do (output "~%Computer wins the trick.~%____________________________________________~%" [])
                  computer)
  player -> (do (output "~%Player wins the trick.~%____________________________________________~%" [])
                player))

(define game-over?
  {((list card) * (list card)) --> boolean}
  (@p [] []) -> true
  _ -> false)

(define play-computer-lead
  {(list card) --> card}
  Cards -> (select-highest Cards))

(define computer-shows
  {card --> card}
  (@p Rank Suit) -> (do (output "~%Computer plays the ~A of ~A~%"
                                (map-rank Rank) (map-suit Suit))
                        (@p Rank Suit)))

(define map-rank
  {rank --> string}
  14 -> "ace"
  13 -> "king"
  12 -> "queen"
  11 -> "jack"
  N -> (make-string "~A" N))

(define map-suit
  {suit --> string}
  c -> "c#5;"
  d -> "c#4;"
  h -> "c#3;"
  s -> "c#6;")

(define select-highest
  {(list card) --> card}
  [Card | Cards] -> (select-highest-help Card Cards))

(define select-highest-help
  {card --> (list card) --> card}
  Card [] -> Card
  Card1 [Card2  | Cards]
	-> (select-highest-help Card2 Cards)  where (higher? Card2 Card1)
  Card [_ | Cards] -> (select-highest-help Card Cards))

(define higher?
  {card --> card --> boolean}
  (@p Rank1 _) (@p Rank2 _) -> (> Rank1 Rank2))

(define play-computer-follow
  {(list card) --> card --> card}
  Cards (@p Rank Suit)
  -> (let FollowSuit (sort lower? (same-suit Cards Suit))
       (if (empty? FollowSuit)
           (select-lowest Cards)
           (let Ccard (select-higher (@p Rank Suit) FollowSuit)
             (if (= (determine-winner Ccard (@p Rank Suit) player) computer)
                 Ccard
                 (head FollowSuit))))))

(define sort
  {(A --> A --> boolean) --> (list A) --> (list A)}
  R X -> (fix (/. Y (sort-help R Y)) X))

(define sort-help
  {(A --> A --> boolean) --> (list A) --> (list A)}
  _ [] -> []
  _ [X] -> [X]
  R [X Y | Z] -> [Y | (sort-help R [X | Z])]	where (R Y X)
  R [X | Y] -> [X | (sort-help R Y)])

(define select-higher
  {card --> (list card) --> card}
  _ [Card] -> Card
  Card1 [Card2 | _] -> Card2     where (higher? Card2 Card1)
  Card [_ | Cards] -> (select-higher Card Cards))

(define select-lowest
  {(list card) --> card}
  [Card | Cards] -> (select-lowest-help Card Cards))

(define select-lowest-help
  {card --> (list card) --> card}
  Card [] -> Card
  Card1 [Card2  | Cards]
  -> (select-lowest-help Card2 Cards)   where (lower? Card2 Card1)
  Card [_ | Cards] -> (select-lowest-help Card Cards))

(define lower?
  {card --> card --> boolean}
  (@p Rank1 _) (@p Rank2 _) -> (< Rank1 Rank2))

(define play-player
  {(list card) --> card}
  Cards -> (do (output "~%Your hand is ~%~%")
               (show-cards 1 Cards)
               (let N (input+ number)
                 (if (in-range? N Cards)
                     (nth N Cards)
                     (play-player Cards)))))

(define show-cards
  {number --> (list card) --> string}
  _ [] -> (output "~%~%Choose a Card: ")
  N [(@p Rank Suit) | Cards]
  -> (do (output "~%~A. ~A of ~A" N (map-rank Rank) (map-suit Suit))
         (show-cards (+ N 1) Cards)))

(define in-range?
  {number --> (list card) --> boolean}
  N Cards -> (and (integer? N) (and (> N 0) (<= N (length Cards)))))

import Data.Maybe
type Domino = (Int, Int)
type End    = Domino
type Hand   = [Domino]
type Board  = [Domino]
-- | The swap function emulates rotating a domino by swapping the values in its 
-- tuple.
-- It takes a Domino (int pair) as an argument, and returns the same type.
swap :: Domino -> Domino
swap (x,y) = (y,x)
-- | The playedP function determines whether a domino is on a given board in
-- either possible rotation.
-- It takes a Domino (int pair) as a parameter, and returns the same type.
defaultPositionP :: Domino -> Bool
defaultPositionP (x,y) = x<=y
isEndP :: End -> Board -> Bool
isEndP e [] = True
isEndP e b = e == last b || e == head b
playedP :: Domino -> Board -> Bool
playedP d b = elem d b || elem (swap d) b
-- | The goesLeftP function determines whether a domino can be played in either
-- configuration at the left side of the board.
goesLeftP :: Domino -> End -> Bool
goesLeftP (x,y) (e,z) = x == e || y == e
-- | The goesRightP function determines whether a domino can be played in
-- either configuration at the right side of the board.
goesRightP :: Domino -> End -> Bool
goesRightP (x,y) (z,e) = x == e || y == e
goesBothP :: Domino -> Board -> Bool
goesBothP d b = goesLeftP d (head b) && goesRightP d (last b) 
-- | TODO
goesEndsP :: Domino -> Board -> Bool
goesEndsP _ [] = True
goesEndsP d b = goesLeftP d (head b) || goesRightP d (last b) 
-- | The goesP function determines whether or not a domino can be played at a 
-- given end of the board.
-- It takes a Domino (int pair) and a Board (list of Dominoes) 
-- as parameters, and returns a Boolean.
goesP :: Domino -> End -> Board -> Bool
goesP d _ [] = True
goesP d e b
  | not (isEndP e b) = False
  | length b == 1 = goesEndsP d b
  | e == (head b) = goesLeftP d e
  | e == (last b) = goesRightP d e
  | otherwise = False
-- | The turnDomino function rotates a domino based on which end of the board
-- it is being played at.
-- It takes a Domino (int pair) and an End (as Domino) as parameters, and
-- returns a Domino.
turnDomino :: Domino -> End -> Board -> Domino
turnDomino d e [] = d
turnDomino d e b  
  | not (isEndP e b) = d
  | not (goesEndsP d b) = d
  | goesLeftP d e && snd d == fst e = d
  | goesRightP d e && fst d == snd e = d
  | otherwise = swap d
-- | The knockingP function determines whether or not a player should knock,
-- based on the contents of their hand and whether or not they can play a
-- domino.
-- It takes a Hand and a Board (both a list of Dominoes) as parameters, and
-- returns a Boolean.
knockingP :: Hand -> Board -> Bool
knockingP h b 
  | null h = True
  | goesEndsP (head h) b = False
  | otherwise = knockingP (tail h) b
-- | The playDom function returns an updated board featuring a given domino, if 
-- that domino can be played at a given end of the board.
playDom :: Domino -> Board -> End -> Maybe Board
playDom d [] _ = Just [d]
playDom d b e 
  | not (isEndP e b) = Nothing
  | goesLeftP d e = Just ((turnDomino d e b) : b)
  | goesRightP d e = Just (b ++ [(turnDomino d e b)])    
  | otherwise = Nothing
-- | The score function returns the fives-and-threes score for two given values.
-- It takes a Domino (int pair), a Board (list of Dominoes), and an End (as 
-- Domino) as parameters, and returns a Maybe Board if a valid move is made.
score :: Int -> Int -> Int
score x y
  | mod (x + y) 15 == 0 = (quot (x + y) 5) + (quot (x + y) 3)
  | mod (x + y) 3 == 0 = quot (x + y) 3
  | mod (x + y) 5 == 0 = quot (x + y) 5
  | otherwise = 0
-- | The scoreDom function returns the score a given domino would give when
-- played at a particular end of a given board. If the domino cannot be played
-- there, 0 is returned.
-- It takes two integer arguments and returns one integer.
scoreDom :: Domino -> Board -> End -> Int
scoreDom (x,y) [] _ = score x y
scoreDom d b e
  | isJust (playDom d b e) = scoreBoard (fromJust (playDom d b e))
  | otherwise = 0
-- | The scoreBoard function scores a given board using the outer dominoes'
-- outer values.
-- It takes a Domino (int pair), a Board (list of Dominoes), and an End (as 
-- Domino) as parameters, and returns an integer.
scoreDouble :: Domino -> Int
scoreDouble (x,y) = x+y
scoreBoard :: Board -> Int
scoreBoard [] = 0
scoreBoard ((x,y):[]) = score x y
scoreBoard (b:bs)
  | (swap b) == b  && (swap (last bs)) == (last bs) = score (scoreDouble b) (scoreDouble (last bs))
  | (swap b) == b = score (scoreDouble b) (snd (last bs))
  | (swap (last bs)) == (last bs) = score (scoreDouble (last bs)) (fst b)
  | otherwise = score (fst b) (snd (last bs))
-- | The possPlays function lists all possible plays from a given hand, grouped
-- by which end of the board they can be played at in a tuple of lists. Note
-- that it takes an empty tuple of lists as the initial argument.
-- It takes a Board (list of Dominoes), and returns an integer.
possPlays :: Hand -> Board -> ([Domino], [Domino]) -> ([Domino], [Domino])
possPlays h [] p = (h,h)
possPlays [] b p = p
possPlays (h:hs) (b:bs) (l,r) 
  | goesBothP h (b:bs) = possPlays hs (b:bs) (h:l, h:r)
  | goesLeftP h (b) = possPlays hs (b:bs) (h:l, r)
  | goesRightP h (last bs) = possPlays hs (b:bs) (l, h:r)
  | otherwise = possPlays hs (b:bs) (l, r)
-- | The scoreN function returns all dominoes that are not yet on the board
-- that, if played, would result in the given score.
-- It takes a Board and an Int representative of the desired score.
-- It returns a list of Dominoes on completion.
scoreNP :: Domino -> Board -> Int -> Bool
scoreNP (x,y) [] s = defaultPositionP (x,y) && score x y == s
scoreNP d b s = let notPlayed = not(playedP d b)
                    scoreHead = scoreDom d b (head b) == s
                    scoreTail = scoreDom d b (last b) == s
                    scoreCorrect = scoreHead || scoreTail
                    goes = goesEndsP d b
                in (notPlayed && scoreCorrect && goes)
scoreN :: Board -> Int -> [Domino]
scoreN [] s = [(x,y) | x <- [0..6], y<- [0..6], score x y == s && defaultPositionP (x,y)]
scoreN b s = [(x,y) | x <- [0..6], y<- [0..6], scoreNP (x,y) b s && defaultPositionP (x,y)]

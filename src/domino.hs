import Data.Maybe
type Domino = (Int, Int)
data End    = L | R deriving (Enum, Eq, Show)
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
playedP :: Domino -> Board -> Bool
playedP d b = elem d b || elem (swap d) b
-- | The goesP function determines whether or not a domino can be played at a 
-- given end of the board.
-- It takes a Domino (int pair) and a Board (list of Dominoes) 
-- as parameters, and returns a Boolean.
getEnd :: End -> Board -> Domino
getEnd e (b:[]) = b
getEnd e (b:bs) 
  | e == L = b
  | e == R = last bs
goesP :: Domino -> End -> Board -> Bool
goesP d _ [] = True
goesP (x,y) e b
  | x>6 || y>6 = False
  | e == L = y == fst(getEnd e b)
  | e == R = x == snd(getEnd e b)
  | otherwise = False
goesSwappedP :: Domino -> End -> Board -> Bool
goesSwappedP d e b = goesP d e b || goesP (swap d) e b
-- | The turnDomino function rotates a domino based on which end of the board
-- it is being played at.
-- It takes a Domino (int pair) and an EndDom (as Domino) as parameters, and
-- returns a Domino.
turnDomino :: Domino -> End -> Board -> Domino
turnDomino d e [] = d
turnDomino d e b  
  | goesP d e b = d
  | goesP (swap d) e b = (swap d)
  | otherwise = d
-- | The knockingP function determines whether or not a player should knock,
-- based on the contents of their hand and whether or not they can play a
-- domino.
-- It takes a Hand and a Board (both a list of Dominoes) as parameters, and
-- returns a Boolean.
knockingP :: Hand -> Board -> Bool
knockingP h b 
  | null h = True
  | goesP (head h) L b = False
  | goesP (head h) R b = False
  | otherwise = knockingP (tail h) b
-- | The playDom function returns an updated board featuring a given domino, if 
-- that domino can be played at a given end of the board.
playDom :: Domino -> End -> Board -> Maybe Board
playDom d _ [] = Just [d]
playDom d e b
  | not ((goesP d e b) || (goesP (swap d) e b)) = Nothing
  | e == L = Just ((turnDomino d e b) : b)
  | e == R = Just (b ++ [(turnDomino d e b)])    
  | otherwise = Nothing
-- | The score function returns the fives-and-threes score for two given values.
-- It takes a Domino (int pair), a Board (list of Dominoes), and an EndDom (as 
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
scoreDom :: Domino -> End -> Board -> Int
scoreDom (x,y) _ [] = score x y
scoreDom d e b
  | isJust (playDom d e b) = scoreBoard (fromJust (playDom d e b))
  | otherwise = 0
-- | The scoreBoard function scores a given board using the outer dominoes'
-- outer values.
-- It takes a Domino (int pair), a Board (list of Dominoes), and an EndDom (as 
-- Domino) as parameters, and returns an integer.
scoreEnds :: Domino -> Domino -> Int
scoreEnds (a,b) (x,y)
  | a == b && x == y = score (x+y) (a+b)
  | a == b = score (a+b) y
  | x == y = score (x+y) a
  | otherwise = score a y
scoreBoard :: Board -> Int
scoreBoard [] = 0
scoreBoard ((x,y):[]) = score x y
scoreBoard (b:bs) = scoreEnds b (last bs)
-- | The possPlays function lists all possible plays from a given hand, grouped
-- by which end of the board they can be played at in a tuple of lists. Note
-- that it takes an empty tuple of lists as the initial argument.
-- It takes a Board (list of Dominoes), and returns an integer.
possPlays :: Hand -> Board -> ([Domino], [Domino]) -> ([Domino], [Domino])
possPlays h [] p = (h,h)
possPlays [] b p = p
possPlays (h:hs) (b:bs) (l,r) 
  | goesP h L (b:bs) && goesP h R (b:bs) = possPlays hs (b:bs) (h:l, h:r)
  | goesP h L (b:bs) = possPlays hs (b:bs) (h:l, r)
  | goesP h R (b:bs) = possPlays hs (b:bs) (l, h:r)
  | otherwise = possPlays hs (b:bs) (l, r)
-- | The scoreN function returns all dominoes that are not yet on the board
-- that, if played, would result in the given score.
-- It takes a Board and an Int representative of the desired score.
-- It returns a list of Dominoes on completion.
-- It uses the scoreNP function to save on verbosity.
-- NOTE: This is the only function to use the goesSwapped helper method as extra verification that a domino can go, as scoreDom returns 0 for invalid moves. I thought it would be less verbose to employ that just once, rather than make scoreDom a Maybe for all its uses.
scoreNP :: Domino -> Board -> Int -> Bool
scoreNP (x,y) [] s = defaultPositionP (x,y) && score x y == s
scoreNP d b s = let notPlayed    = not(playedP d b)
                    scoreHead    = scoreDom d L b == s && goesSwappedP d L b
                    scoreTail    = scoreDom d R b == s && goesSwappedP d R b
                    scoreCorrect = scoreHead || scoreTail
                in (notPlayed && scoreCorrect)
scoreN :: Board -> Int -> [Domino]
scoreN [] s = [(x,y) | x <- [0..6], y<- [0..6], score x y == s && defaultPositionP (x,y)]
scoreN b s = [(x,y) | x <- [0..6], y<- [0..6], scoreNP (x,y) b s && defaultPositionP (x,y)]

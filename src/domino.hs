import Data.Maybe
type Domino = (Int, Int)
type End = Domino
type Hand   = [Domino]
type Board  = [Domino]
-- | The swap function emulates rotating a domino by swapping the values in its 
-- tuple.
-- It takes a Domino (int pair) as an argument, and returns the same type.
swap :: Domino -> Domino
swap d = (snd d, fst d)
-- | The playedP function determines whether a domino is on a given board in
-- either possible rotation.
-- It takes a Domino (int pair) as a parameter, and returns the same type.
playedP :: Domino -> Board -> Bool
playedP d b = elem d b || elem (swap d) b
-- | The goesLeftP function determines whether a domino can be played in either configuration at the left side of the board.
goesLeftP :: Domino -> End -> Bool
goesLeftP d e = snd d == fst e || snd (swap d) == fst e
-- | The goesRightP function determines whether a domino can be played in either configuration at the right side of the board.
goesRightP :: Domino -> End -> Bool
goesRightP d e = fst d == snd e || fst (swap d) == snd e
-- | TODO
goesEnds :: Domino -> Board -> (Bool, Bool)
goesEnds _ [] = (True, True)
goesEnds d b = let left = goesLeftP d (head b) 
                   right = goesRightP d (last b) 
                in ((left, right))
-- | The goesP function determines whether or not a domino can be played at a 
-- given end of the board.
-- It takes a Domino (int pair) and a Board (list of Dominoes) 
-- as parameters, and returns a Boolean.
goesP :: Domino -> End -> Board -> Bool
goesP d _ [] = True
goesP d e b
  | e == (head b) && e == (last b) = fst(goesEnds d b) || snd(goesEnds d b)
  | e == (head b) = fst(goesEnds d b)
  | e == (last b) = snd(goesEnds d b)
  | otherwise = False
-- | The turnDomino function rotates a domino based on which end of the board
-- it is being played at.
-- It takes a Domino (int pair) and an End (as Domino) as parameters, and returns a Domino.
turnDomino :: Domino -> End -> Board -> Domino
turnDomino d e [] = d
turnDomino d e b  
  | fst(goesEnds d b) && snd d == fst e = d
  | snd(goesEnds d b) && fst d == snd e = d
  | otherwise = swap d
-- | The knockingP function determines whether or not a player should knock,
-- based on the contents of their hand and whether or not they can play a
-- domino.
-- It takes a Hand and a Board (both a list of Dominoes) as parameters, and
-- returns a Boolean.
knockingP :: Hand -> Board -> Bool
knockingP h b = if null h
                   then True
                   else (if goesP (head h) (head b) b || 
                            goesP (head h) (last b) b
                            then False
                            else knockingP (tail h) b)
-- | The playDom function returns an updated board featuring a given domino, if 
-- that domino can be played at a given end of the board.
playDom :: Domino -> Board -> End -> Maybe Board
playDom d [] _ = Just [d]
playDom d b e 
  | fst(goesEnds d b) = Just ((turnDomino d e b) : b)
  | snd(goesEnds d b) = Just (b ++ [(turnDomino d e b)])    
  | otherwise = Nothing
-- | The score function returns the fives-and-threes score for two given values.
-- It takes a Domino (int pair), a Board (list of Dominoes), and an End (as 
-- Domino) as parameters, and returns a Maybe Board if a valid move is made.
score :: Int -> Int -> Int
score x y = if mod (x + y) 3 == 0
               then quot (x + y) 3
               else (if mod (x + y) 5 == 0
                        then quot (x + y) 5
                        else 0)
-- | The scoreDom function returns the score a given domino would give when
-- played at a particular end of a given board. If the domino cannot be played
-- there, 0 is returned.
-- It takes two integer arguments and returns one integer.
scoreDom :: Domino -> Board -> End -> Int
scoreDom d b e = if isJust (playDom d b e)
                    then scoreBoard (fromJust (playDom d b e))
                    else 0
-- | The scoreBoard function scores a given board using the outer dominoes'
-- outer values.
-- It takes a Domino (int pair), a Board (list of Dominoes), and an End (as 
-- Domino) as parameters, and returns an integer.
scoreBoard :: Board -> Int
scoreBoard [] = 0
scoreBoard b = score (fst (head b)) (snd (last b))
-- | The possPlays function lists all possible plays from a given hand, grouped
-- by which end of the board they can be played at in a tuple of lists. Note
-- that it takes an empty tuple of lists as the initial argument.
-- It takes a Board (list of Dominoes), and returns an integer.
possPlays :: Hand -> Board -> ([Domino], [Domino]) -> ([Domino], [Domino])
possPlays [] b p = p
possPlays h b p 
  | fst(goesEnds (head h) b) && snd(goesEnds (head h) b) = possPlays (tail h) b (head h:fst p, head h:snd p)
  | fst(goesEnds (head h) b) = possPlays (tail h) b (head h:fst p, snd p)
  | snd(goesEnds (head h) b) = possPlays (tail h) b (fst p, head h:snd p)
  | otherwise = possPlays (tail h) b (fst p, snd p)
-- | The scoreN function returns all dominoes that are not yet on the board
-- that, if played, would result in the given score.
-- It takes a Board and an Int representative of the desired score.
-- It returns a list of Dominoes on completion.
scoreNP :: Domino -> Board -> Int -> Bool
scoreNP d [] s = ((fst d)<=(snd d)) && ((score (fst d) (snd d)) == s)
scoreNP d b s = let notPlayed = not(playedP d b)
                    scoreHead = scoreDom d b (head b) == s
                    scoreTail = scoreDom d b (last b) == s
                    scoreCorrect = scoreHead || scoreTail
                    notDuplicate = (fst d)<=(snd d)
                    goesEndsRes = goesEnds d b
                    goes = fst(goesEndsRes) || snd(goesEndsRes)
                 in (notPlayed && scoreCorrect && notDuplicate && goes)
scoreN :: Board -> Int -> [Domino]
scoreN [] s = [(x,y) | x <- [0..6], y<- [0..6], x<=y && score x y == s]
scoreN b s = [(x,y) | x <- [0..6], y<- [0..6], scoreNP (x,y) b s]

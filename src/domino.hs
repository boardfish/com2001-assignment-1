import Data.Maybe
type Domino = (Int, Int)
type End = Domino
type Hand   = [Domino]
type Board  = [Domino]
-- Not sure if this is the fix but...
swap :: Domino -> Domino
swap d = (snd d, fst d)
playedP :: Domino -> Board -> Bool
playedP d b = elem d b || elem (swap d) b
goesP :: Domino -> End -> Board -> Bool
goesP d e b = if e == (last b)
                 then (fst d) == (snd e) || (snd d) == (snd e)
                 else (fst d) == (fst e) || (snd d) == (fst e)
turnDomino :: Domino -> End -> Board -> Domino
turnDomino d e b = if e == (last b) 
                      then (if fst d == snd e
                               then d
                               else swap d)
                      else (if snd d == fst e
                               then d
                               else swap d)
knockingP :: Hand -> Board -> Bool
knockingP h b = if null h
                   then True
                   else (if goesP (head h) (head b) b || 
                            goesP (head h) (last b) b
                            then False
                            else knockingP (tail h) b)
playDom :: Domino -> Board -> End -> Maybe Board
playDom d b e = if goesP d e b && elem e b
                   then (if e == (head b)
                            then Just ((turnDomino d e b) : b)
                            else Just (b ++ [(turnDomino d e b)]))
                   else Nothing
score :: Int -> Int -> Int
score x y = if mod (x + y) 3 == 0
               then quot (x + y) 3
               else (if mod (x + y) 5 == 0
                        then quot (x + y) 5
                        else 0)
scoreDom :: Domino -> Board -> End -> Int
scoreDom d b e = if isJust (playDom d b e)
                    then scoreBoard (fromJust (playDom d b e))
                    else 0
scoreBoard :: Board -> Int
scoreBoard b = score (fst (head b)) (snd (last b))
possPlays :: Hand -> Board -> ([Domino], [Domino]) -> ([Domino], [Domino])
possPlays [] b p = p
possPlays h b p = if goesP (head h) (head b) b 
                     then possPlays (tail h) b (head h:fst p, snd p)
                     else (if goesP (head h) (last b) b
                            then possPlays (tail h) b (fst p, head h:snd p)
                            else possPlays (tail h) b (fst p, snd p))
-- Comically missed the point here.
scoreN :: Board -> Int -> [Domino]
scoreN b s = [(x,y) | x <- [0..6], y<- [0..6], not(elem (x,y) b) && (scoreDom (x,y) b (head b) == s || scoreDom (x,y) b (last b) == s)]

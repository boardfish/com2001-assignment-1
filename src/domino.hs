type Domino = (Int, Int)
type End = Domino
type Hand   = [Domino]
type Board  = [Domino]
-- Not sure if this is the fix but...
swap :: Domino -> Domino
swap d = (snd d, fst d)
playedP :: Domino -> Board -> Bool
playedP d b = elem d b
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
playDom :: Domino -> Board -> End -> Maybe [Domino]
playDom d b e = if goesP d e b && elem e b
                   then (if e == (head b)
                            then Just ((turnDomino d e b) : b)
                            else Just (b ++ [(turnDomino d e b)]))
                   else Nothing
scoreBoard :: Board -> Int
scoreBoard b = if mod (fst (head b) + snd (last b)) 3 == 0
                  then quot ((fst (head b)) + (snd (last b))) 3
                  else (if mod (fst (head b) + snd (last b)) 5 == 0
                           then quot ((fst (head b)) + (snd (last b))) 5
                           else 0)
-- PSEUDOCODE (ideas) for functions to come
-- possPlays :: Hand -> Board -> Domino
-- possPlays h b = if goesP (head h) (head b) b || goesP (head h) (last b) b
--                    then head h
--                    else null
-- RETURN TYPE SHOULD BE A PAIR
scoreN :: Board -> Int -> [Domino]
scoreN b s = [(x,y) | x <- [0..6], y<- [0..6], not(elem (x,y) b) && mod (x+y) s == 0]

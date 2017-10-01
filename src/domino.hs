type Domino = (Int, Int)
type End = Domino
type Hand   = [Domino]
type Board  = [Domino]
playedP :: Domino -> Board -> Bool
playedP d b = elem d b
goesP :: Domino -> End -> Board -> Bool
goesP d e b = if e == (last b)
                 then (fst d) == (snd e) || (snd d) == (snd e)
                 else (fst d) == (fst e) || (snd d) == (fst e)
knockingP :: Hand -> Board -> Bool
knockingP h b = if null h
                   then True
                   else (if goesP (head h) (head b) b
                            then False
                            else (if goesP (head h) (last b) b
                                    then False
                                    else knockingP (tail h) b))
-- PSEUDOCODE (ideas) for functions to come
-- possPlays :: Hand -> Board -> Domino
-- possPlays h b = if null h
--                    then Null
--                    else (if null b
--                             then h
--                             else (0,0))
-- RETURN TYPE SHOULD BE A PAIR
-- playDom :: Domino -> Board -> End -> Board
-- playDom d b e = if goesP d e b
--                    then (if e == (head b)
--                             then -- add to start of board
--                             else -- add to end of board)
-- RETURN TYPE SHOULD BE A MAYBE
scoreBoard :: Board -> Int
scoreBoard b = if mod (fst (head b) + snd (last b)) 3 == 0
                  then quot ((fst (head b)) + (snd (last b))) 3
                  else (if mod (fst (head b) + snd (last b)) 5 == 0
                           then quot ((fst (head b)) + (snd (last b))) 5
                           else 0)

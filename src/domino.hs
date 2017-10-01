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
possPlays :: Hand -> Board -> Domino
possPlays h b = if null h
                   then "end"
                   else goesP (head b) 

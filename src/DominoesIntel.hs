module DomsIntel where
    import DomsMatch
    import Data.List
    import Data.Maybe
    import Debug.Trace
    type Tactic = DomsPlayer
    -- | The swap function emulates flipping a Dom by swapping the number of 
    -- spots on each side.
    swap :: Dom -> Dom
    swap (x,y) = (y,x)
    -- | The otherPlayer function determines the current Player's opponent 
    -- regardless of which side they're on.
    otherPlayer :: Player -> Player
    otherPlayer p
      | p == P1 = P2
      | p == P2 = P1
    -- | The handToSpots function converts a Hand to a List of the number of 
    -- spots on either side of every Dom in the Hand.
    handToSpots :: Hand -> [Int]
    handToSpots [] = []
    handToSpots ((x,y):hs) = sort (x : y : handToSpots hs)
    -- | The count function counts the occurrences of a given item in a given 
    -- List. It is used in countSpots to determine the most frequent number of 
    -- spots in the Hand.
    count :: Eq a => a -> [a] -> Int
    count x = length . filter (x==)
    -- | deleteAllInstances is a helper function for countSpots. After counting
    -- the number of occurrences of a number of Spots, the function repeats with
    -- the next value. deleteAllInstances is used to delete all instances of the
    -- number that has just been counted.
    deleteAllInstances :: Eq a => a -> [a] -> [a]
    deleteAllInstances a xs = filter (/= a) xs
    -- | countSpots takes a list of Int, meant to be the number of spots on each
    -- side of every Dom in the hand, and returns a List of length 7. Each index
    -- is representative of the frequency of that number of dots in the Hand.
    countSpots :: Int -> [Int] -> [Int]
    countSpots 7 l = []
    countSpots y l = count y l : countSpots (y+1) (deleteAllInstances y l)
    -- | countHandSpots takes a Hand and returns a List of Int pairs, where the
    -- first element represents an amount of spots and the second is its
    -- frequency in the Hand.
    countHandSpots :: Hand -> [(Int, Int)]
    countHandSpots h = zip [0..6] (countSpots 0 (handToSpots h))
    -- | The maxSpots function is a wrapper for countHandSpots that sorts its
    -- return by the frequency of each element.
    maxSpots :: Hand -> [(Int, Int)]
    maxSpots h = reverse (sortBy (comparing $ snd) (countHandSpots h))
    -- | The rebuildBoard function converts a DomBoard to a List with total 
    -- disregard for order. Purely for inspecting the board state with regard to 
    -- what dominoes are played.
    rebuildBoard :: DomBoard -> Hand
    rebuildBoard InitBoard = []
    rebuildBoard (Board _ _ []) = []
    rebuildBoard (Board l r ((d,_,_):his)) = (d : rebuildBoard (Board l r his))
    turnNumber :: (Dom,Player,Int) -> Int
    turnNumber (_,_,turn) = turn
    sortHistory :: DomBoard -> DomBoard
    sortHistory InitBoard = InitBoard
    sortHistory (Board l r his) = (Board l r (reverse (sortBy (comparing $ turnNumber) (his))))
    stepBack :: DomBoard -> DomBoard
    stepBack InitBoard = InitBoard
    stepBack (Board _ _ (his:[])) = InitBoard
    stepBack (Board l r his)   
     |playedLeft = (Board l2tDom r (hist ++ [(l2tDom,l2tP,l2tNum)]))
     |otherwise = (Board l l2tDom (hist ++ [(l2tDom,l2tP,l2tNum)]))
     where 
         (Board l r sortedHistory) = sortHistory (Board l r his)
         ( (ltDom,_,_) : (l2tDom,l2tP,l2tNum) : reverseHist) = sortedHistory
         playedLeft = ltDom == l || (swap ltDom) == l 
         hist = reverse (reverseHist)
    checkKnocking :: [Int] -> Player -> DomBoard -> [Int]
    checkKnocking acc p InitBoard = acc
    checkKnocking acc p (Board l r (turn:[])) = acc
    checkKnocking acc p (Board l r hist)
      | p1 /= p2 = checkKnocking acc p (stepBack (Board l r hist))
      | p1 /= p = checkKnocking acc p (stepBack (Board l r hist))
      | otherwise = checkKnocking (lastL : lastR : acc) p (stepBack (Board l r hist))
     where (Board (lastL,_) (_,lastR) lastHist) = stepBack (Board l r hist)
           ((lDom, p1, s1):(l2Dom, p2, s2):remHist) = reverse hist
    unplayedDoms :: Hand -> DomBoard -> Hand
    -- Assumes all doms in hand are highest no. first
    unplayedDoms h InitBoard = filter (\x -> not (elem x h)) domSet 
    unplayedDoms h b = filter (\x -> not (elem x h || elem x board || elem (swap x) board)) domSet 
        where 
            board = rebuildBoard b
    firstMove :: Tactic
    firstMove h InitBoard p s
      | elem (5,4) h = ((5,4),L)
      | otherwise = clearOut h InitBoard p s 
    firstMove h b p s = clearOut h b p s
    strongestCommonDom :: Hand -> [(Int,Int)] -> DomBoard -> (Dom,End)
    strongestCommonDom [] _ _ = ((0,0),L)
    strongestCommonDom h [] _ = ((0,0),L)
    strongestCommonDom h ((mfs,f):mfsl) b = if not (s == -1) 
                                               then (d,e) 
                                               else strongestCommonDom h mfsl b
        where sortedHand = filter (\(x,y) -> x==mfs || y==mfs) h
              (d,e,s) = hsd sortedHand b 
    -- | clearOut tactic
    -- Prioritises dominoes for which the number of spots on a side is most 
    -- frequent in the hand. The tactic doesn't entirely "clear out" that number
    -- of spots from the hand by design, choosing to reserve those with lesser
    -- amounts so as to cover its back in future.
    -- This tactic gives a roughly 38% win rate when used while the player has 
    -- the lead, with hsd as fallback when the player is losing.
    clearOut :: Tactic
    clearOut h b p s = strongestCommonDom h (maxSpots h) b
    -- | getPlayerScore is a function that normalises a Scores pair to put the
    -- current player first.
    getPlayerScore :: Player -> (Int,Int) -> (Int,Int)
    getPlayerScore p (p1s,p2s)
      | p == P1 = (p1s,p2s)
      | otherwise = (p2s,p1s)
    -- | intelligentPlayer employs three Tactics situationally - hsd, which 
    -- chooses the highest scoring Dom, clearOut, which chooses a Dom with the
    -- most frequent number of spots on either side, and target53, which closes
    -- in on 61 from 53.
    intelligentPlayer :: DomsPlayer
    intelligentPlayer h b p s
      | ps > 53 = trace "TARGET 57" target53 h b p s
      | ps >= os = trace "CLEAR OUT" clearOut h b p s
      | otherwise = trace "HIGH SCORE" hsdPlayer h b p s
      where (ps,os) = getPlayerScore p s 
    -- | scoreExactly returns all Doms in a Hand that would score N on a given
    -- board.
    scoreExactly :: Int -> Hand -> DomBoard -> Hand
    scoreExactly n h b = h `intersect` scoreN b n
    -- | scoreOrLess returns all Doms in a Hand that would score N or less. If
    -- this isn't possible, it loops back around to get Doms that would score
    -- more than the starting amount s.
    -- s - initial score
    -- n - iterator (start same as s)
    -- h - hand
    -- b - board
    scoreOrLess :: Int -> Int -> Hand -> DomBoard -> Hand
    scoreOrLess _ _ [] _ = []
    scoreOrLess s (-1) h b = scoreOrLess s 8 h b
    scoreOrLess s n h b 
      | n == (s+1) = scoreExactly n h b
      | not (null validDoms) = validDoms
      | otherwise = scoreOrLess s (n-1) h b
      where validDoms = scoreExactly n h b
    -- | target53 is a tactic that searches for a Dom that can close the
    -- gap between the player's current score and 61.
    target53 :: Tactic
    target53 h b p s
        | not (goesRP d b) = (d,L)
        | not (goesLP d b) = (d,R)
        | scoreLeft >= scoreRight= (d,L)
        | otherwise = (d,R)
        where scoreLeft = scoreDom d L b
              scoreRight = scoreDom d R b
              (ps,_) = getPlayerScore p s
              (d:ds) = scoreOrLess (61-ps) (61-ps) h b 
    -- | guessDomsInPlay is a function that uses the board history to determine
    -- which dominoes are unplayed.
    guessDomsInPlay :: Player -> Hand -> DomBoard -> Hand
    guessDomsInPlay p h b = let unplayed = unplayedDoms h b
                                knocking = checkKnocking [] p b
                             in filter (\(x,y) -> not (elem x knocking || elem y knocking)) unplayed
    -- | canWin determines whether a player can directly close the gap between 
    -- their current score and 61 in a single move.
    canWin :: Hand -> DomBoard -> Player -> Scores -> Bool
    canWin h b p s
      | ps < 53 = False
      | otherwise = True --TODO
      where (ps,_) = getPlayerScore p s
            scoreDifference = 61-ps
    -- | scoreDomSF is a secondary implementation of scoreDom that returns -1
    -- for invalid moves, rather than downright objecting as scoreDom does.
    scoreDomSF :: Dom -> End -> DomBoard -> Int
    scoreDomSF d e b
      | isJust (playDom P1 d e b) = scoreboard (fromJust (playDom P1 d e b))
      | otherwise = (-1) -- move not possible
    scoreNP :: Dom -> DomBoard -> Int -> Bool
    scoreNP d b s = let scoreHead    = scoreDomSF d L b == s
                        scoreTail    = scoreDomSF d R b == s
                    in scoreHead || scoreTail 
    -- | The scoreN function returns all dominoes that are not yet on the board
    -- that, if played, would result in the given score.
    -- It takes a Board and an Int representative of the desired score.
    -- It returns a list of Dominoes on completion.
    -- It uses the scoreNP function to save on verbosity.
    -- | Please see the documentation for scoreNP, as these two functions 
    -- should be considered collectively.
    scoreN :: DomBoard -> Int -> Hand
    scoreN b s = [(x,y) | x <- [0..6], y<- [0..6], scoreNP (x,y) b s && x>=y]

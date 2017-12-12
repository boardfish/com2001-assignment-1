module DomsIntel where
    import DomsMatch
    import Data.List
    import Data.Maybe
    import Debug.Trace
    type Tactic = DomsPlayer

    -- | intelligentPlayer employs six Tactics situationally: 
    -- clearOut - chooses a Dom with the most frequent number of spots on either 
    -- side, 
    -- target53 - chooses a Dom that gets the player as close to 61 as possible
    -- denyMoves - uses what the opponent is knocking on to deny them a turn
    -- denyAllMoves - uses all unplayed doms as a basis for denying a turn
    -- hsd - inherits from hsdPlayer as a final fallback when on the back foot
    intelligentPlayer :: DomsPlayer
    intelligentPlayer h b p s
      | canWin h b p s = trace "FOR THE WIN" forTheWin h b p s
      | canDenyAllMoves h b p = trace "DENY ALL MOVES" denyAllMoves h b p s
      | canDenyMoves h b p = trace "DENY MOVES" denyMoves h b p s
      | ps > 53 = trace "TARGET 53" target53 h b p s
      | ps >= os = trace "CLEAR OUT" clearOut h b p s
      | otherwise = trace "----------" hsdPlayer h b p s
      where (ps,os) = getPlayerScore p s 

    --------------------
    --HELPER FUNCTIONS--
    --------------------

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

    -----------
    --MAXSPOTS--
    ------------

    -- | countSpots takes a list of Int, meant to be the number of spots on each
    -- side of every Dom in the hand, and returns a List of length 7. Each index
    -- is representative of the frequency of that number of dots in the Hand.
    countSpots :: Int -> [Int] -> [Int]
    countSpots 7 l = []
    countSpots y l = count y l : countSpots (y+1) (deleteAllInstances y l)

    -- | The handToSpots function converts a Hand to a List of the number of 
    -- spots on either side of every Dom in the Hand.
    handToSpots :: Hand -> [Int]
    handToSpots [] = []
    handToSpots ((x,y):hs) = sort (x : y : handToSpots hs)
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
    -- In the default ordering of a Board, this will return Boards as they were
    -- represented in previous stages of the assignment. Otherwise, it returns
    -- all Doms on the Board as the equivalent of a Hand - unordered.
    rebuildBoard :: DomBoard -> Hand
    rebuildBoard InitBoard = []
    rebuildBoard (Board _ _ []) = []
    rebuildBoard (Board l r ((d,_,_):his)) = (d : rebuildBoard (Board l r his))

    -- | turnNumber isolates the turnNumber from an item of the board History.
    turnNumber :: (Dom,Player,Int) -> Int
    turnNumber (_,_,turn) = turn

    -- | unplayedDoms returns all Doms that are not in the given Hand or on the
    -- given Board.
    unplayedDoms :: Hand -> DomBoard -> Hand
    -- Assumes all doms in hand are highest no. first
    unplayedDoms h InitBoard = filter (\x -> not (elem x h)) domSet 
    -- TODO: Neaten
    unplayedDoms h b = filter (\x -> not (elem x h || elem x board || elem (swap x) board)) domSet 
        where 
            board = rebuildBoard b

    -- | firstMove uses (5,4) on an empty board if possible, or makes a strong
    -- first move otherwise.
    -- TODO
    -- firstMove :: Tactic
    -- firstMove h InitBoard p s
    --   | elem (5,4) h = ((5,4),L)
    --   | otherwise = hsdPlayer h InitBoard p s 
    -- firstMove h b p s = intelligentPlayer h b p s

    -- | strongestCommonDom finds the highest-scoring dom that has the most
    -- frequent number of spots.
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
    -- It's primarily a wrapper for strongestCommonDom, as that uses an
    -- accumulator array.
    clearOut :: Tactic
    clearOut h b p s = strongestCommonDom h (maxSpots h) b

    -- | getPlayerScore is a function that normalises a Scores pair to put the
    -- current player first.
    getPlayerScore :: Player -> (Int,Int) -> (Int,Int)
    getPlayerScore p (p1s,p2s)
      | p == P1 = (p1s,p2s)
      | otherwise = (p2s,p1s)

    ------------------------------------
    --COUNTERPLAYS AGAINST KNOWN HANDS--
    ------------------------------------

    -- | sortHistory sorts a given DomBoard's History by turn number, as opposed
    -- to the default ordering of the actual board state.
    sortHistory :: DomBoard -> DomBoard
    sortHistory InitBoard = InitBoard
    sortHistory (Board l r his) = (Board l r sortedHist)
        where sortedHist = (reverse (sortBy (comparing $ turnNumber) (his)))
    
    -- | stepBack takes a DomBoard a single step back in its history. Other
    -- functions make use of this recursively as necessary.
    stepBack :: DomBoard -> DomBoard
    stepBack InitBoard = InitBoard
    stepBack (Board _ _ (his:[])) = InitBoard
    stepBack (Board l r hist)   
     |playedLeft = (Board lastLeft r leftHist)
     |otherwise = (Board l lastRight rightHist)
     where 
         playedLeft = turnNumber (head hist) > turnNumber (last hist)
         leftHist = tail hist
         (lastLeft,_,_) = head (leftHist)
         rightHist = reverse (tail (reverse hist))
         (lastRight,_,_) = last (rightHist)

    -- | filterSpots removes all Doms from the given Hand that have any number
    -- of spots listed in the given list s.
    filterSpots :: Hand -> [Int] -> Hand
    filterSpots [] _ = []
    filterSpots h [] = h
    filterSpots h s = filter (\(x,y) -> not (elem x s || elem y s)) h

    -- | The drops function returns all doms in the given Hand that can be 
    -- played on the given Board. In keeping with leftdrops and rightdrops, it's 
    -- named simply 'drops'.
    drops :: Hand->DomBoard->Hand
    drops h b = filter (\d -> goesRP d b || goesLP d b) h 

    -- | checkKnocking returns all spot counts for which the given player's 
    -- opponent is knocking.
    checkKnocking :: [Int] -> Player -> DomBoard -> [Int]
    checkKnocking acc p InitBoard = acc
    checkKnocking acc p (Board l r (turn:[])) = acc
    checkKnocking acc p b
      | p1 /= p2 = checkKnocking acc p (stepBack b) --other play responded
      | p1 /= p = checkKnocking acc p (stepBack b) --home player knocked
      | otherwise = checkKnocking (lastL : lastR : acc) p (stepBack b)
     where (Board (lastL,_) (_,lastR) _) = stepBack b
           (Board _ _ ((lDom, p1, _):(l2Dom, p2, _):_)) = sortHistory b

    -- | guessDomsInPlay is a function that uses the board history to determine
    -- which dominoes are unplayed.
    guessDomsInPlay :: Player -> Hand -> DomBoard -> Hand
    guessDomsInPlay p h b = let unplayed = unplayedDoms h b
                                knocking = checkKnocking [] (otherPlayer p) b
                             in filterSpots unplayed knocking

    -- | The canDenyMoves predicate checks if the player is able to directly 
    -- deny the opposing player a move, using the history to check when they 
    -- knocked.
    canDenyMoves :: Hand -> DomBoard -> Player -> Bool
    canDenyMoves h b p = 
        let knocks = checkKnocking [] (otherPlayer p) b
            possplays = drops (filterSpots h knocks) b
         in not (null possplays)

    -- | The denyMoves tactic plays a Dom with a number of spots that their 
    -- opponent cannot respond to, based on the player's knowledge of End values 
    -- on which the opponent is knocking.
    denyMoves :: Tactic
    denyMoves h b p s = trace (show knocks ++ " " ++ show b) (d,e)
        where (d,e,_) = hsd (filterSpots h knocks) b
              knocks = checkKnocking [] (otherPlayer p) b

    -- | The denyAllMoves tactic plays a domino with a number of spots that their 
    -- opponent cannot respond to. It is used when the player knows they have
    -- the power to do this, as they can counter any Dom, whether in the
    -- opponent's Hand or sleeping.
    denyAllMoves :: Tactic
    denyAllMoves h b p s = (d,e)
        where (d,e,_) = hsd (filterSpots h domsInPlay) b
              domsInPlay = handToSpots (guessDomsInPlay p h b)
    
    -- | The canDenyMoves predicate checks if the player is able to indirectly 
    -- deny the opposing player a move, using the history to check when they 
    -- knocked and which dominoes they potentially could have.
    canDenyAllMoves :: Hand -> DomBoard -> Player -> Bool
    canDenyAllMoves h b p = 
        let domsInPlay = handToSpots (guessDomsInPlay p h b)
            possplays = drops (filterSpots h domsInPlay) b
         in not (null possplays)

    -----------------
    --ENDGAME MOVES--
    -----------------

    -- | scoreDomSF is a secondary implementation of scoreDom that returns -1
    -- for invalid moves, rather than downright objecting as scoreDom does.
    scoreDomSF :: Dom -> End -> DomBoard -> Int
    scoreDomSF d e b
      | isJust (playDom P1 d e b) = scoreboard (fromJust (playDom P1 d e b))
      | otherwise = (-1) -- move not possible

    -- | The scoreN function returns all dominoes that, if played, would result 
    -- in the given score.
    -- It takes a Board and an Int representative of the desired score.
    -- It returns a list of Dominoes on completion.
    -- It uses the scoreNP function to save on verbosity, so the two are
    -- combined below.
    scoreNP :: Dom -> DomBoard -> Int -> Bool
    scoreNP d b s = let scoreHead    = scoreDomSF d L b == s
                        scoreTail    = scoreDomSF d R b == s
                    in scoreHead || scoreTail 

    scoreN :: DomBoard -> Int -> Hand
    scoreN b s = [(x,y) | x <- [0..6], y<- [0..6], scoreNP (x,y) b s && x>=y]
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

    -- | canWin determines whether a player can directly close the gap between 
    -- their current score and 61 in a single move.
    canWin :: Hand -> DomBoard -> Player -> Scores -> Bool
    canWin h b p s = not (null (scoreExactly (61-ps) h b))
      where (ps,_) = getPlayerScore p s

    -- | forTheWin plays the winning domino.
    forTheWin :: Tactic
    forTheWin h b p s = (d,e)
      where (ps,_) = getPlayerScore p s
            (d,e,_) = hsd (scoreExactly (61-ps) h b) b

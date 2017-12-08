module DomsIntel where
    import DomsMatch
    import Data.List
    type Tactic = DomsPlayer
    swap :: Dom -> Dom
    swap (x,y) = (y,x)
    otherPlayer :: Player -> Player
    otherPlayer p
      | p == P1 = P2
      | p == P2= P1
    handToSpots :: Hand -> [Int]
    handToSpots [] = []
    handToSpots ((x,y):hs) = sort (x : y : handToSpots hs)
    count :: Eq a => a -> [a] -> Int
    count x = length . filter (x==)
    deleteAllInstances :: Eq a => a -> [a] -> [a]
    deleteAllInstances a xs = filter (/= a) xs
    countSpots :: Int -> [Int] -> [Int]
    countSpots 7 l = []
    countSpots y l = count y l : countSpots (y+1) (deleteAllInstances y l)
    countHandSpots :: Hand -> [(Int, Int)]
    countHandSpots h = zip [0..6] (countSpots 0 (handToSpots h))
    -- | The maxSpots function returns a list of tuples, where the first element
    -- is the number of spots in question and the second element is the number
    -- of times this spot amount appears on dominoes in the hand.
    maxSpots :: Hand -> [(Int, Int)]
    maxSpots h = reverse (sortBy (comparing $ snd) (countHandSpots h))
    -- TODO
    -- matchSpots :: Hand -> Int -> Hand
    -- matchSpots h i = let ((mfs,mfs2):mfsl) = maxSpots h
    --                      sortedHand = filter (\(x,y) -> x==mostFrequentSpots || y==mostFrequentSpots) h
    --                      (d,e,_) = if length sortedHand == 0 matchSpots sortedHand b else hsd h b
    --                   in (d, e)
    -- The rebuildBoard function converts a DomBoard to a Hand with total disregard for order.
    rebuildBoard :: DomBoard -> Hand
    rebuildBoard InitBoard = []
    rebuildBoard (Board _ _ []) = []
    rebuildBoard (Board l r ((d,_,_):his)) = (d : rebuildBoard (Board l r his))
    stepBack :: DomBoard -> DomBoard
    stepBack InitBoard = InitBoard
    stepBack (Board _ _ (his:[])) = InitBoard
    stepBack (Board l r his)   
     |playedLeft = (Board l2tDom r (hist ++ [(l2tDom,l2tP,l2tNum)]))
     |otherwise = (Board l l2tDom (hist ++ [(l2tDom,l2tP,l2tNum)]))
     where 
      ( (ltDom,_,_) : (l2tDom,l2tP,l2tNum) : reverseHist) = reverse (his)
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
      | otherwise = clearOut h InitBoard p s -- TODO: Swap this for Clear Out
    firstMove h (Board l r hist) p s = clearOut h (Board l r hist) p s -- TODO: Swap this for Clear Out
    clearOut :: Tactic
    clearOut h b p s
      | not(null sortedHand) = let (d,e,_) = hsd sortedHand b in (d,e)
      | otherwise = let (d,e,_) = hsd h b in (d,e)
       where 
        ((mfs,f):mfsl) = maxSpots h
        sortedHand = filter (\(x,y) -> x==mfs || y==mfs) h


    -- guessDomsInPlay :: Hand -> History -> Hand
    -- guessDomsInPlay = filteredHand where
    --     unplayed = unplayedDoms

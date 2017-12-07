module DominoesIntel where
    import DomsMatch
    import Data.List
    type Tactic = DomsPlayer
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
    -- unplayedDoms :: Hand -> DomBoard -> Hand
    -- unplayedDoms h b = (domSet \\ b) \\ h
    firstMove :: Tactic
    firstMove h db p s
      | elem (5,4) h = ((5,4),L)
      | otherwise = hsdPlayer h db p s -- TODO: Swap this for Clear Out
    clearOut :: Tactic
    clearOut h b p s = let ((mostFrequentSpots,_):_) = maxSpots h
                           (d,e,_) = hsd (filter (\(x,y) -> x==mostFrequentSpots || y==mostFrequentSpots) h) b
                         in (d, e)

module DominoesIntel where
    import Dominoes
    import DominoesGame
    import Data.List
    handToSpots :: Hand -> [Int]
    handToSpots [] = []
    handToSpots ((x,y):hs) = sort (x : y : handToSpots hs)
    count :: Eq a => a -> [a] -> Int
    count x = length . filter (x==)
    deleteAllInstances :: Eq a => a -> [a] -> [a]
    deleteAllInstances a xs = filter (/= a) xs
    countSpots :: Int -> [Int] -> [Int]
    countSpots _ [] = []
    countSpots 7 l = l
    countSpots y l = count y l : countSpots (y+1) (deleteAllInstances y l)
    countHandSpots :: Hand -> [Int]
    countHandSpots h = countSpots 0 (handToSpots h)

-- For each item in the list,
--     check its number and
--         add one to that index of the list

module DominoesIntel where
    import Dominoes
    import DominoesGame
    import Data.List
    countSpots :: Hand -> [Int]
    countSpots ((x,y):xs) = x : y : countSpots xs
    countSpots _          = []
    count :: Eq a => a -> [a] -> Int
    count x = length . filter (x==)
    -- countSpots [] = [0,0,0,0,0,0,0]
    -- countSpots h = map (\(x,y) -> [x,y]) h

module DominoesGame where
import Dominoes
import System.Random
shuffleDoms :: Int -> [Domino]
shuffleDoms seed =  
        let randomList = take 28 (randoms (mkStdGen seed) :: [Int])
            dominoList = [(x,y) | x <- [0..6], y<- [0..6], defaultPositionP (x,y)]
            zippedList = zip dominoList randomList
            -- sortedList = mergesort (\(_,n1) (_,n2)->n1<n2) dominoList
        -- in (map fst sortedList)

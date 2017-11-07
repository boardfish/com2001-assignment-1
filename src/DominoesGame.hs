module DominoesGame where
import Dominoes
import MergeSort
import System.Random 
type DomsPlayer = Hand -> Board -> (Domino, End)
genAllDoms :: [Domino]
genAllDoms = [(x,y) | x <- [0..6], y <- [0..6], defaultPositionP (x,y)]
shuffleDoms :: Int -> [Domino]
shuffleDoms seed =  
        let randomList = take 28 (randoms (mkStdGen seed) :: [Int])
            dominoList = genAllDoms
            zippedList = zip dominoList randomList
            sortedList = mergesort (\(_,n1) (_,n2)->n1<n2) zippedList
         in (map fst sortedList)
dealDoms :: Int -> (Hand, Hand)
dealDoms seed =  splitAt 9 (take 18 (shuffleDoms seed))
simplePlayer :: DomsPlayer
simplePlayer (d:h) b
 | goesSwappedP d L b = (d, L)
 | goesSwappedP d R b = (d, R)
 | otherwise = simplePlayer h b
-- playDomsTurn :: DomsPlayer -> Board -> Int
-- playDomsTurn p b = 
--     let 
-- playDomsRound :: DomsPlayer -> DomsPlayer -> (Int, Int)
-- playDomsRound = 
-- sortHandByScore :: Hand -> Hand
-- sortHandByScore h = 
--     let randomList = map score
--             zippedList = zip h randomList
--             sortedList = mergesort (\(_,n1) (_,n2)->n1<n2) zippedList
--          in (map fst sortedList)

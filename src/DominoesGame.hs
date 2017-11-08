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
singleMove :: DomsPlayer -> Hand -> Board -> (Int, Board)
singleMove p h b
 | knockingP h = (0,b)
 | otherwise = playDom (p h b)
playRound :: (DomsPlayer, Int, Hand) -> (DomsPlayer, Int, Hand) -> Board -> (Int, Int)
playRound (p1,p1s,p1h) (p2,p2s,p2h) b = p1 p1h b
playDomsRound :: DomsPlayer -> DomsPlayer -> Int -> (Int, Int)
playDomsRound p1 p2 seed = let dealtDominos = dealDoms 64
                               board = []
                               scores = playRound (p1,0,fst dealtDominos) (p2,0,dealtDominos) board
                            in (scores)
-- sortHandByScore :: Hand -> Hand
-- sortHandByScore h = 
--     let randomList = map score
--             zippedList = zip h randomList
--             sortedList = mergesort (\(_,n1) (_,n2)->n1<n2) zippedList
--          in (map fst sortedList)

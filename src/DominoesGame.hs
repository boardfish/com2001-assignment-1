module DominoesGame where
import Dominoes
import MergeSort
import System.Random 
import Data.Maybe
import Data.List
import Data.Ord (comparing)
type DomsPlayer = Hand -> Board -> (Domino, End)
deleteDom :: Domino -> Hand -> Hand
deleteDom y [] = []
deleteDom y (x:xs) = if x == y || x == swap y then xs else x : deleteDom y xs
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
fst3 :: (a, b, c) -> a
fst3 (x, _, _) = x
convertHighestScoreResult :: (Int, End, (Int, Int)) -> (Domino, End)
convertHighestScoreResult (s, e, d) = (d, e)
hsdPlayer :: DomsPlayer
hsdPlayer h b = let (ppl, ppr) = possPlays h b ([],[])
                    left = map (\(x,y) -> (scoreDom (x,y) L b, L, (x,y))) ppl
                    right = map (\(x,y) -> (scoreDom (x,y) R b, R, (x,y))) ppr
                    dom = head (reverse (sortBy (comparing fst3) (left ++ right)))
                 in (convertHighestScoreResult dom)
singleMove :: DomsPlayer -> Hand -> Board -> (Int, Board, Hand)
singleMove p h b
  | knockingP h b = (0,b,h)
  | otherwise = let (d,e) = p h b
                    board = fromJust (playDom d e b)
                    score = scoreBoard board
                    hand  = deleteDom d h
                 in ((score, board, hand))
playRound :: (DomsPlayer, Int, Hand) -> (DomsPlayer, Int, Hand) 
          -> Board -> ((Int, Int),Board)
playRound (p1,p1s,p1h) (p2,p2s,p2h) b = 
    let (p1ns, t1b, p1nh) =  singleMove p1 p1h b
        (p2ns, t2b, p2nh) =  singleMove p2 p2h t1b
     in if knockingP p1nh t2b && knockingP p2nh t2b 
           then ((p1ns+p1s, p2ns+p2s), t2b) 
           else playRound (p1,p1ns+p1s,p1nh) (p2,p2ns+p2s,p2nh) t2b
playDomsRound :: DomsPlayer -> DomsPlayer -> Int -> ((Int, Int),Board)
playDomsRound p1 p2 seed = let (p1h,p2h) = dealDoms seed
                               b = []
                               (scores, board) = playRound (p1,0,p1h) (p2,0,p2h) b
                            in (scores,board)

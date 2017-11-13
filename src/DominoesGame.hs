module DominoesGame where
import Dominoes
import MergeSort
import System.Random 
import Data.Maybe
import Data.List
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
hsdPlayer :: DomsPlayer
hsdPlayer h b = let ((score,dom):shs) = sortHandByScore h L b in (dom, L)
singleMove :: DomsPlayer -> Hand -> Board -> (Int, Board, Hand)
singleMove p h b
  | knockingP h b = (0,b,h)
  | otherwise = let (d,e) = p h b
                    board = fromJust (playDom d e b)
                    score = scoreBoard board
                    hand  = deleteDom d h
                 in ((score, board, hand))
playRound :: (DomsPlayer, Int, Hand) -> (DomsPlayer, Int, Hand) -> Board -> ((Int, Int),Board)
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
sortHandByScore :: Hand -> End -> Board -> [(Int, (Int,Int))]
sortHandByScore h e b = reverse (sort [(scoreDom (x,y) e b, (x,y)) | x <- [0..6], y<- [0..6], elem (x,y) h])

# Foreword

This assignment revolved around replicating the mechanics of the game Dominoes, particularly in relation to the fives-and-threes ruleset. Naturally, the base game is very extensible, and many of the functions I have devised can be easily retooled for use in other rulesets, but many of the methods here are specific to fives-and-threes. Here, I have tested a variety of cases at length - all sample console output is taken from GHCI with the domino.hs module loaded. 

# Helper Methods

## swap

This method didn't load when I specified Domino was a pair, and should function exactly as the original did, simply by swapping the two integers in the pair.

### Sample output

```
*Main> swap (1,2)
(2,1)
```

## defaultPositionP

This method determines whether or not the domino is in what one would assume to be its default position - with the greater number on the left. It is used in scoreN to filter out any duplicate entries that arise when a domino is not in its default position.

### Sample output

```
*Main> defaultPositionP (2,3)
True
*Main> defaultPositionP (3,2)
False
*Main> defaultPositionP (3,3)
True
```

## score

This method, given two integers, determines the score they would give according to fives-and-threes rules.

### Tests

#### Multiple of 5

```
*Main> score 2 3
1
*Main> score 7 3
2
```

#### Multiple of 3

```
*Main> score 3 0
1
*Main> score 6 0
2
```

#### Mutual multiple

Fives-and-threes rules state that if a score is a multiple of both three and five (that is, a multiple of 15), both are taken into account in the final sum. In an example given in the provided documentation, 15 scores 8 as it is both 3 \* **5** and 5 \* **3**.

```
*Main> score 15 0
8
```

#### Multiple of neither

```
*Main> score 1 0
0
*Main> score 2 0
0
*Main> score 4 0
0
*Main> score 7 0
0
```

## scoreDom

This function returns the score given after a certain domino has been played, provided that is indeed possible. It is based on, and therefore its correctness is proven by, `playDom` and `scoreBoard` in combination. It serves as a helper method, particularly for `scoreN`.

### Tests

#### Board is empty

```
*Main> scoreDom (0,3) L []
1
```

#### Domino isn't playable

```
*Main> scoreDom (7,7) L [(0,0),(0,3)] 
0
```

#### Play results in a score

```
*Main> scoreDom (3,5) R [(0,0),(0,3)] 
1
```

#### Play does not result in a score

```
*Main> scoreDom (3,2) R [(0,0),(0,3)]
0
```

## scoreEnds

This function returns the score generated from two given dominos as though they were the two ends of a board. This counts double dominoes. If scoring were to be based on the outer spots of the ends alone, this would be taken with the `score` function, but additional logic is necessary in the event of a double domino.

### Tests

#### Dominoes do not generate a score

```
*Main> scoreEnds (0,3) (3,2)
0
```
#### Dominoes generate a score

```
*Main> scoreEnds (0,1) (1,3)
1
```
#### Either domino is a double

```
*Main> scoreEnds (0,3) (3,3)
2
*Main> scoreEnds (3,3) (3,0)
2
```

#### Both dominoes are doubles

```
*Main> scoreEnds (6,6) (3,3)
6
```

## turnDomino

This function returns either a given domino or its swapped configuration, based on the board and end provided. Erroneous inputs will return the domino in its current configuration.

### Tests

#### End provided for which the domino should be flipped

```
*Main> turnDomino (1,0) L [(1,2),(2,0)]
(0,1)
*Main> turnDomino (1,0) R [(1,2),(2,0)]
(0,1)
```

#### End provided for which the domino should not flip

```
*Main> turnDomino (0,1) L [(1,2),(2,0)]
(0,1)
*Main> turnDomino (0,1) R [(1,2),(2,0)]
(0,1)
```

#### Board is empty

The original domino is returned in any case.

```
*Main> turnDomino (0,1) L []
(0,1)
*Main> turnDomino (0,1) R []
(0,1)
```

## scoreNP

This predicate returns whether or not playing a given domino would result in a given score. The logic is primarily inherited from the scoreDom helper function, and as a combined predicate, it is used mostly to make `scoreN` more concise.

### Tests

#### Domino would score at left

```
*Main> scoreNP (0,3) [(0,0),(0,2)] 1
True
```

#### Domino would score at right

```
*Main> scoreNP (0,3) [(2,0),(0,0)] 1
True
```

#### Domino would not score

```
*Main> scoreNP (0,4) [(2,0),(0,0)] 1
False
```

#### Domino would not be valid

```
*Main> scoreNP (3,4) [(2,0),(0,0)] 1
False
```

#### Domino would be first in play and result in a score

TODO: OH SHIT

```
*Main> scoreNP (2,3) [] 1
True
*Main> scoreNP (3,3) [] 2
True
```

#### Domino would be first in play and not result in a score

```
*Main> scoreNP (2,2) [] 1
False
```

# Marked Methods

## playedP

This method simply checks whether a domino is on the board in either possible configuration.

### Tests

#### Domino is on the board

```
*Main> playedP (1,0) [(1,0)]
True
```

#### Domino is not on the board

```
*Main> playedP (1,0) []
False
```

#### Domino is on the board in its flipped position

```
*Main> playedP (1,0) [(0,1)]
True
```

## goesP

This method checks whether or not a domino is playable at a given end. It uses the two helper methods `goesLeftP` and  `goesRightP`, which compare the given Domino and End with pattern matching.

### Tests

#### Domino is playable at the given end

```
*Main> goesP (1,0) L [(0,0),(0,3)]
True
```

#### Domino is playable at the given end in its flipped position

```
*Main> goesP (1,0) R [(3,2),(2,0)]
False
```

This scenario is catered for by goesSwappedP.

#### Domino is not playable at the given end

```
*Main> goesP (1,0) R [(3,2),(2,5)]
False
```

#### Board is empty

An End is still required as an argument, but it does not affect the outcome.

```
*Main> goesP (1,0) L []
True
```

## knockingP

This method checks whether the player has at least one playable Domino in their hand, and returns `True` if this is not the case, signifying that they are knocking.

### Tests

#### Hand is empty

```
*Main> knockingP [] []
True
```

#### Hand has dominoes that are not playable

```
*Main> knockingP [(1,0)] [(2,5)]
True
```

#### Hand has playable dominoes

```
*Main> knockingP [(5,0)] [(2,5)]
False
```

#### Board is empty, and hand is not

```
*Main> knockingP [(0,1)] []
False
```

## playDom

This method returns the Board created when a given Domino is played, but will return Nothing if any part of the move is valid.

### Tests

#### Domino is playable

```
*Main> playDom (2,3) L [(3,2)]
Just [(2,3),(3,2)]
*Main> playDom (2,5) R [(3,2)] 
Just [(3,2),(2,5)]
```

#### Domino is playable in its flipped position

```
*Main> playDom (2,5) R [(3,5)]
Just [(3,5),(5,2)]
```

#### Domino is not playable

```
*Main> playDom (2,5) L [(3,4)] 
Nothing
*Main> playDom (2,5) R [(3,4)] 
Nothing
```

#### Board is empty

An End must still be provided.

```
*Main> playDom (1,0) L [] 
Just [(1,0)]
*Main> playDom (1,0) R [] 
Just [(1,0)]
```

## scoreBoard

This method figures out the score that a given Board is worth. This includes whether there is a double piece at either end.

### Tests

#### Board is empty

```
*Main> scoreBoard []
0
```

#### Board has one domino

```
*Main> scoreBoard [(0,3)]
1
```

#### Board has multiple dominoes
```
*Main> scoreBoard [(0,3),(3,5)]
1
```

#### One end is a double

```
*Main> scoreBoard [(0,3),(3,3)]
2
*Main> scoreBoard [(3,3),(3,0)]
2
```

#### Both ends are doubles

```
*Main> scoreBoard [(3,3),(3,0),(0,2),(2,2)]
2
```

## possPlays

This method determines all possible plays that a player can make with their Hand on a given Board.

### Tests

#### Hand has one or more playable dominoes

```
*Main> possPlays [(0,1)] [(1,3),(3,2)] ([],[])
([(0,1)],[])
*Main> possPlays [(0,1),(2,5)] [(1,3),(3,2)] ([],[])
([(0,1)],[(2,5)])
*Main> possPlays [(0,1),(2,5)] [(6,3),(3,2)] ([],[])
([],[(2,5)])
```

#### Hand has a domino playable at either end

```
*Main> possPlays [(3,5)] [(3,3)] ([],[])
([(3,5)],[(3,5)])
```

#### Hand has no playable dominoes

```
*Main> possPlays [(4,5)] [(1,3),(3,2)] ([],[])
([],[])
```

#### Hand has no dominoes

```
*Main> possPlays [] [(1,3),(3,2)] ([],[])
([],[])
```

#### Board has no dominoes

```
*Main> possPlays [(1,0),(2,3)] [] ([],[])
([(1,0),(2,3)],[(1,0),(2,3)])
```

#### Neither hand nor board has dominoes

```
*Main> possPlays [] [] ([],[])
([],[])
```

## scoreN

This method relies primarily on the predicate function `scoreNP`.

### Tests

#### Board has no dominoes

```
*Main> scoreN [] 0
[(0,0),(0,1),(0,2),(0,4),(1,1),(1,3),(1,6),(2,2),(2,5),(2,6),(3,4),(3,5),(4,4),(5,6)]
*Main> scoreN [] 1
[(0,3),(0,5),(1,2),(1,4),(2,3)]
*Main> scoreN [] 2
[(0,6),(1,5),(2,4),(3,3),(4,6),(5,5)]
*Main> scoreN [] 3
[(3,6),(4,5)]
*Main> scoreN [] 4
[(6,6)]
```

#### Board has one or more dominoes

```
*Main> scoreN [(1,2)] 0
[(0,1),(0,2),(1,1),(1,5),(1,6),(2,3),(2,6)]
*Main> scoreN [(1,2)] 1
[(1,3),(2,2),(2,4)]
*Main> scoreN [(1,2)] 2
[(1,4),(2,5)]
*Main> scoreN [(1,2)] 3
[]
*Main> scoreN [(1,2)] 4
[]
```

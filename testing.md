# Helper Methods

## swap

### Tests

```
*Main> swap (1,2)
(2,1)
```

## score

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

This function returns the score given after a certain domino has been played, provided that is indeed possible. It is based on, and therefore its correctness is proven by, `playDom` and `scoreBoard` in combination.

### Tests

#### Board is empty

```
*Main> scoreDom (0,3) [] (0,0)
1
```

#### Domino isn't playable

```
*Main> scoreDom (7,7) [(0,0),(0,3)] (0,3)
0
```

#### Play results in a score

```
*Main> scoreDom (3,5) [(0,0),(0,3)] (0,3)
1
```

#### Play does not result in a score

```
*Main> scoreDom (3,2) [(0,0),(0,3)] (0,3)
0
```

## turnDomino

This function returns either a given domino or its swapped configuration, based on the board and end provided.

### Tests

#### End provided for which the domino should be flipped

```
*Main> turnDomino (1,0) (1,2) [(1,2),(2,0)]
(0,1)
*Main> turnDomino (1,0) (2,0) [(1,2),(2,0)]
(0,1)
```

#### End provided for which the domino should not flip

```
*Main> turnDomino (0,1) (1,2) [(1,2),(2,0)]
(0,1)
*Main> turnDomino (0,1) (2,0) [(1,2),(2,0)]
(0,1)
```

#### Board is empty

The original domino is returned in any case.

```
*Main> turnDomino (0,1) (0,0) []
(0,1)
```

#### End provided that isn't on the board

```
*Main> turnDomino (0,1) (7,7) [(1,2),(2,0)]
(1,0)
```

## scoreNP

This predicate returns whether or not playing a given domino would result in a given score. The logic is primarily inherited from the scoreDom helper function.

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

```
*Main> scoreNP (2,3) [] 1
True
```

#### Domino would be first in play and not result in a score

```
*Main> scoreNP (2,2) [] 1
False
```

# Marked Methods

## playedP

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

### Tests

#### Domino is playable at the given end

```
*Main> goesP (1,0) (0,0) [(0,0),(0,3)]
True
```

#### Domino is playable at the given end in its flipped position

```
*Main> goesP (1,0) (2,0) [(3,2),(2,0)]
True
```

#### Domino is not playable at the given end

```
*Main> goesP (1,0) (2,5) [(3,2),(2,5)]
False
```

#### Board is empty

A valid End is still required as an argument.

```
*Main> goesP (1,0) (2,5) []
True
```

## knockingP

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

#### Board is empty

```
*Main> knockingP [(0,1)] []
False
```

## playDom

### Tests

#### Domino is playable

```
*Main> playDom (2,5) [(3,2)] (3,2)
Just [(3,2),(2,5)]
```

#### Domino is playable in its flipped position

```
*Main> playDom (2,5) [(3,5)] (3,5)
Just [(3,5),(5,2)]
```

#### Domino is not playable

```
*Main> playDom (2,5) [(3,4)] (3,4)
Nothing
```

#### Board is empty

An End must still be provided.

```
*Main> playDom (1,0) [] (0,0)
Just [(1,0)]
```

#### End is not on the board

```
*Main> playDom (2,5) [(3,4)] (7,7)
Nothing
```

#### End isn't actually an end

```
*Main> playDom (1,0) [(1,2),(2,0),(0,3)] (2,0)
Just [(1,2),(2,0),(0,3),(0,1)]
```

## scoreBoard

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
```

## possPlays

### Tests

#### Hand has one or more playable dominoes

```
*Main> possPlays [(0,1)] [(1,3),(3,2)] ([],[])
([(0,1)],[])
*Main> possPlays [(0,1),(2,5)] [(1,3),(3,2)] ([],[])
([(0,1)],[(2,5)])
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
*** Exception: src/domino.hs:(109,1)-(114,42): Non-exhaustive pattern
s in function possPlays
```

#### Neither hand nor board has dominoes

```
*Main> possPlays [] [] ([],[])
([],[])
```

## scoreN

Predicate function is `scoreNP`, hence if that is correct then so is scoreN.

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

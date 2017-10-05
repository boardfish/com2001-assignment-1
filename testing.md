# Helper Methods

## swap

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

The greatest sum possible would be 12 ( a 6 on either end of the board). This means that there are no circumstances under which this would be the case, as the lowest common multiple of the two is 15. However, were this possible, the `score` function would have division by 5 take precedence, as this is tested first.

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

This function returns the score given after a certain domino has been played, provided that is indeed possible. It is based on, and therefore its correctness is proven by, `playDom` and `scoreBoard`.

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

### End provided for which the domino should not flip

```
*Main> turnDomino (0,1) (1,2) [(1,2),(2,0)]
(0,1)
*Main> turnDomino (0,1) (2,0) [(1,2),(2,0)]
(0,1)
```

### End provided that isn't on the board

#### or board is empty

The original domino is returned in any case.

```
*Main> turnDomino (0,1) (7,7) [(1,2),(2,0)]
(1,0)
*Main> turnDomino (0,1) (0,0) []
(0,1)
```

## scoreNP

This predicate returns whether or not playing a given domino would result in a given score. The logic is primarily inherited from the scoreDom helper function.

### Domino would score at left

```
*Main> scoreNP (0,3) [(0,0),(0,2)] 1
True
```

### Domino would score at right

```
*Main> scoreNP (0,3) [(2,0),(0,0)] 1
True
```

### Domino would not score

```
*Main> scoreNP (0,4) [(2,0),(0,0)] 1
False
```

### Domino would not be valid

```
*Main> scoreNP (3,4) [(2,0),(0,0)] 1
False
```

### Domino would be first in play and result in a score

```
*Main> scoreNP (2,3) [] 1
True
```

### Domino would be first in play and not result in a score

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

## playDom

### Tests

#### Domino is playable

```
*Main> playDom (2,5) [(3,2)] (3,2)
Just [(2,5),(3,2)]
```

#### Domino is playable in its flipped position

```
*Main> playDom (2,5) [(3,5)] (3,5)
Just [(5,2),(3,5)]
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

## scoreBoard

### Tests

#### Board has one or more dominoes

```
*Main> scoreBoard [(0,3)]
1
*Main> scoreBoard [(0,3),(3,5)]
1
*Main> scoreBoard [(0,3),(3,3)]
1
```

#### Board is empty

```
*Main> scoreBoard []
0
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

TODO: Deal with this

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
([(2,3),(1,0)],[])
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
[(0,0),(0,1),(0,2),(0,4),(1,1),(1,3),(1,6),(2,2),(2,5),(2,6),(3,4),
(3,5),(4,4),(5,6)]
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


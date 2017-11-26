% Design - Assignment 3
% Simon Fish

# Scenarios

## First Drop

If the board is empty, play the following if in the hand:

(5,4) - scores 3, anti-score is 2

TODO: come up with a function to find the strongest first moves.

## Endgame

Aim for 61, otherwise go for 59 - it's more common to score 2 than anything
else.

# Strategies

## Clear Out

Play whichever spot value you have the majority of:

### Function: countSpots

Returns an array of 7 after **looping through the hand** to obtain the number of
spots on **each side of each domino**.

## History

### Remaining Doms

Use the history to ascertain what dominoes remain in play.

**Filter for genAllDoms: playedP**

### Knocking

Use the history to see what the opponent is knocking on.

### Hand Contents

Use the history to guess what is in the opponent's hand. Ways to do this:

**Paranoia**: Assume that everything that's not on the board or in the player's
hand is potentially in the other player's hand

## Back Foot

'Stitch' the game - try to play against what is potentially in the other
player's hand

## Danger

Doubles are dangerous - make sure something else is in your hand before playing
them

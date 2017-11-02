# DomsPlayer

## simplePlayer

- Use head of possPlays

## hsdPlayer

- Mapping function of dominoes to their scores
- Sort highest to lowest, take head

# shuffleDoms

- Shuffle dominoes using a random seed
    - Use generated random seed to create a list of numbers
    - Map this to the **array of dominoes** and sort - need a helper function!

# Helper: genAllDominoes

- Generate a list of all dominoes for use in filtering
    - Reuse mapping function from scoreN without the predicate
    - Reverse defaultPosition - feedback said use greater spots first

# playDomsRound (p1, p2, seed)

1. Define hands
    - Call dealDoms

## Helper: dealDoms

- Call shuffleDoms with seed
- Take first 9 for p1's hand, next 9 for p2, leave the remaining 10

2. Play round
    - Call each player with their hands
    - Call playDom with the returned Hand and Board
    - Add scoreN (board) to their score
    - At the end of one turn, return the final score if knockingP for both

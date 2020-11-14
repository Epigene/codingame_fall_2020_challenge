# Bronze ideas

## Perspective!

Perspective hinges on ability to extrapolate with reasonable precision:
1) Moves to make to reach a series of inventory states (will need caching of progression to be performant)
2) What the expected value to end of game (
  either 100th turn or brewing #{ 6 } potions
) is from current state

1) Compare
  all potion make cost with current spells
  VS
  all potion make cost with learning each of 6 spells (plust tax gotten, minus tax paid)

  Learn as spell if its summed shortening of each potion's brew time exceeds 5 (
    makes up for the turn spent learning and them some
  ) && it gives the best boost

2) When to stop learning?
  a) Stop learning and cash in after opponent has brewed #{ 3rd } (halfway) potion
  OR
  b) #{ 50th } move has been reached
  OR
  c) If learning new spells does not increase value gained in the remaining moves (
    this can be time consuming to calculate. Have to compare expected value from spells now
    to expected value if spending a turn learning a good-looking spell
  )

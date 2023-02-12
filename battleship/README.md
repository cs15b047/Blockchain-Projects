# Battleship

This project requires you to build a simplified version of the game battleship in Vyper.
The core differences are:
1. A smaller board: Only a grid of 5x5 per player
2. Each ship/boat has a size of only one field

## Game Rules
The game has exactly two players and each player has a separate board.
This, for example, means that both players can put a boat at the same coordinates

The game has two phases: "setting" and "shooting."

During the first phase, each player sets five pieces on their board.
Each piece represents a boat.
Because the two boards are separate, they can do this in any order.
The player do not need to alternate.

Once all pieces are set, the game moves to the "Shoot" phase.
During the shoot phase the player alternate turns.
Each turn, a player picks a field not chosen by the same player before.

The "Shoot" phase ends as soon as one player has hit all five pieces of the other player.
Then, that player is declared the winner and the game ends.

## Setup
Make sure you have vyper, pytest, and pytest-vyper setup.
The following should be sufficient to do this.

```
pip install pytest vyper
pip install git+https://github.com/kaimast/pytest-vyper
```

Then run the tests like so
```
pytest --disable-warnings
```

## Hints and Notes
We already gave you some constants and other boilerplate code that you can, but do not have to, use.
Make sure your final code works with the provided test file and do not modify the test file in any way.

You should set up some kind of array to track the state of each player's board.
Note that array accesses and declarations in Vyper are inverted, which can be a little confusing.
See [here](https://docs.vyperlang.org/en/stable/types.html?highlight=list#fixed-size-lists) for more info.

If you are still unsure about the game rules, taking a look at the tests might clarify some things.

## No Cheat Prevention
You might remember from class that all smart contract data is public.
As a result, it would be fairly trivial to cheat by inspecting the blockchain to see where the boats of the other player are located.

There are ways to work around this using encryption, but that goes beyond the scope of this project.
This is just an example project, and you do not have to worry about potentially cheating players.

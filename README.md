# Noughts and Crosses
####aka Tic-Tac-Toe

This is a shell based noughts and crosses game.

![Game_Screenshot](screenshots/screen1.png?raw=true "Gameplay")


Creating a new game...

```ruby
require 'noughts_and_crosses'

game = Game.new

```&nbsp;

---
###Game Options
Some options can only be set before you start the game.

You can change the characters used in the game.

Default value is `[:X, :O]`
```ruby
game.options[:charset] = ['$', :+]
```
Changing the AI's intelligence. The higher the number the more intelligent. To turn off the AI set the value to 0 (super easy mode).

Default value is `2`

```ruby
game.options[:ai] = 5
```&nbsp;

---
###Starting the Game
```ruby
game.start
```
You'll then be asked the following questions.
```ruby
Would you like to play a game?
	>>y                 # Answering no will quit the game.
How many players?
	>>1                 # 1 and 2 will give you single player, and two player modes
                            # respectively. Entering 0 will make the game play by itself.
Do you want to go first?
	>>y                 # Yes will have player 1 go first, else player 2
```

You will then be prompted with the game board.

![Game_Screenshot](screenshots/screen2.png?raw=true "Gameplay")

The user should use their numpad for input. The number on the pad will correspond with a square on the game board.

```
     |     |   
  7  |  8  | 9
_____|_____|_____
     |     |   
  4  |  5  |  6
_____|_____|_____
     |     |   
  1  |  2  |  3
     |     |
```



# Wanda Wants Watermelons: ∂e$igN

I formatted this game by splitting up many of the components into their own files so that the game was more manageable and organized. I'll describe each of the files below:

### Structure
- `Animation.lua`: A class grabbed from the Mario games track problem set that holds a collection of frames that switch depending on how much time has passed. I used this to animate the player in the Melon Game.
- `class.lua`: Pre-existing Lua software that someone else created to help create classes more easily.
- `push.lua`: Pre-existing Lua software that makes creating retro-like games easier
- `Util.lua`: A file taken from the Mario games track that splits spritesheets into Quads, enabling easier animation and drawing.
- `Main.lua`: The _~moste importante~_ part of a LÖVE game. Looks at all the files in the game and generates the window, accepts user input, and controls which aspect of the game is active.

### Main Tile Page
- `Map.lua`: Determines the design and functionality of the main tile page. I made this its own class so that I could render new Map objects based on which fruit was desired in that round.

### Melon Game
- `MelonMap.lua`: Determines the design and functionality of the melon game. I made this its own class so that I could render new MelonMap objects based on which fruit was desired in that round.
- `MelonPlayer.lua`: Contains all the different animations, functions, and properties associated with the sprite in the melon game, such as lives, points, and movement.
- `Melon.lua`: Class that represents the fruits and fruit behaviors in the melon game. Each fruit can be a good fruit (if you touch it, you get points) or a bad fruit (if you touch it, you lose a life), and can take on a variety of appearances (pear, watermelon, apple, or banana).
- `Life.lua`: Class that represents the lives the player has in the melon game. At any given time, its either represented on the screen as a filled heart or empty heart.

### Other Files and Folders
- Fonts: Contains the font used throughout the game. Taken from the Mario games track problem set.
- Graphics: All the images that appear on the screen are contained here. I drew everything except the alien sprite Wanda (which was taken from the Mario problem set) using free pixel art software at pixilart.com.
- Sounds: All the sounds in the game are housed in this folder. I found the two songs looped throughout the game at dl-sounds.com.
- You might notice that there's a file called "Player.lua" that isn't called, a file called "speech.png" in the graphics folder that isn't used in my program, and multiple files in the sounds folder that aren't called. Those are there for future updates to my game.
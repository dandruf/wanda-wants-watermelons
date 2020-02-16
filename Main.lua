--[[
    CS50 Final Project
    Wanda Wants Watermelons
    Jasmyne B Roberts, Class of 2023

    House/Dorm: Matthews
    Intended Concentraion: Computer Science
    Intended Players: Young Children
]]


Class = require 'class'
push = require 'push'
require 'Animation'

require 'Melonmap'
require 'Melon'
require 'Life'
require 'MelonPlayer'

require 'Map'
require 'Player'

-- close resolution to NES but 16:9
VIRTUAL_WIDTH = 432 - 16
VIRTUAL_HEIGHT = 243 + 13

-- actual window resolution
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

-- set gamestate
-- gamestate = 'idle'

-- makes upscaling look pixel-y instead of blurry
love.graphics.setDefaultFilter('nearest', 'nearest')

-- an object to contain our map data, preset with watermelon
map = Map(WATERMELON, "watermelon")
melonmap = MelonMap("watermelon")

-- performs initialization of all objects and data needed by program
function love.load()

    -- sets up a different, better-looking retro font as our default
    smallFont = love.graphics.newFont('fonts/font.ttf', 8)
    largeFont = love.graphics.newFont('fonts/font.ttf', 16)
    scoreFont = love.graphics.newFont('fonts/font.ttf', 24)
    -- sets up virtual screen resolution for an authentic retro feel
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = true,
        resizable = false
    })

    love.window.setTitle('Wanda Wants Watermelons')

    love.keyboard.keysPressed = {}
    love.keyboard.keysReleased = {}
end

-- called whenever window is resized
function love.resize(w, h)
    push:resize(w, h)
end

function love.keypressed(key)
    if key == 'escape' then love.event.quit()
    elseif key == 'space' and melonmap.gamestate == "standby" then melonmap.gamestate = "playing"
    elseif key == 'space' and (melonmap.gamestate == 'victory' or melonmap.gamestate == 'loss') then melonmap.gamestate = 'off' end
end

-- global key pressed function
function love.keyboard.wasPressed(key)
    if (love.keyboard.keysPressed[key]) then
        return true
    else
        return false
    end
end

-- global key released function
function love.keyboard.wasReleased(key)
    if (love.keyboard.keysReleased[key]) then
        return true
    else
        return false
    end
    love.keyboard.keysPressed[key] = true
end

-- called whenever a key is released
function love.keyreleased(key)
    love.keyboard.keysReleased[key] = true
end

-- called every frame, with dt passed in as delta in time since last frame
function love.update(dt)
    
    -- maps will only update if their gamestates arne't "off"
    if melonmap.gamestate ~= 'off' then
        melonmap:update(dt)
    end
    if map.gamestate ~= 'off' then
        map:update(dt)
    end

    -- if both maps are off, create new maps with a random target fruit
    if melonmap.gamestate == 'off' and map.gamestate == 'off' then

        -- the different fruits represented in the game
        local fruitOptions = {
            {WATERMELON, "watermelon"},
            {BANANA, "banana"}, 
            {APPLE, "apple"},
            {PEAR, "pear"}}

        local index = love.math.random(1, #fruitOptions)
        map = Map(fruitOptions[index][1], fruitOptions[index][2])
        melonmap = MelonMap(fruitOptions[index][2])
    end

    -- reset all keys pressed and released this frame
    love.keyboard.keysPressed = {}
    love.keyboard.keysReleased = {}

    
end

-- converts window pixels to virtual pixels
function love.mousepressed(x, y, button, istouch)
    if button == 1 and map.gamestate ~= "off" then 
        clickedX, clickedY = push:toGame(x, y)
        map.gamestate = "Clicked?"
    end
end

-- called each frame, used to render to the screen
function love.draw()

    -- begin virtual resolution drawing
    push:apply('start')
    
    if melonmap.gamestate ~= 'off' then
        -- clear screen using Mario background blue
        love.graphics.clear(95/255, 105/255, 200/255, 255/255)
        melonmap:render()
    end

    if map.gamestate ~= 'off' then
        -- clear screen using turquoise gray background
        love.graphics.clear(70/255, 98/255, 99/255, 255/255)
        map:render()
    end

    -- end virtual resolution
    push:apply('end')
end
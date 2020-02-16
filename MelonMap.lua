--[[
    Contains date for tiles, sprites, and all objects contained in melon game. 
    Also contains most of the functional logic for the melon game.
]]

require 'Util'

MelonMap = Class{}

TILE_BRICK = 1
TILE_EMPTY = -1

-- constructor for our map object
function MelonMap:init(fruitgoal)
    -- fruitgoal passed in by main so that we know which fruit we actually want to collect

    self.tile = love.graphics.newImage('graphics/brick.png')

    self.music = love.audio.newSource('sounds/melonmusic.wav', 'static')

    self.tileWidth = 16
    self.tileHeight = 16
    self.mapWidth =  27
    self.mapHeight = 16
    self.tiles = {}

    -- associate player with map
    self.player = MelonPlayer(self)

    -- cache width and height of map in pixels
    self.mapWidthPixels = self.mapWidth * self.tileWidth
    self.mapHeightPixels = self.mapHeight * self.tileHeight

    -- first, fill map with empty tiles
    for y = 1, self.mapHeight do
        for x = 1, self.mapWidth do
            
            -- support for multiple sheets per tile; storing tiles as tables 
            self:setTile(x, y, TILE_EMPTY)
        end
    end

    -- begin generating the terrain using vertical scan lines
    local x = 1
    while x < self.mapWidth do
        -- creates two column of tiles going to bottom of map
        for y = self.mapHeight - 2, self.mapHeight do
            self:setTile(x, y, TILE_BRICK)
        end

        -- next vertical scan line
        x = x + 1
    end

    -- start the background music
    self.music:setLooping(true)
    self.music:play()

    -- sets default gamestate
    self.gamestate = "standby"

    -- creates a table to store three instances of hearts
    self.hearts = {}
    for i = 0, 2 do table.insert(self.hearts, Life(i * 18 + 3)) end

    -- different kinds of fruit!
    self.fruitOptions = {
        "watermelon",
        "banana", 
        "apple",
        "pear"}

    self.fruits = {} -- table that will contain all instaces of fruit
    self.fruitgoal = fruitgoal
    self.createFruitTimer = 0  -- gives a buffer (in seconds) between fruits rendering
end

function MelonMap:update(dt)
    self.player:update(dt)

    if self.gamestate == "playing" then

        -- Control when new fruits can be created
        self.createFruitTimer = self.createFruitTimer - (1 * dt)
        if self.createFruitTimer < 0 then
            self.createFruitTimer = love.math.random(1, 3)

            -- Create a fruit
            table.insert(self.fruits, Melon(self.fruitgoal, self.fruitOptions[love.math.random(1, #self.fruitOptions)], love.math.random(0, self.mapWidthPixels - 30)))
        end

        -- reduces filled hearts with every life lost
        for _, v in ipairs(self.hearts) do
            if _ == self.player.lives + 1 and self.player.lives < 3 then
                v.filled = false
            end
                
            v:update(dt) 
        end

        -- removes instances of fruit object if it reaches the floor or collides with player sprite
        if #self.fruits > 0 then
            for _, v in ipairs(self.fruits) do

                if self:tileAt(v.x, v.y + v.height - 4).id == TILE_BRICK then -- remove fruits when they touch the ground
                    table.remove(self.fruits, _)
                elseif v.x > self.player.x - self.player.xOffset - v.width and 
                v.x < self.player.x + self.player.width - self.player.xOffset and
                v.y + v.height >= self.player.y + self.player.yOffset then  -- remove fruits when they touch the player sprite
                    if v.nice == true then
                        self.player.points = self.player.points + 1
                    elseif v.nice == false then
                        self.player.lives = self.player.lives - 1
                    end

                    table.remove(self.fruits, _)
                else
                    v:update(dt)
                end
            end
        end

    elseif self.gamestate == "victory" or self.gamestate == "loss" then
        -- removes all fruits objects
        for _, v in ipairs(self.fruits) do table.remove(self.fruits, _) end
        for _, v in ipairs(self.hearts) do table.remove(self.hearts, _) end

    end

    -- continously check for victory or loss
    if self.player.points == 3 then
        self.gamestate = "victory"
    elseif self.player.lives == 0 then
        self.gamestate = "loss"
    end
    
    -- music will only play when the gamestate is "playing"
    if self.gamestate == "playing" then
        self.music:play()
    else
        self.music:stop()
    end
end

-- gets the tile type at a given pixel coordinate
function MelonMap:tileAt(x, y)
    return {
        x = math.floor(x / self.tileWidth) + 1,
        y = math.floor(y / self.tileHeight) + 1,
        id = self:getTile(math.floor(x / self.tileWidth) + 1, math.floor(y / self.tileHeight) + 1)
    }
end

-- returns an integer value for the tile at a given x-y coordinate
function MelonMap:getTile(x, y)
    return self.tiles[(y - 1) * self.mapWidth + x]
end

-- sets a tile at a given x-y coordinate to an integer value
function MelonMap:setTile(x, y, id)
    self.tiles[(y - 1) * self.mapWidth + x] = id
end

-- renders our map to the screen, to be called by main's render
function MelonMap:render()

    -- renders all fruits in the game to the screen
    for _, v in ipairs(self.fruits) do
        v:render()
    end

    -- renders the text that'll appear with different game states (start, win, loss, etc.)
    if self.gamestate == "standby" then
        love.graphics.setFont(largeFont)
        love.graphics.printf("Collect the " .. self.fruitgoal .. "s!", 0, 100, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf("Press SPACE to begin", 0, 120, VIRTUAL_WIDTH, 'center')
    elseif self.gamestate == "playing" then
        love.graphics.setFont(scoreFont)
        -- adds point (good fruits collected) to map
        love.graphics.printf(tostring(self.player.points), 0, 0, VIRTUAL_WIDTH, 'right')
        for _, v in ipairs(self.hearts) do
            v:render()
        end
    elseif self.gamestate == "victory" then
        love.graphics.setFont(largeFont)
        love.graphics.printf("HOORAY! You got your " .. self.fruitgoal .. "s!", 0, 100, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf("Press SPACE to return to the main menu", 0, 120, VIRTUAL_WIDTH, 'center')
    elseif self.gamestate == "loss" then
        love.graphics.setFont(largeFont)
        love.graphics.printf("OH NOOO! You did not got your " .. self.fruitgoal .. "s!", 0, 100, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf("Press SPACE to return to the main menu", 0, 120, VIRTUAL_WIDTH, 'center')
    end

    -- draws tiles
    for y = 1, self.mapHeight do
        for x = 1, self.mapWidth do
            local tile = self:getTile(x, y)
            if tile ~= TILE_EMPTY then
                love.graphics.draw(self.tile,
                    (x - 1) * self.tileWidth, (y - 1) * self.tileHeight)
            end
        end
    end

    -- renders player to the screen
    self.player:render()
end

--[[
    Contains tile data and necessary code for rendering a tile map to the
    main screen.
]]

require 'Util'

Map = Class{}
TILE_EMPTY = -1

TILE = 1
BORDER = 2

APPLE = 1
WATERMELON = 2
BANANA = 3
PEAR = 4
I = 5
WANT = 6
DONT = 7
AM = 8
    
-- constructor for our map object
function Map:init(fruitnum, fruitname)
    self.fruit = fruitnum
    self.froot = fruitname

    -- different tiles that can be represented on the screen
    self.tile = {love.graphics.newImage('graphics/tile.png'), love.graphics.newImage('graphics/brick2.png')}

    -- different fruits that can be represented on the screen
    -- we treated those fruits as tiles
    self.overlay = {love.graphics.newImage('graphics/apple.png'), love.graphics.newImage('graphics/watermelon.png'), love.graphics.newImage('graphics/banana.png'), love.graphics.newImage('graphics/pear.png'), love.graphics.newImage('graphics/i.png'), love.graphics.newImage('graphics/want.png'), love.graphics.newImage('graphics/dont.png'), love.graphics.newImage('graphics/am.png')}

    self.tilesheet = love.graphics.newImage('graphics/brick.png')

    self.music = love.audio.newSource('sounds/music.wav', 'static')

    -- screen resolution in tiles
    self.tileWidth = 32
    self.tileHeight = 32
    self.mapWidth = 14
    self.mapHeight = 14
    
    self.tiles = {}
    self.overlays = {}

    -- cache width and height of map in pixels
    self.mapWidthPixels = self.mapWidth * self.tileWidth
    self.mapHeightPixels = self.mapHeight * self.tileHeight

    -- default gamestate
    self.gamestate = "playing"

    -- tile coordinates of first answer tike
    ANSWERBORDER_START_X = self.mapWidth / 2 - 2
    ANSWERBORDER_START_Y = 1

    -- tile coordinates of first word tile
    WORDBANK_START_Y = self.mapHeight / 2 - 1
    WORDBANK_START_X = self.mapWidth / 2 - 3 

    self.answertilepx = (ANSWERBORDER_START_X) * self.tileWidth -- x coordinate of available answer tile in pixels
    self.answertilepy = (ANSWERBORDER_START_Y) * self.tileHeight -- y coordinate of available answer tile in pixels

    -- first, fill map with empty tiles
    for y = 1, self.mapHeight do
        for x = 1, self.mapWidth do
            
            -- support for multiple sheets per tile; storing tiles as tables 
            self:setTile(x, y, BORDER, self.tiles)
            self:setTile(x, y, TILE_EMPTY, self.overlays)
        end
    end

    -- begin generating the terrain using vertical scan lines
    local x = 1
    while x < self.mapWidth do
        
        -- i tried to make the display of fruits and words more random, but it didn't work that time
        -- index = love.math.random(1, 7)
    
        --         local thing = index % #self.overlays
        --         local thing2 = ( index + 1) % #self.overlays
    
        --         -- fruits in wordbox
        --         self:setTile(x, WORDBANK_START_Y, thing, self.overlays)
        --         self:setTile(x, WORDBANK_START_Y + 1, thing2, self.overlays)

        -- generate the selection box and answer box
        if x > WORDBANK_START_X and x < WORDBANK_START_X + 5 then

            -- two rows of wordbox
            self:setTile(x + 1, WORDBANK_START_Y, TILE, self.tiles)
            self:setTile(x, WORDBANK_START_Y + 1, TILE, self.tiles)

            -- fruits in wordbox
            self:setTile(x + 1, WORDBANK_START_Y, x % #self.overlays, self.overlays)
            self:setTile(x, WORDBANK_START_Y + 1, x % #self.overlays - 4, self.overlays)

        
            self:setTile(ANSWERBORDER_START_X + 1, ANSWERBORDER_START_Y + 1, TILE, self.tiles)
            self:setTile(ANSWERBORDER_START_X + 2, ANSWERBORDER_START_Y + 1, TILE, self.tiles)
            self:setTile(ANSWERBORDER_START_X + 3, ANSWERBORDER_START_Y + 1, TILE, self.tiles)
            
            x = x + 1
        else
            for ypos = self.mapHeight / 2, self.mapHeight / 2 + 3 do
                self:setTile(x, ypos, BORDER, self.tiles)
                end
    
            x = x + 1
        end
    end

    -- start the background music
    self.music:setLooping(true)
    self.music:play()

end

-- return whether a given tile is clickable
-- we only want to be able to click tiles that have fruits overlaid on them
function Map:clickable(tile)
    print(self:tileAt(tile.x, tile.y, self.overlays).id)
    if self:tileAt(tile.x, tile.y, self.overlays).id ~= TILE_EMPTY then 
        return true
    else
        return false
    end
end

-- determines which of the three answer tiles are available for fruit overlay upon future user click
function Map:available()
    if self:tileAt(self.answertilepx, self.answertilepy, self.overlays).id == TILE_EMPTY then index = 0
    elseif self:tileAt(self.answertilepx + self.tileWidth, self.answertilepy, self.overlays).id == TILE_EMPTY then index = 1
    elseif self:tileAt(self.answertilepx + (2 * self.tileWidth), self.answertilepy, self.overlays).id == TILE_EMPTY then index = 2
    else return nil
    end

    -- returns tile available for overlay, otherwise returns nil
    return self:tileAt(self.answertilepx + (index * self.tileWidth), self.answertilepy, self.overlays)
end

-- looks through answer slots and sets tile in next empty spot
function Map:guess(guessId, availableTile)
    -- for the future:self:available SHOULD be that this function just does the work
    self:setTile(availableTile.x, availableTile.y, guessId, self.overlays)
    return true
end

-- checks whether answer tiles match the sequence of "I WANT [fruit]"
function Map:check(fruit)

    if self:tileAt(self.answertilepx, self.answertilepy, self.overlays).id == I and 
        self:tileAt(self.answertilepx + self.tileWidth, self.answertilepy, self.overlays).id == WANT and 
        self:tileAt(self.answertilepx + 2 * self.tileWidth, self.answertilepy, self.overlays).id == fruit then

        return true
    else
        return false
    end
end

-- clears answer tiles of their overlays
function Map:reset()
    local answertilex = self:tileAt(self.answertilepx, self.answertilepy, self.overlays).x
    local answertiley = self:tileAt(self.answertilepx, self.answertilepy, self.overlays).y

    self:setTile(answertilex, answertiley, TILE_EMPTY, self.overlays)
    self:setTile(answertilex + 1, answertiley, TILE_EMPTY, self.overlays)
    self:setTile(answertilex + 2, answertiley, TILE_EMPTY, self.overlays)
end

-- function to update camera offset with delta time
function Map:update(dt)

    -- music only plays when the fruits start falling
    if self.gamestate ~= "correct" or self.gamestate ~= "off" then
        self.music:play()
    else
        self.music:stop()
    end

    local current = self:available()
    if current then -- if a tile is free
        if self.gamestate == "Clicked?" then -- and something was clicked
            local clickedTile = self:tileAt(clickedX, clickedY, self.overlays)
            print(clickedTile.id)
            if clickedTile.id ~= TILE_EMPTY then  -- and that something was clickable and in the word bank
                self.gamestate = "Clicked!" 
                self:guess(clickedTile.id, current)  -- add that tile to the answerbox
            end
        end
    else -- if all tiles are filled up
        if self:check(self.fruit) then -- if three tiles are in correct order
            self.gamestate = "correct"
            self.music:stop()
            love.timer.sleep( 25 * dt )
            self.gamestate = "off"
        else -- if tiles are in incorrect order
            love.timer.sleep( 25 * dt )
            self:reset() -- make all tiles blank again
        end
    end
end

-- gets the tile type at a given pixel coordinate and tileset
function Map:tileAt(x, y, tileset)
    local x2 = math.floor(x / self.tileWidth) + 1 -- in tiles
    local y2 = math.floor(y / self.tileHeight) + 1 -- in tiles
    local id = self:getTile(math.floor(x / self.tileWidth) + 1, math.floor(y / self.tileHeight) + 1, tileset)
    
    return {
        x = x2,
        y = y2,
        id = id
    }
end

-- returns an integer value for the tile at a given x-y coordinate and tileset
function Map:getTile(x, y, tileset)
    return tileset[(y - 1) * self.mapWidth + x]
end

-- sets a tile at a given x-y coordinate to an integer value and tileset
function Map:setTile(x, y, id, tileset)
    tileset[(y - 1) * self.mapWidth + x] = id
end

-- renders our map to the screen, to be called by main's render
function Map:render()

    -- renders tiles
    for y = 1, self.mapHeight do
        for x = 1, self.mapWidth do
            local tile = self:getTile(x, y, self.tiles)
            if tile ~= TILE_EMPTY then
                love.graphics.draw(self.tile[tile],
                    (x - 1) * self.tileWidth, (y - 1) * self.tileHeight)
            end
        end
    end

    -- renders fruit overlay
    for y = 1, self.mapHeight do
        for x = 1, self.mapWidth do
            local tile = self:getTile(x, y, self.overlays)
            if tile ~= TILE_EMPTY then
                love.graphics.draw(self.overlay[tile],
                    (x - 1) * self.tileWidth, (y - 1) * self.tileHeight)
            end
        end
    end

    -- renders text
    if self.gamestate ~= "correct" then
        love.graphics.setFont(largeFont)
        love.graphics.printf("Do you want a " .. self.froot .. "?", 0, VIRTUAL_HEIGHT / 2 - 30, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf("Hint: yes", 0, VIRTUAL_HEIGHT / 2 - 11, VIRTUAL_WIDTH, 'center')
    elseif self.gamestate == "correct" then
        love.graphics.setFont(scoreFont)
        love.graphics.printf("WOOT!", 0, VIRTUAL_HEIGHT / 2 - 25, VIRTUAL_WIDTH, 'center')
    end

end

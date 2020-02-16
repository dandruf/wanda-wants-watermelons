--[[
    Represents our fruits in the game. Its only job is to fall because all other 
    behaviors must be considered in context of the entire table of fruits
]]

Melon = Class{}

local FALLING_SPEED = love.math.random(50, 75)

function Melon:init(fruitgoal, fruit, fallx)
    -- fruitgoal so the game knows which will have a good or bad effect on the sprite

    self.width = 32
    self.height = 32
    
    self.x = fallx
    self.y = 0 - self.height

    self.fruit = fruit

    -- the texture of the fruit will be the file of the same fruit
    -- this is why it's important that each fruit's image file uses the same naem as the actual fruit
    self.texture = love.graphics.newImage('graphics/' .. self.fruit ..'.png')

    -- whether a fruit is a nice fruit is determined when initiating a new MelonMap object
    -- nice fruits help the sprite through increasing points
    if self.fruit == fruitgoal then
        self.nice = true 
    else
        self.nice = false
    end

    -- y velocity
    self.dy = FALLING_SPEED
end

function Melon:update(dt)
    -- fruit continues to fall
    self.y = self.y + self.dy * dt
end

function Melon:render()
    local scaleX

    -- draw sprite with scale factor and offsets
    love.graphics.draw(self.texture, math.floor(self.x),
        math.floor(self.y), 0, scaleX, 1)
end

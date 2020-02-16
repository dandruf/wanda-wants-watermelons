--[[
    Represents each life the player has, in hearts <3
]]

Life = Class{}

function Life:init(x)
    -- Heart's coordinates on screen
    self.x = x
    self.y = 2

    -- Heart's width and height
    self.width = 13
    self.height = 12

    -- Heart can either be full or empty, but default is full
    self.textures = {love.graphics.newImage('graphics/heart-full.png'),
    love.graphics.newImage('graphics/heart-empty.png')}
    
    self.texture = self.textures[1]
    self.filled = true 

end

function Life:update(dt)

    -- sprite will either be full heart or empty heart
    if self.filled then
        self.texture = self.textures[1]
    else
        self.texture = self.textures[2]
    end
end

function Life:render()
    local scaleX = 1.5
    local scaleY = 1.5

    -- draw life with scale factor
    love.graphics.draw(self.texture, math.floor(self.x),
        math.floor(self.y), 0, scaleX, scaleY)
end
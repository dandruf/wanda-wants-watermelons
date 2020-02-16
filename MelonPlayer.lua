--[[
    Represents our MelonPlayer in the game, with its own sprite.
]]

MelonPlayer = Class{}

local WALKING_SPEED = 100 

function MelonPlayer:init(map)

    self.points = 0
    self.lives = 3
    
    self.x = 0
    self.y = 0
    self.width = 16
    self.height = 20

    -- offset from top left to center to support sprite flipping
    self.xOffset = 8
    self.yOffset = 10

    -- reference to map for checking tiles
    self.map = map
    self.texture = love.graphics.newImage('graphics/blue_alien.png')

    -- sound effects
    -- self.sounds = {
    --     ['hit'] = love.audio.newSource('sounds/hit.wav', 'static'),
    --     ['coin'] = love.audio.newSource('sounds/coin.wav', 'static'),
    --     ['death'] = love.audio.newSource('sounds/kill2.wav', 'static'),
    --     ['victory'] = love.audio.newSource('sounds/pickup.wav', 'static')
    -- }

    -- animation frames
    self.frames = {}

    -- current animation frame
    self.currentFrame = nil

    -- used to determine behavior and animations
    self.state = 'idle'

    -- determines sprite flipping
    self.direction = 'left'

    -- x and y velocity
    self.dx = 0
    self.dy = 0

    -- position on top of map tiles
    self.y = map.tileHeight * (map.mapHeight - 3) - self.height
    self.x = map.tileWidth * 10

    -- initialize all MelonPlayer animations
    self.animations = {
        ['idle'] = Animation({
            texture = self.texture,
            frames = {
                love.graphics.newQuad(0, 0, 16, 20, self.texture:getDimensions())
            }
        }),
        ['walking'] = Animation({
            texture = self.texture,
            frames = {
                love.graphics.newQuad(128, 0, 16, 20, self.texture:getDimensions()),
                love.graphics.newQuad(144, 0, 16, 20, self.texture:getDimensions()),
                love.graphics.newQuad(160, 0, 16, 20, self.texture:getDimensions()),
                love.graphics.newQuad(144, 0, 16, 20, self.texture:getDimensions()),
            },
            interval = 0.15
        })
    }

    -- initialize animation and current frame we should render
    self.animation = self.animations['idle']
    self.currentFrame = self.animation:getCurrentFrame()

    -- behavior map we can call based on MelonPlayer state
    self.behaviors = {
        ['idle'] = function(dt)
            
            if love.keyboard.isDown('left') then
                self.direction = 'left'
                self.dx = -WALKING_SPEED
                self.state = 'walking'
                self.animations['walking']:restart()
                self.animation = self.animations['walking']
            elseif love.keyboard.isDown('right') then
                self.direction = 'right'
                self.dx = WALKING_SPEED
                self.state = 'walking'
                self.animations['walking']:restart()
                self.animation = self.animations['walking']
            else
                self.dx = 0
            end
        end,
        ['walking'] = function(dt)
            
            -- keep track of input to switch movement while walking, or reset
            -- to idle if we're not moving
            if love.keyboard.isDown('left') then
                self.direction = 'left'
                self.dx = -WALKING_SPEED
            elseif love.keyboard.isDown('right') then
                self.direction = 'right'
                self.dx = WALKING_SPEED
            else
                self.dx = 0
                self.state = 'idle'
                self.animation = self.animations['idle']
            end

            -- check for collisions moving left and right
            self:checkWallCollision()
        end
    }
end

function MelonPlayer:update(dt)
    self.behaviors[self.state](dt)
    self.animation:update(dt)
    self.currentFrame = self.animation:getCurrentFrame()

    self.x = self.x + self.dx * dt
end

-- determines whether player sprite is has touched the sides of the game
function MelonPlayer:checkWallCollision()
    if self.dx > 0 and self.x >= (VIRTUAL_WIDTH - self.map.tileWidth) then
        -- if so, reset velocity and position and change state
        self.dx = 0
        self.x = (self.map:tileAt(self.x + self.width, self.y).x - 1) * self.map.tileWidth - self.width
        -- self.x = self.map:tileAt(self.x - 1, self.y).x * self.map.tileWidth
    elseif self.dx < 0 and self.x <= 1 then
        -- if so, reset velocity and position and change state
        self.dx = 0
        self.x = self.map:tileAt(self.x - 1, self.y).x * self.map.tileWidth
    end
end

function MelonPlayer:render()
    local scaleX

    -- set negative x scale factor if facing left, which will flip the sprite
    -- when applied
    if self.direction == 'right' then
        scaleX = 1
    else
        scaleX = -1
    end

    -- draw sprite with scale factor and offsets
    love.graphics.draw(self.texture, self.currentFrame, math.floor(self.x + self.xOffset),
        math.floor(self.y + self.yOffset), 0, scaleX, 1, self.xOffset, self.yOffset)
end

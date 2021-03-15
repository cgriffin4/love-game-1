local Character = require 'models.character'
local Player = Character:extend()

function Player:new(x, y, height, width, imageSrc, speedMultiplier, health)
    Player.super.new(self, x, y, height, width, imageSrc, speedMultiplier, health)
    self.slope = 0
    self.angle = 0
    self.isForward = 1
end

function Player:draw()
    Player.super.draw(self)
    
    local sX = 0
    local sY = 0
    local distance = 75
    if self.slope == 0 then
        sX = self.x + (distance * self.isForward)
        sY = self.y
    else
        local dx = distance / math.sqrt(1 + (self.slope * self.slope))
        local dy = self.slope * dx
        sX = self.x + (dx * self.isForward)
        sY = self.y + (dy * self.isForward)
    end

    --handle infinite

    love.graphics.rectangle("fill", sX, sY, 5, 5)
end

-- I don't know. Need to translate mouse movement into player angle, then draw player angle visibility, then bullets need leave at that angle
function Player:updateAim(x, y)
    self.slope = (self.y - y) / (self.x - x)
    local a = math.atan(self.slope)
    if x > self.x then 
        self.isForward = 1
        if self.slope > 0 then
            --quadrant 4
            self.angle = 2 * math.pi - a
        else
            --quadrant 1
            self.angle = -1 * a
        end
    else
        self.isForward = -1
        if self.slope > 0 then
            --quadrant 2
            self.angle = math.pi - a
        else
            --quadrant 3
            self.angle = math.pi + (-1 * a)
        end
    end
end

local bob = Player(100, 100, 25, 25, "images/characters/bob/default.png", 1.5, 400)

local characters = {bob}
return characters
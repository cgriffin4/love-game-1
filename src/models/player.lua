Player = Character:extend()

function Player:new(imageSrc, speedMultiplier, health)
    Player.super.new(self, 100, 100, 25, 19.5, imageSrc, speedMultiplier, health)
    --Midpoint for mouse aiming NOTE: need to place somewhere if scaling/resolution change
    self.mX = self.x + (self.width / 2)
    self.mY = self.y + (self.height / 2)
end

function Player:draw()
    Player.super.draw(self)
    
    local sX = 0
    local sY = 0
    local distance = 75
    if self.slope == 0 then
        sX = self.mX + (distance * self.isForward)
        sY = self.mY
    else
        local dx = distance / math.sqrt(1 + (self.slope * self.slope))
        local dy = self.slope * dx
        sX = self.mX + (dx * self.isForward)
        sY = self.mY + (dy * self.isForward)
    end

    --handle infinite

    love.graphics.rectangle("fill", sX, sY, 5, 5)
    love.graphics.rectangle("fill", self.mX, self.mY, 1, 1)
end

-- I don't know. Need to translate mouse movement into player angle, then draw player angle visibility, then bullets need leave at that angle
function Player:updateAimMouse(x, y)
    self.slope = (self.mY - y) / (self.mX - x)
    local a = math.atan(self.slope)
    if x > self.mX then 
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

function Player:updateAimJoystick(x, y)
    self.slope = y / x
    local a = math.atan(self.slope)
    if x > 0 then
        self.isForward = 1
        if y > 0 then
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
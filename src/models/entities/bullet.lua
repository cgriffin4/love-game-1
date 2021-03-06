local Entity = require "models.entities._base"
local Bullet = Entity:extend()

--We pass the x and y of the player.
function Bullet:new(x, y, height, width, speed, angle, lifetime, damage)
    self.x = x
    self.y = y
    self.height = height
    self.width = width
    self.speed = speed
    --self.angle = angle * (180 / 3.141592)
    self.angle = angle
    self.lifetime = lifetime
    self.damage = damage
end

function Bullet:update(dt)
    self.x = self.x + math.cos(self.angle) * self.speed * dt
    self.y = self.y - math.sin(self.angle) * self.speed * dt

    if(self.x < 0 or self.x > love.graphics.getWidth() or self.y < 0 or self.y > love.graphics.getHeight()) then
        self.lifetime = -1
    else
        self.lifetime = self.lifetime - dt
    end
end

function Bullet:draw()
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
end

return Bullet
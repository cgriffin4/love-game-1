local Entity = require "models.entities._base"
local Wall = Entity:extend()

function Wall:new(x, y, height, width)
    Wall.super.new(self, x, y, height, width)

    self.strength = 100
end

function Wall:draw()
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
end

return Wall
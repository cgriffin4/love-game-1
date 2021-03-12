local Object = require "modules.classic"
local Entity = Object:extend()

function Entity:new(x, y, height, width)
    self.x=x
    self.y=y
    self.height=height
    self.width=width
end

function Entity:draw()

end

return Entity
local Entity = require "models.entities._base"
local Weapon = Entity:extend()

function Weapon:new(weapon_data)
    --Entity:new(x, y, height, width)
    Weapon.super.new(self, -100, -100, 10, 20)

    self.reload = weapon_data.reload
    self.damage = weapon_data.damage

    --Image
    self.image = love.graphics.newImage(weapon_data.imageSrc.static)
    local scaleX = self.width / self.image:getWidth()
    local scaleY = self.height / self.image:getHeight()
    if scaleX > scaleY then
        self.scale = scaleX
    else
        self.scale = scaleY
    end
end

function Weapon:draw(slope, isForward)
    Weapon.super.draw(self)
    local angle = math.atan(slope)

    local scaleX = -1 * self.scale
    if isForward == 1 then
        scaleX = self.scale
    end

    love.graphics.draw(self.image, self.x, self.y, angle, scaleX, self.scale)
end

return Weapon
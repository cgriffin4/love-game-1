local Entity = require 'models.entity'
local Character = Entity:extend()

function Character:new(x, y, height, width)
    Character.super.new(self, x, y, height, width)
    self.speed=15
end

local PlayableCharacter = Character:extend()

function PlayableCharacter:new(speedMultiplier, imageSrc)
    PlayableCharacter.super.new(self, 100, 100, 10, 10)
    --Speed
    self.speed = self.speed * speedMultiplier
    --Image
    self.image = love.graphics.newImage(imageSrc)
    local scaleX = self.x / self.image:getWidth()
    local scaleY = self.y / self.image:getHeight()
    if scaleX > scaleY then
        self.scale = scaleX
    else
        self.scale = scaleY
    end
    --Color
    self.color = {a = 1, r = 1, g = 0.5, b = 0.5}
end

function PlayableCharacter:draw()
    love.graphics.setColor(self.color.a, self.color.r, self.color.g, self.color.b);
    love.graphics.draw(self.image, self.x, self.y, 0, self.scale, self.scale, self.width / 2, self.height / 2, 0, 0)
    love.graphics.setColor(1, 1, 1)
end

local bob = PlayableCharacter(2, "images/characters/bob/default.png")

local characters = {bob}
return characters
local Character = require 'models.character'
local Enemy = Character:extend()

function Enemy:new(x, y, height, width, imageSrc, speedMultiplier, health)
    Enemy.super.new(self, x, y, height, width, imageSrc, speedMultiplier, health)
end

local steve = Enemy(300, 300, 50, 50, "images/characters/bob/default.png", 2, 200)

local enemies = {steve}
return enemies
local Character = require "models.entities.characters._base"
local Enemy = Character:extend()

function Enemy:new(enemy_data, x, y)
    --Character:new(x, y, height, width, imageSrc, speedMultiplier, health)
    Enemy.super.new(self, 300, 300, 50, 39, enemy_data.imageSrc.walk, enemy_data.mod_speed, enemy_data.health)
end

return Enemy
local Character = require 'models.character'
local Player = Character:extend()

function Player:new(x, y, height, width, imageSrc, speedMultiplier, health)
    Player.super.new(self, x, y, height, width, imageSrc, speedMultiplier, health)
end

local bob = Player(100, 100, 50, 50, "images/characters/bob/default.png", 4, 400)

local characters = {bob}
return characters
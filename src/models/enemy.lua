Enemy = Character:extend()

function Enemy:new(imageSrc, speedMultiplier, health)
    Enemy.super.new(self, 300, 300, 50, 39, imageSrc, speedMultiplier, health)
end
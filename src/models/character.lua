Character = Entity:extend()

function Character:new(x, y, height, width, imageSrc, speedMultiplier, health)
    Character.super.new(self, x, y, height, width)
    --Speed/Health
    self.speed = 150 * speedMultiplier
    self.health = health
    --Image
    self.image = love.graphics.newImage(imageSrc)
    local scaleX = self.width / self.image:getWidth()
    local scaleY = self.height / self.image:getHeight()
    if scaleX > scaleY then
        self.scale = scaleX
    else
        self.scale = scaleY
    end
    --Color
    self.color = {a = 1, r = 1, g = 0.5, b = 0.5}
    --Direction Facing
    self.slope = 0
    self.angle = 0
    self.isForward = 1
    --Midpoint for mouse aiming NOTE: need to place somewhere if scaling/resolution change
    self.mX = self.x + (self.width / 2)
    self.mY = self.y + (self.height / 2)

    self.attack = 0
end

function Character:update(dt)
    self.attack = self.attack - dt
end

function Character:draw()
    love.graphics.setColor(self.color.a, self.color.r, self.color.g, self.color.b);
    love.graphics.draw(self.image, self.x, self.y, 0, self.scale, self.scale)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
end

function Character:move(direction, dt)
    -- Do movement
    if(direction == 0) then
        self.y = self.y - self.speed * dt
    elseif(direction == 1) then
        self.x = self.x + self.speed * dt
    elseif(direction == 2) then
        self.y = self.y + self.speed * dt
    elseif(direction == 3) then
        self.x = self.x - self.speed * dt
    end

    --Check screen bounds
    local window_width = love.graphics.getWidth()
    if self.x < 0 then
        self.x = 0
    elseif self.x + self.width > window_width then
        self.x = window_width - self.width
    end
    local window_height = love.graphics.getHeight()
    if self.y < 0 then
        self.y = 0
    elseif self.y + self.height > window_height then
        self.y = window_height - self.height
    end
    
    --TODO: change after collision detection rework
    self:setPosition(self.x, self.y)
end

function Character:setPosition(x, y)
    self.x = x
    self.y = y
    --Midpoint for mouse aiming NOTE: need to place somewhere if scaling/resolution change
    self.mX = self.x + (self.width / 2)
    self.mY = self.y + (self.height / 2)
end

function Character:fire()
    print(self.attack)
    if self.attack > 0 or self.weapon == nil then
        return false
    end

    self.attack = self.weapon.reload

    --the bullet shouldn't start within character, but outside of them, might be better to use weapon pos/angle later
    local sX = 0
    local sY = 0
    local distance = math.sqrt(((self.width / 2) * (self.width / 2)) + ((self.height / 2) * (self.height / 2))) + 5
    --Temp - would need to incorporate angles but again gun position might make more sense
    if self.slope == 0 then
        sX = self.mX + (distance * self.isForward)
        sY = self.mY
    else
        local dx = distance / math.sqrt(1 + (self.slope * self.slope))
        local dy = self.slope * dx
        sX = self.mX + (dx * self.isForward)
        sY = self.mY + (dy * self.isForward)
    end

    return Bullet(sX, sY, 5, 5, 150, self.angle, 500, self.weapon.damage)
end
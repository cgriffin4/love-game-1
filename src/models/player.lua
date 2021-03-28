Player = Character:extend()

function Player:new(imageSrc, speedMultiplier, health)
    Player.super.new(self, -100, -100, 25, 19.5, imageSrc, speedMultiplier, health)
    --Midpoint for mouse aiming NOTE: need to place somewhere if scaling/resolution change
    self.mX = self.x + (self.width / 2)
    self.mY = self.y + (self.height / 2)
end

function Player:draw()
    Player.super.draw(self)
    
    local sX = 0
    local sY = 0
    local distance = 75
    if self.slope == 0 then
        sX = self.mX + (distance * self.isForward)
        sY = self.mY
    else
        local dx = distance / math.sqrt(1 + (self.slope * self.slope))
        local dy = self.slope * dx
        sX = self.mX + (dx * self.isForward)
        sY = self.mY + (dy * self.isForward)
    end

    --handle infinite

    love.graphics.rectangle("fill", sX, sY, 5, 5)
    love.graphics.rectangle("fill", self.mX, self.mY, 1, 1)
end

function Player:update(mouse, dt)
    Player.super.update(self, dt)
    --return value
    local bulletFired = nil
    --keyboard movement
    if love.keyboard.isDown("d") then
        self:move(1, dt)
    end
    if love.keyboard.isDown("a") then
        self:move(3, dt)
    end
    if love.keyboard.isDown("w") then
        self:move(0, dt)
    end
    if love.keyboard.isDown("s") then
        self:move(2, dt)
    end

    --Update player aim
    if joysticks[1] ~= nil then
        -- getGamepadAxis returns a value between -1 and 1.
        -- It returns 0 when it is at rest

        local axis1X = joysticks[1]:getGamepadAxis("leftx")
        local axis1Y = joysticks[1]:getGamepadAxis("lefty")

        local axis2X = joysticks[1]:getGamepadAxis("rightx")
        local axis2Y = joysticks[1]:getGamepadAxis("righty")

        local triggerRight = joysticks[1]:getGamepadAxis("triggerright")

        if triggerRight > self.deadzone then
            local b = self:fire()
            if b ~= false then
                print(b.damage)
                bulletFired = b
            end
        end
        if axis1X > self.deadzone then
            self:move(1, dt)
        elseif axis1X < -1 * self.deadzone then
            self:move(3, dt)
        end
        if axis1Y < -1 * self.deadzone then
            self:move(0, dt)
        elseif axis1Y > self.deadzone then
            self:move(2, dt)
        end
        self:updateAimJoystick(axis2X, axis2Y)
    else
        --mouse
        if self.mouse == true then
            self:updateAimMouse(mouse[1], mouse[2])
            if love.mouse.isDown(1) then
                local b = self:fire()
                if b ~= false then
                    print(b.damage)
                    bulletFired = b
                end
            end
        end
    end

    return bulletFired
end

function Player:resolveKeyPress(key)
    print('player key', key)
end

function Player:resetMousePosition()
    --TODO: maintain angle between menu swaps by setting mouse based on angle?
    self.angle = 0
    love.mouse.setPosition(self.x +50, self.y)
end

-- I don't know. Need to translate mouse movement into player angle, then draw player angle visibility, then bullets need leave at that angle
function Player:updateAimMouse(x, y)
    self.slope = (self.mY - y) / (self.mX - x)
    local a = math.atan(self.slope)
    if x > self.mX then 
        self.isForward = 1
        if self.slope > 0 then
            --quadrant 4
            self.angle = 2 * math.pi - a
        else
            --quadrant 1
            self.angle = -1 * a
        end
    else
        self.isForward = -1
        if self.slope > 0 then
            --quadrant 2
            self.angle = math.pi - a
        else
            --quadrant 3
            self.angle = math.pi + (-1 * a)
        end
    end
end

function Player:updateAimJoystick(x, y)
    self.slope = y / x
    local a = math.atan(self.slope)
    if x > 0 then
        self.isForward = 1
        if y > 0 then
            --quadrant 4
            self.angle = 2 * math.pi - a
        else
            --quadrant 1
            self.angle = -1 * a
        end
    else
        self.isForward = -1
        if self.slope > 0 then
            --quadrant 2
            self.angle = math.pi - a
        else
            --quadrant 3
            self.angle = math.pi + (-1 * a)
        end
    end
end
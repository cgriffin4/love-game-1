--local Character = require "models.entities.characters._base"
local requireRel
if arg and arg[0] then
    package.path = arg[0]:match("(.-)[^\\/]+$") .. "?.lua;" .. package.path
    requireRel = require
elseif ... then
    local d = (...):match("(.-)[^%.]+$")
    function requireRel(module) return require(d .. module) end
end
local Character = requireRel("_base")
local Player = Character:extend()

function Player:new(player_data, player_controller, player_profile)
    --Character:new(x, y, height, width, imageSrc, speedMultiplier, health)
    Player.super.new(self, -100, -100, 25, 19.5, player_data.imageSrc.walk, player_data.mod_speed, player_data.health)
    --Weapon
    self:setWeapon(player_data.weapon_start)
    --Controller stuff
    self.controller = player_controller
    --Preferences stuff
    self.profile = player_profile

    --Midpoint for mouse aiming NOTE: need to place somewhere if scaling/resolution change
    self.mX = self.x + (self.width / 2)
    self.mY = self.y + (self.height / 2)
    self.weapon.x = self.mX
    self.weapon.y = self.mY
end

function Player:setWeapon(weapon_name)
    self.weapon = game:constructorFor("weapon", weapon_name)
end

function Player:draw()
    Player.super.draw(self)
    
    local sX = 0
    local sY = 0
    local distance = 75
    --TODO: handle infinite
    if self.slope == 0 then
        sX = self.mX + (distance * self.isForward)
        sY = self.mY
    else
        local dx = distance / math.sqrt(1 + (self.slope * self.slope))
        local dy = self.slope * dx
        sX = self.mX + (dx * self.isForward)
        sY = self.mY + (dy * self.isForward)
    end

    --Draw Aim
    love.graphics.setColor(0, 0, 1)
    love.graphics.rectangle("fill", sX, sY, 5, 5)
    --Draw Debug rect
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", self.mX, self.mY, 1, 1)
end

function Player:setJoystick(joystick)
    --self.mouse = false
    self.joystick = joystick
end

function Player:update(dt)
    Player.super.update(self, dt)
    --return value
    local bulletFired = nil
    
    --KEYBOARD update check
    if self.controller.kbm == true then
        --MOVEMENT
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

        if self.mouse and self.mouse[1] then
            --AIM
            self:updateAimMouse(self.mouse[1], self.mouse[2])
            --FIRING
            if love.mouse.isDown(1) then
                local b = self:fire()
                if b ~= false then
                    print(b.damage)
                    bulletFired = b
                end
            end
        end
    end

    --JOYSTICK update check
    if self.joystick ~= nil then
        -- getGamepadAxis returns a value between -1 and 1.
        -- It returns 0 when it is at rest

        local axis1X = self.joystick:getGamepadAxis("leftx")
        local axis1Y = self.joystick:getGamepadAxis("lefty")

        local axis2X = self.joystick:getGamepadAxis("rightx")
        local axis2Y = self.joystick:getGamepadAxis("righty")

        local triggerRight = self.joystick:getGamepadAxis("triggerright")

        --MOVEMENT
        if axis1X > self.profile.deadzone then
            self:move(1, dt)
        elseif axis1X < -1 * self.profile.deadzone then
            self:move(3, dt)
        end
        if axis1Y < -1 * self.profile.deadzone then
            self:move(0, dt)
        elseif axis1Y > self.profile.deadzone then
            self:move(2, dt)
        end
        --AIM
        self:updateAimJoystick(axis2X, axis2Y)
        --FIRING
        if triggerRight > self.profile.deadzone then
            local b = self:fire()
            if b ~= false then
                print(b.damage)
                bulletFired = b
            end
        end
    else
        
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

return Player
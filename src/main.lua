io.stdout:setvbuf("no")
--crtl + ; to launch

local debugItems = {}
local fps = 0
local joysticks = {}
local deadzone = 0.3
local mouse = {0, 0}
local lastbutton = 'none'

local player
local enemies = {}
local bullets = {}
local walls = {}
local tilemap = {{}}

function love.load()
    love.joystick.loadGamepadMappings( "gamecontrollerdb.txt" )

    Object = require "modules.classic"
    require 'models.entity'
    require 'models.character'

    require 'models.bullet'
    require 'models.enemy'
    require 'models.player'
    require 'models.wall'
    require 'models.weapon'

    require 'models.debug'

    fps = Debug('fps', 0)
    table.insert(debugItems, fps)

    level = 0
    menuCursorY = 1
    menuItems = {"Start Game", "Exit Game"}

    local playablecharacters = require("data.playablecharacters")
    local p1 = playablecharacters[1]
    player = Player(p1[1], p1[2], p1[3])
    player.weapon = Weapon(1, 10)

    love.mouse.setRelativeMode(true)
    mouseX = Debug('MouseX', mouse[1])
    mouseY = Debug('MouseY', mouse[2])
    table.insert(debugItems, mouseX)
    table.insert(debugItems, mouseY)
end

function love.mousemoved(x, y, dx, dy, istouch)
    mouse[1] = x
    mouse[2] = y
    mouseX:update(x)
    mouseY:update(y) 
end

function love.joystickadded(joystick)
    table.insert(joysticks, joystick)
end

function love.gamepadpressed(joystick, button)
    print(button)
    lastbutton = button
end

function love.update(dt)
    fps:update(1 / dt)

    if level == 0 then
        if love.keyboard.isDown("down") and menuCursorY < #menuItems then
            menuCursorY = menuCursorY + 1
        end
        if love.keyboard.isDown("up") and menuCursorY > 1 then
            menuCursorY = menuCursorY - 1
        end
        if love.keyboard.isDown("return") then
            if menuCursorY == 1 then
                player.angle = 0
                love.mouse.setPosition(player.x +50, player.y)
                level = 1
                local enemyTable = require("data.enemies")
                enemies = { Enemy(enemyTable[1][1], enemyTable[1][2], enemyTable[1][3]) }
                tilemap = {
                    {10, 10, 10, 10, 10, 10, 10, 10, 10, 10},
                    {10, 2, 2, 2, 2, 2, 2, 2, 2, 10},
                    {10, 2, 3, 4, 15, 15, 4, 3, 2, 10},
                    {10, 2, 0, 2, 2, 2, 2, 2, 1, 10},
                    {10, 10, 10, 10, 10, 10, 10, 10, 10, 10}
                }
                print('Screen Width', love.graphics.getWidth())
                print('Tilemap Width', #tilemap[1])
                print('Screen Height', love.graphics.getHeight())
                print('Tilemap Height', #tilemap)
                local tm_size = 25
                local tm_width = love.graphics.getWidth() / (#tilemap[1]*tm_size)
                local tm_height = love.graphics.getHeight() / (#tilemap*tm_size)
                local tm_scale = 1
                local tm_h_offset = 0
                local tm_w_offset = 0
                --TODO: probably should use int math.floor above and below here
                if (tm_width < tm_height) then
                    --if width is full then use that to scale
                    tm_scale = tm_width
                    --but we need to adjust height offset
                    tm_h_offset = (tm_height - tm_width) / 2
                else
                    tm_scale = tm_height
                    tm_w_offset = (tm_width - tm_height) / 2
                end
                
                local tm_scaled_size = tm_size * tm_scale
                for i,row in ipairs(tilemap) do
                    for j,tile in ipairs(row) do
                        local x_pos = ((j-1) * tm_scaled_size) + (tm_w_offset * tm_scaled_size)
                        local y_pos = ((i-1) * tm_scaled_size) + (tm_h_offset * tm_scaled_size)
                        --set player position
                        if tile == 0 then
                            player:setPosition(x_pos, y_pos)
                        --set wall positions
                        elseif tile >= 10 then
                            table.insert(walls, Wall(x_pos, y_pos, tm_scaled_size, tm_scaled_size))
                        elseif enemies[tile] ~= nill then
                            --TODO: enemy spawning
                            --temp solution to generating enemies within valid tiles
                            enemies[1]:setPosition(x_pos, y_pos)
                        end
                    end
                end
            end
            if menuCursorY == 2 then
                love.event.quit()
            end
        end
    end

    if level == 1 then
        --temp vars for collision detection
        local x = player.x
        local y = player.y
        
        if love.keyboard.isDown("d") then
            player:move(1, dt)
        end
        if love.keyboard.isDown("a") then
            player:move(3, dt)
        end
        if love.keyboard.isDown("w") then
            player:move(0, dt)
        end
        if love.keyboard.isDown("s") then
            player:move(2, dt)
        end
        
        if love.keyboard.isDown('escape') then
            love.event.quit()
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

            if triggerRight > deadzone then
                local b = player:fire()
                if b ~= false then
                    print(b.damage)
                    table.insert(bullets, b)
                end
            end
            if axis1X > deadzone then
                player:move(1, dt)
            elseif axis1X < -1 * deadzone then
                player:move(3, dt)
            end
            if axis1Y < -1 * deadzone then
                player:move(0, dt)
            elseif axis1Y > deadzone then
                player:move(2, dt)
            end
            player:updateAimJoystick(axis2X, axis2Y)
        else
            --mouse
            player:updateAimMouse(mouse[1], mouse[2])
            if love.mouse.isDown(1) then
                local b = player:fire()
                if b ~= false then
                    print(b.damage)
                    table.insert(bullets, b)
                end
            end

        end
        player:update(dt)

        -- Player Collision Detection (walls and enemies, probably change enemy later)
        for i,enemy in ipairs(enemies)
        do
            if x ~= player.x then
                -- player hit wall
                for j,wall in ipairs(walls) do
                    if player:checkCollision(wall) then
                        player.x = x
                    end
                end
                -- player hit enemy
                if player:checkCollision(enemy) then
                    player.x = x
                end
            end
            if y ~= player.y then
                -- player hit wall
                for j,wall in ipairs(walls) do
                    if player:checkCollision(wall) then
                        player.y = y
                    end
                end
                -- player hit enemy
                if player:checkCollision(enemy) then
                    player.y = y
                end
            end
        end

        -- Bullets
        for i,bullet in ipairs(bullets)
        do
            --Update movement
            bullet:update(dt)
            if bullet.lifetime < 0 then
                table.remove(bullets, i)
            end

            --Wall Collision
            for j,wall in ipairs(walls) do
                if bullet:checkCollision(wall) then
                    table.remove(bullets, i)
                end
            end

            --Enemy Collision
            for j,enemy in ipairs(enemies) do
                if bullet:checkCollision(enemy) then
                    enemy.health = enemy.health - bullet.damage
                    table.remove(bullets, i)
                end
            end

            --Player Collision
            if bullet:checkCollision(player) then
                player.health = player.health - bullet.damage
                table.remove(bullets, i)
            end
        end

    end
end

function love.draw()
    
    if level == 0 then
        if joysticks[1] ~= nil then
            if joysticks[1]:isGamepad() then 
                love.graphics.print(joysticks[1]:getGamepadMappingString(), 0, 0)
            else
                love.graphics.print("false", 0, 0)
            end
            love.graphics.print(joysticks[1]:getGamepadAxis("leftx"), 10, 20)
            love.graphics.print(joysticks[1]:getGamepadAxis("lefty"), 210, 20)
            love.graphics.print(joysticks[1]:getGamepadAxis("rightx"), 410, 20)
            love.graphics.print(joysticks[1]:getGamepadAxis("righty"), 10, 40)
            love.graphics.print(joysticks[1]:getGamepadAxis("triggerleft"), 210, 40)
            love.graphics.print(joysticks[1]:getGamepadAxis("triggerright"), 410, 40)
        end

        for i=1,#menuItems do
            love.graphics.print(menuItems[i], 100, 100 * i)
        end
        
        love.graphics.print(">>", 80, 100*menuCursorY)
    end
    
    if level == 1 then
        for i=1,#debugItems do
            debugItems[i]:draw(0, 10*i-10)
        end

        --for i,row in ipairs(tilemap) do
            --for j,tile in ipairs(row) do
                --if tile >= 5 then
                    --love.graphics.rectangle("line", j * 25, i * 25, 25, 25)
                --end 
            --end
        --end
        for i,wall in ipairs(walls) do
            wall:draw()
        end

        player:draw()
        for i,enemy in ipairs(enemies)
        do
            enemy:draw()
        end
        for i,bullet in ipairs(bullets)
        do
            bullet:draw()
        end
    end
end

function checkCollision(a, b)
    --With locals it's common usage to use underscores instead of camelCasing
    local a_left = a.x
    local a_right = a.x + a.width
    local a_top = a.y
    local a_bottom = a.y + a.height

    local b_left = b.x
    local b_right = b.x + b.width
    local b_top = b.y
    local b_bottom = b.y + b.height

    --If Red's right side is further to the right than Blue's left side.
    if a_right > b_left and
    --and Red's left side is further to the left than Blue's right side.
    a_left < b_right and
    --and Red's bottom side is further to the bottom than Blue's top side.
    a_bottom > b_top and
    --and Red's top side is further to the top than Blue's bottom side then..
    a_top < b_bottom then
        --There is collision!
        return true
    else
        --If one of these statements is false, return false.
        return false
    end
end
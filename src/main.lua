io.stdout:setvbuf("no")
--crtl + ; to launch

joysticks = {}
mouse = {0, 0}

local players = {}
local enemies = {}
local bullets = {}
local walls = {}
local tilemap = {{}}

local menu
local startingPos
local level = 0

local debugItems = {}
local fps = 0
local lastbutton = 'none'

function love.load()
    love.joystick.loadGamepadMappings( "gamecontrollerdb.txt" )

    Object = require "modules.classic"
    require 'game'
    require 'models.entity'
    require 'models.character'

    require 'models.bullet'
    require 'models.enemy'
    require 'models.player'
    require 'models.wall'
    require 'models.weapon'

    require 'models.menu'

    local menus = require("data.menus")
    menu = Menu(menus[1])
    

    local playablecharacters = require("data.playablecharacters")
    local p1 = playablecharacters[1]
    local player = Player(p1[1], p1[2], p1[3])
    player.weapon = Weapon(1, 10)
    table.insert(players, player)
    
    require 'models.debug'

    fps = Debug('fps', 0)
    table.insert(debugItems, fps)

    mouseX = Debug('MouseX', mouse[1])
    mouseY = Debug('MouseY', mouse[2])
    table.insert(debugItems, mouseX)
    table.insert(debugItems, mouseY)
end

--TODO: multiple player controls
--TODO: joystick removed
--TODO: player controller choice
function love.joystickadded(joystick)
    table.insert(joysticks, joystick)
    players[1]:setJoystick(joystick)
end

function love.mousemoved(x, y, dx, dy, istouch)
    mouse[1] = x
    mouse[2] = y
    mouseX:update(x)
    mouseY:update(y) 
end

function love.gamepadpressed(joystick, button)
    print(button)
    lastbutton = button
    if game.isPaused then
        local action = menu:keypressed(key)
        if action ~= nil then
            action()
        end
    else
        -- To be used later for single press actions (like maybe a dash)
        -- TODO: only pass to player controlled by joystick pressed
        for i=1,#players do
            players[i]:resolveKeyPress(button)
        end
    end
end

function love.keypressed(key)
    print(key)
    if game.isPaused then
        local action = menu:keypressed(key)
        if action ~= nil then
            action()
        end
    else
        -- To be used later for single press actions (like maybe a dash)
        -- TODO: only pass to player controlled by mouse/keyboard
        for i=1,#players do
            players[i]:resolveKeyPress(key)
        end
    end
end

function love.update(dt)
    fps:update(1 / dt)

    if game.isPaused == false then
        --TODO: pause game
        if love.keyboard.isDown('escape') then
            love.event.quit()
        end

        -- PLAYER update (movement and attack)
        for i=1,#players do
            local b = players[i]:update(mouse, dt)
            if b ~= nil then
                table.insert(bullets, b)
            end

            -- Player Collision Detection (walls and enemies, probably change enemy later)
            -- player hit wall
            for j,wall in ipairs(walls) do
                players[i]:resolveCollision(wall)
            end
            -- player hit enemy
            for i,enemy in ipairs(enemies) do
                players[i]:resolveCollision(enemy)
            end

        end

        -- Bullets
        for i,bullet in ipairs(bullets)
        do
            --Update movement
            bullet:update(dt)
            if bullet.lifetime < 0 then
                table.remove(bullets, i)
            else
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
                for i=1,#players do
                    if bullet:checkCollision(players[i]) then
                        players[i].health = players[i].health - bullet.damage
                        table.remove(bullets, i)
                    end
                end
            end
        end
    end
end

function love.draw()
    if game.isPaused then
        menu:draw()
    end

    --TODO: change to tilemaps when they become an object
    for i,wall in ipairs(walls) do
        wall:draw()
    end
    -- BULLETS
    for i,bullet in ipairs(bullets) do
        bullet:draw()
    end
    -- ENEMIES
    for i,enemy in ipairs(enemies) do
        enemy:draw()
    end
    -- PLAYERS
    for i,player in ipairs(players) do
        player:draw()
    end

    -- DEBUG
    for i=1,#debugItems do
        debugItems[i]:draw(0, 10*i-10)
    end

    if level == 1 then
        --for i,row in ipairs(tilemap) do
            --for j,tile in ipairs(row) do
                --if tile >= 5 then
                    --love.graphics.rectangle("line", j * 25, i * 25, 25, 25)
                --end 
            --end
        --end
    end
end

function loadLevel(lvl)
    game.level = lvl
    level = lvl
    game:resume()

    if level == 1 then
        local enemyTable = require("data.enemies")
        enemies = { Enemy(enemyTable[1][1], enemyTable[1][2], enemyTable[1][3]) }
        tilemap = {
            {10, 10, 10, 10, 10, 10, 10, 10, 10, 10},
            {10, 2, 2, 2, 2, 2, 2, 2, 2, 10},
            {10, 2, 3, 4, 15, 15, 4, 3, 2, 10},
            {10, 2, 0, 2, 2, 2, 2, 2, 1, 10},
            {10, 10, 10, 10, 10, 10, 10, 10, 10, 10}
        }
        local startingPos = { 0, 0 }
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
                    for i=1,#players do
                        players[i]:setPosition(x_pos, y_pos)
                        players[i]:resetMousePosition()
                    end
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
end
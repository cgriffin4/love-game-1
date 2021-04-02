io.stdout:setvbuf("no")
--crtl + ; to launch

--gameLoopControllers - used to map controllers to player index
local gl_Controllers = {
    playerIndex_kbm = 1
    --,joysticks = {} this is actually dynamically added when a joystick is connected
}

--gameLoopObjects
local gl_Objects = {
    players = {},
    enemies = {},
    bullets = {},
    walls = {},
    tilemap = {{}},
    menu
}

local debugItems = {}
local fps = 0
local lastbutton = 'none'

function love.load()
    love.joystick.loadGamepadMappings( "gamecontrollerdb.txt" )

    --Global Objects { Object, Game }
    Object = require "modules.classic"
    require 'game'

    --set frequently accessed global game data
    game.menus = require("data.menus")
    game.biomes = require("data.biomes")
    -- starter weapons for character selection, loot table weapons will be loaded with biome
    game.weapons = require("data.weapons")

    --Load Start Menu
    gl_Objects.menu = game:constructorFor('menu', 'Main_Menu')

    --TODO: rework debug
    require 'models.debug'

    fps = Debug('fps', 0)
    table.insert(debugItems, fps)

    mouseX = Debug('MouseX', 0)
    mouseY = Debug('MouseY', 0)
    table.insert(debugItems, mouseX)
    table.insert(debugItems, mouseY)
end

--TODO: multiple player controls
--TODO: joystick removed/retest all joystick code since big rewrite
--TODO: player controller choice
function love.joystickadded(joystick)
    --Put into controller list to know which player to pass onbutton press events to
    gl_Controllers[get_JoyUID(joystick)] = 1
    --Add to player object so they can check during player:update
    gl_Objects.players[1]:setJoystick(joystick)
end

function love.mousemoved(x, y, dx, dy, istouch)
    --If a player is using keyboard/mouse update their mouse position
    if gl_Controllers.playerIndex_kbm > 0 and #gl_Objects.players >= gl_Controllers.playerIndex_kbm then
        gl_Objects.players[gl_Controllers.playerIndex_kbm].mouse = { x, y }
        mouseX:update(x)
        mouseY:update(y)
    end
end

function love.gamepadpressed(joystick, button)
    print(button)
    lastbutton = button
    --every player controls menu
    if game.isPaused then
        --TODO: fix this whole process, maybe combine with controller reconnection screen
        if game.level >= 0 then
            local action = gl_Objects.menu:keypressed(key)
            if action ~= nil then
                action()
            end
        else
            game:characterSelectionKeyPress(key, gl_Controllers[get_JoyUID(joystick)])
        end
    else
        -- To be used later for single press actions (like maybe a dash)
        gl_Objects.players[gl_Controllers[get_JoyUID(joystick)]]:resolveKeyPress(button)
    end
end

function love.keypressed(key)
    --every player controls menu
    if game.isPaused then
        --TODO: fix this whole process, maybe combine with controller reconnection screen
        if game.level >= 0 then
            local action = gl_Objects.menu:keypressed(key)
            if action ~= nil then
                action()
            end
        else
            game:characterSelectionKeyPress(key, gl_Controllers.playerIndex_kbm)
        end
    else
        -- To be used later for single press actions (like maybe a dash)
        for i=1,#gl_Objects.players do
            gl_Objects.players[gl_Controllers.playerIndex_kbm]:resolveKeyPress(key)
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
        for i=1,#gl_Objects.players do
            local b = gl_Objects.players[i]:update(dt)
            if b ~= nil then
                table.insert(gl_Objects.bullets, b)
            end

            -- Player Collision Detection (walls and enemies, probably change enemy later)
            -- player hit wall
            for j,wall in ipairs(gl_Objects.walls) do
                gl_Objects.players[i]:resolveCollision(wall)
            end
            -- player hit enemy
            for i,enemy in ipairs(gl_Objects.enemies) do
                gl_Objects.players[i]:resolveCollision(enemy)
            end

        end

        -- Bullets
        for i,bullet in ipairs(gl_Objects.bullets)
        do
            --Update movement
            bullet:update(dt)
            if bullet.lifetime < 0 then
                table.remove(gl_Objects.bullets, i)
            else
                --Wall Collision
                for j,wall in ipairs(gl_Objects.walls) do
                    if bullet:checkCollision(wall) then
                        table.remove(gl_Objects.bullets, i)
                    end
                end

                --Enemy Collision
                for j,enemy in ipairs(gl_Objects.enemies) do
                    if bullet:checkCollision(enemy) then
                        enemy.health = enemy.health - bullet.damage
                        table.remove(gl_Objects.bullets, i)
                    end
                end

                --Player Collision
                for i=1,#gl_Objects.players do
                    if bullet:checkCollision(gl_Objects.players[i]) then
                        gl_Objects.players[i].health = gl_Objects.players[i].health - bullet.damage
                        table.remove(gl_Objects.bullets, i)
                    end
                end
            end
        end
    end
end

function love.draw()
    if game.isPaused then
        --TODO: fix this whole process, maybe combine with controller reconnection screen
        if game.level >= 0 then
            gl_Objects.menu:draw()
        else
            game:characterSelectionDraw()
        end
    end

    --TODO: change to tilemaps when they become an object
    for i,wall in ipairs(gl_Objects.walls) do
        wall:draw()
    end
    -- BULLETS
    for i,bullet in ipairs(gl_Objects.bullets) do
        bullet:draw()
    end
    -- ENEMIES
    for i,enemy in ipairs(gl_Objects.enemies) do
        enemy:draw()
    end
    -- PLAYERS
    for i,player in ipairs(gl_Objects.players) do
        player:draw()
    end

    -- DEBUG
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
end

function GLObject_get(obj)
    return gl_Objects[obj]
end

function GLObject_set(obj, new)
    gl_Objects[obj] = new
end

function GLObject_forEach(obj, fn)
    for i,o in ipairs(gl_Objects[obj]) do
        fn(o)
    end
end

function GLObject_insert(obj, new)
    table.insert(gl_Objects[obj], new)
end

-- Not currently used
function GLObject_apply(obj, fn)
    fn(gl_Objects[obj])
end

--unique ID which changes on reconnect
local get_JoyUID = function(joystick)
    return "playerIndex_" + joystick:getID()
end
io.stdout:setvbuf("no")
--crtl + ; to launch

local bullets = {}

function love.load()
    Object = require "modules.classic"
    require 'models.bullet'

    fps = 0
    level = 0
    menuCursorY = 1
    menuItems = {"Start Game", "Exit Game"}

    local playablecharacters = require("models.playablecharacters")
    player = playablecharacters[1]
end

function love.keypressed(key)
    if key == "space" then
        table.insert(bullets, Bullet(player.x, player.y, 5, 5, 15, math.random(6203) / 1000., 500, 5))
    end
end

function love.update(dt)
    fps = dt * 100

    if level == 0 then
        if love.keyboard.isDown("down") and menuCursorY < #menuItems then
            menuCursorY = menuCursorY + 1
        end
        if love.keyboard.isDown("up") and menuCursorY > 1 then
            menuCursorY = menuCursorY - 1
        end
        if love.keyboard.isDown("return") then
            if menuCursorY == 1 then
                enemies = require("models.enemies")
                
                level = 1
            end
            if menuCursorY == 2 then
                love.event.quit()
            end
        end
    end

    if level == 1 then
        local x = player.x
        local y = player.y
        
        if love.keyboard.isDown("right") then
            player:move(1, dt)
            player.x = player.x + player.speed * dt
        end
        if love.keyboard.isDown("left") then
            player:move(3, dt)
        end
        if love.keyboard.isDown("up") then
            player:move(0, dt)
        end
        if love.keyboard.isDown("down") then
            player:move(2, dt)
        end
        
        if love.keyboard.isDown('escape') then
            love.event.quit()
        end

        -- Enemy Collision Detection
        for i,enemy in ipairs(enemies)
        do
            if x ~= player.x then
                if checkCollision(player, enemy) then
                    player.x = x
                end
            end
            if y ~= player.y then
                if checkCollision(player, enemy) then
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

            --Enemy Collision
            for j,enemy in ipairs(enemies)
            do
                if checkCollision(bullet, enemy) then
                    enemy.health = enemy.health - bullet.damage
                    table.remove(bullets, i)
                end
            end
        end

    end
end

function love.draw()
    
    if level == 0 then
        for i=1,#menuItems do
            love.graphics.print(menuItems[i], 100, 100 * i)
        end
        
        love.graphics.print(">>", 80, 100*menuCursorY)
    end
    
    if level == 1 then
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
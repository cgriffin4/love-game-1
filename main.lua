io.stdout:setvbuf("no")
--crtl + ; to launch


function love.load()
    fps = 0
    level = 0
    menuCursorY = 1
    menuItems = {"Start Game", "Exit Game"}

    character = {}
    character.x = 100
    character.y = 100
    character.speed = 15
end

function love.update(dt)
    fps = dt * 100

    if level == 0 then
        if love.keyboard.isDown("down") and menuCursorY < menuItemCount then
            menuCursorY = menuCursorY + 1
        end
        if love.keyboard.isDown("up") and menuCursorY > 1 then
            menuCursorY = menuCursorY - 1
        end
        if love.keyboard.isDown("return") then
            if menuCursorY == 1 then
                level = 1
            end
            if menuCursorY == 2 then
                love.event.quit()
            end
        end
    end

    if level == 1 then
        if love.keyboard.isDown("right") then
            character.x = character.x + character.speed * dt
        end
        if love.keyboard.isDown("left") then
            character.x = character.x - character.speed * dt
        end
        
        if love.keyboard.isDown("up") then
            character.y = character.y - character.speed * dt
        end
        if love.keyboard.isDown("down") then
            character.y = character.y + character.speed * dt
        end
        
        if love.keyboard.isDown('escape') then
            love.event.quit()
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
        love.graphics.print("Hello World!", character.x, character.y)
    end
end
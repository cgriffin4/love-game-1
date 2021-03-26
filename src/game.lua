Game = Object:extend()

function Game:new()
    self.level = 0
    self.isPaused = true
end

function Game:pause()
    self.isPaused = true
    love.mouse.setRelativeMode(false)
end

function Game:resume()
    self.isPaused = false
    love.mouse.setRelativeMode(true)
end

--Not current used
function Game:loadLevel(level)
    self.level = level
    self:resume()

    if level == 1 then
        local enemyTable = require("data.enemies")
        local enemies = { Enemy(enemyTable[1][1], enemyTable[1][2], enemyTable[1][3]) }
        local tilemap = {
            {10, 10, 10, 10, 10, 10, 10, 10, 10, 10},
            {10, 2, 2, 2, 2, 2, 2, 2, 2, 10},
            {10, 2, 3, 4, 15, 15, 4, 3, 2, 10},
            {10, 2, 0, 2, 2, 2, 2, 2, 1, 10},
            {10, 10, 10, 10, 10, 10, 10, 10, 10, 10}
        }
        local walls = {}
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
                    startingPos = { x_pos, y_pos }
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

        return enemies, tilemap, walls, startingPos
    end
end

game = Game()
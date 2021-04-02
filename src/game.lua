Game = Object:extend()

function Game:new()
    self.level = 0
    self.isPaused = true
    self.constructors = {}
end

function Game:pause()
    self.isPaused = true
    love.mouse.setRelativeMode(false)
end

function Game:resume()
    self.isPaused = false
    --love.mouse.setRelativeMode(true)
end

--Way of caching constructors for game data (weapons, menus, playableCharacters (this one is only used during menu so we won't bother caching))
--TODO: write garbage collection?
function Game:constructorFor(class_name, data_label)
    --Check cache, load file if not cached
    if self.constructors[class_name] == nil then
        if (class_name == "menu") then
            self.constructors[class_name] = require("models.menu")
        elseif (class_name == "weapon") then
            self.constructors[class_name] = require("models.entities.weapon")
        elseif (class_name == "enemy") then
            self.constructors[class_name] = require("models.entities.characters.enemy")
        end
    end
    
    --If not asking for a constructed item by name, then return constructor itself
    if data_label == nil then
        return self.constructors[class_name]
    end
    -- Else, lookup data and construct obj to return
    if (class_name == "weapon") then
        local weapon = self[class_name .. "s"][data_label]
        --TODO: make constructors uniform (new methods take same data object that's stored in data files)
        return self.constructors[class_name](weapon)
    else
        --Enemys are handled correctly here
        --Menus, might be done correctly but still needs testing
        --TODO: test menus, maybe error handling?
        return self.constructors[class_name](self[class_name .. "s"][data_label])    
    end
end

--TODO: fix this whole process, maybe combine with controller reconnection screen
function Game:characterSelection()
    self.level = -1
    self.playablecharacters = require("data.playablecharacters")
    --TODO: tie profiles to controllers... somehow
    self.profiles = { {
        current = { character = 1, ready = false },
        controller_data = { kbm = true },
        save_data = {
            preferences = { deadzone = 0.3 }
        }
    } }
end

--TODO: add gamepad keys, maybe update profile.controller_data here?
function Game:characterSelectionKeyPress(key, i)
    print('game profiles', self.profiles[i].current.character)
    if (key == "right" or key == "d") and self.profiles[i].current.character < #self.playablecharacters then
        self.profiles[i].current.character = self.profiles[i].current.character + 1
    elseif (key == "left" or key == "a") and self.profiles[i].current.character > 1 then
        self.profiles[i].current.character = self.profiles[i].current.character - 1
    elseif (key == "enter" or key == "return") then
        self.profiles[i].current.ready = true
        --Check if last person ready, then start
        local allReady = true
        for i,profile in ipairs(self.profiles) do
            if profile.current.ready == false then
                allReady = false
            end
        end
        if allReady == true then
            self:characterSelectSet()
            self:loadBiome(self.biomes[1])
            self:loadLevel(1)
        end
    end
end

--Sets the gameloop players object, hopefully in the same order as the gameloop controllers (but that needs to be reworked anyway)
function Game:characterSelectSet()
    local Player = require('models.entities.characters.player')

    --Insert players into gameloop data!
    local players = {}
    for i,profile in ipairs(self.profiles) do
        local char = self.playablecharacters[profile.current.character]
        table.insert(players, Player(
            self.playablecharacters[profile.current.character]
            ,profile.controller_data
            ,profile.save_data.preferences))
    end
    GLObject_set("players", players)

    --clear up player selection data
    self.playablecharacters = nil
end

function Game:characterSelectionDraw()
    for i,profile in ipairs(self.profiles) do
        --Current selected character
        local vert = 100
        local horz = 100 * i
        local pre = '<'
        local post = '>'
        if profile.current.character >= #self.playablecharacters then
            post = ''
        elseif profile.current.character <= 1 then
            pre = ''
        end
        love.graphics.print(pre .. self.playablecharacters[profile.current.character].name .. post, horz, vert)
        vert = vert + 100
        --Ready Status
        if profile.current.ready == true then
            love.graphics.print("Enter/A for Ready", horz, vert)
        else
            love.graphics.print("Ready", horz, vert)
        end
    end
end

function Game:loadBiome(biome)
    self.biome = biome
    self.enemys = require(biome.path .. ".enemys")
    --TODO: tilesets, background?
    --TODO: loot tables (additive: after going through a biome it's permenantly added to the list)
end

--TODO: make good
function Game:loadLevel(level)
    self.level = level
    self:resume()

    local Wall = require("models.entities.wall")

    if level == 1 then
        local enemies = {
            self:constructorFor("enemy", 1)--,
            --self:constructorFor("enemy", 2),
            --self:constructorFor("enemy", 1)
        }
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

        GLObject_set("enemies", enemies)
        GLObject_set("tilemap", tilemap)
        GLObject_set("walls", walls)

        --Method 1:
        local players = GLObject_get("players")
        for i,player in ipairs(players) do
            player:setPosition(startingPos[1], startingPos[2])
        end
        --Method 2:
        GLObject_forEach("players", function(player) player:setPosition(startingPos[1], startingPos[2]) end)
    end
end

--TODO: make this the only global variable
game = Game()
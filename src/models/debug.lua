Debug = Object:extend()

function Debug:new(name, value)
    self.name = name
    self.value = value
end

function Debug:update(value)
    self.value = value
end

function Debug:draw(x, y)
    love.graphics.print(self.name .. ":" .. self.value, x, y);
end
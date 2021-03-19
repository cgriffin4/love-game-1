Entity = Object:extend()

function Entity:new(x, y, height, width)
    self.x=x
    self.y=y
    self.height=height
    self.width=width
end

function Entity:draw()

end

function Entity:update()

end

--Checks collision with a provided entity
function Entity:checkCollision(e)
    return self.x + self.width > e.x
        and self.x < e.x + e.width
        and self.y + self.height > e.y
        and self.y < e.y + e.height
end
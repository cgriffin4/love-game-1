Entity = Object:extend()

function Entity:new(x, y, height, width)
    self.x=x
    self.y=y
    self.height=height
    self.width=width

    self.last = {}
    self.last.x = self.x
    self.last.y = self.y

    self.strength = 0
end

function Entity:draw()
    self.last.x = self.x
    self.last.y = self.y
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

function Entity:wasVerticallyAligned(e)
    -- It's basically the collisionCheck function, but with the x and width part removed.
    -- It uses last.y because we want to know this from the previous position
    print('self last y', self.last.y)
    print('needs to be less than', e.last.y + e.height)
    print('self last bottom', self.last.y + self.height)
    print('needs to be greater than', e.last.y)
    print(self.last.y < e.last.y + e.height and self.last.y + self.height > e.last.y)
    return self.last.y < e.last.y + e.height and self.last.y + self.height > e.last.y
end

function Entity:wasHorizontallyAligned(e)
    -- It's basically the collisionCheck function, but with the y and height part removed.
    -- It uses last.x because we want to know this from the previous position
    print('self last y', self.last.x)
    print('self width', self.width)
    print('entity last y', e.last.x)
    print('entity width', e.width)
    return self.last.x < e.last.x + e.width and self.last.x + self.width > e.last.x
end

function Entity:resolveCollision(e)
    --TODO: Add the ability to walk-through some entities (seconday players=clear, wall=stop, enemy=isAttacking?)
    if self.strength > e.strength then
        e:resolveCollision(self)
        -- Return because we don't want to continue this function.
        return
    end
    -------------
    if self:checkCollision(e) then
        if self:wasVerticallyAligned(e) then
            print('was vertical', true)
            if self.x + self.width/2 < e.x + e.width/2 then
                local pushback = self.x + self.width - e.x
                self.x = self.x - pushback
            else
                local pushback = e.x + e.width - self.x
                self.x = self.x + pushback
            end
        elseif self:wasHorizontallyAligned(e) then
            print('was horizontal', true)
            if self.y + self.height/2 < e.y + e.height/2 then
                local pushback = self.y + self.height - e.y
                self.y = self.y - pushback
            else
                local pushback = e.y + e.height - self.y
                self.y = self.y + pushback
            end
        end

        return true
    end

    return false
end
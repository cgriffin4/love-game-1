local Menu = Object:extend()

function Menu:new(menuItems)
    self.options = menuItems
    self.selectedIndex = 1
end

function Menu:display()
    game:pause()
end

--TODO: add gamepad keys
function Menu:keypressed(key)
    if (key == "down" or key == "s") and self.selectedIndex < #self.options then
        self.selectedIndex = self.selectedIndex + 1
    elseif (key == "up" or key == "w") and self.selectedIndex > 1 then
        self.selectedIndex = self.selectedIndex - 1
    elseif (key == "enter" or key == "return") then
        return self.options[self.selectedIndex].onSelection
    end
    return nil
end

function Menu:draw()
    for i=1,#self.options do
        love.graphics.print(self.options[i].label, 100, 100 * i)
    end

    love.graphics.print(">>", 80, 100*self.selectedIndex)
end

return Menu
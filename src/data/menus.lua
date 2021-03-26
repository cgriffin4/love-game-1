local Main_Menu = {
    {
        label = "Start Game",
        onSelection = function()
            loadLevel(1)
        end
    },
    {
        label = "Exit Game",
        onSelection = function()
            love.event.quit()
        end
    }
}

return { Main_Menu }
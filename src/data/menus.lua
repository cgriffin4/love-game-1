local Menus = {
    Main_Menu = {
        {
            label = "Play Local",
            onSelection = function()
                game:characterSelection()
            end
        },
        {
            label = "Exit Game",
            onSelection = function()
                love.event.quit()
            end
        }
    }
}

return Menus
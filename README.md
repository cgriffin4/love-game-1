# About

Just playing with love2d

## Shortcuts

Run with
`ctrl + ;` changed to `F5` (use `ctrl + shift + p` main menu, search for love to change extension bindings)

Build with
`.\build.ps1` or `ctrl + shift + b` (using powershell launch task)

## Outputs

The \build dir will contain folder for web (can move contents to any webserver) as well as a folder for windows (all contents are required). Both could be zipped for building and publishing to itch.io

## Gotchas

Love.js does not work with npm install. I tried it but it grabs a version a few years old. It is currently running by grabbing the src and then running npm install on it and then copying it into the node_modules dir. But it have just been done with the build tools or not be part of node_modules. Not sure the best option.

Love.js does not support netcode, probably. TCP is on the enhancement list though.

Love.js should work with file saving but "Use love.filesystem.getInfo(file_name) before trying to read a potentially non-existent file."

## Resources

LoveWebBuild [https://github.com/schellingb/LoveWebBuilder] - Test to see if build problems are with tool or src (but it does use an old love2d version)

Love.js [https://github.com/Davidobot/love.js] - It builds the website.

Another Kind of World [https://github.com/MadByteDE/Another-Kind-of-World-Remake] - Example game made in Love2D, can check code structure.

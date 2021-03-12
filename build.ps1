Remove-Item build\game-1.love
Compress-Archive -Path src\* -DestinationPath build\game-1.zip -Force
Rename-Item -Path build\game-1.zip -NewName game-1.love
cmd /c copy /b "C:\Program Files\LOVE\love.exe"+build\game-1.love build\windows\game-1.exe
node .\node_modules\love.js\index.js .\build\game-1.love .\build\web -t game-1
Compress-Archive -Path build\web\* build\web.zip -Force
Compress-Archive -Path build\windows\* build\win.zip -Force
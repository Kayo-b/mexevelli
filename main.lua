local GameScene = require('scenes.GameScene')

function love.load()
    currentScene = GameScene:new()
end

function love.update(dt)
    currentScene:update()
end

function love.draw()
    currentScene:draw()
end

function love.mousepressed(x, y, button)
    currentScene:mousepressed(x, y, button)
end
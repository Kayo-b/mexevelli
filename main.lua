local GameScene = require('scenes.GameScene')

function love.load()
    math.randomseed(os.time() + love.timer.getTime() * 1000)
    CurrentScene = GameScene:new()
    love.window.setFullscreen(true)
end

function love.update(dt)
    CurrentScene:update()
end

function love.draw()
    CurrentScene:draw()
end

function love.mousePressed(x, y, button)
    CurrentScene:mousepressed(x, y, button)
end
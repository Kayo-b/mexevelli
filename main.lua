local GameScene = require('scenes.GameScene')

function love.load()
    math.randomseed(os.time() + love.timer.getTime() * 1000)
    CurrentScene = GameScene:new()
    love.window.setFullscreen(false)
    love.window.setMode(1024, 768)
end

function love.update(dt)
    CurrentScene:update()
end

function love.draw()
    CurrentScene:draw()
end

function love.mousepressed(x, y, button)
    print('a')
    CurrentScene:mousepressed(x, y, button)
end
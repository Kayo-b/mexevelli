local GameScene = {}
GameScene.__index = GameScene

local Board = require('game.Board')
local Hand = require('game.Hand')
-- local ScoreTracker = require('game.ScoreTracker')
local MenuPanel = require('ui.MenuPanel')

function GameScene:new()
    local scene = {
        board = Board:new(),
        hand = Hand:new(),
        -- scoreTracker = ScoreTracker:new(),
        menuPanel = MenuPanel:new(),
        gameState = "playing", -- playing, end_turn, round_complete
        currentTurn = 1,
        maxTurns = 5
    }
    setmetatable(scene, GameScene)
    return scene
end

function GameScene:update(dt)
    self.hand:update(dt)
    self.board:update(dt)
    self.menuPanel:update(dt)
end

function GameScene:draw()
    self.board:draw()
    self.hand:draw()
    self.menuPanel:draw()
    -- self.scoreTracker()
end

function GameScene:mousePressed(x, y, button)
    self.hand:mousepressed(x, y, button)
    self.board:mousepressed(x, y, button)
end

return GameScene
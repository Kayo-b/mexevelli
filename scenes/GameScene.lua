local GameScene = {}
GameScene.__index = GameScene

local Board = require('game.Board')
local Hand = require('game.Hand')
local HandValidator = require('game.HandValidator')
-- local ScoreTracker = require('game.ScoreTracker')
local MenuPanel = require('ui.MenuPanel')
local CardGroup = require('game.CardGroup')

function GameScene:new()
    local scene = {
        board = Board:new(),
        hand = Hand:new(),
        handValidator = HandValidator:new(),
        -- scoreTracker = ScoreTracker:new(),
        menuPanel = MenuPanel:new(),
        cardGroup = CardGroup:new(),
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
    local score = self.hand.cardGroup.baseScore or 0
    self.menuPanel:updateScore(score)
    self.menuPanel:update(dt)
    -- self.cardGroup:update(dt)
end

function GameScene:draw()
    self.board:draw()
    self.hand:draw()
    self.menuPanel:draw()
    -- self.cardGroup:draw()
    -- self.scoreTracker()
end

function GameScene:mousepressed(x, y, button)
    if self.hand:mousepressed(x, y, button) then
        return
    end
    local action = self.menuPanel:mousepressed(x, y, button)
    if action == "draw_card" then
        self.hand:drawOneCard()
    elseif action == 'end_turn' then
        --
    elseif action == 'play_cards' then
        local selectedCards = self.hand:getSelectedCards()
        local validHand, score, reason = self.handValidator:validatePlay(selectedCards)
        if validHand then
            local selectedIndices = self.hand:getSelectedCardIndices()
            local playedCards = self.hand:playCards(selectedIndices)
            self.board:addCardGroup(playedCards)
            print("Played " .. #playedCards .. " cards for " .. score .. " points")
        else
            print("Invalid play: " .. (reason or "unknown reason"))
        end
    elseif action == 'sort_cards' then
        print('sort_cards button pressed')
        local sortMode = self.hand:sort()
        self.menuPanel:setSortMode(sortMode)
    elseif action == 'reset_hand' then
        print('reset hand')
        self.hand:resetHand()
    else
        print('pressend on:', button);
    end
    -- self.board:mousepressed(x, y, button)
end

return GameScene
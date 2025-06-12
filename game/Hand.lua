local Hand = {}
Hand.__index = Hand

local Card = require('game.Card')

function Hand:new()
    local hand = {
        cards = {},
        maxCards = 7,
        selectedCards = {},
        x = 10,
        y = love.graphics.getHeight() - 100
    }
    setmetatable(hand, Hand)
    hand:drawCards() -- first draw
    return hand
end

function Hand:drawCards()
    -- Fill hand 
    while #self.cards < self.maxCards do
        table.insert(self.cards, self:generateRandomCard())
    end
end
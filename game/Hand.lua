local Hand = {}
Hand.__index = Hand

local Card = require('game.Card');

function Hand:new()
    local hand = {
        cards = {},
        maxCards = 7,
        selectedCards = {},
        x = 10,
        y = love.graphics.getHeight() - 100
    };
    setmetatable(hand, Hand);
    hand:drawCards(); -- first draw
    return hand;
end

function Hand:drawCards()
    -- Fill hand 
    while #self.cards < self.maxCards do
        table.insert(self.cards, self:generateRandomCard());
    end;
end

function Hand:playCards(cardIndices)
    local playedCards = {};
    -- remove selected cards and return them
    for i = #cardIndices, 1, -1 do
        table.insert(playedCards, table.remove(self.cards, cardIndices[i]));
    end;
    return playedCards;
end

function Hand:generateRandomCard()
    local values = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13};
    local suits = {"hearts", "diamonds", "clubs", "spades"};
    
    local randomValue = values[math.random(1, #values)];
    local randomSuit = suits[math.random(1, #suits)];
    
    return Card:new(randomValue, randomSuit);
end
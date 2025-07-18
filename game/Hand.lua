local Hand = {}
Hand.__index = Hand

local Card = require('game.Card');

function Hand:new()
    local hand = {
        cards = {},
        maxCards = 21,
        initialHand = 11,
        selectedCards = {},
        x = 10,
        y = love.graphics.getHeight()
    };
    setmetatable(hand, Hand);
    hand:drawCards();
    return hand;
end

function Hand:drawCards()
    while #self.cards < self.initialHand do
        table.insert(self.cards, self:generateRandomCard());
    end;
end

function Hand:drawOneCard()
    table.insert(self.cards, self:generateRandomCard());
end

function Hand:playCards(cardIndices)
    local playedCards = {};
    for i = #cardIndices, 1, -1 do
        table.insert(playedCards, table.remove(self.cards, cardIndices[i]));
    end;
    return playedCards;
end

function Hand:getSelectedCardIndices()
    local indices = {}
    for i, card in ipairs(self.cards) do
        if card.selected then
            table.insert(indices, i)
        end
    end
    return indices
end

function Hand:generateRandomCard()
    -- decide if Aces can be lower and higher cards
    local values = {2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14};
    local suits = {"hearts", "diamonds", "clubs", "spades"};

    local randomValue = values[math.random(1, #values)];
    local randomSuit = suits[math.random(1, #suits)];
    -- print('random values: ', randomSuit, randomValue)
    return Card:new(randomValue, randomSuit);
end

function Hand:update(dt)
    for i, card in ipairs(self.cards) do
        card:update(dt)
    end
end

function Hand:draw()
    for i, card in ipairs(self.cards) do
        card.x = self.x + (i - 1) * 60
        card.y = love.graphics.getHeight() - 100
        if card.selected then
            card.y = card.y - 20
        end
        card:draw()
    end
    -- print(self.y, self.x, love.graphics.getHeight())
end

function Hand:mousepressed(x, y, button)
    for i, card in ipairs(self.cards) do
        if x >= card.x and x <= card.x + card.width and
        y >= card.y and y <= card.y + card.height then
            card.selected = not card.selected
            print('card clicked', card.suit, card.value, card.selected)
            return true
        end
    end
    print('No card clicked')
    return false
end

return Hand;
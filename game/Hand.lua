local Hand = {}
Hand.__index = Hand

local Card = require('game.Card')
local HandValidator = require('game.HandValidator')
local CardGroup = require('game.CardGroup')
local aux = require('utils.aux')

function Hand:new()
    local hand = {
        cards = {},
        maxCards = 21,
        initialHand = 11,
        selectedCards = {},
        x = 10,
        y = love.graphics.getHeight(),
        cardGroup = CardGroup:new(),
    };
    setmetatable(hand, Hand);
    hand:drawCards();
    return hand;
end

function Hand:resetHand()
    self.cards = {}
    self.selectedCards = {}
    self:drawCards()
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
    -- --print('random values: ', randomSuit, randomValue)
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
    -- --print(self.y, self.x, love.graphics.getHeight())
end

function Hand:sort()
    HandValidator:sortSuits(self.cards)
    -- local sortType = 'sameKind'
    -- if sortType == 'sameKind' then
    --     table.sort(self.cards, function(a, b)
    --         print(a.value, b.value,'card value')
    --         return a.suitId < b.suitId
    --     end)
    --     for i, card in ipairs(self.cards) do
    --         --print('card and index:', card.value, i)
    --     end
    -- end
end

function Hand:mousepressed(x, y, button)
    for i, card in ipairs(self.cards) do
        if x >= card.x and x <= card.x + card.width and
        y >= card.y and y <= card.y + card.height then
            card.selected = not card.selected
            self.cardGroup:addCards(self.cards)
            table.insert(self.selectedCards, card)
            return true
        end
    end
    --print('No card clicked')
    return false
end

-- if mouse pressed and
-- if mouse is down and
-- if mouse is moving 
-- then
-- get current card index in the current location and save
-- while mouse down track the x y positions of the mouse and update card position to it
-- when mouse is up
-- compare current index with hand card indexes on the array and determine over which card the current position is  over
-- then get the center position of the card 
-- then determine if the current xy position is on the left or right side of the card's center
-- replace the dragged card into the slot  

function Hand:dragCard(x, y, button)
    if button ~= 1 then return end

    for i, card in ipairs(self.cards) do
        if x >= card.x and x <= card.x + card.width and
        y >= card.y and y <= card.y + card.height then
            card.selected = not card.selected
            self.cardGroup:addCards(self.cards)
            table.insert(self.selectedCards, card)
            return true
        end
    end

    --print('No card clicked')
    return false
end

function Hand:handleSelectedCards(card)
    if #self.selectedCards == 0 then
        table.insert(self.selectedCards, card)
    else
        for k, selectedCard in ipairs(self.selectedCards) do
            if card.selected then
                table.remove(self.selectedCards, k)
            else
                table.insert(self.selectedCards, card)
            end
        end
    end
end


return Hand;
local Hand = {}
Hand.__index = Hand

local Deck = require('game.Deck')
local HandValidator = require('game.HandValidator')
local CardGroup = require('game.CardGroup')
local aux = require('utils.aux')

function Hand:new()
    local hand = {
        cards = {},
        maxCards = 21,
        initialHand = 11,
        selectedCards = {},
        sortMode = nil, -- "suit" | "rank": mode applied by the last Hand:sort()
        movingCard = nil, -- card picked up for manual reordering
        deck = Deck:new(),
        x = 10,
        y = love.graphics.getHeight(),
        cardGroup = CardGroup:new(),
    };
    setmetatable(hand, Hand);
    hand.deck:shuffle();
    hand:drawCards();
    return hand;
end

function Hand:resetHand()
    self.cards = {}
    self.selectedCards = {}
    self.movingCard = nil
    self.deck = Deck:new()
    self.deck:shuffle()
    self:drawCards()
end

-- Deal the opening hand from the deck (no replacement, so no duplicates).
function Hand:drawCards()
    while #self.cards < self.initialHand do
        local card = self.deck:draw()
        if not card then break end
        table.insert(self.cards, card)
    end
end

-- Draw one card from the deck. If the deck runs out, reshuffle a fresh one.
function Hand:drawOneCard()
    local card = self.deck:draw()
    if not card then
        self.deck:reshuffle()
        card = self.deck:draw()
    end
    if card then
        table.insert(self.cards, card)
    end
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

function Hand:getSelectedCards()
    local cards = {}
    for _, card in ipairs(self.cards) do
        if card.selected then
            table.insert(cards, card)
        end
    end
    return cards
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
        if card == self.movingCard then
            card.y = card.y - 40 -- picked up for manual reordering
        end
        if card ~= self.movingCard then
            card:draw()
        end
    end
    -- draw the picked-up card last so it renders on top
    if self.movingCard then
        self.movingCard:draw()
    end
end

function Hand:sort()
    -- Toggle: first click sorts by suit (sequences), second by rank
    -- (pairs/triplets of different suits), third back to suit, and so on.
    self.sortMode = (self.sortMode == "suit") and "rank" or "suit"
    if self.sortMode == "suit" then
        HandValidator:sortCardsBySuit(self.cards)
    else
        HandValidator:sortCardsByRank(self.cards)
    end

    -- sorting clears the current selection
    for _, card in ipairs(self.cards) do
        card.selected = false
    end
    self.selectedCards = {}
    return self.sortMode
end

function Hand:mousepressed(x, y, button)
    -- right-click toggles play-selection (left-click is used for moving cards)
    if button == 2 then
        for i, card in ipairs(self.cards) do
            if x >= card.x and x <= card.x + card.width and
            y >= card.y and y <= card.y + card.height then
                card.selected = not card.selected
                self.cardGroup:addCards(self.cards)
                return true
            end
        end
        return false
    end

    -- left-click: if a card is picked up, drop it at the clicked slot,
    -- otherwise pick up the clicked card
    if self.movingCard then
        return self:dropCard(x, y)
    end
    return self:pickUpCard(x, y)
end

-- Pick up the card under the cursor for manual reordering.
function Hand:pickUpCard(x, y)
    for i, card in ipairs(self.cards) do
        if x >= card.x and x <= card.x + card.width and
        y >= card.y and y <= card.y + card.height then
            self.movingCard = card
            return true
        end
    end
    return false
end

-- Place the picked-up card at the slot under the cursor.
-- Clicking the card itself, or far outside the hand row, cancels the move.
-- The slot is found from card centres: left half of a card -> insert before
-- it, right half (or the gap past the last card) -> insert after it.
function Hand:dropCard(x, y)
    local moving = self.movingCard
    self.movingCard = nil -- the move is consumed either way

    if not moving or #self.cards < 2 then
        return false
    end

    -- clicking back on the picked-up card cancels
    if x >= moving.x and x <= moving.x + moving.width and
    y >= moving.y and y <= moving.y + moving.height then
        return true
    end

    -- clicking far outside the hand row cancels
    local minY, maxY = math.huge, -math.huge
    for _, c in ipairs(self.cards) do
        minY = math.min(minY, c.y)
        maxY = math.max(maxY, c.y + c.height)
    end
    if y < minY - 20 or y > maxY + 20 then
        return true
    end

    -- remove the card, then find the insertion slot from card centres
    local currentIndex
    for i, c in ipairs(self.cards) do
        if c == moving then
            currentIndex = i
            break
        end
    end
    if not currentIndex then return false end
    table.remove(self.cards, currentIndex)

    local targetIndex = #self.cards + 1
    for i, c in ipairs(self.cards) do
        if x < c.x + c.width / 2 then
            targetIndex = i
            break
        end
    end
    table.insert(self.cards, targetIndex, moving)
    return true
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
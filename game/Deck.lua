local Deck = {}
Deck.__index = Deck

local Card = require('game.Card')

-- A standard 52-card deck, no jokers: 13 ranks x 4 suits, each card unique.
--   ranks: 2..10, J=11, Q=12, K=13, A=14 (Ace high)
local RANKS = { 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14 }
local SUITS = { "hearts", "diamonds", "clubs", "spades" }

function Deck:new()
    local deck = { cards = {} }
    setmetatable(deck, Deck)
    deck:build()
    return deck
end

function Deck:build()
    self.cards = {}
    for _, suit in ipairs(SUITS) do
        for _, rank in ipairs(RANKS) do
            table.insert(self.cards, Card:new(rank, suit))
        end
    end
end

-- Fisher-Yates shuffle (uniform over all permutations).
function Deck:shuffle()
    for i = #self.cards, 2, -1 do
        local j = math.random(i)
        self.cards[i], self.cards[j] = self.cards[j], self.cards[i]
    end
end

-- Rebuild and reshuffle the full deck (used when the deck runs out).
function Deck:reshuffle()
    self:build()
    self:shuffle()
end

-- Draw the top card WITHOUT replacement. Returns nil when the deck is empty.
function Deck:draw()
    if #self.cards == 0 then
        return nil
    end
    return table.remove(self.cards)
end

function Deck:remaining()
    return #self.cards
end

return Deck

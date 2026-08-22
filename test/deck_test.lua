-- Tests for game/Deck.lua — single 52-card deck, draw without replacement.
package.path = "./?.lua;" .. package.path

local Deck = require('game.Deck')
local Card = require('game.Card')

local failures, total = 0, 0
local function check(desc, got, want)
    total = total + 1
    if got ~= want then
        failures = failures + 1
        print("FAIL: " .. desc .. " | got " .. tostring(got) .. ", want " .. tostring(want))
    else
        print("ok:   " .. desc)
    end
end

math.randomseed(99)
local deck = Deck:new()

check("deck has 52 cards", deck:remaining(), 52)

-- every card is a unique (rank, suit) pair
local seen = {}
for _, c in ipairs(deck.cards) do
    local key = c.suitId .. ":" .. c.suit
    check("unique card " .. key, seen[key] == nil, true)
    seen[key] = true
end

-- drawing removes cards without replacement
deck:shuffle()
local drawn = {}
for i = 1, 52 do
    local c = deck:draw()
    assert(c, "deck should still have cards at draw " .. i)
    local key = c.suitId .. ":" .. c.suit
    check("no duplicate across 52 draws: " .. key, drawn[key] == nil, true)
    drawn[key] = true
end
check("deck empty after 52 draws", deck:remaining(), 0)
check("draw on empty deck returns nil", deck:draw() == nil, true)

-- reshuffle restores a full deck
deck:reshuffle()
check("reshuffle restores 52 cards", deck:remaining(), 52)

-- distribution: 4 of each rank, 13 of each suit
local byRank, bySuit = {}, {}
for _, c in ipairs(deck.cards) do
    byRank[c.suitId] = (byRank[c.suitId] or 0) + 1
    bySuit[c.suit] = (bySuit[c.suit] or 0) + 1
end
local ranksOk, suitsOk = true, true
for r = 2, 14 do if byRank[r] ~= 4 then ranksOk = false end end
for _, s in ipairs({ "hearts", "diamonds", "clubs", "spades" }) do if bySuit[s] ~= 13 then suitsOk = false end end
check("exactly 4 copies of each rank", ranksOk, true)
check("exactly 13 of each suit", suitsOk, true)

-- cards are real Card objects
check("deck cards are Card instances", getmetatable(deck.cards[1]) == Card, true)

print()
print(string.format("%d tests, %d failures", total, failures))
os.exit(failures == 0 and 0 or 1)

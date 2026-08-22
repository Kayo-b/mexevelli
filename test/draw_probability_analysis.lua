-- Probability analysis: current draw system vs a single 52-card deck.
-- Current system: each card is drawn independently from 13 ranks x 4 suits,
-- WITH replacement (math.random per rank and per suit), so duplicates occur.

-- EXACT math for an 11-card hand (initialHand = 11)
local pNoDup = 1
for i = 0, 10 do pNoDup = pNoDup * (52 - i) / 52 end
print(string.format("P(no duplicate card in 11-card hand)      = %.4f", pNoDup))
print(string.format("P(at least one duplicate)                 = %.4f (%.1f%%)", 1 - pNoDup, (1 - pNoDup) * 100))

-- expected duplicate PAIRS in an 11-card hand (linearity of expectation)
local expPairs = (11 * 10 / 2) / 52
print(string.format("expected duplicate pairs per 11-card hand = %.3f", expPairs))

-- P(a specific card, e.g. Ace of spades, is in the hand)
local pSpecWith = 1 - (51 / 52) ^ 11
print(string.format("P(specific card present): with replacement = %.4f, single deck (11/52) = %.4f",
    pSpecWith, 11 / 52))

-- expected DISTINCT cards in an 11-card hand (with replacement)
print(string.format("expected distinct cards: with replacement = %.2f, single deck = 11", 52 * pSpecWith))

-- SIMULATION of the current system (100k hands)
math.randomseed(12345)
local trials, dupHands, maxDup = 100000, 0, 0
for t = 1, trials do
    local seen, dups = {}, 0
    for i = 1, 11 do
        local key = math.random(13) * 100 + math.random(4)
        if seen[key] then dups = dups + 1 end
        seen[key] = true
    end
    if dups > 0 then dupHands = dupHands + 1 end
    if dups > maxDup then maxDup = dups end
end
print(string.format("SIMULATED duplicate-rate in 100k hands    = %.4f (max dup pairs in one hand: %d)", dupHands / trials, maxDup))

print()
print("=== NEW system: real 52-card deck, draw without replacement ===")
local Deck = require('game.Deck')
local newDupHands, newMaxDup = 0, 0
for t = 1, trials do
    local deck = Deck:new()
    deck:shuffle()
    local seen, dups = {}, 0
    for i = 1, 11 do
        local c = deck:draw()
        local key = c.suitId .. ":" .. c.suit
        if seen[key] then dups = dups + 1 end
        seen[key] = true
    end
    if dups > 0 then newDupHands = newDupHands + 1 end
    if dups > newMaxDup then newMaxDup = dups end
end
print(string.format("SIMULATED duplicate-rate in 100k deals    = %.4f (max dup pairs in one hand: %d)", newDupHands / trials, newMaxDup))
-- P(specific card) by simulation
local deck = Deck:new(); deck:shuffle()
local seenAce = 0
for t = 1, trials do
    local d = Deck:new(); d:shuffle()
    local found = false
    for i = 1, 11 do
        local c = d:draw()
        if c.suitId == 14 and c.suit == "spades" then found = true end
    end
    if found then seenAce = seenAce + 1 end
end
print(string.format("SIMULATED P(Ace of spades in 11-card deal) = %.4f (exact 11/52 = %.4f)", seenAce / trials, 11 / 52))

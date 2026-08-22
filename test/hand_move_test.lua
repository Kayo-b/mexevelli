-- Tests for the two-click card move in game/Hand.lua:
--   left-click a card to pick it up, left-click a slot to drop it
--   (left half of a card -> insert before it, right half -> after it)
--   right-click toggles play-selection (unchanged play flow)
package.path = "./?.lua;" .. package.path

love = {
    graphics = {
        getHeight = function() return 768 end,
        getWidth  = function() return 1024 end,
    },
}

local Hand = require('game.Hand')
math.randomseed(7)
local hand = Hand:new()

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

-- lay cards out exactly like Hand:draw does, so click coordinates are real
local function layout()
    for i, card in ipairs(hand.cards) do
        card.x = hand.x + (i - 1) * 60
        card.y = love.graphics.getHeight() - 100
    end
end

local function describe()
    local parts = {}
    for _, c in ipairs(hand.cards) do
        parts[#parts + 1] = tostring(c.suitId)
    end
    return table.concat(parts, ",")
end

local function indexOf(card)
    for i, c in ipairs(hand.cards) do
        if c == card then return i end
    end
    return nil
end

-- 1) pick up a card, drop it at the end of the hand
layout()
local c3 = hand.cards[3]
check("left-click picks up a card", hand:mousepressed(c3.x + 10, c3.y + 10, 1), true)
check("movingCard is set after pick up", hand.movingCard == c3, true)
local last = hand.cards[#hand.cards]
hand:mousepressed(last.x + last.width + 20, last.y + 10, 1)
check("dropped at the end", hand.cards[#hand.cards] == c3, true)
check("movingCard cleared after drop", hand.movingCard == nil, true)

-- 2) drop before the first card
layout()
local c4 = hand.cards[4]
hand:mousepressed(c4.x + 10, c4.y + 10, 1)
hand:mousepressed(hand.cards[1].x - 20, hand.cards[1].y + 10, 1)
check("dropped at the front", hand.cards[1] == c4, true)

-- 3) left half of a card -> insert before it
layout()
local a, b = hand.cards[2], hand.cards[5]
hand:mousepressed(a.x + 10, a.y + 10, 1)
hand:mousepressed(b.x + 5, b.y + 10, 1)
check("inserted right before target card", indexOf(a) + 1 == indexOf(b), true)

-- 4) right half of a card -> insert after it
layout()
local a2, b2 = hand.cards[3], hand.cards[6]
hand:mousepressed(a2.x + 10, a2.y + 10, 1)
hand:mousepressed(b2.x + b2.width - 5, b2.y + 10, 1)
check("inserted right after target card", indexOf(b2) + 1 == indexOf(a2), true)

-- 5) clicking the picked-up card again cancels
layout()
local before = describe()
local c5 = hand.cards[5]
hand:mousepressed(c5.x + 10, c5.y + 10, 1)
check("picked up for cancel test", hand.movingCard == c5, true)
hand:mousepressed(c5.x + 10, c5.y + 10, 1)
check("clicking moving card cancels (order unchanged)", describe() == before, true)
check("movingCard cleared after cancel", hand.movingCard == nil, true)

-- 6) clicking far outside the hand row cancels
layout()
before = describe()
local c6 = hand.cards[6]
hand:mousepressed(c6.x + 10, c6.y + 10, 1)
hand:mousepressed(c6.x + 10, c6.y + 500, 1)
check("click far below cancels (order unchanged)", describe() == before, true)
check("movingCard cleared after outside cancel", hand.movingCard == nil, true)

-- 7) right-click toggles play-selection, does not start a move
layout()
local t = hand.cards[2]
check("right-click selects card", hand:mousepressed(t.x + 10, t.y + 10, 2), true)
check("card selected", t.selected, true)
check("getSelectedCards sees it", #hand:getSelectedCards(), 1)
check("right-click does not start a move", hand.movingCard == nil, true)
hand:mousepressed(t.x + 10, t.y + 10, 2)
check("right-click again deselects", t.selected, false)

-- 8) left-click does not toggle play-selection
layout()
local t2 = hand.cards[1]
hand:mousepressed(t2.x + 10, t2.y + 10, 1)
hand:mousepressed(t2.x + 10, t2.y + 10, 1) -- cancel pick up
check("left-click does not toggle play-selection", t2.selected, false)

-- 9) a manual move then the automatic sort still work together
layout()
local m = hand.cards[4]
hand:mousepressed(m.x + 10, m.y + 10, 1)
hand:mousepressed(hand.cards[1].x - 20, hand.cards[1].y + 10, 1)
local SUIT_ORDER = { hearts = 1, diamonds = 2, clubs = 3, spades = 4 }
local suitSorted = true
hand:sort() -- first click: sort by suit (sequences)
for i = 2, #hand.cards do
    if (SUIT_ORDER[hand.cards[i - 1].suit] or 99) > (SUIT_ORDER[hand.cards[i].suit] or 99) then
        suitSorted = false
    end
end
check("hand suit-sorts correctly after a manual move", suitSorted, true)
local rankSorted = true
hand:sort() -- second click: sort by rank (pairs/triplets)
for i = 2, #hand.cards do
    if hand.cards[i - 1].suitId > hand.cards[i].suitId then rankSorted = false end
end
check("hand rank-sorts correctly after a manual move", rankSorted, true)

print()
print(string.format("%d tests, %d failures", total, failures))
os.exit(failures == 0 and 0 or 1)

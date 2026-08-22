-- Integration test: the "Sort Cards" button toggles between two sort modes.
--   click 1 -> sort by suit (sequences)
--   click 2 -> sort by rank (pairs/triplets of different suits)
--   click 3 -> back to suit
-- Stubs the small part of love the scene needs so it runs under plain Lua.
package.path = "./?.lua;" .. package.path

love = {
    graphics = {
        getHeight = function() return 768 end,
        getWidth  = function() return 1024 end,
    },
}

local GameScene = require('scenes.GameScene')
math.randomseed(42)
local scene = GameScene:new()

local SUIT_ORDER = { hearts = 1, diamonds = 2, clubs = 3, spades = 4 }

local function isSuitSorted(cards)
    for i = 2, #cards do
        local s1 = SUIT_ORDER[cards[i - 1].suit] or 99
        local s2 = SUIT_ORDER[cards[i].suit] or 99
        if s1 > s2 then return false end
    end
    return true
end

local function isRankSorted(cards)
    for i = 2, #cards do
        if cards[i - 1].suitId > cards[i].suitId then return false end
    end
    return true
end

local function describe(cards)
    local parts = {}
    for _, c in ipairs(cards) do
        parts[#parts + 1] = (c.suit or "?"):sub(1, 1):upper() .. tostring(c.suitId)
    end
    return table.concat(parts, ",")
end

local sortBtn
for _, b in ipairs(scene.menuPanel.buttons) do
    if b.action == "sort_cards" then sortBtn = b end
end
assert(sortBtn, "Sort Cards button not found")

local function clickSort()
    scene:mousepressed(sortBtn.x + sortBtn.width / 2, sortBtn.y + sortBtn.height / 2, 1)
end

-- click 1: sort by suit (sequences)
clickSort()
print("click 1 (suit): " .. describe(scene.hand.cards))
assert(isSuitSorted(scene.hand.cards), "first click should sort by suit (sequences)")
assert(sortBtn.text == "Sort Cards (Suits)", "button label should show Suits mode after first click")

-- click 2: sort by rank (pairs/triplets)
clickSort()
print("click 2 (rank): " .. describe(scene.hand.cards))
assert(isRankSorted(scene.hand.cards), "second click should sort by rank (pairs/triplets)")
assert(sortBtn.text == "Sort Cards (Pairs)", "button label should show Pairs mode after second click")

-- click 3: cycles back to suit
clickSort()
print("click 3 (suit): " .. describe(scene.hand.cards))
assert(isSuitSorted(scene.hand.cards), "third click should cycle back to suit")

print("integration: sort button toggles suit/rank modes")
os.exit(0)

-- Tests for game/HandValidator.lua — Rummikub / Machiavelli meld rules.
package.path = "./?.lua;" .. package.path

local HandValidator = require('game.HandValidator')
local Card = require('game.Card') -- integration check: real Card objects

local failures = 0
local total = 0

local function card(rank, suit)
    return { suitId = rank, value = rank, suit = suit }
end

local function check(desc, got, want)
    total = total + 1
    if got ~= want then
        failures = failures + 1
        print("FAIL: " .. desc .. " | got " .. tostring(got) .. ", want " .. tostring(want))
    else
        print("ok:   " .. desc)
    end
end

-- validatePlay wrapper: returns valid, score, reason, groups
local function play(cards, opts)
    local v = HandValidator:new(opts)
    return v:validatePlay(cards)
end

local function expectPlay(desc, cards, wantValid, opts)
    local valid, score, reason = play(cards, opts)
    total = total + 1
    if valid ~= wantValid then
        failures = failures + 1
        print("FAIL: " .. desc .. " | got " .. tostring(valid) .. " (" .. tostring(reason) .. "), want " .. tostring(wantValid))
    else
        print("ok:   " .. desc .. (valid and (" [" .. score .. " pts]") or (" -> " .. tostring(reason))))
    end
    return valid, score, reason
end

print("=== Runs ===")
expectPlay("run of 3 hearts", {card(4,"hearts"), card(5,"hearts"), card(6,"hearts")}, true)
expectPlay("run of 4 spades (9,10,J,Q)", {card(9,"spades"), card(10,"spades"), card(11,"spades"), card(12,"spades")}, true)
expectPlay("run Q-K-A high ace", {card(12,"spades"), card(13,"spades"), card(14,"spades")}, true)
expectPlay("run of 2 cards", {card(4,"hearts"), card(5,"hearts")}, false)
expectPlay("run with gap", {card(4,"hearts"), card(5,"hearts"), card(7,"hearts")}, false)
expectPlay("run mixed suits", {card(4,"hearts"), card(5,"diamonds"), card(6,"clubs")}, false)
expectPlay("run wraps K-A-2", {card(13,"hearts"), card(14,"hearts"), card(2,"hearts")}, false)
expectPlay("run duplicate rank same suit", {card(5,"hearts"), card(5,"hearts"), card(6,"hearts"), card(7,"hearts")}, false)

print("=== Sets ===")
expectPlay("set of 3 sevens", {card(7,"hearts"), card(7,"diamonds"), card(7,"clubs")}, true)
expectPlay("set of 4 eights", {card(8,"hearts"), card(8,"diamonds"), card(8,"clubs"), card(8,"spades")}, true)
expectPlay("set duplicate suit", {card(7,"hearts"), card(7,"diamonds"), card(7,"hearts")}, false)
expectPlay("set different ranks", {card(7,"hearts"), card(8,"diamonds"), card(9,"clubs")}, false)
expectPlay("set of 5 (too many)", {card(8,"hearts"), card(8,"diamonds"), card(8,"clubs"), card(8,"spades"), card(8,"hearts")}, false)

print("=== Mixed plays ===")
expectPlay("run + set", {card(4,"hearts"), card(5,"hearts"), card(6,"hearts"), card(7,"diamonds"), card(7,"clubs"), card(7,"spades")}, true)
expectPlay("run + set + extra unplayable", {card(4,"hearts"), card(5,"hearts"), card(6,"hearts"), card(9,"spades")}, false)
expectPlay("two runs", {card(2,"clubs"), card(3,"clubs"), card(4,"clubs"), card(5,"diamonds"), card(6,"diamonds"), card(7,"diamonds")}, true)

print("=== Backtracking (overlapping melds) ===")
-- 4d can be in the set {4d,4c,4s,4h} OR in the run {3d,4d,5d}.
-- The full partition is run {3d,4d,5d} + set {4c,4s,4h}.
expectPlay("overlap: 4-set + run share a card", {card(4,"diamonds"), card(4,"clubs"), card(4,"spades"), card(4,"hearts"), card(3,"diamonds"), card(5,"diamonds")}, true)
-- Both melds need 4c: set {4d,4c,4s} and run {4c,5c,6c} cannot coexist -> no full partition.
expectPlay("overlap impossible (both melds need 4c)", {card(3,"hearts"), card(4,"hearts"), card(5,"hearts"), card(4,"diamonds"), card(4,"clubs"), card(4,"spades"), card(5,"clubs"), card(6,"clubs")}, false)

print("=== Minimum play requirement (30 pts OR 3+ cards) ===")
local v30 = HandValidator:new()
check("default minPlayScore=30, minPlayCards=3", v30.minPlayScore == 30 and v30.minPlayCards == 3, true)
-- 3-card run worth 9 points passes because it is 3+ cards in valid groups.
expectPlay("low-scoring 3-card run still valid (3+ cards)", {card(2,"hearts"), card(3,"hearts"), card(4,"hearts")}, true)
-- Classic first-meld rule: with minPlayCards=0, that same play must score 30.
expectPlay("classic rule: 9-pt run rejected", {card(2,"hearts"), card(3,"hearts"), card(4,"hearts")}, false, { minPlayCards = 0 })
expectPlay("classic rule: J-set scores 30, accepted", {card(11,"hearts"), card(11,"diamonds"), card(11,"clubs")}, true, { minPlayCards = 0 })
-- 2 cards never valid, even with 30+ score impossible for 2 cards anyway
expectPlay("two cards rejected", {card(10,"hearts"), card(10,"diamonds")}, false)

print("=== Scores ===")
local v = HandValidator:new()
local _, score = play({card(4,"hearts"), card(5,"hearts"), card(6,"hearts")})
check("run 4,5,6 = 15", score, 15)
_, score = play({card(9,"spades"), card(10,"spades"), card(11,"spades"), card(12,"spades")})
check("run 9,10,J,Q = 39", score, 39)
_, score = play({card(12,"spades"), card(13,"spades"), card(14,"spades")})
check("run Q,K,A = 31 (A=11)", score, 31)
_, score = play({card(8,"hearts"), card(8,"diamonds"), card(8,"clubs"), card(8,"spades")})
check("set of four 8s = 32", score, 32)

print("=== Groups output ===")
local groups
_, _, _, groups = play({card(4,"hearts"), card(5,"hearts"), card(6,"hearts"), card(7,"diamonds"), card(7,"clubs"), card(7,"spades")})
check("2 groups returned", #groups, 2)
local types = {}
for _, g in ipairs(groups) do
    types[#types + 1] = g.type
    check("each group is a valid meld", (g.type == "run" or g.type == "set") and #g.cards >= 3, true)
end
table.sort(types)
check("groups are run + set", table.concat(types, ","), "run,set")

print("=== Single-meld helpers ===")
local vr = v:isValidRun({card(4,"hearts"), card(5,"hearts"), card(6,"hearts")})
check("isValidRun returns isValid", vr.isValid, true)
check("isValidRun returns score", vr.score, 15)
local vs = v:isValidSet({card(7,"hearts"), card(7,"diamonds"), card(7,"clubs")})
check("isValidSet returns isValid", vs.isValid, true)
check("isValidSet returns score", vs.score, 21)
local vg, sg = v:validateGroup({card(4,"hearts"), card(5,"hearts"), card(6,"hearts")})
check("validateGroup run true", vg, true)
check("validateGroup run score", sg, 15)
vg, sg = v:validateGroup({card(4,"hearts"), card(5,"diamonds"), card(6,"clubs")})
check("validateGroup garbage false", vg, false)
check("validateGroup garbage score 0", sg, 0)

print("=== Real Card objects (integration) ===")
local cards = {
    Card:new(4, "hearts"),
    Card:new(5, "hearts"),
    Card:new(6, "hearts"),
}
local validReal, scoreReal = play(cards)
check("real Card run valid", validReal, true)
check("real Card run score", scoreReal, 15)

print("=== sortCardsBySuit (sequences) ===")
local function keys(cards)
    local parts = {}
    for _, c in ipairs(cards) do
        parts[#parts + 1] = (c.suit or "?"):sub(1, 1):upper() .. tostring(c.suitId or "?")
    end
    return table.concat(parts, ",")
end

local function sortBySuit(cards)
    HandValidator:sortCardsBySuit(cards)
end
local function sortByRank(cards)
    HandValidator:sortCardsByRank(cards)
end

local mixed = { card(10,"hearts"), card(3,"spades"), card(10,"diamonds"), card(3,"hearts"), card(14,"spades"), card(3,"clubs") }
sortBySuit(mixed)
check("by suit: suits grouped hearts<diamonds<clubs<spades", keys(mixed), "H3,H10,D10,C3,S3,S14")
check("by suit: ace last within its suit", mixed[#mixed].suitId, 14)

print("=== sortCardsByRank (pairs/triplets) ===")
local grouped = { card(10,"hearts"), card(3,"spades"), card(10,"diamonds"), card(3,"hearts"), card(14,"spades"), card(3,"clubs") }
sortByRank(grouped)
check("by rank: same ranks grouped, ranks ascending", keys(grouped), "H3,C3,S3,H10,D10,S14")
check("by rank: ace is high (last)", grouped[#grouped].suitId, 14)

local suitTie = { card(7,"spades"), card(7,"hearts"), card(7,"diamonds") }
sortByRank(suitTie)
check("by rank: suit tiebreak hearts<diamonds<spades", keys(suitTie), "H7,D7,S7")

local nilSafe = { card(5,"spades"), { suitId = 8, suit = nil, value = 8 }, card(4,"diamonds") }
sortByRank(nilSafe)
check("by rank: unknown suit sorts last, no crash", keys(nilSafe), "D4,S5,?8")

local nilRank = { { suitId = nil, suit = "hearts", value = nil }, card(3,"clubs") }
sortByRank(nilRank)
check("by rank: missing rank sorts first, no crash", keys(nilRank), "H?,C3")

check("by rank: nil input does not crash", (function() sortByRank(nil); return true end)(), true)
check("by rank: empty input does not crash", (function() sortByRank({}); return true end)(), true)
check("by suit: nil input does not crash", (function() sortBySuit(nil); return true end)(), true)

-- both modes on the same hand produce different orders
local a = { card(10,"hearts"), card(3,"spades"), card(10,"diamonds"), card(3,"hearts"), card(14,"spades"), card(3,"clubs") }
local b = { card(10,"hearts"), card(3,"spades"), card(10,"diamonds"), card(3,"hearts"), card(14,"spades"), card(3,"clubs") }
sortBySuit(a)
sortByRank(b)
check("suit order differs from rank order", keys(a) ~= keys(b), true)

print()
print(string.format("%d tests, %d failures", total, failures))
os.exit(failures == 0 and 0 or 1)

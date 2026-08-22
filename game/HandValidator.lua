local HandValidator = {}
HandValidator.__index = HandValidator

local aux = require('utils.aux')

-- ---------------------------------------------------------------------------
-- Scoring (matches Card:getValue): Aces = 11, face cards = 10, pips = rank.
-- We compute from suitId so the score is correct even before Card:draw() has
-- run Card:getValue() (Card:new stores the raw rank 2..14 in both fields).
-- ---------------------------------------------------------------------------
local SCORE_BY_VALUE = {}
for v = 2, 10 do SCORE_BY_VALUE[v] = v end
SCORE_BY_VALUE[11] = 10 -- J
SCORE_BY_VALUE[12] = 10 -- Q
SCORE_BY_VALUE[13] = 10 -- K
SCORE_BY_VALUE[14] = 11 -- A

local SUITS = { "hearts", "diamonds", "clubs", "spades" }

local function cardScore(card)
    return SCORE_BY_VALUE[card.suitId] or card.suitId or 0
end

local function cardLabel(card)
    if card.getDisplayValue then
        return card:getDisplayValue() .. " of " .. (card.suit or "?")
    end
    return tostring(card.suitId) .. " of " .. (card.suit or "?")
end

-- ---------------------------------------------------------------------------
-- Constructor.
-- opts.minPlayScore / opts.minPlayCards encode the game's minimum play
-- requirement: "30 points OR 3+ cards in valid groups". Set minPlayCards = 0
-- to enforce the classic Rummikub "first meld must score 30" rule instead.
-- ---------------------------------------------------------------------------
function HandValidator:new(opts)
    opts = opts or {}
    local validator = {
        minPlayScore = opts.minPlayScore or 30,
        minPlayCards = opts.minPlayCards or 3,
    }
    setmetatable(validator, HandValidator)
    return validator
end

function HandValidator:calculateScore(cards)
    local total = 0
    for _, card in ipairs(cards) do
        total = total + cardScore(card)
    end
    return total
end

-- ---------------------------------------------------------------------------
-- Public entry point: validate a full play (the cards the player selected).
-- Returns:
--   valid:boolean, score:number, reason:string, groups:table
-- groups is a list of { type = "run"|"set", cards = {...} } - the partition
-- of every selected card into legal Rummikub melds.
-- ---------------------------------------------------------------------------
function HandValidator:validatePlay(selectedCards)
    selectedCards = selectedCards or {}

    if #selectedCards < 3 then
        return false, 0, "Select at least 3 cards to play", {}
    end

    local groups, reason = self:separateIntoGroups(selectedCards)
    if not groups then
        return false, 0, reason or "Cards do not form valid runs or sets", {}
    end

    local totalScore = 0
    for _, group in ipairs(groups) do
        local isValid, score = self:validateGroup(group.cards)
        if not isValid then
            return false, 0, "Invalid group found", {}
        end
        totalScore = totalScore + score
    end

    -- Minimum play requirement: 30 points OR 3+ cards in valid groups.
    -- A minPlayCards value of 0 disables the card-count alternative, leaving
    -- only the score requirement (classic Rummikub first-meld rule).
    local meetsScore = totalScore >= self.minPlayScore
    local meetsCards = self.minPlayCards > 0 and #selectedCards >= self.minPlayCards
    if not (meetsScore or meetsCards) then
        local reason
        if self.minPlayCards > 0 then
            reason = "Play must score at least " .. self.minPlayScore
                .. " points or contain " .. self.minPlayCards
                .. "+ cards in valid groups"
        else
            reason = "Play must score at least " .. self.minPlayScore .. " points"
        end
        return false, 0, reason, {}
    end

    return true, totalScore, "Valid play", groups
end

-- Validate a single contiguous group: it must be exactly one legal meld.
function HandValidator:validateGroup(cards)
    local run = self:isValidRun(cards)
    if run.isValid then
        return true, run.score, "Run"
    end

    local set = self:isValidSet(cards)
    if set.isValid then
        return true, set.score, "Set"
    end

    return false, 0, "Group is neither a valid run nor a valid set"
end

-- ---------------------------------------------------------------------------
-- Partition cards into runs and/or sets (Rummikub melds).
-- Strategy: generate every candidate meld that can be built from the cards,
-- then exact-cover search (backtracking) over the candidates until every card
-- belongs to exactly one meld. Returns the partition, or nil + reason.
-- ---------------------------------------------------------------------------
function HandValidator:separateIntoGroups(cards)
    local candidates = self:buildCandidates(cards)

    -- Every card must be usable by at least one meld.
    local usable = {}
    for _, meld in ipairs(candidates) do
        for _, c in ipairs(meld.cards) do
            usable[c] = true
        end
    end
    for _, c in ipairs(cards) do
        if not usable[c] then
            return nil, "Unplayable card: " .. cardLabel(c)
        end
    end

    local used = {}
    local current = {}
    local solution = nil

    local function search()
        if solution then return true end

        -- Pick the first still-unplaced card (deterministic order).
        local first = nil
        for _, c in ipairs(cards) do
            if not used[c] then
                first = c
                break
            end
        end
        if not first then
            -- Every card placed: success.
            solution = {}
            for _, meld in ipairs(current) do
                table.insert(solution, meld)
            end
            return true
        end

        -- Try every meld that contains this card and is fully free.
        for _, meld in ipairs(candidates) do
            if #meld.cards >= 3 and self:meldContains(meld, first) then
                local free = true
                for _, c in ipairs(meld.cards) do
                    if used[c] then
                        free = false
                        break
                    end
                end
                if free then
                    for _, c in ipairs(meld.cards) do
                        used[c] = true
                    end
                    table.insert(current, meld)
                    if search() then return true end
                    table.remove(current)
                    for _, c in ipairs(meld.cards) do
                        used[c] = nil
                    end
                end
            end
        end
        return false
    end

    if search() then
        local groups = {}
        for _, meld in ipairs(solution) do
            table.insert(groups, { type = meld.type, cards = meld.cards })
        end
        return groups
    end

    return nil, "Cards cannot be fully arranged into runs or sets"
end

-- Generate every candidate meld (run/set of exactly >=3 cards) from 'cards'.
-- A card is identified by its (suitId, suit) pair; cards sharing both are
-- treated as one physical card for meld purposes.
function HandValidator:buildCandidates(cards)
    local byValue = {} -- rank -> list of cards
    local bySuit = {}  -- suit -> { rank -> card }
    for _, card in ipairs(cards) do
        byValue[card.suitId] = byValue[card.suitId] or {}
        table.insert(byValue[card.suitId], card)

        bySuit[card.suit] = bySuit[card.suit] or {}
        bySuit[card.suit][card.suitId] = card
    end

    local candidates = {}

    -- SETS: same rank, 3-4 distinct suits.
    for rank, rankCards in pairs(byValue) do
        local present = {}
        for _, c in ipairs(rankCards) do
            present[c.suit] = c
        end
        local suitList = {}
        for _, s in ipairs(SUITS) do
            if present[s] then
                table.insert(suitList, s)
            end
        end

        local function addSet(start, chosen, need)
            if #chosen == need then
                local setCards = {}
                for _, s in ipairs(chosen) do
                    table.insert(setCards, present[s])
                end
                table.insert(candidates, { type = "set", cards = setCards })
                return
            end
            for i = start, #suitList do
                table.insert(chosen, suitList[i])
                addSet(i + 1, chosen, need)
                table.remove(chosen)
            end
        end

        addSet(1, {}, 3)
        addSet(1, {}, 4)
    end

    -- RUNS: same suit, consecutive ranks, length >= 3. Every contiguous
    -- window of length >= 3 inside a maximal consecutive stretch is a
    -- candidate, so overlapping run choices are possible.
    for suit, rankMap in pairs(bySuit) do
        local ranks = {}
        for r in pairs(rankMap) do
            table.insert(ranks, r)
        end
        table.sort(ranks)

        local i = 1
        while i <= #ranks do
            local j = i
            while j < #ranks and ranks[j + 1] == ranks[j] + 1 do
                j = j + 1
            end
            local len = j - i + 1
            if len >= 3 then
                for start = i, j - 2 do
                    for stop = start + 2, j do
                        local runCards = {}
                        for k = start, stop do
                            table.insert(runCards, rankMap[ranks[k]])
                        end
                        table.insert(candidates, { type = "run", cards = runCards })
                    end
                end
            end
            i = j + 1
        end
    end

    return candidates
end

function HandValidator:meldContains(meld, card)
    for _, c in ipairs(meld.cards) do
        if c == card then
            return true
        end
    end
    return false
end

-- ---------------------------------------------------------------------------
-- Single-meld checks. Both return { isValid = bool, cards = ..., score = n }.
-- ---------------------------------------------------------------------------

-- A run: >= 3 cards, all the same suit, with consecutive ranks (no wrap:
-- Q-K-A is fine, K-A-2 is not).
function HandValidator:isValidRun(cards)
    if #cards < 3 then
        return { isValid = false, cards = cards, score = 0 }
    end

    local suit = cards[1].suit
    local sorted = {}
    for _, c in ipairs(cards) do
        if c.suit ~= suit then
            return { isValid = false, cards = cards, score = 0 }
        end
        table.insert(sorted, c)
    end
    table.sort(sorted, function(a, b)
        return a.suitId < b.suitId
    end)

    for i = 2, #sorted do
        if sorted[i].suitId ~= sorted[i - 1].suitId + 1 then
            return { isValid = false, cards = cards, score = 0 }
        end
    end

    return { isValid = true, cards = sorted, score = self:calculateScore(sorted) }
end

-- A set: 3 or 4 cards, all the same rank, all different suits.
function HandValidator:isValidSet(cards)
    local n = #cards
    if n < 3 or n > 4 then
        return { isValid = false, cards = cards, score = 0 }
    end

    local rank = cards[1].suitId
    local seenSuits = {}
    for _, c in ipairs(cards) do
        if c.suitId ~= rank then
            return { isValid = false, cards = cards, score = 0 }
        end
        if seenSuits[c.suit] then
            return { isValid = false, cards = cards, score = 0 }
        end
        seenSuits[c.suit] = true
    end

    return { isValid = true, cards = cards, score = self:calculateScore(cards) }
end

-- ---------------------------------------------------------------------------
-- Hand sorting helpers. Two modes, toggled by the Sort Cards button:
--   sortCardsBySuit -> same-suit sequences grouped (runs visible)
--   sortCardsByRank -> pairs/triplets of different suits grouped (sets visible)
-- Both are nil-safe: missing ranks sort first and unknown suits sort last,
-- so table.sort never hits a nil comparison.
-- ---------------------------------------------------------------------------
local SUIT_ORDER = { hearts = 1, diamonds = 2, clubs = 3, spades = 4 }

local function suitRank(suit)
    return SUIT_ORDER[suit] or 99
end

local function rankOf(card)
    return card.suitId or 0
end

-- Same-suit sequences: all cards of a suit together, ordered by rank.
function HandValidator:sortCardsBySuit(cards)
    if not cards then return end

    table.sort(cards, function(a, b)
        local suitA, suitB = suitRank(a.suit), suitRank(b.suit)
        if suitA ~= suitB then
            return suitA < suitB
        end
        return rankOf(a) < rankOf(b)
    end)
end

-- Pairs/triplets of different suits: same-rank cards grouped together,
-- with the suit as the tiebreaker.
function HandValidator:sortCardsByRank(cards)
    if not cards then return end

    table.sort(cards, function(a, b)
        local rankA, rankB = rankOf(a), rankOf(b)
        if rankA ~= rankB then
            return rankA < rankB
        end
        return suitRank(a.suit) < suitRank(b.suit)
    end)
end

return HandValidator

local HandValidator = {}
HandValidator.__index = HandValidator 

function HandValidator:new()
    local validator = {}
    setmetatable(validator, HandValidator)
    return validator
end

function HandValidator:validatePlay(selectedCards)
    local groups = self:separateIntoGroups(selectedCards)
    local totalScore = 0
    return true
    -- for _, group in ipairs(groups) do
    --     local isValid, score = self:validateGroup(group)
    --     if not isValid then
    --         return false, 0, "Invalid group found"
    --     end
    -- end

    -- return true, totalScore, "Valid play"
end

function HandValidator:validateGroup(cards)
    if self:isValidRun(cards) then
        return true, self:calculateScore(cards)
    elseif self:isValidSet(cards) then
        return true, self:calculateScore(cards)
    end

    return false, 0
end

function HandValidator:separateIntoGroups(selectedCards)
    --identify if the selected cards form groups of runs and/or sets
    print(selectedCards, 'SELECTED CARDS')
    local groups = {1,2,3,4}
    return groups
end

function HandValidator:isValidRun(cards)
    --add rule for runs
end

function HandValidator:isValidSet(cards)
    --add rule for sets 
end

return HandValidator
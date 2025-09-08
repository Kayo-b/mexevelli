local HandValidator = {}
HandValidator.__index = HandValidator

local aux = require('utils.aux')

function HandValidator:new()
    local validator = {}
    setmetatable(validator, HandValidator)
    return validator
end

function HandValidator:validatePlay(selectedCards)
    local groups = self:separateIntoGroups(selectedCards)
    local totalScore = 0
    print('groups: ', groups)
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
    aux.isSequence(selectedCards)
    local groups = {1,2,3,4}
    return groups
end

function HandValidator:isValidRun(cards)
    -- i need to sort the has table based on the id values
    table.sort(cards, function(a, b)
        print(a.suitId,b.suitId,'<<<')
        return a.suitId < b.suitId
    end)
    local count = 0
    for i ,card in ipairs(cards) do
        print('card :', cards[i].suitId,'length: ',#cards, i)
        if #cards > 1 then
            if i == #cards then return count >= 3 end
            local test1 = cards[i].suitId
            local test2 = cards[i+1].suitId
            print(cards[i].suitId,'<<<<<><><><>', test1)
            print(cards[i+1].suitId,'<<<<<><><><>',test2)
            print(test2-test1)
            if cards[i+1].suitId - cards[i].suitId == 1 then
                count = count + 1
                print('counting!', count)
            end
        end
    end
    print('count:', count)
    return count >= 3
end

function HandValidator:isValidSet(cards)
    --add rule for sets
end

return HandValidator
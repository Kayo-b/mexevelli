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
    --print('groups: ', groups)
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
    --print(selectedCards, 'SELECTED CARDS')
    aux.isSequence(selectedCards)
    local groups = {1,2,3,4}
    return groups
end

-- externalize the sort ?
-- create separate functions to check sequences and triplets then integrate them into the HandValidator
    -- sort all selected cards by suit 
    -- then sort by sequence to see if there are elegible runs -> count score
    -- then sort by same suite, if it has tripplet from a diff suite -> count score 

function HandValidator:validateSuites(selectedCards)
    print(selectedCards, 'selected cards')
    -- see if the sequence suites are the same
    if selectedCards then
        for i, card in ipairs(selectedCards) do
            print(card.suit, 'card suit')
        end
    end

end

function HandValidator:isValidRun(cards)
    -- i need to sort the has table based on the id values
    local cardsRun = {}
    table.sort(cards, function(a, b)
        --print(a.suitId,b.suitId,'<<<')
        return a.suitId < b.suitId
    end)
    local count = 0
    for i ,card in ipairs(cards) do
        --print('card :', cards[i].suitId,'length: ',#cards, i)
        if #cards > 1 then
            --print('OI')
            if i == #cards then return {isValid = #cardsRun >= 3, cards = cardsRun} end
            local test1 = cards[i].suitId
            local test2 = cards[i+1].suitId
            --print(cards[i].suitId,'<<<<<><><><>', test1)
            --print(cards[i+1].suitId,'<<<<<><><><>',test2)
            --print(test2-test1)

            self.validateSuites(cardsRun)
            if cards[i+1].suitId - cards[i].suitId == 1 then
                -- if cards[i].suit 
                --print(cards[i].suit,'card!')
                count = count + 1
                table.insert(cardsRun, card)
                --print('counting!', count)
            end
            -- --print(cardsRun[1].suitId,#cardsRun,'CARDS RUN')
        end
    end
    --print('count:', count)
    return {
        isValid = #cardsRun >= 3,
        cards = cardsRun
    }
end

function HandValidator:isValidSet(cards)
    --add rule for sets
end

return HandValidator
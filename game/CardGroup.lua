local CardGroup = {}
local HandValidator = require('game.HandValidator')
local aux = require('utils.aux')
CardGroup.__index = CardGroup

function CardGroup:new(cards, groupType)
    local group = {
        cards = cards or {},
        groupType = groupType,
        x = 500,
        y = 0,
        baseScore = 0,
        handValidator = HandValidator:new()

    };
    setmetatable(group, CardGroup);
    group:calculateScore();
    return group;
end;

function CardGroup:addCards(cards)
    self.cards = {}
    for i, card in ipairs(cards) do
        print(card.value, card.selected)
        if card.selected then
            table.insert(self.cards, card)
        end
    end
    local result = HandValidator:isValidRun(self.cards)
    print(result.isValid,'????<<<<<<<')
    if result.isValid then print('Is Valid? ', result.isValid) end
    local newCards = result.cards
    aux.printTable(newCards)
    self:calculateScore(newCards)
end;

function CardGroup:calculateScore(cards)
    cards = cards or self.cards
    self.baseScore = 0
    for _, card in ipairs(cards) do
        self.baseScore = self.baseScore + card.value;
    end;
end;

function CardGroup:draw()
    for i, card in ipairs(self.cards) do
        card.x = self.x + (i - 1) * 40
        card.y = self.y --love.graphics.getHeight() - 1100;
        card:draw()
    end;
end;

function CardGroup:setPosition(x, y)
    self.x = x
    self.y = y
    print(self.x, self.y, 'card group position')
    for i, card in ipairs(self.cards) do
        card.x = x + (i - 1) * (card.width + 1)
        card.y = y
    end
end

function CardGroup:getWidth()
    if #self.cards == 0 then return 0 end

    local cardWidth = self.cards[1].width or 50
    local spacing = 5
    return #self.cards * cardWidth + (#self.cards - 1) * spacing
end

function CardGroup:update(dt)
    for _, card in ipairs(self.cards) do
        if card.update then
            card:update(dt)
        end
    end
end


return CardGroup;
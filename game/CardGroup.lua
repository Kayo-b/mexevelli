local CardGroup = {};
CardGroup.__index = CardGroup;

function CardGroup:new(cards, groupType)
    local group = {
        cards = cards or {},
        groupType = groupType,
        x = 0,
        y = 0,
        baseScore = 0
    };
    setmetatable(group, CardGroup);
    group:calculateScore();
    return group;
end;

function CardGroup:addCard(card, position)
    table.insert(self.cards, position or #self.cards + 1, card);
    self.calculateScore();
end;

function CardGroup:calculateScore()
    self.baseScore = 0;
    for _, card in ipairs(self.cards) do
        self.baseScore = self.baseScore + card.value;
    end;
end;

function CardGroup:draw()
    for i, card in ipairs(self.cards) do
        card.x = self.x + (i - 1) * 30;
        card.y = self.y;
        card:draw();
    end;
end;

function CardGroup:setPosition(x, y)
    self.x = x
    self.y = y

    for i, card in ipairs(self.cards) do
        card.x = x + (i - 1) * (card.width + 1) -- Space cards out
        card.y = y
    end
end

function CardGroup:getWidth()
    if #self.cards == 0 then return 0 end
    
    local cardWidth = self.cards[1].width or 50  -- Default card width
    local spacing = 5
    return #self.cards * cardWidth + (#self.cards - 1) * spacing
end

return CardGroup;
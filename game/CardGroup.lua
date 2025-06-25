local CardGroup = {};
CardGroup.__index = CardGroup;

function CardGroup:new(cards, groupType)
    local group = {
        cards = cards or {},
        groupType = groupType,
        x = 500,
        y = 0,
        baseScore = 0
    };
    setmetatable(group, CardGroup);
    group:calculateScore();
    return group;
end;

function CardGroup:addCards(cards)
    for _, card in ipairs(cards) do
        table.insert(self.cards, card)
    end
    self:calculateScore();
end;

function CardGroup:calculateScore()
    self.baseScore = 0;
    for _, card in ipairs(self.cards) do
        self.baseScore = self.baseScore + card.value;
    end;
end;

function CardGroup:draw()
    for i, card in ipairs(self.cards) do
        card.x = self.x + (i - 1) * 40;
        card.y = self.y --love.graphics.getHeight() - 1100;
        card:draw();
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
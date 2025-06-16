local Card = {};
Card.__index = Card;

function Card:new(value, suit)
    local card = {
        value = value,
        suit = suit,
        width = 50,
        height = 70,
        x = 0,
        y = 0,
        selected = false,
    };
    setmetatable(card, Card);
    return card;
end;

function Card:draw()
    local color = (
    self.suit == "hearts"
    or self.suit  == "diamonds"
    )
    and {1, 0, 0}
    or {0, 0, 0};

    love.graphics.setColor(1, 1, 1);
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height);
    love.graphics.setColor(0, 0, 0);
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height);

    love.graphics.setColor(color);
    love.graphics.printf(self:getDisplayValue(), self.x, self.y + 10, self.width, "center");
    love.graphics.printf(self:getSuitSymbol(), self.x, self.y + 30, self.width, "center");
end;

function Card:getDisplayValue()
    if self.value == 1 then return "A";
    elseif self.value == 11 then return "J";
    elseif self.value == 12 then return "Q";
    elseif self.value == 13 then return "K";
    else return tostring(self.value);
    end;
end;
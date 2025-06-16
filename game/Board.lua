local Board = {}
Board.__index = Board

local CardGroup = require('game.CardGroup')

function Board:new()
    local board = {
        width = love.graphics.getWidth() - 20,
        height = love.graphics.getHeight() - 20,
        backgroundColor = {0.5, 0.5, 0.2},
        borderColor = {3, 3, 3},
        x = 10,
        y = 10,
        cardGroups = {}
    }
    setmetatable(board, Board)

    board:addCardGroup()

    return board
end

function Board:addCardGroup(cards, groupType)
    -- Provide default empty cards if none given
    cards = cards or {}
    local group = CardGroup:new(cards, groupType)
    table.insert(self.cardGroups, group)
    self:arrangeGroups()
    -- print(self.width, self.height)
end

function Board:draw()
    local width = love.graphics.getWidth() - 20
    local height = love.graphics.getHeight() - 20

    love.graphics.setColor(self.backgroundColor)
    love.graphics.rectangle("fill", self.x, self.y, width, height)

    love.graphics.setColor(self.borderColor)
    love.graphics.setLineWidth(3)
    love.graphics.rectangle("line", self.x, self.y, width, height)

    love.graphics.setColor(1, 1, 1)
    love.graphics.print("board", self.x + 10, self.y + 10)

    -- Draw all card groups
    for i, cardGroup in ipairs(self.cardGroups) do
        cardGroup:draw()
    end

    if self.totalScore then
        love.graphics.setColor(1, 1, 0)
        love.graphics.print("Score: " .. self.totalScore, width - 150, self.y + 10)
    end
end

function Board:arrangeGroups()
    local x, y = self.x + 20, self.y + 50
    for i, group in ipairs(self.cardGroups) do
        group:setPosition(x, y)
        x = x + group:getWidth() + 30
        if x > self.width - 100 then
            x = self.x + 20
            y = y + 80
        end
    end
end

return Board
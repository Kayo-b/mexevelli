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
    cards = cards or {}
    local group = CardGroup:new(cards, groupType)
    table.insert(self.cardGroups, group)
    -- self:arrangeGroups()
    -- local group
    -- if cardGroupOrCards and cardGroupOrCards.cards then
    --     group = cardGroupOrCards
    -- else
    --     local cards = cardGroupOrCards or {}
    --     group = CardGroup:new(cards, groupType)
    -- end

    table.insert(self.cardGroups, group)
    self:arrangeGroups()
end

function Board:draw()
    local width = love.graphics.getWidth() - 20
    local height = love.graphics.getHeight() - 20

    love.graphics.setColor(self.backgroundColor)
    love.graphics.rectangle("fill", self.x, self.y, width, height)

    love.graphics.setColor(self.borderColor)
    love.graphics.setLineWidth(3)
    love.graphics.rectangle("line", self.x, self.y, width, height)
    love.graphics.line(500, 1250, 2000, 1250)
    love.graphics.line(250, 100, 250, 900)
    -- love.graphics.rectangle("line", 300, 300, 50, 50)
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

-- function Board:arrangeGroups()
--     local startX, startY = 100, 100
--     local spacing = 250  -- Much larger spacing to ensure separation

--     for i, group in ipairs(self.cardGroups) do
--         local x = startX + (i - 1) * spacing  -- Simple: 100, 350, 600, etc.
--         local y = startY
--         print('Group', i, 'positioned at:', x, y)

--         group:setPosition(x, y)
--         -- Verify it was actually set
--         print('Group', i, 'self.x after setPosition:', group.x, group.y)
--     end
-- end

--grid pattern
function Board:arrangeGroups()
    local startX, startY = 250, -100
    local spacing = 15
    local groupsPerRow = 3

    for i, group in ipairs(self.cardGroups) do
        local row = math.floor((i - 1) / groupsPerRow)
        local col = (i - 1) % groupsPerRow

        local x = startX + col * (group:getWidth() + spacing)
        local y = startY + row * 120

        group:setPosition(x, y)
    end
end

function Board:update(dt)
    for _, group in ipairs(self.cardGroups) do
        group:update(dt)
    end

    -- self:updateScorePopups(dt)

    -- self:updateDropZoneHighlights(dt)
end

return Board
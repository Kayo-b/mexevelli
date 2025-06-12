local Board = {}
Board.__index = Board

local CardGroup = require('game.CardGroup')


function Board:new()
    local board = {
        width = love.graphics.getWidth() * 0.8,
        height = love.graphics.getHeight() * 0.7,
        x = 10,
        y = 10
    }
    setmetatable(board, Board)
    return board
end

function Board:addCardGroup(cards, groupType)
    local group = CardGroup:neww(cards, groupType)
    table.insert(self.cardGroups, group)
    self:arrangeGroups()
end 

function Board:canManipulate(fromHand, targetGroup)
    -- add logic to check if vards can be added or rearenged
end

function Board:arrangeGroups()
    -- position card groups on board
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



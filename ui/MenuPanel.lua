local MenuPanel = {}
MenuPanel.__index = MenuPanel

function MenuPanel:new()
    local panel = {
        x = 10,
        y = 10,
        width = 190,
        height = 300,
        buttons = {},
        visible = true,
        currentScore = 0,
        score = {},
    }

    panel.buttons = {
        -- {
        --     text = "End Turn",
        --     x = panel.x + 10,
        --     y = panel.y + 20,
        --     width = 170,
        --     height = 40,
        --     action = "end_turn"
        -- },
        -- {
        --     text = "Reset Board",
        --     x = panel.x + 10,
        --     y = panel.y + 70,
        --     width = 170,
        --     height = 40,
        --     action = "reset_board"
        -- },
        -- {
        --     text = "Settings",
        --     x = panel.x + 10,
        --     y = panel.y + 120,
        --     width = 170,
        --     height = 40,
        --     action = "settings"
        -- },
        {
            text = "Draw Card",
            x = panel.x + 10,
            y = panel.y + 170,
            width = 170,
            height = 40,
            action = "draw_card"
        },
        {
            text = "Play Cards",
            x = panel.x + 10,
            y = panel.y + 220,
            width = 170,
            height = 40,
            action = "play_cards"
        },
        {
            text = "Sort Cards",
            x = panel.x + 10,
            y = panel.y + 270,
            width = 170,
            height = 40,
            action = "sort_cards"
        }

    }

    panel.score = {
        text = "Score: 0",
        x = panel.x + 10,
        y = panel.y + 330,
        width = 170,
        height = 40,
    }

    setmetatable(panel, MenuPanel)
    return panel
end

function MenuPanel:update(dt)
end

function MenuPanel:updateScore(score)
    self.currentScore = score or 0
    self.score.text = "Score: " .. self.currentScore
end

function MenuPanel:draw()
    if not self.visible then return end

    -- love.graphics.setColor(0.2, 0.2, 0.2, 0.9)
    -- love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)

    -- love.graphics.setColor(0.5, 0.5, 0.5, 1)
    -- love.graphics.rectangle("line", self.x, self.y, self.width, self.height)

    for _, button in ipairs(self.buttons) do
        self:drawButton(button)
    end
    self:drawScore()

    love.graphics.setColor(1, 1, 1, 1)
end

function MenuPanel:drawButton(button)
    love.graphics.setColor(0.4, 0.4, 0.4, 1)
    love.graphics.rectangle("fill", button.x, button.y, button.width, button.height)

    love.graphics.setColor(0.6, 0.6, 0.6, 1)
    love.graphics.rectangle("line", button.x, button.y, button.width, button.height)

    love.graphics.setColor(1, 1, 1, 1)
    local font = love.graphics.getFont()
    local textWidth = font:getWidth(button.text)
    local textHeight = font:getHeight()
    local textX = button.x + (button.width - textWidth) / 2
    local textY = button.y + (button.height - textHeight) / 2
    love.graphics.print(button.text, textX, textY)
end

function MenuPanel:drawScore()
    love.graphics.setColor(0.2, 0.3, 0.6, 0.9)
    love.graphics.rectangle("fill", self.score.x, self.score.y, self.score.width, self.score.height)

    love.graphics.setColor(0.4, 0.5, 0.8, 1)
    love.graphics.rectangle("line", self.score.x, self.score.y, self.score.width, self.score.height)

    love.graphics.setColor(1, 1, 1, 1)
    local font = love.graphics.getFont()
    local textWidth = font:getWidth(self.score.text)
    local textHeight = font:getHeight()
    local textX = self.score.x + (self.score.width - textWidth) / 2
    local textY = self.score.y + (self.score.height - textHeight) / 2
    love.graphics.print(self.score.text, textX, textY)
end

function MenuPanel:mousepressed(x, y, button)
    if not self.visible or button ~= 1 then return end

    for _, btn in ipairs(self.buttons) do
        if self:isMouseOverButton(x, y, btn) then
            print('menu btn clicked', btn.action)
            return btn.action
        end
    end

    return nil
end

function MenuPanel:isMouseOverButton(x, y, button)
    return x >= button.x and x <= button.x + button.width and
        y >= button.y and y <= button.y + button.height
end

function MenuPanel:toggle()
    self.visible = not self.visible
end

return MenuPanel

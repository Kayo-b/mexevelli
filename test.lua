-- function fact (n)
--     if n == 0 then
--         return 1
--     else
--         return n * fact(n-1)
--     end
-- end

-- --print('enter a number: ')
-- a = io.read("*number")
-- --print(fact(a))

-- Player = {x = 5, y = 5, health = 100}

-- function Player:new(o)
--     o = o or {}
--     setmetatable(o, self)
--     self.__index = self
--     return o
-- end

-- function Player:move(dx, dy)
--     self.x = self.x + dx
--     self.y = self.y + dy
-- end

-- -- Create instances
-- player1 = Player:new{x = 10, y = 20}
-- player2 = Player:new()

-- player1:move(5, 5)
-- --print(player1.x, player1.y, player1.health)
-- --print(player2.x, player2.y, player2.health)

function values(t)
    local i = 0
    return function ()
        i = i + 1
        return t[i]
    end
end

t =  {10, 20, 30}
iter = values(t)

-- while true do
--     local ele = iter()
--     if ele == nil then break end
--     --print(ele)
-- end

-- for ele in values(t) do
--     --print(ele)
-- end
iterator = values(t)
--print(values(t))
--print(iterator())
--print(iterator())
local aux = {}

function aux.printTable(t)
    for k, v in pairs(t) do
        if type(v) == "table" then
            print(k .. ":")
            aux.printTable(v)
        else
            print(k, v)
        end
    end
end

return aux
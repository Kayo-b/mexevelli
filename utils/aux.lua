local aux = {}

function aux.printTable(t)
    for k, v in pairs(t) do
        if type(v) == "table" then
            --print(k .. ":")
            aux.printTable(v)
        else
            --print(k, v)
        end
    end
end

function aux.isCardRepeated(t, cards)
    for i, card in pairs(cards) do
        if t == card then
            --print('CARD REPEATED', card.value, t.value)
            return true
        else
            --print('CARD NOT REPEATED')
            return false
        end
    end
end

function aux.isSequence(cards)
    for i, card in pairs(cards) do
        --print(cards[i])
    end
end
return aux
if Link.framework ~= 'ox' then return end

function GetPlayerCharacterName(source)
    local player = exports.ox_core:GetPlayer(source)
    if player and player.charId then
        -- OX uses different structure, fallback to server player name
        local name = GetPlayerName(source)
        local parts = {}
        for part in name:gmatch("%S+") do
            table.insert(parts, part)
        end
        return parts[1] or '', parts[2] or ''
    end
    -- Fallback to server player name
    local name = GetPlayerName(source)
    local parts = {}
    for part in name:gmatch("%S+") do
        table.insert(parts, part)
    end
    return parts[1] or 'Player', parts[2] or tostring(source)
end

function IsPlayerAdmin(source)
    return IsPlayerAceAllowed(source, 'admin')
end

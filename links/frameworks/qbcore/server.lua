if Link.framework ~= 'qbcore' then return end

function GetPlayerCharacterName(source)
    local player = exports['qb-core']:GetPlayer(source)
    if player and player.PlayerData and player.PlayerData.charinfo then
        return player.PlayerData.charinfo.firstname, player.PlayerData.charinfo.lastname
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

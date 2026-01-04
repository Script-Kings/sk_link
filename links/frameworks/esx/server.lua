if Link.framework ~= 'esx' then return end

function GetPlayerCharacterName(source)
    local ESX = exports['es_extended']:getSharedObject()
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        -- ESX stores name in different places depending on version
        local name = xPlayer.getName()
        if name then
            local parts = {}
            for part in name:gmatch("%S+") do
                table.insert(parts, part)
            end
            return parts[1] or '', parts[2] or ''
        end
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
    local ESX = exports['es_extended']:getSharedObject()
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        return xPlayer.getGroup() == 'admin' or xPlayer.getGroup() == 'superadmin'
    end
    return false
end

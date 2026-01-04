if Link.framework ~= 'qbox' then return end

function GetPlayerCharacterName(source)
    local player = exports.qbx_core:GetPlayer(source)
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

function GetPlayerCitizenId(source)
    local player = exports.qbx_core:GetPlayer(source)
    return player.PlayerData.citizenid
end

function GetPlayerMoney(source, type)
    local money = exports.qbx_core:GetMoney(source, type)
    return money
end

function CanPlayerAfford(source, amount)
    local cash = GetPlayerMoney(source, 'cash')
    local bank = GetPlayerMoney(source, 'bank')

    if cash >= amount then
        return true
    end

    if bank >= amount then
        return true
    end

    return false
end

function AddPlayerMoney(source, type, amount)
    local player = exports.qbx_core:GetPlayer(source)

    if not player then return false end

    return exports.qbx_core:AddMoney(source, type, amount)
end

function RemovePlayerMoney(source, type, amount)
    local player = exports.qbx_core:GetPlayer(source)

    if not player then return false end

    return exports.qbx_core:RemoveMoney(source, type, amount)
end

function IsPlayerAdmin(source)
    return IsPlayerAceAllowed(source, 'admin')
end

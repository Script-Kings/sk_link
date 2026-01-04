if Link.framework ~= 'esx' then return end

local ESX = exports['es_extended']:getSharedObject()

RegisterNetEvent('esx:playerLoaded', function(xPlayer, skin)
    PLAYER = xPlayer
    Debug('Player loaded')
end)

RegisterNetEvent('esx:setJob', function(jobData)
    PLAYER.job = jobData
end)

function GetPlayerJob()
    return PLAYER.job.name
end

function NotifyViaFramework(message, type)
    if type == 'warning' then
        type = 'error'
    end

    ESX.ShowNotification(message, type, 4000)
end

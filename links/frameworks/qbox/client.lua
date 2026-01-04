if Link.framework ~= 'qbox' then return end

require '@qbx_core.modules.playerdata'

PLAYER = QBX.PlayerData

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PLAYER = QBX.PlayerData
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(jobData)
    PLAYER.job = jobData
end)

function GetPlayerJob()
    return PLAYER.job.name
end

function NotifyViaFramework(message, type)
    exports.qbx_core:Notify(message, type, 4000)
end

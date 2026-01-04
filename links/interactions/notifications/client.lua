-- Client-side notification wrapper (if needed for future use)
function NotifyClient(message, type)
    type = type or 'info'

    if Link.notifications == 'ox' then
        lib.notify({
            description = message,
            type = type
        })
    elseif Link.notifications == 'framework' then
        if Link.framework == 'qbox' or Link.framework == 'qbcore' then
            if Link.framework == 'qbox' then
                exports.qbx_core:Notify(message, type, 4000)
            else
                exports['qb-core']:GetCoreObject().Functions.Notify(message, type)
            end
        elseif Link.framework == 'esx' then
            local ESX = exports['es_extended']:getSharedObject()
            ESX.ShowNotification(message)
        elseif Link.framework == 'ox' then
            lib.notify({
                description = message,
                type = type
            })
        else
            lib.notify({
                description = message,
                type = type
            })
        end
    else
        lib.notify({
            description = message,
            type = type
        })
    end
end

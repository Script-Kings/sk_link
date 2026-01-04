-- Framework-agnostic notification wrapper
function NotifyPlayer(source, message, type)
    type = type or 'info'

    if Link.notifications == 'ox' then
        TriggerClientEvent('ox_lib:notify', source, {
            description = message,
            type = type
        })
    elseif Link.notifications == 'framework' then
        -- Framework-specific notifications are handled in framework files
        if Link.framework == 'qbox' or Link.framework == 'qbcore' then
            TriggerClientEvent('QBCore:Notify', source, message, type)
        elseif Link.framework == 'esx' then
            TriggerClientEvent('esx:showNotification', source, message)
        elseif Link.framework == 'ox' then
            TriggerClientEvent('ox_lib:notify', source, {
                description = message,
                type = type
            })
        else
            -- Fallback to ox_lib
            TriggerClientEvent('ox_lib:notify', source, {
                description = message,
                type = type
            })
        end
    elseif Link.notifications == 'codem-notification' then
        TriggerClientEvent('codem-notification:client:notify', source, {
            type = type,
            message = message
        })
    elseif Link.notifications == 'okokNotify' then
        TriggerClientEvent('okokNotify:Alert', source, '', message, 4000, type)
    elseif Link.notifications == 'mythic' then
        TriggerClientEvent('mythic_notify:client:SendAlert', source, {
            type = type,
            text = message
        })
    elseif Link.notifications == '17mov' then
        TriggerClientEvent('17mov:notify', source, message, type)
    else
        -- Fallback to ox_lib
        TriggerClientEvent('ox_lib:notify', source, {
            description = message,
            type = type
        })
    end
end

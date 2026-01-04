-- Target system wrapper for client-side
function AddTargetToPlayer(options)
    if Link.input == 'ox_target' then
        exports.ox_target:addGlobalPlayer(options)
    elseif Link.input == 'qb-target' then
        exports['qb-target']:AddGlobalPlayer(options)
    elseif Link.input == 'qtarget' then
        exports.qtarget:AddGlobalPlayer(options)
    elseif Link.input == 'interact' then
        -- Interact system implementation if needed
        exports.interact:AddGlobalPlayer(options)
    end
end

function RemoveTargetFromPlayer(name)
    if Link.input == 'ox_target' then
        exports.ox_target:removeGlobalPlayer(name)
    elseif Link.input == 'qb-target' then
        exports['qb-target']:RemoveGlobalPlayer(name)
    elseif Link.input == 'qtarget' then
        exports.qtarget:RemoveGlobalPlayer(name)
    elseif Link.input == 'interact' then
        exports.interact:RemoveGlobalPlayer(name)
    end
end

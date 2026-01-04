local currentGroupId = nil
local isLeader = false

local function AddRadialItem()
    if not PlayerGroups.enabled then return end
    if Link.radial ~= 'ox' then return end

    Wait(1000)

    lib.addRadialItem({
        id = 'playergroups',
        label = 'Groups',
        icon = 'users',
        onSelect = function()
            lib.showContext('playergroups_menu')
        end
    })
end

local function UpdatePlayerTarget()
    if not currentGroupId or not isLeader then
        RemoveTargetFromPlayer('invite_player')
        return
    end

    local targetOptions = {}

    if Link.input == 'ox_target' then
        targetOptions = {
            {
                name = 'invite_player',
                icon = 'users',
                label = 'Invite to Group',
                distance = 2,
                onSelect = function(data)
                    local targetPed = data.entity
                    local playerIndex = NetworkGetPlayerIndexFromPed(targetPed)
                    local serverId = GetPlayerServerId(playerIndex)
                    TriggerServerEvent('sk_playergroups:server:InvitePlayer', serverId)
                end
            }
        }
    elseif Link.input == 'qb-target' or Link.input == 'qtarget' then
        targetOptions = {
            {
                name = 'invite_player',
                icon = 'fas fa-users',
                label = 'Invite to Group',
                distance = 2,
                action = function(entity)
                    local targetPed = entity
                    local playerIndex = NetworkGetPlayerIndexFromPed(targetPed)
                    local serverId = GetPlayerServerId(playerIndex)
                    TriggerServerEvent('sk_playergroups:server:InvitePlayer', serverId)
                end
            }
        }
    end

    if #targetOptions > 0 then
        AddTargetToPlayer(targetOptions)
    end
end

local function UpdateGroupMenu()
    local options = {}

    if currentGroupId then
        local groupMembers = lib.callback.await('sk_playergroups:server:GetGroupMembers', false, currentGroupId)

        options = {
            {
                readOnly = true,
                icon = 'users',
                title = "Your current group:",
            },

        }

        for _, member in pairs(groupMembers) do
            table.insert(options, {
                icon = member.role == "leader" and "crown" or "user",
                title = ("%s %s"):format(member.firstName, member.lastName),
            })
        end

        local memberCount = #groupMembers
        for i = memberCount + 1, PlayerGroups.max_group_members do
            table.insert(options, {
                icon = 'user-plus',
                title = 'Empty slot',
                disabled = true
            })
        end

        table.insert(options, {
            icon = 'door-open',
            title = 'Leave Group',
            onSelect = function()
                local success = lib.callback.await('sk_playergroups:server:LeaveGroup')
                if success then
                    currentGroupId = nil
                    isLeader = false
                    UpdateGroupMenu()
                end
            end
        })
    else
        options = {
            {
                disabled = true,
                icon = 'users',
                title = "You don't belong to any groups."
            },
            {
                icon = 'plus',
                title = 'New group',
                onSelect = function()
                    local success, groupId = lib.callback.await('sk_playergroups:server:CreateGroup', false)
                    if success and groupId then
                        isLeader = true
                        currentGroupId = groupId
                        UpdateGroupMenu()
                        lib.showContext('playergroups_menu')
                    end
                end
            }
        }
    end

    lib.registerContext({
        id = 'playergroups_menu',
        title = 'Groups',
        options = options,
        canClose = true
    })
    UpdatePlayerTarget()
end

lib.callback.register('sk_playergroups:client:InviteDialog', function()
    return lib.alertDialog({
        header = "You've been invited to join a group",
        content = 'Firstname Lastname has invited you to join their group.',
        centered = true,
        cancel = true,
        labels = {
            cancel = 'Decline',
            confirm = 'Accept Invite'
        }
    })
end)

lib.callback.register('sk_playergroups:client:RequestJoinDialog', function(data)
    return lib.alertDialog({
        header = "Join Request",
        content = ("%s wants to join your group"):format(data.requesterName),
        centered = true,
        cancel = true,
        labels = {
            cancel = 'Decline',
            confirm = 'Accept'
        }
    })
end)

RegisterNetEvent('sk_playergroups:client:AddRadialItem', AddRadialItem)

RegisterNetEvent('sk_playergroups:client:Update', function(data)
    if data then
        currentGroupId = data.groupId
        isLeader = data.isLeader or false
    else
        currentGroupId = nil
        isLeader = false
    end

    UpdateGroupMenu()
    UpdatePlayerTarget()
end)

-- Framework-agnostic player loaded handler
local function OnPlayerLoaded()
    UpdateGroupMenu()
    UpdatePlayerTarget()
    AddRadialItem()
end

-- Framework-specific handlers
if Link.framework == 'qbox' or Link.framework == 'qbcore' then
    AddEventHandler('QBCore:Client:OnPlayerLoaded', OnPlayerLoaded)
elseif Link.framework == 'esx' then
    AddEventHandler('esx:playerLoaded', OnPlayerLoaded)
elseif Link.framework == 'ox' then
    AddEventHandler('ox:playerLoaded', OnPlayerLoaded)
end

-- Fallback for standalone or when player is already loaded
AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        Wait(1000) -- Wait for framework to initialize
        if Link.framework == 'standalone' or LocalPlayer.state.isLoggedIn then
            AddRadialItem()
            UpdateGroupMenu()
            UpdatePlayerTarget()
        end
    end
end)

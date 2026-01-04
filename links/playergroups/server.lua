local Groups = {}

--
--
-- FUNCTIONS
--
--

local function IsGroupLocked(groupId)
    local group = Groups[groupId]
    return group and group.locked or false
end

local function GetGroupMemberCount(groupId)
    if not Groups[groupId] then return 0 end
    local count = 0
    for _ in pairs(Groups[groupId].members) do
        count = count + 1
    end
    return count
end

local function GetGroupMembers(groupId)
    if not Groups[groupId] then return {} end

    local members = {}
    for playerId, role in pairs(Groups[groupId].members) do
        local first, last = GetPlayerCharacterName(playerId)
        table.insert(members,
            { id = playerId, firstName = first or 'Player', lastName = last or tostring(playerId), role = role })
    end
    return members
end

local function BroadcastGroupUpdate(groupId)
    if not groupId or not Groups[groupId] then return end

    for playerId, role in pairs(Groups[groupId].members) do
        TriggerClientEvent('sk_playergroups:client:Update', playerId, {
            groupId = groupId,
            isLeader = role == 'leader',
        })
    end
end

local function BroadcastGroupNotify(groupId, message, type)
    if not groupId or not Groups[groupId] then return end

    for playerId, _ in pairs(Groups[groupId].members) do
        NotifyPlayer(playerId, message, type)
    end
end

local function GetPlayerGroupId(src)
    for groupId, groupData in pairs(Groups) do
        if groupData.members[src] then
            return groupId
        end
    end
end

local function CreateGroup(src)
    local existingGroup = GetPlayerGroupId(src)
    if existingGroup then
        print(("Player %s already in group %s"):format(src, existingGroup))
        return existingGroup
    end

    local newGroupId = #Groups + 1
    Groups[newGroupId] = {
        locked = false,
        activity = nil,
        members = {
            [src] = "leader"
        }
    }

    NotifyPlayer(src, 'You have successfully created a group', 'success')
    BroadcastGroupUpdate(newGroupId)
    return newGroupId
end

local function IsPlayerGroupLeader(src)
    local groupId = GetPlayerGroupId(src)
    if not groupId then return false end

    return Groups[groupId].members[src] == "leader"
end

local function GetGroupLeader(groupId)
    if not Groups[groupId] then return nil end

    for playerId, role in pairs(Groups[groupId].members) do
        if role == "leader" then
            return playerId
        end
    end

    return nil
end

local function DisbandGroup(groupId, disbanderName, disbanderId)
    if not Groups[groupId] then return end

    if disbanderName then
        -- Notify all members except the disbander
        for playerId, _ in pairs(Groups[groupId].members) do
            if playerId ~= disbanderId then
                NotifyPlayer(playerId, ("%s has disbanded the group"):format(disbanderName), 'info')
            end
        end
    end

    for playerId, _ in pairs(Groups[groupId].members) do
        TriggerClientEvent('sk_playergroups:client:Update', playerId, nil)
    end

    Groups[groupId] = nil
end

local function LeaveGroup(src)
    local groupId = GetPlayerGroupId(src)
    if not groupId then
        return false
    end

    if IsGroupLocked(groupId) then
        NotifyPlayer(src, 'The group is currently locked', 'error')
        return false
    end

    if IsPlayerGroupLeader(src) then
        local first, last = GetPlayerCharacterName(src)
        local playerName = ("%s %s"):format(first, last)
        DisbandGroup(groupId, playerName, src)
        return true
    else
        local first, last = GetPlayerCharacterName(src)
        local playerName = ("%s %s"):format(first, last)

        Groups[groupId].members[src] = nil

        if next(Groups[groupId].members) == nil then
            Groups[groupId] = nil
        else
            BroadcastGroupNotify(groupId, ("%s has left the group"):format(playerName), 'info')
            BroadcastGroupUpdate(groupId)
        end

        return true
    end
end

local function IsPlayerInGroup(src)
    return GetPlayerGroupId(src) ~= nil
end

local function AddPlayerToGroup(src, groupId)
    local existingGroup = GetPlayerGroupId(src)
    if existingGroup then
        return false, "Player already in a group."
    end

    if not Groups[groupId] then
        return false, "Invalid group."
    end

    if GetGroupMemberCount(groupId) >= PlayerGroups.max_group_members then
        return false, "Group is full."
    end

    Groups[groupId].members[src] = "member"
    return true
end

local function SetGroupActivity(groupId, activity)
    if not Groups[groupId] then
        return false, "Invalid group."
    end

    Groups[groupId].activity = activity
    local tidiedActivity = activity:gsub("^%l", string.upper)

    BroadcastGroupUpdate(groupId)
    BroadcastGroupNotify(groupId, ("Your group has started an activity: %s"):format(tidiedActivity or "None"), 'info')
    return true
end

local function GetGroupActivity(groupId)
    if not Groups[groupId] then return nil end
    return Groups[groupId].activity
end

--
--
-- NET EVENTS
--
--

RegisterNetEvent('sk_playergroups:server:InvitePlayer', function(targetId)
    local src = source

    if not IsPlayerInGroup(src) then
        NotifyPlayer(src, "You must be in a group to invite someone", "error")
        return
    end

    if IsPlayerInGroup(targetId) then
        NotifyPlayer(src, "This player is already in a group", "error")
        return
    end

    if not IsPlayerGroupLeader(src) then
        NotifyPlayer(src, "You must be the group leader to invite players", "error")
        return
    end

    local groupId = GetPlayerGroupId(src)

    if GetGroupMemberCount(groupId) >= PlayerGroups.max_group_members then
        NotifyPlayer(src, "The group is already full", "error")
        return
    end

    NotifyPlayer(src, "Invitation sent to player", "info")

    local response = lib.callback.await('sk_playergroups:client:InviteDialog', targetId)
    if response == "confirm" then
        local first, last = GetPlayerCharacterName(targetId)
        local playerName = ("%s %s"):format(first, last)

        BroadcastGroupNotify(groupId, ("%s has joined the group"):format(playerName), 'success')

        local success, errorMsg = AddPlayerToGroup(targetId, groupId)
        if success then
            NotifyPlayer(targetId, 'You have joined the group', 'success')
            BroadcastGroupUpdate(groupId)
        else
            NotifyPlayer(src, errorMsg or "Failed to add player to the group", "error")
        end
    else
        NotifyPlayer(src, 'The player declined your invitation', 'error')
    end
end)

RegisterNetEvent('sk_playergroups:server:SetActivity', function(activity)
    local src = source
    local groupId = GetPlayerGroupId(src)

    if not groupId then
        NotifyPlayer(src, "You must be in a group to set an activity", "error")
        return
    end

    if not IsPlayerGroupLeader(src) then
        NotifyPlayer(src, "You must be the group leader to set an activity", "error")
        return
    end

    SetGroupActivity(groupId, activity)
end)

--
--
-- CALLBACKS
--
--

lib.callback.register('sk_playergroups:server:CreateGroup', function(source)
    return CreateGroup(source)
end)

lib.callback.register('sk_playergroups:server:LeaveGroup', function(source)
    return LeaveGroup(source)
end)

lib.callback.register('sk_playergroups:server:DisbandGroup', function(source)
    local groupId = GetPlayerGroupId(source)

    if not groupId then
        return false, "You must be in a group to disband it."
    end

    if not IsPlayerGroupLeader(source) then
        return false, "You must be the leader to disband the group."
    end

    local first, last = GetPlayerCharacterName(source)
    local playerName = ("%s %s"):format(first, last)
    DisbandGroup(groupId, playerName, source)
    return true
end)

lib.callback.register('sk_playergroups:server:IsPlayerInGroup', function(source)
    return IsPlayerInGroup(source)
end)

lib.callback.register('sk_playergroups:server:GetGroupMembers', function(source, groupId)
    return GetGroupMembers(groupId)
end)

lib.callback.register('sk_playergroups:server:GetPlayerGroupId', function(source)
    return GetPlayerGroupId(source)
end)

lib.callback.register('sk_playergroups:server:GetGroupsWithPlayerData', function()
    local groups = {}
    for groupId, groupData in pairs(Groups) do
        local members = GetGroupMembers(groupId)
        table.insert(groups, {
            id = groupId,
            members = members,
            activity = groupData.activity or nil
        })
    end
    return groups
end)

lib.callback.register('sk_playergroups:server:SetActivity', function(source, activity)
    local groupId = GetPlayerGroupId(source)

    if not groupId then
        return false, "You must be in a group to set activity."
    end

    if not IsPlayerGroupLeader(source) then
        return false, "You must be the leader to set activity."
    end

    return SetGroupActivity(groupId, activity)
end)

lib.callback.register('sk_playergroups:server:GetActivity', function(source)
    local groupId = GetPlayerGroupId(source)
    if not groupId then return nil end
    return GetGroupActivity(groupId)
end)

lib.callback.register('sk_playergroups:server:RequestJoinGroup', function(source, groupId)
    local requesterId = source

    if IsPlayerInGroup(requesterId) then
        return false, "You are already in a group."
    end

    if not Groups[groupId] then
        return false, "Group does not exist."
    end

    if IsGroupLocked(groupId) then
        return false, "This group is locked."
    end

    if GetGroupMemberCount(groupId) >= PlayerGroups.max_group_members then
        return false, "Group is full."
    end

    local leaderId = nil
    for playerId, role in pairs(Groups[groupId].members) do
        if role == "leader" then
            leaderId = playerId
            break
        end
    end

    if not leaderId then
        return false, "Group has no leader."
    end

    local first, last = GetPlayerCharacterName(requesterId)
    local requesterName = ("%s %s"):format(first, last)

    local response = lib.callback.await('sk_playergroups:client:RequestJoinDialog', leaderId, {
        requesterId = requesterId,
        requesterName = requesterName,
        groupId = groupId
    })

    if response == "confirm" then
        local success, errorMsg = AddPlayerToGroup(requesterId, groupId)

        if success then
            BroadcastGroupNotify(groupId, ("%s has joined the group"):format(requesterName), 'success')
            NotifyPlayer(requesterId, 'You have joined the group', 'success')
            BroadcastGroupUpdate(groupId)
            return true
        else
            return false, errorMsg or "Failed to join group."
        end
    else
        NotifyPlayer(requesterId, 'Your request to join the group was declined', 'error')
        return false, "Request declined."
    end
end)

--
--
-- EVENT HANDLERS
--
--

-- Framework-agnostic player disconnect handler
AddEventHandler('playerDropped', function()
    local src = source
    if IsPlayerInGroup(src) then
        LeaveGroup(src)
    end
end)

-- Framework-specific handlers
if Link.framework == 'qbox' or Link.framework == 'qbcore' then
    AddEventHandler('QBCore:Server:OnPlayerUnload', function(source)
        LeaveGroup(source)
    end)
elseif Link.framework == 'esx' then
    AddEventHandler('esx:playerDropped', function(playerId)
        LeaveGroup(playerId)
    end)
end

--
--
-- EXPORTS
--
--

exports('BroadcastGroupNotify', BroadcastGroupNotify)
exports('GetPlayerGroupId', GetPlayerGroupId)
exports('CreateGroup', CreateGroup)
exports('GetGroupMembers', GetGroupMembers)
exports('IsPlayerGroupLeader', IsPlayerGroupLeader)
exports('GetGroupLeader', GetGroupLeader)
exports('DisbandGroup', DisbandGroup)
exports('LeaveGroup', LeaveGroup)
exports('IsPlayerInGroup', IsPlayerInGroup)
exports('SetGroupActivity', SetGroupActivity)
exports('GetGroupActivity', GetGroupActivity)

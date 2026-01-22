function hasPerm(player, perm)
    local characterID = exports.rp_login:getPlayerData(player, "characterID")

    if not playerPerms[characterID] then
        return false
    end

    for groupID, perms in pairs(playerPerms[characterID]) do
        if perms[perm] == true then
            return true 
        end
    end

    return false 
end

function hasPermInCurrentGroup(player, groupID, perm)
    local characterID = exports.rp_login:getPlayerData(player, "characterID")
    if not playerPerms[characterID] or not playerPerms[characterID][groupID] then
        return false
    end
    return playerPerms[characterID][groupID][perm] == true
end

function isPlayerInGroup(player, groupID)
    local characterID = exports.rp_login:getPlayerData(player, "characterID")
    if tonumber(groups[groupID].owner["id"]) == tonumber(characterID) then
        return "owner"
    end
    for k, v in pairs(groups[groupID].members) do
        if tonumber(v.id) == tonumber(characterID) then
            return "member"
        end
    end

    return false
end

function getPlayerGroupDuty(player)
	local duty = exports.rp_login:getPlayerData(player,"groupDuty")
	return duty
end
function getPlayersInGroupType(groupType)
    local playersInGroupType = {}

    for groupID, group in pairs(groups) do
        if group.type == groupType then
            for _, member in ipairs(group.members) do
                local playerElement = exports.rp_utils:getPlayerFromCharID(member.id)
                if playerElement and not playersInGroupType[playerElement] then
                    playersInGroupType[playerElement] = true
                end
            end

            if group.owner then
                local ownerElement = exports.rp_utils:getPlayerFromCharID(group.owner.id)
                if ownerElement and not playersInGroupType[ownerElement] then
                    playersInGroupType[ownerElement] = true
                end
            end
        end
    end

    return playersInGroupType
end


function getFreePlayerGroupSlot(player)
	local i = 1
	while(true) do
		if(not tonumber(playerSlot[player][i])) then return i end
		i = i + 1
	end
	return false
end

function getGroupData(groupID, data)
	return groups[tonumber(groupID)][data] or false
end
function getPlayersInGroup(groupID)
    local targetedPlayers = {}
    local players = getElementsByType("player")
    for k, v in pairs(players) do
        if isPlayerInGroup(v, groupID) then
            table.insert(targetedPlayers, v)
        end
    end
    return targetedPlayers
end


function removeMemberFromGroup(characterID, groupID)
    local members = groups[groupID].members
	local groupType = groups[groupID].groupType
	local ids = {} 
	for k,v in pairs(members) do
		if v.id == characterID then
			table.remove(members, k)
		end
		table.insert(ids, v.id)
	end
    for k, v in pairs(ids) do
        if v == characterID then
            table.remove(ids, k)

            if playerPerms[characterID] and playerPerms[characterID][groupID] then
                playerPerms[characterID][groupID] = nil
            end

            exports.rp_db:query_free("DELETE FROM playergroupperms WHERE characterID = ? AND groupID = ?", characterID, groupID)
            exports.rp_db:query_free("UPDATE groups SET members = ? WHERE id = ?", toJSON(ids), groupID)
			local target = exports.rp_utils:getPlayerFromCharID(characterID)
			if target then
			getPlayerGroups(target)
			if groupType == 2 or groupType == 5 then updateBlipsForPlayer(target, true) end
			exports.rp_library:createBox(target,"Zostałeś wyrzucony z grupy: "..groups[groupID].name)
			end
            return true
        end
    end
    return false
end

function addMemberToGroup(player, groupID, canAddPlayers)
    local characterID = exports.rp_login:getPlayerData(player, "characterID")
    local members = groups[groupID].members
	local owner = groups[groupID].owner["id"]
	local groupType = groups[groupID].groupType
	if characterID == owner then return false end
	local ids = {} 
	for k,v in pairs(members) do
		table.insert(ids, v.id)
	end
    for _, member in pairs(members) do
        if member.id == characterID then
            return false 
        end
    end


	table.insert(ids, characterID)

    local groupPerms = {}

    if canAddPlayers then
        groupPerms["invite"] = true
    end

    exports.rp_db:query_free("INSERT INTO playergroupperms (characterID, perms, groupID) VALUES (?,?,?)", characterID, toJSON(groupPerms), groupID)

    playerPerms[characterID] = playerPerms[characterID] or {}
    playerPerms[characterID][groupID] = groupPerms
    table.insert(members, {
        id = characterID,
        name = exports.rp_utils:getPlayerICName(player),
        perms = groupPerms  
    })
	exports.rp_library:createBox(player,"Zostałeś dodany do grupy "..groups[groupID].name)
	exports.rp_db:query_free("UPDATE groups SET members = ? WHERE id = ?", toJSON(ids), groupID)
	if groupType == 2 or groupType == 5 then updateBlipsForPlayer(player) end
	getPlayerGroups(player)
    return true
end


-- function getPlayerGroups(player)
    -- local characterID = exports.rp_login:getPlayerData(player, "characterID")
	-- if playerSlot[player] then playerSlot[player] = {} end
    -- local query = exports.rp_db:query("SELECT owner, members, id FROM groups")
    -- local foundGroup = false 

    -- for _, group in ipairs(query) do
        -- if tonumber(group.owner) == characterID then
            -- setPlayerSlotGroup(player, group.id)
            -- foundGroup = true 
        -- else
            -- local members = fromJSON(group.members)
            -- if type(members) == "table" then
                -- for _, memberID in ipairs(members) do
                    -- if tonumber(memberID) == characterID then
                        -- setPlayerSlotGroup(player, group.id)
                        -- foundGroup = true 
                        -- break
                    -- end
                -- end
            -- end
        -- end
    -- end

    -- if not foundGroup then
        -- playerSlot[player] = {} 
    -- end
-- end

function getPlayerGroups(player)
    local characterID = exports.rp_login:getPlayerData(player, "characterID")
    if not characterID then
        return
    end

    -- Resetowanie slotów grupowych dla gracza
    playerSlot[player] = {}

    local foundGroup = false

    for groupID, groupData in pairs(groups) do
        if groupData.owner and tonumber(groupData.owner.id) == tonumber(characterID) then
            setPlayerSlotGroup(player, groupID)
            foundGroup = true
        else
            for _, member in ipairs(groupData.members) do
                if tonumber(member.id) == tonumber(characterID) then
                    setPlayerSlotGroup(player, groupID)
                    foundGroup = true
                    break
                end
            end
        end
    end

    if not foundGroup then
        playerSlot[player] = {}
    end
end

function isPlayerInGroupType(player, groupType)
    if not playerSlot[player] then
        return false
    end

    for slot, groupID in pairs(playerSlot[player]) do
        if groupID and groups[groupID] and groups[groupID].type == groupType then
            return true
        end
    end

    return false
end

groups = {}
playerSlot = {}
playerPerms = {}
local playerDuties = {}
local playerDutyTimers = {}

function loadGroups()
    local groupsData = exports.rp_db:query("SELECT * FROM groups")

    local allMembersQuery = [[
        SELECT c.id, c.name, c.surname, g.groupID, g.perms, g.skin 
        FROM characters AS c
        JOIN playergroupperms AS g ON c.id = g.characterID
        WHERE g.groupID IN (
            SELECT id FROM groups
        )
    ]]
    local allMembersData = exports.rp_db:query(allMembersQuery)

    local groupMembers = {}
    for _, member in ipairs(allMembersData) do
        groupMembers[member.groupID] = groupMembers[member.groupID] or {}
        table.insert(groupMembers[member.groupID], {
            id = member.id,
            name = member.name .. " " .. member.surname,
            perms = fromJSON(member.perms),
			skin = member.skin
        })

        playerPerms[member.id] = playerPerms[member.id] or {}
        playerPerms[member.id][member.groupID] = fromJSON(member.perms)
		playerPerms[member.id][member.groupID].skin = member.skin
    end

    local allOwnersQuery = [[
        SELECT c.id, c.name, c.surname, g.id AS groupID, p.perms, p.skin 
        FROM characters AS c
        JOIN groups AS g ON c.id = g.owner
        LEFT JOIN playergroupperms AS p ON p.characterID = c.id AND p.groupID = g.id
    ]]
    local allOwnersData = exports.rp_db:query(allOwnersQuery)

    local groupOwners = {}
    for _, owner in ipairs(allOwnersData) do
        groupOwners[owner.groupID] = {
            id = owner.id,
            name = owner.name .. " " .. owner.surname,
            perms = owner.perms and fromJSON(owner.perms) or {},
			skin = owner.skin
        }

        playerPerms[owner.id] = playerPerms[owner.id] or {}
		playerPerms[owner.id][owner.groupID].skin = owner.skin
        playerPerms[owner.id][owner.groupID] = owner.perms and fromJSON(owner.perms) or {}
    end

    for _, group in ipairs(groupsData) do
        local members = groupMembers[group.id] or {}
        local owner = groupOwners[group.id] or nil

        if owner then
            members = filterMembersWithoutOwner(members, owner.id)
        end

        groups[group.id] = {
            id = group.id,
            name = group.name,
            type = group.type,
            owner = owner,
            perms = fromJSON(group.perms),
            members = members,
            TAG = group.TAG,
            createdAt = group.createdAt,
			ooc = true,
			rgb = fromJSON(group.rgb)
        }

        -- iprint("Group ID: " .. group.id, groups[group.id].owner, groups[group.id].members)
    end
end

function filterMembersWithoutOwner(members, ownerId)
    local filteredMembers = {}
    for _, member in ipairs(members) do
        if member.id ~= ownerId then
            table.insert(filteredMembers, member)
        end
    end
    return filteredMembers
end




function openGroupCommand(player, cmand, ...)
    local arg = {...}

    -- Komendy administracyjne (PIERWSZE w kolejności!)
    if arg[1] == "usun" then
        if not exports.rp_admin:hasAdminPerm(player, "creatingGroups") then return end
        local groupID = tonumber(arg[2])
        if not groupID then
            return exports.rp_library:createBox(player, "/g usun [id grupy]")
        end
        if not groups[groupID] then
            return exports.rp_library:createBox(player, "Grupa o podanym ID nie istnieje.")
        end

        -- Usuwanie grupy
        local members = groups[groupID].members
        local owner = groups[groupID].owner.id
        local vehicles = exports.rp_vehicles:getGroupVehicles(groupID)
        for k, v in pairs(vehicles) do
            exports.rp_db:query_free("DELETE FROM vehicles WHERE id = ?", v.uid)
        end
        groups[groupID] = nil
        exports.rp_db:query_free("DELETE FROM groups WHERE id = ?", groupID)
        exports.rp_db:query_free("DELETE FROM playergroupperms WHERE groupID = ?", groupID)

        -- Powiadomienia
        local ownerElement = exports.rp_utils:getPlayerFromCharID(owner)
        if ownerElement then
            exports.rp_library:createBox(ownerElement, "Twoja grupa została usunięta przez administrację.")
            getPlayerGroups(ownerElement)
            playerPerms[owner][groupID] = nil
        end

        for k, v in pairs(members) do
            local member = exports.rp_utils:getPlayerFromCharID(v.id)
            if member then
                exports.rp_library:createBox(member, "Grupa, w której byłeś członkiem, została usunięta.")
                getPlayerGroups(member)
                playerPerms[v.id][groupID] = nil
            end
        end

    elseif arg[1] == "stworz" then
        if not exports.rp_admin:hasAdminPerm(player, "creatingGroups") then return end
        triggerClientEvent(player, "onPlayerTryToCreateGroup", player, {}, nil, nil, nil, nil)

    elseif arg[1] == "edytuj" then
        if not exports.rp_admin:hasAdminPerm(player, "creatingGroups") then return end
        local groupID = tonumber(arg[2])
        if not groupID then
            return exports.rp_library:createBox(player, "/g edytuj [id]")
        end
        if not groups[groupID] then
            return exports.rp_library:createBox(player, "Grupa o podanym ID nie istnieje.")
        end
        triggerClientEvent(player, "onPlayerTryToCreateGroup", player, 
            getGroupData(groupID, "perms"), 
            getGroupData(groupID, "type"), 
            getGroupData(groupID, "name"), 
            getGroupData(groupID, "owner"), 
            groupID
        )
	elseif arg[2] == "setskin" then
		local groupID = getPlayerGroupFromSlot(player, tonumber(arg[1]))
        if not groupID then 
            return exports.rp_library:createBox(player, "Nie masz grupy na tym slocie!") 
        end
        if not hasPermInCurrentGroup(player, groupID, "invite") then return iprint("brak permow", player, groupID) end
		local targetID = tonumber(arg[3]) -- /g [slot] setskin [target] [targetskin]
		local target = exports.rp_login:findPlayerByID(targetID)
		if not target then return exports.rp_library:createBox(player, "Nieznaleziono gracza.") end
		if not isPlayerInGroup(target, groupID) then return exports.rp_library:createBox(player, "Gracz nie jest w tej grupie.") end
		local targetSkin = tonumber(arg[4])
		if not targetSkin then return exports.rp_library:createBox(player, "/g [slot] setskin [target] [targetskin]") end
		local checkSkin = exports.rp_shop:skinIsPremium(targetSkin)
		if checkSkin then return exports.rp_library:createBox(player,"Niemożliwe jest ustawienie tego skina.") end
		local characterID = exports.rp_login:getPlayerData(target,"characterID")
		playerPerms[characterID][groupID]["skin"] = targetSkin
		exports.rp_library:createBox(player,"Ustawiono skina.")
		local success = exports.rp_db:query_free("UPDATE playergroupperms SET skin = ? WHERE characterID = ? AND groupID = ?", targetSkin, characterID, groupID)

		
	elseif arg[2] == "skin" then
		local groupID = getPlayerGroupFromSlot(player, tonumber(arg[1]))
        if not groupID then 
            return exports.rp_library:createBox(player, "Nie masz grupy na tym slocie!") 
        end
		local skin = playerPerms[exports.rp_login:getPlayerData(player,"characterID")][groupID]["skin"]
		exports.rp_newmodels:setElementModel(player, skin)
    -- Komendy grupowe (OOC)
    elseif arg[1] and arg[2] == "ooc" then
        local groupID = getPlayerGroupFromSlot(player, tonumber(arg[1]))
        if not groupID then 
            return exports.rp_library:createBox(player, "Nie masz grupy na tym slocie!") 
        end
        if not hasPermInCurrentGroup(player, groupID, "invite") then return end
        groups[groupID].ooc = not groups[groupID].ooc
        local message = groups[groupID].ooc and "Lider włączył chat OOC." or "Lider wyłączył chat OOC."
        local playerList = getPlayersInGroup(groupID)
        for k, v in pairs(playerList) do
            exports.rp_chat:sendChatOOC(v, "(( "..(groups[groupID].TAG or "Brak").." )) "..message, 255, 0, 0)
        end
	elseif tonumber(arg[1]) and arg[2] == "duty" then
		local slot = tonumber(arg[1])
        local groupID = getPlayerGroupFromSlot(player, slot)
        if not groupID then
            return exports.rp_library:createBox(player, "Brak grupy na slocie "..slot)
        end
		local dutyEnabled = exports.rp_login:getPlayerData(player, "groupDuty")
		if dutyEnabled then
			exports.rp_login:setPlayerData(player,"groupDuty", false )
			exports.rp_library:createBox(player,"Zszedłeś z duty.")
			removeDuty(player)
		else
		if groups[groupID].type == 1 or groups[groupID].type == 6 then 
		local isInInterior = exports.rp_login:getPlayerData(player,"currentInterior")
		if not isInInterior then return exports.rp_library:createBox(player,"Musisz być w interiorze, aby włączyć duty tej grupy.") end
		local validInterior = tonumber(isInInterior.interiorOwner) == tonumber(groupID)
		if not validInterior then return exports.rp_library:createBox(player, "Musisz być w interiorze, aby włączyć duty tej grupy.") end
		end
			exports.rp_login:setPlayerData(player,"groupDuty", {groups[groupID].name, groups[groupID].rgb[1], groups[groupID].rgb[2], groups[groupID].rgb[3], groupID, groups[groupID].type} )
			exports.rp_library:createBox(player,"Wszedłeś na duty.")
			if groups[groupID].type == 1 or groups[groupID].type == 2 or groups[groupID].type == 3 or groups[groupID].type == 5 or groups[groupID].type == 6 then
				local minutes = createPlayerDuty(player, groupID)
				triggerClientEvent(player,"onPlayerUpdateDutyTime", player, minutes)
			end
		end
    elseif arg[1] and arg[2] then
        local groupID = getPlayerGroupFromSlot(player, tonumber(arg[1]))
        if not groupID then 
            return exports.rp_library:createBox(player, "Nie masz grupy na tym slocie!") 
        end
        if not groups[groupID].ooc then
            return exports.rp_library:createBox(player, "Chat OOC jest wyłączony!")
        end
        local message = table.concat(arg, " ", 2)
        local groupColor = groups[groupID].rgb or {255, 255, 255}
        local playerList = getPlayersInGroup(groupID)
        for k, v in pairs(playerList) do
            exports.rp_chat:sendChatOOC(v, 
                "(( "..(groups[groupID].TAG or "Brak").." )) "..exports.rp_utils:getPlayerICName(player)..": "..message, 
                groupColor[1], 
                groupColor[2], 
                groupColor[3]
            )
        end
		
	
    -- Otwieranie GUI grupy
    elseif tonumber(arg[1]) then
        local slot = tonumber(arg[1])
        local groupID = getPlayerGroupFromSlot(player, slot)
        if not groupID then
            return exports.rp_library:createBox(player, "Brak grupy na slocie "..slot)
        end
        local groupVehicles = exports.rp_vehicles:getGroupVehicles(groupID)
        triggerClientEvent(player, "onPlayerOpenGroupGui", player, groups[groupID], groupVehicles)

    -- Domyślna pomoc
    else
        exports.rp_library:createBox(player, 
            "Dostępne komendy:\n"..
            "/g [slot] - Otwórz panel grupy\n"..
            "/g [slot] ooc - Przełącz chat OOC\n"..
            "/g [slot] [wiadomość] - Wyślij wiadomość OOC\n"..
            "/g stworz - Stwórz grupę (admin)\n"..
            "/g edytuj [id] - Edytuj grupę (admin)\n"..
            "/g usun [id] - Usuń grupę (admin)"
        )
    end
end
addCommandHandler("g", openGroupCommand, false, false)


function tstst(player, cmand)
	getPlayerGroups(player)
end
addCommandHandler("slots", tstst, false, false)

function createPlayerDuty(player, groupID) -- sa dwie opcje timer o godzinie 4:00 ktory usuwa all duty, lub restart serwera.
	local characterID = exports.rp_login:getPlayerData(player,"characterID")
	if not characterID then return end
	if not playerDuties[characterID] then playerDuties[characterID] = {} end
	 if not playerDuties[characterID][groupID] then
        playerDuties[characterID][groupID] = {
            minutes = 0
        }
    end
	if not playerDutyTimers[player] then
        startDutyTimer(player, characterID)
    end
	
	return playerDuties[characterID][groupID].minutes
end


function removeDuty(player)
    if isTimer(playerDutyTimers[player]) then
        killTimer(playerDutyTimers[player])
		playerDutyTimers[player] = nil
    end
end

function startDutyTimer(player, characterID)
    playerDutyTimers[player] = setTimer(function()
        local duty = exports.rp_login:getPlayerData(player,"groupDuty")
		local afk = exports.rp_login:getPlayerData(player,"afk")
		if afk then return end
        if duty then
            local groupID = duty[5]
            if playerDuties[characterID] and playerDuties[characterID][groupID] then
                playerDuties[characterID][groupID].minutes = playerDuties[characterID][groupID].minutes + 1
                -- outputDebugString("[DUTY] Dodano minutę dla " .. getPlayerName(player) .. " w grupie " .. groupID)
				local minutes = playerDuties[characterID][groupID].minutes
				if minutes == 15 then
					exports.rp_atm:givePlayerCustomMoney(player, 500)
					exports.rp_library:createBox(player, "Otrzymałeś 500$ za duty, za kolejne 15 minut też otrzymasz 500$.")
				elseif minutes == 30 then
					exports.rp_atm:givePlayerCustomMoney(player, 500)
					exports.rp_library:createBox(player, "Otrzymałeś 500$ za duty, nie otrzymasz już więcej pieniędzy z duty, wróc jutro.")
				end
				triggerClientEvent(player,"onPlayerUpdateDutyTime", player, playerDuties[characterID][groupID].minutes)
            end
        end
    end, 60000, 0)
end

function createGroup(permTable, groupName, groupOwner, type, groupEditing)
    if not exports.rp_admin:hasAdminPerm(client, "creatingGroups") then
        return exports.rp_anticheat:banPlayerAC(client, "Manipulate Event", "onPlayerCreateGroup/Edit")
    end
    local owner = tonumber(groupOwner)

    local target = exports.rp_login:findPlayerByID(groupOwner)
    if target then
        owner = exports.rp_login:getPlayerData(target, "characterID")
    end

    if groupEditing then -- id grupy edytujacy.
        local ownerData = exports.rp_db:query("SELECT id, name, surname FROM characters WHERE id = ?", owner)
        local ownerTable = {
            id = owner,
            name = ownerData[1].name .. " " .. ownerData[1].surname,
            perms = permTable
        }
        groups[groupEditing].perms = permTable
        groups[groupEditing].name = groupName
        groups[groupEditing].owner = ownerTable
        groups[groupEditing].type = type
		playerPerms[owner] = playerPerms[owner] or {}
		permTable.invite = true
        playerPerms[owner][groupEditing] = permTable
        exports.rp_db:query("UPDATE groups SET name = ?,  perms = ?, owner = ?, type = ? WHERE id = ?",groupName,toJSON(permTable),owner,type,groupEditing)
        exports.rp_library:createBox(client, "Pomyślnie zmodyfikowano grupę.")
        if target then
            getPlayerGroups(target)
        end
    else
        local query = exports.rp_db:query("SELECT id FROM groups ORDER BY id DESC LIMIT 1")
        local groupID = 1
        if query and query[1] then
            groupID = query[1].id + 1
        end
        permTable.invite = true
        local res = exports.rp_db:query_free("INSERT INTO groups (id, name,type,owner,perms,members) VALUES (?,?,?,?,?,?)",groupID,groupName,type,owner,toJSON(permTable),toJSON({}))
        local ownerData = exports.rp_db:query("SELECT id, name, surname FROM characters WHERE id = ?", owner)
        local ownerTable = {
            id = owner,
            name = ownerData[1].name .. " " .. ownerData[1].surname,
            perms = permTable
        }
        groups[groupID] = {id = groupID,name = groupName,type = type,owner = ownerTable,perms = permTable,members = {},TAG = "Brak",createdAt = "Brak", ooc = true, rgb = {255, 255, 255}
        }
		
		playerPerms[owner] = playerPerms[owner] or {}
        playerPerms[owner][groupID] = permTable


        local permQuery = exports.rp_db:query_free("INSERT INTO playergroupperms (characterID, perms, groupID) VALUES (?,?,?)",owner,toJSON(permTable),groupID)

        exports.rp_library:createBox(client, "Pomyślnie stworzono grupę.")
        if target then
            getPlayerGroups(target)
        end
    end
end
addEvent("onPlayerCreateGroup", true)
addEventHandler("onPlayerCreateGroup", getRootElement(), createGroup)


function onPlayerLeaveGroup(groupID)
    local isInGroup = isPlayerInGroup(client, groupID)
    if not isInGroup then
        return
    end
    local characterID = exports.rp_login:getPlayerData(client, "characterID")
    local members = groups[groupID].members
	local ids = {} 
	for k,v in pairs(members) do
		table.insert(ids, v.id)
	end
    for k, v in pairs(ids) do
        if v == characterID then
            table.remove(members, k)

            exports.rp_db:query("UPDATE groups SET members = ? WHERE id = ?", toJSON(ids), groupID)

            exports.rp_db:query_free("DELETE FROM playergroupperms WHERE characterID = ? AND groupID = ?", characterID, groupID)

            if playerPerms[characterID] then
                playerPerms[characterID][groupID] = nil

                local hasOtherGroups = false
                for otherGroupID, perms in pairs(playerPerms[characterID]) do
                    if perms then
                        hasOtherGroups = true
                        break
                    end
                end

                if not hasOtherGroups then
                    playerPerms[characterID] = nil
                end
            end
            getPlayerGroups(client)

            exports.rp_library:createBox(client, "Opuściłeś grupę.")

            break
        end
    end
end
addEvent("onPlayerLeaveGroup", true)
addEventHandler("onPlayerLeaveGroup", getRootElement(), onPlayerLeaveGroup)


function onPlayerTryToRemoveTargetFromGroup(characterID, groupID)
	local adder = hasPermInCurrentGroup(client, groupID, "invite")
	if not adder then return exports.rp_library:createBox(player,"Nie posiadasz uprawnień do wyrzucania graczy z grupy.") end
	local removed = removeMemberFromGroup(characterID, groupID)
	if not removed then return exports.rp_library:createBox(client,"Nie możesz usunąć tego gracza z grupy.") end
	exports.rp_library:createBox(client,"Pomyślnie wyrzucono gracza z grupy.")
end
addEvent("onPlayerRemoveTargetFromGroup", true)
addEventHandler("onPlayerRemoveTargetFromGroup", getRootElement(), onPlayerTryToRemoveTargetFromGroup)

function onPlayerTryToSpawnGroupVehicle(vehicleID, groupID)
	exports.rp_vehicles:spawnGroupVehicle(client, vehicleID, groupID)
end

addEvent("onPlayerTryToSpawnGroupVehicle", true)
addEventHandler("onPlayerTryToSpawnGroupVehicle", getRootElement(), onPlayerTryToSpawnGroupVehicle)

function onPlayerAddTargetToGroup(targetID, groupID, invitePerm)
	if not targetID or not tonumber(targetID) then return end
	local realTarget = exports.rp_login:findPlayerByID(targetID)
	if not realTarget then return exports.rp_library:createBox(client,"Nie znaleziono gracza o podanym ID.") end
	local hasPerm = hasPermInCurrentGroup(client, groupID, "invite")
	if not hasPerm then return exports.rp_library:createBox(client, "Nie posiadasz uprawnień do dodawania graczy.") end
	local added = addMemberToGroup(realTarget, groupID, invitePerm)
	if not added then return exports.rp_library:createBox(client,"Wystąpił błąd z dodaniem gracza do grupy.") end
	exports.rp_library:createBox(client,"Dodano gracza do grupy.")
	
end
addEvent("onPlayerAddTargetToGroup", true)
addEventHandler("onPlayerAddTargetToGroup", getRootElement(), onPlayerAddTargetToGroup)

function onPlayerChangeTargetPermsGroup(characterID, groupID, perms)
    local adder = hasPermInCurrentGroup(client, groupID, "invite")
    if not adder then 
        return exports.rp_library:createBox(client, "Nie posiadasz uprawnień do zmiany uprawnień graczy z grupy.") 
    end
	local hasInvite = hasPermInCurrentGroup(exports.rp_utils:getPlayerFromCharID(characterID), groupID, "invite")
	if hasInvite then
		perms.invite = true
	end
    local success = exports.rp_db:query_free("UPDATE playergroupperms SET perms = ? WHERE characterID = ? AND groupID = ?", toJSON(perms), characterID, groupID)
    if not success then
        return exports.rp_library:createBox(client, "Wystąpił błąd podczas zmiany uprawnień gracza.")
    end

    playerPerms[characterID] = playerPerms[characterID] or {}
    playerPerms[characterID][groupID] = perms 
	local members = groups[groupID].members
	for k,v in pairs(members) do
		if v.id == characterID then
			v.perms = perms
		end
	end
    exports.rp_library:createBox(client, "Pomyślnie zmieniono uprawnienia gracza z grupy.")
end
addEvent("onPlayerChangeTargetPermsGroup", true)
addEventHandler("onPlayerChangeTargetPermsGroup", getRootElement(), onPlayerChangeTargetPermsGroup)

function onPlayerChangeTagGroup(TAG, groupID) 
	local adder = hasPermInCurrentGroup(client, groupID, "invite")
	if not adder then return end
	if string.len(TAG) > 4 or string.len(TAG) < 4 then return exports.rp_library:createBox(client,"TAG powinien zawierać 4 znaki.") end 
	groups[groupID].TAG = TAG
	exports.rp_db:query_free("UPDATE groups SET TAG = ? WHERE id = ?", TAG, groupID)
	exports.rp_library:createBox(client,"Ustawiłeś TAG grupy.")

end
addEvent("onPlayerChangeTagGroup", true)
addEventHandler("onPlayerChangeTagGroup", getRootElement(), onPlayerChangeTagGroup)

function onPlayerChangeGroupColor(groupID, r,g,b) 
	local adder = hasPermInCurrentGroup(client, groupID, "invite")
	if not adder then return end
	groups[groupID].rgb = {r,g,b}
	exports.rp_db:query_free("UPDATE groups SET rgb = ? WHERE id = ?", toJSON(groups[groupID].rgb), groupID)
	exports.rp_library:createBox(client,"Zmieniłeś kolor grupy.")

end
addEvent("onPlayerChangeGroupColor", true)
addEventHandler("onPlayerChangeGroupColor", getRootElement(), onPlayerChangeGroupColor)


function setPlayerSlotGroup(player, groupID)
if not playerSlot[player] then playerSlot[player] = {} end
local freeSlot = getFreePlayerGroupSlot(player)
playerSlot[player][freeSlot] = groupID

end


function getPlayerGroupFromSlot(player, slot)
	if(not tonumber(playerSlot[player][slot])) then return false end
	return tonumber(playerSlot[player][slot])
end


function getSlotFromGroup(player, groupID)
	if not playerSlot[player] then return end
	for k, v in pairs(playerSlot[player]) do
		if(v == groupID) then return k end

	end
	return false
end


addEventHandler("onPlayerQuit", root,
	function(quitType)
		if playerSlot[source] then playerSlot[source] = nil end
		if playerPerms[source] then playerPerms[source] = nil end
		removeDuty(source)
	end
)

loadGroups()

local itemsToPass = {
    [1] = {
        {name = "Stek", price = 25},
        {name = "Frytki", price = 15},
		{name = "Piwo", price = 5}
    },
    [6] = {
        {name = "Karnet", price = 50},
    },
}


function commandPass(player, cmand, target, count)
	local duty = getPlayerGroupDuty(player)
	if not duty then return exports.rp_library:createBox(player,"Musisz być na duty grupy aby komuś coś podać.") end
	local items = itemsToPass[duty[6]]
	if items == nil and not items then return exports.rp_library:createBox(player,"Nie możesz nic podawać w tej grupie.") end
	if not target or not count then return exports.rp_library:createBox(player,"/podaj [id gracza] [ilosc]") end
	local isInInterior = exports.rp_login:getPlayerData(player,"currentInterior")
	if not isInInterior then return exports.rp_library:createBox(player,"Musisz być w interiorze grupy aby podać coś.") end
	local validInterior = tonumber(isInInterior.interiorOwner) == tonumber(duty[5])
	if not validInterior then return exports.rp_library:createBox(player, "Musisz być w interiorze grupy aby podać coś.") end
	local realTarget = exports.rp_login:findPlayerByID(target)
	if not realTarget then return exports.rp_library:createBox(player,"Nie znaleziono gracza o podanym ID.") end
	if not tonumber(count) and tonumber(count) < 0 then return end
	local distance = exports.rp_utils:getDistanceBetweenElements(player, realTarget)
	if distance > 10 then return exports.rp_library:createBox(player,"Graczowi któremu chcesz podać przedmiot, jest za daleko.") end
	triggerClientEvent(player,"onPlayerGiveItemsFromGroupMenu",player, items, realTarget, count)
end
addCommandHandler("podaj", commandPass, false, false)

local function getPriceForItem(itemName)
    for _, groupItems in pairs(itemsToPass) do
        for _, item in ipairs(groupItems) do
            if item.name == itemName then
                return item.price
            end
        end
    end
    return nil
end

function onPlayerPassedItemToTarget(itemName, target, itemCount)
	--validate itemName
	local duty = getPlayerGroupDuty(client)
	if not duty then return end
	local items = itemsToPass[duty[6]]
	if items == nil and not items then return end
	if tonumber(itemCount) < 0 then return end
	if itemName ~= "Stek" and itemName ~= "Frytki" and itemName ~= "Karnet" and itemName ~= "Piwo" then return end
	local typeService = 10
	if itemName == "Karnet" then typeService = 11 end
	local payment = getPriceForItem(itemName)
	exports.rp_offers:sendOffer(client, target, typeService, itemCount, payment*itemCount, itemName)
end
addEvent("onPlayerPassedItemToTarget", true)
addEventHandler("onPlayerPassedItemToTarget", getRootElement(), onPlayerPassedItemToTarget)
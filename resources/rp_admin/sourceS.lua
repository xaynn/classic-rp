local playerPermissions = {}

local defaultPerms = {["vehicleCreate"] = true, ["vehicleSpawn"] = true, ["vehicleBring"] = true, ["vehicleFix"] = true, ["vehicleLocate"] = true, ["bw"] = true, ["spec"] = true, ["giveRank"] = true}
local playerDutyTimer = {}
local playerAdminTimers = {}
local reportsData = {}
local spectatingData = {} -- admin, gracz
local private, public


function generateRSA()
    if private and public then
        return "already_loaded"
    end

    if fileExists("rsa.env") then
        local file = fileOpen("rsa.env")
        if file then
            local size = fileGetSize(file)
            local content = fileRead(file, size)
            fileClose(file)

            local parts = split(content, ":")
            if #parts >= 2 then
                private = decodeString("base64", parts[1])
                public = decodeString("base64", parts[2])
                return "loaded"
            else
                return "error"
            end
        else
            return "error"
        end
    else
        local file = fileCreate("rsa.env")
        if file then
            private, public = generateKeyPair("rsa", {size = 2048})
            local privateEncoded = encodeString("base64", private)
            local publicEncoded = encodeString("base64", public)

            fileWrite(file, privateEncoded .. ":" .. publicEncoded)
            fileClose(file)
            return "created"
        else
            return "error"
        end
    end
end


-- generateRSA()
generateRSA()
-- local private, public = generateKeyPair("rsa", { size = 2048 })

function hasAdminPerm(player, perm)
    local perms = playerPermissions[player]
    if not perms then
        return false
    end
    return perms[perm] or false
end

function getAdmins()
	return playerPermissions
end
function getAdminSpectatingPlayer(player)
	local data = spectatingData[player] or false
	return data
end
function setAdminPerms(player, perms)
    if not playerPermissions[player] then
        playerPermissions[player] = {}
    end

    for perm, state in pairs(perms) do
        if type(state) == "boolean" then
            playerPermissions[player][perm] = state
        else
            return outputChatBox("Stan uprawnienia musi być wartością boolean.", player)
        end
    end

    local _, accountID = exports.rp_login:isLoggedPlayer(player)
    local permsData = exports.rp_db:query("SELECT * FROM admins WHERE account_id = ?", accountID)

    if next(permsData) == nil then
        exports.rp_db:query("INSERT INTO admins (account_id, perms) VALUES (?, ?)", accountID, toJSON(playerPermissions[player]))
    else
        exports.rp_db:query("UPDATE admins SET perms = ? WHERE account_id = ?", toJSON(playerPermissions[player]), accountID)
    end

end

function getAdminPerms(player)
    return playerPermissions[player] or {}
end

addCommandHandler(
    "setPerm",
    function(admin, command, targetPlayerID, perm, state, allPerms)
		-- if not hasAdminPerm(admin,"giveRank") then return end
        local targetPlayer = exports.rp_login:findPlayerByID(targetPlayerID)
        if not targetPlayer then
            return exports.rp_library:createBox(admin, "Gracz nie zostal znaleziony")
        end
        if not defaultPerms[perm] then
            return exports.rp_library:createBox(admin, "Nie ma takiej permisji na serwerze.")
        end

        if allPerms then
            for k, v in pairs(defaultPerms) do
                setAdminPerm(targetPlayer, k, v)
            end
        else
            state = state == "true"

            setAdminPerm(targetPlayer, perm, state)
        end
        exports.rp_library:createBox(admin, "Uprawnienia admina zostały zaktualizowane.")
    end
)


function adminTimer(player)
if isElement(player) then 
playerDutyTimer[player] = playerDutyTimer[player] + 1
triggerClientEvent(player, "onPlayerUpdateDutyTime", player, playerDutyTimer[player])
end
-- print(playerDutyTimer[player])
end

addCommandHandler("listPerms", function(admin, command, targetPlayerID)
	if not hasAdminPerm(admin,"giveRank") then return end
    local targetPlayer = exports.rp_login:findPlayerByID(targetPlayerID)
    if not targetPlayer then
        return exports.rp_library:createBox(admin, "Gracz nie został znaleziony")
    end

    local perms = getAdminPerms(targetPlayer)
    local text = "Uprawnienia gracza:\n" 

    for perm, state in pairs(perms) do
        text = text .. perm .. " : " .. tostring(state) .. " "
    end

    exports.rp_library:createBox(admin, text)
end)

local adminRanks = {
    [3] = {"Administrator", 161, 8, 8},
    [2] = {"Community Manager", 9, 89, 22},
    [1] = {"Supporter", 26, 23, 212},
}

function dutyCommand(player, cmand)
    if not hasAdminPerm(player, "bw") then
        return
    end
    local adminlevel = exports.rp_login:getPlayerData(player, "adminlevel")
    if adminlevel then
        if exports.rp_login:getPlayerData(player, "adminDuty") then
            exports.rp_login:setPlayerData(player, "adminDuty", false)
            exports.rp_library:createBox(player, "Wylogowałeś się z duty.")
            if playerAdminTimers[player] and isTimer(playerAdminTimers[player]) then
                killTimer(playerAdminTimers[player])
            end
        else
            local rank, r, g, b = adminRanks[adminlevel][1],adminRanks[adminlevel][2],adminRanks[adminlevel][3],adminRanks[adminlevel][4]
            exports.rp_library:createBox(player, "Zalogowałeś się na duty " .. rank)
            if not playerDutyTimer[player] then
                playerDutyTimer[player] = 0
            end
            if playerAdminTimers[player] and isTimer(playerAdminTimers[player]) then
                killTimer(playerAdminTimers[player])
            end
			exports.rp_login:setPlayerData(player, "adminDuty", {rank, r, g, b})
			triggerClientEvent(player, "onPlayerUpdateDutyTime", player, playerDutyTimer[player])
            playerAdminTimers[player] = setTimer(adminTimer, 60000, 0, player)
        end
    end
end

addCommandHandler("aduty", dutyCommand, false, false)


function getColorAndRank(player)
local adminlevel = exports.rp_login:getPlayerData(player, "adminlevel")
local rank, r, g, b = adminRanks[adminlevel][1],adminRanks[adminlevel][2],adminRanks[adminlevel][3],adminRanks[adminlevel][4]
return rank, r, g, b
end
-- timer duty
function loadAdminPerms(player, uid)
    local permQuery = exports.rp_db:query("SELECT * FROM admins WHERE account_id = ?", uid)
	if next(permQuery) == nil then return end
        local permjson = fromJSON(permQuery[1].perms)
        playerPermissions[player] = permjson
		playerDutyTimer[player] = tonumber(permQuery[1].dutyTime)
		
end

function setAdminCommand(player, cmand, target)
    if not hasAdminPerm(player, "giveRank") then
        return print("Nie ma permisji do ustawiania admina")
    end
    local id = tonumber(target)
    if not id then
        return
    end
    local actualTarget = exports.rp_login:findPlayerByID(id)
	if not actualTarget then return end
    local perms = getAdminPerms(actualTarget)
    triggerClientEvent(player,"onOpenAdminRights",player,actualTarget,perms,getPlayerName(actualTarget),exports.rp_login:getPlayerData(actualTarget, "adminlevel") or 0)
end
addCommandHandler("setadmin", setAdminCommand, false, false)


function flyCommand(player, cmand)
	if not hasAdminPerm(player, "fly") then
		return
	end
	triggerClientEvent(player,"onPlayerToggleFly",player)
end
addCommandHandler("fly", flyCommand, false, false)

function godmodeCommand(player, cmand, state)
	if not hasAdminPerm(player, "fly") then return end
	if not state then return exports.rp_library:createBox(player,"/godmode true/false") end
	if state ~= "true" and state ~= "false" then return exports.rp_library:createBox(player,"/godmode true/false") end
	triggerClientEvent(player,"setGodModeState", player, state)
end
addCommandHandler("godmode", godmodeCommand, false, false)
addCommandHandler("god", godmodeCommand, false, false)

function givePremium(player, timeInDays)
	local timestamp = getRealTime().timestamp + 86400 * timeInDays
	local accountID = exports.rp_login:getPlayerData(player, "characterID")
	exports.rp_db:query("UPDATE users SET premium_timestamp = ? WHERE id = ?", timestamp, accountID)
	exports.rp_login:setPlayerData(player,"premium", true)
end

function premiumCommandHandler(player, cmand, target, days)
	local adminlevel = exports.rp_login:getPlayerData(player,"adminlevel") == 3
	if not adminlevel then return end
	if not days then return exports.rp_library:createBox(player, "/givepremium [id gracza] [dni]") end
	local realTarget = exports.rp_login:findPlayerByID(tonumber(target))
	if not realTarget then return exports.rp_library:createBox(player,"Nieznaleziono gracza.") end
	local daysS = tonumber(days)
	if not daysS or daysS < 1 or daysS >= 366 then return exports.rp_library:createBox(player,"Dni musza byc liczba, 1-365)") end
	givePremium(realTarget, days)
end
addCommandHandler("givepremium", premiumCommandHandler, false, false)

function specCommand(player, cmand, target)
	if not hasAdminPerm(player, "spec") then
		return
	end
	if not target then exports.rp_library:createBox(player,"/spec [id]") triggerClientEvent(player,"onPlayerToggleSpec",player,false) spectatingData[player] = nil  return end
	local realTarget = exports.rp_login:findPlayerByID(tonumber(target))
	if realTarget == player or not realTarget then return exports.rp_library:createBox(player,"Nieznaleziono gracza o podanym ID") end
	local serverPlayers = getElementsByType("player")
	local tmpTable = {}
	for k,v in ipairs(serverPlayers) do
	 if v ~= player then
                local playerID = exports.rp_login:getPlayerData(player, "playerID")
                if playerID then
                    table.insert(tmpTable, v)
                end
            end
	end
 	triggerClientEvent(player,"onPlayerToggleSpec",player, true, realTarget, tmpTable)
	spectatingData[player] = realTarget
end
addCommandHandler("spec", specCommand, false, false)

function adminList(player, cmand)
	local tmpTable = {}
	for k,v in pairs(playerPermissions) do
		local adminlevel = exports.rp_login:getPlayerData(k,"adminlevel")
		local rank = adminRanks[adminlevel][1]
		local playerID = exports.rp_login:getPlayerData(k,"playerID")
		table.insert(tmpTable,{getPlayerName(k),rank,playerID,adminlevel})
	end
	if #tmpTable < 1 then return exports.rp_library:createBox(player,"Nie ma administracji na duty.") end
	triggerClientEvent(player,"onPlayerShowAdmins",player,tmpTable)
end
addCommandHandler("admins", adminList, false, false)
addCommandHandler("a", adminList, false, false)

function onPlayerGotAdmin(target, perms, adminlevel)
    if not hasAdminPerm(client, "giveRank") then
        return exports.rp_anticheat:banPlayerAC(client, "Manipulate Event", "onPlayerGotAdmin/Give")
    end
    
    local adminlevel = tonumber(adminlevel)
    setAdminPerms(target, perms)

    exports.rp_login:setPlayerData(target, "adminlevel", adminlevel)
	local _, accountID = exports.rp_login:isLoggedPlayer(target)
	exports.rp_db:query("UPDATE users SET adminlevel = ? WHERE id = ?", adminlevel, accountID)
    exports.rp_library:createBox(client, "Nadałeś uprawnienia graczowi " .. getPlayerName(target) .. " adminlevel: " .. adminlevel)
end

addEvent("onPlayerGotAdmin", true)
addEventHandler("onPlayerGotAdmin", root, onPlayerGotAdmin)


function onClientChangeSpecPlayer(target)
	if not hasAdminPerm(client, "spec") then
        return exports.rp_anticheat:banPlayerAC(client, "Manipulate Event", "onClientChangeSpecPlayer")
    end
	local dimension, interior = getElementDimension(target), getElementInterior(target)
	setElementDimension(client, dimension)
	setElementInterior(client, interior)
	spectatingData[client] = target

end
addEvent("onClientChangeSpecPlayer", true)
addEventHandler("onClientChangeSpecPlayer", getRootElement(), onClientChangeSpecPlayer)

function onClientPlayerStopSpectating(data)
	if not hasAdminPerm(client, "spec") then
        return exports.rp_anticheat:banPlayerAC(client, "Manipulate Event", "onClientChangeSpecPlayer")
    end
	if not data.dimension then return end
	
	setElementDimension(client, data.dimension)
	setElementInterior(client, data.interior)
	setElementPosition(client, data.x, data.y, data.z)
	setElementFrozen(client, false)
	spectatingData[client] = nil

end
addEvent("onClientPlayerStopSpectating", true)
addEventHandler("onClientPlayerStopSpectating", getRootElement(), onClientPlayerStopSpectating)

function onClientUpdatePlayerRefreshSpecList()
	if not hasAdminPerm(client, "spec") then
        return exports.rp_anticheat:banPlayerAC(client, "Manipulate Event", "onClientRefreshSpecList")
    end
    local newList = {}
    for _, player in ipairs(getElementsByType("player")) do
        if player ~= client then
            local playerID = exports.rp_login:getPlayerData(player, "playerID")
            if playerID then
                table.insert(newList, player)
            end
        end
    end
	triggerClientEvent(client,"onPlayerGotSpecListData",client, newList)
    return newList

end
addEvent("onClientRefreshSpecList", true)
addEventHandler("onClientRefreshSpecList", getRootElement(), onClientUpdatePlayerRefreshSpecList)

addEventHandler("onPlayerQuit", root, -- zrobienie przy restarcie print ile kto mial na duty.
	function(quitType)
	local _, accountID = exports.rp_login:isLoggedPlayer(source)
	if accountID and playerPermissions[source] then
		exports.rp_db:query("UPDATE admins set dutyTime = ? WHERE id = ?",playerDutyTimer[source], accountID)
		if playerAdminTimers[source] and isTimer(playerAdminTimers[source]) then killTimer(playerAdminTimers[source]) end
		if playerDutyTimer[source] then playerDutyTimer[source] = nil end
	end
	if playerPermissions[source] then playerPermissions[source] = nil end
	if spectatingData[source] then spectatingData[source] = nil end
	end
)


-- komendy admina
local timeTable = {
["d"] = 86400,
["m"] = 60,
["h"] = 3600,
}


function DoesPlayerHasLowerAdminLevel(player, target)
	local playerlevel = exports.rp_login:getPlayerData(player,"adminlevel") or 0
	local targetlevel = exports.rp_login:getPlayerData(target,"adminlevel") or 0
	if tonumber(playerlevel) <= tonumber(targetlevel) then return true else return false end
end

function banCommand(player, cmand, target, timetype, time, ...) --/ban id czastyp, czas, powod
    if not hasAdminPerm(player, "ban") then
        return
    end
    local id = tonumber(target)
    if not id then
        return exports.rp_library:createBox(player,"/ban [id] [typczasu] [czas] [powod]")
    end
    if not (...) then
        return exports.rp_library:createBox(player,"/ban [id] [typczasu] [czas] [powod]")
    end
    local actualTarget = exports.rp_login:findPlayerByID(id)
    if not actualTarget then
        return exports.rp_library:createBox(player,"Nie znaleziono gracza o podanym ID.")
    end
	if DoesPlayerHasLowerAdminLevel(player, actualTarget) then return -- czy gracz banujacy ma mniejszy lub rowny lvl, jezeli tak to return
		exports.rp_library:createBox(player,"Nie możesz zbanować tego gracza.") --webhook 
	end
	local reason = table.concat({...}, " ")
    local time = tonumber(time)
    local timetype = tostring(timetype)
	if not tonumber(time) then return end
    if timetype == "d" or timetype == "h" or timetype == "m" then
	local _, accountID = exports.rp_login:isLoggedPlayer(actualTarget)
	if not accountID then return exports.rp_library:createBox(player,"Gracz nie jest zalogowany") end
        local convertTime = timeTable[timetype]
		local timestamp = getRealTime().timestamp + convertTime * time
        exports.rp_db:query("UPDATE users set ban_reason = ?, ban_timestamp = ? WHERE id = ?",reason,timestamp,accountID)
		renderPenalty(exports.rp_utils:getPlayerICName(actualTarget).." ("..getPlayerName(actualTarget)..")", exports.rp_utils:getPlayerICName(player).." ("..getPlayerName(player)..")", reason, 3, time..timetype)
		kickPlayer(actualTarget, "Zostałeś zbanowany przez "..getPlayerName(player).." z powodem: "..reason)

		--webhook ban
    end
end
addCommandHandler("ban", banCommand, false, false)

function unbanCommand(player, cmand, target)
    if not hasAdminPerm(player, "ban") then
        return
    end
    local actualTarget = target
    if not actualTarget then
        return exports.rp_library:createBox(player, "/unban nick")
    end
    local query =
        exports.rp_db:query("UPDATE users set ban_reason = ?, ban_timestamp = ? WHERE username = ?", 0, 0, actualTarget)
    if query then
        exports.rp_library:createBox(player, "Jeżeli takie konto posiadało bana, zostało odbanowane.")
    else
        print("blad")
    end
end

addCommandHandler("unban", unbanCommand, false, false)
function blacklistCommand(player, cmand, target, ...)
    if not hasAdminPerm(player, "ban") then
        return
    end
    local id = tonumber(target)
    if not id then
        return exports.rp_library:createBox(player,"/blacklist [id] [powod]")
    end
    if not (...) then
        return exports.rp_library:createBox(player,"/blacklist [id] [powod]")
    end
    local actualTarget = exports.rp_login:findPlayerByID(id)
    if not actualTarget then
        return exports.rp_library:createBox(player,"Nie znaleziono gracza o podanym ID.")
    end
	if DoesPlayerHasLowerAdminLevel(player, actualTarget) then return -- czy gracz banujacy ma mniejszy lub rowny lvl, jezeli tak to return
		exports.rp_library:createBox(player,"Nie możesz zblacklistowac tego gracza.") --webhook 
	end
	local reason = table.concat({...}, " ")
	local _, accountID = exports.rp_login:isLoggedPlayer(actualTarget)
	if not accountID then return exports.rp_library:createBox(player,"Gracz nie jest zalogowany") end
		local timestamp = getRealTime().timestamp + 86400 * 999
        exports.rp_db:query("UPDATE users set ban_reason = ?, ban_timestamp = ? WHERE id = ?",reason,timestamp,accountID)
		cryptBan(actualTarget, getPlayerSerial(actualTarget), getPlayerIP(actualTarget), accountID, reason)
			setTimer ( function()
			--kickPlayer(actualTarget, "Zostałeś zbanowany przez "..getPlayerName(player).." z powodem: "..reason)
			banPlayer(actualTarget, true, false, true, player, reason)
			end, 1000, 1 )
		--webhook ban
    end
addCommandHandler("blacklist", blacklistCommand, false, false)

-- delblacklist

function kickCommand(player, cmand, target, ...)
if not hasAdminPerm(player,"kick") then return end
 local id = tonumber(target)
    if not id then
        return exports.rp_library:createBox(player,"/kick [id] [powod]")
    end
    if not (...) then
        return exports.rp_library:createBox(player,"/kick [id] [powod]")
    end
    local actualTarget = exports.rp_login:findPlayerByID(id)
    if not actualTarget then
        return exports.rp_library:createBox(player,"Nie znaleziono gracza o podanym ID.")
    end
	if DoesPlayerHasLowerAdminLevel(player, actualTarget) then return -- czy gracz banujacy ma mniejszy lub rowny lvl, jezeli tak to return
		exports.rp_library:createBox(player,"Nie możesz wyrzucić tego gracza.") --webhook 
	end
	local reason = table.concat({...}, " ")
	renderPenalty(exports.rp_utils:getPlayerICName(actualTarget).." ("..getPlayerName(actualTarget)..")", exports.rp_utils:getPlayerICName(player).." ("..getPlayerName(player)..")", reason, 2, 0)
	kickPlayer(actualTarget, "Zostałeś wyrzucony z serwera przez "..getPlayerName(player).." z powodem: "..reason)

	--webhook
end
addCommandHandler("kick", kickCommand, false, false)

function reportCommand(player, cmand, ...)
	local arg = {...}
	if arg[1] == "usun" then
	local report = PlayerHasReport(player)
	if report then
		deleteReport(report)
		exports.rp_library:createBox(player, "Pomyślnie usunięto twój raport.")
	end
		else
		triggerClientEvent(player, "onPlayerShowReportGui", player)
	end
end
addCommandHandler("report", reportCommand, false, false)

function adminReportCommand(player)
	if not playerPermissions[player] then return end
	if #reportsData < 1 then return exports.rp_library:createBox(player,"Nie ma aktualnie raportów.") end
	triggerClientEvent(player, "onPlayerShowReportAdminGui", player, reportsData)
end
addCommandHandler("areports", adminReportCommand, false, false)
addCommandHandler("reports", adminReportCommand, false, false)


function tpCommand(player, cmand, target)
    if not hasAdminPerm(player, "tpToPlayer") then
        return
    end
    local id = tonumber(target)
    if not id then
        return exports.rp_library:createBox(player, "/tp [id]")
    end

    local actualTarget = exports.rp_login:findPlayerByID(id)
    if not actualTarget then
        return exports.rp_library:createBox(player, "Nie znaleziono gracza o podanym ID.")
    end
    local x, y, z = getElementPosition(actualTarget)
    local dim, int = getElementDimension(actualTarget), getElementInterior(actualTarget)
    setElementPosition(player, x + 1, y + 1, z + 1)
    setElementDimension(player, dim)
    setElementInterior(player, int)
	--webhook
end
addCommandHandler("tp", tpCommand, false, false)


function bringCommand(player, cmand, target)
    if not hasAdminPerm(player, "tpToPlayer") then
        return
    end
    local id = tonumber(target)
    if not id then
        return exports.rp_library:createBox(player, "/bring [id]")
    end

    local actualTarget = exports.rp_login:findPlayerByID(id)
    if not actualTarget then
        return exports.rp_library:createBox(player, "Nie znaleziono gracza o podanym ID.")
    end
    local x, y, z = getElementPosition(player)
    local dim, int = getElementDimension(player), getElementInterior(player)
    setElementPosition(actualTarget, x + 1, y + 1, z + 1)
    setElementDimension(actualTarget, dim)
    setElementInterior(actualTarget, int)
	--webhook
end
addCommandHandler("bring", bringCommand, false, false)

function ninjaCommand(player, cmand)
	if not hasAdminPerm(player, "ninja") then return end
	if getElementAlpha(player) == 255 then setElementAlpha(player, 0) else setElementAlpha(player, 255) end
end
addCommandHandler("ninja", ninjaCommand, false, false)

function blockCharCommand(player, cmand, target, ...)
    if not hasAdminPerm(player, "charBlock") then
        return
    end
    local id = tonumber(target)
    if not id then
        return exports.rp_library:createBox(player, "/block [id] [powod]")
    end

    local actualTarget = exports.rp_login:findPlayerByID(id)
    if not actualTarget then
        return exports.rp_library:createBox(player, "Nie znaleziono gracza o podanym ID.")
    end
	if not (...) then return exports.rp_library:createBox(player,"/block [id] [powod]") end
	local reason = table.concat({...}, " ")
    exports.rp_db:query("UPDATE characters set ck = ? WHERE id = ?",1, exports.rp_login:getPlayerData(actualTarget,"characterID"))
	renderPenalty(exports.rp_utils:getPlayerICName(actualTarget).." ("..getPlayerName(actualTarget)..")", exports.rp_utils:getPlayerICName(player).." ("..getPlayerName(player)..")", reason, 4, 0)
    kickPlayer(actualTarget,player,"Twoja postać została zablokowana przez: "..getPlayerName(player).." z powodem: "..reason)

end
addCommandHandler("block", blockCharCommand, false, false)

function getPositionCommand(player, cmand)
    if not hasAdminPerm(player, "bw") then
        return
    end
	local x,y,z = getElementPosition(player)
	outputChatBox("Twoja pozycja: {"..x..","..y..","..z.."}", player)
end
addCommandHandler("getpos", getPositionCommand, false, false)

function setPositionCommand(player, cmand, x,y,z)
    if not hasAdminPerm(player, "bw") then
        return
    end
	if not z then return exports.rp_library:createBox(player,"/setpos [x] [y] [z]") end
	setElementPosition(player, x, y, z)
end
addCommandHandler("setpos", setPositionCommand, false, false)

function adminChat(player, cmand, ...)
    if not playerPermissions[player] then
        return
    end
    if not (...) then
        return exports.rp_library:createBox(player, "/" .. cmand .. " [wiadomość]")
    end
    local text = table.concat({...}, " ")
    if string.len(text) < 1 then
        return
    end
    local rank, r, g, b = getColorAndRank(player)
    local playerID = exports.rp_login:getPlayerData(player, "playerID")
    local fullText =
        "[" .. playerID .. "] " .. "[" .. rank .. "] " .. exports.rp_utils:getPlayerICName(player) .. ": " .. text
    for k, v in pairs(playerPermissions) do
        exports.rp_chat:sendChatOOC(k, fullText, r, g, b)
    end
end

addCommandHandler("adminchat", adminChat, false, false)
addCommandHandler("ac", adminChat, false, false)

function PlayerHasReport(player)
    local characterID = exports.rp_login:getPlayerData(player, "characterID")
    for k, v in pairs(reportsData) do
        if v.from == characterID then
            return k
        end
    end
    return false
end

function isReportActive(id)
    for k, v in pairs(reportsData) do
        if v.id == id then
            return k
        end
    end
    return false
end


function deleteReport(index)
	table.remove(reportsData, index)
end

function onGotReportFromPlayer(reportText, category, targetID)
    if string.len(reportText) <= 5 or string.len(reportText) > 61 then
        return
    end
    if PlayerHasReport(client) then
        return exports.rp_library:createBox(client,"Masz już wysłany raport, możesz go zakończyć pod komendą /report usun")
    end
	local realTarget = false
    if category == "Zgłoszenie gracza" then
        realTarget = exports.rp_login:findPlayerByID(targetID)
        if not realTarget then
            return exports.rp_library:createBox(client, "Nie znaleziono gracza o podanym ID.")
        end
    end
    local id = #reportsData + 1
    local characterID = exports.rp_login:getPlayerData(client, "characterID")
    table.insert(
        reportsData,
        {
            id = id,
            reportText = reportText,
            category = category,
            from = characterID,
            reportTitle = {exports.rp_utils:getPlayerICName(client), exports.rp_login:getPlayerData(client,"playerID")},
			targetPlayer = {exports.rp_utils:getPlayerICName(realTarget) or false, exports.rp_login:getPlayerData(realTarget,"playerID") or false}
        }
    )

    exports.rp_library:createBox(client, "Pomyślnie wysłano twój report.")
    for k, v in pairs(playerPermissions) do
        exports.rp_chat:sendChatOOC(k, "Wpłynął raport, sprawdź go pod /reports.", 255, 0, 0)
    end
end
addEvent("onPlayerSubmitReport", true)
addEventHandler("onPlayerSubmitReport", root, onGotReportFromPlayer)


function onAdminAcceptedReport(data)
    if not playerPermissions[client] then
        return
    end
    local isReportAvailable = isReportActive(data.id)
    if not isReportAvailable then
        return exports.rp_library:createBox(client, "Ten report jest już przez kogoś odebrany.")
    end
    outputChatBox("Zaakceptowałeś reporta z treścią: " .. data.reportText .. " [" .. data.category .. "]", client, 255, 0, 0)
	local from = exports.rp_utils:getPlayerFromCharID(data.from)
    if isElement(from) then
        outputChatBox("Twój report został zaakceptowany przez " .. getPlayerName(client), from, 255, 0, 0)
    end
    exports.rp_library:createBox(client, "Zaakceptowałeś reporta.")
	deleteReport(isReportAvailable)
end
addEvent("onPlayerAcceptReport", true)
addEventHandler("onPlayerAcceptReport", root, onAdminAcceptedReport)

function onAdminDeclineReport(data)
    if not playerPermissions[client] then
        return
    end
    local isReportAvailable = isReportActive(data.id)
    if not isReportAvailable then
        return exports.rp_library:createBox(client, "Ten report jest już przez kogoś odebrany.")
    end
	local from = exports.rp_utils:getPlayerFromCharID(data.from)
    if isElement(from) then
        outputChatBox("Twój report został odrzucony przez " .. getPlayerName(client), from, 255, 0, 0)
    end
    exports.rp_library:createBox(client, "Odrzuciłeś reporta.")
	deleteReport(isReportAvailable)

end
addEvent("onPlayerDeclineReport", true)
addEventHandler("onPlayerDeclineReport", root, onAdminDeclineReport)



local availableFightStyles = {
[4] = true,
[5] = true,
[6] = true,
[7] = true,
[15] = true,
[16] = true,

}


function setCommand(player, cmand, ...)
    local arg = {...}
    if arg[1] == "hp" then -- set hp target hp
        if not hasAdminPerm(player, "bw") then
            return
        end
        local target = tonumber(arg[2])
        local hp = tonumber(arg[3])
        if not hp then
            return exports.rp_library:createBox(player, "/set hp [target] [hp]")
        end
        if hp > 200 or hp < 1 then
            return exports.rp_library:createBox(player, "Przedział HP wynosi 1-200.")
        end
        local actualTarget = exports.rp_login:findPlayerByID(target)
        if not actualTarget then
            return exports.rp_library:createBox(player, "Nie znaleziono gracza o podanym ID.")
        end
        setElementHealth(actualTarget, hp)
        exports.rp_library:createBox(actualTarget, getPlayerName(player) .. " ustawił Ci " .. hp .." HP")
        if hp > 20 then
            exports.rp_nicknames:setPlayerStatus(actualTarget, "zraniony", false)
        else
            exports.rp_nicknames:setPlayerStatus(actualTarget, "zraniony", true)
        end
    elseif arg[1] == "cash" then
        if not hasAdminPerm(player, "cash") then
            return
        end

        local target = tonumber(arg[2])
        local cash = tonumber(arg[3])
        if not cash then
            return exports.rp_library:createBox(player, "/set cash [target] [kasa]")
        end
        if cash < 1 or cash > 10000 then
            return exports.rp_library:createBox(player, "Przedział kasy wynosi 1-10000.")
        end
        local actualTarget = exports.rp_login:findPlayerByID(target)
        if not actualTarget then
            return exports.rp_library:createBox(player, "Nie znaleziono gracza o podanym ID.")
        end
        exports.rp_login:setPlayerData(actualTarget, "money", cash)
		-- exports.rp_login:changeCharData(actualTarget, "money", cash)
		--webhook
	elseif arg[1] == "skin" then
		if not hasAdminPerm(player,"cash") then return end
		local target = tonumber(arg[2])
		local id = tonumber(arg[3])
		if not id then return exports.rp_library:createBox(player,"/set skin [id gracza] [id skina]") end
		local actualTarget = exports.rp_login:findPlayerByID(target)
		if not actualTarget then
            return exports.rp_library:createBox(player, "Nie znaleziono gracza o podanym ID.")
        end
		local setModel = exports.rp_newmodels:setElementModel(actualTarget, id)
		if not setModel then return exports.rp_library:createBox(player,"Złe ID Skina.") end
		exports.rp_login:changeCharData(actualTarget, "skin", id)
    elseif arg[1] == "fight" then
        if not hasAdminPerm(player, "fightstyles") then
            return
        end
        local target = tonumber(arg[2])
        local fs = tonumber(arg[3])
		if not target then return exports.rp_library:createBox(player,"/set fight [id gracza] [styl walki]") end
        local available = availableFightStyles[fs]
        if not available then
            return exports.rp_library:createBox(player,"Nie ma takiego stylu, style: 4(standard), 5(box), 6(kung fu), 7(knee head), 15(grab kick), 16(elbows)")
        end
        local actualTarget = exports.rp_login:findPlayerByID(target)
        if not actualTarget then
            return exports.rp_library:createBox(player, "Nie znaleziono gracza o podanym ID.")
        end
        local fightStylesTable = exports.rp_login:getCharDataFromTable(actualTarget, "fightstyles")
        local removed = false
        for k, v in pairs(fightStylesTable) do
            if v == fs then
                table.remove(fightStylesTable, k)
                removed = true
                break
            end
        end
        if not removed then
            table.insert(fightStylesTable, fs)
			exports.rp_library:createBox(player,"Nadałeś graczowi styl walki: "..fs)
			else
			exports.rp_library:createBox(player,"Usunąłeś graczowi styl walki: "..fs)
        end
		-- iprint(fightStylesTable)
        exports.rp_login:changeCharData(actualTarget, "fightstyles", fightStylesTable)
    elseif arg[1] == "nick" then -- tylko zmieniany nick jest do exita.
        if not hasAdminPerm(player, "displayName") then
            return
        end
        local target = tonumber(arg[2])
        local name, surname = arg[3], arg[4]
        if not name or not surname then
            return exports.rp_library:createBox(player, "/set nick [target] [imie] [nazwisko]")
        end
        local actualTarget = exports.rp_login:findPlayerByID(target)
        if not actualTarget then
            return exports.rp_library:createBox(player, "Nie znaleziono gracza o podanym ID.")
        end
        exports.rp_login:setPlayerData(actualTarget, "name", name, true)
        exports.rp_login:setPlayerData(actualTarget, "surname", surname, true)
		exports.rp_library:createBox(player,"Zmieniono graczowi dane.")
		exports.rp_login:setPlayerData(actualTarget, "visibleName", name.." "..surname)
    end
end
addCommandHandler("set", setCommand, false, false)


function uncryptBan(banHash)
	local decoded = decodeString("rsa", banHash, { key = private })
	return decoded
end

function cryptBan(player, serial, ip, accountID, reason)
	local txt = serial..":"..ip..":"..accountID..":"..reason
	local encoded = encodeString("rsa", txt, {key = public})
	triggerClientEvent(player,"createBanFile", player, encoded)
	return encoded
end


function adminGraffitiCommand(player, cmand)
    if not playerPermissions[player] then
        return
    end
	triggerClientEvent(player,"onAdminOpenGraffitiEditor", player)
end
addCommandHandler("gadmin", adminGraffitiCommand, false, false)
function resetPassword(player, cmand, target, password)
    if not hasAdminPerm(player, "resetpassword") then
        return
    end
	if not password then return exports.rp_library:createBox(player, "/resetpassword [nick] [haslo]") end
	if string.len(password) < 6 then return exports.rp_library:createBox(player, "Hasło jest za krótkie, wymagane jest minimum 6 znaków") end
	local hashedPassword = passwordHash(password, "bcrypt", {})
	if not hashedPassword then return end
    local query = exports.rp_db:query("UPDATE users set password = ? WHERE username = ?", hashedPassword, target)
    if query then
        exports.rp_library:createBox(player, "Jeżeli takie konto istnieje to hasło zostało zmienione.")
    end
end
addCommandHandler("resetpassword", resetPassword, false, false)


function renderPenalty(player, whoAdded, reason, penaltyType, time)
	local loggedPlayers = exports.rp_login:getLoggedPlayers()
	for k,v in pairs(loggedPlayers) do
		triggerClientEvent(k,"addPenalty",k, player, whoAdded, reason, penaltyType, time)
	end
end


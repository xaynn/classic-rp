local panicBlips = {}
local panicPlayers = {}
local panicTimers = {}
local roadblocks = {}
local reports911 = {}
local spikes = createElement("spikesElements")
local blipTimers911 = {}
local mdtData = {}
local pdVehicles = { [598]=true, [596]=true, [597]=true, [599]=true, [416] = true }
local visibleBlipsForPD = {}
local visibleBlipsForLSSD = {}

function loadMDTData()
	local result = exports.rp_db:query("SELECT * FROM mdt")
	for k,v in ipairs(result) do
		local wantedboolean = v.wanted
		if wantedboolean == "1" then wantedboolean = true else wantedboolean = false end
		local type = v.type
		mdtData[v.fullName] = {fullName = v.fullName, wanted = wantedboolean, logs = fromJSON(v.logs) or {}, type = type}
	end
end
loadMDTData()
function createPanicBlip(player, players)
	panicPlayers[player] = true
	
	local x,y,z = getElementPosition(player)
	local blip = createBlip(x,y,z,0,2,255,255,255,255,0,9999,player)
	panicTimers[blip] = setTimer(destroyCooldown, 60000, 1, blip, player)
	local zoneName = getZoneName(x,y,z)
	panicBlips[blip] = blip
	for k,v in pairs(players) do
		setElementVisibleTo(blip, k, true)
	end
		for k,v in pairs(players) do
		outputChatBox(exports.rp_utils:getPlayerICName(player).." wywołał panic button, lokalizacja: "..zoneName, k, 255, 0, 0, true)

	end
end

function destroyCooldown(blip, player)
    if panicTimers[blip] then
        killTimer(panicTimers[blip])
        panicTimers[blip] = nil
		if isElement(player) then
			panicPlayers[player] = nil
		end
        destroyElement(panicBlips[blip])
    end
end

function cuffCommand(player, cmand, target)
    if not hasPerm(player, "cuffPlayer") then
        return
    end
    local target = tonumber(target)
    if not target then
        return exports.rp_library:createBox(player, "/" .. cmand .. " [id]")
    end
    local realTarget = exports.rp_login:findPlayerByID(target)
    if not realTarget or realTarget == player then
        return exports.rp_library:createBox(player, "Nie znaleziono gracza.")
    end
    local distance = exports.rp_utils:getDistanceBetweenElements(player, realTarget)
    if distance > 5 then
        return exports.rp_library:createBox(player, "Gracz jest za daleko aby go skuć.")
    end
    -- exports.pAttach:attach(realTarget, player, "pelvis", 0.1, 0.5, 0, 0, 90, 0)
	attachElements ( realTarget, player, 0, 1, 0)
    exports.rp_login:setPlayerData(realTarget, "cuffed", player, true)
    exports.rp_login:setPlayerData(player, "cuffed", realTarget, true)
end
addCommandHandler("skuj", cuffCommand, false, false)
addCommandHandler("zakuj", cuffCommand, false, false)

function ticketCommand(player, cmand, target, amount)
    if not hasPerm(player, "cuffPlayer") then
        return
    end

	 if not target then
        return exports.rp_library:createBox(player, "/" .. cmand .. " [id] [kwota]")
    end
	local amount = tonumber(amount)
	if not amount or amount > 5000 or amount < 10 then return exports.rp_library:createBox(player,"Zakres ceny mandatu to 10-5000.") end
    local realTarget = exports.rp_login:findPlayerByID(target)
    if not realTarget or realTarget == player then
        return exports.rp_library:createBox(player, "Nie znaleziono gracza.")
    end
    local distance = exports.rp_utils:getDistanceBetweenElements(player, realTarget)
    if distance > 5 then
        return exports.rp_library:createBox(player, "Gracz jest za daleko aby wystawić mu ticket.")
    end
	-- send offer with amount
	exports.rp_offers:sendOffer(player, realTarget, 2, 0, amount, "Ticket") --(player, target, typeService, itemID, payment, name)

end
addCommandHandler("mandat", ticketCommand, false, false)

function healPlayer(player, cmand, target)
    if not hasPerm(player, "cuffPlayer") then
        return
    end
	 if not target then
        return exports.rp_library:createBox(player, "/" .. cmand .. " [id]")
    end
    local realTarget = exports.rp_login:findPlayerByID(target)
    if not realTarget then
        return exports.rp_library:createBox(player, "Nie znaleziono gracza.")
    end
    local distance = exports.rp_utils:getDistanceBetweenElements(player, realTarget)
    if distance > 5 then
        return exports.rp_library:createBox(player, "Gracz jest za daleko aby go uleczyć.")
    end
	
	exports.rp_offers:sendOffer(player, realTarget, 9, 0, 50, "Leczenie") --(player, target, typeService, itemID, payment, name)
	
	-- send heal offer
end
addCommandHandler("ulecz", healPlayer, false, false)
function uncuffCommand(player, cmand)
    if not hasPerm(player, "cuffPlayer") then
        return
    end
    local cuffedPlayer = exports.rp_login:getPlayerData(player, "cuffed")
    if not cuffedPlayer then
        return
    end
    if isElement(cuffedPlayer) then
		detachElements(cuffedPlayer)
        exports.rp_login:setPlayerData(cuffedPlayer, "cuffed", false, true)
        exports.rp_login:setPlayerData(player, "cuffed", false, true)
    end
end
addCommandHandler("odkuj", uncuffCommand, false, false)

addEventHandler(
    "onPlayerQuit",
    root,
    function(quitType)
		if panicPlayers[source] then panicPlayers[source] = nil end
        local cuffed = exports.rp_login:getPlayerData(source, "cuffed")
        if cuffed then
            local targetCuffed = exports.rp_login:getPlayerData(cuffed, "cuffed")
			detachElements(targetCuffed)
			detachElements(cuffed)
        end
    end
)

function blockWheelVehicle(player)
    if not hasPerm(player, "blockVehicleWheel") then
        return
    end
    local veh = exports.rp_utils:getNearestElement(player, "vehicle", 5) 
    if not veh then
        return exports.rp_library:createBox(player, "Aby zablokować pojazd, musisz być obok niego.")
    end
    local data = exports.rp_vehicles:getVehicleCurrentData(veh, "blockedWheel")
    if data then
        return exports.rp_library:createBox(player, "Ten pojazd ma już zablokowane koło.")
    end
    exports.rp_vehicles:changeVehicleCurrentStatistics(veh, "blockedWheel", true)
    exports.rp_library:createBox(player, "Zablokowałeś pojazdowi koło.")
	local vehicleID = exports.rp_vehicles:getVehicleUID(veh)
	exports.rp_vehicles:spawnVehicle(vehicleID)
end

function unblockWheelVehicle(player)
    if not hasPerm(player, "blockVehicleWheel") then
        return
    end
    local veh = exports.rp_utils:getNearestElement(player, "vehicle", 5) 
    if not veh then
        return exports.rp_library:createBox(player, "Aby zablokować pojazd, musisz być obok niego.")
    end
    local data = exports.rp_vehicles:getVehicleCurrentData(veh, "blockedWheel")
    if not data then
        return exports.rp_library:createBox(player, "Ten pojazd nie ma zablokowanego koła.")
    end
    exports.rp_vehicles:changeVehicleCurrentStatistics(veh, "blockedWheel", false)
    exports.rp_library:createBox(player, "Odblokowałeś pojazdowi koło.")
end


function useFakePapersCommand(player, cmand, ...)
    if not hasPerm(player, "usepapiren") then
        return
    end

    local args = {...} 
    local action = args[1] 

    if action == "nadaj" then
        local name, surname = args[2], args[3]
        if not name or not surname then
            return exports.rp_library:createBox(player, "/papiery nadaj [imie] [nazwisko].")
        end

        if string.len(name) > 15 or string.len(surname) > 15 then
            return exports.rp_library:createBox(player, "Imię i nazwisko mogą mieć tylko po 15 znaków.")
        end

        exports.rp_login:setPlayerData(player, "fakeName", {name, surname}, true)
        exports.rp_library:createBox(player, "Nadałeś sobie papiery.")
    elseif action == "uzyj" then
        local usedPapers = exports.rp_login:getPlayerData(player, "usedPapers")
        if usedPapers then
            exports.rp_login:setPlayerData(player, "usedPapers", false, true)
			exports.rp_login:setPlayerData(player,"visibleName",exports.rp_utils:getPlayerRealName(player))
        else
            local fakeName = exports.rp_login:getPlayerData(player, "fakeName")
            if not fakeName then
                return exports.rp_library:createBox(player, "Użyj najpierw /papiery nadaj [imie] [nazwisko].")
            end

            exports.rp_login:setPlayerData(player, "visibleName", fakeName[1] .. " " .. fakeName[2])
            exports.rp_login:setPlayerData(player, "usedPapers", true, true)
            exports.rp_library:createBox(player, "Użyłeś papierów.")
        end
    else
        exports.rp_library:createBox(player, "Nieprawidłowe użycie komendy. Spróbuj: /papiery nadaj [imie] [nazwisko] lub /papiery uzyj.")
    end
end

addCommandHandler("papiery", useFakePapersCommand, false, false)



function mdtCommand(player)
	if not hasPerm(player, "mdt") then return end
	local veh = getPedOccupiedVehicle(player)
	if not veh then return end
	if pdVehicles[getElementModel(veh)] or exports.rp_login:getObjectData(veh,"customPD") then
	triggerClientEvent(player,"onPlayerOpenMDT",player, mdtData)
	end
end
addCommandHandler("mdt", mdtCommand, false, false)

function onPlayerRemoveWanted(fullName, vehicle)
    if not hasPerm(client, "mdt") then
        return
    end
    if not mdtData[fullName] then
        return
    end
    if vehicle then
        if mdtData[fullName].type ~= "vehicle" then
            return
        end
        exports.rp_library:createBox(client, "Usunąłeś pojazd z poszukiwanych.")
        exports.rp_db:query("DELETE FROM mdt WHERE fullName = ?", fullName)
        mdtData[fullName] = nil
    else
        mdtData[fullName].wanted = false
        exports.rp_db:query("UPDATE mdt set wanted = ? WHERE fullName = ?", false, fullName)
        exports.rp_library:createBox(client, "Usunąłeś gracza z poszukiwanych.")
    end
end

addEvent("onPlayerTryRemoveWantedPlayer", true)
addEventHandler("onPlayerTryRemoveWantedPlayer", getRootElement(), onPlayerRemoveWanted)
function onPlayerSendWanted(firstEdit, secondEdit, thirdEdit, fourthEdit)
    if not hasPerm(client, "mdt") then return end
	local formattedTime = exports.rp_utils:formatDate("d.m.Y h:i:s")

    if thirdEdit and not fourthEdit then -- Zgłoszenie pojazdu
		if string.len(firstEdit) > 40 or string.len(secondEdit) > 40 or string.len(thirdEdit) > 40 then return end
        mdtData[firstEdit] = {
            fullName = secondEdit,
            logs = {thirdEdit.." [ "..formattedTime.." ]"},
			wanted = true,
			type = "vehicle",
        }
	        exports.rp_library:createBox(client, "Wystawiłeś poszukiwanie dla pojazdu.")

		exports.rp_db:query("INSERT INTO mdt (fullName, wanted, logs, type) VALUES (?, ?, ?, ?)", secondEdit, true, toJSON({thirdEdit}), "vehicle")
    else -- Zgłoszenie gracza
		if string.len(firstEdit) > 40 or string.len(secondEdit) > 60 then return end
		if fourthEdit then return insertPlayerLog(firstEdit, secondEdit) end
        if not mdtData[firstEdit] then
            mdtData[firstEdit] = {
                fullName = firstEdit,
                wanted = true,
                logs = {secondEdit.." [ "..formattedTime.." ]"},
				type = "player",
            }
        else
            table.insert(mdtData[firstEdit].logs, secondEdit.." [ "..formattedTime.." ]")
        end
        exports.rp_library:createBox(client, "Wystawiłeś poszukiwanie dla osoby.")

        -- Zapis gracza do bazy danych
        exports.rp_db:query(
            "INSERT INTO mdt (fullName, wanted, logs, type) VALUES (?, ?, ?, ?) ON DUPLICATE KEY UPDATE wanted = ?, logs = ?",
            firstEdit, true, toJSON(mdtData[firstEdit].logs), "player", true, toJSON(mdtData[firstEdit].logs)
        )
    end
end
addEvent("onPlayerSendWanted", true)
addEventHandler("onPlayerSendWanted", getRootElement(), onPlayerSendWanted)


function insertPlayerLog(fullName, log) -- dodawanie do listy osob, do poszukiwanych musi byc wanted = true
	local formattedTime = exports.rp_utils:formatDate("d.m.Y h:i:s")
    if not mdtData[fullName] then
        mdtData[fullName] = { 
            fullName = fullName,
            wanted = false,
            logs = {log.." [ "..formattedTime.." ]"},
			type = "player",
        }
		exports.rp_db:query("INSERT INTO mdt (fullName, wanted, logs, type) VALUES (?, ?, ?, ?)", fullName, true, toJSON({log}), "player")
    else
        table.insert(mdtData[fullName].logs, log.." [ "..formattedTime.." ]")
		exports.rp_db:query("UPDATE mdt set logs = ? WHERE fullName = ?",toJSON(mdtData[fullName].logs), fullName)
    end
end

function setPlayerWanted(fullName, log)
	local formattedTime = exports.rp_utils:formatDate("d.m.Y h:i:s")
	    if not mdtData[fullName] then
        mdtData[fullName] = { 
            fullName = fullName,
            wanted = true,
            logs = {log.." [ "..formattedTime.." ]"},
			type = "player"
        }
		exports.rp_db:query("INSERT INTO mdt (fullName, wanted, logs, type) VALUES (?, ?, ?, ?)", fullName, true, toJSON({log}), "player")
    else
        table.insert(mdtData[fullName].logs, log.." [ "..formattedTime.." ]")
		exports.rp_db:query("UPDATE mdt set logs = ? WHERE fullName = ?",toJSON(mdtData[fullName].logs), fullName)

    end
end

function command911(player,cmand)
		if not hasPerm(player,"911") then return end
		triggerClientEvent(player,"onPlayerOpen911",player, reports911, true) -- otwieranie okienka dla pd
end
addCommandHandler("911", command911, false, false)

function enable911GUI(player)
	if isElement(player) then
		triggerClientEvent(player,"onPlayerOpen911",player) -- otwieranie okienka dla gracza z telefonu
	end
end

function onPlayerSend911Report(text, anonim, sendTo)
    if #text > 80 or #text < 4 then
        return
    end
	if not sendTo.lsfd and not sendTo.lspd then return print("blad") end
    if not exports.rp_utils:checkPassiveTimer("911report", client, 300) then
        return exports.rp_library:createBox(client, "Poczekaj chwilę przed następnym zgłoszeniem.")
    end

    local characterID = exports.rp_login:getPlayerData(client, "characterID")
    if not characterID or reports911[characterID] then
        return exports.rp_library:createBox(client, "Posiadasz już aktywne zgłoszenie.")
    end

    local playerName = anonim and "Anonim" or exports.rp_utils:getPlayerICName(client)

    if sendTo.lspd then
        local lspdPlayers = getPlayersInGroupType(2)
        for k, v in pairs(lspdPlayers) do
			outputChatBox ( "[DISPATCH] Wpłynęło zgłoszenie /911.", k, 255, 255, 255, true )
        end
    end
    if sendTo.lsfd then
        local lsfdPlayers = getPlayersInGroupType(3)
        for k, v in pairs(lsfdPlayers) do
			outputChatBox("[DISPATCH] Wpłynęło zgłoszenie /911.", k, 255, 0, 0, true)
        end
    end
	local x,y,z = getElementPosition(client)
	local dimension = getElementDimension(client)
    reports911[characterID] = {
        sender = playerName,
        text = text,
        characterID = characterID,
        groups = sendTo,
		x = x,
		y = y,
		z = z,
		playerElement = client,
		dimension = dimension or false
    }
	exports.rp_library:createBox(client,"Pomyślnie wysłałeś zgłoszenie.")
end

addEvent("onPlayerSend911Report", true)
addEventHandler("onPlayerSend911Report", getRootElement(), onPlayerSend911Report)

function send911Report(player, text, sendTo) -- only server side, for notifications, i.e corner notification
	if not sendTo.lsfd and not sendTo.lspd then return print("blad") end


    if sendTo.lspd then
        local lspdPlayers = getPlayersInGroupType(2)
        for k, v in pairs(lspdPlayers) do
			outputChatBox ( "[DISPATCH] Wpłynęło zgłoszenie /911.", k, 255, 255, 255, true )
        end
    end
    if sendTo.lsfd then
        local lsfdPlayers = getPlayersInGroupType(3)
        for k, v in pairs(lsfdPlayers) do
			outputChatBox("[DISPATCH] Wpłynęło zgłoszenie /911.", k, 255, 0, 0, true)
        end
    end
	local x,y,z = getElementPosition(player)
	local dimension = getElementDimension(player)
	local characterID = #reports911 * 8
    reports911[characterID] = {
        sender = "Anonim",
        text = text,
        characterID = characterID,
        groups = sendTo,
		x = x,
		y = y,
		z = z,
		playerElement = player,
		dimension = dimension or false
    }
end

function onPlayerDo911(data, accepted)
    -- exports.rp_utils:getPlayerFromCharID(characterID)
    -- check czy jest w sluzbie porzadkowej
	if not hasPerm(client,"911") then return end
    local data = data
	local characterID = data.characterID
	local isAvailable = reports911[characterID]
	if not isAvailable then return exports.rp_library:createBox(client,"Ktoś zajął się już tym zgłoszeniem.") end
	local playerWhoSend911 = exports.rp_utils:getPlayerFromCharID(tonumber(characterID))
    if accepted then
        if data.dimension ~= 0 then
            outputChatBox("Zgłoszenie które zaakceptowałeś, nie jest na zwykłym świecie, może być np w interiorze i pozycja Blipa może się nie zgadzać.",client,255,255,255,true)
        end
        if isElement(playerWhoSend911) then
            outputChatBox("[911] Twoje zgłoszenie zostało zaakceptowane.", playerWhoSend911, 255, 255, 255, true)
        end
		local blip = createBlip(data.x, data.y, data.z, 0, 2, 255, 0, 0, 255, 0, 9999, client)
        blipTimers911[blip] = setTimer(destroy911Blip, 60000, 1, blip)
		reports911[characterID] = nil
    else
        if isElement(playerWhoSend911) then
            outputChatBox("[911] Twoje zgłoszenie zostało odrzucone.", playerWhoSend911, 255, 255, 255, true)
			reports911[characterID] = nil
        end
    end
end
addEvent("onPlayerDo911", true)
addEventHandler("onPlayerDo911", getRootElement(), onPlayerDo911)


function destroy911Blip(blip)
	if isElement(blip) and blipTimers911[blip] then
		destroyElement(blip)
	end
end


function drugTestCommand(player, cmand, target)
	if not hasPerm(player, "drug") then return end
	local target = tonumber(target)
	if not target then return exports.rp_library:createBox(player,"/drugtest [id]") end
	local realTarget = exports.rp_login:findPlayerByID(target)
	if not realTarget or realTarget == player then return exports.rp_library:createBox(player,"Nieznaleziono gracza.") end
	    local distance = exports.rp_utils:getDistanceBetweenElements(player, realTarget)
    if distance > 5 then
        return exports.rp_library:createBox(player, "Gracz jest za daleko aby wykonać mu drugtest.")
    end
	exports.rp_offers:sendOffer(player, realTarget, 6, 0, 0, "DrugTest") -- ofka

end
addCommandHandler("drugtest", drugTestCommand, false, false)
--local groupTable = {
    -- ["Gastronomia"] = 1,
    -- ["LSPD"] = 2,
    -- ["LSFD"] = 3,
	-- ["Gang"] = 4,
	-- ["LSSD"] = 5
-- }
function panicButton(player)
    local duty = getPlayerGroupDuty(player)
    if not duty then
        return
    end
	if panicPlayers[player] then return exports.rp_library:createBox(player,"Posiadasz cooldown na pb.") end 
    if hasPermInCurrentGroup(player, duty[6], "panicButton") then
        local players = getPlayersInGroupType(duty[7])
		createPanicBlip(player, players)
    else
        exports.rp_library:createBox(player, "Nie posiadasz uprawnień.")
    end
end
addCommandHandler("pb", panicButton, false, false)
addCommandHandler("panicbutton", panicButton, false, false)

function bodyCheckCommand(player)
	if not hasPerm(player, "mdt") then return end
	local getNearbyBody = exports.rp_inventory:getNearbyCorpse(player)
	outputChatBox("Ciało: ", player, 255, 255, 255)
	outputChatBox("Data zgonu: ", player, 255, 255, 255)
	outputChatBox("Smierć spowodowana przez: ", player, 255, 255, 255)

end
addCommandHandler("sprawdzcialo", bodyCheckCommand, false, false)

function isPlayerInJailPosition(player)
    if not isElement(player) or getElementType(player) ~= "player" then return false end

    local px, py, pz = getElementPosition(player)
    local interior = getElementInterior(player)

    local jailX, jailY, jailZ = 267.2783203125, 77.6875, 1001.0390625

    local radius = 5

    if interior == 6 then
        local distance = getDistanceBetweenPoints3D(px, py, pz, jailX, jailY, jailZ)
        if distance <= radius then
            return true
        end
    end

    return false
end

function jailCommand(player, cmand, target, time)
	if not hasPerm(player, "jail") then return end
	local target = tonumber(target)
	if not target then return exports.rp_library:createBox(player,"/jail [id] [czas w godzinach, max 30]") end
	local realTarget = exports.rp_login:findPlayerByID(target)
	if not realTarget or realTarget == player then return exports.rp_library:createBox(player,"Nieznaleziono gracza.") end
	local distance = exports.rp_utils:getDistanceBetweenElements(player, realTarget)
    if distance > 5 then
        return exports.rp_library:createBox(player, "Gracz jest za daleko aby nadać mu jaila.")
    end
	local time = tonumber(time)
	if time == 0 then 
		exports.rp_login:changeCharData(realTarget, "jailtime", 0) exports.rp_library:createBox(realTarget,"Zostałeś wypuszczony z więzienia przez "..exports.rp_utils:getPlayerICName(player)) setElementInterior(realTarget, 0) setElementDimension(realTarget, 0) setElementPosition(realTarget, 1480.1455078125,-1738.6396484375,13.546875)
	return
	end
	if time > 30 or time < 1 then return exports.rp_library:createBox(player,"Czas jaki możesz nadać, to 1-30h.") end
	local isInJail = isPlayerInJailPosition(realTarget)
	if not isInJail then return exports.rp_library:createBox(player,"Gracz musi znajdować się w pomieszczeniu więzienia aby go wsadzić.") end
	local timestamp = getRealTime().timestamp + 3600 * time
	exports.rp_login:changeCharData(realTarget, "jailtime", timestamp)
	local date = exports.rp_utils:getDate(timestamp)
	outputChatBox("Zostałeś umieszczony do więzienia do czasu: "..date.."| "..time.." godzin.", realTarget, 255, 255, 255)
	exports.rp_library:createBox(player,"Gracz został wrzucony do więzienia.")
	setElementPosition(realTarget, 263.7470703125,78.0732421875,1001.0390625)
	setElementInterior(realTarget, 6)
end
addCommandHandler("jail", jailCommand, false, false)

-- blokady drogowe na characterID, max 10

function getPlayerRoadBlocks(characterID)
	if not roadblocks[characterID] then return 0 end
	return #roadblocks[characterID] 
end

function getPlayerRoadBlock(characterID, object)
	if not roadblocks[characterID] then return false end
	for i, v in ipairs(roadblocks[characterID]) do
		if v == object then
			return object, i
		end
	end
	return false
end

function destroyRoadBlock(object)
    for characterID, blocks in pairs(roadblocks) do
        for i, data in ipairs(blocks) do
            if data.object == object then
                if isElement(data.marker) then
                    destroyElement(data.marker) 
                end
                if isElement(data.object) then
                    destroyElement(data.object) 
                end
                table.remove(roadblocks[characterID], i) 
                return
            end
        end
    end
end
local validObjects = {[1459] = true, [1427] = true, [1237] = true, [2899] = true}
function onPlayerCreateRoadBlock(objectID, x, y, z, rotX, rotY, rotZ)
	if not hasPerm(client, "roadblock") then return end
	local vehicle = getPedOccupiedVehicle(client)
	if vehicle then return end
	local pX, pY, pZ = getElementPosition(client)
    local distance = getDistanceBetweenPoints3D(pX, pY, pZ, x, y, z)
	if distance > 5 then 
        return  
    end
    if not validObjects[objectID] then return end
    local characterID = exports.rp_login:getPlayerData(client, "characterID")
    if not roadblocks[characterID] then roadblocks[characterID] = {} end

    local count = getPlayerRoadBlocks(characterID)
    if count >= 10 then 
        return exports.rp_library:createBox(client, "Posiadasz limit blokad drogowych.")
    end

    local obj = createObject(objectID, x, y, z)
	setObjectBreakable(obj, false)
	local marker = false
	if objectID == 2899 then -- kolczatka 
		marker = createMarker(x, y, z, "cylinder", 2, 255, 0, 0, 0)
		setElementParent(marker, spikes)
	end
    table.insert(roadblocks[characterID], {object = obj, marker = marker})
	setElementDimension(obj, getElementDimension(client))
	setElementInterior(obj, getElementInterior(client))
    setElementRotation(obj, rotX, rotY, rotZ)
end
addEvent("onPlayerCreateRoadBlock", true)
addEventHandler("onPlayerCreateRoadBlock", getRootElement(), onPlayerCreateRoadBlock)


function onPlayerRemoveRoadBlock()
	if not hasPerm(client, "roadblock") then return end
	local object = exports.rp_utils:getNearestElement(client,"object", 2)
	-- if nearestObj ~= object then return end
	if isElement(object) then
		destroyRoadBlock(object) 
	end
end
addEvent("onPlayerRemoveRoadBlock", true)
addEventHandler("onPlayerRemoveRoadBlock", getRootElement(), onPlayerRemoveRoadBlock)

function roadblockCommand(player, cmand)
		if not hasPerm(player, "roadblock") then return end
		triggerClientEvent(player,"onPlayerOpenRoadBlockGui", player)
end
addCommandHandler("blokady", roadblockCommand, false, false)

function spikesHitHandler(hitElement, matchinDimension)
    if getElementType(hitElement) == "player" then
        if matchinDimension then
			local vehicle = getPedOccupiedVehicle(hitElement)
			if not vehicle then return end
			setVehicleWheelStates(vehicle,1)
			setVehicleWheelStates(vehicle,-1,1)
			setVehicleWheelStates(vehicle,-1,-1,1)
			setVehicleWheelStates(vehicle,-1,-1,-1,1)
			exports.rp_vehicles:updateDamageCar(vehicle, nil, nil)
        end
    end
end

addEventHandler("onMarkerHit", spikes, spikesHitHandler)
-- syreny
function onPlayerChangeSirenSound(data, headlighters)
    if headlighters then
        local veh = getPedOccupiedVehicle(client)

        if not veh then
            return
        end

        local model = getElementModel(veh)
        local isPdVehicle = pdVehicles[model] 
        local hasCustomPD = exports.rp_login:getObjectData(veh, "customPD") 

        if isPdVehicle or hasCustomPD then
            if exports.rp_login:getObjectData(veh, "headlight") then
                exports.rp_login:setObjectData(veh, "headlight", false)
                return
            end

            exports.rp_login:setObjectData(veh, "headlight", 1)
        end
    else
        if data ~= 1 and data ~= 2  and data ~= 3 and data ~= 4 then
            return
        end
        local veh = getPedOccupiedVehicle(client)
        if not veh then
            return
        end
        if pdVehicles[getElementModel(veh)] or exports.rp_login:getObjectData(veh, "customPD") then
            if exports.rp_login:getObjectData(veh, "PDSound") then
                return exports.rp_login:setObjectData(veh, "PDSound", false)
            end
            exports.rp_login:setObjectData(veh, "PDSound", data)
        end
    end
end
addEvent("onPlayerChangeSirenSound", true)
addEventHandler("onPlayerChangeSirenSound", getRootElement(), onPlayerChangeSirenSound)


-- komenda /d dla LEA
function LSPDChatCommand(player, cmand, ...)
	local isInGroup = isPlayerInGroupType(player, 2)
	if not isInGroup then return end
	local text = table.concat({...}, " ")
	if #text < 1 then return exports.rp_library:createBox(player,"/d [wiadomosc]") end
	local lspdPlayers = getPlayersInGroupType(2)
	local playerName = exports.rp_utils:getPlayerICName(player)
        for k, v in pairs(lspdPlayers) do
			outputChatBox ( "[LSPD] "..playerName.." mówi: "..text, k, 33, 48, 219, true )
        end
end
addCommandHandler("d", LSPDChatCommand, false, false)


function LSSDChatCommand(player, cmand, ...)
	local isInGroup = isPlayerInGroupType(player, 5)
	if not isInGroup then return end
	local text = table.concat({...}, " ")
	if #text < 1 then return exports.rp_library:createBox(player,"/s [wiadomosc]") end
	local lssdPlayers = getPlayersInGroupType(5)
	local playerName = exports.rp_utils:getPlayerICName(player)
        for k, v in pairs(lssdPlayers) do
			outputChatBox ( "[LSSD] "..playerName.." mówi: "..text, k, 35, 120, 4, true )
        end
end
addCommandHandler("s", LSSDChatCommand, false, false)

-- blip dla pojazdow

function blipCommand(player, cmd)
    local isInPDGroup, isInLSSDGroup = isPlayerInGroupType(player, 2), isPlayerInGroupType(player, 5)
    local groupType = false
    if isInPDGroup then
        groupType = 2
    elseif isInLSSDGroup then
        groupType = 5
    end
    if not groupType then return end

    local veh = getPedOccupiedVehicle(player)
    if not veh then return end

    if pdVehicles[getElementModel(veh)] or exports.rp_login:getObjectData(veh, "customPD") then
        if isElement(visibleBlipsForPD[veh]) then return end

        local blip = createBlipAttachedTo(veh, 0, 2, 66, 135, 245, 255, 0, 9999, resourceRoot)
        visibleBlipsForPD[veh] = blip

        local pdPlayers = getPlayersInGroupType(groupType)
        for k, v in pairs(pdPlayers) do
            setElementVisibleTo(blip, k, true)
        end
    end
end
addCommandHandler("nadajgps", blipCommand, false, false)

local function onPlayerSelectedCharacter()
    local player = source
    local isInPDGroup, isInLSSDGroup = isPlayerInGroupType(player, 2), isPlayerInGroupType(player, 5)
    local groupType = false

    if isInPDGroup then
        groupType = 2
    elseif isInLSSDGroup then
        groupType = 5
    end

    if not groupType then return end

    for veh, blip in pairs(visibleBlipsForPD) do
        if isElement(blip) then
            setElementVisibleTo(blip, player, true)
        end
    end
end
addEventHandler("onPlayerSelectedCharacter", root, onPlayerSelectedCharacter)

function updateBlipsForPlayer(player, kicked)
    if kicked then
        local pdPlayers = getPlayersInGroupType(2)
        local lssdPlayers = getPlayersInGroupType(5)

        for veh, blip in pairs(visibleBlipsForPD) do
            if isElement(blip) then
                for k, v in ipairs(pdPlayers) do
                    setElementVisibleTo(blip, k, true)
                end
                for k, v in ipairs(lssdPlayers) do
                    setElementVisibleTo(blip, k, true)
                end
            end
        end
        return
    end

    local isInPDGroup, isInLSSDGroup = isPlayerInGroupType(player, 2), isPlayerInGroupType(player, 5)
    if not isInPDGroup and not isInLSSDGroup then return end

    for veh, blip in pairs(visibleBlipsForPD) do
        if isElement(blip) then
            setElementVisibleTo(blip, player, true)
        end
    end
end


local function vehicleDestroyed()
	if getElementType(source) == 'vehicle' then
		local hasBlip = visibleBlipsForPD[source]
		if hasBlip then
			destroyElement(hasBlip)
		end
	end
end
addEventHandler("onElementDestroy", getRootElement(), vehicleDestroyed)


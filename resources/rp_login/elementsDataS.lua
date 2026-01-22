elementsData = {}
playersData = {}
tabPlayers = {}


function addTabPlayer(player, name, premium, playerID)
    if not tabPlayers[player] then
        tabPlayers[player] = {}
    end
    tabPlayers[player] = {player = player, name = name, premium = premium, playerID = playerID}
	-- return tabPlayers[player]
end
function destroyTabPlayer(userdata)
    if tabPlayers[userdata] then
        tabPlayers[userdata] = nil
		triggerClientEvent(root,"onLocalDataPlayerTabChange",getRootElement(),tabPlayers)
    end
end

function updateTabData()
	triggerClientEvent(client,"updateTabData", client, tabPlayers)
end
addEvent("onPlayerGotScoreboardData", true)
addEventHandler("onPlayerGotScoreboardData", root, updateTabData)

function setPlayerData(player, data, nowData, disabledSync)
	if not isElement(player) then return end
    if not playersData[player] then
        playersData[player] = {}
    end

    playersData[player][data] = nowData ~= false and nowData or false
    if not disabledSync then
        triggerClientEvent(root, "onLocalDataPlayerChange", getRootElement(), player, data, nowData)
    end
end

function setObjectData(element, key, value, disabledSync)
	if not isElement(element) then return end
    if not elementsData[element] then
        elementsData[element] = {}
    end
    elementsData[element][key] = value ~= false and value or false
    if not disabledSync then
        triggerClientEvent(root, "onLocalDataSingleElementUpdate", getRootElement(), element, key, value)
    end
end

function getObjectData(element, data)
    -- iprint(element, data)
    if isElement(element) and elementsData[element] then
        return elementsData[element][data] or false
    end
end

function getPlayerData(player, data)
    if isElement(player) and playersData[player] then
        return playersData[player][data] or false
    end
end

function onObjectDestroyed()
    if elementsData[source] then
        elementsData[source] = nil
    end
end
addEventHandler("onElementDestroy", root, onObjectDestroyed)

function returnPlayerData(player)
    -- if getElementType(player) == "player" and isLoggedPlayer(player) then
		if not playersData[player] then return end
		local distance = exports.rp_utils:getDistanceBetweenElements(client, player)
		local isAdminSpectating = exports.rp_admin:getAdminSpectatingPlayer(client)
		if not isAdminSpectating and distance >= 300 then return end
        local onlyRequiredDataToVisible = {
            visibleName = playersData[player].visibleName,
            desc = playersData[player].desc,
            ame = playersData[player].ame,
			adminlevel = playersData[player].adminlevel,
			adminDuty = playersData[player].adminDuty,
			groupDuty = playersData[player].groupDuty,
			playerID = playersData[player].playerID,
			charStatuses = playersData[player].charStatuses,
			money = playersData[player].money,
			statistics = playersData[player].statistics, -- moze aktualizowac to tylko dla lokalnego gracza, kiedy trzeba, zeby cziter nie widzial statystyk, pieniedzy moze tez.
			pedType = playersData[player].pedType or false,
			premium = playersData[player].premium or false,
			characterID = playersData[player].characterID,
        }
		if player ~= client then onlyRequiredDataToVisible.money = 0  onlyRequiredDataToVisible.statistics = {} onlyRequiredDataToVisible.characterID = 0 end -- moze byc jakis bug
		triggerClientEvent(client,"onLocalDataSinglePlayerUpdate",client,player,onlyRequiredDataToVisible)

    -- end
end
addEvent("returnPlayerData", true)
addEventHandler("returnPlayerData", root, returnPlayerData)

function returnObjectData(element)
    if elementsData[element] then
		 triggerClientEvent(client, "onLocalDataFullElementUpdate", client, element, elementsData[element])
    end
end
addEvent("returnObjectData", true)
addEventHandler("returnObjectData", root, returnObjectData)
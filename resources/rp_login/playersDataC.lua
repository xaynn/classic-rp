local localPlayersData = {}
local localTabPlayers = {}
local elementsData = {} -- pojazdy, obiekty, oprocz graczy

function updateLocalPlayersData(player, key, value)
    if isElement(player) and isElementStreamedIn(player) then
        if not localPlayersData[player] then
            localPlayersData[player] = {}
        end
		
        localPlayersData[player][key] = value
		-- print(getPlayerName(player).." key: "..key)
    elseif type(player) == "table" then
        localPlayersData = player
    end
end
addEvent("onLocalDataPlayerChange", true)
addEventHandler("onLocalDataPlayerChange", root, updateLocalPlayersData)

function updateLocalTabPlayersData(player, tabData)
   localTabPlayers[player] = tabData
end


addEvent("onLocalDataPlayerTabChange", true)
addEventHandler("onLocalDataPlayerTabChange", root, updateLocalTabPlayersData)


function updatelocalPlayer(player, data)
localPlayersData[player] = data
end
addEvent("onLocalDataSinglePlayerUpdate", true)
addEventHandler("onLocalDataSinglePlayerUpdate", root, updatelocalPlayer)


function handleFullDataUpdate(element, data)
    if isElement(element) and isElementStreamedIn(element) then
        if not elementsData[element] then
            elementsData[element] = {}
        end
        elementsData[element] = data
    end
end
addEvent("onLocalDataFullElementUpdate", true)
addEventHandler("onLocalDataFullElementUpdate", root, handleFullDataUpdate)

function updateElementData(element, data, nowData)
    if isElement(element) and isElementStreamedIn(element) then
        if not elementsData[element] then
            elementsData[element] = {}
        end
        if data then
            elementsData[element][data] = nowData
        end
    end
end

addEvent("onLocalDataSingleElementUpdate", true)
addEventHandler("onLocalDataSingleElementUpdate", root, updateElementData)


function getPlayers()
	return localPlayersData
end


function getTabPlayers()
	return localTabPlayers
end

function getObjectDatas()
	return elementsData
end


function onQuitGame(reason)
    if localPlayersData[source] then
        destroyPlayerData(source)
    end
	if localTabPlayers[source] then
	destroyTabPlayerData(source)
	end
end
addEventHandler("onClientPlayerQuit", getRootElement(), onQuitGame)



function setPlayerData(player, data, newData)
    if isElement(player) then
		-- print("checked if isElement")
        -- if localPlayersData[player] then
			if not localPlayersData[player] then localPlayersData[player] = {} end
            localPlayersData[player][data] = newData
			-- print("set data .."..data)
        -- end
    end
end

function getPlayerData(player, data)
        if localPlayersData[player] then
            return localPlayersData[player][data]
        end
end

function getObjectData(element, data)
        if elementsData[element] then
            return elementsData[element][data]
        end
end

function setObjectData(element, data, newData)
	if elementsData[element] then
		elementsData[element][data] = newData
	end
end


function destroyPlayerData(player)
    -- if isElement(player) then
        if localPlayersData[player] then
            localPlayersData[player] = nil
        end
    -- end
    return false
end



function destroyTabPlayerData(player)
    if isElement(player) then
        if localTabPlayers[player] then
            localTabPlayers[player] = nil
        end
    end
    return false
end

function destroyElementData(element)
	if elementsData[element] then
		elementsData[element] = nil
	end
end
local streamQueue = {}
local queueInterval = 50 -- ms


-- addEventHandler( "onClientElementStreamIn", root, 
    -- function ()
        -- if getElementType(source) == "ped" then
			-- print("znaleziono ")
			-- triggerServerEvent("returnPlayerData", localPlayer, source)
        -- end
    -- end
-- )



function processStreamQueue()
    if #streamQueue > 0 then
        local element = table.remove(streamQueue, 1)
			if isElement(element) then
				triggerServerEvent("returnObjectData", localPlayer, element)
			end
			-- iprint("Triggered returnObjectData for ", element)
    end
end
setTimer(processStreamQueue, queueInterval, 0)

local elementsType = {["object"]=true,["vehicle"]=true, ["marker"] = true}
addEventHandler( "onClientElementStreamIn", root, 
    function ()
		local elementType = getElementType(source)
		
        if elementsType[elementType] and not isElementLocal(source) then 
			-- triggerServerEvent("returnObjectData", localPlayer, source)
			-- iprint("Triggered streamQueue", elementType)
			table.insert(streamQueue, source)
        end
    end
)


addEventHandler(
    "onClientElementStreamOut",
    root,
    function()
        local elementType = getElementType(source)
        if elementType == "player" or elementType == "ped" then
            if localPlayersData[source] then
                destroyPlayerData(source)
            end
        elseif elementType == "vehicle" or elementType == "object" or elementType == "marker" then
            destroyElementData(source)
        end
    end
)

addEventHandler("onClientElementDestroy", root, function()
	if getElementType(source) == "vehicle" or getElementType(source) == "object" or getElementType(source) == "marker" then
		destroyElementData(source)
	end
end)

function dbd()
	iprint(localPlayersData[localPlayer])
end
addCommandHandler("datas", dbd, false, false)
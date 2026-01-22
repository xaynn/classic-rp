local touchedPlayersPed = {}
local playerDataJob = {}
local partTimeJobs = {
[1] = "Magazynier",
[2] = "Złodziej",
[3] = "Rybak",
}
local thiefMarkers = {}
function onPlayerChangePartTimeJob(jobID)
	if not tonumber(jobID) and jobID < 1 and jobID > 3 then return end
	if touchedPlayersPed[client] then
	
    exports.rp_login:changeCharData(client, "parttimejob", tonumber(jobID))
	touchedPlayersPed[client] = nil
	exports.rp_library:createBox(client,"Zatrudniłeś się jako "..partTimeJobs[jobID]..".")
	end
end
addEvent("onPlayerChangePartTimeJob", true)
addEventHandler("onPlayerChangePartTimeJob", root, onPlayerChangePartTimeJob)


function touchPed(player, state)
if not touchedPlayersPed[player] then touchedPlayersPed[player] = {} end
touchedPlayersPed[player] = state 
end

function hasPlayerJobStarted(player)
	return playerDataJob[player] or false
end





--zlodziej
local thiefBlip = createBlip(2451.919921875,-1781.7470703125,13.354012489319, 37, 2, 255, 255, 255, 255, 0, 300)
thiefPed = createPed(29,2451.919921875,-1781.7470703125,13.354012489319, -90, false)
setElementFrozen(thiefPed, true)
local fishermanPed = createPed(2, 375.7568359375,-2069.1572265625,7.8359375, -180, false)
setElementFrozen(fishermanPed, true)

local thiefVehicles = {
[1] = {2466.9521484375,-1775.1884765625,13.363746643066,0,0,0},
[2] = {2470.998046875,-1776.3759765625,13.555879592896,0,0,0},
[3] = {2475.751953125,-1776.1923828125,13.556293487549,0,0,0},
[4] = {2479.869140625,-1777.5087890625,13.555288314819, 0,0,0},
[5] = {2491.71875,-1778.22265625,13.552394866943,0,0,0},
[6] = {2496.0126953125,-1778.3779296875,13.546875,0,0,0},
[7] = {2500.7685546875,-1778.9814453125,13.546875,0,0,0},
}
local vehicleThiefData = {}


local thiefRandom = {
[1] = {2784.666015625,-2417.6005859375,13.749819755554},
[2] = {2784.9638671875,-2455.9072265625,13.751005172729},
[3] = {2785.33984375,-2494.23046875,13.765645980835},
}

local warehouseRandom = {
[1] = {1294.6572265625,-4.7734375,1001.026550293},
[2] = {1294.6591796875,-33.185546875,1001.026550293},
[3] = {1291.8525390625,-33.4951171875,1001.0238037109},
[4] = {1291.7607421875,-5.765625,1001.0236816406},
[5] = {1285.1376953125,-4.5673828125,1001.015625},
[6] = {1282.5537109375,-4.923828125,1001.015625},
[7] = {1282.6826171875,-19.0390625,1001.015625},
[8] = {1285.609375,-19.208984375,1001.015625},
[9] = {1281.373046875,-31.8779296875,1001.0211181641},
[10] = {1276.05859375,-20.85546875,1001.0236206055},
[11] = {1273.0927734375,-19.4296875,1001.0250854492},
[12] = {1272.65625,-4.669921875,1001.0252685547},
[13] = {1269.5947265625,-4.125,1001.0267944336},
[14] = {1264.4609375,-17.259765625,1001.0234375},
[15] = {1266.8125,-17.2255859375,1001.028137207},
[16] = {1268.9208984375,-32.25,1001.0270996094},
[17] = {1271.9287109375,-32.857421875,1001.0256347656},
}

local wareHouseObjects = {
[1] = {1293.0458984375,-4.8115234375,1001.0249633789},
[2] = {1283.90625,-5.3740234375,1001.015625},
[3] = {1270.720703125,-4.3115234375,1001.0262451172},
[4] = {1265.5869140625,-17.84765625,1001.0234375},
[5] = {1274.884765625,-19.8994140625,1001.0241699219},
[6] = {1284.2880859375,-19.58984375,1001.015625},
[7] = {1293.0888671875,-33.1533203125,1001.0250244141},
[8] = {1282.611328125,-32.1259765625,1001.0211181641},
[9] = {1270.2392578125,-32.333984375,1001.0264892578},
}

local thiefMarkersPositions = {
    [1] = { -- Budynek 1
        {2796.044921875,-2411.880859375,13.63164806366},  -- Marker 1
        {2790.8271484375,-2411.6220703125,13.632921218872},  -- Marker 2
        {2784.9697265625,-2411.66796875,13.634351730347},  -- Marker 3
        {2782.283203125,-2423.9697265625,13.635007858276},  -- Marker 4
        {2790.6640625,-2423.685546875,13.632961273193},  -- Marker 5
    },
    [2] = { -- Budynek 2
        {2782.560546875,-2448.734375,13.6349401474},
        {2781.9267578125,-2462.1845703125,13.635095596313},
        {2790.39453125,-2462.4189453125,13.633027076721},
        {2790.5576171875,-2449.0712890625,13.6329870224},
        {2796.3896484375,-2448.423828125,13.631563186646},
    },
    [3] = { -- Budynek 3
        {2798.65234375,-2485.962890625,13.637012481689},
        {2793.0908203125,-2487.4521484375,13.643803596497},
        {2784.9189453125,-2488.2177734375,13.653780937195},
        {2782.6552734375,-2501.0390625,13.656545639038},
        {2790.5126953125,-2501.5947265625,13.646950721741},
    }
}
local jobHandlers = {}


function setPlayerWork(player, job, selectedElement)
    local data = playerDataJob[player]
    if data then
        return exports.rp_library:createBox(player, "Zakończyłeś pracę."), destroyPlayerJob(player)
    end

    local blip
    if job == 1 then -- magazynier
        if selectedElement ~= warehousePed then
            return
        end

        local selectedMarkers = {}
        thiefMarkers[player] = {}

        for i = 1, 10 do
            local randomIndex = math.random(1, #warehouseRandom)
            if not selectedMarkers[randomIndex] then
                selectedMarkers[randomIndex] = true
                local pos = warehouseRandom[randomIndex]
                local marker = createMarker(pos[1], pos[2], pos[3] - 0.9, "cylinder", 1, 255, 0, 0, 0, player)
                setElementDimension(marker, 9)
                setElementInterior(marker, 18)
				table.insert(thiefMarkers[player], marker)
            end
        end
		
        playerDataJob[player] = {job}
    elseif job == 2 then -- zlodziej
        if selectedElement ~= thiefPed then
            return
        end
        local rand = math.random(1, 3)
        local buildingPosition = thiefRandom[rand]

        thiefMarkers[player] = {}
        for _, pos in ipairs(thiefMarkersPositions[rand]) do
            local marker = createMarker(pos[1], pos[2], pos[3] - 0.9, "cylinder", 1, 255, 0, 0, 0, player)
            table.insert(thiefMarkers[player], marker)
        end

		local blip = createBlip(buildingPosition[1],buildingPosition[2],buildingPosition[3],0,2,255,0,0,255,0,9999,player)

        playerDataJob[player] = {job, blip, rand}
    elseif job == 3 then -- rybak
		-- if selectedElement ~= fishermanPed then return end
		-- playerDataJob[player] = {job}
		
    end
	setTimer ( destroyPlayerJob, 6000000, 1, player )
    exports.rp_library:createBox(player, "Rozpocząłeś pracę " .. partTimeJobs[job] .. ".")
end



function playerMarkers(player)
    return thiefMarkers[player] or false
end

function restartThiefVehicle(vehicle)
    if isElement(vehicle) then
        setElementPosition(vehicle,vehicleThiefData[vehicle][1],vehicleThiefData[vehicle][2],vehicleThiefData[vehicle][3])
        setElementRotation(vehicle,vehicleThiefData[vehicle][4],vehicleThiefData[vehicle][5],vehicleThiefData[vehicle][6])
        setElementFrozen(vehicle, true)
		setVehicleEngineState(vehicle, false)
    end
end

jobHandlers["1"] = function(hitElement, playerData)
    local hasPackage = exports.rp_login:getPlayerData(hitElement, "hasPackage")

    if hasPackage then
        if source == warehouseMarker then
            exports.rp_login:setPlayerData(hitElement, "hasPackage", false, true)
            exports.rp_utils:playerJumpAndRunControlState(hitElement, true)
            setPedAnimation(hitElement, "CARRY", "putdwn", 2000, false, true, true, false)
			if isElement(playerData[2]) then destroyElement(playerData[2]) end
			local playerMarkersList = playerMarkers(hitElement)
            if #playerMarkersList == 0 then
                destroyPlayerJob(hitElement)
                exports.rp_atm:givePlayerCustomMoney(hitElement, 250)
                exports.rp_library:createBox(hitElement, "Otrzymałeś 250$ za pracę.")
            end
        end
        return
    end

    local playerMarkersList = playerMarkers(hitElement)
    for index, marker in pairs(playerMarkersList) do
        if source == marker then
            exports.rp_login:setPlayerData(hitElement, "hasPackage", true, true)
            destroyElement(marker)
			table.remove(playerMarkersList, index)
            exports.rp_utils:playerJumpAndRunControlState(hitElement, false)
			playerData[2] = createObject(2912, getElementPosition(hitElement))
			exports.pAttach:attach(playerData[2], hitElement, "backpack", 0, 0.8, 0, 0, 90, 0)
            setPedAnimation(hitElement, "CARRY", "crry_prtial", 1, true, true, false)
            return
        end
    end
end




jobHandlers["2"] = function(hitElement, playerData)
    local exitMarker = playerData[5]

    if exitMarker then
        local vehicle = getPedOccupiedVehicle(hitElement)
        if vehicle == playerData[6] then
            removePedFromVehicle(hitElement)
            restartThiefVehicle(vehicle)
            exports.rp_atm:givePlayerCustomMoney(hitElement, 500)
            exports.rp_library:createBox(hitElement, "Otrzymałeś 500$ za pracę.")
            local blip = playerData[2]
            destroyElement(blip)
            destroyElement(playerData[5])

            playerDataJob[hitElement] = nil
            thiefMarkers[hitElement] = nil
        end
    end

    local playerMarkersList = playerMarkers(hitElement)
    if playerMarkersList then
        if #playerMarkersList == 0 then
            local markerBurrito = playerData[4]
            if source == markerBurrito then
                exports.rp_library:createBox(hitElement, "Odniosłeś paczki do burrito, wróć na miejsce docelowe.")
				setElementPosition(playerData[2], 2455.935546875, -1773.125, 13.574820518494)
                setPedAnimation(hitElement, "CARRY", "putdwn", 2000, false, true, true, false)
                destroyElement(markerBurrito)
                playerData[4] = nil
                playerData[5] = createMarker(2455.935546875, -1773.125, 13.574820518494 - 0.9, "cylinder", 2, 255, 0, 0, 0, hitElement)
                exports.rp_utils:playerJumpAndRunControlState(hitElement, true)
            end
        end

        for index, marker in pairs(playerMarkersList) do
            if marker == source then
                destroyElement(marker)
                table.remove(playerMarkersList, index)
                if #playerMarkersList == 0 then
                    exports.rp_library:createBox(hitElement, "Odnieś wszystkie paczki do Burrito")
                    setPedAnimation(hitElement, "CARRY", "crry_prtial", 1, true)
                    exports.rp_utils:playerJumpAndRunControlState(hitElement, false)
                end
                return
            end
        end
    end
end


jobHandlers["3"] = function(hitElement, playerData)
	
end

function handlePlayerMarker(hitElement, matchingDimension)
    if hitElement and matchingDimension and playerDataJob[hitElement] then
        local elementType = getElementType(hitElement)
        if elementType == "player" then
            local playerData = playerDataJob[hitElement]
            local jobID = tostring(playerData[1])

            if jobHandlers[jobID] then
                jobHandlers[jobID](hitElement, playerData)
            else
                outputDebugString("Brak zdefiniowanej funkcji dla pracy: " .. tostring(jobID))
            end
        end
    end
end

addEventHandler("onMarkerHit", root, handlePlayerMarker)


addEventHandler(
    "onPlayerQuit",
    root,
    function(quitType)
        destroyPlayerJob(source)
		if touchedPlayersPed[source] then touchedPlayersPed[source] = nil end
		
end)


function destroyPlayerJob(player)
    local job = hasPlayerJobStarted(player)
    if not job then
        return
    end
    local markerList = playerMarkers(player)
    for k, v in pairs(markerList) do
        if isElement(v) then
            destroyElement(v)
        end
    end
    local playerData = playerDataJob[player]
    if not playerData then
        return
    end
	local visibleBlip = job[2] 
	if isElement(visibleBlip) then
		destroyElement(visibleBlip)
	end
	
    local exitMarker = playerData[5]
    if isElement(exitMarker) then
        destroyElement(exitMarker)
    end
    local vehicle = playerData[6]
    if isElement(vehicle) then
        restartThiefVehicle(vehicle)
    end
    thiefMarkers[player] = nil
    playerDataJob[player] = nil
	if isElement(player) then
		exports.rp_utils:playerJumpAndRunControlState(player, true)
		setPedAnimation(player, "CARRY", "putdwn", 100, false, true, true, false)
	end
end


function enterVehicle(player, seat, jacked)
    local job, _, _, actualVehicle = hasPlayerJobStarted(player)
		if not job then return end
		local model = getElementModel(source)
		if model ~= 482 then return end
    if job[1] == 2 then
		if playerDataJob[player][6] then return end
        exports.rp_library:createBox(player, "Od teraz tylko w tym pojeździe możesz wkładać paczki.")
		local marker = createMarkerAttachedTo(source, "cylinder", 2, 0, 0, 0, 1, player,0,-2.5,-1)
		-- setElementAlpha(marker, 0)
		-- setMarkerColor(marker, 0, 0, 0, 0)
		playerDataJob[player][4] = marker
		playerDataJob[player][6] = source

    end
end
addEventHandler("onVehicleEnter", getRootElement(), enterVehicle)


function enterVehicleStart(player, seat, jacked)
    local data = exports.rp_login:getObjectData(source, "tempVehicle")
    if data then
        local job, _, _, actualVehicle = hasPlayerJobStarted(player)
        if not job then
            cancelEvent()
        else
			-- iprint(job[6])
			if job and job[6] and job[6] ~= source then cancelEvent() end
        end
    end
end

addEventHandler ( "onVehicleStartEnter", getRootElement(), enterVehicleStart ) 

--Magazynier
local warehouseBlip = createBlip(2328.767578125,-2316.82421875,13.251238822937, 51, 2, 255, 255, 255, 255, 0, 300)
warehousePed = createPed(16,1284.869140625,5.5703125,1001.0106201172, -90, false)
setElementDimension(warehousePed,9)
setElementInterior(warehousePed,18)
setElementFrozen(warehousePed, true)


function loadVehicles()
        for k, v in pairs(thiefVehicles) do
            local vehicle = createVehicle(482, v[1], v[2], v[3]+0.2, v[4], v[5], v[6], "BRAK", false, 2, 255)
            setVehicleColor(vehicle, 0, 0, 0)
            setElementFrozen(vehicle, true)
            vehicleThiefData[vehicle] = {v[1], v[2], v[3], v[4], v[5], v[6]}
            exports.rp_login:setObjectData(vehicle, "tempVehicle", true)
            setVehicleDamageProof(vehicle, true)
        end
end

setModelHandling(482, "maxVelocity", 100)
setModelHandling(482, "engineAcceleration", 5)

function loadPedData()
 exports.rp_login:setPlayerData(warehousePed, "visibleName", "Magazynier")
        exports.rp_login:setPlayerData(warehousePed, "playerID", "PED")
        exports.rp_login:setPlayerData(warehousePed, "pedType", 2) -- 2 zlodziej, praca, typ dwa TO PRACA, 1 urzednik.

        exports.rp_login:setPlayerData(thiefPed, "visibleName", "Złodziej")
        exports.rp_login:setPlayerData(thiefPed, "playerID", "PED")
        exports.rp_login:setPlayerData(thiefPed, "pedType", 2) -- 2 zlodziej, praca, typ dwa TO PRACA, 1 urzednik.
		exports.rp_login:setPlayerData(fishermanPed, "pedType", 3)
		exports.rp_login:setPlayerData(fishermanPed, "playerID", "PED")
		exports.rp_login:setPlayerData(fishermanPed, "visibleName", "Rybak")
		correctPositionForVehicles = setTimer ( loadVehicles, 10000, 1)
		for k,v in pairs(wareHouseObjects) do
			local obj = createObject(3761, v[1], v[2], v[3]+1)
			setElementDimension(obj, 9)
			setElementInterior(obj, 18)
			setObjectBreakable(obj, false)
			-- setElementRotation(obj,0,0,0)
		end
		warehouseMarker = createMarker(1285.869140625,5.9580078125,1001.0098876953 - 0.9, "cylinder", 2, 255, 0, 0, 0)
		setElementDimension(warehouseMarker, 9)
		setElementInterior(warehouseMarker, 18)
end
setTimer ( loadPedData, 10000, 1)



function createMarkerAttachedTo(element, mType, size, r, g, b, a, visibleTo, xOffset, yOffset, zOffset)
	mType, size, r, g, b, a, visibleTo, xOffset, yOffset, zOffset = mType or "checkpoint", size or 4, r or 0, g or 0, b or 255, a or 255, visibleTo or getRootElement(), xOffset or 0, yOffset or 0, zOffset or 0
	assert(isElement(element), "Bad argument @ 'createMarkerAttachedTo' [Expected element at argument 1, got " .. type(element) .. "]") assert(type(mType) == "string", "Bad argument @ 'createMarkerAttachedTo' [Expected string at argument 2, got " .. type(mType) .. "]") assert(type(size) == "number", "Bad argument @ 'createMarkerAttachedTo' [Expected number at argument 3, got " .. type(size) .. "]") assert(type(r) == "number", "Bad argument @ 'createMarkerAttachedTo' [Expected number at argument 4, got " .. type(r) .. "]")	assert(type(g) == "number", "Bad argument @ 'createMarkerAttachedTo' [Expected number at argument 5, got " .. type(g) .. "]") assert(type(b) == "number", "Bad argument @ 'createMarkerAttachedTo' [Expected number at argument 6, got " .. type(b) .. "]") assert(type(a) == "number", "Bad argument @ 'createMarkerAttachedTo' [Expected number at argument 7, got " .. type(a) .. "]") assert(isElement(visibleTo), "Bad argument @ 'createMarkerAttachedTo' [Expected element at argument 8, got " .. type(visibleTo) .. "]") assert(type(xOffset) == "number", "Bad argument @ 'createMarkerAttachedTo' [Expected number at argument 9, got " .. type(xOffset) .. "]") assert(type(yOffset) == "number", "Bad argument @ 'createMarkerAttachedTo' [Expected number at argument 10, got " .. type(yOffset) .. "]") assert(type(zOffset) == "number", "Bad argument @ 'createMarkerAttachedTo' [Expected number at argument 11, got " .. type(zOffset) .. "]")
	local m = createMarker(0, 0, 0, mType, size, r, g, b, a, visibleTo)
	if m then if attachElements(m, element, xOffset, yOffset, zOffset) then return m end end return false
end



function partWasted ( ammo, attacker, weapon, bodypart )
	destroyPlayerJob(source)
end
addEventHandler ( "onPlayerWasted", root, partWasted )

--rybak
local playerFishesTicks = {}

local fishingColshapesPositions = {
    {x = 403.7490234375, y = -2087.9931640625, z = 7.8359375, radius = 1},
    {x = 398.8447265625, y = -2088.3720703125, z = 7.8359375, radius = 1},
    {x = 396.10546875, y = -2088.685546875, z = 7.8359375, radius = 1},
    {x = 391.1494140625, y = -2088.658203125, z = 7.8359375, radius = 1},
    {x = 383.21484375, y = -2088.6884765625, z = 7.8359375, radius = 1},
    {x = 374.876953125, y = -2088.7392578125, z = 7.8359375, radius = 1},
    {x = 369.4677734375, y = -2088.5771484375, z = 7.8359375, radius = 1},
    {x = 367.2021484375, y = -2088.5078125, z = 7.8359375, radius = 1},
    {x = 362.26171875, y = -2088.7490234375, z = 7.8359375, radius = 1},
    {x = 354.4990234375, y = -2088.7978515625, z = 7.8359375, radius = 1},
}

local fishMarkers = createElement("fishMarkers")

for k, v in ipairs(fishingColshapesPositions) do
    local colshape = createColSphere(v.x, v.y, v.z, v.radius)
    setElementParent(colshape, fishMarkers)
end


function onPlayerClickFish(state)
    if not exports.rp_login:getPlayerData(client, "isFishing") then
        return
    end
    if state == 1 then
        local elapsed = getTickCount() - playerFishesTicks[client]
		-- outputChatBox(elapsed)
		if elapsed <= 5000 then return exports.rp_anticheat:banPlayerAC(client, "Manipulate Event", "onPlayerFishChangedState, time: "..elapsed) end
		exports.rp_library:createBox(client,"Złowiłeś rybę.")
		-- exports.rp_atm:givePlayerCustomMoney(client, 50)
		exports.rp_inventory:giveItem(client, "Ryba", 1)
        exports.rp_login:setPlayerData(client, "isFishing", false, true)
        triggerClientEvent(client, "onPlayerUpdateFishingData", client, _, true)
        playerFishesTicks[client] = nil
		bindKey(client, "E", "down", startFishingJob)
    elseif state == 2 then
        exports.rp_library:createBox(player,"Nie udało się złowić ryby.")
        exports.rp_login:setPlayerData(client, "isFishing", false, true)
        triggerClientEvent(client, "onPlayerUpdateFishingData", client, _, true)
        playerFishesTicks[client] = nil
		bindKey(client, "E", "down", startFishingJob)
    end
end

addEvent("onPlayerFishChangedState", true)
addEventHandler("onPlayerFishChangedState", getRootElement(), onPlayerClickFish)


function startFishingJob(player)
	if not isPlayerInFishingColshape(player) then return unbindKey(player, "E", "down", startFishingJob) end
    unbindKey(player, "E", "down", startFishingJob)
    exports.rp_library:createBox(player, "Rozpocząłeś łowienie ryb, trzymaj lewy przycisk myszy aby złowić rybę.")
    triggerClientEvent(player, "onPlayerStartFishing", player) -- timeout
    local randomTime = math.random(3000, 10000)
    local data = 1
    exports.rp_login:setPlayerData(player, "isFishing", true, true)
    triggerClientEvent(player, "onPlayerUpdateFishingData", player, data)
	playerFishesTicks[player] = getTickCount()
end

function onColShapeFishHit(player, matchingDimension)
    if getElementType(player) == "player" then
        -- if exports.rp_login:getPlayerData(player,"isFishing") then return end
        local job = exports.rp_login:getCharDataFromTable(player, "parttimejob")
        if tonumber(job) ~= 3 then
            return exports.rp_library:createBox(player, "Aby łowić ryby, musisz zatrudnić się w urzędzie pracy.")
        end
        if isKeyBound(player, "E", "down", startFishingJob) then
            return
        end
        bindKey(player, "E", "down", startFishingJob)
    end
end
addEventHandler("onColShapeHit", fishMarkers, onColShapeFishHit)

function onColShapeFishLeave(player)
    if getElementType(player) == "player" then
        if exports.rp_login:getPlayerData(player, "isFishing") then
            exports.rp_login:setPlayerData(player, "isFishing", false, true)
			triggerClientEvent(player,"onPlayerUpdateFishingData", player, _, true)
			local unbinded = unbindKey(player, "E", "down", startFishingJob)
			playerFishesTicks[player] = nil
        end
    end
end
addEventHandler("onColShapeLeave", fishMarkers, onColShapeFishLeave)

function isPlayerInFishingColshape(player)
    for _, colshape in ipairs(getElementChildren(fishMarkers)) do
        if isElementWithinColShape(player, colshape) then
            return true
        end
    end
    return false
end

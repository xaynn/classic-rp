
--custom skin = setElementModelSafe(thePlayer, id)
--object createTestElement(thePlayer, "object", id, x,y,z, rx,ry,rz)
--vehicle createTestElement(thePlayer, "vehicle", id, x,y,z, rx,ry,rz)
--getVehicleCustomName(id) exports.rp_newmodels:


--todo swiatla, zamykanie,otwieranie, przypisywanie pod grupe, ui respawnowania pojazdow
vehicles = {}
local vehiclesID = {}
local vehicleID = {}
local playerTemporaryKeys = {}
local blipPlayers = {}
local vehicleEngineState = {}
local playerAllowedToEnterVehicle = {}
local tuneMarkersElements = createElement("tuneMarkersElements")
local isPlayerInTune = {}
function getVehicleMaxFuel(id)
	return 60
end

function getVehByID(id)
local data = vehiclesID[tonumber(id)] or false
return data
end

function playVehicleSound(player,sound)
triggerClientEvent(player,"onPlayVehicleSound",player,sound)
end

function getVehicleUID(vehicle)
	local uid = vehicleID[vehicle]
	return uid or false
end
function getVehicleCurrentData(vehicle, dataToGet)
	local vehicleData = vehicles[vehicle]
	local data = getVehicleData(vehicleData, dataToGet)
	return data or false
end

function changeVehicleCurrentStatistics(vehicle, key, newValue)
	local vehicleData = vehicles[vehicle]
    if vehicleData[key] ~= nil then
        vehicleData[key] = newValue
    end
end

local premiumVehicles = {[411] = true, [415] = true, [541] = true, [480] = true, [40008] = true, [40009] = true, [40011] = true, [40014] = true, [40015] = true, [40016] = true, [40017] = true, [40018] = true, [40019] = true, [40020] = true, [40021] = true, [40022] = true, [40023] = true,
 [40024] = true, [40025] = true, [40026] = true, [40027] = true, [40028] = true, [40029] = true, [40030] = true, [40031] = true, [40032] = true, [40033] = true, [40034] = true, [40035] = true, [40036] = true, [40037] = true, [40038] = true, [40039] = true, [40040] = true, [40041] = true, [40042] = true, [40043] = true, [40044] = true, [40045] = true, [40046] = true, [40047] = true, [40048] = true, [40049] = true, [40050] = true, [40051] = true, [40052] = true, [40053] = true, [40055] = true, [40056] = true, [40057] = true}
function isPremiumVehicle(vehicleID)
	if premiumVehicles[vehicleID] then return true else return false end
end

function setNewSyncer(vehicle, player, state)
    if state then
        setElementSyncer(vehicle, player, true)
		-- print("new syncer for vehicle")
    else
        setElementSyncer(vehicle, false, true)
		-- print("disabled sync for vehicle")
    end
end

function vehicleElementName(vehicle)
	local vehicleData = exports.rp_newmodels:getElementModel(vehicle)
	local vehicleName = exports.rp_newmodels:getCustomModelName(vehicleData) or getVehicleNameFromModel(vehicleData)
	return vehicleName
end

function vehicleModelName(model)
	local modelName
	if tonumber(model) then
		modelName = exports.rp_newmodels:getCustomModelName(model) or getVehicleNameFromModel(model)
	end
	return modelName
end
local seatWindows = {
	[0] = 4,
	[1] = 2,
	[2] = 5,
	[3] = 3
}
local firstCreatedParkedVehicles = {
[1] = {1362.49609375,-1637.9912109375,13.3828125},
[2] = {1370.39453125,-1637.8779296875,13.3828125},
[3] = {1367.9365234375,-1648.6103515625,13.3828125},
[4] = {1367.41796875,-1656.4560546875,13.3828125},
}
function table.random(theTable)
    if type(theTable) ~= "table" or #theTable == 0 then
        return nil 
    end
    return theTable[math.random(1, #theTable)] 
end

function createVeh(player, owner, model, owner_type, onlyCreateInDB)
        local owner = tonumber(owner) -- findPlayer i ge
        local model = tonumber(model)
		local owner_type = tonumber(owner_type)
		if not model then return "modelError" end
		if not owner_type then return "ownerTypeError" end
        local modelName = vehicleModelName(model)
		if not modelName or modelName == "" then return "badID" end
        local target = exports.rp_login:findPlayerByID(owner)
        if target and exports.rp_login:getPlayerData(target,"characterID") then
            owner = exports.rp_login:getPlayerData(target, "characterID")
        end
		if not owner then return "badOwner" end
        local fuel = getVehicleMaxFuel(id)
        local color = {math.random(0, 255), math.random(0, 255), math.random(0, 255), 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255} -- 13, 14, 15 to headlights
        local rotation = {0, 0, 0}
		local x,y,z = getElementPosition(player)
		if onlyCreateInDB then
		x, y, z = 0, 0, 0
			-- local randomPos = table.random(firstCreatedParkedVehicles)
				-- if randomPos then
					-- x, y, z = randomPos[1], randomPos[2], randomPos[3]
				-- end
			end
        local tuning = {}
        local damage = {wheel1 = 0,wheel2 = 0,wheel3 = 0,wheel4 = 0,panel0 = 0,panel1 = 0,panel2 = 0,panel3 = 0,panel4 = 0,panel5 = 0,panel6 = 0,door0 = 0,door1 = 0,door2 = 0,door3 = 0,door4 = 0,door5 = 0}
        local tmpTable = {hp = 1000,x = x,y = y,z = z + 0.5,int = getElementInterior(player),dim = getElementDimension(player),plate = "BRAK",damage = damage,owner=owner,tuning = tuning,fuel = fuel,mileage = 0,color = color,model = model,rotation = rotation,owner_type = 1,blockedWheel = false}
        local _, __, uid = exports.rp_db:query("INSERT INTO vehicles (data, owner) VALUES (?, ?)", toJSON(tmpTable), owner)
		if not onlyCreateInDB then
        local veh = exports.rp_newmodels:createVehicle(model, x, y, z, rotation[1], rotation[2], rotation[3], "BRAK")
		-- setElementCollisionsEnabled(veh, false)
		vehicleEngineState[veh] = false
        vehicles[veh] = tmpTable
        vehiclesID[tonumber(uid)] = veh
		vehicleID[veh] = tonumber(uid)
		setVehiclePlateText(veh, "BRAK")
		setVehicleColor(veh, color[1], color[2], color[3], color[4], color[5], color[6], color[7], color[8], color[9], color[10], color[11], color[12])
		end
end



function vehicleCommand(player, cmand, ...)
    local arg = {...}
    if arg[1] == "stworz" then -- stworz owner, model, owner_type 1 - gracz, 2 - grupa.
        if not exports.rp_admin:hasAdminPerm(player,"vehicleCreate") then return end
        local owner = tonumber(arg[2]) -- findPlayer i ge
        local model = tonumber(arg[3])
        local owner_type = tonumber(arg[4])
        local created = createVeh(player, owner, model, owner_type)
        if created == "modelError" then
            exports.rp_library:createBox(player, "/v stworz [owner] [model] [owner_type, 1-3]")
        elseif created == "badID" then
            exports.rp_library:createBox(player, "Zle ID pojazdu")
        elseif created == "badOwner" then
            exports.rp_library:createBox(player, "/v stworz [owner] [model] [owner_type, 1-3]")
        elseif created == "ownerTypeError" then
            exports.rp_library:createBox(player, "/v stworz [owner] [model] [owner_type, 1-3]")
        end
    elseif arg[1] == "spawn" then
	    if not exports.rp_admin:hasAdminPerm(player,"vehicleSpawn") then return end
        local id = tonumber(arg[2])
        if not id then
            return exports.rp_library:createBox(player, "TIP: /v spawn id")
        end
        local spawned = spawnVehicle(id)
        if spawned then
            exports.rp_library:createBox(player, "Zespawnowałeś pojazd")
        else
            exports.rp_library:createBox(player, "Odspawnowałeś pojazd")
        end
	elseif arg[1] == "kolor" then
		if not exports.rp_admin:hasAdminPerm(player,"vehicleCreate") then return end
		local id = tonumber(arg[2])
		if not id then return exports.rp_library:createBox(player,"TIP: /v kolor id color1, color2, color3") end
		if not arg[5] then return exports.rp_library:createBox(player,"Kolory musza byc w numerach 0-255, oraz wypelnij wszystkie argumenty.") end
		local color = {arg[3], arg[4], arg[5], 255, 255, 255, 0, 0, 0, 0, 0, 0, 255, 255, 255}
		local vehicle = vehiclesID[id]
		if not vehicle then return exports.rp_library:createBox(player,"Pojazd nie jest zespawnowany.") end
		changeVehicleCurrentStatistics(vehicle, "color", color)
		setVehicleColor(vehicle, color[1], color[2], color[3], color[4], color[5], color[6], color[7], color[8], color[9], color[10], color[11], color[12])
    elseif arg[1] == "parkuj" then -- sprawdzanie permow czy nalezy auto do niego itd
        local vehicle = getPedOccupiedVehicle(player)
		if not vehicle then return end
        if not hasPlayerPermToVehicle(player, vehicle) then
            return
        end
        local x, y, z = getElementPosition(vehicle)
        local rotx, roty, rotz = getElementRotation(vehicle)
        local int, dim = getElementInterior(vehicle), getElementDimension(vehicle)
        local data = vehicles[vehicle]
        changeVehicleStatistics(data, "rotation", {rotx, roty, rotz})
        changeVehicleStatistics(data, "x", x)
        changeVehicleStatistics(data, "y", y)
        changeVehicleStatistics(data, "z", z)
        changeVehicleStatistics(data, "int", int)
        changeVehicleStatistics(data, "dim", dim)
        exports.rp_library:createBox(player, "Zaparkowałeś pojazd.")
    elseif arg[1] == "z" then
        local nearestVehicle = getNearestElement(player, "vehicle", 5)
		if not nearestVehicle then return end
        if not hasPlayerPermToVehicle(player, nearestVehicle) then
            return
        end
            setVehicleLocked(nearestVehicle, not isVehicleLocked(nearestVehicle))
            local vehName = vehicleElementName(nearestVehicle)
			local sex = exports.rp_login:getPlayerGender(player)
			if sex == "male" then
            exports.rp_nicknames:amePlayer(player, string.format("%s %s.", isVehicleLocked(nearestVehicle) and "zamknął" or "otworzył", vehName))
				else
			exports.rp_nicknames:amePlayer(player, string.format("%s %s.", isVehicleLocked(nearestVehicle) and "zamknęła" or "otworzyła", vehName))
			end
            playVehicleSound(player, "lock")
    elseif arg[1] == "uid" then
        local nearestVehicle = getNearestElement(player, "vehicle", 5)
        if nearestVehicle then
            local uid = vehicleID[nearestVehicle]
            exports.rp_library:createBox(player, "UID pojazdu: " .. uid)
        end
    elseif arg[1] == "bring" then
	    if not exports.rp_admin:hasAdminPerm(player,"vehicleBring") then return end
        if not arg[2] then
            return exports.rp_library:createBox(player, "TIP: /v bring [id]")
        end
        local uid = vehiclesID[tonumber(arg[2])]
        if uid then
            local x, y, z = exports.rp_utils:getXYInFrontOfPlayer(player, 5)
            setElementPosition(uid, x, y, z)
            setElementDimension(uid, getElementDimension(player))
            setElementInterior(uid, getElementInterior(player))
            exports.rp_library:createBox(player, "Zbringowałeś pojazd.")
        end
    elseif arg[1] == "flip" then
	    if not exports.rp_admin:hasAdminPerm(player,"vehicleBring") then return end
        local uid = vehiclesID[tonumber(arg[2])]
        if uid then
            local rx, ry, rz = getElementRotation(uid)
            setElementRotation(uid, rx, ry + 180, rz)
            exports.rp_library:createBox(player, "Obróciłeś pojazd.")
        end
    elseif arg[1] == "fix" then
	    if not exports.rp_admin:hasAdminPerm(player,"vehicleFix") then return end
        local uid = vehiclesID[tonumber(arg[2])]
        if uid then
            fixVehicle(uid)
            updateDamageCar(uid, nil, true)
            exports.rp_library:createBox(player, "Naprawiłeś pojazd.")
        end
    elseif arg[1] == "okno" then
    local veh = getPedOccupiedVehicle(player)
    if not veh then return end

    local seat = getPedOccupiedVehicleSeat(player)
    if not seatWindows[seat] then return end

    local windowIndex = seatWindows[seat]
    local data = exports.rp_login:getObjectData(veh, "windows")

    if type(data) ~= "table" then
        data = {false, false, false, false} 
    end

    local newState = not data[seat + 1]
    data[seat + 1] = newState

    exports.rp_login:setObjectData(veh, "windows", data)
	playVehicleSound(player, "closingwindow")
	elseif arg[1] == "blokuj" then
	exports.rp_groups:blockWheelVehicle(player)
	
	elseif arg[1] == "odblokuj" then
	exports.rp_groups:unblockWheelVehicle(player)
	elseif arg[1] == "drzwi"  then
    local id = tonumber(arg[2]) or "all"
	if not exports.rp_utils:checkPassiveTimer("vehicleDoors", player, 600) then return end
	if id == "all" then exports.rp_library:createBox(player,"/v drzwi (0-5)") end
	local vehicle = getPedOccupiedVehicle(player)
	local driver = getVehicleOccupant(vehicle, 0)
	if driver == player then
	if id == "all" then
	for i=0,5 do
		setVehicleDoorOpenRatio ( vehicle, i, 1 - getVehicleDoorOpenRatio ( vehicle, i ), 500 )
		end
	else
	
	setVehicleDoorOpenRatio(vehicle, id, 1 - getVehicleDoorOpenRatio ( vehicle, id ), 500)
	end
	end
    elseif arg[1] == "okna" then -- otwieranie wszystkich okien
        -- todo
	local veh = getPedOccupiedVehicle(player)
	local driver = getVehicleOccupant(veh, 0)
	if driver ~= player then return end
	if not veh then return end
	local data = exports.rp_login:getObjectData(veh, "windows")
    
    if type(data) ~= "table" then
        data = {false, false, false, false}
    end

    local isAnyOpen = false
    for i = 1, #data do
        if data[i] then
            isAnyOpen = true
            break
        end
    end

    local newState = not isAnyOpen
    local newData = {newState, newState, newState, newState}

    exports.rp_login:setObjectData(veh, "windows", newData)
	playVehicleSound(player,"closingwindow")
	elseif arg[1] == "tablica" then
	if not exports.rp_groups:hasPerm(player, "steal") then return exports.rp_library:createBox(player,"Nie możesz zdjąć tablicy.") end
	local vehicle = getNearestElement(player, "vehicle", 5)
	if not vehicle and not exports.rp_login:getObjectData(vehicle,"stealed") then return exports.rp_library:createBox(player,"Nie możesz zdjąć pojazdowi tablic, gdy nie jest on ukradziony.") end
	setVehiclePlateText(vehicle, "_")
	-- exports.rp_soundsystem:playSoundInArea(player, _, _, _, _, _, "takingplates")
	elseif arg[1] == "tp" then
	if not exports.rp_admin:hasAdminPerm(player,"vehicleFix") then end
	local uid = vehiclesID[tonumber(arg[2])]
	if not uid then return exports.rp_library:createBox(player,"Pojazd o podanym ID nie jest zespawnowany.") end
	local x,y,z = getElementPosition(uid)
	local dimension, interior = getElementDimension(uid), getElementInterior(uid)
	setElementPosition(player, x,y,z)
	setElementDimension(player, dimension)
	setElementInterior(player, interior)
	elseif arg[1] == "fuel" then
		if not exports.rp_admin:hasAdminPerm(player,"vehicleFix") then return end
		local uid = vehiclesID[tonumber(arg[2])]
        if uid then
		 local data = vehicles[uid]
			changeVehicleStatistics(data, "fuel", 60)
            exports.rp_library:createBox(player, "Zatankowano pojazd.")
			local driver = getVehicleOccupant(uid, 0)
			if driver then triggerClientEvent(driver,"onLocalVehicleUpdateData",driver,60) end
        end
	elseif arg[1] == "tankuj" then
	if isPlayerInGasStation(player) then
		local vehicle = getPedOccupiedVehicle(player)
		if not vehicle then return end
	   if getVehicleEngineState(vehicle) then return  exports.rp_library:createBox(player,"Wyłącz silnik przed tankowaniem.") end
		local data = vehicles[vehicle]
		local vehicleFuel = getVehicleData(data, "fuel")
		triggerClientEvent(player,"onPlayerShowFuelTank",player, vehicleFuel, priceForLitr)
	end
	elseif arg[1] == "kradnij" then
        local veh = getPedOccupiedVehicle(player)
        if not veh then
            return exports.rp_library:createBox(player, "Musisz być w pojeździe.")
        end
        local driver = getVehicleOccupant(veh, 0)
        if not driver then
            return exports.rp_library:createBox(player, "Musisz być na miejscu kierowcy, aby ukraść pojazd.")
        end
        exports.rp_groups:stealVehicle(player, veh)
	elseif arg[1] == "tuning" then
		if not isPlayerInTune[player] then return end
		local veh = getPedOccupiedVehicle(player)
		if not veh then return end
		local vehType = getVehicleType(veh)
		local tempVehicle = exports.rp_login:getObjectData(veh, "tempVehicle")
		if tempVehicle then return end
		if vehType == "Automobile" or vehType == "Quad" then
		local vehicleUpgrades = getVehicleCompatibleUpgradesForTune(veh)
		-- local color1, color2, color3, color4, color5, color6, color7, color8, color9, color10, color11, color12 = getVehicleColor ( veh, true)
		-- local dataColors = {color1, color2, color3}
		-- iprint(dataColors)
		local color = getVehicleCurrentData(veh, "color")
		local colors = {color[13], color[14], color[15]}
		triggerClientEvent(player,"onPlayerOpenTuneSystem",player, vehicleUpgrades, veh, colors)
		local genDim = exports.rp_login:getPlayerData(player,"characterID") + 99
		setElementDimension(player, genDim)
		setElementDimension(veh, genDim)
		setElementPosition(veh,2064.84765625,-1831.62890625,13.546875)
		setElementFrozen(veh, true)
		else
		exports.rp_library:createBox(player,"Można tuningować tylko zwykłe pojazdy.")
		end
	elseif arg[1] == "napraw" then
        if not exports.rp_groups:hasPerm(player, "repairVehicle") then
            return
        end
        local target = arg[2]
        if not target then
            return exports.rp_library:createBox(player, "/v napraw [id gracza]")
        end
        local realTarget = exports.rp_login:findPlayerByID(tonumber(target))
        if not realTarget then
            return exports.rp_library:createBox(player, "Nie ma gracza na serwerze.")
        end
        local distance = exports.rp_utils:getDistanceBetweenElements(player, realTarget)
        if distance > 5 then
            return exports.rp_library:createBox(player, "Gracz jest za daleko aby wysłać mu ofertę.")
        end
        local veh = getPedOccupiedVehicle(realTarget)
        if not veh then
            return exports.rp_library:createBox(player, "Gracza nie ma w pojezdzie.")
        end
        local price = exports.rp_groups:calculateVehicleRepairCost(veh)
        if price.totalCost < 1 then
            return exports.rp_library:createBox(player, "Pojazd nie wymaga naprawy.")
        end
        exports.rp_offers:sendOffer(player, realTarget, 7, veh, price.totalCost, "Naprawa pojazdu")
    elseif arg[1] == "namierz" then -- dla admina
	    if not exports.rp_admin:hasAdminPerm(player,"vehicleLocate") then return end
        local uid = vehiclesID[tonumber(arg[2])]
        if not uid then
            return exports.rp_library:createBox(player, "Pojazd nie jest zespawnowany.")
        end
        locateVehicle(player, uid)
        exports.rp_library:createBox(player, "Pojazd został namierzony.")
    elseif arg[1] == "podpisz" then
        local veh = getPedOccupiedVehicle(player)
        if not veh then
            return
        end
        local groupID = arg[2]
        if not groupID then
            return
        end
        local data = vehicles[veh]
        local owner = data.owner
        local isInGroup = exports.rp_groups:isPlayerInGroup(player, tonumber(groupID))
        if not isInGroup then
            return exports.rp_library:createBox(player, "Nie jesteś w tej grupie, aby przypisać pojazd.")
        end
        if owner == exports.rp_login:getPlayerData(player, "characterID") then
            exports.rp_library:createBox(player, "Podpisałeś pojazd pod grupę.")
			setNewOwnerVehicle(veh, groupID, 2)
        else
            exports.rp_library:createBox(player, "Nie jest to twój pojazd.")
        end
    else
		local vehicles = getPlayerVehicles(player)
		triggerClientEvent(player,"showVehicles",player, vehicles)
    end
end

addCommandHandler("v", vehicleCommand, false, false)
addCommandHandler("veh", vehicleCommand, false, false)


function getPlayerVehicles(player)
    local tmpTable = {}
    local characterID = exports.rp_login:getPlayerData(player, "characterID")
    local veh = exports.rp_db:query("SELECT * FROM vehicles WHERE owner = ?", characterID)

    for k, v in pairs(veh) do
        local data = fromJSON(v.data)
        data.uid = v.id 
		data.vehicleName = vehicleModelName(data.model)
        table.insert(tmpTable, data)
    end

    return tmpTable
end

function getGroupVehicles(groupID)
	local tmpTable = {}
	local veh = exports.rp_db:query("SELECT * FROM vehicles WHERE owner = ?", groupID)
	for k,v in pairs(veh) do
		local data = fromJSON(v.data)
		if data.owner_type == 2 then
		data.uid = v.id
		data.vehicleName = vehicleModelName(data.model)--exports.rp_newmodels:getVehicleCustomName(data.model) or getVehicleNameFromModel(data.model)
        table.insert(tmpTable, data)
		end
		
	end
	return tmpTable
end 

function locateVehicle(player, vehicle)
    local player = player
    local x, y, z = getElementPosition(vehicle)
    if blipPlayers[player] and isElement(blipPlayers[player]) then
        destroyElement(blipPlayers[player])
    end
    blipPlayers[player] = createBlipAttachedTo(vehicle,0, 2, 255,0 ,0, 255,0, 16383, player)
    setTimer(
        function()
            if blipPlayers[player] and isElement(blipPlayers[player]) then
                destroyElement(blipPlayers[player])
            end
        end,
        30000,
        1
    )
end

function locateVehiclePlayer(vehicleID) -- chuj tego nie zabezpieczam, raczej typ z lua executorem nie bedzie specjalnie sprawdzal i namierzal inne pojazdy xD
    local player = client
	local uid = vehiclesID[tonumber(vehicleID)]
	if not exports.rp_utils:checkPassiveTimer("vehicleLocate", player, 1000) then return exports.rp_library:createBox(player,"Poczekaj chwilę przed następnym kliknięciem.") end
	if not uid then return exports.rp_library:createBox(player,"Pojazd nie jest zespawnowany.") end
    local x, y, z = getElementPosition(uid)
	local stealed = exports.rp_login:getObjectData(uid,"stealed")
	if stealed then return exports.rp_library:createBox(player, "Z twoim pojazdem są prowadzone czynnośći, nie można go namierzyć.") end
    if blipPlayers[player] and isElement(blipPlayers[player]) then
        destroyElement(blipPlayers[player])
    end
    blipPlayers[player] = createBlipAttachedTo(uid, 0, 2, 255,0 ,0, 255,0, 16383, player)
	exports.rp_library:createBox(player,"Namierzono pojazd.")
    setTimer(
        function()
            if blipPlayers[player] and isElement(blipPlayers[player]) then
                destroyElement(blipPlayers[player])
            end
        end,
        30000,
        1
    )
end
addEvent("onPlayerLocateVehicle", true)
addEventHandler("onPlayerLocateVehicle", root, locateVehiclePlayer)


function enableEngine(player)
    local vehicle = getPedOccupiedVehicle(player)
    if not vehicle then
        return
    end
    if not hasPlayerPermToVehicle(player, vehicle) then
        return
    end
	local driver = getVehicleOccupant(vehicle, 0)
	if not driver then return end
	local vehicleType = getVehicleType(vehicle)
	if vehicleType == "Bike" or vehicleType == "BMX" then return end
	local tempVehicle = exports.rp_login:getObjectData(vehicle, "tempVehicle")
	local fuel
	if tempVehicle then
		fuel = 60
		if not exports.rp_groups:hasPlayerJobStarted(player) == 2 then return exports.rp_library:createBox(player,"Musisz zacząć prace dorywczą aby korzystać z tego pojazdu.") end
	else
		local data = vehicles[vehicle] or false
		fuel = getVehicleData(data, "fuel") or 60
	end

	

	if fuel <= 0 then return exports.rp_library:createBox(player,"Pojazd nie posiada paliwa.") end
	if not tempVehicle then
	local blockedWheel = getVehicleCurrentData(vehicle, "blockedWheel")
	if blockedWheel then return exports.rp_library:createBox(player,"Pojazd posiada blokadę na koło.") end
	end

    if exports.rp_utils:checkPassiveTimer("vehEngine", player, 1000) then
        setTimer(
            function()
                if getElementHealth(vehicle) <= 350 then
                    return playVehicleSound(player, "enginefailed"), exports.rp_library:createBox(
                        player,
                        "Silnik jest uszkodzony."
                    )
                end
                setVehicleEngineState(vehicle, not getVehicleEngineState(vehicle))
                vehicleEngineState[vehicle] = getVehicleEngineState(vehicle)
                -- print(vehicleEngineState[vehicle])
                if getVehicleEngineState(vehicle) then
                    playVehicleSound(player, "engine")
                    exports.rp_nicknames:amePlayer(player, "odpala silnik w pojeździe.")
                end
            end,
            500,
            1
        )
    end
end


function enableLights(player)
    if exports.rp_utils:checkPassiveTimer("vehLights", player, 400) then
        local vehicle = getPedOccupiedVehicle(player)
        if not vehicle then
            return
        end
		local driver = getVehicleOccupant(vehicle, 0)
		if not driver then return end
        if (getVehicleOverrideLights(vehicle) ~= 2) then
            setVehicleOverrideLights(vehicle, 2)
        else
            setVehicleOverrideLights(vehicle, 1)
        end
		playVehicleSound(player,"lightswitch")

    end
end

function hitVehicleFuel(returnData)
		-- print("executed getVehicleFuel")
		local vehicle = getPedOccupiedVehicle(client)
		if not vehicle then return end--print("brak pojazdu") end
		if not vehicles[vehicle] then return end--print("brak danych") end

    if returnData then
        local data = vehicles[vehicle]
        local fuel = getVehicleData(data, "fuel")
        triggerClientEvent(client, "onLocalVehicleUpdateData", client, fuel)
    else
        local driver = getVehicleOccupant(vehicle, 0)
        local vehUsing = getPedOccupiedVehicle(client)
        if not driver or not vehUsing then
            return --print("brak drivera lub nie korzystasz z pojazdu")
        end
        if driver ~= client then
            return --print("not driver")
        end
        if vehUsing ~= vehicle then
            return-- print("bad veh")
        end
        if not getVehicleEngineState(vehicle) then
            return --print("silnik nie jest wlaczony")
        end
        local data = vehicles[vehicle]
        local fuel = getVehicleData(data, "fuel")
		local calc = fuel - 0.3
		if calc <= 0 then calc = 0 setVehicleEngineState(vehicle, false) end
        changeVehicleStatistics(data, "fuel", calc)
        triggerClientEvent(client, "onLocalVehicleUpdateData", client, calc)
    end
end
addEvent("getVehicleFuel", true)
addEventHandler("getVehicleFuel", root, hitVehicleFuel)


function hasPlayerPermToVehicle(player, vehicle) -- pojazd jako element, lub jako id:-)
	if not playerTemporaryKeys[player] then playerTemporaryKeys[player] = {} end
	if exports.rp_login:getObjectData(vehicle, "tempVehicle") then return true end
	local ownerType = getVehicleCurrentData(vehicle, "owner_type")
	if ownerType == 2 then
		local groupID = getVehicleCurrentData(vehicle, "owner")
		local hasPerm = exports.rp_groups:hasPermInCurrentGroup(player, tonumber(groupID), "vehicleAccess")
		if hasPerm then return true end
	end
	
    local data = vehicles[vehicle] or getVehByID(vehicle) -- element lub id pojazdu
	-- iprint(data)
    local owner = getVehicleData(data, "owner")
	local vehID = getVehicleData(data, "uid") -- uid pojazdu
    local keys = playerTemporaryKeys[player]
    local playerCharacterID = exports.rp_login:getPlayerData(player, "characterID")
	local adminDuty = exports.rp_login:getPlayerData(player,"adminDuty")
	
	if adminDuty then 
		return true
	end
	-- local admin = exports.rp_admin:hasPerm(player,"vehicles")
	-- if admin then return true end
    if tonumber(playerCharacterID) == tonumber(owner) then
        return true -- wlasciciel pojazdu
    end
	
    for k, v in pairs(keys) do
        if tonumber(v) == tonumber(vehID) then
            return true
        end
    end

    return false
end


function giveTempKeys(player, vehicleUID)
    if not playerTemporaryKeys[player] then
        playerTemporaryKeys[player] = {}
    end
    local tempKeys = playerTemporaryKeys[player]
    local removed = false
    for k, v in pairs(tempKeys) do
        if tonumber(v) == tonumber(vehicleUID) then
            table.remove(tempKeys, k)
            removed = true
        end
    end

    if removed then
        return "deletedKey"
    else
        table.insert(tempKeys, tonumber(vehicleUID))
        return "added key"
    end
end




function enterVehicle(player, seat, jacked)
    if isVehicleLocked(source) then
        local vehicleAllowed = playerAllowedToEnterVehicle[player]
        if vehicleAllowed ~= source then
            exports.rp_anticheat:banPlayerAC(player, "Manipulate Vehicle", "onVehicleEnter")
        end
    end
		-- if not getElementSyncer(source) then
			-- setNewSyncer(source, player, true)
		if not getElementSyncer(source) then
			if seat == 0 then
				setNewSyncer(source, player, true)
			end
		end
		-- if not getElementCollisionsEnabled(source) then setElementCollisionsEnabled(source, true) end
    if getElementHealth(source) <= 350 then
        exports.rp_library:createBox(player, "Silnik jest uszkodzony.")
        setVehicleEngineState(source, false)
    end
    local state = vehicleEngineState[source]
    if not state then
        setVehicleEngineState(source, false)
    end
	local wasTriedToStealed = exports.rp_login:getObjectData(source,"stealing")
	if wasTriedToStealed then
		local owner = getVehicleCurrentData(source, "owner")
		local characterID = exports.rp_login:getPlayerData(player,"characterID")
		if characterID == owner then
		outputChatBox("#8982bd** widać próby kradzieży  pojazdu, cywil przechodzący obok ciebie powiadomił Cię, że wył alarm pojazdu w okolicy.", player, 255, 255, 255, true)
		exports.rp_login:setObjectData(source,"stealing", false, true)
		end
	end

end
addEventHandler("onVehicleEnter", getRootElement(), enterVehicle)


function onVehicleExit ( player, seat, jacked )
  if playerAllowedToEnterVehicle[player] then playerAllowedToEnterVehicle[player] = nil end 
  if seat == 0 then setNewSyncer(source, player, false) end
end
addEventHandler ( "onVehicleExit", getRootElement(), onVehicleExit )

function enterVehicleStart(player, seat, jacked)
    if isVehicleLocked(source) then
        cancelEvent()
    end
    if not isVehicleLocked(source) then
        playerAllowedToEnterVehicle[player] = source
    end
    if seat == 0 then
		if isPremiumVehicle(exports.rp_newmodels:getElementModel(source)) and not exports.rp_login:getPlayerData(player, "premium") then return cancelEvent(), exports.rp_library:createBox(player,"Nie posiadasz premium, aby móc korzystać z tego pojazdu.") end
        local driver = getVehicleOccupant(source, 0)
        if driver then
            local allowed = hasPlayerPermToVehicle(player, source)
            if not allowed then
                cancelEvent()
            end
        end
    end
end
addEventHandler("onVehicleStartEnter", getRootElement(), enterVehicleStart)



function changeVehicleStatistics(table, key, newValue)
    if table[key] ~= nil then
        table[key] = newValue
    end
end



function vehicleElementName(vehicle)
	local vehicleData = exports.rp_newmodels:getElementModel(vehicle)
	local vehicleName = exports.rp_newmodels:getCustomModelName(vehicleData) or getVehicleNameFromModel(vehicleData)
	return vehicleName
end

function getVehicleData(tbl, key)
	-- iprint(tbl, key)
    if tbl[key] ~= nil then
        return tbl[key]
    else
        return nil
    end
end

local tuneTable = {[8001] = {maxVelocity = 2.5, engineAcceleration = 1, traction = 0.1},
[8002] = {maxVelocity = 5, engineAcceleration = 2, traction = 0.2},
[8003] = {maxVelocity = 7.5, engineAcceleration = 3, traction = 0.3},
}


local convertedDoors = {
["door0"] = 0,
["door1"] = 1,
["door2"] = 2,
["door3"] = 3,
["door4"] = 4,
["door5"] = 5,
}

local convertedPanels = {
["panel0"] = 0,
["panel1"] = 1,
["panel2"] = 2,
["panel3"] = 3,
["panel4"] = 4,
["panel5"] = 5,
["panel6"] = 6,
}

function displayVehicleLoss(loss)
    local source = source
	if isVehicleDamageProof(source) then return end
    local thePlayer = getVehicleOccupant(source)
    if (thePlayer) then
        local data = vehicles[source]
        -- iprint(data)
        if data then
            local damage = getVehicleData(data, "damage")
            if loss > 40 then
                updateDamageCar(source, loss)
            else
                updateVehicleDoorStates(source, damage)
                updateVehiclePanelStates(source, damage)
                setTimer(
                    function()
						local c,x = getElementHealth(source), loss
                        setElementHealth(source, tonumber(c) + tonumber(x))
                    end,100,1)
            end
        end
    else
        local data = vehicles[source]
        if data then
            local damage = getVehicleData(data, "damage")
			
            updateVehicleDoorStates(source, damage)
            updateVehiclePanelStates(source, damage)
            setTimer(
                function()
						local c,x = getElementHealth(source), loss
                        setElementHealth(source, tonumber(c) + tonumber(x))
                end,100,1)
        end
    end
end

addEventHandler("onVehicleDamage", root, displayVehicleLoss)


function updateVehicleDoorStates(vehicle, damage)
    for door, state in pairs(damage) do
        if string.match(door, "door") then
			local doorConverted = convertedDoors[door]
            setVehicleDoorState(vehicle, doorConverted, tonumber(state))
        end
    end
end

function updateVehiclePanelStates(vehicle, damage)
    for panel, state in pairs(damage) do
        if string.match(panel, "panel") then
			local panelConverted = convertedPanels[panel]
			setVehiclePanelState(vehicle, panelConverted, tonumber(state))
        end
    end
end

function spawnVehicle(id)
    local getVehicle = getVehByID(tonumber(id))
    if getVehicle then
        saveVehicle(getVehicle)
        destroyVehicleData(getVehicle)
        if isElement(getVehicle) then 
            destroyElement(getVehicle)
        end
        return false
    else
        local veh = exports.rp_db:query("SELECT * FROM vehicles WHERE id = ?", id)
        if veh and veh[1] then
            local data = fromJSON(veh[1].data)
            local model = getVehicleData(data, "model")
            local x, y, z = getVehicleData(data, "x"), getVehicleData(data, "y"), getVehicleData(data, "z")
            local rotation = getVehicleData(data, "rotation")
            local damage = getVehicleData(data, "damage")
            local plate = getVehicleData(data, "plate")
            local color = getVehicleData(data, "color")
            local hp = getVehicleData(data, "hp")
			local tuning = getVehicleData(data, "tuning")
			if x == 0 and y == 0 and z == 0 then
				x, y, z = exports.rp_utils:getXYInFrontOfPlayer(player, 1)
			end
            local vehicle = exports.rp_newmodels:createVehicle(model, x, y, z, rotation[1], rotation[2], rotation[3], "BRAK")
			data.uid = veh[1].id 
            setVehicleDamageProof(vehicle, true)
            vehicles[vehicle] = data
            vehiclesID[tonumber(veh[1].id)] = vehicle
            vehicleID[vehicle] = tonumber(veh[1].id)
			--tuneTable maxVelocity, engineAcceleration
			local highestTraction = 0
            for k,v in pairs(tuning) do 
				local dataTuneEngine = tuneTable[tonumber(v)]
				if dataTuneEngine then
					local acceleration = getVehicleHandling(vehicle,"engineAcceleration")
					local maxVelocity = getVehicleHandling(vehicle,"maxVelocity")
					local traction = getVehicleHandling(vehicle,"tractionMultiplier")
					if dataTuneEngine.traction > highestTraction then
						highestTraction = dataTuneEngine.traction
					end
					setVehicleHandling(vehicle, "engineAcceleration", acceleration + dataTuneEngine.engineAcceleration)
					setVehicleHandling(vehicle, "maxVelocity", maxVelocity + dataTuneEngine.maxVelocity)
					else
					addVehicleUpgrade(vehicle, tonumber(v))
				end
			end
			local traction = getVehicleHandling(vehicle, "tractionMultiplier")
			local newTraction = traction + highestTraction
			setVehicleHandling(vehicle, "tractionMultiplier", math.min(newTraction, 1.2))
            setVehicleWheelStates(vehicle, damage.wheel1, damage.wheel2, damage.wheel3, damage.wheel4)
            updateVehicleDoorStates(vehicle, damage)
            updateVehiclePanelStates(vehicle, damage)
            setVehiclePlateText(vehicle, plate)
            setVehicleColor(vehicle, color[1], color[2], color[3], color[4], color[5], color[6], color[7], color[8], color[9], color[10], color[11], color[12])
			setVehicleHeadLightColor(vehicle, color[13], color[14], color[15])
            setVehicleLocked(vehicle, true)
            vehicleEngineState[vehicle] = false
			local vehicleType = getVehicleType(vehicle)
			if vehicleType == "Bike" or vehicleType == "BMX" then
				vehicleEngineState[vehicle] = true
				setVehicleEngineState(vehicle, true)
			end
            if hp <= 350 then
                setElementHealth(vehicle, 350)
            else
                setElementHealth(vehicle, hp)
            end
			setNewSyncer(vehicle, player, false)
            setTimer(function()
                if isElement(vehicle) then 
                    setVehicleDamageProof(vehicle, false)
                end
            end, 5000, 1)
            
            return true
        end
    end
end

function setNewOwnerVehicle(vehicle, target, type) -- owner id gracza lub grupa. czyli target to Element i przy grupie to moze byc po prostu ID grupy.
    local typeTarget = tonumber(type)

    if typeTarget == 1 then -- nowy wlasciciel gracz
        local characterID = exports.rp_login:getPlayerData(target, "characterID")
        local data = vehicles[vehicle]
        changeVehicleStatistics(data, "owner", characterID)
        changeVehicleStatistics(data, "owner_type", typeTarget)
        local actualData = vehicles[vehicle]
        local id = vehicleID[vehicle]
        exports.rp_db:query("UPDATE vehicles set data = ?, owner = ? WHERE id = ?", toJSON(actualData), characterID, id)
    elseif typeTarget == 2 then -- przydzielanie pojazdu do  grupy
        local data = vehicles[vehicle]
        changeVehicleStatistics(data, "owner", target)
        changeVehicleStatistics(data, "owner_type", typeTarget)
        local actualData = vehicles[vehicle]
        local id = vehicleID[vehicle]
        exports.rp_db:query("UPDATE vehicles set data = ?, owner = ? WHERE id = ?", toJSON(actualData), target, id)
    end
end

function onPlayerVehicleRegister(id)
        local playerVehicles = getPlayerVehicles(client)
        local found = false
        for k, v in pairs(playerVehicles) do
            local vehID = getVehicleData(v, "uid")
            if tonumber(vehID) == tonumber(id) then
                found = true
                break
            end
        end
        
        if not found then
            return 
        end
		
		local veh = vehiclesID[tonumber(id)]
		if not veh then return exports.rp_library:createBox(client,"Pojazd musi byc zespawnowany, aby go zarejestrować.") end
		local plate = getVehiclePlateText(veh)
		if plate ~= "BRAK" then return exports.rp_library:createBox(client,"Ten pojazd jest już zarejestrowany.") end
		local bought = exports.rp_atm:takePlayerCustomMoney(client, 100) 
		if not bought then return exports.rp_library:createBox(client,"Nie posiadasz wystarczającej gotówki aby zarejestrować pojazd (100$).") end
		local newPlate = generateLicensePlate("California", id)--exports.rp_utils:toHex(id+999999)
		setVehiclePlateText(veh, newPlate)
		local data = vehicles[veh]
        changeVehicleStatistics(data, "plate", newPlate)
		exports.rp_library:createBox(client,"Pomyślnie zarejestrowałeś pojazd za 100$.")
		saveVehicle(veh)

		
		
end
addEvent("onPlayerVehicleRegister", true)
addEventHandler("onPlayerVehicleRegister", root, onPlayerVehicleRegister)


function onVehicleCheck(vehicle)
	-- local veh = getPedOccupiedVehicle(client)
	-- if veh ~= vehicle then return end
    local data = vehicles[vehicle]
    if data then
        local damage = getVehicleData(data, "damage")

        updateVehicleDoorStates(vehicle, damage)
        updateVehiclePanelStates(vehicle, damage)
    end
end
addEvent("onVehicleCheckDamage", true)
addEventHandler("onVehicleCheckDamage", root, onVehicleCheck)


function isVehicleEmpty( vehicle )
	if not isElement( vehicle ) or getElementType( vehicle ) ~= "vehicle" then
		return true
	end
	return not (next(getVehicleOccupants(vehicle)) and true or false)
end

function spawnGroupVehicle(player, vehicleIDGroup, groupID)
    local isInGroup = exports.rp_groups:isPlayerInGroup(player, groupID)
    if not isInGroup then
        return
    end
	local hasPerm = exports.rp_groups:hasPermInCurrentGroup(player, groupID, "vehicleAccess")
	if not hasPerm then return exports.rp_library:createBox(player, "Nie posiadasz uprawnień do spawnowania pojazdów") end
	if not exports.rp_utils:checkPassiveTimer("spawnVehicle", player, 1000) then return exports.rp_library:createBox(player,"Poczekaj chwilę nad ponownym przycisnięciem.") end
	local getVehicle = getVehByID(tonumber(vehicleIDGroup))
	if getVehicle then
		if not isVehicleEmpty(getVehicle) then return exports.rp_library:createBox(client,"W pojezdzie są osoby.") end
        saveVehicle(getVehicle)
        destroyVehicleData(getVehicle)
        if isElement(getVehicle) then 
            destroyElement(getVehicle)
			exports.rp_library:createBox(client,"Pojazd został odspawnowany.")
        end
    else
	local veh = exports.rp_db:query("SELECT * FROM vehicles WHERE id = ?", vehicleIDGroup)
        if veh and veh[1] then
            local data = fromJSON(veh[1].data)
            local model = getVehicleData(data, "model")
            local x, y, z = getVehicleData(data, "x"), getVehicleData(data, "y"), getVehicleData(data, "z")
            local rotation = getVehicleData(data, "rotation")
            local damage = getVehicleData(data, "damage")
            local plate = getVehicleData(data, "plate")
            local color = getVehicleData(data, "color")
			local tuning = getVehicleData(data, "tuning")
            local hp = getVehicleData(data, "hp")
            local vehicle = exports.rp_newmodels:createVehicle(model, x, y, z, rotation[1], rotation[2], rotation[3], "BRAK")--exports.rp_newmodels:createTestElement(player, "vehicle", model, x, y, z, rotation[1], rotation[2], rotation[3])
            data.uid = veh[1].id 
            setVehicleDamageProof(vehicle, true)
            vehicles[vehicle] = data
            vehiclesID[tonumber(veh[1].id)] = vehicle
            vehicleID[vehicle] = tonumber(veh[1].id)
           			local highestTraction = 0
            for k,v in pairs(tuning) do 
				local dataTuneEngine = tuneTable[tonumber(v)]
				if dataTuneEngine then
					local acceleration = getVehicleHandling(vehicle,"engineAcceleration")
					local maxVelocity = getVehicleHandling(vehicle,"maxVelocity")
					local traction = getVehicleHandling(vehicle,"tractionMultiplier")
					if dataTuneEngine.traction > highestTraction then
						highestTraction = dataTuneEngine.traction
					end
					setVehicleHandling(vehicle, "engineAcceleration", acceleration + dataTuneEngine.engineAcceleration)
					setVehicleHandling(vehicle, "maxVelocity", maxVelocity + dataTuneEngine.maxVelocity)
					else
					addVehicleUpgrade(vehicle, tonumber(v))
				end
			end
			local traction = getVehicleHandling(vehicle, "tractionMultiplier")
			local newTraction = traction + highestTraction
			setVehicleHandling(vehicle, "tractionMultiplier", math.min(newTraction, 1.2))
            setVehicleWheelStates(vehicle, damage.wheel1, damage.wheel2, damage.wheel3, damage.wheel4)
            updateVehicleDoorStates(vehicle, damage)
            updateVehiclePanelStates(vehicle, damage)
            setVehiclePlateText(vehicle, plate)
            setVehicleColor(vehicle, color[1], color[2], color[3], color[4], color[5], color[6], color[7], color[8], color[9], color[10], color[11], color[12])
			setVehicleHeadLightColor(vehicle, color[13], color[14], color[15])
            setVehicleLocked(vehicle, true)
			vehicleEngineState[vehicle] = false
			local vehicleType = getVehicleType(vehicle)
			if vehicleType == "Bike" or vehicleType == "BMX" then
				vehicleEngineState[vehicle] = true
				setVehicleEngineState(vehicle, true)
			end
            
            if hp <= 350 then
                setElementHealth(vehicle, 350)
            else
                setElementHealth(vehicle, hp)
            end
			setNewSyncer(vehicle, player, false)
            setTimer(function()
                if isElement(vehicle) then 
                    setVehicleDamageProof(vehicle, false)
					setElementFrozen(vehicle, true)
                end
            end, 5000, 1)
			exports.rp_library:createBox(client,"Pojazd został zespawnowany.")
            
        end
		end
	
end

function spawnVehicleG(id) -- todo tuning, widok tuningu i staty do pojazdu
	if not exports.rp_utils:checkPassiveTimer("spawnVehicle", client, 1000) then return exports.rp_library:createBox(client,"Poczekaj chwilę nad ponownym przycisnięciem.") end
    if not tonumber(id) then return end
    local getVehicle = getVehByID(tonumber(id))
        local playerVehicles = getPlayerVehicles(client)
        local found = false

        for k, v in pairs(playerVehicles) do
            local vehID = getVehicleData(v, "uid")
            if tonumber(vehID) == tonumber(id) then
                found = true
                break
            end
        end
        
        if not found then
            return exports.rp_anticheat:banPlayerAC(client, "Manipulate Event", "onPlayerSpawnVehicle")
        end
    if getVehicle then
		if not isVehicleEmpty(getVehicle) then return exports.rp_library:createBox(client,"W pojezdzie są osoby.") end
        saveVehicle(getVehicle)
        destroyVehicleData(getVehicle)
        if isElement(getVehicle) then 
            destroyElement(getVehicle)
			exports.rp_library:createBox(client,"Pojazd został odspawnowany.")
        end
    else

        
        local veh = exports.rp_db:query("SELECT * FROM vehicles WHERE id = ?", id)
        if veh and veh[1] then
            local data = fromJSON(veh[1].data)
            local model = getVehicleData(data, "model")
            local x, y, z = getVehicleData(data, "x"), getVehicleData(data, "y"), getVehicleData(data, "z")
			local tuning = getVehicleData(data, "tuning")
			local updatePosition = false
			if x == 0 and y == 0 and z == 0.5 then
				x, y, z = exports.rp_utils:getXYInFrontOfPlayer(client, 3)
				updatePosition = true
			end
            local rotation = getVehicleData(data, "rotation")
            local damage = getVehicleData(data, "damage")
            local plate = getVehicleData(data, "plate")
            local color = getVehicleData(data, "color")
            local hp = getVehicleData(data, "hp")
            local vehicle = exports.rp_newmodels:createVehicle(model, x, y, z, rotation[1], rotation[2], rotation[3], "BRAK")--exports.rp_newmodels:createTestElement(player, "vehicle", model, x, y, z, rotation[1], rotation[2], rotation[3])
            data.uid = veh[1].id 
            setVehicleDamageProof(vehicle, true)
            vehicles[vehicle] = data
            vehiclesID[tonumber(veh[1].id)] = vehicle
            vehicleID[vehicle] = tonumber(veh[1].id)
			if updatePosition then
				changeVehicleCurrentStatistics(vehicle, "x", x)
				changeVehicleCurrentStatistics(vehicle, "y", y)
				changeVehicleCurrentStatistics(vehicle, "z", z)
			end
            local highestTraction = 0
            for k,v in pairs(tuning) do 
				local dataTuneEngine = tuneTable[tonumber(v)]
				if dataTuneEngine then
					local acceleration = getVehicleHandling(vehicle,"engineAcceleration")
					local maxVelocity = getVehicleHandling(vehicle,"maxVelocity")
					local traction = getVehicleHandling(vehicle,"tractionMultiplier")
					if dataTuneEngine.traction > highestTraction then
						highestTraction = dataTuneEngine.traction
					end
					setVehicleHandling(vehicle, "engineAcceleration", acceleration + dataTuneEngine.engineAcceleration)
					setVehicleHandling(vehicle, "maxVelocity", maxVelocity + dataTuneEngine.maxVelocity)
					else
					addVehicleUpgrade(vehicle, tonumber(v))
				end
			end
			local traction = getVehicleHandling(vehicle, "tractionMultiplier")
			local newTraction = traction + highestTraction
			setVehicleHandling(vehicle, "tractionMultiplier", math.min(newTraction, 1.2))
            setVehicleWheelStates(vehicle, damage.wheel1, damage.wheel2, damage.wheel3, damage.wheel4)
            updateVehicleDoorStates(vehicle, damage)
            updateVehiclePanelStates(vehicle, damage)
            setVehiclePlateText(vehicle, plate)
            setVehicleColor(vehicle, color[1], color[2], color[3], color[4], color[5], color[6], color[7], color[8], color[9], color[10], color[11], color[12])
			setVehicleHeadLightColor(vehicle, color[13], color[14], color[15])
            setVehicleLocked(vehicle, true)
            vehicleEngineState[vehicle] = false
			local vehicleType = getVehicleType(vehicle)
			if vehicleType == "Bike" or vehicleType == "BMX" then
				vehicleEngineState[vehicle] = true
				setVehicleEngineState(vehicle, true)
			end
            
            if hp <= 350 then
                setElementHealth(vehicle, 350)
            else
                setElementHealth(vehicle, hp)
            end
			setNewSyncer(vehicle, player, false)
            setTimer(function()
                if isElement(vehicle) then 
                    setVehicleDamageProof(vehicle, false)
					setElementFrozen(vehicle, true)
                end
            end, 5000, 1)
			exports.rp_library:createBox(client,"Pojazd został zespawnowany.")
            
        end
    end
end
addEvent ( "onPlayerSpawnVehicle", true )
addEventHandler ( "onPlayerSpawnVehicle", getRootElement(), spawnVehicleG )


function givePlayerKeysToVehicle(playerID, vehicleID)
    if not exports.rp_utils:checkPassiveTimer("giveTempKeys", client, 1000) then
        return exports.rp_library:createBox(client, "Poczekaj chwilę nad ponownym przycisnięciem.")
    end
    local target = exports.rp_login:findPlayerByID(playerID)
    if not target then
        return exports.rp_library:createBox(client, "Nie ma gracza o podanym ID.")
    end
    local playerVehicles = getPlayerVehicles(client)
    local found = false

    for k, v in pairs(playerVehicles) do
        local vehID = getVehicleData(v, "uid")
        if tonumber(vehID) == tonumber(vehicleID) then
            found = true
            break
        end
    end

    if not found then
        return exports.rp_anticheat:banPlayerAC(client, "Manipulate Event", "onPlayerGiveTempKeys")
    end
    local reason = giveTempKeys(target, vehicleID)
	local fullName = exports.rp_utils:getPlayerICName(target)
    if reason == "deletedKey" then
        exports.rp_library:createBox(client, "Nie udostępniasz już graczowi pojazdu.")
    else
        exports.rp_library:createBox(client, "Udostępniłeś "..fullName.." pojazd.")
    end
end

addEvent("onPlayerGiveTempKeys", true)
addEventHandler("onPlayerGiveTempKeys", root, givePlayerKeysToVehicle)


function updateDamageCar(vehicle, loss, fixedByAdmin)
    local data = vehicles[vehicle]
    local damage = getVehicleData(data, "damage")

    for part, _ in pairs(damage) do
        if string.match(part, "door") then
            local doorConverted = convertedDoors[part]
            damage[part] = getVehicleDoorState(vehicle, doorConverted)
        elseif string.match(part, "panel") then
            local panelConverted = convertedPanels[part]
            damage[part] = getVehiclePanelState(vehicle, panelConverted)
        elseif string.match(part, "wheel") then
            local wheelStates = {getVehicleWheelStates(vehicle)}
            local wheelIndex = tonumber(string.match(part, "%d+"))
            damage[part] = wheelStates[wheelIndex]
        end
    end
    changeVehicleStatistics(data, "damage", damage)
    if loss then
		local calc = getElementHealth(vehicle) - loss
		
        if calc <= 350 then
            setElementHealth(vehicle, 350)
            local driver = getVehicleOccupant(vehicle, 0)
            exports.rp_library:createBox(driver, "Silnik jest uszkodzony.")
            setVehicleEngineState(vehicle, false)
        end
        changeVehicleStatistics(data, "hp", getElementHealth(vehicle) - loss)
    end

    if fixedByAdmin then
        changeVehicleStatistics(data, "hp", 1000)
    end
end


function destroyVehicleData(vehicle)
		local vehID = vehicleID[vehicle]
		vehicles[vehicle] = nil
        vehiclesID[vehID] = nil
		vehicleID[vehicle] = nil
		vehicleEngineState[vehicle] = nil
end

function saveVehicle(vehicle)
    local data = vehicles[vehicle]
    if data then
        local id = vehicleID[vehicle]
        exports.rp_db:query("UPDATE vehicles set data = ? WHERE id = ?", toJSON(data), id)
    end
end

function onVehicleHandBrake(vehicle, state)
    if not isElement(vehicle) then
        return
    end
    local driver = getVehicleOccupant(vehicle, 0)
    local vehUsing = getPedOccupiedVehicle(client)
    if not driver or not vehUsing then
        return
    end
    if driver ~= client then
        return 
    end
    if vehUsing ~= vehicle then
        return
    end
    setElementFrozen(vehicle, state)
end
addEvent("onVehicleSetHandbrake", true)
addEventHandler("onVehicleSetHandbrake", root, onVehicleHandBrake)


function getNearestElement(player, type, distance)
    local result = false
    local dist = nil
    if player and isElement(player) then
        local elements = getElementsWithinRange(Vector3(getElementPosition(player)), distance, type, getElementInterior(player), getElementDimension(player))
        for i = 1, #elements do
            local element = elements[i]
            if not dist then
                result = element
                dist = getDistanceBetweenPoints3D(Vector3(getElementPosition(player)), Vector3(getElementPosition(element)))
            else
                local newDist = getDistanceBetweenPoints3D(Vector3(getElementPosition(player)), Vector3(getElementPosition(element)))
                if newDist <= dist then
                    result = element
                    dist = newDist
                end
            end
        end
    end
    return result
end


function greetPlayer ( )
	bindKey ( source, "K", "down", enableEngine)
	bindKey ( source, "L", "down", enableLights)
	bindKey (source, "[", "down", enableIndicator, "left")
	bindKey (source, "]", "down", enableIndicator, "right")
	bindKey (source, ";", "down", enableIndicator, ";")

	

end
addEventHandler ( "onPlayerJoin", root, greetPlayer )


function testcmdd(player,cmd)
local vehicle = getNearestElement(player, "vehicle", 5)
exports.rp_login:setObjectData(vehicle,"desc", "testowy opis")

end
-- addCommandHandler("setobj", testcmdd, false, false)

function onResRestart(res)
    if res == getThisResource() then
        local vehicles = getElementsByType("vehicle")
        local players = getElementsByType("player")
        for k, v in pairs(players) do
            bindKey(v, "K", "down", enableEngine)
            bindKey(v, "L", "down", enableLights)
			bindKey (v, "[", "down", enableIndicator, "left")
			bindKey (v, "]", "down", enableIndicator, "right")
			bindKey (v, ";", "down", enableIndicator, ";")

        end
        for k, v in pairs(vehicles) do
            if isElement(v) then
                saveVehicle(v)
                destroyElement(v)
            end
        end
    end
end
addEventHandler("onResourceStart", root, onResRestart)


addEventHandler("onResourceStop",root,function(resource)
        if resource == getThisResource() then
            local vehicles = getElementsByType("vehicle")

            for k, v in pairs(vehicles) do
                saveVehicle(v)
                destroyElement(v)
            end
        end
    end
)


addEventHandler("onPlayerQuit", root,
	function(quitType)
	if playerTemporaryKeys[source] then playerTemporaryKeys[source] = nil end
	end
)
function generateLicensePlate(state, vehicleUID)
    local plate = ""
    local randomChar = function()
        return string.char(math.random(65, 90))
    end
    
    local randomDigit = function()
        return math.random(0, 9)
    end

    local uidToString = function(uid)
        return string.format("%x", uid)  
    end

    local baseUID = uidToString(vehicleUID)

 
    local statePrefix = ""
    if state == "California" then
        statePrefix = "CA"
        plate = statePrefix .. "-" .. randomChar() .. randomChar() .. randomChar() .. baseUID:sub(1, 4)
    elseif state == "New York" then
        statePrefix = "NY"
        plate = statePrefix .. "-" .. randomChar() .. randomChar() .. randomChar() .. baseUID:sub(1, 4)
    elseif state == "Texas" then
        statePrefix = "TX"
        plate = statePrefix .. "-" .. randomChar() .. randomChar() .. randomChar() .. baseUID:sub(1, 3)
    elseif state == "Florida" then
        statePrefix = "FL"
        plate = statePrefix .. "-" .. randomChar() .. randomChar() .. randomChar()
        local digitsCount = math.random(3, 4)
        for i = 1, digitsCount do
            plate = plate .. baseUID:sub(i, i)
        end
    elseif state == "Illinois" then
        statePrefix = "IL"
        plate = statePrefix .. "-" .. randomChar() .. baseUID:sub(1, 1) .. baseUID:sub(2, 4) .. randomChar() .. randomChar() .. baseUID:sub(5, 5)
    end

    return plate
end

-- tune
local vehicleUpgrades = {[1000] = 500}
local function vehicleTuneUpgradesPrices(id)
	if vehicleUpgrades[id] then return vehicleUpgrades[id] end
	return 100
end
function getVehicleCompatibleUpgradesForTune(vehicle)
	local upgrades = getVehicleCompatibleUpgrades(vehicle)
	local tmpTable = {}
	for upgradeKey, upgradeValue in ipairs(upgrades) do
		table.insert(tmpTable, {name=getVehicleUpgradeSlotName(upgradeValue).." ("..upgradeValue..")", id = upgradeValue, price = vehicleTuneUpgradesPrices(id)})
	end
	table.insert(tmpTable,{name="Tuning Silnik 1", id = 8001, price = 1000})
	table.insert(tmpTable,{name="Tuning Silnik 2", id = 8002, price = 2000})
	table.insert(tmpTable,{name="Tuning Silnik 3", id = 8003, price = 3000})

	return tmpTable
end

local markersTunePositions = {
[1] = {2073.5146484375,-1831.6162109375,13.546875},
-- [2] = {},
}



local function loadTuneMarkers()
    for k, v in pairs(markersTunePositions) do
        local blip = createBlip(v[1], v[2], v[3], 27, 2, 255, 0, 0, 255, 0, 300)
        local marker = createMarker(v[1], v[2], v[3]-0.9, "cylinder", 2, 255, 0, 0, 0)--createColSphere(v[1], v[2], v[3], 10)
		exports.rp_login:setObjectData(marker, "3DText", "Tuning pojazdu")
        setElementParent(marker, tuneMarkersElements)
    end
end

loadTuneMarkers()


function tuneMarkerHit(hitElement, matchinDimension)
    if getElementType(hitElement) == "player" then
        if matchinDimension then	
			local vehicle = getPedOccupiedVehicle(hitElement)
			if not vehicle then return end
            if not isPlayerInTune[hitElement] then
                isPlayerInTune[hitElement] = true
            end
        end
    end
end

addEventHandler("onMarkerHit", tuneMarkersElements, tuneMarkerHit)

function tuneMarkerLeave(hitElement, matchingDimension)
    if getElementType(hitElement) == "player" then
        if matchingDimension then
            isPlayerInTune[hitElement] = nil
        end
    end
end
addEventHandler("onMarkerLeave", tuneMarkersElements, tuneMarkerLeave)

function saveOriginalVehicleData()
	local player = client
    local veh = getPedOccupiedVehicle(player)
    if not veh then return end

    local color = {getVehicleColor(veh, true)}
    local lights = {getVehicleHeadLightColor(veh)}
    local data = {
        color = color,
        lights = lights,
        upgrades = {},
    }

    for slot = 0, 16 do
        local upgrade = getVehicleUpgradeOnSlot(veh, slot)
        if upgrade then
            table.insert(data.upgrades, upgrade)
        end
    end

    exports.rp_login:setObjectData(veh, "preview:originalData", data, true)
end
addEvent("onPlayerEnterPreviewMode", true)
addEventHandler("onPlayerEnterPreviewMode", getRootElement(), saveOriginalVehicleData)


function onPlayerChangeVehicleColorr(r, g, b, headlights, wheelColor)
    local veh = getPedOccupiedVehicle(client)
    if not veh then return end

    r, g, b = tonumber(r), tonumber(g), tonumber(b)
    if not r or not g or not b then return end

    local bought = exports.rp_atm:takePlayerCustomMoney(client, 100)
    if not bought then
        return exports.rp_library:createBox(client, "Nie posiadasz wystarczająco pieniędzy, aby dokonać zmiany. (100$)")
    end

    local data = getVehicleCurrentData(veh, "color") or {255, 255, 255, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255}

    if wheelColor then
        data[7], data[8], data[9] = r, g, b
        setVehicleColor(veh, unpack(data))
        changeVehicleCurrentStatistics(veh, "color", data)
        exports.rp_library:createBox(client, "Zakupiłeś zmianę koloru felg.")
    elseif headlights then
        setVehicleHeadLightColor(veh, r, g, b)
        data[13], data[14], data[15] = r, g, b
        changeVehicleCurrentStatistics(veh, "color", data)
        exports.rp_library:createBox(client, "Zakupiłeś zmianę koloru świateł.")
    else
        data[1], data[2], data[3] = r, g, b
        setVehicleColor(veh, unpack(data))
        changeVehicleCurrentStatistics(veh, "color", data)
        exports.rp_library:createBox(client, "Zakupiłeś zmianę koloru pojazdu.")
    end
	saveOriginalVehicleData(client)
end
addEvent("onPlayerChangeVehicleColor", true)
addEventHandler("onPlayerChangeVehicleColor", getRootElement(), onPlayerChangeVehicleColorr)

function restoreOriginalVehicleData()
	local player = client

    local veh = getPedOccupiedVehicle(player)
    if not veh then return end

    local data = exports.rp_login:getObjectData(veh,"preview:originalData")
    if not data then return end

    setVehicleColor(veh, unpack(data.color))
    setVehicleHeadLightColor(veh, unpack(data.lights))

    -- usuń wszystkie upgrade’y
    for slot = 0, 16 do
        local upgrade = getVehicleUpgradeOnSlot(veh, slot)
        if upgrade then
            removeVehicleUpgrade(veh, upgrade)
        end
    end

    -- załaduj zapisane upgrade’y
    for _, upgrade in ipairs(data.upgrades) do
        addVehicleUpgrade(veh, upgrade)
    end

    exports.rp_login:setObjectData(veh,"preview:originalData", false)
	setElementPosition(veh, 2077.1181640625,-1830.83203125,13.3828125)
	setElementDimension(veh, 0)
	setElementDimension(player, 0)
	setElementFrozen(veh, false)
	isPlayerInTune[player] = nil

end
addEvent("onPlayerCancelPreview", true)
addEventHandler("onPlayerCancelPreview", getRootElement(), restoreOriginalVehicleData)

function onPlayerTuneVehicle(mod)
    local veh = getPedOccupiedVehicle(client)
    if not veh then return end

    local currentUpgrades = getVehicleUpgrades(veh)
    for _, upgrade in ipairs(currentUpgrades) do
        if upgrade == tonumber(mod) then
            return exports.rp_library:createBox(client, "Pojazd posiada już tę modyfikację.")
        end
    end

	local vehicleTuning = getVehicleCurrentData(veh, "tuning")
	for k,v in ipairs(vehicleTuning) do
		if v == tonumber(mod) then
			return exports.rp_library:createBox(client, "Pojazd posiada już tę modyfikację.")
		end
	end
    local price = vehicleTuneUpgradesPrices(tonumber(mod))
    local bought = exports.rp_atm:takePlayerCustomMoney(client, price)
    if not bought then
        return exports.rp_library:createBox(client, "Nie posiadasz wystarczająco pieniędzy, aby zakupić modyfikację.")
    end

    exports.rp_library:createBox(client,"Zakupiłeś modyfikację.")
    addVehicleUpgrade(veh, mod)
	local tmpTable = {}
	tmpTable = vehicleTuning
	for k,v in pairs(tmpTable) do -- mozna dodac, ze np mod o id 9999 to tuning silnika, handling itd
		if v == mod then
			table.remove(tmpTable, k) 
		end
	end
	table.insert(tmpTable, mod)
	changeVehicleCurrentStatistics(veh, "tuning", tmpTable)
    saveOriginalVehicleData(client) -- dopdanie do daty tuning, oraz przy spawnie dawanie te rzeczy.
	triggerClientEvent(client, "onPlayerBoughtMod", client, mod)
	
end

addEvent("onPlayerTuneVehicle", true)
addEventHandler("onPlayerTuneVehicle", getRootElement(), onPlayerTuneVehicle)

function onPlayerRepairVehicle()
    local veh = getPedOccupiedVehicle(client)
	if not veh or not isPlayerInTune[client] then return end
    local price = exports.rp_groups:calculateVehicleRepairCost(veh)
    if price.totalCost < 1 then
        return exports.rp_library:createBox(client, "Pojazd nie wymaga naprawy.")
    end
    exports.rp_offers:sendOffer(client, client, 7, veh, price.totalCost, "Naprawa pojazdu")
end
addEvent("onPlayerRepairVehicle", true)
addEventHandler("onPlayerRepairVehicle", getRootElement(), onPlayerRepairVehicle)



-- addCommandHandler( 'random_color',
	-- function( uPlayer )
		-- if isPedInVehicle( uPlayer ) then
			-- local uVehicle = getPedOccupiedVehicle( uPlayer )
			-- if uVehicle then
				-- local r, g, b = math.random( 255 ), math.random( 255 ), math.random( 255 )
				-- addVehicleUpgrade(uVehicle, 1096)
				-- setVehicleColor( uVehicle, r, g, b, 0, 0, 0, r, g, b, 0,0,0 ) -- 7, 8, 9 to kolory felg!
			-- end
		-- end
	-- end
-- )


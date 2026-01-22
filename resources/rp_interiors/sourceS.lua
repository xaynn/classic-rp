local interiors = {} -- mozna niby loopowac...
local interiorsByUIDAndPickups = {}
local playerInPickup = {}
local pickupTypes = {
[1] = 1273, -- dom kupiony
[2] = 1272, -- dom do kupna
[3] = 1239, -- urzad
[4] = 1275, -- binco, ciuchy

}

function loadInteriors()
    for k, v in pairs(exports.rp_db:query("SELECT * FROM interiors")) do
        local pickup = createPickup(v.x, v.y, v.z, 3, pickupTypes[v.type]) --v.type == 0 and 1273 or v.type == 3 and 1272 or v.type == 4 and 1275 or 1239
        local exitpickup = createPickup(v.intx, v.inty, v.intz, 3, 1239)
        setElementDimension(pickup, v.dimensionwithin)
        setElementInterior(pickup, v.interiorwithin)
        setElementInterior(exitpickup, v.interior)
        setElementDimension(exitpickup, v.id)
        interiors[pickup] = v
        interiors[exitpickup] = {
            id = v.id,
            intx = v.intx,
            inty = v.inty,
            intz = v.intz,
            owner = v.owner,
            garage = v.garage,
            enterPickup = pickup
        }
        interiors[pickup].exitPickup = exitpickup
        interiors[pickup].objectData = fromJSON(v.objectData)
        if v.type ~= 3 then
            interiors[pickup].locked = true
            interiors[exitpickup].locked = true
        end
        interiorsByUIDAndPickups[v.id] = {pickup, exitpickup}
    end
end

function hasPlayerPerm(player, pickup)
    if isElement(pickup) then
        local owner = interiors[pickup].owner
        local characterID = exports.rp_login:getPlayerData(player, "characterID")
		local duty = exports.rp_login:getPlayerData(player,"groupDuty")
        if owner == characterID then
            return true
        end
		if exports.rp_admin:hasAdminPerm(player,"creatingInteriors") then 
			return true
		end
		if duty and duty[5] == owner then
			return true
		end
    end
    return false
end

function changeInteriorDoorState(player, pickup)
    if hasPlayerPerm(player, pickup) or exports.rp_admin:hasAdminPerm(player, "openInteriors") then
        local interiorData = interiors[pickup]
        local exitMarker = interiorData.enterPickup or interiorData.exitPickup

        local newState = not interiorData.locked
        interiorData.locked = newState
        if exitMarker then
            interiors[exitMarker].locked = newState
        end
        local sex = exports.rp_login:getPlayerGender(player)
        local action
        if sex == "male" then
            action = newState and "zamknął" or "otworzył"
        else
            action = newState and "zamknęła" or "otworzyła"
        end

        exports.rp_nicknames:amePlayer(player, string.format("%s drzwi.", action))
        setPedAnimation(player, "int_house", "wash_up", 500, false, true, false, false)
    end
end

function getPlayersInInterior(id)
    local data = interiorsByUIDAndPickups[id]
    if not data then
        return false
    end
    local dim = getElementDimension(data[2])
    local interior = getElementInterior(data[2])
    local players = getElementsInDimension("player", dim, interior)
    return players or {}
end

function cmdC(player, cmand)
local x,y,z = getElementPosition(player)
for i = 1, 174 do
createIntByCMD(player, x,y+i,z,"Test "..i, 1, i)
end

end
-- addCommandHandler("debugxd",cmdC, false, false)


function createIntByCMD(player,x,y,z,name,type, intID)
local target = exports.rp_login:findPlayerByID(tonumber(owner))
    local owner

	local queryItem = exports.rp_db:query("SELECT id FROM interiors ORDER BY id DESC LIMIT 1")
    local interiorID = 1
    if queryItem and queryItem[1] then
        interiorID = queryItem[1].id + 1
    end
    local dimension = getElementDimension(player)
    local interiorwithin = getElementInterior(player)
    local interiorInt = interiorsTable[tonumber(intID)]
	local price = interiorPrice
	if not price or not tonumber(price) then price = 0 end
	local interiorName = name
	local interiorType = 1 
	local interiorDesc = "test"
	

	
	 if interiorInt then
        local ix = interiorInt[2]
        local iy = interiorInt[3]
        local iz = interiorInt[4]
        local optAngle = interiorInt[5]
        local interiorw = interiorInt[1]
        local angleexit = getPedRotation(player)

        local pickup = createPickup(x, y, z, 3, pickupTypes[interiorType])
        interiors[pickup] = {
            id = interiorID,
            name = interiorName,
            type = interiorType,
            x = x,
            y = y,
            z = z,
            owner = 1,
            interior = interiorw,
            intx = ix,
            inty = iy,
            intz = iz,
            dimensionwithin = dimension,
            interiorwithin = interiorwithin,
            angle = optAngle,
            angleexit = angleexit,
			description = interiorDesc,
			objects = 0,
			price = price,
			garage = interiorGarage,
        }
        -- interiors[pickup] = data
        local exitpickup = createPickup(ix, iy, iz, 3, 1239)
        interiors[exitpickup] = {
            id = interiorID,
            intx = ix,
            inty = inty,
            intz = intz,
			garage = interiorGarage,
            enterPickup = pickup
        }
        interiors[pickup].exitPickup = exitpickup

        interiorsByUIDAndPickups[interiorID] = {pickup, exitpickup}

        setElementDimension(pickup, dimension)
        setElementInterior(pickup, interiorwithin)
        setElementInterior(exitpickup, interiorw)
        setElementDimension(exitpickup, interiorID)
        -- v.locked = true
        local res = exports.rp_db:query_free("INSERT INTO interiors (id, name, type, x, y, z, owner, interior, intx, inty, intz, dimensionwithin, interiorwithin, angle, angleexit, description, objects, price) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",interiorID,interiorName,interiorType,x,y,z,1,interiorw,ix,iy,iz,dimension,interiorwithin,optAngle,angleexit,interiorDesc, 0, price)
    end
end

function deleteProperty(player, pickup)
    local interiorData = interiors[pickup]
    local id = interiorData.id
    local markers = interiorsByUIDAndPickups[id]
    local dim = getElementDimension(markers[2])
    local interior = getElementInterior(markers[2])
    local dimTP = getElementDimension(markers[1])
    local interiorTP = getElementInterior(markers[1])
    local x, y, z = getElementPosition(markers[1])
    local players = getPlayersInInterior(id)

    if isElement(markers[1]) then
        destroyElement(markers[1])
        destroyElement(markers[2])
    end

    exports.rp_db:query_free("DELETE FROM interiors WHERE id = ?", id)
    interiors[markers[1]] = nil
    interiors[markers[2]] = nil
    triggerClientEvent(player, "onPlayerShowInterior", player, _, _, _, _, false)
	interiorsByUIDAndPickups[id] = nil
    for k, v in pairs(players) do
        setElementPosition(v, x, y, z)
        setElementDimension(v, dimTP)
        setElementInterior(v, interiorTP)
        exports.rp_library:createBox(v, "Interior w którym byłeś, został usunięty.")
    end
    exports.rp_library:createBox(player, "Interior został usunięty.")
end

function flashbangInterior(pickup)
    local id = interiors[pickup].id
    local marker = interiorsByUIDAndPickups[id]
    if marker[1] == pickup then
        local players = getPlayersInInterior(id)
		for k,v in pairs(players) do
			triggerClientEvent(v, "onPlayerGotFlashed", v)
		end
    end
end
function createInteriorByGui(interiorName, interiorType, interiorDesc, intID, owner, interiorPrice, interiorGarage)
    if not exports.rp_admin:hasAdminPerm(client, "creatingInteriors") then
        return
    end
	if not interiorName or not interiorType or not interiorDesc or not intID or not owner or not interiorGarage then return exports.rp_library:createBox(client,"Nie podano wszystkich argumentów") end
	local target = exports.rp_login:findPlayerByID(tonumber(owner))
    if target then
        owner = exports.rp_login:getPlayerData(target, "characterID")
    else
        owner = owner
    end
	local queryItem = exports.rp_db:query("SELECT id FROM interiors ORDER BY id DESC LIMIT 1")
    local interiorID = 1
    if queryItem and queryItem[1] then
        interiorID = queryItem[1].id + 1
    end
	local x, y, z = getElementPosition(client)
    local dimension = getElementDimension(client)
    local interiorwithin = getElementInterior(client)
    local interiorInt = interiorsTable[tonumber(intID)]
	local price = interiorPrice
	if not price or not tonumber(price) then price = 0 end
	if interiorType == 2 then
		owner = -1
	end
	if interiorType ~= 2 then
		price = 0
	end
	 if interiorInt then
        local ix = interiorInt[2]
        local iy = interiorInt[3]
        local iz = interiorInt[4]
        local optAngle = interiorInt[5]
        local interiorw = interiorInt[1]
        local angleexit = getPedRotation(client)

        local pickup = createPickup(x, y, z, 3, pickupTypes[interiorType])
        interiors[pickup] = {
            id = interiorID,
            name = interiorName,
            type = interiorType,
            x = x,
            y = y,
            z = z,
            owner = owner,
            interior = interiorw,
            intx = ix,
            inty = iy,
            intz = iz,
            dimensionwithin = dimension,
            interiorwithin = interiorwithin,
            angle = optAngle,
            angleexit = angleexit,
			description = interiorDesc,
			objects = 0,
			price = price,
			garage = interiorGarage,
        }
        -- interiors[pickup] = data
        local exitpickup = createPickup(ix, iy, iz, 3, 1239)
        interiors[exitpickup] = {
            id = interiorID,
            intx = ix,
            inty = inty,
            intz = intz,
			garage = interiorGarage,
            enterPickup = pickup
        }
        interiors[pickup].exitPickup = exitpickup

        interiorsByUIDAndPickups[interiorID] = {pickup, exitpickup}

        setElementDimension(pickup, dimension)
        setElementInterior(pickup, interiorwithin)
        setElementInterior(exitpickup, interiorw)
        setElementDimension(exitpickup, interiorID)
        -- v.locked = true
        local res = exports.rp_db:query_free("INSERT INTO interiors (id, name, type, x, y, z, owner, interior, intx, inty, intz, dimensionwithin, interiorwithin, angle, angleexit, description, objects, price, garage) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",interiorID,interiorName,interiorType,x,y,z,owner,interiorw,ix,iy,iz,dimension,interiorwithin,optAngle,angleexit,interiorDesc, 0, price, interiorGarage)
    end
	
end
addEvent("onPlayerCreateInterior", true)
addEventHandler("onPlayerCreateInterior", root, createInteriorByGui)


function onPlayerEditInterior(name, descInt, owner, garage)
	if not exports.rp_utils:checkPassiveTimer("editInterior", client, 2000) then return exports.rp_library:createBox(client,"Poczekaj chwilę przed następną zmianą danych interioru.") end

    local isInPickup, marker = isPlayerInPickUp(client)
    if not isInPickup then return end

    if not hasPlayerPerm(client, marker) then return end

    local id = interiors[marker].id
    local markers = interiorsByUIDAndPickups[id]
    local enterDoors = markers[1]

    if not enterDoors then return end

    if string.len(descInt) > 30 then
        return
    end

    local target = exports.rp_login:findPlayerByID(tonumber(owner))
    local newOwner = target and exports.rp_login:getPlayerData(target, "characterID") or owner

    interiors[enterDoors].description = descInt
    interiors[enterDoors].name = name

    if exports.rp_admin:hasAdminPerm(client, "creatingInteriors") then
        if not tonumber(garage) then
            return
        end

        interiors[enterDoors].owner = newOwner
        interiors[enterDoors].garage = garage
        interiors[markers[2]].owner = newOwner
        interiors[markers[2]].garage = garage

        exports.rp_db:query_free("UPDATE interiors SET name = ?, description = ?, owner = ?, garage = ? WHERE id = ?",name, descInt, newOwner, garage, id)
		
    else
        exports.rp_db:query_free("UPDATE interiors SET name = ?, description = ? WHERE id = ?",name, descInt, id)
    end
	exports.rp_library:createBox(client, "Zmieniono dane interioru.")
end

addEvent("onPlayerEditInterior", true)
addEventHandler("onPlayerEditInterior", root, onPlayerEditInterior)



function onTeleportInterior(id)
	if not exports.rp_admin:hasAdminPerm(client, "tpInteriors") then return end
	local marker = interiorsByUIDAndPickups[id][1] -- marker glowny
	if not marker then return exports.rp_library:createBox(client,"Interior nie istnieje") end
	local x,y,z = getElementPosition(marker)
	local dim, interior = getElementDimension(marker), getElementInterior(marker)
	setElementPosition(client, x,y,z)
	setElementDimension(client, dim)
	setElementInterior(client, interior)
end
addEvent("onPlayerTryToTpInterior", true)
addEventHandler("onPlayerTryToTpInterior", root, onTeleportInterior)

function isPlayerInPickUp(player)
    local pickupElement = playerInPickup[player]
    if pickupElement and interiors[pickupElement] then
        return true, pickupElement
    end
    return false
end

function getPlayerInteriors(player)
    local interiors = {}
    local owner = exports.rp_login:getPlayerData(player, "characterID")
    local query = exports.rp_db:query("select id, name from interiors WHERE owner=?", owner)
    if query then
        for k, v in ipairs(query) do
            table.insert(interiors, v.name .. " (" .. v.id .. ")")
        end
    end
    return interiors
end

function fadeCameraDelayed(player) 
      if (isElement(player)) then
            fadeCamera(player, true, 1)
      end
end
-- local testObj = {}

-- for i = 1, 5 do 
	-- table.insert(testObj, {position = {774.1103515625,-72.517578125,1000.6484375}, rotation = {1,1,1}, id = 8082, textures = {a = "files/images/328.jpg", b = "files/images/328.jpg"}})

-- end



--createObject(v.id, v.position[1], v.position[2], v.position[3], v.rotation[1], v.rotation[2], v.rotation[3])
function setPlayerDelayInterior(player, isExiting, objects, objectData)
    fadeCamera(player, false, 1, 0, 0, 0)
    setElementFrozen(player, true)

    setTimer(fadeCameraDelayed, 1000, 1, player)

    if isExiting then
        triggerClientEvent(player, "onPlayerLoadInteriorObjects", player, nil, true)
        exports.rp_login:setPlayerData(player, "currentInterior", false, true)
        playerInPickup[player] = nil
		    setTimer(setElementFrozen, 1000, 1, player, false)
    else
        if objectData and #objectData > 0 then
            triggerClientEvent(player, "onPlayerLoadInteriorObjects", player, objectData)
			setElementFrozen(player, true)
		else
			setTimer(setElementFrozen, 1000, 1, player, false)
        end

        if playerInPickup[player] then
            local data = {
                marker = playerInPickup[player],
                interiorUID = interiors[playerInPickup[player]].id,
				interiorOwner = interiors[playerInPickup[player]].owner,
            }
            exports.rp_login:setPlayerData(player, "currentInterior", data, true)
            playerInPickup[player] = nil
        end
    end
end



local tempPickup = {}

local function enterInteriorFromConfirmation(confirmed)
    enterInterior(client, _, _, tempPickup[client], getPedOccupiedVehicle(client), true)
    exports.rp_gym:stopExercise(_, 0, true, client)
    tempPickup[client] = nil
end

function enterInterior(player, _, _, pickup, vehicle, confirm) -- Sprawdzenie, czy jest pojazd
    confirm = confirm or false
    local interiorData = interiors[pickup]
    if not interiorData then return end

    if interiorData.locked then
        exports.rp_library:createBox(player, "Interior jest zamknięty.")
        return
    end

    local isExiting = interiorData.enterPickup and true or false
    local marker = isExiting and interiorData.enterPickup or interiorData.exitPickup
    local rot = isExiting and interiors[marker].angleexit or interiorData.angle
    local dimension = getElementDimension(marker)
    local interior = getElementInterior(marker)
    local x, y, z = getElementPosition(marker)
    local objects = interiors[pickup].objects or 0 -- to limit ile w intku moze byc obiektow
	local objectData = interiors[pickup].objectData

    local garage = interiors[marker].garage

    if vehicle and tonumber(garage) == 0 then
        return exports.rp_library:createBox(player, "Nie można wjechać tutaj pojazdem.")
    end
    -- iprint(interiorData)
    -- print(isExiting)
    if interiorData.id == 10 and isExiting and confirm == not true then -- tu ma sprawdzać czy ten interior to siłownia i czy gracz wychodzi
        if exports.rp_gym:isPlayerDuringTraining(player) then
            -- print("server confirm")
            triggerClientEvent(player, "confirmExitFromGym", player)
            tempPickup[player] = pickup
            return
            -- gui czy gracz na pewno chce wyjść z interioru gdy nie skończył treningu
        end
    end
	if interiorData.id == 12 and isExiting then
		triggerClientEvent(player,"casinoState", player, false)
		elseif interiorData.id == 12 and not isExiting then
		triggerClientEvent(player,"casinoState", player, true)
	end

    if vehicle and getVehicleOccupant(vehicle, 0) and garage == 1 then
	local checkInside = getElementsWithinRange(x, y, z, 10, "vehicle", interior, dimension)
	if #checkInside > 0 then return exports.rp_library:createBox(player, "Pojazd w środku/na zewnątrz blokuje przejazd.") end
        setElementFrozen(vehicle, true) 
        setTimer(function()
            setElementPosition(player, x, y, z)
            setElementDimension(player, dimension)
            setElementInterior(player, interior)
            setElementRotation(player, 0, 0, rot)

            setElementPosition(vehicle, x, y, z)
            setElementDimension(vehicle, dimension)
            setElementInterior(vehicle, interior)

            setElementFrozen(vehicle, false)
        end, 1000, 1)
    else
        setTimer(function()
            setElementPosition(player, x, y, z)
            setElementDimension(player, dimension)
            setElementInterior(player, interior)
            setElementRotation(player, 0, 0, rot)
        end, 1000, 1)
    end

    setPlayerDelayInterior(player, isExiting, objects, objectData) --function setPlayerDelayInterior(player, isExiting, objects, objectData)

    setPedGravity(player, 0.008)

    unbindKey(player, "e", "down", enterInterior)
    triggerClientEvent(player, "onPlayerShowInterior", player, _, _, _, _, false)
end

addEvent("confirmExitFromGymFromClient", true)
addEventHandler("confirmExitFromGymFromClient", getRootElement(), enterInteriorFromConfirmation)


function hitInteriorPickup(player)
	if not interiors[source] then return end
    local pdimension = getElementDimension(player)
    local idimension = getElementDimension(source)
    if pdimension == idimension then
        local name = interiors[source].name
        local typ = interiors[source].exitPickup
		
        bindKey(player, "e", "down", enterInterior, source, getPedOccupiedVehicle(player))
		playerInPickup[player] = source
        if typ then
            local description = interiors[source].description
            local locked = interiors[source].locked
            if name then
				local id = interiors[source].id
				if interiors[source].type == 2 then
					id = id .. ", Cena za zakup: $"..interiors[source].price
				end
                triggerClientEvent(player, "onPlayerShowInterior", player, name, description, locked, id, true)
            end
        end
    end
    cancelEvent()
end
addEventHandler("onPickupHit", getResourceRootElement(), hitInteriorPickup)

function onPickupLeave(player)
    local pdimension = getElementDimension(player)
    local idimension = getElementDimension(source)
    if pdimension == idimension then
        if isKeyBound(player, "e", "down", enterInterior) then
            unbindKey(player, "e", "down", enterInterior)
			triggerClientEvent(player, "onPlayerShowInterior", player, _, _, _, _, false)
			if playerInPickup[player] then
				playerInPickup[player] = nil
			end
        end
    end
end
addEventHandler("onPickupLeave", getResourceRootElement(), onPickupLeave)


addEventHandler("onPlayerQuit",root,
    function(quitType)
        if playerInPickup[player] then
            playerInPickup[player] = nil
        end
    end
)


function addObjectToInterior(player, obj, pos, rot, textureImageA, textureImageB)
    local interiorID = exports.rp_login:getPlayerData(player, "currentInterior")
    if not interiorID then
        return exports.rp_library:createBox(player, "Nie jesteś w interiorze, aby go edytować.")
    end

    local marker = interiorID.marker
    local interior = interiors[marker]
    if not hasPlayerPerm(player, marker) then
        return exports.rp_library:createBox(player, "Nie posiadasz uprawnień do edytowania tego interioru.")
    end

    if interior.objects == #interior then
        return exports.rp_library:createBox(player, "Posiadasz limit obiektów już w budynku.")
    end

    interior.objects = interior.objects + 1
    interior.lastObjectID = interior.lastObjectID + 1
    local lastID = interior.lastObjectID

    local texturePathA = "files/images/" .. textureImageA .. ".jpg"
    local texturePathB = "files/images/" .. textureImageB .. ".jpg"

    table.insert(interior.objectData, {
        position = pos,
        rotation = rot,
        id = obj,
        textures = { a = texturePathA, b = texturePathB },
        lastObjectID = lastID
    })

    local players = getPlayersInInterior(interiorID.interiorUID)
    for _, v in ipairs(players) do
        if isElement(v) then
            triggerClientEvent(v, "onPlayerUpdateObjectInInterior", v, pos, rot, obj, texturePathA, texturePathB, lastID)
        end
    end

    exports.rp_db:query_free("UPDATE interiors SET objectData = ?, lastObjectID = ? WHERE id = ?",toJSON(interior.objectData),lastID,interiorID.interiorUID)
end


function testObjxd(player, cmand, textureImageA, textureImageB)
	local x,y,z = getElementPosition(player)
	local posData = {x, y, z}
	local rot = {0, 0, 0}
	addObjectToInterior(player, 8082, posData, rot, textureImageA, textureImageB)
end
addCommandHandler("dodajob", testObjxd, false, false)

function listener(res, object, cx, cy, cz, rx, ry, rz, sx, sy, sz)
   -- if res == resource and source == player then
   local player = source
   iprint("Pozycja: ", cx, cy, cz)
   iprint("Rotacja: ", rx, ry, rz)
   local posData = {cx, cy, cz}
   local rot = {rx, ry, rz}
   	addObjectToInterior(player, getElementModel(object), posData, rot, "31", "32")

      -- saveFurniturePosition(player, object, cx, cy, cz, rx, ry, rz, sx, sy, sz)
   -- end
end
addEventHandler("3DEditor:savedObject", root, listener)

function removeObjectFromInterior(player, id)
    local interiorID = exports.rp_login:getPlayerData(player, "currentInterior")
    if not interiorID then
        return exports.rp_library:createBox(player, "Nie jesteś w interiorze aby go edytować.")
    end
    if not hasPlayerPerm(player, interiorID.marker) then
        return exports.rp_library:createBox(player, "Nie posiadasz uprawnień do edytowania tego interioru.")
    end
    for k, v in pairs(interiors[interiorID.marker].objectData) do
        if v.lastObjectID == id then
            table.remove(interiors[interiorID.marker].objectData, k)
            local lastID = interiors[interiorID.marker].lastObjectID
            interiors[interiorID.marker].objects = interiors[interiorID.marker].objects - 1
            local players = getPlayersInInterior(interiorID.interiorUID)
            for _, v in ipairs(players) do
                if isElement(v) then
                    triggerClientEvent(v,"onPlayerUpdateObjectInInterior",v,_,_,_,_,_,_, id)
                end
            end
            exports.rp_db:query_free("UPDATE interiors SET objectData = ? WHERE id = ?",toJSON(interiors[interiorID.marker].objectData),interiorID.interiorUID)
            break -- update do bazy danych
        end
    end
end

function editObjectFromInterior(player, id, pos, rot, textureImageA, textureImageB)
    local interiorID = exports.rp_login:getPlayerData(player, "currentInterior")
    if not interiorID then
        return exports.rp_library:createBox(player, "Nie jesteś w interiorze aby go edytować.")
    end
    if not hasPlayerPerm(player, interiorID.marker) then
        return exports.rp_library:createBox(player, "Nie posiadasz uprawnień do edytowania tego interioru.")
    end
	iprint("ustawianie nowe dane w intku")
    for k, v in pairs(interiors[interiorID.marker].objectData) do
        if v.lastObjectID == id then
			iprint("znaleziono obiekt... zmienianie danych")
            if pos then
                v.position = {pos[1], pos[2], pos[3]}
            end
            if rot then
                v.rotation = {rot[1], rot[2], rot[3]}
            end
            if textureImageA then
                v.textures.a = "files/images/" .. textureImageA .. ".jpg"
            end
            if textureImageB then
                v.textures.b = "files/images/" .. textureImageB .. ".jpg"
            end
			local players = getPlayersInInterior(interiorID.interiorUID)
			for _, p in ipairs(players) do
			if isElement(p) then
				triggerClientEvent(p, "onPlayerUpdateObjectInInterior", p, pos, rot, v.id, texturePathA, texturePathB, v.lastObjectID)
				end
			end
			exports.rp_db:query_free("UPDATE interiors SET objectData = ? WHERE id = ?",toJSON(interiors[interiorID.marker].objectData), interiorID.interiorUID)
            break
        end
    end
end


function testObjxdremove(player, cmand, id)
	removeObjectFromInterior(player, tonumber(id))
end
addCommandHandler("usunob", testObjxdremove, false, false)


-- commands

function buyPropertyCommand(player, pickup)
    local type = interiors[pickup].type
    if not type or type ~= 2 then
        return exports.rp_library:createBox(player, "Ten interior nie jest na sprzedaż.")
    end
    local price = interiors[pickup].price
    local bought = exports.rp_atm:takePlayerCustomMoney(player, tonumber(price)) -- gotowka
    if bought then
		local interiorID = interiors[pickup].id
        interiors[pickup].owner = exports.rp_login:getPlayerData(player, "characterID")
		interiors[pickup].type = 1
		setPickupType(pickup, 3, 1273)
		exports.rp_db:query_free("UPDATE interiors SET owner = ?, type = 1 WHERE id = ?",interiors[pickup].owner, interiorID)
        exports.rp_library:createBox(player, "Zakupiłeś interior za: " .. price..".")
		else
		exports.rp_library:createBox(player,"Nie posiadasz tyle pieniędzy, aby zakupić ten interior.") 
    end
end

function sellPropertyToPlayer(player, target, price, pickup) 
	local owner = exports.rp_login:getPlayerData(player,"characterID")
	if owner ~= interiors[pickup].owner then return end
	local id = interiors[pickup].id
	local markers = interiorsByUIDAndPickups[id]
	local type = interiors[pickup].type
	if type == 1 then
	local bought = exports.rp_atm:takePlayerCustomMoney(target, tonumber(price)) -- gotowka
    if not bought then return exports.rp_library:createBox(target,"Nie posiadasz przy sobie tyle gotówki aby zakupić interior.")  end
		exports.rp_atm:givePlayerCustomMoney(player, tonumber(price))
		local targetOwner = exports.rp_login:getPlayerData(target,"characterID")
		interiors[markers[1]].owner = targetOwner
		interiors[markers[2]].owner = targetOwner
		exports.rp_db:query_free("UPDATE interiors SET owner = ? WHERE id = ?",targetOwner, id)
		exports.rp_library:createBox(player,"Gracz zakupił twój interior.")

	end
end

function openOrCloseDoor(player, cmand)
	local isInPickup, marker = isPlayerInPickUp(player)
	if isInPickup then
		changeInteriorDoorState(player, marker)
	end
end

addCommandHandler("z", openOrCloseDoor, false, false)

function knockDoor(player, cmand)
    local isInPickup, marker = isPlayerInPickUp(player)
	local id
    if isInPickup then
        id = interiors[marker].id
        local enterPickup = interiorsByUIDAndPickups[id][1] 
        local exitPickup = interiorsByUIDAndPickups[id][2]
        if marker ~= enterPickup then
            return end
        end

        if not exports.rp_utils:checkPassiveTimer("interiorKnock", player, 5000) then
            return exports.rp_library:createBox(player, "Pukać możesz co 5 sekund.")
        end

        if interiors[marker].locked then
            exports.rp_chat:meCommand(player, nil, "puka do drzwi")
            triggerClientEvent(player, "onPlayerKnockDoor", player, player)
            
            local players = getPlayersInInterior(id)
            for k, v in pairs(players) do
				if isElement(v) then
					triggerClientEvent(v, "onPlayerKnockDoor", v)
				end
            end
        end
    end
addCommandHandler("zapukaj", knockDoor, false, false)



function doorCommand(player, cmand, ...)
    local arg = {...}
    local tip = "/drzwi stworz/z|zamknij/tp/usun/flash/lista/sprzedaj"
    if not arg[1] then
        return exports.rp_library:createBox(player, tip)
    end
    if arg[1] == "kup" then
        local isInPickup, marker = isPlayerInPickUp(player)
        if isInPickup then
            buyPropertyCommand(player, marker)
        end
    elseif arg[1] == "stworz" then -- gui od tworzenia zamiast komenda, jezeli np intek to typ 2 to tworzy sie editbox z cena wykupna intka.
        if not exports.rp_admin:hasAdminPerm(player, "creatingInteriors") then
            return
        end
        triggerClientEvent(player, "onPlayerTryToCreateInterior", player)
        exports.rp_library:createBox(player,"Wypełnij wszystkie dane o interiorze: Nazwa intka, Typ: 1-[dom] 2-[dom na sprzedaz], 3-[urzad], 4-[ciuchy], Opis, ID Intka z GTA, ID ownera, Cena za intek jeżeli typ intka to 2., Garaż (0-1)")
    elseif arg[1] == "z" or arg[1] == "zamknij" then
        openOrCloseDoor(player)
	elseif arg[1] == "edytor" then
		local isInPickup, marker = isPlayerInPickUp(player)
		if not isInPickup then return end
		if hasPlayerPerm(player, marker) or exports.rp_admin:hasAdminPerm(player, "openInteriors") then
			triggerClientEvent(player,"onPlayerEditObjectsInInterior",player)
		end

    elseif arg[1] == "usun" then
        if not exports.rp_admin:hasAdminPerm(player, "creatingInteriors") then
            return
        end
        local isInPickup, marker = isPlayerInPickUp(player)
        if isInPickup then
            deleteProperty(player, marker)
        end
    elseif arg[1] == "flash" or arg[1] == "flashbang" then
        local isInPickup, marker = isPlayerInPickUp(player) -- upra jezeli to PD i ma te upra.
        if isInPickup then
            if not exports.rp_groups:hasPerm(player, "flashbang") then
                return
            end

            if not exports.rp_utils:checkPassiveTimer("interiorFlash", player, 60000) then
                return exports.rp_library:createBox(player, "Interior możesz flashować co 60 sekund.")
            end
            flashbangInterior(marker)
        end
    elseif arg[1] == "sprzedaj" then
        local isInPickup, marker = isPlayerInPickUp(player)
        if isInPickup then
            local target = arg[2]
            local price = tonumber(arg[3])
            if not target or not price then
                return exports.rp_library:createBox(player, "/drzwi sprzedaj [id gracza] [cena]")
            end
            local realTarget = exports.rp_login:findPlayerByID(tonumber(target))
            if not realTarget then
                return exports.rp_library:createBox(player, "Nie ma gracza o podanym ID na serwerze")
            end
            if realTarget == player then
                return
            end
            local distance = exports.rp_utils:getDistanceBetweenElements(player, realTarget)
            if distance > 10 then
                return exports.rp_library:createBox(player, "Gracz któremu chcesz sprzedać interior, jest za daleko.")
            end
            if price < 1 or price > 999999 then
                return
            end
            exports.rp_offers:sendOffer(player, realTarget, 3, marker, price, "Sprzedaż interioru")
        end
    elseif arg[1] == "wywaz" then
        local isInPickup, marker = isPlayerInPickUp(player)
        if isInPickup then
			if not exports.rp_groups:hasPerm(player, "kickDoor") then return end

            local id = interiors[marker].id
            local markers = interiorsByUIDAndPickups[id]
            local enterDoors = markers[1]
            if marker == enterDoors then
			if not interiors[marker].locked then return exports.rp_library:createBox(player,"Drzwi są otwarte, nie możesz wyważyć drzwi.") end
			if not exports.rp_utils:checkPassiveTimer("interiorKick", player, 300000) then return exports.rp_library:createBox(player, "Interior możesz wyważać co 5 minut.") end
			interiors[marker].locked = false
			interiors[markers[2]].locked = false
			exports.rp_nicknames:amePlayer(player, "wyważa drzwi.")
			local players = getPlayersInInterior(id)
				for k,v in pairs(players) do
				triggerClientEvent(v, "onPlayerGotDoorBreaked", v)
				end
            end
        end
    elseif arg[1] == "edytuj" then
        local isInPickup, marker = isPlayerInPickUp(player)
        if isInPickup then
            local admin = exports.rp_admin:hasAdminPerm(player, "creatingInteriors")
            local id = interiors[marker].id
            local markers = interiorsByUIDAndPickups[id]
            local enterDoors = markers[1]
            if not enterDoors then
                return
            end
            local owner = interiors[enterDoors].owner
            if not hasPlayerPerm(player, enterDoors) then
                return
            end
            local name = interiors[enterDoors].name
            local desc = interiors[enterDoors].description
            local garage = interiors[enterDoors].garage
            triggerClientEvent(player, "onPlayerTryToEditInterior", player, name, desc, owner, garage, admin)
            if admin then
                exports.rp_library:createBox(player,"Wypełnij wszystkie dane o interiorze: Nazwa intka, Typ: 1-[dom] 2-[dom na sprzedaz], 3-[urzad], 4-[ciuchy], Opis, ID Intka z GTA, ID ownera, Cena za intek jeżeli typ intka to 2., Garaż (0-1)")
            end
        end
    elseif arg[1] == "lista" then
        if not exports.rp_admin:hasAdminPerm(player, "tpInteriors") then
            return
        end
        triggerClientEvent(player, "onPlayerGotInteriorList", player, interiors)
    elseif arg[1] == "tp" then
        if not exports.rp_admin:hasAdminPerm(player, "tpInteriors") then
            return
        end

        if not arg[2] then
            return exports.rp_library:createBox(player, "/drzwi tp [id]")
        end
        local id = tonumber(arg[2])
        if not id then
            return
        end
        if not interiorsByUIDAndPickups[id] then
            return exports.rp_library:createBox(player, "O podanym ID interior nie istnieje.")
        end
        local x, y, z = getElementPosition(interiorsByUIDAndPickups[id][1])
        local dim, interior =
            getElementDimension(interiorsByUIDAndPickups[id][1]),
            getElementInterior(interiorsByUIDAndPickups[id][1])
        setElementPosition(player, x, y, z)
        setElementDimension(player, dim)
        setElementInterior(player, interior)
    end
end
addCommandHandler("drzwi", doorCommand, false, false)


function getElementsInDimension(theType, dimension, interior)
    local elementsInDimension = { }
    for key, value in ipairs(getElementsByType(theType)) do
        if getElementDimension(value) == dimension and getElementInterior(value) == interior then
            table.insert(elementsInDimension, value)
        end
    end
    return elementsInDimension
end

loadInteriors()
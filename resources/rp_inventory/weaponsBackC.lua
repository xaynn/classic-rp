local players = {}
local playerInfo = {}

-- Function to get the object model ID for a weapon
local function getWeaponModel(weapon)
    if weapon > 1 and weapon < 9 then
        return 331 + weapon
    elseif weapon == 9 then
        return 341
    elseif weapon == 15 then
        return 326
    elseif (weapon > 21 and weapon < 30) or (weapon > 32 and weapon < 39) or (weapon > 40 and weapon < 44) then
        return 324 + weapon
    elseif weapon > 29 and weapon < 32 then
        return 325 + weapon
    elseif weapon == 32 then
        return 372
    end
    return nil
end

-- Function to create a weapon object for a player
local function createWeapon(player, weapon)
    local model = getWeaponModel(weapon)
    if not model then return end
    local slot = getSlotFromWeapon(weapon)
    if not players[player] then players[player] = {} end
    players[player][slot] = createObject(model, 0, 0, 0)
    setElementCollisionsEnabled(players[player][slot], false)
end

-- Function to destroy a specific weapon object
local function destroyWeapon(player, slot)
    if players[player] and players[player][slot] then
        destroyElement(players[player][slot])
        players[player][slot] = nil
    end
end

-- Function to remove all weapon objects from a player
local function destroyAllWeapons(player)
    if players[player] then
        for _, object in pairs(players[player]) do
            destroyElement(object)
        end
        players[player] = {}
    end
end

-- Initialize player weapon data
local function initializePlayer(player)
    players[player] = {}
    playerInfo[player] = {true, isPedInVehicle(player)}
end

-- When the resource starts, initialize all players
addEventHandler("onClientResourceStart", getResourceRootElement(), function()
    for _, player in ipairs(getElementsByType("player", root, true)) do
        initializePlayer(player)
    end
end)

-- When a player leaves the server
addEventHandler("onClientPlayerQuit", root, function()
    if source ~= localPlayer then
        destroyAllWeapons(source)
        players[source] = nil
        playerInfo[source] = nil
    end
end)

-- When a player enters the stream
addEventHandler("onClientElementStreamIn", root, function()
    if getElementType(source) == "player" and source ~= localPlayer then
        initializePlayer(source)
    end
end)

-- When a player leaves the stream
addEventHandler("onClientElementStreamOut", root, function()
    if source ~= localPlayer then
        destroyAllWeapons(source)
        players[source] = nil
        playerInfo[source] = nil
    end
end)

-- When a player respawns
addEventHandler("onClientPlayerSpawn", root, function()
    if playerInfo[source] then
        playerInfo[source][1] = true
    end
end)

-- When a player dies
addEventHandler("onClientPlayerWasted", root, function()
    destroyAllWeapons(source)
    if playerInfo[source] then
        playerInfo[source][1] = false
    end
end)

-- When a player enters a vehicle
addEventHandler("onClientPlayerVehicleEnter", root, function()
    destroyAllWeapons(source)
    if playerInfo[source] then
        playerInfo[source][2] = true
    end
end)

-- When a player exits a vehicle
addEventHandler("onClientPlayerVehicleExit", root, function()
    if playerInfo[source] then
        playerInfo[source][2] = false
    end
end)

-- Render weapons on players
addEventHandler("onClientPreRender", root, function()
    for player, weapons in pairs(players) do
        local x, y, z = getPedBonePosition(player, 3)
        local rotation = math.rad(90 - getPedRotation(player))
        local equippedWeaponSlot = getPedWeaponSlot(player)
        local offsetX, offsetY = math.cos(rotation) * 0.22, -math.sin(rotation) * 0.22
        local alpha = getElementAlpha(player)

        for slot, object in pairs(weapons) do
            if slot == equippedWeaponSlot then
                destroyWeapon(player, slot)
            else
                setElementRotation(object, 0, 70, getPedRotation(player) + 90)
                setElementAlpha(object, alpha)
                setElementDimension(object, getElementDimension(player))
                setElementInterior(object, getElementInterior(player))

                local posX, posY, posZ
                if slot == 2 then
                    posX, posY, posZ = getPedBonePosition(player, 51)
                    posX, posY = posX + math.sin(rotation) * 0.11, posY + math.cos(rotation) * 0.11
                elseif slot == 4 then
                    posX, posY, posZ = getPedBonePosition(player, 41)
                    posX, posY = posX - math.sin(rotation) * 0.06, posY - math.cos(rotation) * 0.06
                else
                    posX, posY, posZ = x + offsetX, y + offsetY, z - 0.2
                    setElementRotation(object, -17, -65, getPedRotation(player))
                end
                setElementPosition(object, posX, posY, posZ)
            end
        end

        -- If the player is alive and not in a vehicle, display weapons
        if playerInfo[player] and playerInfo[player][1] and not playerInfo[player][2] then
            for i = 3, 5 do
                local weapon = getPedWeapon(player, i)
                if weapon ~= equippedWeaponSlot and weapon > 0 and not players[player][i] then
                    createWeapon(player, weapon)
                end
            end
        end
    end
end)

-- Automatically clear weapons when necessary (e.g., weapon reset)
function autoClearWeapons(source)
    if players[source] then
        destroyAllWeapons(source)
    end
    if playerInfo[source] then
        playerInfo[source][1] = false
    end
end


function repairWeapon(source)
	if playerInfo[source] then
		playerInfo[source][1] = true
	end
end
local function checkAndRemoveWeapons(player)
    if not players[player] then return end
    for slot, object in pairs(players[player]) do
        local weapon = getPedWeapon(player, slot)
        if weapon == 0 or not weapon then 
            destroyWeapon(player, slot)
        end
    end
end

addEventHandler("onClientPlayerWeaponSwitch", root, function(_, newWeapon)
    checkAndRemoveWeapons(source)
end)

function onPlayerWeaponChangedState(player, state)
	-- checkAndRemoveWeapons(player)
	if state then
		repairWeapon(player)
	else
		autoClearWeapons(player)
	end
end
addEvent("onPlayerWeaponChangedState", true)
addEventHandler("onPlayerWeaponChangedState", getRootElement(), onPlayerWeaponChangedState)

addEventHandler("onClientRender", root, function()
    for player in pairs(players) do
        checkAndRemoveWeapons(player)
    end
end)

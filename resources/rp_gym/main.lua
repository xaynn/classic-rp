local STAMINA = 100 -- player's stamina on training machine // change to what you need
local CARDIO_RATE = 0.02 -- change as you need
local STEROIDS_MULTIPLIER = 2 -- change as you need
local playersGymState = {} -- players training states
local playersUsedSteroids = {}
local playerCooldowns = {}
local playerStamina = {}
local COOLDOWN_TIME = 20 * 60 * 60 * 1000

-- Objects IDs for training machines
local machinesID = {
	["runningtrack"] = 2627,
	["pressbench"] = 2629,
	["bicycle"] = 2630,
	["mat"] = 2631
}


local gymMarkers = {
[1] = {768.7109375,-76.0576171875,1000.65625, 7, 10},


} -- pos, int, dim

removeWorldModel(2629, 50, 766.787109375,-59.884765625,1000.65625, 7) -- model

removeWorldModel(2630, 50, 773.5400390625,-68.7294921875,1000.6587524414, 7) -- model

removeWorldModel(2627, 50,758.4765625,-65.4912109375,1000.8479003906, 7) -- model

local gymObjects = { -- typ pressbench, bicycle, mat, runningtrack
[1] = {"pressbench", 766.787109375,-59.884765625,1000.65625, 7, 10},
[2] = {"pressbench", 764.3798828125,-59.884765625,1000.65625, 7, 10},
[3] = {"pressbench",769.3173828125,-59.884765625,1000.65625, 7, 10},

[4] = {"mat", 759.015625,-59.6962890625,1000.7802124023, 7, 10},
[5] = {"bicycle", 758.560546875,-71.1279296875,1000.6484375, 7, 10},
[6] = {"bicycle", 760.125,-71.1279296875,1000.6538085938, 7, 10},
[7] = {"runningtrack", 758.0556640625,-65.1640625,1000.6556396484, 7, 10},
[8] = {"runningtrack", 760.0556640625,-65.1640625,1000.6556396484, 7, 10},

}

local function loadGymObjects() 
	for k,v in ipairs(gymObjects) do
		createTrainingMachine(_, _, v[2], v[3], v[4], 0, 0, 0, v[1], v[5], v[6])
	end
end

local function setPlayerGymCooldown(player)
    local characterID = exports.rp_login:getPlayerData(player, "characterID")
    playerCooldowns[characterID] = getTickCount()
end

function isGymCooldownOver(player)
    local characterID = exports.rp_login:getPlayerData(player, "characterID")
    local lastUsed = playerCooldowns[characterID]

    if not lastUsed then
        return true 
    end

    return getTickCount() - lastUsed >= COOLDOWN_TIME
end
local markerElements = createElement("gymMarkers")
local function loadGymMarkers()
	for k,v in ipairs(gymMarkers) do
		local marker = createMarker ( v[1], v[2], v[3]-0.9, "cylinder", 1.5, 255, 255, 0, 0 )
		exports.rp_login:setObjectData(marker, "3DText", "Siłownia")
		setElementDimension(marker, v[5])
		setElementInterior(marker, v[4])
		setElementParent(marker, markerElements)
	end
end

function bindKeyShop(player, key, keyState, _, marker)
    unbindKey(player, "E", "down", bindKeyShop)
    if playersGymState[player] then
        return
    end
    if not isGymCooldownOver(player) then
        return exports.rp_library:createBox(player, "Nie minęło 20 godzin od ostatniego treningu.")
    end
    local bought = exports.rp_atm:takePlayerCustomMoney(player, 100)
    if bought then
        exports.rp_library:createBox(player, "Zakupiłeś karnet za 100 dolarów, podejdz do maszyny i zacznij cwiczyć.")
        onPlayerGotSuccessfullGymOffer(player, true)
    else
        exports.rp_library:createBox(player, "Nie posiadasz wystarczającej liczby pieniędzy (100$)")
    end
end


local function handlePlayerMarker(hitElement, matchinDimension)
    local elementType = getElementType(hitElement)
    if elementType ~= "player" then
        return
    end
    if matchinDimension then
		if playersGymState[player] then return end
		bindKey(hitElement, "E", "down", bindKeyShop, hitElement, source)
        exports.rp_library:createBox(hitElement, "Kliknij E aby zakupić karnet, kosztuje 100$.")
    end
end
addEventHandler("onMarkerHit", markerElements, handlePlayerMarker)

function markerLeave(leaveElement, matchingDimension)
	local elementType = getElementType(leaveElement)

	if elementType == "player" then
		unbindKey(leaveElement, "E", "down", bindKeyShop)
	end
end
addEventHandler("onMarkerLeave", markerElements, markerLeave)
-- All created training machines on whole server
local trainingMachines = {}

-- TrainingMachine base setup // coordinates, rotation, type, occupied, object, player, cardioTrainingMode, manage (for timer), cooldown for weights, accesories for weights, progress of the training, player's stamina, penalty for faster training
trainingMachine = {coordinates = {x = 0, y = 0, z = 0}, rotation = {rx = 0, ry = 0, rz = 0}, type = nil, occupied = false, object = nil, player = nil, cardioTrainingMode = nil, manage = nil, cooldown = false, accesories = {} --[[,stamina = STAMINA]], penalty = 0, interior = 0, dimension = 0}

-- Resets properties on machine so it is ready to use by another player
local function resetMachineProperties(machine)
	machine.occupied = false
	machine.player = nil
	machine.cardioTrainingMode = nil
	machine.manage = nil
	machine.cooldown = nil
	machine.penalty = 0
end

function onPlayerGotSuccessfullGymOffer(player, state) -- The exported function is triggered in offers when a player accepts an offer and has enough money to buy a ticket. For example, when a player enters a marker where they can purchase a ticket, if they buy it, this function should be triggered. It is also triggered when a player has 0 stamina and saves it, as they must have a 20-hour cooldown before training again.
	if isElement(player) then
		if playersUsedSteroids[player] == nil then
			playersUsedSteroids[player] = 1
		end
		triggerClientEvent(player, "turnStaminaBar", player, true) -- true for turning on/false for turning off --add stamina bar
		playersGymState[player] = state
		playerStamina[player] = 100
	end
end

function isPlayerDuringTraining(player)
	-- print("check1")
	if playersGymState[player] then
		return true
	end
	return false
end

function onPlayerUsedSteroids(player, type)
	playersUsedSteroids[player] = 1 * STEROIDS_MULTIPLIER
end

local function onPlayerExit()
	if playersGymState[source] then 
		playersGymState[source] = nil 
	end -- clearing player state when he quits

	if playersUsedSteroids[source] ~= nil then 
		playersUsedSteroids[source] = nil 
	end
	
	if playerStamina[source] then playerStamina[source] = nil end
	for _, machine in pairs(trainingMachines) do
		if machine.player == source then
			resetMachineProperties(machine)
		end
	end
end
addEventHandler("onPlayerQuit", root, onPlayerExit)

-- OOP training machine initialization // called from trainingMachine:New()
function trainingMachine:__init(o)
    -- Create the main object
    local object = createObject(machinesID[o.type], o.coordinates[1], o.coordinates[2], o.coordinates[3], o.rotation[1], o.rotation[2], o.rotation[3])

    -- Handle pressbench type
    if o.type == "pressbench" then
        local x, y, z = utility.getPositionFromElementOffset(object, -.45, .55, 1)
        local barbells = createObject(2913, x, y, z)
		setElementCollisionsEnabled(barbells, false)
        setElementRotation(barbells, 0, 90, 0)
        o.accesories = {barbells}
        setElementInterior(barbells, o.interior)
        setElementDimension(barbells, o.dimension)
    -- Handle mat type
    elseif o.type == "mat" then
        local x2, y2, z2 = utility.getPositionFromElementOffset(object, -0.2, 0, 0.2)
        local dumbell1 = createObject(2916, x2, y2, z2)
        x2, y2, z2 = utility.getPositionFromElementOffset(object, 0.2, 0, 0.2)
        local dumbell2 = createObject(2916, x2, y2, z2)
		setElementCollisionsEnabled(dumbell1, false)
		setElementCollisionsEnabled(dumbell2, false)
        o.accesories = {dumbell1, dumbell2}
        setElementInterior(dumbell1, o.interior)
        setElementDimension(dumbell1, o.dimension)
        setElementInterior(dumbell2, o.interior)
        setElementDimension(dumbell2, o.dimension)
    end

    return object  -- Return the main object
end

-- OOP function that calls for a new training machine initialization // called from createTrainingMachine // gets coordinates, rotation, type // returns o
function trainingMachine:New(o, coordinates, rotation, type, interior, dimension)
    o = o or {} 
    setmetatable(o, self)
    self.__index = self
    o.coordinates = coordinates
    o.rotation = rotation
    o.type = type
    o.occupied = false
    o.interior = interior
    o.dimension = dimension
    o.object = trainingMachine:__init(o)

    -- Set the interior and dimension for the created object
    setElementInterior(o.object, o.interior)
    setElementDimension(o.object, o.dimension)
	setElementCollisionsEnabled(o.object, false)


    return o  -- Return the created training machine object
end

-- function for a createmachine command, creates a new machine with specified coordinates, rotation and machine type // gets x, y, z, rx, ry, type
function createTrainingMachine(_, _, x, y, z, rx, ry, rz, type, int, dim)
	if x and y and z and rx and ry and rz and utility.findKeyInTable(machinesID, type) and dim then
	z = z - 1
		local newMachine = trainingMachine:New(nil, {x, y, z}, {rx, ry, rz}, type, int, dim)
		table.insert(trainingMachines, newMachine)
	else
		outputChatBox("createmachine [x] [y] [z] [rx] [ry] [rz] [id] [int] [dim]")
	end
end


local function onPlayerTryToBuyTicket(player, cmand)
    local marker = exports.rp_utils:getNearestElement(player, "marker", 2)
    if marker then
        local data = exports.rp_login:getObjectData(marker, "3DText") == "Siłownia"
        if data then
            if playersGymState[player] then
                return
            end
            if not isGymCooldownOver(player) then
                return exports.rp_library:createBox(player, "Nie minęło 20 godzin od ostatniego treningu.")
            end
            local bought = exports.rp_atm:takePlayerCustomMoney(player, 100)
            if bought then
                exports.rp_library:createBox(player,"Zakupiłeś karnet za 100 dolarów, podejdz do maszyny i zacznij cwiczyć.")
                onPlayerGotSuccessfullGymOffer(player, true)
            else
                exports.rp_library:createBox(player, "Nie posiadasz wystarczającej liczby pieniędzy (100$)")
            end
        end
    end
end
-- addCommandHandler("karnet", onPlayerTryToBuyTicket, false, false)

-- offsets table for player position for each machine type
-- ["runningtrack"] = 2627,
-- ["pressbench"] = 2629,
-- ["bicycle"] = 2630,
-- ["mat"] = 2631

local playerPositionOffsets = {
	[2627] = {{0, -1.5, 1}, {0, 0, 0}}, -- running -- {x, y, z}, {rx, ry, rz}
	[2629] = {{0, -1, 1.05}, {0, 0, 0}}, -- pressbench
	[2630] = {{.5, .5, 1}, {0, 0, -180}}, -- bicycle
	[2631] = {{0, -1, 1.05}, {0, 0, 0}} -- lifting
}

-- prefixes for certain animations for a certain machine type
local animationPrefixes = {
    ["runningtrack"] = "gym_tread_",
	["pressbench"] = "gym_bp_",
	["bicycle"] = "gym_bike_",
	["mat"] = "gym_free_"
}

-- animation blocks for certain animation prefixes
local categories = {
	["gym_tread_"] = "gymnasium",
	["gym_bp_"] = "benchpress",
	["gym_bike_"] = "gymnasium",
	["gym_free_"] = "freeweights"
}

-- temp variable for tracking training progress (100 ends training and provides +1 level)

-- function that looks for a machine occupied by provided player // gets player // returns trainingMachine reference
local function findPlayerMachine(player)
	for k, machine in pairs(trainingMachines) do
		if machine.player == player then
			return machine
		end
	end
end

-- function running in a loop (0.1 sec cooldown), checks if player is viable for progress update for cardio training // gets player
local function manageCardioProgress(player)
	local machine = findPlayerMachine(player)
	if (playerStamina[player] - 0.4) <= 0 then
		-- print("stop")
		playerStamina[player] = 0
		triggerClientEvent(player, "turnStaminaBar", player, false) -- true for turning on/false for turning off --remove stamina bar
		triggerClientEvent(player, "noStamina", player, _, _, machine.type)
		return
	end
	if machine.cardioTrainingMode == 2 then
		playerStamina[player] = playerStamina[player] - (CARDIO_RATE * (machine.cardioTrainingMode)^2)
		triggerClientEvent(player, "onStaminaChange", player, playerStamina[player]) --update stamina bar
		machine.penalty = machine.penalty + (CARDIO_RATE * (machine.cardioTrainingMode))
	else
		playerStamina[player] = playerStamina[player] - (CARDIO_RATE * machine.cardioTrainingMode)
		triggerClientEvent(player, "onStaminaChange", player, playerStamina[player]) --update stamina bar
	end
end

-- fucntion called by the weightsTraining event (which is called when player completes lift animation) // checks if progress cooldown is active (prevents client manipulation) if unactive, +1 progress then sets cooldown for 2 seconds
local function manageWeightsProgress()
	local player = client
	local machine = findPlayerMachine(player)
	if machine.cooldown == false then
		machine.cooldown = true
		if (playerStamina[player] - 4) <= 0 then
			-- print("stop")
			playerStamina[player] = 0
			triggerClientEvent(player, "turnStaminaBar", player, false) -- true for turning on/false for turning off --remove stamina bar
			triggerClientEvent(player, "noStamina", player, _, _, machine.type)
			return
		end
		playerStamina[player] = playerStamina[player] - 4
		triggerClientEvent(player, "onStaminaChange", player, playerStamina[player]) --update stamina bar
		if machine.type == "mat" then
			machine.penalty = machine.penalty + 1
		end
		setTimer(function ()
			machine.cooldown = false
		end, 2000, 1)
	end
end

-- function called from findMachine (which is called from event playerLookingForMachine) // gets machine, player // function freezes player, sets cardioTrainingMode, player, manage properties on a machine; gets position and rotation from machine then sets player in it; sets correct training start animation for machine type, attach correct accessories for correct training machine; triggers onExercise event to client
local function startExercise(machine, player)
	setElementFrozen(player, true)

	machine.occupied = true
	machine.player = player

	if machine.type == "runningtrack" or machine.type == "bicycle" then
		machine.cardioTrainingMode = 0
		machine.manage = setTimer(manageCardioProgress, 100, 0, player)
	end

  	local x, y, z = getElementPosition(machine.object)
  	local rx, ry, rz = getElementRotation(machine.object)

  	setElementPosition(player, x + playerPositionOffsets[machinesID[machine.type]][1][1], y + playerPositionOffsets[machinesID[machine.type]][1][2], z + playerPositionOffsets[machinesID[machine.type]][1][3])
  	setElementRotation(player, rx + playerPositionOffsets[machinesID[machine.type]][2][1], ry + playerPositionOffsets[machinesID[machine.type]][2][2], rz + playerPositionOffsets[machinesID[machine.type]][2][3], "default", true)

	if machine.type == "mat" then
		utility.animation(player, animationPrefixes[machine.type] .. "pickup", categories[animationPrefixes[machine.type]], true)
		setTimer(function ()
			exports.pAttach:attach(machine.accesories[1], player, 24, 0.05, 0.04, 0, 0, 90, 0)
			exports.pAttach:attach(machine.accesories[2], player, 34, 0.05, 0.02, 0, 0, 90, 0)
		end, 2000, 1)
    elseif machine.type == "pressbench" then
		utility.animation(player, animationPrefixes[machine.type] .. "geton", categories[animationPrefixes[machine.type]], true)
		setTimer(function ()
			-- print("attach")
			exports.pAttach:attach(machine.accesories[1], player, 24, 0, 0.05, -0.1, 5, 0, 0)
		end, 4000, 1)
	else
		utility.animation(player, animationPrefixes[machine.type] .. "geton", categories[animationPrefixes[machine.type]], true)
    end
	triggerClientEvent(player, "onExercise", player, machine.type, STAMINA)
end

-- function called from offExercise event // gets type of training machine, time duration of animation to unfreeze player // function kills timer for managing player training progress; sets correct training start animation for machine type, detach correct accessories for correct training machine; unfreezes player after animation end
function stopExercise(type, time, exit, player)
	local player = client or player
	exit = exit or false
	if exit then
		setPlayerGymCooldown(player)
		triggerClientEvent(player, "turnStaminaBar", player, false)
		exports.rp_library:createBox(player,"Zakończyłeś trening, aby rozpocząć kolejny trening musi minąć 20h.")
		playersGymState[player] = nil
		playersUsedSteroids[player] = nil 
		playerStamina[player] = nil
		return
	end

	if isTimer(findPlayerMachine(player).manage) then
		killTimer(findPlayerMachine(player).manage)
	end

	local machine = findPlayerMachine(player)
	-- print("steroids ", playersUsedSteroids[player])
	-- print("stamina ", playerStamina[player])
	-- print("penalty ", machine.penalty)
	local progress = (STAMINA - (playerStamina[player] + machine.penalty)) / STAMINA * 3 * playersUsedSteroids[player]

	local statType
	if type == "runningtrack" or type == "bicycle" then
		statType = "fitness"
	else
		statType = "strength"
	end

	local stat = exports.rp_login:getCharDataFromTable(player, statType)
	local wholeProgress = stat + progress

	if wholeProgress > 100 then 
		wholeProgress = 100
	elseif wholeProgress < 0 then
		wholeProgress = 0
	end
	exports.rp_login:changeCharData(player, statType, wholeProgress)
	setPlayerGymCooldown(player)

	if playerStamina[player] <=0 then
		exports.rp_library:createBox(player,"Zakończyłeś trening, aby rozpocząć kolejny trening musi minąć 20h.")
		playersGymState[player] = nil
	end
	-- print("progres treningu: ", progress)

	if type == "mat" then
		utility.animation(player, animationPrefixes[type] .. "putdown", categories[animationPrefixes[type]], false)
		setTimer(function ()
			exports.pAttach:detach(machine.accesories[1])
			exports.pAttach:detach(machine.accesories[2])
			local x2, y2, z2 = utility.getPositionFromElementOffset(machine.object, -0.2, 0, 0.2)
			setElementPosition(machine.accesories[1], x2, y2, z2)
			setElementRotation(machine.accesories[1], 0, 0, 0)
			x2, y2, z2 = utility.getPositionFromElementOffset(machine.object, 0.2, 0, 0.2)
			setElementPosition(machine.accesories[2], x2, y2, z2)
			setElementRotation(machine.accesories[2], 0, 0, 0)
		end, 900, 1)
    elseif type == "pressbench" then
		utility.animation(player, animationPrefixes[type] .. "getoff", categories[animationPrefixes[type]], false)
		setTimer(function ()
			exports.pAttach:detach(machine.accesories[1])
			local x, y, z = utility.getPositionFromElementOffset(machine.object, -.45, .55, 1)
			setElementPosition(machine.accesories[1], x, y, z)
 			setElementRotation(machine.accesories[1], 0, 90, 0)
		end, 2000, 1)
	else
		utility.animation(player, animationPrefixes[type] .. "getoff", categories[animationPrefixes[type]], false)
    end

	setTimer(function ()
		setElementFrozen(player, false)
		resetMachineProperties(machine)
	end, time, 1)
end

-- function called when player is looking for the nearest machine // checks if player has a training offer; looks for nearest machine and checks if it is occupied by someone else; starts exercise (startExercise()) if previous conditions met
local function findMachine()
	if playersGymState[client] then
		for _, machine in pairs(trainingMachines) do
			if utility.getDistanceBetweenElements(machine.object, client) <= 2 then
				if machine.occupied ~= true then
					startExercise(machine, client) 
					break
				end
			end
		end
		
	end
end

-- Types
-- ["runningtrack"]
-- ["pressbench"]
-- ["bicycle"]
-- ["mat"]

-- ["bicycle"] = {
-- 	["normal"] = "still",
-- 	["medium"] = "pedal",
-- 	["fast"] = "fast"
-- },
-- ["runningtrack"] = {
-- 	["normal"] = "walk",
-- 	["medium"] = "jog",
-- 	["fast"] = "sprint"
-- }

-- modes for cardio training (multipliers for progress) // idle x0; normal x1; fast x2
local cardioTrainingModes = {
	["still"] = 0,
	["walk"] = 0,
	["pedal"] = 1,
	["jog"] = 1,
	["fast"] = 2,
	["sprint"] = 2,
}

-- function for training actions handling; called on doExercise event called by the client // gets type of training, action name (anim name), if it is supposed to freeze last frame of anim, if it is supposed to loop the anim // checks if loop argument is provided else false; assigns current player's machine; checks if training type is cardio; sets animation for provided training type and speed
local function trainingAction(type, action, freezeLastFrame, loop)
	local loop = loop or false
	local machine = findPlayerMachine(client)

	if type == "runningtrack" or type == "bicycle" then
		machine.cardioTrainingMode = cardioTrainingModes[action]
	end

	utility.animation(client, animationPrefixes[type] .. action, categories[animationPrefixes[type]], freezeLastFrame, loop)
end

local function setGymStat(player, _, statType, value)
	-- print("wykonano")
	if statType and value then
		exports.rp_login:changeCharData(player, statType, value)
	else
		outputChatBox("setgymstat [stat_type] [value]; stat types: fitness, strength")
	end
end

-- all events
addEvent("doExercise", true)
addEventHandler("doExercise", getRootElement(), trainingAction)

addEvent("offExercise", true)
addEventHandler("offExercise", getRootElement(), stopExercise)

addEvent("playerLookingForMachine", true)
addEventHandler("playerLookingForMachine", getRootElement(), findMachine)

addEvent("weightsTraining", true)
addEventHandler("weightsTraining", getRootElement(), manageWeightsProgress)

-- addCommandHandler ( "createmachine", createTrainingMachine )

-- addCommandHandler ( "setgymstat", setGymStat )

setTimer ( loadGymObjects, 10000, 1 )
setTimer ( loadGymMarkers, 10000, 1 )

local gymBlip = createBlip (2115.3203125,-1744.322265625,13.554714202881, 54, 2, 255, 255,255, 255, 0, 500)

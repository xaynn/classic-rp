local scaleValue = exports.rp_scale:returnScaleValue()

local petrolGui = {}
petrolGui.width, petrolGui.height = 400 * scaleValue, 150 * scaleValue
petrolGui.x, petrolGui.y = exports.rp_scale:getScreenStartPositionFromBox(petrolGui.width, petrolGui.height, 0, 0, "center", "center") 

DGS = exports.dgs
local sx, sy = guiGetScreenSize()
local font = dxCreateFont("files/Helvetica.ttf", 10 * scaleValue, false, "proof") or "default"

local vehicleFuel = nil
local petrolShowed = false
local petrolForLitr = 0
local isFueling = false
local fuelAdded = 0

function onGotTank(fuel, litr, actualFuel)
    if actualFuel then
        vehicleFuel = actualFuel
		updateProgressBar()
		updateFuelLabel()
    end
    if fuel and litr then
        vehicleFuel = fuel
        petrolForLitr = litr
        petrolShowed = not petrolShowed
        if petrolShowed then
            createPetrolGui()
        else
            destroyPetrolGui()
        end
    end
end

local function windowClosed()
    setTimer(function()
        showCursor(false)
        destroyPetrolGui()
    end, 100, 1)
end


-- local function stopFueling()
    -- if isFueling and fuelAdded > 0 then
        -- triggerServerEvent("onPlayerTankVehicle", localPlayer, fuelAdded)
        -- vehicleFuel = vehicleFuel + fuelAdded
        -- updateFuelLabel()
        -- updateProgressBar()
    -- end
    -- isFueling = false
    -- fuelAdded = 0
-- end

function updateFuelLabel()
    local calc = petrolForLitr * fuelAdded
    DGS:dgsSetText(petrolGui.label, "Paliwo: " .. math.floor(vehicleFuel) .. "/60L, Cena za tankowanie: " .. math.floor(calc) .. "$")
end

function updateProgressBar()
    local progressCurrentFuel = (vehicleFuel / 60) * 100
    DGS:dgsProgressBarSetProgress(petrolGui.progressbar, progressCurrentFuel)

    local progressTotalFuel = ((vehicleFuel + fuelAdded) / 60) * 100
    DGS:dgsProgressBarSetProgress(petrolGui.progressbarsecond, progressTotalFuel)
end


function startFueling(button, state)
	if source == petrolGui.tankVehicle then
    if button == "left" then
        if state == "down" then
            isFueling = true
			addEventHandler("onClientRender",root,renderFuelState)
        else
            isFueling = false
			triggerServerEvent("onPlayerTankVehicle", localPlayer, fuelAdded)
			removeEventHandler("onClientRender",root,renderFuelState)
			fuelAdded = 0
			end
        end
    end
end


function renderFuelState()
	if isFueling then
		local calc = vehicleFuel + fuelAdded
		if calc >= 60 then return end
		fuelAdded = fuelAdded + 0.1
		updateFuelLabel()
		updateProgressBar()
	end
end

function createPetrolGui()
    petrolGui.window = exports.rp_library:createWindow("petrolWindow", petrolGui.x, petrolGui.y, petrolGui.width, petrolGui.height, "Tankowanie pojazdu", 5, 0.55 * scaleValue, true)
    petrolGui.label = DGS:dgsCreateLabel(10 * scaleValue, 10 * scaleValue, 50 * scaleValue, 50 * scaleValue, "Paliwo: " .. math.floor(vehicleFuel) .. "/60L, Cena za tankowanie: ", false, petrolGui.window)
    DGS:dgsSetProperty(petrolGui.label, "font", font)
    petrolGui.tankVehicle = exports.rp_library:createButtonRounded("petrol:tankvehicle", 260 * scaleValue, 50 * scaleValue, 120 * scaleValue, 30 * scaleValue, "Tankuj", petrolGui.window, 0.6 * scaleValue, 10)
    addEventHandler("onDgsMouseClick", petrolGui.tankVehicle, startFueling)
	addEventHandler("onDgsWindowClose",petrolGui.window,windowClosed)

    petrolGui.progressbarsecond = DGS:dgsCreateProgressBar(10 * scaleValue, 50 * scaleValue, 150 * scaleValue, 34 * scaleValue, false, petrolGui.window)
    petrolGui.progressbar = DGS:dgsCreateProgressBar(10 * scaleValue, 50 * scaleValue, 150 * scaleValue, 34 * scaleValue, false, petrolGui.window)
	-- DGS:dgsSetProperty(petrolGui.progressbarsecond,"bgColor",tocollo)
	DGS:dgsSetProperty(petrolGui.progressbarsecond,"indicatorColor",tocolor(255,0,0,255))

    updateProgressBar()
    showCursor(true)
end

function destroyPetrolGui()
    for k, v in pairs(petrolGui) do
        if isElement(v) then destroyElement(v) end
    end
    petrolShowed = false
    showCursor(false)
    isFueling = false
    fuelAdded = 0
    -- removeEventHandler("onClientRender", root, renderFuelState)
end

addEvent("onPlayerShowFuelTank", true)
addEventHandler("onPlayerShowFuelTank", root, onGotTank)

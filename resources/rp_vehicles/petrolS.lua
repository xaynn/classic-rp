local gasStations = {
[1] = {1938.58984375,-1774.482421875,13.091702461243}
}
local isInGasStation = {}
local gasStationsElements = createElement("gasStationsElements")
priceForLitr = 5
    -- setElementParent(zone, cornerElements)
local petrolObjects = {
[1] = {1941.7373046875,-1769.212890625,13.640625},
[2] = {1941.775390625,-1776.0390625,13.640625}
}


function loadGasStations()
    for k, v in pairs(gasStations) do
        local blip = createBlip(v[1], v[2], v[3], 13, 2, 255, 0, 0, 255, 0, 300)
        local col = createColSphere(v[1], v[2], v[3], 10)
		setElementDimension(blip, 0)
		setElementDimension(col, 0)
        setElementParent(col, gasStationsElements)
    end
	for k,v in pairs(petrolObjects) do
		local obj = createObject(3465, v[1], v[2], v[3])
	end
end

function isPlayerInGasStation(player)
	return isInGasStation[player] or false
end


function GasEnterHandler(hitElement, matchinDimension)
    if getElementType(hitElement) == "player" then
        if matchinDimension then
			if not isInGasStation[hitElement] then
			isInGasStation[hitElement] = true
			end
        end
    end
end

addEventHandler("onColShapeHit", gasStationsElements, GasEnterHandler)

function GasExitHandler(hitElement, matchingDimension)
    if getElementType(hitElement) == "player" then
        if matchingDimension then
                isInGasStation[hitElement] = nil
        end
    end
end
addEventHandler("onColShapeLeave", gasStationsElements, GasExitHandler)

addEventHandler("onPlayerQuit", root,
	function(quitType)
		if isInGasStation[source] then
			isInGasStation[source] = nil
		end
	end
)

function tankVehicle(fuel)
    if fuel < 1 then
        return
    end
    if not tonumber(fuel) then return end
    local vehicle = getPedOccupiedVehicle(client)
    if not vehicle then
        return
    end
    local data = vehicles[vehicle]
    local vehicleFuel = getVehicleData(data, "fuel")
    if vehicleFuel >= 60 then
        return exports.rp_library:createBox(client, "Pojazd posiada pełny bak")
    end

    local maxFuelToAdd = 60 - vehicleFuel
    if fuel > maxFuelToAdd then
        fuel = maxFuelToAdd
    end

    local price = priceForLitr * fuel
    local bought = exports.rp_atm:takePlayerCustomMoney(client, price)
    if not bought then
        return exports.rp_library:createBox(client, "Nie masz wystarczająco pieniędzy do zakupu tyle litrów paliwa.")
    end

    local actualFuel = vehicleFuel + fuel
    changeVehicleStatistics(data, "fuel", actualFuel)
    exports.rp_library:createBox(client, "Zatankowano pojazd za: "..math.floor(price).."$.")
	exports.rp_nicknames:amePlayer(client, "tankuje "..vehicleElementName(vehicle)..".")
	exports.rp_soundsystem:playSoundInArea(client, _, _, _, _, _, "petrol")

    local driver = getVehicleOccupant(vehicle, 0)
    if driver then
        triggerClientEvent(driver, "onLocalVehicleUpdateData", driver, actualFuel)
        triggerClientEvent(driver, "onPlayerShowFuelTank", driver, _, _, actualFuel)
    end
end
addEvent("onPlayerTankVehicle", true)
addEventHandler("onPlayerTankVehicle", root, tankVehicle)




loadGasStations()
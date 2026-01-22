local timersVehicles = {}

function enableIndicator(player, type)

    local vehicle = getPedOccupiedVehicle(player)
    if not vehicle then
        return
    end
	local driver = getVehicleOccupant(vehicle, 0)
	if not driver then return end
    indicatorCreate(vehicle, type)
end


--todo awaryjne tez
function indicatorCreate(vehicle, type)
    local objectData = "indicator" .. type
    if timersVehicles[vehicle] then
        indicatorDelete(vehicle, objectData)
        return
    end
    timersVehicles[vehicle] = setTimer(blinkIndicator, 500, 0, vehicle, type)
end

function indicatorDelete(vehicle, objectData)
    local delTimer = timersVehicles[vehicle]
    if isTimer(delTimer) then
        killTimer(delTimer)
        exports.rp_login:setObjectData(vehicle, objectData, false)
        timersVehicles[vehicle] = nil
    end
end

function blinkIndicator(vehicle, type)
    local objectData = "indicator" .. type
    local state = exports.rp_login:getObjectData(vehicle, objectData)
    exports.rp_login:setObjectData(vehicle, objectData, not state)
end

addEventHandler(
    "onElementDestroy",
    getRootElement(),
    function()
        if getElementType(source) == "vehicle" then
            if isTimer(timersVehicles[source]) then
                killTimer(timersVehicles[source])
                timersVehicles[source] = nil
            end
        end
    end
)

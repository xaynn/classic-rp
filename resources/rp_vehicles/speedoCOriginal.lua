local speedometer = {}
speedometer.enabled = false
speedometer.vehicleTypes = {["BMX"]=true, ["BIKE"]=true}
local scaleValue = exports.rp_scale:returnScaleValue()
speedometer.kmh = dxCreateFont('files/Helvetica.ttf', 70 * scaleValue, false, 'proof') or 'default' -- fallback to default
speedometer.font = dxCreateFont('files/Helvetica.ttf', 20 * scaleValue, false, 'proof') or 'default' -- fallback to default

local offSetX, offsetY = exports.rp_scale:returnOffsetXY()
local maxspeed = nil
speedometer.startX, speedometer.startY = exports.rp_scale:getScreenStartPositionFromBox(50*scaleValue, 50*scaleValue, offSetX, offsetY, "right", "bottom")

function speedometer.init(state)
    if state then
        speedometer.enabled = true
		addEventHandler("onClientRender", root, speedometer.render)
    else
        speedometer.enabled = false
		removeEventHandler("onClientRender", root, speedometer.render)
    end
end



function speedometer.vehicleEnter(player, seat)
    if player == localPlayer and seat == 0 then
        local typeVehicle = getVehicleType(source)
        if speedometer.vehicleTypes[typeVehicle] then
            return
        end
		speedometer.init(true)
		local handling = getVehicleHandling(source)
		maxspeed = handling["maxVelocity"] * 0.9
    end
end


function speedometer.vehicleExit(player, seat)
    if player == localPlayer and seat == 0 then
        if speedometer.enabled then
            speedometer.init(false)
        end
    end
end

addEventHandler("onClientVehicleEnter", root, speedometer.vehicleEnter)
addEventHandler("onClientVehicleExit", root, speedometer.vehicleExit)

function speedometer.render()
    local veh = getPedOccupiedVehicle(localPlayer)
    if veh and getVehicleEngineState(veh) then
        local gear = getVehicleCurrentGear(veh)
        local speed = math.floor(getElementSpeed(veh, 1)) 

        local formattedSpeed
		local offset = 0

        if speed == 0 then
            formattedSpeed = "0" 
        elseif speed < 100 then
            formattedSpeed = string.format("%02d", speed) 
        else
			offset = 20
            formattedSpeed = tostring(speed) 
        end
  
        dxDrawText(formattedSpeed, speedometer.startX-90-offset*scaleValue, speedometer.startY - 80 * scaleValue, speedometer.startX, speedometer.startY, tocolor(255, 255, 255, 255), 1, speedometer.kmh, "left", "top")

        if gear == 0 then gear = "R" end
        dxDrawText(gear, speedometer.startX - 200 * scaleValue, speedometer.startY - 20 * scaleValue, speedometer.startX, speedometer.startY, tocolor(255, 255, 255, 255), 1, speedometer.font, "left", "top")


        local fillRatio = math.min(speed / maxspeed, 1)

        local barWidth = 250 * scaleValue
        local filledWidth = barWidth * fillRatio

        dxDrawRectangle(speedometer.startX - 200 * scaleValue, speedometer.startY + 30 * scaleValue, barWidth, 15 * scaleValue, tocolor(118, 108, 106, 100)) -- tło paska
        dxDrawRectangle(speedometer.startX - 200 * scaleValue, speedometer.startY + 30 * scaleValue, filledWidth, 15 * scaleValue, tocolor(118, 108, 106, 255)) -- wypełnienie paska

        local capPosition = filledWidth
        dxDrawRectangle(speedometer.startX - 200 * scaleValue + capPosition, speedometer.startY + 30 * scaleValue, 5 * scaleValue, 15 * scaleValue, tocolor(255, 255, 255, 255))
    end
end









function getElementSpeed(theElement, unit)
    -- Check arguments for errors
    assert(isElement(theElement), "Bad argument 1 @ getElementSpeed (element expected, got " .. type(theElement) .. ")")
    local elementType = getElementType(theElement)
    assert(elementType == "player" or elementType == "ped" or elementType == "object" or elementType == "vehicle" or elementType == "projectile", "Invalid element type @ getElementSpeed (player/ped/object/vehicle/projectile expected, got " .. elementType .. ")")
    assert((unit == nil or type(unit) == "string" or type(unit) == "number") and (unit == nil or (tonumber(unit) and (tonumber(unit) == 0 or tonumber(unit) == 1 or tonumber(unit) == 2)) or unit == "m/s" or unit == "km/h" or unit == "mph"), "Bad argument 2 @ getElementSpeed (invalid speed unit)")
    -- Default to m/s if no unit specified and 'ignore' argument type if the string contains a number
    unit = unit == nil and 0 or ((not tonumber(unit)) and unit or tonumber(unit))
    -- Setup our multiplier to convert the velocity to the specified unit
    local mult = (unit == 0 or unit == "m/s") and 50 or ((unit == 1 or unit == "km/h") and 180 or 111.84681456)
    -- Return the speed by calculating the length of the velocity vector, after converting the velocity to the specified unit
    return (Vector3(getElementVelocity(theElement)) * mult).length
end
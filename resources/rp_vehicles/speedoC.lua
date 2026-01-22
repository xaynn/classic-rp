local speedometer = {}
speedometer.enabled = false
speedometer.vehicleTypes = {["BMX"]=true, ["BIKE"]=true}
local scaleValue = exports.rp_scale:returnScaleValue()
speedometer.kmh = dxCreateFont('files/Helvetica.ttf', 70 * scaleValue, false, 'proof') or 'default' -- fallback to default
speedometer.font = dxCreateFont('files/Helvetica.ttf', 20 * scaleValue, false, 'proof') or 'default' -- fallback to default
speedometer.fontFuel = dxCreateFont('files/Helvetica.ttf', 12 * scaleValue, false, 'proof') or 'default' -- fallback to default

local offSetX, offsetY = exports.rp_scale:returnOffsetXY()
local maxspeed = nil
speedometer.startX, speedometer.startY = exports.rp_scale:getScreenStartPositionFromBox(50*scaleValue, 50*scaleValue, offSetX, offsetY, "right", "bottom")
speedometer.fuel = dxCreateTexture("files/fuel.png", "argb", true, "clamp", "2d")
speedometer.handbrake = dxCreateTexture("files/handbrake.png", "argb", true, "clamp", "2d")
speedometer.engine = dxCreateTexture("files/engine.png", "argb", true, "clamp", "2d")
speedometer.indicator_left = dxCreateTexture("files/indicator_left.png", "argb", true, "clamp", "2d")
speedometer.indicator_right = dxCreateTexture("files/indicator_right.png", "argb", true, "clamp", "2d")

local loginExport = exports.rp_login

function localVehicleData(fuel)
speedometer.vehicleFuel = fuel
end
addEvent("onLocalVehicleUpdateData", true)
addEventHandler("onLocalVehicleUpdateData", root, localVehicleData)

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
		-- iprint(maxspeed)
		
		triggerServerEvent("getVehicleFuel", localPlayer, true)
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

local function onPlayerWasted()
	if speedometer.enabled then
		speedometer.init(false)
	end
end
addEventHandler("onClientPlayerWasted", localPlayer, onPlayerWasted)

local lastTick = getTickCount()
local lastSoundTime = 0 
local soundInterval = 550
function speedometer.render() -- todo fuel, icon.
    local veh = getPedOccupiedVehicle(localPlayer)
    if veh and getVehicleEngineState(veh) then
        local currentTick = getTickCount()

        local gear = getVehicleCurrentGear(veh)
        local speed = getElementSpeed(veh)

        local formattedSpeed
        -- local offset = 0

        if speed == 0 then
            formattedSpeed = "0"
        elseif speed < 100 then
            formattedSpeed = string.format("%02d", speed)
        else
            -- offset = 20
            formattedSpeed = tostring(speed)
        end

        dxDrawText(math.floor(formattedSpeed),speedometer.startX - 50 * scaleValue,speedometer.startY - 80 * scaleValue,speedometer.startX - 50 * scaleValue,speedometer.startY - 80 * scaleValue,tocolor(255, 255, 255, 255),1,speedometer.kmh,"center","top")

        if gear == 0 then
            gear = "R"
        end
        dxDrawText(gear,speedometer.startX - 200 * scaleValue,speedometer.startY - 20 * scaleValue,speedometer.startX,speedometer.startY,tocolor(255, 255, 255, 255),1,speedometer.font,"left","top")

        local fillRatio = math.min(speed * 1 / maxspeed, 1)

        local barWidth = 250 * scaleValue
        local filledWidth = barWidth * fillRatio

		dxDrawRectangle(speedometer.startX - 200 * scaleValue, speedometer.startY + 30 * scaleValue, barWidth, 15 * scaleValue, tocolor(118, 108, 106, 100)) -- tło paska
		dxDrawRectangle(speedometer.startX - 200 * scaleValue, speedometer.startY + 30 * scaleValue, filledWidth, 15 * scaleValue, tocolor(118, 108, 106, 255)) -- wypełnienie paska
		if speedometer.vehicleFuel then
        dxDrawText(math.floor(speedometer.vehicleFuel) .. "/60L",speedometer.startX,speedometer.startY + 55 * scaleValue,speedometer.startX,speedometer.startY,tocolor(255, 255, 255, 255),1,speedometer.fontFuel,"left","top")
		end
        dxDrawImage(speedometer.startX - 30 * scaleValue,speedometer.startY + 50 * scaleValue,32 * scaleValue,32 * scaleValue,speedometer.fuel,0,0,0,tocolor(255, 255, 255, 255),false)
        dxDrawImage(speedometer.startX - 90 * scaleValue,speedometer.startY + 60 * scaleValue,23 * scaleValue,11 * scaleValue,speedometer.indicator_left,0,0,0,tocolor(255, 255, 255, 50),false)
        dxDrawImage(speedometer.startX - 60 * scaleValue,speedometer.startY + 60 * scaleValue,23 * scaleValue,11 * scaleValue,speedometer.indicator_right,0,0,0,tocolor(255, 255, 255, 50),false)
        if loginExport:getObjectData(veh, "indicator[") then
            dxDrawImage(speedometer.startX - 90 * scaleValue,speedometer.startY + 60 * scaleValue,23 * scaleValue,11 * scaleValue,speedometer.indicator_left,0,0,0,tocolor(15, 181, 9, 150),false)
            if currentTick - lastSoundTime > soundInterval then
                playVehicleSound("blinker")
                lastSoundTime = currentTick
            end
        elseif loginExport:getObjectData(veh, "indicator]") then
            dxDrawImage(speedometer.startX - 60 * scaleValue,speedometer.startY + 60 * scaleValue,23 * scaleValue,11 * scaleValue,speedometer.indicator_right,0,0,0,tocolor(15, 181, 9, 150),false)
            if currentTick - lastSoundTime > soundInterval then
                playVehicleSound("blinker")
                lastSoundTime = currentTick
            end
        elseif loginExport:getObjectData(veh, "indicator;") then
            dxDrawImage(speedometer.startX - 90 * scaleValue,speedometer.startY + 60 * scaleValue,23 * scaleValue,11 * scaleValue,speedometer.indicator_left,0,0,0,tocolor(15, 181, 9, 150),false)
            dxDrawImage(speedometer.startX - 60 * scaleValue,speedometer.startY + 60 * scaleValue,23 * scaleValue,11 * scaleValue,speedometer.indicator_right,0,0,0,tocolor(15, 181, 9, 150),false)
            if currentTick - lastSoundTime > soundInterval then
                playVehicleSound("blinker")
                lastSoundTime = currentTick
            end
        end

        if isElementFrozen(veh) then
            dxDrawImage(speedometer.startX - 130 * scaleValue,speedometer.startY + 55 * scaleValue,25 * scaleValue,25 * scaleValue,speedometer.handbrake,0,0,0,tocolor(255, 0, 0, 255),false)
        end
        -- dxDrawImage(speedometer.startX - 30 * scaleValue, speedometer.startY + 50 * scaleValue, 32*scaleValue, 32*scaleValue, speedometer.fuel, 0,0,0,tocolor(255, 255, 255, 255),false)

        local capPosition = filledWidth
        dxDrawRectangle(speedometer.startX - 200 * scaleValue + capPosition,speedometer.startY + 30 * scaleValue,5 * scaleValue,15 * scaleValue,tocolor(255, 255, 255, 255) )

        if currentTick - lastTick >= 60000 then
            triggerServerEvent("getVehicleFuel", localPlayer)
            lastTick = currentTick
        end
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
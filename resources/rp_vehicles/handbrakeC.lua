local scaleValue = exports.rp_scale:returnScaleValue()
local offsetX, offsetY = exports.rp_scale:returnOffsetXY()
local handbrakeX, handbrakeY = exports.rp_scale:getScreenStartPositionFromBox(64 * scaleValue, 256 * scaleValue, offsetX, offsetY, "right", "bottom")
handbrakeX = handbrakeX - 500 * scaleValue

local lockedArea = {
    minX = handbrakeX + 30 * scaleValue,
    minY = handbrakeY,
    maxX = handbrakeX + 40 * scaleValue,
    maxY = handbrakeY + 256 * scaleValue
}

local handbrakeState = false
local pasekX, pasekY = 0, 0
local stateBlocked, stateUnlocked = false, false

addEventHandler("onClientCursorMove", root, function(_, _, x, y)
    if not handbrakeState or isMTAWindowActive() then return end

    if isCursorShowing() then
        local veh = getPedOccupiedVehicle(localPlayer)
        if not veh then return end

        x = math.max(lockedArea.minX, math.min(lockedArea.maxX, x))
        y = math.max(lockedArea.minY, math.min(lockedArea.maxY, y))
        setCursorPosition(x, y)

        pasekX, pasekY = x - 32 * scaleValue, y - 8 * scaleValue

        local centerY = (lockedArea.minY + lockedArea.maxY) / 2
        local topThird = lockedArea.minY + (centerY - lockedArea.minY) / 2
        local bottomThird = centerY + (lockedArea.maxY - centerY) / 2

        if y < topThird and not stateBlocked then
            setVehicleHandbrake(veh, true)
            stateBlocked = true
            stateUnlocked = false
        elseif y > bottomThird and not stateUnlocked then
            setVehicleHandbrake(veh, false)
            stateUnlocked = true
            stateBlocked = false
        end
    end
end)

addEventHandler("onClientRender", root, function()
    if not handbrakeState or not isCursorShowing() then return end
    dxDrawRectangle(handbrakeX + 28 * scaleValue, handbrakeY, 10 * scaleValue, 256 * scaleValue, tocolor(0, 150, 0), false)
    dxDrawImage(pasekX, pasekY, 64 * scaleValue, 16 * scaleValue, 'files/recznyPasek.png')
end)

function setVehicleHandbrake(vehicle, state)
    triggerServerEvent("onVehicleSetHandbrake", localPlayer, vehicle, state)
    playSound("files/handbrake.mp3")
end

addEventHandler("onClientVehicleExit", root, function(player, seat)
    if player == localPlayer and handbrakeState and seat == 0 then
        handbrakeState = false
        showCursor(false)
        setPedControlState(localPlayer, "handbrake", false)
    end
end)

function handbrakeEnable(_, state)
    local veh = getPedOccupiedVehicle(localPlayer)
    if not veh or getPedOccupiedVehicleSeat(localPlayer) ~= 0 or isMTAWindowActive() or getElementSpeed(veh) > 5 then return end

    if state == "down" then
        handbrakeState = true
        showCursor(true)
    else
        handbrakeState = false
        showCursor(false)
    end
end
bindKey("lalt", "both", handbrakeEnable)

function getElementSpeed(element)
    if not isElement(element) then return false end
    local x, y, z = getElementVelocity(element)
    return (x^2 + y^2 + z^2) ^ 0.5 * 161 
end

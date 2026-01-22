
function fixRotationWithPlayer(ped, pos, pos2)
	local rotZ = findRotation(pos.x, pos.y, pos2.x, pos2.y)
	local WrotZ = findRotation(pos2.x, pos2.y, pos.x, pos.y)
	local rotZ = rotZ-180
	if not(rotZ == WrotZ) then
		setPedRotation(ped, rotZ+180)
	end
end

function findRotation(x1, y1, x2, y2)
    local t = -math.deg(math.atan2(x2 - x1, y2 - y1))
    local rotation = t < 0 and t + 360 or t
    -- outputDebugString("Rotation: " .. rotation) -- Dodaj to w celu debugowania
    return rotation
end

local alphaPeds = {}
local isRenderHandlerRegistered = false

function syncPedCorners(player, data, nowData)
		if not player and not isElement(player) then return end
    if (getElementType(player) == "ped") and (data == "cornerState") then
        if isElement(nowData) then
            now = getTickCount()

            table.insert(alphaPeds, {ped = player, followPlayer = nowData})
            setTimer(movePed, 100, 1, player, nowData)
            setTimer(stopPedCorner, 4000, 1, player)

            if not isRenderHandlerRegistered then
                addEventHandler("onClientRender", getRootElement(), renderAlphaPed)
                isRenderHandlerRegistered = true
            end
        end
        if nowData == "leaving" then
            backwardPed(player)
        end
    end
end



function renderAlphaPed()

    for i, pedData in ipairs(alphaPeds) do
        local ped = pedData.ped
        local followPlayer = pedData.followPlayer

        local progress = getProgress(1500, now)
        local alpha = interpolateBetween(0, 0, 0, 255, 0, 0, progress, "Linear")

        if isElement(ped) and isElement(followPlayer) then
            setElementAlpha(ped, alpha)

            -- Assuming fixRotationWithPlayer is defined
            fixRotationWithPlayer(ped, ped:getPosition(), followPlayer:getPosition())

        end

        if alpha >= 255 then
            table.remove(alphaPeds, i)
        end
    end

    if #alphaPeds == 0 then
        removeEventHandler("onClientRender", getRootElement(), renderAlphaPed)
        isRenderHandlerRegistered = false
    end
end

addEventHandler("onLocalDataPlayerChange", root, syncPedCorners)
function getProgress(addtick, tick)
    local now = getTickCount()
    local elapsedTime = now - tick
    local duration = tick + addtick - tick
    local progress = elapsedTime / duration
    return progress
end

function stopPedCorner(ped)
    if not isElement(ped) then
        return
    end
    -- setPedControlState(ped,"walk", false)
    setPedControlState(ped, "forwards", false)
	setPedAnimation(ped, "DEALER", "shop_pay", 7000, false, false, false, false)

    -- setPedControlState(ped, "backwards", false)
end
function movePed(ped, playerToFollow)
    if not isElement(ped) then
        return
    end

    setPedControlState(ped, "walk", true)
    -- setPedControlState(ped, "backwards", true)
    setPedControlState(ped, "forwards", true)

    local pedX, pedY, pedZ = getElementPosition(ped)
    local playerX, playerY, playerZ = getElementPosition(playerToFollow)

    fixRotationWithPlayer(ped, {x = pedX, y = pedY}, {x = playerX, y = playerY})
end

function backwardPed(ped)
    setPedControlState(ped, "forwards", false)
    setPedControlState(ped, "backwards", true)
    for i, pedData in ipairs(alphaPeds) do
        if pedData.ped == ped then
            table.remove(alphaPeds, i)
            break
        end
    end
end

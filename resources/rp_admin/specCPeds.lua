local specPeds = {}
local backData = {}
local specState = false
local currentSpecIndex = nil

function createTestPeds()
    for i = 1, 5 do
        local x, y, z = getElementPosition(localPlayer)
        local ped = createPed(math.random(0, 312), x + math.random(-5, 5), y + math.random(-5, 5), z)
        table.insert(specPeds, ped)
    end
end

function specPlayer(state, targetPed)
    if state then
        specState = true
        backData.x, backData.y, backData.z = getElementPosition(localPlayer)
        backData.dimension, backData.interior = getElementDimension(localPlayer), getElementInterior(localPlayer)
        specPeds = {}
        createTestPeds()
        
        if #specPeds == 0 then return end
        
        currentSpecIndex = 1
        for i, ped in ipairs(specPeds) do
            if ped == targetPed then
                currentSpecIndex = i
                break
            end
        end

        setElementPosition(localPlayer, 0, 0, -1)
        setElementFrozen(localPlayer, true)
        if specState then
            bindKey("arrow_l", "up", specPreviousPlayer)
            bindKey("arrow_r", "up", specNextPlayer)
        end

        setCustomCameraTarget(specPeds[currentSpecIndex])
    else
        specState = false
        
        unbindKey("arrow_l", "up", specPreviousPlayer)
        unbindKey("arrow_r", "up", specNextPlayer)
        
        setCustomCameraTarget()
        setCameraTarget(localPlayer)
        backData = {}
    end
end
addEvent("onPlayerToggleSpec", true)
addEventHandler("onPlayerToggleSpec", getRootElement(), specPlayer)

function specNextPlayer()
    if not specState or not currentSpecIndex then return end
    currentSpecIndex = (currentSpecIndex % #specPeds) + 1
    local target = specPeds[currentSpecIndex]
    setCustomCameraTarget(target)
end

function specPreviousPlayer()
    if not specState or not currentSpecIndex then return end
    currentSpecIndex = (currentSpecIndex - 2) % #specPeds + 1
    local target = specPeds[currentSpecIndex]
    setCustomCameraTarget(target)
end

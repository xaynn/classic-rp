local specPlayers = {}
local backData = {}
local specState = false
local loginData = exports.rp_login
local currentSpecIndex = nil


function refreshSpecList()
	triggerServerEvent("onClientRefreshSpecList", localPlayer)
end

function onPlayerGotRefreshedSpecList(data)
	tableServerPlayers = data

end
addEvent("onPlayerGotSpecListData", true)
addEventHandler("onPlayerGotSpecListData", getRootElement(), onPlayerGotRefreshedSpecList)

function specPlayer(state, targetPlayer, serverPlayers)
    if state then
        specState = true
        backData.x, backData.y, backData.z = getElementPosition(localPlayer)
        backData.dimension, backData.interior = getElementDimension(localPlayer), getElementInterior(localPlayer)
        
		tableServerPlayers = serverPlayers
        
        if #tableServerPlayers == 0 then return end
        
        currentSpecIndex = 1
        for i, player in ipairs(tableServerPlayers) do
            if player == targetPlayer then
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

        setCustomCameraTarget(tableServerPlayers[currentSpecIndex])
        triggerServerEvent("onClientChangeSpecPlayer", localPlayer, tableServerPlayers[currentSpecIndex])
    else
        specState = false
		tableServerPlayers = {}
        triggerServerEvent("onClientPlayerStopSpectating", localPlayer, backData)
        
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
	refreshSpecList()
    currentSpecIndex = (currentSpecIndex % #tableServerPlayers) + 1
    local target = tableServerPlayers[currentSpecIndex]
    setCustomCameraTarget(target)
    triggerServerEvent("onClientChangeSpecPlayer", localPlayer, target)
end

function specPreviousPlayer()
    if not specState or not currentSpecIndex then return end
	refreshSpecList()
    currentSpecIndex = (currentSpecIndex - 2) % #tableServerPlayers + 1
    local target = tableServerPlayers[currentSpecIndex]
    setCustomCameraTarget(target)
    triggerServerEvent("onClientChangeSpecPlayer", localPlayer, target)
end


function onPlayerQuit()
    if not specState or not tableServerPlayers then return end
	refreshSpecList()
    for i, player in ipairs(tableServerPlayers) do
        if player == source then
            table.remove(tableServerPlayers, i)

            if i == currentSpecIndex then
                if #tableServerPlayers > 0 then
                    currentSpecIndex = (i - 1) % #tableServerPlayers + 1
                    specNextPlayer()
                else
                    specPlayer(false) 
                end
            end
            break
        end
    end
end
addEventHandler("onClientPlayerQuit", getRootElement(), onPlayerQuit)




-- onclientplayerquit
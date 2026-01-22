local healthTimer 
local count = 0
local disableTimer
local localPlayerDrugged = false

function onPlayerUseDrug(id)
    if isTimer(healthTimer) then
        killTimer(healthTimer)
    end
    if id == 1 then
        healthTimer = setTimer(addHealth, 500, 0, 5) -- maryha
        setGameSpeed(0.9)
    elseif id == 2 then -- haszysz
        healthTimer = setTimer(addHealth, 500, 0, 10)
    elseif id == 3 then -- koks
        healthTimer = setTimer(addHealth, 500, 0, 20)
        setGameSpeed(1.2)
    end
    disableTimer = setTimer(disableNarcotic, 300000, 1)
	localPlayerDrugged = id
end

addEvent("onPlayerUseDrug", true)
addEventHandler("onPlayerUseDrug", root, onPlayerUseDrug)

function disableNarcotic()
	setGameSpeed(1.0)
	triggerServerEvent("onPlayerSobrietyFromNarcotic", localPlayer)
	localPlayerDrugged = false
end

function addHealth(healthCount)
	if count >= 8 then killTimer(healthTimer) count = 0 return end
	count = count + 1
	local health = getElementHealth(localPlayer)
	setElementHealth(localPlayer, health + healthCount)
end

function isPlayerDrugged()
	return localPlayerDrugged
end

-- onPlayerUseDrug(1)



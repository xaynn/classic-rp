local seconds = 0
local sx, sy = guiGetScreenSize()
local scaleValue = exports.rp_scale:returnScaleValue()
-- local font = dxCreateFont("files/Helvetica.ttf", 15 * scaleValue, false, "proof") or "default" -- fallback to default
local offsetX, offsetY = exports.rp_scale:returnOffsetXY()
local bwTimer = false
local startX, startY = exports.rp_scale:getScreenStartPositionFromBox(1 * scaleValue, 1 * scaleValue, 0, offsetY, "center", "bottom")
startX = startX - 100 *scaleValue
local sound = false
function onGotBWTime(secs, state)
    if state then
        removeEventHandler("onClientRender", root, drawBW)
		if isTimer(bwTimer) then killTimer(bwTimer) end
		seconds = 0
		setCameraDrunkLevel(0)
		exports.rp_admin:setCustomCameraTarget(false)
		if isElement(sound) then destroyElement(sound) end
    else
        seconds = secs
		setTimer ( function()
		        addEventHandler("onClientRender", root, drawBW) -- fix, when its done instant then onClientElementStreamIn wont be triggered.
				exports.rp_admin:setCustomCameraTarget(localPlayer)
				sound = playSound("files/heartbeat.mp3", true)
				setSoundVolume(sound, 0.01)
		end, 50, 1 )
        -- bwTimer = setTimer(decBW, 1000, 0)
    end
end

addEvent("onGotBWTime", true)
addEventHandler("onGotBWTime", root, onGotBWTime)

function decBW(serverSeconds)
    -- seconds = seconds - 1
	seconds = serverSeconds
end
addEvent("updateBWTime", true)
addEventHandler("updateBWTime", getRootElement(), decBW)
local font = dxCreateFont("files/Helvetica.ttf", 15, true, "proof")
local heartbeatStart = getTickCount()
local heartbeatInterval = 1000 -- co ile ms jest uderzenie serca
local heartbeatFadeTime = 1000 -- jak długo trwa fade

function drawHeartbeatEffect()
    local now = getTickCount()
    local sinceLastBeat = (now - heartbeatStart) % heartbeatInterval

    local alpha = 0
    if sinceLastBeat < heartbeatFadeTime then
        local progress = sinceLastBeat / heartbeatFadeTime
        if progress <= 0.5 then
            alpha = interpolateBetween(0, 0, 0, 150, 0, 0, progress * 2, "OutQuad")
        else
            alpha = interpolateBetween(150, 0, 0, 0, 0, 0, (progress - 0.5) * 2, "InQuad")
        end
    end

    dxDrawRectangle(0, 0, sx, sy, tocolor(200, 0, 0, alpha))
end

function drawBW()
	-- drawHeartbeatEffect()
	-- local x,y,z = getElementPosition(localPlayer)
	dxDrawRectangle ( 0,0,sx,sy, tocolor ( 115, 2, 2, 100) )
    if seconds > 0 then
        dxDrawText("BW: " .. secondsToMinutes(seconds),startX,startY,startX,startY,tocolor(255, 255, 255, 255),1*scaleValue,font,"left","top",false,false,false,false,true)
		-- setCameraMatrix (x,y,z+10,x,y,z-40)
    end
end

function secondsToMinutes(seconds)
    local minutes = math.floor(seconds / 60)
    local remaining_seconds = seconds % 60
    return string.format("%d minut, %d sekund", minutes, remaining_seconds)
end

function hasPlayerBW()
    if seconds > 0 then
        return true
    else
        return false
    end
end

local txd = engineLoadTXD ( "files/bodybag.txd" )
engineImportTXD ( txd, 2070 )
local dff = engineLoadDFF ( "files/bodybag.dff" )
engineReplaceModel ( dff, 2070 )
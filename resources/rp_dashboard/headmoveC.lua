headmove = {}
local sx, sy = guiGetScreenSize()
-- headmove.others = true
function headmove.enable(state, others)
    if state ~= nil then
        headmove.state = state

        if isTimer(headmove.timer) then
            killTimer(headmove.timer)
        end

        if isTimer(headmove.localHead) then
            killTimer(headmove.localHead)
        end

        if state then
            headmove.timer = setTimer(headmove.triggerEvent, 3000, 0)
            headmove.localHead = setTimer(timerLocalPlayerHead, 150, 0)
        else
            setPedLookAt(localPlayer, 0, 0, 0, 100)
        end
    end

    if others ~= nil then
        headmove.others = others
        if not headmove.others then
            for _, v in ipairs(getElementsByType("player")) do
                if v ~= localPlayer then
                    setPedLookAt(v, 0, 0, 0, 100)
                end
            end
        end
    end
end




function timerLocalPlayerHead()
	local veh = getPedOccupiedVehicle(localPlayer)
	if veh then return end
    local fX, fY, fZ = getWorldFromScreenPosition(sx / 2, sy / 2, 10)
    setPedLookAt(localPlayer, fX, fY, fZ, -1, 0)
end

function headmove.commands(cmand, arg)
	exports.rp_library:createBox("Headmove znajduje się pod dashboardem.")
    -- if not arg or (arg ~= "ja" and arg ~= "inni") then
        -- return exports.rp_library:createBox("/headmove [ja/inni]")
    -- end
    -- if arg == "ja" then
        -- setPedLookAt(localPlayer, 0, 0, 0, 100)
        -- exports.rp_library:createBox("Zmieniłeś /headmove ja")
        -- headmove.enable(not headmove.state)
    -- elseif arg == "inni" then
        -- headmove.others = not headmove.others
        -- if not headmove.others then
            -- for k, v in ipairs(getElementsByType("player")) do
                -- exports.rp_library:createBox("Zmieniłeś /headmove inni")
                -- if v ~= localPlayer then
                    -- setPedLookAt(v, 0, 0, 0, 100)
                -- end
            -- end
        -- end
    -- end
end
addCommandHandler("headmove", headmove.commands, false, false)

  
local loginData = exports.rp_login 
local g_fLastX, g_fLastY, g_fLastZ = 0, 0, 0 
function headmove.triggerEvent() -- create timer, kill timer
    if headmove.state then
        local fX, fY, fZ = getWorldFromScreenPosition(sx / 2, sy / 2, 10)
        if fX == g_fLastX and fY == g_fLastY and fZ == g_fLastZ then
            return
        end
		local veh = getPedOccupiedVehicle(localPlayer)
		if veh then return end
		if isPedAiming(localPlayer) then return end
        -- setPedLookAt(localPlayer, fX, fY, fZ, -1, 0)
        g_fLastX, g_fLastY, g_fLastZ = fX, fY, fZ
        local targetPlayers = getElementsByType("player", getRootElement(), true)
		local tmpTablePlayers = {}

        for k, v in pairs(targetPlayers) do
			local distance = exports.rp_utils:getDistanceBetweenElements(localPlayer, v)
            if distance > 30 and v ~= localPlayer then
                table.insert(tmpTablePlayers, v)
            end
        end
        triggerLatentServerEvent("onPlayerHeadChangedPosition", 5000, false, localPlayer, localPlayer, fX, fY, fZ, targetPlayers)
    end
end

function isPedAiming (thePedToCheck)
	if isElement(thePedToCheck) then
		if getElementType(thePedToCheck) == "player" or getElementType(thePedToCheck) == "ped" then
			if getPedTask(thePedToCheck, "secondary", 0) == "TASK_SIMPLE_USE_GUN" or isPedDoingGangDriveby(thePedToCheck) then
				return true
			end
		end
	end
	return false
end


function headmove.updateHeadRotation(player, x, y, z)
	if not headmove.others then return end
	if not isElement(player) or type(x) ~= "number" or type(y) ~= "number" or type(z) ~= "number" then 
            return 
       end
	setPedAimTarget ( player, x, y, z )
    setPedLookAt(player, x, y, z, -1, 0) 
end

addEvent("onPlayerUpdateHeadPosition", true)
addEventHandler("onPlayerUpdateHeadPosition", getRootElement(), headmove.updateHeadRotation)
-- headmove.enable(true)
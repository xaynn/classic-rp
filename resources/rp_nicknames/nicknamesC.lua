local showLocalNickname = false
local enabledNicknames = true
local scaleValue = exports.rp_scale:returnScaleValue()
local nametags = {}
local lastRefreshTime = 0
local refreshInterval = 13 -- ms
local font = dxCreateFont('files/Helvetica.ttf', 15 * scaleValue, true, 'proof')
local fonth1 = dxCreateFont('files/Helvetica.ttf', 13 * scaleValue, true, 'proof')
local fonth2 = dxCreateFont('files/Helvetica.ttf', 10 * scaleValue, true, 'proof')
local fonth3 = dxCreateFont('files/Helvetica.ttf', 12 * scaleValue, true, 'proof')
local fonth4 = dxCreateFont('files/Helvetica.ttf', 12 * scaleValue, true, 'proof')


local hitPlayers = {}
local hitTimers = {}
local maxDistance = 33
local disconnectedPlayers = {}
local data = exports.rp_login
local DGS = exports.dgs
local utilsData = exports.rp_utils
local localPlayerGotDMG = false
local sx, sy = guiGetScreenSize()
local adminRanks = {
    [3] = {"Administrator", 161, 8, 8},
    [2] = {"Community Manager", 9, 89, 22},
    [1] = {"Supporter", 26, 23, 212},
}
local streamedPlayers = {}
local streamedVehicles = {}
local streamedPeds = {}


function renderVehicleDesc() --todo
    local cx, cy, cz = getCameraMatrix()
	local time = localPlayerGotDMG
	if(tonumber(time)) then
		local progress = (getTickCount() - time) / 1000
		if(progress > 0 and progress < 1) then
			local alpha = interpolateBetween(255, 0, 0, 0, 0, 0, progress, "Linear")
			dxDrawImage(0, 0, sx, sy, "files/dmg.png", 0, 0, 0, tocolor(255, 255, 255, alpha))
		end
	end

    for v, k in pairs(streamedVehicles) do
        if isElement(v) and isElementOnScreen(v) then
            local nx, ny, nz = getElementPosition(v)
            local dist = getDistanceBetweenPoints3D(nx, ny, nz, cx, cy, cz)
            local progress = dist / maxDistance
            local desc = data:getObjectData(v, "desc")
            if desc then
                if progress < 1 then
                    local x, y, z = getElementPosition(v)
                    local alphac, scale = interpolateBetween(255, 1, 0, 0, 0.5, 0, progress, "Linear")
                    if isLineOfSightClear(cx, cy, cz, x, y, z, true, false, false, true, false, false, false) then
                        local sx, sy = getScreenFromWorldPosition(x, y, z, 25, false)
                        if sy then
                            dxDrawText(desc,sx,sy,sx,sy,tocolor(255, 235, 180, alphac),scale * 0.7,font,"center","center",false,false,false,true,true)
                        end
                    end
                end
            end
        end
    end
end


addEventHandler("onClientRender", root, renderVehicleDesc)


	
	
function renderDisconnectedPlayers()
    local cx, cy, cz = getCameraMatrix()

    for _, wartosc in ipairs(disconnectedPlayers) do
        local px, py, pz = wartosc.position[1], wartosc.position[2], wartosc.position[3]

        local sx, sy = getScreenFromWorldPosition(px, py, pz, 25, false)
        if sx and sy then
            local dist = getDistanceBetweenPoints3D(px, py, pz, cx, cy, cz)
            local progress = math.min(dist / 40, 1)
            
            if progress < 1 and dist > 3 then
                local alpha, scale = interpolateBetween(255, 1, 0, 0, 0.5, 0, progress, "Linear")
                local textScale = 1 * scale

                dxDrawText(wartosc.playerName, sx, sy, sx, sy, tocolor(255, 255, 255, alpha), textScale, font, "center", "center", false, false, false, true, true)
                dxDrawText(wartosc.quitType, sx, sy + 20, sx, sy + 20, tocolor(255, 235, 255, alpha), textScale, font, "center", "center", false, false, false, true, true)
            end
        end
    end
end

local addedRenderDisconnect = false
function onPlayerDisconnected(player, position, quitType, playerName)
	table.insert(disconnectedPlayers, {player = player, position = position, quitType = quitType, playerName = playerName})
	if #disconnectedPlayers > 0 and not addedRenderDisconnect then
		addEventHandler("onClientRender", root, renderDisconnectedPlayers)
		addedRenderDisconnect = true
	end
	setTimer ( removeDisconnectedPlayer, 10000, 1, player)
end
addEvent("onClientPlayerDisconnected", true)
addEventHandler("onClientPlayerDisconnected", getRootElement(), onPlayerDisconnected)
function removeDisconnectedPlayer(player)
	for k,v in ipairs(disconnectedPlayers) do
		if v.player == player then
			table.remove(disconnectedPlayers, k)
			if #disconnectedPlayers == 0 then
				removeEventHandler("onClientRender", root, renderDisconnectedPlayers)
				addedRenderDisconnect = false
			end
		end
	end
end

function changeColorByDamagePed(attacker)
    local source = source
    hitPlayers[source] = true
    if hitTimers[source] and isTimer(hitTimers[source]) then
        killTimer(hitTimers[source])
    end
    hitTimers[source] = setTimer(function()
        hitPlayers[source] = false
    end, 3000, 1)
end
addEventHandler("onClientPedDamage", getRootElement(), changeColorByDamagePed)

local localDmgTimer = false
function changeColorByDamagePlayer(attacker, weapon, bodypart)
    local source = source
    hitPlayers[source] = true
    if source == localPlayer and not localPlayerGotDMG then
        localPlayerGotDMG = getTickCount()
        if localDmgTimer and isTimer(localDmgTimer) then
            killTimer(localDmgTimer)
        end
        localDmgTimer = setTimer(function()
                localPlayerGotDMG = false
            end,3000,1)
    end
    if hitTimers[source] and isTimer(hitTimers[source]) then
        killTimer(hitTimers[source])
    end
    hitTimers[source] =setTimer(function()
            hitPlayers[source] = false
        end,3000,1)
end
addEventHandler("onClientPlayerDamage", root, changeColorByDamagePlayer)




function wastedPlayer ( killer, weapon, bodypart )
   if isPedInVehicle(source) then return end
   setElementCollisionsEnabled(source,false)
end
addEventHandler ( "onClientPlayerWasted", getRootElement(), wastedPlayer )


function spawnedPlayerCollision ()
setElementCollisionsEnabled(source,true)
end
addEventHandler ( "onClientPlayerSpawn", root, spawnedPlayerCollision )

local keys = getBoundKeys("chatbox")
local firstKeyName = next(keys)
local secondKeyName = next(keys, firstKeyName)
chatBoxKey = firstKeyName
chatBoxKeySecond = secondKeyName


local lastKeyPressTime = 0
local keyCooldown = 50

function onKey(button, press)
    if button == chatBoxKey or button == chatBoxKeySecond then
            setTimer(
                function()
                    if isChatBoxInputActive() then
                        exports.rp_login:setPlayerData(localPlayer, "chatTyping", true)
                        triggerLatentServerEvent("onChatTyping", 5000, false, localPlayer, true)
                    end
                end, 300, 1)
    end
end

addEventHandler(
    "onClientKey", root,
    function(button, press)
        if (button == "enter" or button == "escape") and press then
                setTimer(
                    function()
                        if not isChatBoxInputActive() and exports.rp_login:getPlayerData(localPlayer, "chatTyping") then
                            exports.rp_login:setPlayerData(localPlayer, "chatTyping", false)
                            triggerLatentServerEvent("onChatTyping", 5000, false, localPlayer, false)
                        end
                    end, 300, 1)
        end
    end
)

-- Bindowanie klawiszy
bindKey(firstKeyName, "down", onKey)
bindKey(secondKeyName, "down", onKey)

function setEnabledNicknames()
    enabledNicknames = not enabledNicknames
    if enabledNicknames then
        addEventHandler("onClientRender", root, renderNametags)
    else
		removeEventHandler("onClientRender", root, renderNametags)
    end
end
addCommandHandler("tognames", setEnabledNicknames, false, false)

function togme(state)
    -- showLocalNickname = not showLocalNickname
	
	if state then
		addNametag(localPlayer)
	else
		destroyNameTag(localPlayer)
	end
    -- if showLocalNickname then
        -- addNametag(localPlayer)
    -- else
        -- destroyNameTag(localPlayer)
    -- end
end
addCommandHandler("togname", togme, false, false)

function loadPlayerNicknames()
        addEventHandler("onClientRender", root, renderNametags)
		setTimer(updateRenderTarget, 200, 0)
		-- addNametag(localPlayer)
end

function setNicknamesState(state)
	--if tog ja
	enabledNicknames = state
    if enabledNicknames then
        addEventHandler("onClientRender", root, renderNametags)
    else
		removeEventHandler("onClientRender", root, renderNametags)
    end
end

-- addEventHandler("onClientPedStep", localPlayer,
     -- function(leftFoot)
	-- setTimer(updateRenderTarget, 100, 1)
     -- end
-- )

-- createPedsInCircle()
local streamQueue = {}
local queueInterval = 50 -- ms


function processStreamQueue()
    if #streamQueue > 0 then
        local element = table.remove(streamQueue, 1)
			if not isElement(element) then return end -- moze byc bug
            triggerServerEvent("returnPlayerData", localPlayer, element)
    end
end
setTimer(processStreamQueue, queueInterval, 0)

addEventHandler("onClientElementStreamIn", root,
    function ()
        local elementType = getElementType(source)
            if isElementLocal(source) then return end
            if elementType == "player" then
                setPlayerNametagShowing(source, false)
                streamedPlayers[source] = true
				addNametag(source)
            elseif elementType == "ped" then
                streamedPeds[source] = true
				addNametag(source)
            elseif elementType == "vehicle" then
                streamedVehicles[source] = true
            end

            table.insert(streamQueue, source)
    end
)

addEventHandler("onClientElementStreamOut", root,
    function ()
        local elementType = getElementType(source)
        if elementType == "player" then
            streamedPlayers[source] = nil
			destroyNameTag(source)
        elseif elementType == "ped" then
            streamedPeds[source] = nil
			destroyNameTag(source)
        elseif elementType == "vehicle" then
            streamedVehicles[source] = nil
        end
    end
)

			



addEventHandler(
    "onClientVehicleCollision",
    getRootElement(),
    function(collider, damageImpulseMag, bodyPart, x, y, z, nx, ny, nz)
        local fDamageMultiplier = getVehicleHandling(source).collisionDamageMultiplier

        local occupants = getVehicleOccupants(source)
        if not occupants then
            return
        end
        for seat, player in pairs(occupants) do
            if player then
                if (damageImpulseMag * fDamageMultiplier * 0.09) > 10 then
                    hitPlayers[player] = true
                    if hitTimers[player] and isTimer(hitTimers[player]) then
                        killTimer(hitTimers[player])
                    end
                    hitTimers[player] = setTimer(
                        function()
                            hitPlayers[player] = false
                        end,3000,1)
                end
            end
        end
    end
)





function getPlayerRenderData(player)
    local elementType = getElementType(player)
    local playerName

    if elementType == "player" then
        local icName = utilsData:getPlayerICName(player)
		if not icName then return end
        local oocName = getPlayerName(player)
        local isDutyEnabled = data:getPlayerData(localPlayer, "adminDuty")
        playerName = isDutyEnabled and (icName .. " (" .. oocName .. ")") or icName
    elseif elementType == "ped" then
        playerName = data:getPlayerData(player, "visibleName")
    end

    if not playerName then return end

    local tmpTable = {
        desc = data:getPlayerData(player, "desc") or false,
        ame = data:getPlayerData(player, "ame") or false,
        fullName = playerName,
        adminLevel = data:getPlayerData(player, "adminlevel") or false,
        adminDuty = data:getPlayerData(player, "adminDuty") or false,
        groupDuty = data:getPlayerData(player, "groupDuty") or false,
        playerID = data:getPlayerData(player, "playerID") or false,
        charStatus = data:getPlayerData(player, "charStatuses") or {},
		premium = data:getPlayerData(player,"premium") or false,
        masked = string.find(playerName, "Zamaskowany") or string.find(playerName, "Zamaskowana") or false,
    }

    tmpTable.adminData = tmpTable.groupDuty or tmpTable.adminDuty or {}

    if nametags[player] then
        nametags[player].playerData = tmpTable
    end
end






local renderTargetWidth = 512 * scaleValue
local renderTargetHeight = 256 * scaleValue

function addNametag(player)
nametags[player] = {
    rt = dxCreateRenderTarget(renderTargetWidth, renderTargetHeight, true),
    offset = {renderTargetWidth / 2, renderTargetHeight / 2}, -- środek
    rtSize = {renderTargetWidth, renderTargetHeight}, 
    v3Offset = 0.6,
    playerData = {},
}
end



function updateRenderTarget()
    for elem, data in pairs(nametags) do
        if isElement(elem) and isElement(data.rt) then 
            if dxSetRenderTarget(data.rt, true) then
                dxSetBlendMode("modulate_add")
                dxDrawRectangle(0, 0, data.rtSize[1], data.rtSize[2], tocolor(0, 0, 0, 0))

                getPlayerRenderData(elem)
                local info = nametags[elem]
                local name = info.playerData.fullName
                local playerID = info.playerData.playerID
				local charStatuses = info.playerData.charStatus or {}
				local duty = info.playerData.adminData or {}
				local desc = info.playerData.desc
				local ame = info.playerData.ame 
				local masked = info.playerData.masked
				local premium = info.playerData.premium or false

                local actualColor = "#ffffff"
				if premium then actualColor = "#fcc305" end
                if hitPlayers[elem] then
                    actualColor = "#bf1717"
                elseif isPedDead(elem) then
                    actualColor = "#2e2d2d"
                end
				
				local textY = 60 * scaleValue
local nickOffset = 5

if name and not masked then
    local fullText = actualColor .. name .. " #ffffff(" .. playerID .. ")"
    local textWidth = dxGetTextWidth(fullText, 1, fonth1, true)
    local xOffset = (data.rtSize[1] - textWidth) / 2 + nickOffset
    dxDrawText(fullText, xOffset, textY, xOffset + textWidth, data.rtSize[2], tocolor(255, 255, 255, 255), 1, fonth1, "left", "top", false, false, false, true)
elseif name then
    local fullText = actualColor .. name
    local textWidth = dxGetTextWidth(fullText, 1, fonth1, true)
    local xOffset = (data.rtSize[1] - textWidth) / 2 + nickOffset
    dxDrawText(fullText, xOffset, textY, xOffset + textWidth, data.rtSize[2], tocolor(255, 255, 255, 255), 1, fonth1, "left", "top", false, false, false, true)
end

-- statusy postaci
if #charStatuses > 0 then
    local statusText = "(" .. table.concat(charStatuses, ", ") .. ")"
    local textWidth = dxGetTextWidth(statusText, 1, fonth2)
    local xOffset = (data.rtSize[1] - textWidth) / 2 + nickOffset
    dxDrawText(statusText, xOffset, 80 * scaleValue, xOffset + textWidth, data.rtSize[2], tocolor(255, 255, 255, 255), 1, fonth2, "left", "top", false, false, false, false, true)
end

-- duty
if #duty > 0 then
    local dutyText = duty[1]
    local textWidth = dxGetTextWidth(dutyText, 1, fonth4)
    local xOffset = (data.rtSize[1] - textWidth) / 2 + nickOffset
    dxDrawText(dutyText, xOffset, 40 * scaleValue, xOffset + textWidth, data.rtSize[2], tocolor(duty[2], duty[3], duty[4], 255), 1, fonth4, "left", "top", false, false, false, true, true)
end

-- ame
if ame then
    local textWidth = dxGetTextWidth(ame, 1, fonth3)
    local xOffset = (data.rtSize[1] - textWidth) / 2 + nickOffset
    dxDrawText(ame, xOffset, 0, xOffset + textWidth, data.rtSize[2], tocolor(220, 162, 244, 255), 1, fonth3, "center", "top", false, false, false, true, true)
end

                dxSetBlendMode("blend")
                dxSetRenderTarget() 
            end
        end
    end
end




function renderNametags()
    local cx, cy, cz = getCameraMatrix()

    for elem, v in pairs(nametags) do
        if isElement(elem) and getElementAlpha(elem) > 0 then

            local boneX, boneY, boneZ
            if isPedDead(elem) then
                boneX, boneY, boneZ = getElementPosition(elem)
                boneZ = boneZ - 0.5 
            else
                boneX, boneY, boneZ = getPedBonePosition(elem, 6)
            end

            local dist = getDistanceBetweenPoints3D(cx, cy, cz, boneX, boneY, boneZ)

            if dist <= maxDistance then
                local progress = dist / maxDistance
                if progress < 1 then
                    local isInVehicle = isPedInVehicle(elem)
                    local offsetZ = isInVehicle and 0.01 or 0.01
                    local renderZ = boneZ + offsetZ - 0.1 + (1 * (0.35 - progress))

                    local screenX, screenY = getScreenFromWorldPosition(boneX, boneY, renderZ, 25, false)
                    if screenX and isLineOfSightClear(cx, cy, cz, boneX, boneY, boneZ, true, false, false, true, false, false, false) then
                        local alpha, scale = interpolateBetween(255, 1.3, 0, 0, 0.5, 0, progress, "Linear")

                        dxDrawImage(
                            screenX - (v.rtSize[1] * scale) / 2,
                            screenY - (v.rtSize[2] * scale) / 2,
                            v.rtSize[1] * scale,
                            v.rtSize[2] * scale,
                            v.rt,
                            0, 0, 0,
                            tocolor(255, 255, 255, alpha),
                            false
                        )

                        local desc = v.playerData and v.playerData.desc
                        if desc and dist <= 10 then
							local descX, descY, descZ = getPedBonePosition(elem, 1)
                            local textX, textY = getScreenFromWorldPosition(descX, descY, descZ)
                            if textX then
                                dxDrawText(
                                    desc, textX, textY, textX, textY,
                                    tocolor(238, 252, 220, alpha),
                                    0.5, font, "center", "top", false, false, false, true, true
                                )
                            end
                        end
                    end
                end
            end
        end
    end
end



function destroyNameTag(player)
    local isSetNameTag = nametags[player]
    if not isSetNameTag then
        return
    end
    destroyElement(nametags[player].rt)
    nametags[player] = nil
end

-- addNametag(localPlayer)
-- addEventHandler("onClientRender", root, renderNametags)
		-- setTimer(updateRenderTarget, 200, 0)
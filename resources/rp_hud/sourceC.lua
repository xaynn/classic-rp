DGS = exports.dgs
local scaleValue = exports.rp_scale:returnScaleValue()
local font = dxCreateFont('assets/Helvetica.ttf', 15 * scaleValue, false, 'proof') or 'default' -- fallback to default
local offSetX, offsetY = exports.rp_scale:returnOffsetXY()
local nameX, nameY = exports.rp_scale:getScreenStartPositionFromBox(400*scaleValue, 100*scaleValue, offSetX, offsetY, "right", "top")
local components = {"ammo", "clock", "money", "radar", "weapon", "health", "armour", "area_name", "vehicle_name"}
local fontNick = dxCreateFont('assets/Helvetica.ttf', 12 * scaleValue, false, 'proof') or 'default' -- fallback to default
local fontCash = dxCreateFont('assets/Helvetica.ttf', 15 * scaleValue, false, 'proof') or 'default' -- fallback to default
local fontDuty = dxCreateFont('assets/Helvetica.ttf', 11 * scaleValue, false, 'proof') or 'default' -- fallback to default

local startXWeapon = nameX+70*scaleValue
local startYWeapon = nameY+75*scaleValue
local weaponWidth = 299*scaleValue
local weaponHeight = 57*scaleValue
local loginData = exports.rp_login
local utilsData = exports.rp_utils
local renderInfo = {}

function initHud(state, enableDefaultHud)
    if state then
        addEventHandler("onClientRender", root, renderInfo.hud)
		addEventHandler("onClientRender", root, renderRadar, false, "high+3")
        for k, v in pairs(components) do
            setPlayerHudComponentVisible(v, false)
        end
    else
        for k, v in pairs(renderInfo) do
            if isElement(v) then
                destroyElement(v)
            end
        end
        if enableDefaultHud then
            for k, v in pairs(components) do
                setPlayerHudComponentVisible(v, true)
            end
        else
			for k,v in pairs(components) do
            setPlayerHudComponentVisible(v, false)
			end
        end
        removeEventHandler("onClientRender", root, renderRadar)
        removeEventHandler("onClientRender", root, renderInfo.hud)
    end
end


function isMelee( weapon )
   return weapon and weapon <= 15
end

local dutyTime = 0
local playerName = false
local duty = false
local money = false
local playerID = false
local dutyText = false
local renderTarget = dxCreateRenderTarget(400 * scaleValue, 60 * scaleValue, true)
local needsUpdate = true -- Flaga do aktualizacji render targeta

local function updateRenderTarget()
    if not renderTarget or not playerID then return end
    dxSetRenderTarget(renderTarget, true)
    dxSetBlendMode("modulate_add")

    dxDrawRoundedRectangle(0, 0, 400 * scaleValue, 60 * scaleValue, 5, tocolor(19, 23, 24, 255), false)

    local fullName = playerName .. " (" .. playerID .. ")"
    dxDrawText(fullName, 10 * scaleValue, 10 * scaleValue, 10 * scaleValue, 10 * scaleValue, tocolor(226, 227, 227, 255), 1, fontNick, "left", "top")

    dxDrawText(money .. "$", 390 * scaleValue, 15 * scaleValue, 390 * scaleValue, 15 * scaleValue, tocolor(27, 150, 14, 255), 1, fontCash, "right", "top")

    if duty and duty[1] then
        dxDrawText(dutyText, 10 * scaleValue, 32 * scaleValue, 10 * scaleValue, 32 * scaleValue, tocolor(duty[2], duty[3], duty[4], 255), 1, fontDuty, "left", "top")
    end

    dxSetBlendMode("blend")
    dxSetRenderTarget() 
end
local lastAmmoInClip = 0
local lastTotalAmmo = 0
local ammoText = ""
local ammoTextWidth = 0
function renderInfo.hud()
    if playerName and playerID then
        if needsUpdate then
            updateRenderTarget() 
            needsUpdate = false
        end

        dxDrawImage(nameX, nameY, 400 * scaleValue, 60 * scaleValue, renderTarget, 0, 0, 0, tocolor(255, 255, 255, 255))

        local weaponID = getPedWeapon(localPlayer)
        if weaponID and not isMelee(weaponID) then
            local ammoInClip = getPedAmmoInClip(localPlayer)
            local totalAmmo = getPedTotalAmmo(localPlayer) - ammoInClip
            if ammoInClip ~= lastAmmoInClip or totalAmmo ~= lastTotalAmmo then
                lastAmmoInClip = ammoInClip
                lastTotalAmmo = totalAmmo
                ammoText = ammoInClip .. "/" .. totalAmmo
                ammoTextWidth = dxGetTextWidth(ammoText, scale, fontNick)
            end

            dxDrawRoundedRectangle(startXWeapon, startYWeapon, weaponWidth, weaponHeight, 5, tocolor(19, 23, 24, 255), false, true)
            dxDrawImage(startXWeapon + 35 * scaleValue, startYWeapon + 3 * scaleValue, 174 * scaleValue, 50 * scaleValue, "assets/weapons/" .. weaponID .. ".png", 0, 0, 0, tocolor(255, 255, 255, 255), true)

            dxDrawText(ammoText, 
                       startXWeapon + 250 * scaleValue, 
                       startYWeapon + 17 * scaleValue, 
                       startXWeapon + 250 * scaleValue, 
                       startYWeapon + 17 * scaleValue, 
                       tocolor(255, 255, 255, 225), 
                       scale, 
                       fontNick, 
                       "center", 
                       "top")

            dxDrawRectangle(startXWeapon + 250 * scaleValue - (ammoTextWidth / 2) - 10 * scaleValue, 
                            startYWeapon + 8 * scaleValue, 
                            1 * scaleValue, 
                            40 * scaleValue, 
                            tocolor(125, 109, 237, 255))
        end
    end
end

function updatePlayerHUD()
    playerName = utilsData:getPlayerICName(localPlayer) or "Brak"
    duty = loginData:getPlayerData(localPlayer, "groupDuty") or loginData:getPlayerData(localPlayer, "adminDuty") or false
    money = loginData:getPlayerData(localPlayer, "money") or 0
    playerID = loginData:getPlayerData(localPlayer, "playerID")
    money = moneyFormat(money)

    if duty then
        dutyText = ("%s (%dm)"):format(duty[1], dutyTime)
    end

    needsUpdate = true 
end
setTimer(updatePlayerHUD, 1000, 0)

function handleRestore( didClearRenderTargets )
    if didClearRenderTargets then
		updateRenderTarget()
       updatePlayerHUD()
    end
end
addEventHandler("onClientRestore",root,handleRestore)


function onPlayerUpdateDutyTime(seconds)
dutyTime = seconds
end
addEvent("onPlayerUpdateDutyTime", true)
addEventHandler("onPlayerUpdateDutyTime", root, onPlayerUpdateDutyTime)



local hud = {}
local hudMaskShader = dxCreateShader("hud_mask.fx")
local radarTexture = dxCreateTexture("assets/radar/radar2.jpg")
local maskTexture1 = dxCreateTexture("assets/radar/rectangle_mask.png")
dxSetShaderValue(hudMaskShader, "sPicTexture", radarTexture)
dxSetShaderValue(hudMaskShader, "sMaskTexture", maskTexture1)
local scaleValue = exports.rp_scale:returnScaleValue()
local offSetX, offsetY = exports.rp_scale:returnOffsetXY()
hud.radarWidth, hud.radarHeight = 370*scaleValue, 250*scaleValue
hud.radarStartX, hud.radarStartY = exports.rp_scale:getScreenStartPositionFromBox(hud.radarWidth, hud.radarHeight, offSetX, offsetY, "left", "bottom")
hud.radarStartX = hud.radarStartX - 30 * scaleValue
hud.radarStartY = hud.radarStartY + 30 * scaleValue

hud.arrow = dxCreateTexture("assets/radar/arrow.png", "argb", true, "clamp", "2d")


-- showHud(false)


function findRotation( x1, y1, x2, y2 ) 
    local t = -math.deg( math.atan2( x2 - x1, y2 - y1 ) )
    return t < 0 and t + 360 or t
end

local function clamp(value, min, max)
   return math.max(min, math.min(value, max))
end

local playerStamina = 100
local playerCondition = 0
local maxStamina = 100

function getPointFromDistanceRotation(x, y, dist, angle)
    local a = math.rad(90 - angle);
    local dx = math.cos(a) * dist;
    local dy = math.sin(a) * dist;
    return x+dx, y+dy;
end
local goodInterior = true
function renderRadar()
	local interior = getElementInterior(localPlayer)
	if interior ~= 0 then 
		goodInterior = false
		else
		goodInterior = true
	end
    local px, py, pz = getElementPosition(localPlayer)

    local x = px / 6000
    local y = py / -6000
    dxSetShaderValue(hudMaskShader, "gUVPosition", x, y)
    dxSetShaderValue(hudMaskShader, "gUVScale", hud.radarWidth / 3072, hud.radarHeight / 3072)

    local _, _, camrot = getElementRotation(getCamera())
    dxSetShaderValue(hudMaskShader, "gUVRotAngle", math.rad(-camrot))

	if goodInterior then
    dxDrawImage(hud.radarStartX, hud.radarStartY + 2 * scaleValue, hud.radarWidth, hud.radarHeight - 2 * scaleValue, maskTexture1, 0, 0, 0, tocolor(255, 255, 255, 85))
    dxDrawImage(hud.radarStartX + 2.5 * scaleValue, hud.radarStartY + 1 * scaleValue, hud.radarWidth - 4.9 * scaleValue, hud.radarHeight - 1 * scaleValue, hudMaskShader, 0, 0, 0, tocolor(255, 255, 255, 230))
		else
	dxDrawImage(hud.radarStartX + 2.5 * scaleValue, hud.radarStartY + 1 * scaleValue, hud.radarWidth - 4.9 * scaleValue, hud.radarHeight - 1 * scaleValue, "assets/radar/questionmark.jpg", 0, 0, 0, tocolor(255, 255, 255, 230))
	end
    dxDrawImage(hud.radarStartX, hud.radarStartY, hud.radarWidth, hud.radarHeight, "assets/radar/radar.png", 0, 0, 0, tocolor(200, 200, 200, 255), true)

    -- Granice radaru i środek
    local lB, rB = hud.radarStartX + 10 * scaleValue, hud.radarStartX + hud.radarWidth - 10 * scaleValue
    local tB, bB = hud.radarStartY + 10 * scaleValue, hud.radarStartY + hud.radarHeight - 10 * scaleValue
    local centerX, centerY = (rB + lB) / 2, (tB + bB) / 2

    local pxx, pyy, pzz = getElementPosition(localPlayer)
    local _, _, camZ = getElementRotation(getCamera())

    for _, v in ipairs(getElementsByType("blip")) do
        local bx, by = getElementPosition(v)
        local actualDist = getDistanceBetweenPoints2D(pxx, pyy, bx, by)
        local maxDist = getBlipVisibleDistance(v) 
		local blipR, blipG, blipB, blipA = getBlipColor(v)

        if actualDist <= maxDist then
            local dist = actualDist / (6000 / ((3072 + 3072) / 2))
            local rot = findRotation(bx, by, pxx, pyy)
            local bpx, bpy = getPointFromDistanceRotation(centerX, centerY, dist, rot - camZ)

            local blipSize = 5 * scaleValue
            bpx = math.max(lB + blipSize, math.min(rB - blipSize, bpx))
            bpy = math.max(tB + blipSize, math.min(bB - blipSize, bpy))

            dxDrawImage(bpx - 15 * scaleValue, bpy - 15 * scaleValue, 30 * scaleValue, 30 * scaleValue, "assets/blips/" .. getBlipIcon(v) .. ".png", 0, 0, 0, tocolor(blipR, blipG, blipB, blipA))
        end
    end

	if goodInterior then
		local _, _, rz = getElementRotation(localPlayer)
		dxDrawImage(centerX - 15 * scaleValue, centerY - 15 * scaleValue, 30 * scaleValue, 30 * scaleValue, hud.arrow, camrot - rz)
	end
    dxDrawText(exports.rp_utils:getElementDirectionCardialPoint(localPlayer), hud.radarStartX * 2 + 440 * scaleValue, hud.radarStartY, hud.radarStartX * 2 + 440 * scaleValue, hud.radarStartY, tocolor(255, 255, 255, 255), 1, 1, fontNick, "center", "top", false, false, true, false, true)
	local zoneName = getZoneName(px, py, pz)
	if zoneName ~= "Unknown" then
		dxDrawText(zoneName, hud.radarStartX * 2 + 440 * scaleValue, hud.radarStartY + 20 *scaleValue, hud.radarStartX * 2 + 440 * scaleValue, hud.radarStartY + 20 * scaleValue, tocolor(255, 255, 255, 255), 1, 1, fontNick, "center", "top", false, false, true, false, true)
	end
    local healthPercent = getElementHealth(localPlayer) / getPedMaxHealth(localPlayer)
    local barLength = 123 * healthPercent * scaleValue
    dxDrawImage(hud.radarStartX, hud.radarStartY + 241 * scaleValue, 123 * scaleValue, 9 * scaleValue, "assets/hud/red_line.png", 0, 0, 0, tocolor(255, 255, 255, 255), true)
    dxDrawImage(hud.radarStartX, hud.radarStartY + 241 * scaleValue, barLength, 9 * scaleValue, "assets/hud/red_line_color.png", 0, 0, 0, tocolor(255, 255, 255, 255), true)

    local staminaBarLength = 124 * (playerStamina / 100) * scaleValue
    dxDrawRectangle(hud.radarStartX + 246 * scaleValue, hud.radarStartY + 241 * scaleValue, 124 * scaleValue, 9 * scaleValue, tocolor(247, 228, 10, 50), true)
    dxDrawRectangle(hud.radarStartX + 246 * scaleValue, hud.radarStartY + 241 * scaleValue, staminaBarLength, 9 * scaleValue, tocolor(247, 228, 10, 255), true)

    local currentArmor = getPedArmor(localPlayer)
    if currentArmor > 0 then
        local armorLength = 123 * (currentArmor / 100) * scaleValue
        dxDrawRectangle(hud.radarStartX, hud.radarStartY + 241 * scaleValue, armorLength, 9 * scaleValue, tocolor(7, 94, 235, 255), true)
    end

    local northX = centerX + math.sin(math.rad(camrot)) * hud.radarWidth + 100 / 2
    local northY = centerY - math.cos(math.rad(camrot)) * hud.radarHeight + 100 / 2
    northX = math.max(hud.radarStartX - 15 * scaleValue, math.min(hud.radarStartX + hud.radarWidth - 15 * scaleValue, northX))
    northY = math.max(hud.radarStartY - 15 * scaleValue, math.min(hud.radarStartY + hud.radarHeight - 30 * scaleValue, northY))
    dxDrawImage(northX, northY, 32 * scaleValue, 32 * scaleValue, "assets/blips/4.png", math.rad(-camrot), 0, 0, tocolor(255, 255, 255, 255), true)
end










function getPedMaxHealth(ped)
    -- Output an error and stop executing the function if the argument is not valid
    assert(isElement(ped) and (getElementType(ped) == "ped" or getElementType(ped) == "player"), "Bad argument @ 'getPedMaxHealth' [Expected ped/player at argument 1, got " .. tostring(ped) .. "]")

    -- Grab his player health stat.
    local stat = getPedStat(ped, 24)

    -- Do a linear interpolation to get how many health a ped can have.
    -- Assumes: 100 health = 569 stat, 200 health = 1000 stat.
    local maxhealth = 100 + (stat - 569) / 4.31

    -- Return the max health. Make sure it can't be below 1
    return math.max(1, maxhealth)
end

function playerHasBW ()
exports.rp_bw:hasPlayerBW()
end

function calculateStaminaToRemove()
    local playerCondition = exports.rp_login:getCharDataFromTable(localPlayer, "fitness")
    if not playerCondition then playerCondition = 1 end

    local staminaPercentage = playerCondition / maxStamina * 100
    local staminaToRemove

    if staminaPercentage >= 90 then
        staminaToRemove = 0.1
    elseif staminaPercentage >= 70 then
        staminaToRemove = 0.2
    elseif staminaPercentage >= 50 then
        staminaToRemove = 0.4
    elseif staminaPercentage >= 30 then
        staminaToRemove = 0.5
    else
        staminaToRemove = 0.8
    end

    local isPlayerDrugged = exports.rp_drugs:isPlayerDrugged()
    if isPlayerDrugged == 1 then
        staminaToRemove = staminaToRemove / 1.5
		elseif isPlayerDrugged == 2 then
		staminaToRemove = staminaToRemove / 2
		elseif isPlayerDrugged == 3 then
		staminaToRemove = staminaToRemove / 2.5
		end

    return staminaToRemove
end



local lastSprintClick = 0
local holdingKey = false
local cdAnim = false

function walkFunc()
    local now = getTickCount()
    local delta = now - lastSprintClick

    local random = math.random(1, 100)

    if playerStamina <= 0 and random > 90 and cdAnim == false and not playerHasBW() then
        cdAnim = true
		triggerServerEvent("setFallAnimation", localPlayer)
        setTimer(
            function()
                cdAnim = false
                setPedControlState(localPlayer, "walk", false)
                setPedControlState(localPlayer, "sprint", false)
            end,
            10000,
            1
        )
    end
    if holdingKey then
        setPedControlState(localPlayer, "walk", false)
        setPedControlState(localPlayer, "sprint", false)
    elseif delta >= 500 and not holdingKey then
        setPedControlState(localPlayer, "walk", true)
    end
end

setTimer(
    function()
        walkFunc()
    end,
    1000,
    0
)
local keys = {"forwards", "backwards", "left", "right"}
for k, v in ipairs(keys) do
    bindKey(v, "both", walkFunc)
end





function sprint(key, keyState)
if playerHasBW() then return end
    if keyState == "down" then
        holdingKey = true
    else
        holdingKey = false
    end

    lastSprintClick = getTickCount()
    if playerStamina > 0 then
		if getPedMoveState(localPlayer) == "sprint" then
        local removeStamina = calculateStaminaToRemove()
        playerStamina = playerStamina - removeStamina
		end
    else
        setPedControlState(localPlayer, "walk", false)
        setPedControlState(localPlayer, "sprint", false)
        if playerStamina < 0 then
            playerStamina = 0
        end
    end
end
bindKey("sprint", "both", sprint)

setTimer(
    function()
        if holdingKey then
            return
        end
        local now = getTickCount()
        local delta = now - lastSprintClick
        if delta >= 5000 and playerStamina <= 100 then
            playerStamina = playerStamina + 10
            if playerStamina > 100 then
                playerStamina = 100
            end
        end
    end,
    5000,
    0
)


local walkingGui = {}
walkingGui.textInfoX, walkingGui.textInfoY = exports.rp_scale:getScreenStartPositionFromBox(100 * scaleValue, 100 * scaleValue, 0, offsetY, "center", "bottom")
walkingGui.isWalking = false

function walkingGui.enable()
    walkingGui.isWalking = not walkingGui.isWalking
    if walkingGui.isWalking then
        addEventHandler("onClientRender", root, walkingGui.render)
    else
        removeEventHandler("onClientRender", root, walkingGui.render)
    end
end



function walkingGui.enableAlt(key, press)
        local veh = getPedOccupiedVehicle(localPlayer)
        if veh then
            return
        end
        if (key == "w") then
            if (getKeyState("lalt")) then
				local logged = exports.rp_login:getPlayerData(localPlayer,"characterID")
				if not logged then return end
                walkingGui.enable()
            end
        end
end
bindKey("w", "down", walkingGui.enableAlt)

function walkingGui.render()
    if walkingGui.isWalking then
        dxDrawText("Nacisnij ALT + W, aby powrócić do normalnego trybu poruszania sie.",walkingGui.textInfoX,walkingGui.textInfoY,walkingGui.textInfoX,walkingGui.textInfoY,tocolor(255, 255, 255),1,font,"center","center")
        setPedControlState(localPlayer, "forwards", true)
    end
end

function dxDrawRoundedRectangle(x, y, width, height, radius, color, postGUI, subPixelPositioning)
    dxDrawRectangle(x+radius, y+radius, width-(radius*2), height-(radius*2), color, postGUI, subPixelPositioning)
    dxDrawCircle(x+radius, y+radius, radius, 180, 270, color, color, 16, 1, postGUI)
    dxDrawCircle(x+radius, (y+height)-radius, radius, 90, 180, color, color, 16, 1, postGUI)
    dxDrawCircle((x+width)-radius, (y+height)-radius, radius, 0, 90, color, color, 16, 1, postGUI)
    dxDrawCircle((x+width)-radius, y+radius, radius, 270, 360, color, color, 16, 1, postGUI)
    dxDrawRectangle(x, y+radius, radius, height-(radius*2), color, postGUI, subPixelPositioning)
    dxDrawRectangle(x+radius, y+height-radius, width-(radius*2), radius, color, postGUI, subPixelPositioning)
    dxDrawRectangle(x+width-radius, y+radius, radius, height-(radius*2), color, postGUI, subPixelPositioning)
    dxDrawRectangle(x+radius, y, width-(radius*2), radius, color, postGUI, subPixelPositioning)
end



-- updatedDuty("18th Street Mafia", {255,0,0,0})

function moneyFormat(amount)
   local formatted = amount
   while true do
      formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1.%2')
      if (k==0) then
         break
      end
   end
   return formatted
end

-- initHud(true)
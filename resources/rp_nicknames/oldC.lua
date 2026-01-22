local lastRefreshTime = 0
local pedRefreshTime = 0
local refreshInterval = 13 -- ms
local pedRefreshInterval = 50 -- ms
local nickCache = {}
local pedCache = {}
local function updateNickCache()
    nickCache = {}
    local cx, cy, cz = getCameraMatrix()

    for player, _ in pairs(streamedPlayers) do
        if isElement(player) and isElementStreamedIn(player) and isElementOnScreen(player) then
            local nx, ny, nz = getElementPosition(player)
            local dist = getDistanceBetweenPoints3D(nx, ny, nz, cx, cy, cz)
            if dist <= maxDistance then
                local bx, by, bz = getPedBonePosition(player, 8)
                bz = bz + 0.35
                local sx, sy = getScreenFromWorldPosition(bx, by, bz)
                if sx and sy then
                    local playerName = utilsData:getPlayerICName(player)
                    local desc = data:getPlayerData(player, "desc")
                    local descX, descY = false, false
                    if desc then
                        local dx, dy, dz = getPedBonePosition(player, 2)
                        descX, descY = getScreenFromWorldPosition(dx, dy, dz)
                    end
                    if playerName then
                        local ame = data:getPlayerData(player, "ame") or false
                        local fullName = playerName
                        local adminLevel = data:getPlayerData(player, "adminlevel")
                        local adminDuty = data:getPlayerData(player, "adminDuty")
                        local adminData = adminDuty and adminRanks[adminLevel] or {}
                        local groupDuty = data:getPlayerData(player, "groupDuty")
                        if adminDuty then fullName = getPlayerName(player):gsub("_", " ") end
                        if groupDuty then adminData = groupDuty end
                        local playerID = data:getPlayerData(player, "playerID")
                        local charStatus = data:getPlayerData(player, "charStatuses") or {}
                        nickCache[player] = {sx, sy, fullName, desc, dist, charStatus, adminData, descX or 0, descY or 0, playerID, ame}
                    end
                end
            end
        end
    end
end

local function updatePedCache()
    pedCache = {}
    local cx, cy, cz = getCameraMatrix()

    for ped, _ in pairs(streamedPeds) do
        if isElement(ped) and isElementStreamedIn(ped) and isElementOnScreen(ped) then
            local nx, ny, nz = getElementPosition(ped)
            local dist = getDistanceBetweenPoints3D(nx, ny, nz, cx, cy, cz)
            if dist <= maxDistance then
                local bx, by, bz = getPedBonePosition(ped, 8)
                bz = bz + 0.35
                local sx, sy = getScreenFromWorldPosition(bx, by, bz)
                if sx and sy then
                    local pedName = exports.rp_utils:getPlayerICName(ped) --getElementData(ped, "pedName") or "NPC"
					if pedName then
						pedCache[ped] = {sx, sy, pedName, dist}
					end
                end
            end
        end
    end
end

local function drawPlayerNicknames()
    local currentTime = getTickCount()
    local cx, cy, cz = getCameraMatrix()
 
    if currentTime - lastRefreshTime >= refreshInterval then
        updateNickCache()
        lastRefreshTime = currentTime
    end

    if currentTime - pedRefreshTime >= pedRefreshInterval then
        updatePedCache()
        pedRefreshTime = currentTime
    end

    for player, pos in pairs(nickCache) do
        if isElement(player) then
            local dist = pos[5]
            local progress = dist / maxDistance
            if progress < 1 then
                local x, y, z = getElementPosition(player)
                local alphac, scale = interpolateBetween(255, 1, 0, 0, 0.5, 0, progress, "Linear")
                if isLineOfSightClear(cx, cy, cz, x, y, z, true, false, false, true, false, false, false) then
                    local sx, sy = pos[1], pos[2]
					  local actualColor = "#ffffff"
                    if hitPlayers[player] then
                        actualColor = "#bf1717"
                    elseif isPedDead(player) then
                        actualColor = "#2e2d2d"
                    end
                    dxDrawText(actualColor .. pos[3] .. " (" .. pos[10] .. ")", sx, sy, sx, sy, tocolor(255, 255, 255, alphac), scale * 0.8, font, "center", "center", false, false, false, true, true)
                    
                    if #pos[6] > 0 then
                        dxDrawText("(" .. table.concat(pos[6], ", ") .. ")", sx, sy + 20 * scale, sx, sy + 20 * scale, tocolor(255, 255, 255, alphac), scale * 0.7, font, "center", "center", false, false, false, false, true)
                    end

                    if #pos[7] > 0 then
                        dxDrawText(pos[7][2] .. pos[7][1], sx, sy - 20 * scale, sx, sy - 20 * scale, tocolor(255, 255, 255, alphac), scale * 0.8, font, "center", "center", false, false, false, true, true)
                    end

                    if pos[11] then
                        dxDrawText(pos[11], sx, sy - 60 * scale, sx, sy - 60 * scale, tocolor(220, 162, 244, alphac), scale * 0.8, font, "center", "center", false, false, false, true, true)
                    end

                    if pos[4] and dist <= 10 then
                        local alphasec, scalesec = interpolateBetween(255, 1, 0, 0, 0.5, 0, dist / 10, "Linear")
                        dxDrawText(pos[4], pos[8], pos[9], pos[8], pos[9], tocolor(238, 252, 220, alphasec), scalesec * 0.7, font, "center", "center", false, false, false, true, true)
                    end
                end
            end
        end
    end

    for ped, pos in pairs(pedCache) do
        if isElement(ped) then
            local sx, sy, pedName, dist = unpack(pos)
            local progress = dist / maxDistance
            if progress < 1 then
                local alpha, scale = interpolateBetween(255, 1, 0, 0, 0.5, 0, progress, "Linear")
				if pedName then
					dxDrawText(pedName, sx, sy, sx, sy, tocolor(255, 255, 255, alpha), scale * 0.8, font, "center", "center", false, false, false, true, true)
				end
            end
        end
    end
end

addEventHandler("onClientRender", root, drawPlayerNicknames)

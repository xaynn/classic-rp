-- Classic Roleplay Race Client
-- Handles race marker creation, editing, race state, timer, and leaderboard display for the client

-- Table to store all race markers (checkpoints, start, end)
local raceMarkers = {}

-- Table to store start position markers for edit mode
local startPosMarkers = {}

-- State flags for marker creation and race state
local hasStart = false
local hasEnd = false
local isInRace = false
local startedRaceName = ""
local editMode = false
local editedRaceName = ""

-- Timer variables for client-side display only (not authoritative)
local raceStartTick = nil
local raceTimerDisplay = nil

-- Leaderboard variables (received from server)
local leaderboardData = {}
local showLeaderboard = false

-- Marker color definitions for different checkpoint types
local markerColors = {
    startpoint = {r=153, g=0, b=0},
    endpoint = {r=0, g=204, b=102},
    normal = {r=0, g=102, b=204}
}

-- Blip icon IDs
local markerBlips = {
    startpoint = 53,
    endpoint = 53,
    normal = 41
}

-- Utility: Prevents creating multiple start or end markers
local function isDuplicateStartOrEnd(checkpointType)
    if hasStart and checkpointType == "startpoint" then
        exports.rp_library:createBox("Już stworzyłeś punkt startowy!")
        return true
    elseif hasEnd and checkpointType == "endpoint" then
        exports.rp_library:createBox("Już stworzyłeś punkt końcowy!")
        return true
    end
    
    return false
end

local startMarkerIdx
local endMarkerIdx

-- Creates a race marker at the player's position and adds it to raceMarkers
local function createRaceMarker(checkpointType)
    checkpointType = checkpointType or "normal"
    if isDuplicateStartOrEnd(checkpointType) then return end
    if not localPlayer then return end

    local x, y, z = getElementPosition(localPlayer)
    z = z - 1 -- Place marker slightly below player
    local color = markerColors[checkpointType]
    local blipID = markerBlips[checkpointType]

    local markerElement = createMarker(x, y, z, "checkpoint", 4, color.r, color.g, color.b, 170)
    local blipElement = createBlip(x, y, z, blipID, 2, 255, 0, 0)
    local markerData = {
        element = markerElement,
        position = {x=x, y=y, z=z},
        type = checkpointType,
        blip = blipElement,
        blipInfo = {blipID=blipID, size=2, r=255, g=0, b=0}
    }
    table.insert(raceMarkers, markerData)

    if checkpointType == "startpoint" then 
        hasStart = true 
        startMarkerIdx = #raceMarkers
    end
    if checkpointType == "endpoint" then 
        hasEnd = true 
        endMarkerIdx = #raceMarkers
    end

    if isElement(markerElement) then
        exports.rp_library:createBox("Pomyślnie stworzyłeś checkpoint!")
    else
        exports.rp_library:createBox("Nie udało się stworzyć checkpointa! :(")
    end
end

-- Finds the index of a marker in raceMarkers by its element
local function findMarkerIndex(markerElement)
    for i, markerData in pairs(raceMarkers) do
        if markerData and markerData.element == markerElement then
            return i
        end
    end
    return nil
end

-- Removes a marker and its blip from the world and updates state flags
local function removeMarker(markerData)
    if markerData then
        if isElement(markerData.element) then destroyElement(markerData.element) end
        if isElement(markerData.blip) then destroyElement(markerData.blip) end
        if markerData.type == "startpoint" then hasStart = false end
        if markerData.type == "endpoint" then hasEnd = false end
    end
end

-- Removes a marker after it's hit (keeps table index stable for server logic)
local function removeAfterHit(markerIndex)
    removeMarker(raceMarkers[markerIndex])
end
addEvent("removeMarker", true)
addEventHandler("removeMarker", localPlayer, removeAfterHit)

-- Handles marker creation/removal in edit mode (Enter key)
local function manageMarker()
    for i, markerData in pairs(raceMarkers) do
        if markerData and isElementWithinMarker(localPlayer, markerData.element) then
            removeMarker(markerData)
            raceMarkers[i] = nil
            return
        end
    end

    for posNumber, startPosMarkerData in pairs(startPosMarkers) do
        if startPosMarkerData and isElementWithinMarker(localPlayer, startPosMarkerData.element) then
            removeMarker(startPosMarkerData)
            startPosMarkers[posNumber] = nil
            return
        end
    end

    createRaceMarker()
end


-- Removes all markers and blips from the world and resets state
local function removeAllMarkers()
    for i, markerData in pairs(raceMarkers) do
        removeMarker(markerData)
    end

    raceMarkers = {}
    hasStart = false
    hasEnd = false
    isInRace = false
    startedRaceName = ""
end

-- Toggles edit mode for a race (creates/removes handlers and UI)
local function toggleEditMode(_, raceName)
    if not raceName then
        exports.rp_library:createBox("Użycie: /editrace [nazwa]")
    end

    if not isInRace then
        triggerServerEvent("checkRace", localPlayer, raceName)
    else
        exports.rp_library:createBox("Wyścig wystartował!")
    end
end
addCommandHandler("editrace", toggleEditMode)

local function createMarkerOnEnter(button, press)
    if button == "enter" and press and not isChatBoxInputActive() then
        manageMarker()
        cancelEvent()
    end
end

-- Remove all start position markers (when leaving edit mode)
local function removeAllStartPosMarkers()
    for _, data in pairs(startPosMarkers) do
        if isElement(data.element) then destroyElement(data.element) end
        if isElement(data.blip) then destroyElement(data.blip) end
    end

    startPosMarkers = {}
end

-- Exits edit mode and notifies server
local function exitEditMode()
    if editMode then
        editedRaceName = ""
        editMode = false
        startMarkerIdx = nil
        endMarkerIdx = nil
        removeEventHandler("onClientKey", getRootElement(), createMarkerOnEnter)
        removeCommandHandler("startpoint")
        removeCommandHandler("endpoint")
        removeCommandHandler("saverace")
        removeCommandHandler("startpos")
        removeAllMarkers()
        removeAllStartPosMarkers()
        outputChatBox("Zakończono tryb edycji wyścigu.", 255, 255, 0)
        triggerServerEvent("exitEditMode", localPlayer)
    end
end

-- Saves the current race configuration and sends it to the server
local function saveRace(_)
    local markersPackage = {}
    local startPosMarkersPackage = {}
    if startMarkerIdx then
        local tempMarker = raceMarkers[startMarkerIdx]
        table.remove(raceMarkers, startMarkerIdx)
        table.insert(raceMarkers, 1, tempMarker)
    end

    if endMarkerIdx then
        local tempMarker = raceMarkers[endMarkerIdx]
        table.remove(raceMarkers, endMarkerIdx)
        table.insert(raceMarkers, tempMarker)
    end

    for _, markerData in pairs(raceMarkers) do
        if markerData then
            table.insert(markersPackage,{position = markerData.position, type = markerData.type, blipInfo = markerData.blipInfo})
        end
    end
    
    for _, markerData in pairs(startPosMarkers) do
        if markerData then
            table.insert(startPosMarkersPackage,{position = markerData.position, posNumber = markerData.posNumber, blipInfo = markerData.blipInfo, rotation = markerData.rotation})
        end
    end

    outputChatBox("Zapisano wyścig!", 0, 255, 0)
    triggerServerEvent("saveRace", localPlayer, editedRaceName, markersPackage, startPosMarkersPackage)
    toggleEditMode(_, editedRaceName)
end

-- Creates markers from a package (used for loading/syncing from server)
local function createExistingMarkers(markersPackage)
    for _, markerInfo in ipairs(markersPackage) do
        if markerInfo.blipInfo then
            local color = markerColors[markerInfo.type]
            local blipID, size, r, g, b = markerInfo.blipID, markerInfo.size, markerInfo.r, markerInfo.g, markerInfo.b
            local x, y, z = markerInfo.position.x, markerInfo.position.y, markerInfo.position.z
            local markerElement = createMarker(x, y, z, "checkpoint", 4, color.r, color.g, color.b, 170)
            local blipElement = createBlip(x, y, z, blipID, size, r, g, b)
            local markerData = {
                element = markerElement,
                position = {x=x, y=y, z=z},
                type = markerInfo.type,
                blip = blipElement,
                blipInfo = markerInfo.blipInfo
            }
            table.insert(raceMarkers, markerData)

            if markerInfo.type == "startpoint" then hasStart = true end
            if markerInfo.type == "endpoint" then hasEnd = true end
        end
    end
end

local function createStartPosMarker(_, posNumber)
    if not localPlayer then return end
    local x, y, z = getElementPosition(localPlayer)
    local rx, ry, rz = getElementRotation(localPlayer)
    z = z - 1 -- Place marker slightly below player
    local r, g, b = 255, 255, 255
    local size, alpha, icon = 2, 120, 0
    local blip = createBlip(x, y, z, icon, size, r, g, b, alpha)
    local theType = "cylinder"
    if startPosMarkers[posNumber] then -- if a startpos of that number already exist
        removeMarker(startPosMarkers[posNumber])
        if not isInRace then 
            outputChatBox("Nadpisales istniejaca pozycje startowa o numerze: " .. posNumber, r, g, b)
        end
    end
    local markerElement = createMarker(x, y, z, theType, size, r, g, b, alpha)
    local blip = createBlip(x, y, z, icon, size, r, g, b, alpha)
    startPosMarkerData = {
        element = markerElement, 
        position = {x=x, y=y, z=z}, 
        rotation = {rx=rx, ry=ry, rz=rz},
        posNumber = posNumber,
        blip=blip,
        blipInfo = {blipID=icon, size=size, r=r, g=g, b=b}
    }
    startPosMarkers[posNumber] = startPosMarkerData
    if isElement(markerElement) then
        exports.rp_library:createBox("Pomyślnie stworzyłeś checkpoint!")
    else
        exports.rp_library:createBox("Nie udało się stworzyć checkpointa! :(")
    end
end

local function createExistingStartPositions(startPositionsData)
    for _, markerInfo in ipairs(startPositionsData) do
        if markerInfo.blipInfo then
            local r, g, b = 255, 255, 255
            local blipID, size = markerInfo.blipID, markerInfo.size
            local x, y, z = markerInfo.position.x, markerInfo.position.y, markerInfo.position.z
            local rx, ry, rz =  markerInfo.position.rx, markerInfo.position.ry, markerInfo.position.rz
            local markerElement = createMarker(x, y, z, "cylinder", 2, r, g, b, 120)
            local posNumber = markerInfo.posNumber
            local blip = createBlip(x, y, z, blipID, size, r, g, b)
            startPosMarkerData = {
                element = markerElement, 
                position = {x=x, y=y, z=z}, 
                rotation = {rx=rx, ry=ry, rz=rz},
                posNumber = posNumber,
                blip=blip,
                blipInfo = {blipID=icon, size=size, r=r, g=g, b=b}
            }
            startPosMarkers[posNumber] = startPosMarkerData
        end
    end
end

-- Handles server response for race existence and enters edit mode if valid
function editModeHandler(exists, raceName, markersPackage, startPositionsData)
    if not exists then
        outputChatBox("Taki wyścig nie istnieje!", 255, 0, 0)
        return
    end
    markersPackage = markersPackage or {}
    if not editMode then
        editedRaceName = raceName
        addEventHandler("onClientKey", getRootElement(), createMarkerOnEnter)
        createExistingMarkers(markersPackage)
        createExistingStartPositions(startPositionsData)
        editMode = true

        outputChatBox("Pomyślnie Rozpoczęłeś edycję wyścigu! Aby stworzyć punkt startowy, wpisz /startpoint", 255, 255, 255)
        outputChatBox("Aby stworzyć punkt końcowy, wpisz /endpoint", 255, 255, 255)
        outputChatBox("Aby utworzyć checkpoint kliknij enter!", 255, 255, 255)
        outputChatBox("Aby usunąć checkpoint kliknij enter będąc w checkpoincie do usunięcia!", 255, 255, 255)
        outputChatBox("Aby zapisać wyścig wpisz /saverace", 255, 255, 255)

        addCommandHandler("startpoint", createRaceMarker)
        addCommandHandler("endpoint", createRaceMarker)
        addCommandHandler("saverace", saveRace)
        addCommandHandler("startpos", createStartPosMarker)
    else
        exitEditMode()
    end
end

addEvent("returnIfRaceExists", true)
addEventHandler("returnIfRaceExists", localPlayer, editModeHandler)

-- Handles player hitting a checkpoint marker (sends event to server)
local function onCheckpointHit(player)
    if not isInRace or player ~= localPlayer then return end
    local markerElement = source
    local markerIndex = findMarkerIndex(markerElement)
    if markerIndex then
        triggerServerEvent("updateCheckpointsForPlayer", localPlayer, markerIndex, startedRaceName)
    end
end

addEventHandler("onClientMarkerHit", root, onCheckpointHit)

-- Calculates real-time distance to the next checkpoint for the player
local function getDistanceToNextCheckpointForPlayer(checkpoints, player)
    local markerData = raceMarkers[checkpoints + 1]
    if not markerData or not markerData.position then return 0 end
    local x, y, z = getElementPosition(player)
    local mx, my, mz = markerData.position.x, markerData.position.y, markerData.position.z
    return math.sqrt((x - mx)^2 + (y - my)^2 + (z - mz)^2)
end

-- Starts the race: creates all markers, sets state, and starts timer/leaderboard
local function startRace(markersPackage, raceName, serverStartTick, startPositionsData)
    isInRace = true
    startedRaceName = raceName
    createExistingMarkers(markersPackage)
    createExistingStartPositions(startPositionsData)
    raceStartTick = getTickCount()

    if raceTimerDisplay then
        removeEventHandler("onClientRender", root, raceTimerDisplay)
        raceTimerDisplay = nil
    end

    raceTimerDisplay = function()
        if isInRace and raceStartTick then
            removeAllStartPosMarkers()
            local elapsed = (getTickCount() - raceStartTick) / 1000
            local screenW, screenH = guiGetScreenSize()
            dxDrawText(
                string.format("Czas: %.2f s", elapsed),
                0, 10, screenW, 60,
                tocolor(255,255,255), 2, "default-bold", "center", "top"
            )
        end
    end

    addEventHandler("onClientRender", root, raceTimerDisplay)
    showLeaderboard = true
end

addEvent("startRace", true)
addEventHandler("startRace", localPlayer, startRace)

-- Draws the leaderboard in the upper right corner, updating local player's distance in real time
local function drawLeaderboard()
    if not showLeaderboard or not leaderboardData or #leaderboardData == 0 then return end

    local screenW, screenH = guiGetScreenSize()
    local x = screenW - 320 -- Offset from right edge
    local y = 140           -- Offset from top
    local lineHeight = 28
    dxDrawText("LEADERBOARD", x, y, x + 300, y + lineHeight, tocolor(255,215,0), 1.5, "default-bold", "left", "top")
    y = y + lineHeight

    -- Prepare entries with distance and checkpoints
    local entries = {}
    for i, entry in ipairs(leaderboardData) do
        local dist = math.huge
        local targetPlayer = getPlayerFromName(entry.name)
        if targetPlayer and isElement(targetPlayer) then
            dist = getDistanceToNextCheckpointForPlayer(entry.checkpoints, targetPlayer)
        end
        table.insert(entries, {entry = entry, distance = dist, checkpoints = entry.checkpoints or 0})
    end

    -- Sort: first by checkpoints (desc), then by distance (asc)
    table.sort(entries, function(a, b)
        if a.checkpoints ~= b.checkpoints then
            return a.checkpoints > b.checkpoints
        else
            return a.distance < b.distance
        end
    end)

    for i, data in ipairs(entries) do
        local entry = data.entry
        local distanceStr = ""
        if data.distance and data.distance ~= math.huge then
            distanceStr = string.format(" | %.1fm", data.distance)
        end
        local text = string.format("%d. %s | CP: %d%s", i, entry.ICName, entry.checkpoints, distanceStr)
        dxDrawText(text, x, y, x + 300, y + lineHeight, tocolor(255,255,255), 1.2, "default-bold", "left", "top")
        y = y + lineHeight
    end
end

addEventHandler("onClientRender", root, drawLeaderboard)

-- Receives leaderboard updates from the server and enables display
local function onUpdateLeaderboard(data)
    leaderboardData = data or {}
    showLeaderboard = true
end

addEvent("updateLeaderboard", true)
addEventHandler("updateLeaderboard", localPlayer, onUpdateLeaderboard)

-- Ends the race: removes all markers, hides timer and leaderboard
local function endRace()
    removeAllMarkers()
    isInRace = false
    raceStartTick = nil
    showLeaderboard = false
    leaderboardData = {}

    if raceTimerDisplay then
        removeEventHandler("onClientRender", root, raceTimerDisplay)
        raceTimerDisplay = nil
    end
end

addEvent("endRace", true)
addEventHandler("endRace", localPlayer, endRace)

local bettingTimer = nil
local bettingTimeLeft = 0

local function showBettingTimer(time)
    bettingTimeLeft = time
    if bettingTimer then
        removeEventHandler("onClientRender", root, bettingTimer)
    end

    bettingTimer = function()
        if bettingTimeLeft > 0 then
            local screenW, screenH = guiGetScreenSize()
            dxDrawText("CZAS NA ZAKŁADY: " .. tostring(math.ceil(bettingTimeLeft)), 0, 40, screenW, 120, tocolor(255, 215, 0), 3, "default-bold", "center", "top")
        end
    end

    addEventHandler("onClientRender", root, bettingTimer)
    setTimer(function()
        if bettingTimeLeft > 0 then
            bettingTimeLeft = bettingTimeLeft - 1
        end
        if bettingTimeLeft <= 0 and bettingTimer then
            removeEventHandler("onClientRender", root, bettingTimer)
            bettingTimer = nil
        end
    end, 1000, time)
end

addEvent("showBettingTimer", true)
addEventHandler("showBettingTimer", localPlayer, showBettingTimer)

local raceStartTimer = nil
local raceStartTimeLeft = 0

local function showStartTimer(time)
    raceStartTimeLeft = time
    if raceStartTimer then
        removeEventHandler("onClientRender", root, raceStartTimer)
    end

    raceStartTimer = function()
        if raceStartTimeLeft > 0 then
            local screenW, screenH = guiGetScreenSize()
            dxDrawText("WYŚCIG ROZPOCZNIE SIĘ ZA\n" .. tostring(math.ceil(raceStartTimeLeft)), 0, screenH/2-100, screenW, screenH/2+100, tocolor(255, 50, 50), 5, "default-bold", "center", "center")
        end
    end

    addEventHandler("onClientRender", root, raceStartTimer)
    setTimer(function()
        if raceStartTimeLeft > 0 then
            raceStartTimeLeft = raceStartTimeLeft - 1
        end
        if raceStartTimeLeft <= 0 and raceStartTimer then
            removeEventHandler("onClientRender", root, raceStartTimer)
            raceStartTimer = nil
        end
    end, 1000, time)
end

addEvent("showRaceStartTimer", true)
addEventHandler("showRaceStartTimer", localPlayer, showStartTimer)

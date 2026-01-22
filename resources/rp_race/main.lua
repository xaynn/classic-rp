-- Race logic for Classic Roleplay
-- Scoreboard order: by checkpoints reached, then by distance to next checkpoint

-- endpoint has to be the last marker in the list (TODO: add check)
-- startpoint has to be the first marker in the list (TODO: add check)

--TODO: make single owner, add sharing race

-- Table storing all races and player-to-race mapping
local races = {}
local playersEditingRace = {}
local startedRaces = {}

-- Table to track pending invitations: [player] = {raceName = ..., inviter = ...}
local pendingInvites = {}
local pendingRaces = {}

-- Utility Helpers
function getPlayerFromCharacterID(characterID)
    return exports.rp_utils:getPlayerFromCharID(characterID)
end

function getCharacterID(player)
    return exports.rp_login:getPlayerData(player, "characterID")
end

function notify(player, message)
    exports.rp_library:createBox(player, message)
end

function notifyRace(race, message)
    for _, competitorID in ipairs(race.competitorsList) do
        local player = getPlayerFromCharacterID(competitorID)
        if player then
            notify(player, message)
        end
    end
end

-- Race object definition and constructor
race = {}
race.__index = race

local BETS_TIMER = 5000 -- milliseconds for betting phase
local RACE_START_DELAY = 1000 -- milliseconds for race start delay

function race:new(raceName, player)
    local ownerID = getCharacterID(player)
    local o = setmetatable({}, self)
    o.name = raceName
    o.markers = {}
    o.ownerID = ownerID
    o.started = false
    o.prepared = false
    o.hasStart = false            -- Has a start marker?
    o.hasEnd = false              -- Has an end marker?
    o.entryFee = 0
    o.entryFeePool = 0
    o.checkpointsCount = 0        -- Number of checkpoints (excluding start/end)
    o.reachedCheckpoints = {}     -- [player] = checkpointNumber
    o.competitorsList = {ownerID}  -- Save competitors as character IDs
    o.playersThatReachedEnd = {}  -- Players who finished the race
    o.bets = {}                   -- [betterPlayer] = {target=player, amount=number}
    o.bettingOpen = false
    o.bettingTimer = nil          -- Timer handle for betting phase
    o.startPositionsMarkers = {}  -- [number] = {x, y, z, rx, ry, rz}
    o.startMode = "random"        -- "random" or "manual"
    o.playerStartPos = {}         -- [player] = startpos number
    o.leaderboard = {}            -- Stores finish times
    o.timer = nil
    o.winner = nil
    o.startTick = nil             -- Server-side race start time (getTickCount)
    o.raceStartInvites = {}
    race.countdown = false
    return o
end

local function setEntryFee(player, _, raceName, entryFee)
    if not entryFee or not raceName then
        notify(player, "Użycie: /entryfee [raceName] [price]")
        return
    end
    local race = races[player][raceName]
    if race then
        entryFee = tonumber(entryFee)
        if entryFee and entryFee >= 0 then
            race.entryFee = entryFee
            notify(player, "Ustawiłeś wejściówkę na wyścig: ".. tonumber(entryFee) .."$")
        else
            notify(player, "Ustawiłeś niepoprawną kwotę wejściówki!")
        end
    end
end

addCommandHandler("entryfee", setEntryFee)

-- TODO: Add a function that removes all added competitors from a race
local function removeAllPlayersFromRace()

end

-- TODO
local function importRacesFromDB()

end

local function addRaceOnPlayerEnter()

end

local function removeRaceOnPlayerLeave()

end

local function cleanupOnPlayerLeave()

end

local function initOnPlayerEnter()

end

-- Resets all runtime data for a race (used on race end)
local function resetRaceData(race)
    if race then
        race.started = false
        race.reachedCheckpoints = {}
        race.playersThatReachedEnd = {}
        race.bets = {}
        race.bettingOpen = false
        race.bettingTimer = nil
        race.leaderboard = {}
        race.timer = nil
        race.winner = nil
        race.startTick = nil
        race.entryFeePool = 0
        race.countdown = false
        startedRaces[race.name] = nil
    end
end

-- Helper: get the race a player is currently in
local function getPlayerCurrentStartedRace(player)
    for _, race in pairs(startedRaces) do
        if race.bettingOpen or race.started then
            for _, competitorID in ipairs(race.competitorsList) do
                local competitor = getPlayerFromCharacterID(competitorID)
                if competitor == player then
                    return race
                end
            end
        end
    end
    return nil
end

local function distanceBetweenPoints(x1, y1, z1, x2, y2, z2)
    return ((x2 - x1)^2 + (y2 - y1)^2 + (z2 - z1)^2)^0.5
end

local function getDistanceToNextCheckpoint(player, race, checkpointIndex)
    local px, py, pz = getElementPosition(player)
    local markerData = race.markers[checkpointIndex + 1]
    if not markerData then return math.huge end
    local markerPos = markerData.position
    local mx, my, mz = markerPos.x, markerPos.y, markerPos.z
    return distanceBetweenPoints(px, py, pz, mx, my, mz)
end

-- Calculates and sends the current leaderboard to all competitors
local function updateLeaderboard(raceName)
    local race = startedRaces[raceName]
    if not race then return end
    local standings = {}
    -- Gather checkpoint and distance info for each competitor
    for _, competitorID in ipairs(race.competitorsList) do
        local competitor = getPlayerFromCharacterID(competitorID)
        if competitor then
            local checkpoints = race.reachedCheckpoints[competitor] or 0
            table.insert(standings, {
                player = competitor,
                checkpoints = checkpoints,
            })
        end
    end

    -- Prepare leaderboard data to send to clients
    local leaderboardData = {}
    for i, entry in ipairs(standings) do
        table.insert(leaderboardData, {
            name = getPlayerName(entry.player),
            ICName = exports.rp_utils:getPlayerICName(entry.player),
            checkpoints = entry.checkpoints,
        })
    end

    -- Send leaderboard to all competitors
    for _, competitorID in ipairs(race.competitorsList) do
        local competitor = getPlayerFromCharacterID(competitorID)
        if competitor then
            triggerClientEvent(competitor, "updateLeaderboard", competitor, leaderboardData)
        end
    end
end

local function checkIfRaceExistsAndPlayerOwnsIt(player, raceName)
    local raceToCheck = races[player][raceName]
    return raceToCheck or false
end

-- Checks if a race exists for a client and returns info for editing
local function checkIfRaceExistsForClient(raceName)
    local player = client
    local raceToCheck = races[player][raceName]
    local raceExists = checkIfRaceExistsAndPlayerOwnsIt(player, raceName)
    if getPlayerCurrentStartedRace(player) then
        notify(player, "Jesteś w trakcie wyścigu!")
        return
    end
    if raceExists then
        playersEditingRace[player] = raceToCheck
        triggerClientEvent(player, "returnIfRaceExists", player, raceExists, raceName, raceToCheck.markers, raceToCheck.startPositionsMarkers)
    else
        notify(player, "Wyscig o nazwie ".. raceName .. " nie istnieje, lub nie jestes jego wlascicielem!")
    end
end

addEvent("checkRace", true)
addEventHandler("checkRace", getRootElement(), checkIfRaceExistsForClient)

local function getRaceThatPlayerIsEditing(player)
    return playersEditingRace[player]
end

local function unfreezePlayers(race)
    for _, competitorID in ipairs(race.competitorsList) do
        local competitor = getPlayerFromCharacterID(competitorID)
        if competitor then
            local vehicle = getPedOccupiedVehicle(competitor)
            if vehicle then
                setElementFrozen(vehicle, false)
            end
            setElementFrozen(competitor, false)
        end
    end
end

-- Opens betting phase for a race (call before starting the race)
local function openBetting(race)
    race.bettingOpen = true
    if isTimer(race.bettingTimer) then killTimer(race.bettingTimer) end
    for _, competitorID in ipairs(race.competitorsList) do
        local competitor = getPlayerFromCharacterID(competitorID)
        if competitor then
            outputChatBox("Zakłady na wyścig otwarte przez " .. (BETS_TIMER / 1000) .. " sekund! Użyj: /bet [IDZawodnika] [kwota]", competitor, 0, 255, 255)
            triggerClientEvent(competitor, "showBettingTimer", competitor, BETS_TIMER / 1000)
        end
    end
    race.bettingTimer = setTimer(function()
        if race and race.bettingOpen then
            race.bettingOpen = false
            for _, competitorID in ipairs(race.competitorsList) do
                local competitor = getPlayerFromCharacterID(competitorID)
                if competitor then
                    notify(competitor, "Zakłady na wyścig zostały zamknięte!")
                    triggerClientEvent(competitor, "showRaceStartTimer", competitor, RACE_START_DELAY / 1000)
                end
            end
            race.countdown = true
            setTimer(function()
                if race.prepared and not race.started then
                    unfreezePlayers(race)
                    race.countdown = false
                    race.startTick = getTickCount()
                    for _, competitorID in pairs(race.competitorsList) do
                        local competitor = getPlayerFromCharacterID(competitorID)
                        if competitor then
                            triggerClientEvent(competitor, "startRace", competitor, race.markers, race.name, race.startTick, race.startPositionsMarkers)
                            race.reachedCheckpoints[competitor] = 0
                        end
                    end
                    race.started = true
                    notify(player, "Wyścig '" .. race.name .. "' rozpoczęty!")
                    updateLeaderboard(race.name)
                end
            end, RACE_START_DELAY, 1)
        end
    end, BETS_TIMER, 1)
end

local function bet(player, _, targetID, amountStr)
    if not targetID or not amountStr then
        notify(player, "Użycie: /bet [IDZawodnika] [kwota]")
        return
    end

    local race = getPlayerCurrentStartedRace(player)
    if not race then
        notify(player, "Zakłady są zamknięte lub nie bierzesz udziału w wyścigu!")
        return
    end

    if race.bets[player] then
        notify(player, "Możesz postawić tylko jeden zakład na wyścig!")
        return
    end

    local targetPlayer
    for _, competitorID in ipairs(race.competitorsList) do
        local competitor = getPlayerFromCharacterID(competitorID)
        if competitor then
            if exports.rp_login:findPlayerByID(targetID) == competitor then
                targetPlayer = competitor
                break
            end
        end
    end

    if not targetPlayer then
        notify(player, "Nie znaleziono zawodnika w tym wyścigu!")
        return
    end

    local amount = tonumber(amountStr)
    if not amount or amount <= 0 then
        notify(player, "Podaj poprawną kwotę!")
        return
    end

    if not exports.rp_atm:takePlayerCustomMoney(player, amount, true) then
        notify(player, "Nie masz wystarczająco pieniędzy!")
    else
        race.bets[player] = {target = targetPlayer, amount = amount}
        notify(player, "Postawiłeś "..amount.."$ na ".. exports.rp_utils:getPlayerICName(targetPlayer).."!")
    end
end

-- Betting command: /bet [playerName] [amount]
addCommandHandler("bet", bet)

local function allPlayersNearStart(race)
    for _, competitorID in ipairs(race.competitorsList) do
        local competitor = getPlayerFromCharacterID(competitorID)
        if not competitor then return end
        local found = false
        for _, marker in pairs(race.startPositionsMarkers) do
            local x, y, z = getElementPosition(competitor)
            local mx, my, mz = marker.position.x, marker.position.y, marker.position.z
            local distance = ((x-mx)^2 + (y-my)^2 + (z-mz)^2)^0.5
            if distance < 200 then
                found = true
                break
            end
        end
        if not found then return false end
    end
    return true
end

-- Helper: assign start positions to players (random/manual)
local function assignRandomStartPositions(race)
    if race.startMode == "manual" then
        -- Already assigned
        return
    end
    -- Random assignment
    local indexes = {}
    for k in pairs(race.startPositionsMarkers) do 
        table.insert(indexes, k) 
    end
    math.randomseed(getTickCount())
    for _, competitorID in ipairs(race.competitorsList) do
        local competitor = getPlayerFromCharacterID(competitorID)
        if competitor then
            local idx = table.remove(indexes, math.random(1, #indexes))
            race.playerStartPos[competitor] = idx
            if #indexes == 0 then break end
        end
    end
end

local function teleportAndFreezePlayers(race)
    for _, competitorID in ipairs(race.competitorsList) do
        local competitor = getPlayerFromCharacterID(competitorID)
        if not competitor then return end
        local posNum = race.playerStartPos[competitor]
        local pos = race.startPositionsMarkers[posNum].position
        local rot = race.startPositionsMarkers[posNum].rotation
        local vehicle = getPedOccupiedVehicle(competitor)
        local tempZ = pos.z + 1
        setElementPosition(competitor, pos.x, pos.y, tempZ)
        setElementRotation(competitor, rot.rx, rot.ry, rot.rz)
        setElementFrozen(competitor, true)
        if vehicle then
            setElementPosition(vehicle, pos.x, pos.y, tempZ)
            setElementRotation(vehicle, rot.rx, rot.ry, rot.rz)
            setElementFrozen(vehicle, true)
        end
    end
end

local function startRace(race)
    startedRaces[race.name] = race
    race.raceStartInvites = {}
    assignRandomStartPositions(race)
    teleportAndFreezePlayers(race)
    openBetting(race)
end

local function stopRaceStart(race)
    if not race then return end
    for _, competitorID in ipairs(race.competitorsList) do
        local competitor = getPlayerFromCharacterID(competitorID)
        if competitor then
            notify(competitor, "Start wyścigu został anulowany, ponieważ ktoś odrzucił lub skonczyl sie czas na akceptacje!")
            if not race.raceStartInvites[competitor] and race.entryFee > 0 then
                exports.rp_atm:givePlayerCustomMoney(competitor, race.entryFee, false)
            end
        end
    end
    race.raceStartInvites = {}
end

local function manageRaceStartInvite(player, _, accepted)
    for _, race in pairs(pendingRaces) do
        for pendingCompetitor, pending in pairs(race.raceStartInvites) do
            if player == pendingCompetitor then
                if not accepted then
                    notify(player, "Użycie: /racestart [accept/decline]")
                end
                if pending then
                    accepted = (accepted == "accept")
                    if accepted and not getPlayerCurrentStartedRace(player) then
                        if race.entryFee > 0 then
                            if not exports.rp_atm:takePlayerCustomMoney(player, race.entryFee, true) then
                                notify(player, "Nie masz wystarczająco pieniędzy na start w wyścigu")
                                stopRaceStart(player, race)
                                return
                            end
                            race.entryFeePool = race.entryFeePool + race.entryFee
                        end
                        race.raceStartInvites[pendingCompetitor] = false
                        notify(player, "Zaakceptowales start wyscigu!")
                        local owner = getPlayerFromCharacterID(characterID)
                        notify(owner, "Gracz '"..exports.rp_utils:getPlayerICName(player).."' zaakceptował start wyścigu!")
                        for _, pending in pairs(race.raceStartInvites) do
                            if pending == true then return end
                        end
                        startRace(race)
                    else
                        notify(player, "Odrzuciles start wyscigu!")
                        stopRaceStart(player, race)
                    end
                end
                return
            else
                notify(player, "Nie jestes w zadnym rozpoczynajacym sie wyscigu!")
            end
        end
    end

end

addCommandHandler("racestart", manageRaceStartInvite)

local function sendRaceStartInvites(race)
    race.raceStartInvites = {}
    pendingRaces[race.name] = race
    for _, competitorID in ipairs(race.competitorsList) do
        if race.ownerID ~= competitorID then
            local competitor = getPlayerFromCharacterID(competitorID)
            if competitor then
                race.raceStartInvites[competitor] = true
                if race.entryFee == 0 then
                    outputChatBox("Wyscig ".. race.name .." wlasnie sie rozpoczyna, aby zaakceptowac start, wpisz /racestart accept, lub aby odrzucic /racestart decline! Po 30 sekundach start wygasnie!", competitor)
                else
                    outputChatBox("Wyscig ".. race.name .." wlasnie sie rozpoczyna, wejściówka na wyścig wynosi:".. race.entryFee ..", aby zaakceptowac start i opłacić wejściówkę, wpisz /racestart accept, lub aby odrzucic /racestart decline! Po 30 sekundach start wygasnie!", competitor)
                end
                setTimer(function()
                    if race.started then return end
                    stopRaceStart(race)
                end, 30000, 1)
            end
        end
    end
end

local function prepareRaceToStart(player, _, raceName)
    if getPlayerCurrentStartedRace(player) then
        notify(player, "Jesteś już w trakcie wyścigu")
        return
    end

    if not raceName then
        notify(player, "Użycie: /startrace [nazwa]")
        return
    end

    if not checkIfRaceExistsAndPlayerOwnsIt(player, raceName) then
        notify(player, "Taki wyścig nie istnieje!")
        return
    end

    local race = races[player][raceName]
    if race.prepared then
        if race.started or race.bettingOpen or race.countdown then
            notify(player, "Wyścig już się rozpoczął!")
            return
        end

        if #race.raceStartInvites ~= 0 then
            -- start here
            notify(player, "Już rozpocząłeś zapraszanie graczy!")
            return
        end

        if #race.startPositionsMarkers > 0 and #race.competitorsList <= #race.startPositionsMarkers then
            -- If only the owner is in the race, skip acceptance and start immediately
            local onlyOwner = true
            for _, competitorID in ipairs(race.competitorsList) do
                if not race.ownerID == competitorID then
                    onlyOwner = false
                    break
                end
            end

            if #race.competitorsList == 1 and onlyOwner then
                startRace(race)
                notify(player, "Wyścig rozpoczęty! (tylko właściciel)")
                return
            end

            -- Otherwise, prompt all competitors except organizer for race start acceptation
            if not allPlayersNearStart(race) then
                notify(player, "Nie wszyscy gracze są blisko pozycji startowych!")
                return
            end

            sendRaceStartInvites(race)
            notify(player, "Wysłano prośbę o akceptację startu wyścigu do wszystkich zawodników.")
        else
            notify(player, "Brak pozycji startowych lub za dużo graczy na daną ilość pozycji!")
            return
        end
    else
        notify(player, "Wyścig '" .. raceName .. "' nie jest jeszcze gotowy do rozpoczęcia! Brakuje punktu startowego lub końcowego.")
    end
end

addCommandHandler("startrace", prepareRaceToStart)

-- Payout logic at race end (dynamic odds)
local function payoutBets(race)
    if not race or not race.bets then return end

    local winner = race.playersThatReachedEnd[1]
    if not winner then return end

    local totalPool, winnerPool = 0, 0
    for _, bet in pairs(race.bets) do
        totalPool = totalPool + bet.amount
        if bet.target == winner then
            winnerPool = winnerPool + bet.amount
        end
    end

    if winnerPool == 0 then
        for _, competitorID in pairs(race.competitorsList) do
            local competitor = getPlayerFromCharacterID(competitorID)
            if competitor then
                notify(competitor, "Nikt nie postawił na zwycięzcę wyścigu!")
            end
        end
        return
    end

    for better, bet in pairs(race.bets) do  -- better is the player who placed the bet
        if bet.target == winner then
            local payout = math.floor((bet.amount / winnerPool) * totalPool)
            exports.rp_atm:givePlayerCustomMoney(better, payout, false)
            notify(better, "Wygrałeś "..payout.."$ za poprawny zakład na "..exports.rp_utils:getPlayerICName(bet.target).."!")
        else
            notify(better, "Twój zakład na ".. exports.rp_utils:getPlayerICName(bet.target) .." przegrał.")
        end
    end
end

local function createRace(player, _, raceName)
    if not raceName then
        notify(player, "Użycie: /createrace [nazwa]")
        return
    end

    local newRace = race:new(raceName, player)
    if not races[player] then
        races[player] = {}
        races[player][raceName] = newRace
    else
        races[player][raceName] = newRace
    end

    notify(player, "Stworzyłeś wyścig o nazwie " .. raceName .. "! Teraz możesz przejść do konfiguracji Szanowny Graczu.")
end

addCommandHandler("createrace", createRace)

-- Saves race configuration (markers) and checks if race is ready to start
local function saveRace(raceName, markersPackage, startPosMarkersPackage)
    local player = client
    local race = races[player][raceName]
    if not race then
        notify(player, "Nie znaleziono wyścigu o nazwie: " .. tostring(raceName))
        return
    end

    race.markers = markersPackage
    race.startPositionsMarkers = startPosMarkersPackage
    race.hasStart = false
    race.hasEnd = false
    race.checkpointsCount = 0

    -- Count start, end, and checkpoints
    for _, marker in pairs(race.markers) do
        local markerType = marker.type
        if markerType == "startpoint" then
            race.hasStart = true
        elseif markerType == "endpoint" then
            race.hasEnd = true
        else
            race.checkpointsCount = race.checkpointsCount + 1
        end
    end

    -- Mark race as prepared if all requirements are met
    if race.hasStart and race.hasEnd and #race.competitorsList > 0 then
        notify(player, "Twoj wyscig o nazwie ".. raceName .." jest gotowy do startu!")
        race.prepared = true
    end

    -- Clear editing state
    for player, editedRace in pairs(playersEditingRace) do
        if editedRace == raceName then
            playersEditingRace[player] = nil
        end
    end
end

addEvent("saveRace", true)
addEventHandler("saveRace", getRootElement(), saveRace)

local function raceList(player)
    outputChatBox("Twoje wyscigi to:", player)
    if races[player] then
        for _, raceName in pairs(races[player]) do
            outputChatBox(raceName, player)
        end
    end
end

addCommandHandler("racelist", raceList)

-- Checks if a player is in competitor list in a given race
local function checkIfPlayerIsInRace(race, player)
    if not race then return false end
    for _, competitorID in pairs(race.competitorsList) do
        local competitor = getPlayerFromCharacterID(competitorID)
        if competitor == player then return true end
    end
    return false
end

-- Ends the race, notifies all competitors, and resets race data
local function endRace(race)
    if race then
        race.started = false
        for _, competitorID in pairs(race.competitorsList) do
            local competitor = getPlayerFromCharacterID(competitorID)
            triggerClientEvent(competitor, "endRace", competitor)
        end
        payoutBets(race)
        resetRaceData(race)
    end
end

-- Updates checkpoints reached by a player and handles finish logic
local function updateReachedCheckpoints(markerIndex, raceName)
    local player = client
    local race = startedRaces[raceName]
    if not race then return end
    if not checkIfPlayerIsInRace(race, player) then return end
    -- maybe kick/ban player, because player would have to tamper the race name
    
    if race.reachedCheckpoints[player] == markerIndex - 1 then
        local x, y, z = getElementPosition(player)
        local markerData = race.markers[markerIndex]
        local markerPos = markerData.position
        local markerType = markerData.type
        local mx, my, mz = markerPos.x, markerPos.y, markerPos.z

        local inMarker = (mx <= x + 5 and mx >= x - 5) and (my <= y + 5 and my >= y - 5)
        if inMarker then
            race.reachedCheckpoints[player] = race.reachedCheckpoints[player] + 1
            triggerClientEvent(player, "removeMarker", player, markerIndex)
            updateLeaderboard(raceName)
        end

        -- If this is the endpoint, handle finish logic
        if markerType == "endpoint" then
            if not race.playersThatReachedEnd[player] then
                table.insert(race.playersThatReachedEnd, player)
                -- Calculate official server time
                local finishTick = getTickCount()
                local elapsedMs = finishTick - (race.startTick or finishTick)
                local elapsedSec = elapsedMs / 1000
                notify(player, "Twój czas: " .. string.format("%.2f", elapsedSec) .. " sekund!")
                race.leaderboard[player] = elapsedSec
                local message = exports.rp_utils:getPlayerICName(player) .. " ukończył wyścig w czasie: " .. string.format("%.2f", elapsedSec) .. " sekund!"
                notifyRace(race, message)
            end

            -- End race if all players finished
            if #race.playersThatReachedEnd == #race.competitorsList then
                endRace(race)
            end
        end
    end
end

addEvent("updateCheckpointsForPlayer", true)
addEventHandler("updateCheckpointsForPlayer", getRootElement(), updateReachedCheckpoints)

-- Table to track last invite time per inviter-target pair: [inviter][target] = timestamp
local inviteSpamCooldowns = {}
-- Table to track invite expiry: [player] = expiryTimestamp
local inviteExpiry = {}
local INVITE_SPAM_COOLDOWN = 10 -- seconds
local INVITE_VALIDITY = 30 -- seconds

local function sendInviteToRace(targetPlayer, raceName, inviter, now)
    pendingInvites[targetPlayer] = {raceName = raceName, inviter = inviter}
    inviteExpiry[targetPlayer] = now + INVITE_VALIDITY

    notify(inviter, "Wysłano zaproszenie do gracza '" .. exports.rp_utils:getPlayerICName(targetPlayer) .. "' do wyścigu '" .. raceName .. "'!")
    notify(targetPlayer, "Otrzymano zaproszenie od gracza '" .. exports.rp_utils:getPlayerICName(inviter) .. "' do wyścigu '" .. raceName .. "'!")

    setTimer(function(targetPlayer)
        if pendingInvites[targetPlayer] and inviteExpiry[targetPlayer] and (getTickCount()/1000) >= inviteExpiry[targetPlayer] then
            pendingInvites[targetPlayer] = nil
            inviteExpiry[targetPlayer] = nil
            if isElement(targetPlayer) then
                notify(targetPlayer, "Twoje zaproszenie do wyścigu wygasło.")
            end
        end
    end, INVITE_VALIDITY * 1000, 1, targetPlayer)
end

local function addCompetitor(player, _, raceName, playerID)
    local race = races[player][raceName]
    if not race then
        notify(player, "Wyścig '" .. raceName .. "' nie istnieje!")
        return
    end

    local now = getTickCount() / 1000
    local targetPlayer = exports.rp_login:findPlayerByID(playerID)
    if not targetPlayer then
        notify(player, "Nie znaleziono gracza o podanym ID.")
        return
    end

    inviteSpamCooldowns[player] = inviteSpamCooldowns[player] or {}
    if inviteSpamCooldowns[player][targetPlayer] and now - inviteSpamCooldowns[player][targetPlayer] < INVITE_SPAM_COOLDOWN then
        notify(player, "Musisz odczekać przed ponownym zaproszeniem tego gracza!")
        return
    end

    inviteSpamCooldowns[player][targetPlayer] = now
    if pendingInvites[targetPlayer] and inviteExpiry[targetPlayer] and now < inviteExpiry[targetPlayer] then
        notify(player, "Ten gracz ma już aktywne zaproszenie!")
        return
    end

    if not checkIfPlayerIsInRace(race, targetPlayer) then
        sendInviteToRace(targetPlayer, raceName, player, now)
    else
        notify(player, "Gracz '" .. exports.rp_utils:getPlayerICName(targetPlayer) .. "' jest już w wyścigu '" .. raceName .. "'!")
    end
end

addCommandHandler("addcompetitor", addCompetitor)

local function exitEditMode()
    local player = client
    if player then
        playersEditingRace[player] = nil
    end
end

-- Event: handle player exiting edit mode (from client)
addEvent("exitEditMode", true)
addEventHandler("exitEditMode", getRootElement(), exitEditMode)

local function setStartPosAssignmentMode(player, _, raceName, mode)
    if not raceName or not mode then
        notify(player, "Użycie: /racestartpos [nazwa] [manual|random]")
        return
    end

    local race = races[player][raceName]
    checkIfRaceExistsAndPlayerOwnsIt(player, raceName)
    if mode ~= "manual" and mode ~= "random" then
        notify(player, "Tryb musi być manual lub random!")
        return
    end

    race.startMode = mode
    notify(player, "Tryb pozycji startowych ustawiony na: ".. mode)
end

-- Command: /racestartpos [racename] [manual|random]
addCommandHandler("racestartpos", setStartPosAssignmentMode)

local function manualStartPosAssignment(player, _, targetID, posNumberStr)
    local race = getRaceThatPlayerIsEditing(player)
    if not race then
        notify(player, "Nie jesteś w żadnym wyścigu!")
        return
    end

    if race.startMode ~= "manual" then
        notify(player, "Tryb pozycji startowych nie jest manual!")
        return
    end

    local posNumber = tonumber(posNumberStr)
    if not posNumber or not race.startPositionsMarkers[posNumber] then
        notify(player, "Nieprawidłowy numer pozycji startowej!")
        return
    end

    local targetPlayer = exports.rp_login:findPlayerByID(targetID)
    if not targetPlayer then
        notify(player, "Nie znaleziono gracza!")
        return
    end

    if not checkIfPlayerIsInRace(race, targetPlayer) then
        notify(player, "Gracz nie jest w tym wyścigu!")
        return
    end

    race.playerStartPos[targetPlayer] = posNumber
    notify(player, "Przypisano gracza do pozycji startowej #".. posNumber)
end

-- Command: /setstartpos [playerID] [startposnumber]
addCommandHandler("setstartpos", manualStartPosAssignment)

local function acceptRaceInvite(player)
    local now = getTickCount() / 1000
    if not pendingInvites[player] or not inviteExpiry[player] or now > inviteExpiry[player] then
        notify(player, "Nie masz żadnych zaproszeń do wyścigu.")
        pendingInvites[player] = nil
        inviteExpiry[player] = nil
        return
    end

    local raceName = pendingInvites[player].raceName
    local race = races[pendingInvites[player].inviter][raceName]
    if not race then
        notify(player, "Wyścig nie istnieje!")
        pendingInvites[player] = nil
        inviteExpiry[player] = nil
        return
    end

    if not checkIfPlayerIsInRace(race, player) then
        local competitorID = getCharacterID(player)
        table.insert(race.competitorsList, competitorID)
        notify(player, "Dołączyłeś do wyścigu '"..raceName.."'!")
        local invite = pendingInvites[player]
        local inviter = pendingInvites[player].inviter
        if invite and invite.raceName == raceName and invite.inviter and isElement(invite.inviter) then
            notify(inviter, "Gracz '".. exports.rp_utils:getPlayerICName(player) .."' zaakceptował zaproszenie do wyścigu!")
        end
        pendingInvites[player] = nil
        inviteExpiry[player] = nil
    end
end

addCommandHandler("acceptrace", acceptRaceInvite)

local function declineRaceInvite(player)
    local now = getTickCount() / 1000
    if not pendingInvites[player] or not inviteExpiry[player] or now > inviteExpiry[player] then
        notify(player, "Nie masz żadnych zaproszeń do wyścigu.")
        pendingInvites[player] = nil
        inviteExpiry[player] = nil
        return
    end

    local raceName = pendingInvites[player].raceName
    local invite = pendingInvites[player]
    if invite and invite.inviter and isElement(invite.inviter) then
        notify(invite.inviter, "Gracz '"..exports.rp_utils:getPlayerICName(player).."' odrzucił zaproszenie do wyścigu!")
    end

    notify(player, "Odrzuciłeś zaproszenie do wyścigu '"..raceName.."'.")

    pendingInvites[player] = nil
    inviteExpiry[player] = nil
end

addCommandHandler("declinerace", declineRaceInvite)

local numberOfPeds = 100
local radius = 4 
local pedModel = 8 

function createPedsInCircle(centerX, centerY, centerZ)
centerX, centerY, centerZ = 2452.07178, -1607.90125 + 3, 14.80871 + 1
    for i = 0, numberOfPeds - 1 do
        local angle = (i / numberOfPeds) * (2 * math.pi) 
        local x = centerX + radius * math.cos(angle)
        local y = centerY + radius * math.sin(angle)
        local z = centerZ

        local ped = createPed(pedModel, x, y, z)
        if ped then
			exports.rp_login:setPlayerData(ped,"name", "Testowe")
			exports.rp_login:setPlayerData(ped,"visibleName", "Super Ped"..i)
			-- exports.rp_login:setPlayerData(ped,"desc", "Testowy opisek : D qwe qwep iqwpeo iqwpoeiqiopwe")
			exports.rp_login:setPlayerData(ped,"adminlevel", 1)
			-- exports.rp_login:setPlayerData(ped,"adminDuty", true)
			exports.rp_login:setPlayerData(ped, "playerID", i)
            setElementRotation(ped, 0, 0, math.deg(angle) + 90) 
        end
    end
end
-- createPedsInCircle()
local ameTimers = {}
local characterStatuses = {
    male = {
        ["pijanstwo"] = "pijany",
        ["zraniony"] = "zraniony",
		["pisze"] = "pisze...",
		["afk"] = "afk",
		["wysportowany"] = "wysportowany",
		["muskularny"] = "muskularny",
		["rękawiczki"] = "rekawiczki",
		["kamizelka"] = "kamizelka",
		["nacpany"] = "naćpany",
    },
    female = {
        ["pijanstwo"] = "pijana",
        ["zraniony"] = "zraniona",
		["pisze"] = "pisze...",
		["afk"] = "afk",
		["wysportowany"] = "wysportowana",
		["muskularny"] = "muskularna",
		["rękawiczki"] = "rękawiczki",
		["kamizelka"] = "kamizelka",
		["nacpany"] = "naćpana",
    }
}



function setPlayerStatus(player, status, state)
    if not status then return end

    local charStatuses = exports.rp_login:getPlayerData(player, "charStatuses") or {}
    local gender = exports.rp_login:getPlayerGender(player)
    local convertedStatus = characterStatuses[gender] and characterStatuses[gender][status]

    if not convertedStatus then return end
	if state and getPlayerStatus(player, status) then return end
    if state then
        if convertedStatus == "pisze..." then
            table.insert(charStatuses, 1, convertedStatus) -- priorytet dla "pisze..."
        else
            table.insert(charStatuses, convertedStatus)
        end
    else
        for k, v in ipairs(charStatuses) do
            if v == convertedStatus then
                table.remove(charStatuses, k)
                break
            end
        end
    end

    exports.rp_login:setPlayerData(player, "charStatuses", charStatuses)
end
function getPlayerStatus(player, status)
    if not status then return false end

    local charStatuses = exports.rp_login:getPlayerData(player, "charStatuses") or {}
    local gender = exports.rp_login:getPlayerGender(player)
    local convertedStatus = characterStatuses[gender] and characterStatuses[gender][status]

    if not convertedStatus then return false end

    for _, v in ipairs(charStatuses) do
        if v == convertedStatus then
            return true
        end
    end

    return false
end

function onChatTyping(state)
    if state ~= true and state ~= false then
        return exports.rp_anticheat:banPlayerAC(client, "Manipulate Event", "onChatTyping")
    end
	if getPlayerStatus(client,"pisze") and state == true then return end
    setPlayerStatus(client, "pisze", state)
end
addEvent("onChatTyping", true)
addEventHandler("onChatTyping", root, onChatTyping)

function onPlayerGotAFK(state)
    if state ~= true and state ~= false then
        return exports.rp_anticheat:banPlayerAC(client, "Manipulate Event", "onPlayerGotAFK")
    end
	-- if getPlayerStatus(client,"afk") and state == true then return end
    setPlayerStatus(client, "afk", state)
end
addEvent("onPlayerGotAFK", true)
addEventHandler("onPlayerGotAFK", root, onPlayerGotAFK)

function onPlayerChangeDescription(desc)
    if not tostring(desc) then
        return
    end
	local desc = splitText(desc, 40)
	local vehicle = getPedOccupiedVehicle(client)
	if string.len(desc) > 81 then return exports.rp_anticheat:banPlayerAC(client,"Manipulate Event", "onPlayerChangeDescription") end
    if vehicle and exports.rp_vehicles:hasPlayerPermToVehicle(client, vehicle) then
        if string.len(desc) == 0 then -- check if have vehicle permissions
		
            exports.rp_login:setObjectData(vehicle,"desc", false)
            exports.rp_library:createBox(client, "Usunąłeś opis pojazdu.")
        else
            -- setVehicleData(vehicle,"desc", false)
			exports.rp_login:setObjectData(vehicle,"desc", desc)
            exports.rp_library:createBox(client, "Ustawiłeś opis pojazdu.")
        end
    else
        if string.len(desc) == 0 then
            exports.rp_library:createBox(client, "Usunąłeś opis postaci.")
            exports.rp_login:setPlayerData(client, "desc", false)
        else
            exports.rp_library:createBox(client, "Pomyślnie ustawiłeś opis postaci.")
            exports.rp_login:setPlayerData(client, "desc", desc)
        end
    end
end

addEvent("onPlayerChangeDescription", true)
addEventHandler("onPlayerChangeDescription", getRootElement(), onPlayerChangeDescription)

function ameCommand(player, cmand, ...)
    local logged = exports.rp_login:isLoggedPlayer(player)
    if not logged then
        return
    end
    local msg = table.concat({...}, " ")
    if msg then
        -- local name, surname = exports.rp_login:getPlayerData(player, "name"), exports.rp_login:getPlayerData(player, "surname")
		local name = exports.rp_utils:getPlayerICName(player)
        local final = name
        local txt = splitText(msg, 40)
        local txtFinal = final .. " " .. txt
        onPlayerAME(player, txtFinal)
    end
end
addCommandHandler("ame", ameCommand, false, false)

function amePlayer(player, msg)
		local name = exports.rp_utils:getPlayerICName(player)
        local final = name
        local txt = splitText(msg, 40)
        local txtFinal = final .. " " .. txt
		onPlayerAME(player, txtFinal)
end

function onPlayerAME(player,text)
    if not tostring(text) then
        return
    end

    exports.rp_login:setPlayerData(player, "ame", text)
    if ameTimers[player] and isTimer(ameTimers[player]) then
        killTimer(ameTimers[player])
    end
    ameTimers[player] = setTimer(destroyAme, 8000, 1, player)
end


function destroyAme(player)
    if isElement(player) then
        exports.rp_login:setPlayerData(player, "ame", false)
    end
end

local quitTypes = {
["Unknown"] = "",
["Quit"] = "Wyjście",
["Kicked"] = "Wyrzucony",
["Banned"] = "Zbanowany",
["Bad Connection"] = "Utracone połączenie",
["Timed out"] = "Utracone połączenie",

}
function onAmeQuit(qtype)
    if ameTimers[source] and isTimer(ameTimers[source]) then
        killTimer(ameTimers[source])
    end
	local onlinePlayers = exports.rp_login:getLoggedPlayers()
	local position = {getElementPosition(source)}
	local quitType = quitTypes[qtype] or "blad"
	local playerName = exports.rp_utils:getPlayerICName(source)
	if not playerName then return end
	for k,v in pairs(onlinePlayers) do
		triggerClientEvent(k, "onClientPlayerDisconnected", k, source, position, quitType, playerName.." ("..getPlayerName(source)..")")
	end
end
addEventHandler("onPlayerQuit", root, onAmeQuit)



function splitText(originalText, lim)
    if originalText then
        local tab = split(originalText, " ")
        local newText = ""
        local currentLineNumber = 0
        local lineLim = lim or 50

        for k, v in ipairs(tab) do
            local orgLen = string.len(v)
            local vAfter = string.gsub(v, "#%x%x%x%x%x%x", "")
             --tekst po usuniecu hexów
            local newLen = string.len(vAfter)

            --outputChatBox ("B: " .. v .. ", A: " .. tostring(vAfter))

            if newLen < 40 then -- zabezpieczenie przeciw dlugim slowom
                if currentLineNumber + newLen > lineLim then
                    newText = newText .. "\n" .. v
                    currentLineNumber = newLen
                else
                    newText = newText .. " " .. v
                    currentLineNumber = currentLineNumber + newLen + 1 -- +1 bo spacja
                end
            end
        end

        return newText
    end
end


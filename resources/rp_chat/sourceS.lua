
-- exports.rp_login:isLoggedPlayer(player) --  logged, accountID, playState
local blipPlayers = {}

local chatRadius = 20 
local polishCharacters = {
    ["ą"] = "Ą",
    ["ć"] = "Ć",
    ["ę"] = "Ę",
    ["ł"] = "Ł",
    ["ń"] = "Ń",
    ["ó"] = "Ó",
    ["ś"] = "Ś",
    ["ź"] = "Ź",
    ["ż"] = "Ż"
}

local changeEmotes = {
	[":D"] = "śmieję się",
	[":)"] = "uśmiecha się",
	[":P"] = "wystawia język",
	[":("] = "robi smutną buźkę",
	[":3"] = "robi minę słodkiego kotka",

}

function getSpectatingAdmin(player)
    for _, admin in ipairs(getElementsByType("player")) do
        if exports.rp_admin:getAdminSpectatingPlayer(admin) == player then
            return admin
        end
    end
    return nil
end

function getSpectatorsInRange(player, radius)
    local playerX, playerY, playerZ = getElementPosition(player)
    local playerInterior = getElementInterior(player)
    local playerDimension = getElementDimension(player)
	if not radius then radius = chatRadius end
    local nearbyPlayers = getElementsWithinRange(playerX, playerY, playerZ, radius, "player", playerInterior, playerDimension)
    
    local spectatingAdmins = {}

    for _, nearbyPlayer in ipairs(nearbyPlayers) do
        local spectatingAdmin = getSpectatingAdmin(nearbyPlayer)
        if spectatingAdmin and not spectatingAdmins[spectatingAdmin] then
            spectatingAdmins[spectatingAdmin] = true
            table.insert(nearbyPlayers, spectatingAdmin)
        end
    end

    return nearbyPlayers
end
function capitalizeFirstLetter(text)
    local firstChar = utf8.sub(text, 1, 1)
    local restOfString = utf8.sub(text, 2)

    if polishCharacters[firstChar] then
        firstChar = polishCharacters[firstChar]
    else
        firstChar = utf8.upper(firstChar)
    end

    return firstChar .. restOfString
end
function position2Players(player, targetPlayer)
	local x, y, z = getElementPosition(player)
	local x1, y2, z2 = getElementPosition(targetPlayer)
	return x, y, z, x1, y2, z2
end

local changeEmotes = {
    [":D"] = "śmieję się",
    [":)"] = "uśmiecha się",
    [":P"] = "wystawia język",
    [":("] = "robi smutną buźkę",
    [":3"] = "robi minę słodkiego kotka",
}

function onPlayerChatICNormal(messageText, messageType)
    local isLoggedPlayer, hasBW = exports.rp_login:isLoggedPlayer(source), exports.rp_bw:hasPlayerBW(source)
    if not isLoggedPlayer or hasBW then return cancelEvent() end

    local normalMessage = (messageType == 0) 
    local meMessage = (messageType == 1)
    if meMessage then
        cancelEvent()
        meCommand(source, nil, messageText)
    end
    if not normalMessage then return false end
    if not exports.rp_utils:checkPassiveTimer("chat", source, 300) then return cancelEvent() end

    local playerName = exports.rp_utils:getPlayerICName(source)
    local playerX, playerY, playerZ = getElementPosition(source)
    local talkingThroughPhone = exports.rp_phone:returnPlayerCaller(source)

    local modifiedMessage = messageText
    for emote, description in pairs(changeEmotes) do--"#dca2f4**
        local coloredDescription = "#dca2f4*" .. description .. "*#FFFFFF"
        modifiedMessage = modifiedMessage:gsub(emote:gsub("([%(%)%.%%%+%-%*%?%[%]%^%$])", "%%%1"), coloredDescription)
    end

    local messageInStars = false
    if modifiedMessage:find("<.->") then
        modifiedMessage = modifiedMessage:gsub("<(.-)>", function(match)
            messageInStars = true
            return "#dca2f4*" .. match .. "*#FFFFFF"
        end)
    end

    local messageToOutput = playerName .. " mówi: " .. capitalizeFirstLetter(modifiedMessage) .. "."

    local recipients = getSpectatorsInRange(source)
    if talkingThroughPhone then
        local phoneData = exports.rp_inventory:getPlayerPhoneData(source)
		local gender = exports.rp_login:getPlayerGender(source)
        local oldData
		if gender == "male"  then oldData = "Mężczyzna" else oldData = "Kobieta" end
        if phoneData.hidecallerid then
            oldData = "Nieznany"
        end
        local text = oldData .. " mówi (telefon): " .. capitalizeFirstLetter(modifiedMessage) .. "."
        outputChatBox(text, talkingThroughPhone, 252, 186, 3, true)
    end

    for _, nearbyPlayer in ipairs(recipients) do
        local targetX, targetY, targetZ = getElementPosition(nearbyPlayer)
        local distance = getDistanceBetweenPoints3D(playerX, playerY, playerZ, targetX, targetY, targetZ)
        local r, g, b = colorForDistance(distance, chatRadius)
        outputChatBox(messageToOutput, nearbyPlayer, r, g, b, true)
    end

    cancelEvent()
end
addEventHandler("onPlayerChat", root, onPlayerChatICNormal)


function megaphoneCommand(player, cmand, ...)
local isLoggedPlayer = exports.rp_login:isLoggedPlayer(player)
    if not isLoggedPlayer then
        return
    end
	if not exports.rp_groups:hasPerm(player, "megafon") then return end

	if not exports.rp_utils:checkPassiveTimer("chat", player, 300) then return end
	local text = table.concat({...}, " ")
	if string.len(text) < 1 then return end
    local playerName = exports.rp_utils:getPlayerICName(player)
	local playerX, playerY, playerZ = getElementPosition(player) 
	
    local recipients = getSpectatorsInRange(player)

	local messageToOutput = "#d4a808"..playerName .. " megafon: " .. capitalizeFirstLetter(text) .. "."
	for _, nearbyPlayer in ipairs(recipients) do
        local targetX, targetY, targetZ = getElementPosition(nearbyPlayer)
        local distance = getDistanceBetweenPoints3D(playerX, playerY, playerZ, targetX, targetY, targetZ)

        local r, g, b = colorForDistance(distance, 30)
        outputChatBox(messageToOutput, nearbyPlayer, r, g, b, true)
    end
	
end
addCommandHandler("m", megaphoneCommand, false, false)
addCommandHandler("megafon", megaphoneCommand, false, false)

function colorForDistance(distance, maxDistance)
    local ratio = 1 - (distance / maxDistance)
    local red = math.max(50, math.min(255, math.floor(255 * ratio)))
    local green = math.max(50, math.min(255, math.floor(255 * ratio)))
    local blue = math.max(50, math.min(255, math.floor(255 * ratio)))
    return red, green, blue
end

function formatMessageWithStars(message)
    return "* " .. message:gsub("<(.-)>", "%1") .. " *"
end

function whisperCommand(player, cmand, ...)
    local isLoggedPlayer, hasBW = exports.rp_login:isLoggedPlayer(player), exports.rp_bw:hasPlayerBW(player)
    if not isLoggedPlayer or hasBW then
        return
    end
	if not exports.rp_utils:checkPassiveTimer("chat", player, 300) then return end
    local text = table.concat({...}, " ")
	if string.len(text) < 3 then return end

    local firstArgument = text:match("^(%S+)")
	local playerName = exports.rp_utils:getPlayerICName(player)--exports.rp_login:getPlayerData(player, "name") .. " " .. exports.rp_login:getPlayerData(player, "surname")
    local messageToOutput = playerName .. " szepcze: " .. capitalizeFirstLetter(text) .. "."
	local remainingMessage = text:sub(#firstArgument + 2) 

    if tonumber(firstArgument) then
        local targetPlayer = exports.rp_login:findPlayerByID(tonumber(firstArgument))
        if not targetPlayer then
            return exports.rp_library:createBox(player, "Nie ma gracza o podanym ID.")
        end
        
        if getDistanceBetweenPoints3D(position2Players(player, targetPlayer)) <= 5 then
            local targetPlayerName = exports.rp_utils:getPlayerICName(targetPlayer)--exports.rp_login:getPlayerData(targetPlayer, "name") .. " " .. exports.rp_login:getPlayerData(targetPlayer, "surname")
            exports.rp_nicknames:amePlayer(player, "szepcze do " .. targetPlayerName .. ".")
			local remainingMessage = text:sub(#firstArgument + 2)
			local messageToOutput = playerName .. " szepcze do "..targetPlayerName..": " .. capitalizeFirstLetter(remainingMessage) .. "."

            outputChatBox(messageToOutput, targetPlayer, 255, 255, 255, false)
            outputChatBox(messageToOutput, player, 255, 255, 255, false)
        end
    else
	
		local recipients = getSpectatorsInRange(player)
		outputChatBox(messageToOutput, recipients, 255, 255, 255, false)
    end
end

addCommandHandler("c", whisperCommand, false, false)
addCommandHandler("szept", whisperCommand, false, false)

function meCommand(player, cmand, ...)
 local isLoggedPlayer, hasBW = exports.rp_login:isLoggedPlayer(player), exports.rp_bw:hasPlayerBW(player)
    if not isLoggedPlayer or hasBW then
        return
    end
	if not exports.rp_utils:checkPassiveTimer("chat", player, 300) then return end
	local text = table.concat({...}, " ")
	if string.len(text) < 1 then return end

    local playerName = exports.rp_utils:getPlayerICName(player)--exports.rp_login:getPlayerData(player, "name") .. " " .. exports.rp_login:getPlayerData(player, "surname")


	local finalText = "#dca2f4** "..playerName.." "..text.."."
	local playerX, playerY, playerZ = getElementPosition(player) 
	
	 local recipients = getSpectatorsInRange(player)
    
    for _, nearbyPlayer in ipairs(recipients) do
        local targetX, targetY, targetZ = getElementPosition(nearbyPlayer)
        local distance = getDistanceBetweenPoints3D(playerX, playerY, playerZ, targetX, targetY, targetZ)

        local r, g, b = colorForDistance(distance, chatRadius)
        outputChatBox(finalText, nearbyPlayer, r, g, b, true)
    end
	

end
addCommandHandler("me", meCommand, false, false)

function meCommandLong(player, cmand, ...)
 local isLoggedPlayer, hasBW = exports.rp_login:isLoggedPlayer(player), exports.rp_bw:hasPlayerBW(player)
    if not isLoggedPlayer or hasBW then
        return
    end
	if not exports.rp_utils:checkPassiveTimer("chat", player, 300) then return end
	local text = table.concat({...}, " ")
	if string.len(text) < 1 then return end

    local playerName = exports.rp_utils:getPlayerICName(player)--exports.rp_login:getPlayerData(player, "name") .. " " .. exports.rp_login:getPlayerData(player, "surname")


	local finalText = "#dca2f4** "..playerName.." "..text.."."
	local playerX, playerY, playerZ = getElementPosition(player) 
	
	 local recipients = getSpectatorsInRange(player, 50)
    
    for _, nearbyPlayer in ipairs(recipients) do
        local targetX, targetY, targetZ = getElementPosition(nearbyPlayer)
        local distance = getDistanceBetweenPoints3D(playerX, playerY, playerZ, targetX, targetY, targetZ)

        local r, g, b = colorForDistance(distance, chatRadius)
        outputChatBox(finalText, nearbyPlayer, r, g, b, true)
    end
	

end
addCommandHandler("lme", meCommandLong, false, false)

function doCommandLong(player, cmand, ...)
 local isLoggedPlayer, hasBW = exports.rp_login:isLoggedPlayer(player), exports.rp_bw:hasPlayerBW(player)
    if not isLoggedPlayer or hasBW then
        return
    end
	if not exports.rp_utils:checkPassiveTimer("chat", player, 300) then return end
	local text = table.concat({...}, " ")
	if string.len(text) < 1 then return end

    local playerName = exports.rp_utils:getPlayerICName(player)--exports.rp_login:getPlayerData(player, "name") .. " " .. exports.rp_login:getPlayerData(player, "surname")


	local finalText = "#8982bd** "..text..". (( "..playerName.." ))"
	local playerX, playerY, playerZ = getElementPosition(player) 
	
	 local recipients = getSpectatorsInRange(player, 50)
    
    for _, nearbyPlayer in ipairs(recipients) do
        local targetX, targetY, targetZ = getElementPosition(nearbyPlayer)
        local distance = getDistanceBetweenPoints3D(playerX, playerY, playerZ, targetX, targetY, targetZ)

        local r, g, b = colorForDistance(distance, chatRadius)
        outputChatBox(finalText, nearbyPlayer, r, g, b, true)
    end
	

end
addCommandHandler("ldo", doCommandLong, false, false)

function globOOC(player, cmand, ...)
	if not exports.rp_admin:hasAdminPerm(player,"globalChats") then return end
	local text = table.concat({...}, " ")
	if string.len(text) < 1 then return end
	local playerName = exports.rp_utils:getPlayerICName(player)
	local finalText = "(( "..playerName..": "..text.." ))"
	outputChatBox(finalText, root, 255, 255, 255, true)
end
addCommandHandler("globooc", globOOC, false, false)

function globME(player, cmand, ...)
	if not exports.rp_admin:hasAdminPerm(player,"globalChats") then return end
	local text = table.concat({...}, " ")
	if string.len(text) < 1 then return end
	local finalText = "** "..text.."."
	outputChatBox(finalText, root, 220, 162, 244, true)
end
addCommandHandler("globme", globME, false, false)

function globDO(player, cmand, ...)
	if not exports.rp_admin:hasAdminPerm(player,"globalChats") then return end
	local text = table.concat({...}, " ")
	if string.len(text) < 1 then return end
	local finalText = "#8982bd** "..text.."."
	outputChatBox(finalText, root, 255, 255, 255, true)
end
addCommandHandler("globdo", globDO, false, false)

function tryCommand(player, cmand, ...)
 local isLoggedPlayer, hasBW = exports.rp_login:isLoggedPlayer(player), exports.rp_bw:hasPlayerBW(player)
    if not isLoggedPlayer or hasBW then
        return
    end
	if not exports.rp_utils:checkPassiveTimer("chat", player, 300) then return end
	local text = table.concat({...}, " ")
	if string.len(text) < 1 then return end

    local playerName = exports.rp_utils:getPlayerICName(player)--exports.rp_login:getPlayerData(player, "name") .. " " .. exports.rp_login:getPlayerData(player, "surname")
	local random = math.random(1,2)
	local additionalText 
	if random == 1 then additionalText = "zawiódł próbując" else additionalText = "odniósł sukces" end
	local finalText = "#dca2f4*** "..playerName.." "..additionalText.." "..text.."."
	local playerX, playerY, playerZ = getElementPosition(player) 
	
	 local recipients = getSpectatorsInRange(player)
    
    for _, nearbyPlayer in ipairs(recipients) do
		local targetX, targetY, targetZ = getElementPosition(nearbyPlayer)
        local distance = getDistanceBetweenPoints3D(playerX, playerY, playerZ, targetX, targetY, targetZ)

        local r, g, b = colorForDistance(distance, chatRadius)
        outputChatBox(finalText, nearbyPlayer, r, g, b, true)
    end
	
	
end
addCommandHandler("sprobuj", tryCommand, false, false)
addCommandHandler("try", tryCommand, false, false)

function sendICMessage(element, text)
	local playerName = exports.rp_utils:getPlayerICName(element)
	local messageToOutput = playerName .. " mówi: " .. capitalizeFirstLetter(text)
    local recipients = getSpectatorsInRange(element)
    local playerX, playerY, playerZ = getElementPosition(element)
    for _, nearbyPlayer in ipairs(recipients) do
        local targetX, targetY, targetZ = getElementPosition(nearbyPlayer)
        local distance = getDistanceBetweenPoints3D(playerX, playerY, playerZ, targetX, targetY, targetZ)
        local r, g, b = colorForDistance(distance, chatRadius)
        outputChatBox(messageToOutput, nearbyPlayer, r, g, b, true)
    end
end

function doCommand(player, cmand, ...)
 local isLoggedPlayer, hasBW = exports.rp_login:isLoggedPlayer(player), exports.rp_bw:hasPlayerBW(player)
    if not isLoggedPlayer or hasBW then
        return
    end
	if not exports.rp_utils:checkPassiveTimer("chat", player, 300) then return end
	local text = table.concat({...}, " ")
	if string.len(text) < 1	then return end
    local playerName = exports.rp_utils:getPlayerICName(player)--exports.rp_login:getPlayerData(player, "name") .. " " .. exports.rp_login:getPlayerData(player, "surname")


	local finalText = "#8982bd** "..text..". (( "..playerName.." ))"
	local playerX, playerY, playerZ = getElementPosition(player) 
	
	
	 local recipients = getSpectatorsInRange(player)
    
    for _, nearbyPlayer in ipairs(recipients) do
	local targetX, targetY, targetZ = getElementPosition(nearbyPlayer)
        local distance = getDistanceBetweenPoints3D(playerX, playerY, playerZ, targetX, targetY, targetZ)

        local r, g, b = colorForDistance(distance, chatRadius)
        outputChatBox(finalText, nearbyPlayer, r, g, b, true)
    end
	
end
addCommandHandler("do", doCommand, false, false)

function oocCommand(player, cmand, ...)
	local isLoggedPlayer = exports.rp_login:isLoggedPlayer(player)
    if not isLoggedPlayer then
        return
    end
	if not exports.rp_utils:checkPassiveTimer("chat", player, 300) then return end
	local text = table.concat({...}, " ")
	if string.len(text) < 1 then return end
    local playerName = exports.rp_utils:getPlayerICName(player)
	local playerX, playerY, playerZ = getElementPosition(player) 
	
	local finalText = "(( "..playerName..": "..text.." ))"

		 local recipients = getSpectatorsInRange(player)

	    for _, nearbyPlayer in ipairs(recipients) do
		local targetX, targetY, targetZ = getElementPosition(nearbyPlayer)
        local distance = getDistanceBetweenPoints3D(playerX, playerY, playerZ, targetX, targetY, targetZ)

        local r, g, b = colorForDistance(distance, chatRadius)
        sendChatOOC(nearbyPlayer, finalText, r, g, b)
    end
	

end
addCommandHandler("ooc", oocCommand, false, false)
addCommandHandler("b", oocCommand, false, false)

function privateMessage(player, cmand, target, ...)
	local isLoggedPlayer = exports.rp_login:isLoggedPlayer(player)
    if not isLoggedPlayer then
        return
    end
	if not tonumber(target) then return end
	local realTarget = exports.rp_login:findPlayerByID(tonumber(target))
	if not realTarget then exports.rp_library:createBox(player,"Nie znaleziono gracza o podanym ID.") return end
	local text = table.concat({...}, " ")
	if string.len(text) < 1 then return end
	local fullName = exports.rp_utils:getPlayerICName(player)
	local fullNameTarget = exports.rp_utils:getPlayerICName(realTarget)
	local playerID = exports.rp_login:getPlayerData(player,"playerID")

    sendChatOOC(player, "(( Do [" .. target .. "] " .. fullNameTarget .. ": " .. text .. " ))", 201, 138, 10) 
    sendChatOOC(realTarget, "(( Od [" .. playerID .. "] " .. fullName .. ": " .. text .. " ))", 245, 176, 34)


end
addCommandHandler("w", privateMessage, false, false)
addCommandHandler("pm", privateMessage, false, false)
addCommandHandler("pw", privateMessage, false, false)


function payCommand(player, cmand, target, money)
	local isLoggedPlayer = exports.rp_login:isLoggedPlayer(player)
    if not isLoggedPlayer then
        return
    end
	if not tonumber(target) then return end
	local realTarget = exports.rp_login:findPlayerByID(tonumber(target))
	if not realTarget then exports.rp_library:createBox(player,"Nie znaleziono gracza o podanym ID.") return end
	local money = tonumber(money)
	if not money then return exports.rp_library:createBox(player, "/"..cmand.." [id gracza] [kasa]") end
	local distance = exports.rp_utils:getDistanceBetweenElements(player, realTarget)
	if distance > 5 then return exports.rp_library:createBox(player,"Gracz jest za daleko aby dać mu pieniądze.") end
	if realTarget == player then return exports.rp_library:createBox(player,"Nie możesz sobie samemu dać pieniędzy.") end
	exports.rp_atm:giveToPlayerMoney(player, realTarget, money)
end
addCommandHandler("pay", payCommand, false, false)
addCommandHandler("plac", payCommand, false, false)

function showCommand(player, cmand, target, action)
    local isLoggedPlayer = exports.rp_login:isLoggedPlayer(player)
    if not isLoggedPlayer then
        return
    end
    if not target or not action then
        return exports.rp_library:createBox(player, "/pokaz [id gracza] [prawko/dowod]")
    end
    local realTarget = exports.rp_login:findPlayerByID(target)
    if not realTarget then
        return exports.rp_library:createBox(player, "Nie ma gracza o podanym ID.")
    end

	local distance = exports.rp_utils:getDistanceBetweenElements(player, realTarget)
	if distance > 5 then return exports.rp_library:createBox(player,"Gracz jest za daleko aby mu coś pokazać.") end
    if action == "prawko" then
		local license = exports.rp_utils:getPlayerLicense(player,"prawko")
        if license then
            exports.rp_nicknames:amePlayer(player,"pokazuję licencję kierowcy do " .. exports.rp_utils:getPlayerICName(realTarget) .. ".")
			meCommand(player,nil,"pokazuję licencję kierowcy do " .. exports.rp_utils:getPlayerICName(realTarget) .. ".")
			else
			exports.rp_library:createBox(player,"Nie posiadasz licencji kierowcy.") 
        end
    elseif action == "dowod" then
        exports.rp_nicknames:amePlayer(player, "pokazuję ID do " .. exports.rp_utils:getPlayerICName(realTarget) .. ".")
		outputChatBox("ID: "..exports.rp_utils:getPlayerICName(player), realTarget, 255, 255, 255)
    end
end
addCommandHandler("pokaz", showCommand, false, false)

function localizationPingCommand(player, cmand, target)
 local isLoggedPlayer = exports.rp_login:isLoggedPlayer(player)
    if not isLoggedPlayer then
        return
    end
    if not target then
        return exports.rp_library:createBox(player, "/ping [id gracza]")
    end
    local realTarget = exports.rp_login:findPlayerByID(target)
    if not realTarget then
        return exports.rp_library:createBox(player, "Nie ma gracza o podanym ID.")
    end
	if realTarget == player then return end
	if not exports.rp_utils:checkPassiveTimer("pingPlayer", player, 30000) then return exports.rp_library:createBox(player,"Możesz wysyłać swoją lokalizację co 30 sekund.") end
    exports.rp_nicknames:amePlayer(player, "udostępnia swoją lokalizację.")

	locatePlayer(player, realTarget)
	
	
end
addCommandHandler("ping", localizationPingCommand, false, false)


function shoutCommand(player, cmd, ...)
    local isLoggedPlayer, hasBW = exports.rp_login:isLoggedPlayer(player), exports.rp_bw:hasPlayerBW(player)
    if not isLoggedPlayer or hasBW then return end
    if not exports.rp_utils:checkPassiveTimer("chat", player, 300) then return end

    local text = table.concat({...}, " ")
    if string.len(text) < 3 then return end

    local chatRadius = 100 -- zasięg krzyku
    local playerX, playerY, playerZ = getElementPosition(player)
    local playerName = exports.rp_utils:getPlayerICName(player)
    local message = playerName .. " krzyczy: " .. capitalizeFirstLetter(text) .. "!"

    local recipients = getSpectatorsInRange(player)
    for _, nearbyPlayer in ipairs(recipients) do
        local targetX, targetY, targetZ = getElementPosition(nearbyPlayer)
        local distance = getDistanceBetweenPoints3D(playerX, playerY, playerZ, targetX, targetY, targetZ)

        if distance <= chatRadius then
            local r, g, b = colorForDistance(distance, chatRadius)
            outputChatBox(message, nearbyPlayer, r, g, b, false)
        end
    end

end

addCommandHandler("k", shoutCommand, false, false)
addCommandHandler("krzyk", shoutCommand, false, false)



function leaveServerHandler(player)
	local isLoggedPlayer = exports.rp_login:isLoggedPlayer(player)
    if not isLoggedPlayer then
        return
    end
	kickPlayer(player, "Wyjscie z serwera")

end
addCommandHandler("qs", leaveServerHandler, false, false)

function wsCommand(player, cmand)
    triggerClientEvent(player, "onPlayerGotWalkingStyles", player)
end
addCommandHandler("ws", wsCommand, false, false)
addCommandHandler("walkingstyle", wsCommand, false, false)

function onPlayerChangeWalkingStyle(walkingStyle)
    setPedWalkingStyle(client, walkingStyle)
end
addEvent("onPlayerChangeWalkingStyle", true)
addEventHandler("onPlayerChangeWalkingStyle", root, onPlayerChangeWalkingStyle)


function locatePlayer(player, realTarget)
    local x, y, z = getElementPosition(player)
    if blipPlayers[player] and isElement(blipPlayers[player]) then
        destroyElement(blipPlayers[player])
    end
    blipPlayers[player] = createBlip(x,y,z,0,2,255,255,255,255,0,9999,realTarget)--createBlipAttachedTo(player,0, 2, 255,0 ,255, 255,0, 16383, realTarget)
	outputChatBox ( exports.rp_utils:getPlayerICName(player).." udostępnił tobie lokalizację.", realTarget, 255, 255, 255, true )    
	outputChatBox ( "udostępniłeś lokalizację graczu: "..exports.rp_utils:getPlayerICName(realTarget), player, 255, 255, 255, true )    

	setTimer(
        function()
            if blipPlayers[player] and isElement(blipPlayers[player]) then
                destroyElement(blipPlayers[player])
            end
        end,
        30000,
        1
    )
end

-- komenda id
-- #9f0fcf
function sendChatOOC(player, text, r, g, b)
triggerClientEvent(player,"onOOCChatSend",player, text, r, g, b)
end

addEventHandler("onPlayerJoin",root,function ()
    bindKey(source, "b", "down", "chatbox", "OOC")
end)


function idCommand(player, cmd, skrawekNicku)
    local isLoggedPlayer = exports.rp_login:isLoggedPlayer(player)
    if not isLoggedPlayer then
        return
    end

    if not skrawekNicku or skrawekNicku:len() < 1 then
        exports.rp_library:createBox(player,"Użycie: /id [fragment nicku]")
        return
    end

    local tmpTable = {}

    for _, target in ipairs(getElementsByType("player")) do
        local visibleName = exports.rp_login:getPlayerData(target, "visibleName")
        if visibleName and string.find(visibleName:lower(), skrawekNicku:lower(), 1, true) then
            table.insert(tmpTable, string.format("%s (ID: %d)", visibleName, exports.rp_login:getPlayerData(target,"playerID") or -1))
        end
    end
	if #tmpTable < 1 then return exports.rp_library:createBox(player,"Nie znaleziono żadnego gracza, z takim skrawkiem nicku.") end
	triggerClientEvent(player,"onPlayerShowPlayersByNick", player, tmpTable)
end
addCommandHandler("id", idCommand, false, false)

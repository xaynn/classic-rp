local playerCallings = {}

function returnPlayerCaller(player)
	if not playerCallings[player] then return false end
	if playerCallings[player][1] then
		return playerCallings[player][2]
	end
	return false
end
--returnPlayerCaller

function getPhoneSetting(settings, settingName)
    for i, setting in ipairs(settings) do
        if setting.name == settingName then
            return setting.state
        end
    end
    return false
end


function onPlayerPhoneCall(targetNumber)
	if tonumber(targetNumber) == 911 then
		exports.rp_groups:enable911GUI(client)
		return
	end
	local player = exports.rp_inventory:getPlayerPhoneNumber(client)
	if not player then return end
	local target = exports.rp_inventory:findPlayerByNumer(targetNumber) -- ten co odbiera
	if not target then return exports.rp_library:createBox(client,"Numer jest nieosiągalny.") end
	if playerCallings[target] then return exports.rp_library:createBox(client, "Osoba prowadzi aktualnie rozmowę") end
	local targetPhoneData = exports.rp_inventory:getPlayerPhoneData(target)
	local phoneDataClient = exports.rp_inventory:getPlayerPhoneData(client)
	
	if getPhoneSetting(phoneDataClient.settings, "Zastrzeż numer") then 
		player = "Zastrzeżony numer" 
	end
	

	triggerClientEvent(target,"onPlayerCalling", target, _, true, player)
	-- triggerClientEvent(client,"onPlayerCalling", client, targetNumber)
	playerCallings[client] = {false, target, false} --talking, target, ten co odbiera
	playerCallings[target] = {false, client, true}
	local muted = getPhoneSetting(targetPhoneData.settings,"Wycisz telefon")
	if not muted then
		local ringtone = getPhoneSetting(targetPhoneData.settings,"Dzwonek")
		local loggedPlayers = exports.rp_login:getLoggedPlayers()
		for k,v in pairs(loggedPlayers) do
			triggerClientEvent(k, "playSoundForPlayers", k, target, ringtone)
		end
	end
end
addEvent("onPlayerPhoneCall", true)
addEventHandler("onPlayerPhoneCall", getRootElement(), onPlayerPhoneCall)

function onPlayerCallDecline()
    local player = client
    local target = playerCallings[player][2]
    triggerClientEvent(player, "goToHomeScreen", player)
    playerCallings[player] = nil
    local loggedPlayers = exports.rp_login:getLoggedPlayers()
    for k, v in pairs(loggedPlayers) do
        triggerClientEvent(k, "playSoundForPlayers", k, player, "disable")
        triggerClientEvent(k, "playSoundForPlayers", k, target, "disable")
    end
    if isElement(target) then
        triggerClientEvent(target, "goToHomeScreen", target)
        playerCallings[target] = nil
    end
end
addEvent("onPlayerCallDecline", true)
addEventHandler("onPlayerCallDecline", getRootElement(), onPlayerCallDecline)


function onPlayerAnswerPhone()
	-- ten co odbiera
	local player = client
	local target = playerCallings[player][2]
	playerCallings[player][1] = true
	playerCallings[target][1] = true
	triggerClientEvent(player, "goToHomeScreen", player, "talkingStage")
	
	local loggedPlayers = exports.rp_login:getLoggedPlayers()
	for k,v in pairs(loggedPlayers) do
		triggerClientEvent(k, "playSoundForPlayers", k, client, "disable")
		triggerClientEvent(k, "playSoundForPlayers", k, target, "disable")

	end

end
addEvent("onPlayerAnswerPhone", true)
addEventHandler("onPlayerAnswerPhone", getRootElement(), onPlayerAnswerPhone)

function onPlayerQuitPhone()
    if playerCallings[source] then
        local target = playerCallings[source][2]

        playerCallings[source] = nil
        playerCallings[target] = nil
        outputChatBox("Rozmówca rozłączył się. ", target, 255, 255, 255)
        triggerClientEvent(target, "goToHomeScreen", target)
    end
end
addEventHandler("onPlayerQuit", getRootElement(), onPlayerQuitPhone)


addEvent("onPlayerSendSMS", true)
addEventHandler(
    "onPlayerSendSMS",
    root,
    function(targetNumber, messageText)
        --check czy ma telefon
        if not exports.rp_utils:checkPassiveTimer("sendSMS", client, 300) or not messageText then
            return
        end
		
		if string.len(messageText) >= 35 then return end
        local player = exports.rp_inventory:getPlayerPhoneNumber(client)
        if not player then
            return
        end
        local realTime = getRealTime()
        local timestamp = realTime.timestamp
        local formattedDate =
            string.format(
            "%02d:%02d %02d.%02d.%d",
            realTime.hour,
            realTime.minute,
            realTime.monthday,
            realTime.month + 1,
            realTime.year + 1900
        )

        local targetPlayer = exports.rp_inventory:findPlayerByNumer(targetNumber)

        -- if targetPlayer and targetPlayer ~= client then
        if targetPlayer then
            local messageData = {
                text = messageText,
                sender = player,
                receiver = targetNumber,
                timestamp = timestamp,
                formattedDate = formattedDate,
                status = "delivered"
            }

            triggerClientEvent(client, "onPlayerSMSDelivered", client, targetNumber, messageData)

            triggerClientEvent(targetPlayer, "onPlayerReceiveSMS", targetPlayer, messageData)
			local targetPhoneData = exports.rp_inventory:getPlayerPhoneData(targetPlayer)
            local muted = getPhoneSetting(targetPhoneData.settings, "Wycisz telefon")
            if not muted then
                local closePlayers = exports.rp_utils:getNearbyPlayers(targetPlayer, 30)
                for k, v in pairs(closePlayers) do
                    triggerClientEvent(v, "playSoundForPlayers", v, targetPlayer, _, true)
                end
            end
        else
            exports.rp_library:createBox(client, "Numer nieosiągalny.")
        end
    end
)

--todo; numery, opcje do innych rzeczy czyli tablica znowu do konfiguracji, notatki, zdjecia mozna po kliencie zapisywac, aparat, telegram
local playerCallings = {}

function returnPlayerCaller(player)
	if not playerCallings[player] then return false end
	return playerCallings[player][2]
end
function onPlayerCallToPlayer(phoneNumber)
	if phoneNumber == 911 then
		exports.rp_groups:enable911GUI(client)
		return
	end
	local target = exports.rp_inventory:findPlayerByNumer(phoneNumber)
	local caller = exports.rp_inventory:getPlayerPhoneNumber(client)
	if not caller then return end
	-- if target == client then return exports.rp_library:createBox(client,"Nie możesz dzwonić do samego siebie.") end
	if target then
		if playerCallings[target] then return exports.rp_library:createBox(client, "Osoba prowadzi aktualnie rozmowę") end
		local phoneData = exports.rp_inventory:getPlayerPhoneData(target)
		local phoneDataClient = exports.rp_inventory:getPlayerPhoneData(client)
		if phoneDataClient.hidecallerid then caller = "Zastrzeżony numer" end
		-- iprint(phoneData)
		local loggedPlayers = exports.rp_login:getLoggedPlayers()
		
		triggerClientEvent(target,"onPlayerCalling", target, caller, true)
		local ringtone = phoneData.ringtone
		local muted = phoneData.mute
		triggerClientEvent(client,"onPlayerCalling", client, phoneNumber)
		-- local ringtone = 
		-- local silentPhone = 
		-- if not silentPhone then
			playerCallings[client] = {false, target, false} --talking, target, ten co odbiera
			playerCallings[target] = {false, client, true}
			if not muted then
			for k,v in pairs(loggedPlayers) do
				triggerClientEvent(k,"onPlayerMakeRingSound", k, target, ringtone) -- make sound at position, attach to player
			end
			end
		-- end
	else 
		exports.rp_library:createBox(client,"Numer jest nieosiągalny.")
	end
end

addEvent("onPlayerCallToPlayer", true)
addEventHandler("onPlayerCallToPlayer", getRootElement(), onPlayerCallToPlayer)


function onPlayerDeclineCall()
	if not playerCallings[client] then return end

	local target = playerCallings[client][2] 
	local player = client 

	playerCallings[player] = nil
	playerCallings[target] = nil

	local loggedPlayers = exports.rp_login:getLoggedPlayers()
	for k,v in pairs(loggedPlayers) do
		triggerClientEvent(k, "onPlayerMakeRingSound", k, player, "disable")
		triggerClientEvent(k, "onPlayerMakeRingSound", k, target, "disable")
	end
	triggerClientEvent(target,"onPlayerCalling",target, false, false, false, true)
	triggerClientEvent(client,"onPlayerCalling",client, false, false, false, true)

end
addEvent("onPlayerDeclineCall", true)
addEventHandler("onPlayerDeclineCall", getRootElement(), onPlayerDeclineCall)


function onPlayerAnswerCall()
	if not playerCallings[client] then return end

	local target = playerCallings[client][2] 
	local player = client 

	playerCallings[player][1] = true
	if playerCallings[target] then
		playerCallings[target][1] = true
	end

	local loggedPlayers = exports.rp_login:getLoggedPlayers()
	for k,v in pairs(loggedPlayers) do
		triggerClientEvent(k, "onPlayerMakeRingSound", k, client, "disable")
		triggerClientEvent(k, "onPlayerMakeRingSound", k, target, "disable")

	end
	triggerClientEvent(target,"onPlayerCalling",target, false, false, true)
	triggerClientEvent(client,"onPlayerCalling",client, false, false, true)


end
addEvent("onPlayerAnswerCall", true)
addEventHandler("onPlayerAnswerCall", getRootElement(), onPlayerAnswerCall)


function onPlayerSendMessage(targetNumber, message)
		if not exports.rp_utils:checkPassiveTimer("sendSMS", client, 500) then return exports.rp_library:createBox(player,"Nie spamuj SMS'ami.") end

	    local rt = getRealTime()
		local timestamp = string.format("%02d.%02d.%04d %02d:%02d",
        rt.monthday, rt.month + 1, rt.year + 1900, rt.hour, rt.minute
    )
		rt.hour = rt.hour + 2
		local target = exports.rp_inventory:findPlayerByNumer(targetNumber)
		if not target then return exports.rp_library:createBox(client,"Numer jest nieosiągalny") end
		local numberCaller = exports.rp_inventory:getPlayerPhoneNumber(client)
		local numberTarget = exports.rp_inventory:getPlayerPhoneNumber(target)
		local phoneData = exports.rp_inventory:getPlayerPhoneData(target)
		local phoneDataClient = exports.rp_inventory:getPlayerPhoneData(client)
		local message = message
		if string.len(message) < 4 or string.len(message) > 30 then return exports.rp_library:createBox(client,"SMS jest za krótki lub za długi") end
		if not phoneData.mute then
			exports.rp_chat:doCommand(target, nil, "Słychać dźwięk SMS'a.")
		end
-- dla odbiorcy (target): nadawcą jest client, odbiorcą jest target
triggerClientEvent(target, "onPlayerUpdateSMS", target, numberCaller, message, timestamp, client, numberTarget)

-- dla nadawcy (client): nadawcą jest client, odbiorcą jest target
triggerClientEvent(client, "onPlayerUpdateSMS", client, numberCaller, message, timestamp, client, numberTarget)

	
	local messageData = {
		number = numberCaller,
		to = numberTarget,
		message = message,
		timestamp = timestamp
	}
	exports["rp_inventory"]:addMessageToPhoneData(target, messageData)
	exports["rp_inventory"]:addMessageToPhoneData(client, messageData)


local loggedPlayers = exports.rp_login:getLoggedPlayers()
local targetMute = phoneData.mute
	for k,v in pairs(loggedPlayers) do
		if not targetMute then
		triggerClientEvent(k, "onPlayerMakeRingSound", k, target, nil, true)
		end
	end


	
end
addEvent("onPlayerSendMessage", true)
addEventHandler("onPlayerSendMessage", getRootElement(), onPlayerSendMessage)


addEventHandler("onPlayerQuit", root,
	function(quitType)
		if playerCallings[source] then
			local target = playerCallings[source][2]
			
			playerCallings[source] = nil
			playerCallings[target] = nil
			outputChatBox("Rozmówca rozłączył się. ", target, 255, 255, 255)
			triggerClientEvent(target,"onPlayerCalling",target, false, false, false, true)

		end
	end
)
local playersGreen = {}
local playersRed = {}
local playersBlack = {}

function generateSpin()
 local wynik
    local rand = math.random(1,100)
    if rand == 1 then
        wynik = "green"
    elseif rand <= 50 then
        wynik = "red"
    else
        wynik = "black"
    end
	local players = exports.rp_utils:getNearbyPlayersAtPosition(1117.2126953125,7.1833984375,1002.0859375, 30, 12, 12)
	for k,v in pairs(players) do
	    triggerClientEvent(v, "startSlotMachine", v, wynik)
	end
	setTimer(endSpin, 15000, 1, wynik)
end
local timer = setTimer(generateSpin, 60000, 0)

function endSpin(wynik)
    local playersList
	local multiplier = 2

    if wynik == "red" then
        playersList = playersRed
    elseif wynik == "green" then
        playersList = playersGreen
		multiplier = 14
    elseif wynik == "black" then
        playersList = playersBlack
    else
        return
    end
    for k, v in ipairs(playersList) do
		local bet = v.bet
		local player = v.player
		exports.rp_atm:givePlayerCustomMoney(player, bet * multiplier)
		exports.rp_library:createBox(player, "Wygrałeś "..bet*multiplier.."$")
		triggerClientEvent(player,"onPlayerUpdateTimeCasino", player, false, exports.rp_login:getPlayerData(player,"money"))
    end
	
	playersRed = {}
	playersGreen = {}
	playersBlack = {}
end


local playerMarker = createMarker(1132.880859375,-10.6845703125,999.6796875, "cylinder", 4, 10, 244, 23, 1, root)
setElementDimension(playerMarker, 12)
setElementInterior(playerMarker, 12)
function handlePlayerMarker(hitElement)
	local elementType = getElementType(hitElement)

	if elementType == "player" then
	local remaining = getTimerDetails(timer) -- Get the timers details
		triggerClientEvent(hitElement, "onPlayerUpdateTimeCasino", hitElement, remaining)
	end
end
addEventHandler("onMarkerHit", playerMarker, handlePlayerMarker)


addEvent("playerBet", true)
addEventHandler("playerBet", getRootElement(), function(type, amount)
    if type ~= "czerwone" and type ~= "zielone" and type ~= "czarne" then
        return
    end

    local amount = tonumber(amount)
    if not amount or amount < 1 then
        return
    end

    local bought = exports.rp_atm:takePlayerCustomMoney(client, amount, true)
    if not bought then
        return exports.rp_library:createBox(client, "Nie posiadasz tyle pieniędzy")
    end

    local function addOrUpdateBet(playersTable)
        for _, v in ipairs(playersTable) do
            if v.player == client then
                v.bet = v.bet + amount
                return
            end
        end
        table.insert(playersTable, {player = client, bet = amount})
    end

    if type == "czerwone" then
        addOrUpdateBet(playersRed)
    elseif type == "zielone" then
        addOrUpdateBet(playersGreen)
    elseif type == "czarne" then
        addOrUpdateBet(playersBlack)
    end
	exports.rp_chat:meCommand(client, nil,"obstawia na "..type.." "..amount.."$")
	triggerClientEvent(client,"onPlayerUpdateTimeCasino", client, false, exports.rp_login:getPlayerData(client,"money"))
    exports.rp_library:createBox(client, "Obstawiłeś " .. amount .. " na " .. type)
end)




local blip = createBlip(2069.3271484375,-1773.3994140625,13.559643745422, 43, 2, 255, 255, 255, 255, 0, 500)
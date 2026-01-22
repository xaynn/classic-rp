local pedTimers = {}
local playerTimers = {}
--max 3 cornery na strefe.

function getActualPlayerCorner(player) -- w ktorym stoi gracz.
	local data = cornerPlayerData[player]
	if data then
		return data.cornerID, data.bonus
	end
	return false
end

function isPlayerDoingCorner(player)
	local data = cornerPlayerData[player]
	if data and data.startedCorner then
		return true
	end
	
	return false
end

local narcoticPrices = {
[1] = 25, -- marihuana
[2] = 50, -- haszysz
[3] = 100, -- kokaina

}
function setPlayerDoingCorner(player, state)
	if state then
		-- tworzenie peda.
		if not cornerPlayerData[player] then return end
		local time = getRealTime()
		local hours = time.hour
		local minutes = time.minute
		local currentTime = hours + minutes/60  -- zamiana na format 15.5 = 15:30
		if currentTime < 15 or currentTime >= 24 then 
			return exports.rp_library:createBox(player, "Cornery można robić tylko od 15:00 do 23:59.") 
		end
		local cornerID = cornerPlayerData[player].cornerID
		if cornerZones[cornerID].playersDoingCorner >= 2 then return exports.rp_library:createBox(player,"Na tym cornerze, za dużo osób już handluje.") end
		cornerPlayerData[player].startedCorner = true
		-- pedTimers[player] = createCornerPed(player)
		   if isTimer(playerTimers[player]) then
            killTimer(playerTimers[player])
            playerTimers[player] = nil
        end
		local time = math.random(20000, 40000)
		playerTimers[player] = setTimer(createCornerPed, time, 1, player)
		-- cornerPlayerData[player].cornerPed = ped
		cornerZones[cornerID].playersDoingCorner = cornerZones[cornerID].playersDoingCorner + 1
		exports.rp_library:createBox(player,"Rozpocząłeś corner, ktoś może Cię w każdej chwili okraść, pamiętaj o dynamice akcji i nie utrudniaj lootgraba.")
	else
	  --usuwanie peda i corner gracza
		if isElement( cornerPlayerData[player].cornerPed) then destroyElement(cornerPlayerData[player].cornerPed) end
	  	cornerPlayerData[player].startedCorner = false
		local cornerID = cornerPlayerData[player].cornerID
		cornerZones[cornerID].playersDoingCorner = cornerZones[cornerID].playersDoingCorner - 1
		if isTimer(pedTimers[player]) then killTimer(pedTimers[player]) end
		if isTimer(playerTimers[player]) then killTimer(playerTimers[player]) end
		exports.rp_library:createBox(player,"Przerwałeś corner.")
	end
end

function createCornerPed(player)
	if not cornerPlayerData[player] then return end
	if not cornerPlayerData[player].startedCorner then return end
	local x, y, z = exports.rp_utils:getXYInFrontOfPlayer(player, 5)
	local pedID = table.random(randomPedSkins)
	local ped = createPed(pedID, x, y, z)
	setPedWalkingStyle(ped, table.random(randomWalkingStyles))
	exports.rp_login:setPlayerData(ped, "visibleName", table.random(randomPedNames)) 
	exports.rp_login:setPlayerData(ped, "playerID", "PED")
	-- exports.rp_login:setPlayerData(ped,"pedType", 10) -- zwykle pedy, brak interakcji.
	cornerPlayerData[player].cornerPed = ped
	setTimer(correctPosition, 100, 1, ped, x, y, z)
	local px, py, pz = getElementPosition(player)
	fixRotationWithPlayer(ped, {x = px, y = py}, {x = x, y = y})
	exports.rp_login:setPlayerData(ped,"cornerState", player)
	pedTimers[player] = setTimer(takeOrderFromPlayer, 6000, 1, player, ped)
	-- ped powinien isc do gracza, potem
end

function takeOrderFromPlayer(player, ped)
	if not isElement(player) or not isElement(ped) then return end
	-- iprint("takeorder ped: "..ped)
	--check czy ma narkotyki, jesli nie to mowi nara a jezeli tak to daje hajs.
	local x, y, z = exports.rp_utils:getXYInFrontOfPlayer(player, 1)
	correctPosition(ped, x, y, z)
	local narcotics, narcoticID = exports.rp_inventory:getItemTypeInInventory(player, 7, 1)
	if narcotics then
		exports.rp_chat:sendICMessage(ped, "Dzięki, zwijam się.")
		local bonus = cornerPlayerData[player].bonus
		local cash = narcoticPrices[narcoticID] + bonus
		exports.rp_atm:givePlayerCustomMoney(player, cash)
		exports.rp_nicknames:amePlayer(ped, "podaje kwit.")
		outputChatBox("+ "..cash.."$", player, 36, 201, 80, true)
		addAmountToSoldGrams(player, 1) -- wartosc, jak np bedziemy sprzedawac wiecej.
		local chance = math.random(1,3)
		local data = {
		["lspd"] = true,
		["lsfd"] = false
		}
		if chance == 1 then exports.rp_groups:send911Report(player, "Ktoś zaproponował mi dziwne substancje, stojąc na winklu.", data) end
	else
		exports.rp_chat:sendICMessage(ped, "Po chuj tu stoisz jak nic nie masz?")
		setPlayerDoingCorner(player, false)
		
	end
	exports.rp_login:setPlayerData(ped,"cornerState", "leaving")
	setTimer(destroyCornerPed, 8000, 1, player, ped)
	
end

function destroyCornerPed(player, ped)
    if isElement(ped) then 
        destroyElement(ped) 
    end
    if cornerPlayerData[player] and cornerPlayerData[player].startedCorner then
        local time = math.random(20000, 40000)
        if isTimer(playerTimers[player]) then
            killTimer(playerTimers[player])
        end
        playerTimers[player] = setTimer(createCornerPed, time, 1, player)
    end
end

function findRotation(x1, y1, x2, y2)
    local t = -math.deg(math.atan2(x2 - x1, y2 - y1))
    return t < 0 and t + 360 or t
end







function fixRotationWithPlayer(ped, pos, pos2)
    local rotZ = findRotation(pos.x, pos.y, pos2.x, pos2.y) - 180

    if not (rotZ == getPedRotation(ped)) then
        setPedRotation(ped, rotZ)
    end
end



function table.random(theTable)
    return theTable[math.random(#theTable)]
end



function player_Wasted ( ammo, attacker, weapon, bodypart )
	if isPlayerDoingCorner(source) then setPlayerDoingCorner(source, false) end
end
addEventHandler ( "onPlayerWasted", root, player_Wasted )
local bwTimers = {}
local bwSeconds = {}

function setPlayerBW(player, seconds)
    if bwTimers[player] and isTimer(bwTimers[player]) then
        killTimer(bwTimers[player])
    end
    bwTimers[player] = setTimer(bwTimer, 1000, 0, player)
    bwSeconds[player] = seconds
    triggerClientEvent(player, "onGotBWTime", player, seconds)
    if not isPedDead(player) then
        killPed(player)
    end
end


function hasPlayerBW(player)
	if bwTimers[player] and bwSeconds[player] then return true end
	return false
end

function disablePlayerBW(player)
    local x, y, z = getElementPosition(player)
	local skinMod = exports.rp_newmodels:getElementModel(player)
    spawnPlayer(player, x, y, z, 0, 0, getElementInterior(player), getElementDimension(player))
	-- exports.rp_newmodels:setElementModel(player, 7)
	exports.rp_newmodels:setElementModel(player, skinMod)


    fadeCamera(player, true)
    setCameraTarget(player, player)
    if bwTimers[player] and isTimer(bwTimers[player]) then
        killTimer(bwTimers[player])
        bwTimers[player] = nil
        bwSeconds[player] = nil
        triggerClientEvent(player, "onGotBWTime", player, nil, true)
    end
	    exports.rp_login:changeCharData(player, "bwtime", 0)
		setElementHealth(player, 15)
		if exports.rp_login:getPlayerData(player,"drunkLevel") then exports.rp_login:setPlayerData(player,"drunkLevel", 0, true) exports.rp_nicknames:setPlayerStatus(player, "pijanstwo", false) end

		
end





local damageTypes = {
	[19] = "Rocket",
	[37] = "Burnt",
	[49] = "Rammed",
	[50] = "Ranover/Helicopter Blades",
	[51] = "Explosion",
	[52] = "Driveby",
	[53] = "Drowned",
	[54] = "Fall",
	[55] = "Unknown",
	[56] = "Melee",
	[57] = "Weapon",
	[59] = "Tank Grenade",
	[63] = "Blown"
}


function onPlayerDied(ammo, attacker, weapon, bodypart)
    if exports.rp_login:getPlayerState(source) == "logged" then
        if bwTimers[source] then
            return
        end
        local seconds = 300
        setPlayerBW(source, seconds)
		outputChatBox("Twoja postać jest nieprzytomna, komendy narracyjne są aktualnie niedostępne, wyjątkiem jest komenda /do dzięki której będziesz mógł opisywać aktualną rzeczywistość. Aby uśmiercić swoją postać wpisz /akceptujsmierc.", source, 255, 255, 255, false)
		if exports.rp_nicknames:getPlayerStatus(source, "kamizelka") then 
			exports.rp_nicknames:setPlayerStatus(source, "kamizelka", false)
		end

		if exports.rp_nicknames:getPlayerStatus(source, "zraniony") then return end
		exports.rp_nicknames:setPlayerStatus(source, "zraniony", true)
    end
end
addEventHandler("onPlayerWasted", root, onPlayerDied)




function bwTimer(player)
    if bwSeconds[player] and isElement(player) then

        if bwSeconds[player] < 1 then
            disablePlayerBW(player)
        else
            bwSeconds[player] = bwSeconds[player] - 1
			triggerClientEvent(player, "updateBWTime", player, bwSeconds[player])
        end
    end

    local time = bwSeconds[player] or 0
    exports.rp_login:changeCharData(player, "bwtime", time)
end



function onPlayerBWQuit()
    if bwTimers[source] and bwSeconds[source] then
        killTimer(bwTimers[source])
        bwSeconds[source] = nil
    end
end
addEventHandler("onPlayerQuit", root, onPlayerBWQuit)


function unbwCommand(player, cmand, target)
	if not exports.rp_admin:hasAdminPerm(player,"bw") then return end
    if not tonumber(target) then
        return exports.rp_library:createBox(player, "TIP: /unbw [id]")
    end
	local id = tonumber(target)
    local actualTarget = exports.rp_login:findPlayerByID(id)
    if actualTarget then
		if not bwTimers[actualTarget] then return exports.rp_library:createBox(player,"Gracz nie posiada BW") end
        disablePlayerBW(actualTarget)
        exports.rp_library:createBox(actualTarget, getPlayerName(player) .. " zdjął Ci BW.")
    end
end
addCommandHandler("unbw", unbwCommand, false, false)

function bwCommand(player, cmand, target, time)
	if not exports.rp_admin:hasAdminPerm(player,"bw") then return end
    if not tonumber(target) or not tonumber(time) then
        return exports.rp_library:createBox(player, "TIP: /bw [id] [czas-sekundy]")
    end
	
	local id = tonumber(target)
	local seconds = tonumber(time)
	if seconds > 1000 or seconds < 30 then return exports.rp_library:createBox(player,"BW da się ustawić na maksymalnie 30-1000 sekund.") end
	local actualTarget = exports.rp_login:findPlayerByID(id)
	if actualTarget then
	if bwTimers[actualTarget] then disablePlayerBW(actualTarget) end
	setPlayerBW(actualTarget, seconds)
	exports.rp_library:createBox(actualTarget,getPlayerName(player).." ustawił Ci BW na "..seconds.." sekund.")
	end
end
addCommandHandler("bw", bwCommand, false, false)


function onPlayerGotDamage(attacker, weapon, bodypart, loss)
    if attacker and bodypart == 9 and weapon >= 22 and weapon <= 34 then
        killPed(source, attacker, weapon, bodypart)
        return
    end

    if attacker and exports.rp_utils:isMelee(weapon) then
        local strengthPlayer = exports.rp_login:getCharDataFromTable(attacker, "strength")
        if strengthPlayer and strengthPlayer > 1 then
            local damage = strengthPlayer * 0.01
            local currentHealth = getElementHealth(source)
            local newHealth = currentHealth - damage

            if newHealth > 0 then
                setElementHealth(source, newHealth)
            else
                killPed(source, attacker, weapon, bodypart)
            end
        end
    end

    if attacker then
        local hasTaser = exports.rp_login:getPlayerData(attacker, "taser")
        if hasTaser then
            local nearbyPlayers = exports.rp_utils:getNearbyPlayers(source, 20)
            local x,y,z = getElementPosition(source)
            local dim, interior = getElementDimension(source), getElementInterior(source)
            setPedAnimation(source, "Crack", "crckdeth2", 200000, false, true, false, false)
            for k,v in pairs(nearbyPlayers) do
                triggerClientEvent(v,"onClientPlayerGotTased", v, x, y, z, dim, interior)
            end
        end
    end

    local hasRealArmor = getPedArmor(source) > 0
    local hasItemArmor = exports.rp_inventory:getUsedTypeItem(source, 5)
    if hasRealArmor and not hasItemArmor then
        return exports.rp_anticheat:banPlayerAC(source, "Armor", "onPlayerDamageBW")
    end
	

    if exports.rp_nicknames:getPlayerStatus(source, "zraniony") then return end
    if getElementHealth(source) <= 20 then
        exports.rp_nicknames:setPlayerStatus(source, "zraniony", true)
    end
end
addEventHandler("onPlayerDamage", root, onPlayerGotDamage)



function ckCommand(player, command, ...)
	if hasPlayerBW(player) then
		local playtime = exports.rp_login:getPlayerData(player, "playtime")
		if playtime >= 10800 then
			local reason = table.concat({...}, " ")
			if string.len(reason) < 4 then
				return exports.rp_library:createBox(player, "Powód śmierci musi być większy niż 4 znaki.")
			end
			exports.rp_inventory:createCorpse(player, reason)
		else
			exports.rp_library:createBox(player, "Nie posiadasz 3h na postaci, aby ją uśmiercić.")
		end
	end
end
addCommandHandler("akceptujsmierc", ckCommand, false, false)

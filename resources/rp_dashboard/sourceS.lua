function openDashboard(player, cmand, target)
    local tempPlayer = player -- Gracz wywołujący komendę
    local targetPlayer = player -- Domyślnie dashboard dla siebie

    if target then
        -- Sprawdź czy gracz ma uprawnienia do oglądania innych
        if not exports.rp_admin:hasAdminPerm(player, "bw") then
            return exports.rp_library:createBox(player, "Nie masz uprawnień, aby podejrzeć statystyki innego gracza.")
        end

        local realTarget = exports.rp_login:findPlayerByID(target)
        if not realTarget then
            return exports.rp_library:createBox(player, "❌ Nie znaleziono gracza o podanym ID.")
        end

        targetPlayer = realTarget
    end

    local data = {}
    local logged, accountID, _, characterID = exports.rp_login:isLoggedPlayer(targetPlayer)
    if not logged then return end

    data.accountID = accountID
    data.characterID = characterID
    data.vehicles = exports.rp_vehicles:getPlayerVehicles(targetPlayer)
    data.interiors = exports.rp_interiors:getPlayerInteriors(targetPlayer)
    data.premium = getPlayerPremiumInfo(targetPlayer)
    data.characterName = exports.rp_utils:getPlayerRealName(targetPlayer)
    data.playtime = exports.rp_login:getPlayerData(targetPlayer, "playtime")
    data.strength = exports.rp_login:getCharDataFromTable(targetPlayer, "strength")
    data.fitness = exports.rp_login:getCharDataFromTable(targetPlayer, "fitness")
    data.bankMoney = exports.rp_login:getCharDataFromTable(targetPlayer, "bankmoney")

    triggerClientEvent(tempPlayer, "onPlayerOpenDashboard", tempPlayer, data)
end
addCommandHandler("dashboard", openDashboard, false, false)
addCommandHandler("stats", openDashboard, false, false)


function getPlayerPremiumInfo(player)
if exports.rp_login:getPlayerData(player,"premium") then return "Tak" else return "Nie" end
end


--onPlayerHeadChangedPosition
function onPlayerHeadChangedPosition(player, x, y, z, targetPlayers)
        if not isElement(player) or type(x) ~= "number" or type(y) ~= "number" or type(z) ~= "number" then 
            return
        end 
	if type(targetPlayers) ~= "table" then return end
	triggerClientEvent(targetPlayers, "onPlayerUpdateHeadPosition", player, player, x, y, z)
end
addEvent("onPlayerHeadChangedPosition", true)
addEventHandler("onPlayerHeadChangedPosition", getRootElement(), onPlayerHeadChangedPosition)

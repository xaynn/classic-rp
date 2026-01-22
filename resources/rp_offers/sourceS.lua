local pendingOffers = {}
local offerTimers = {}
function sendOffer(player, target, typeService, itemID, payment, name) -- nazwa, typ, czyli np Podanie przedmiotu lub usługa.
    if pendingOffers[player] or pendingOffers[target] then
        return exports.rp_library:createBox(player, "Jedna z osób ma aktualnie wysłaną ofertę.")
    end
    pendingOffers[player] = {
        name = name,
        player = target,
        typeService = typeService,
        itemID = itemID,
        payment = payment,
        style = "giving"
    }
    pendingOffers[target] = {
        name = name,
        player = player,
        typeService = typeService,
        itemID = itemID,
        payment = payment,
        style = "receiving"
    }
    offerTimers[player] = setTimer(destroyOffer, 30000, 1, player)
    offerTimers[target] = setTimer(destroyOffer, 30000, 1, target)
    triggerClientEvent(
        target,
        "onPlayerGotOffer",
        target,
        exports.rp_utils:getPlayerICName(player),
        name,
        payment,
        typeService
    )
end

function onPlayerAcceptOffer(player) -- akceptujacy
    if pendingOffers[player] and pendingOffers[player].style == "receiving" then
        -- if not isElement(pendingOffers[player].player) then return destroyOffer(player) end
        local offerFrom = pendingOffers[player].player
        local typeService = pendingOffers[player].typeService
        local itemID = pendingOffers[player].itemID
        local name = pendingOffers[player].name -- nazwa itemu lub uslugi
        local payment = pendingOffers[player].payment
        if typeService == 1 then -- dawanie itemu
            local distance = exports.rp_utils:getDistanceBetweenElements(player, offerFrom)
            if distance >= 5 then
                return destroyOffer(offerFrom), destroyOffer(player), exports.rp_library:createBox( player,"Za daleko byłeś od gracza, aby zaakceptować od niego przedmiot" )
            end
            exports.rp_inventory:giveItemToPlayer(offerFrom, player, itemID)
        elseif typeService == 2 then -- mandat
            local bought = exports.rp_atm:takePlayerCustomMoney(player, payment)
            if not bought then
                return destroyOffer(player), destroyOffer(offerFrom)
            end
			if bought == "bank" then exports.rp_library:createBox(player,"Zapłacono przy uzyciu karty.") end
            exports.rp_nicknames:amePlayer(player, "płaci za ticket.")
        elseif typeService == 3 then -- sprzedaz intka przez gracza.
            local pickup = itemID
            exports.rp_interiors:sellPropertyToPlayer(player, offerFrom, payment, pickup)
        elseif typeService == 4 then -- pocałunek
            local rotx, roty, rotz = getElementRotation(offerFrom)
            local x, y, z = exports.rp_utils:getXYInFrontOfPlayer(offerFrom, 0.9)
            setElementRotation(offerFrom, rotx, roty, rotz - 180)
            setElementRotation(player, x, y, z)
            setPedAnimation(offerFrom, "BD_FIRE", "PLAYA_KISS_03", -1, false, false, false, false)
        elseif typeService == 5 then -- podawanie dloni
            local rotx, roty, rotz = getElementRotation(offerFrom)
            local x, y, z = exports.rp_utils:getXYInFrontOfPlayer(offerFrom, 1.0)
            setElementRotation(offerFrom, rotx, roty, rotz - 180)
            setElementRotation(player, x, y, z)
            setPedAnimation(offerFrom, "GANGS", "PRTIAL_HNDSHK_BIZ_01", -1, false, false, false, false)
            setPedAnimation(player, "GANGS", "PRTIAL_HNDSHK_BIZ_01", -1, false, false, false, false)
        elseif typeService == 8 then -- ofka silowni
            local bought = exports.rp_atm:takePlayerCustomMoney(player, payment)
            if not bought then
                return destroyOffer(player), destroyOffer(offerFrom)
            end
			if bought == "bank" then exports.rp_library:createBox(player,"Zapłacono przy uzyciu karty.") end
            exports.rp_gym:onPlayerGotSuccessfullGymOffer(player, true)
        elseif typeService == 9 then -- heal
		 local bought = exports.rp_atm:takePlayerCustomMoney(player, payment)
            if not bought then
                return destroyOffer(player), destroyOffer(offerFrom)
            end
			if bought == "bank" then exports.rp_library:createBox(player,"Zapłacono przy uzyciu karty.") end
            local hasPlayerBW = exports.rp_bw:hasPlayerBW(player)
            if hasPlayerBW then
                exports.rp_bw:disablePlayerBW(player)
            else
                setElementHealth(player, 200)
            end
        elseif typeService == 6 then -- drug test
             --exports.rp_drugs:isPlayerDrugged(player) -- zwrot negatywny, pozytywny
			 local drugged = exports.rp_nicknames:getPlayerStatus(player, "nacpany")
			 if drugged then
				drugged = "pozytywny"
			 else
				drugged = "negatywny"
			 end
            outputChatBox("DrugTest: " .. drugged, offerFrom, 255, 255, 255)
        elseif typeService == 7 then -- ofka naprawy przez mechanika
            local veh = pendingOffers[player].itemID
            if not isElement(veh) then
                return destroyOffer(player), destroyOffer(offerFrom)
            end
            local bought = exports.rp_atm:takePlayerCustomMoney(player, payment)
            if not bought then
                return destroyOffer(player), destroyOffer(offerFrom)
            end
			if bought == "bank" then exports.rp_library:createBox(player,"Zapłacono przy uzyciu karty.") end
            fixVehicle(veh)
            exports.rp_vehicles:updateDamageCar(veh, nil, true)
		elseif typeService == 10 then -- podaj
		local bought = exports.rp_atm:takePlayerCustomMoney(player, payment)
            if not bought then
                return destroyOffer(player), destroyOffer(offerFrom)
            end
			if bought == "bank" then exports.rp_library:createBox(player,"Zapłacono przy uzyciu karty.") end
			local itemCount = itemID
			exports.rp_inventory:giveItem(player, name, tonumber(itemCount))
		elseif typeService == 11 then -- podaj karnet '
			local isDuringTraining = exports.rp_gym:isPlayerDuringTraining(player)
			if isDuringTraining then return exports.rp_library:createBox(player, "Jesteś już podczas treningu, nie możesz akceptować kolejnego karnetu.") end
		local gymCooldownOver = exports.rp_gym:isGymCooldownOver(player)
			if not gymCooldownOver then return exports.rp_library:createBox(player, "Nie minęło 20 godzin od ostatniego treningu.") end
		local bought = exports.rp_atm:takePlayerCustomMoney(player, payment)
            if not bought then
                return destroyOffer(player), destroyOffer(offerFrom)
            end
			if bought == "bank" then exports.rp_library:createBox(player,"Zapłacono przy uzyciu karty.") end
			local itemCount = itemID
			exports.rp_gym:onPlayerGotSuccessfullGymOffer(player, true)
        end
        triggerClientEvent(player, "onPlayerGotOffer", player, _, _, _, _, true)
        exports.rp_library:createBox(offerFrom, "Gracz zaakceptował twoją ofertę.")
        exports.rp_library:createBox(player, "Zaakceptowałeś ofertę")
        destroyOffer(player)
        destroyOffer(offerFrom)
    end
end


function onPlayerDeclineOffer(player)
    if pendingOffers[player] then
        local offerFrom = pendingOffers[player].player
        exports.rp_library:createBox(offerFrom, "Gracz odrzucił twoją ofertę.")
        exports.rp_library:createBox(player, "Odrzuciłeś ofertę.")
        destroyOffer(player)
        destroyOffer(offerFrom)
    end
end





function destroyOffer(player)
	if pendingOffers[player] then
		pendingOffers[player] = nil
		triggerClientEvent(player,"onPlayerGotOffer", player, _, _, _, _, true)
	end
end


addEventHandler("onPlayerQuit",root,
    function(quitType)
        if pendingOffers[source] then
            local offerFrom = pendingOffers[source].player
            destroyOffer(source)
            destroyOffer(offerFrom)
			exports.rp_library:createBox(offerFrom,"Gracz z którym miałeś ofertę, wyszedł z serwera.")
			-- outputServerLog("Gracz z który miałeś ofertę, wyszedł z serwera.")
        end
    end
)


function onPlayerJoined ( )
	bindKey ( source, "]", "down", onPlayerAcceptOffer )
	bindKey ( source, "[", "down", onPlayerDeclineOffer )

end
addEventHandler ( "onPlayerJoin", root, onPlayerJoined )


function onResRestart(res)
    if res == getThisResource() then
        local players = getElementsByType("player")
        for k, v in pairs(players) do
            bindKey(v, "]", "down", onPlayerAcceptOffer)
            bindKey(v, "[", "down", onPlayerDeclineOffer)
        end
    end
end
addEventHandler("onResourceStart", root, onResRestart)
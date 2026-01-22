local stealingTimers = {}
function stealVehicle(player, vehicle) -- wytrych do pojazdu aby moc go otworzyc.
    if not isElement(vehicle) or getElementType(vehicle) ~= "vehicle" then
        return exports.rp_library:createBox(player, "Nie znaleziono pojazdu, który chcesz ukraść.")
    end
	if not hasPerm(player, "steal") then return exports.rp_library:createBox(player,"Nie posiadasz uprawnień do kradnięcia pojazdów.") end
	local isGroupVehicle = exports.rp_vehicles:getVehicleCurrentData(vehicle,"owner_type") == 2
	if isGroupVehicle then return exports.rp_library:createBox(player, "Nie można ukraść pojazdu grupowego.") end
	local stealed = exports.rp_login:getObjectData(vehicle,"stealed") or exports.rp_login:getObjectData(vehicle,"stealing")
	if stealed then return exports.rp_library:createBox(player,"Ten pojazd jest już skradziony lub ktoś go kradnie.") end
	exports.rp_login:setObjectData(vehicle,"stealing", true, true)
    exports.rp_library:createBox(player,"Rozpoczęto kradnięcie pojazdu, trwa to minutę, może się powieść lub nie, może włączyć się alarm!")
    exports.rp_nicknames:amePlayer(player, "dłubie coś w pojeździe.")
    stealingTimers[player] = setTimer(tryToStealVehicle, 60000, 1, player, vehicle)
end

function tryToStealVehicle(player, vehicle)
    if not isElement(player) or not isElement(vehicle) then
        return
    end
    local veh = getPedOccupiedVehicle(player)
    if not veh == vehicle then
        return
    end
    local random = math.random(1, 3)
    if random == 1 then
        setVehicleEngineState(vehicle, true)
        exports.rp_login:setObjectData(vehicle, "stealed", true, true)
		exports.rp_library:createBox(player,"Pomyślnie ukradłeś pojazd.")
		exports.rp_login:setObjectData(vehicle,"stealing", false, true)
    else
		local x,y,z = getElementPosition(vehicle)
        --włącz alarm samochodu tez od losowosci
		triggerClientEvent(root,"onVehicleAlarm", getRootElement(), vehicle, x, y, z)
        exports.rp_library:createBox(player, "Nie udało się ukraść samochodu, nie można go już ukraść.")
    end
end

-- przeszukiwanie intkow, graczy
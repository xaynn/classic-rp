function createBox(player, text)
   if isElement(player) then
      triggerClientEvent ( player, "onPlayerGotNotification", player, text )
   end
end

function testS(player)
exports.rp_library:createBox(player,"server side")
end
-- addCommandHandler("cmd", testS, false, false)

function onPlayerInteraction(action, selectedElement)
    if not action or not selectedElement or not isElement(selectedElement) then
        return
    end
	
    local distance = exports.rp_utils:getDistanceBetweenElements(client, selectedElement)
    if distance > 5 then
        return
    end
    if action == "Pocałunek" then -- pocalunek
        exports.rp_offers:sendOffer(client, selectedElement, 4, 0, 0, "Pocałunek")
    elseif action == "Podaj rękę" then
        exports.rp_offers:sendOffer(client, selectedElement, 5, 0, 0, "Dłoń")
    elseif action == "Przytul" then
	-- przytulenie
    elseif action == "VCARD" then
	-- podanie kontaktu do telefonu
    elseif action == "UNAFK" then
        if exports.rp_login:getPlayerData(selectedElement, "afk") then
            triggerClientEvent(selectedElement, "SetWindowFlashing", selectedElement)
			 outputChatBox ( "Gracz "..exports.rp_utils:getPlayerICName(client).." pinguję cię.", selectedElement, 255, 255, 255, true )
        end
	elseif action == "Otwórz/zamknij pojazd" then
		local hasPerm = exports.rp_vehicles:hasPlayerPermToVehicle(client, selectedElement)
		if not hasPerm then return end
            setVehicleLocked(selectedElement, not isVehicleLocked(selectedElement))
		local vehName = exports.rp_vehicles:vehicleElementName(selectedElement)
			local sex = exports.rp_login:getPlayerGender(client)
			if sex == "male" then
            exports.rp_nicknames:amePlayer(client, string.format("%s %s.", isVehicleLocked(selectedElement) and "zamknął" or "otworzył", vehName))
				else
			exports.rp_nicknames:amePlayer(client, string.format("%s %s.", isVehicleLocked(selectedElement) and "zamknęła" or "otworzyła", vehName))
			end
            exports.rp_vehicles:playVehicleSound(client, "lock")
	elseif action == "Otwórz/zamknij bagażnik" then
		setVehicleDoorOpenRatio(selectedElement, 1, 1 - getVehicleDoorOpenRatio ( selectedElement, 1), 1000)
	elseif action == "Otwórz/zamknij maskę" then
		setVehicleDoorOpenRatio(selectedElement,0, 1 - getVehicleDoorOpenRatio ( selectedElement, 0), 1000)
	elseif action == "Zatrudnij się" then
			exports.rp_groups:touchPed(client, true)
			triggerClientEvent(client,"onPlayerGotPartTimeJobs",client)
	elseif action == "Wyrób licencję kierowcy" then
		   local license = exports.rp_utils:getPlayerLicense(client,"prawko")
		   if license then return exports.rp_library:createBox(client,"Posiadasz już licencję kierowcy.") end
		    local bought = exports.rp_atm:takePlayerCustomMoney(client, tonumber(100))
			if not bought then return exports.rp_library:createBox(client, "Nie masz wystarczająco pieniędzy do zakupu licencji kierowcy (100$).") end
			exports.rp_utils:givePlayerLicense(client,"prawko")
			exports.rp_library:createBox(client,"Kupiłeś licencję kierowcy.")
	elseif action == "Zacznij pracę" then
			local dataStats = exports.rp_login:getPlayerData(client, "statistics")
			local job = tonumber(exports.rp_login:getCharData(dataStats, "parttimejob"))
			if job < 1 then return exports.rp_library:createBox(client,"Zatrudnij się w urzędzie pracy, aby pracować.") end
			exports.rp_groups:setPlayerWork(client, job, selectedElement)
	elseif action == "Zarejerestruj pojazd" then
		local vehicles = exports.rp_vehicles:getPlayerVehicles(client)
			triggerClientEvent(client,"onPlayerGotVehicleRegister",client,vehicles)
	elseif action == "Sprzedaj ryby" then
		local fishesTable = exports.rp_inventory:getItemTypeInInventory(client, 20, _, true) -- zwraca tablice, itemCount i itemID
		if next(fishesTable) == nil then return exports.rp_library:createBox(client,"Nie posiadasz do sprzedaży żadnej ryby.") end
		local fishes = 0
		for k,v in pairs(fishesTable) do
			fishes = fishes + v.itemCount
			exports.rp_inventory:updateItem(client, v.itemID, 2, v.itemCount)
		end
		if fishes > 0 then
			local money = 50 * fishes
			exports.rp_library:createBox(client,"Sprzedałeś "..fishes.." ryby, otrzymałeś za nie "..money.."$.")
			exports.rp_atm:givePlayerCustomMoney(client, money)
		end
    end
end
addEvent("onPlayerInteract", true)
addEventHandler("onPlayerInteract", root, onPlayerInteraction)

local tempItems = {}
local playerUsingWeapon = {}
local deployedItems = {}
local tempObjects = {}
local gunShells = {} -- moze obiekty nw, moze danme tyloko
local sobrietyTimers = {}
local gunShellTimer = false
local phoneDatas = {}

local deployedObjectsID = {
[1] = 331,
[2] = 333,
[3] = 334,
[4] = 335,
[5] = 336,
[6] = 337,
[7] = 338,
[8] = 339,
[9] = 341,
[22] = 346,
[23] = 347,
[24] = 348,
[25] = 349,
[26] = 350,
[27] = 351,
[28] = 352,
[29] = 353,
[32] = 372,
[30] = 355,
[31] = 356,
[33] = 357,
[34] = 358,
[43] = 2969,
}
--[[
itemTypes = 1 food, var1 hp
2 gun, var1 bron, var2 styl, var3 ammo // moga byc stanyt albo pk i nie ma sensu
3, magazynki
sortowanie po UID przedmiotow w eq

owner type - 1 gracz, 2 grupa, 3 ziemia, 4 pojazd.
]]

local weaponStyles = {
[22] = 69,
[23] = 70,
[24] = 71,
[25] = 72,
[26] = 73,
[27] = 74,
[28] = 75,
[29] = 76,
[30] = 77, -- bron, czyli ak, potem staty setPedStat [1], czyli dla kalacha argument. setPedStat(player, weaponStyles[gun][1], value)
[31] = 78,
[32] = 75,

}

function hasPlayerSetupEQ(player)
	return tempItems[player] or false
end

function findTempObject(player, object)
    if tempObjects[player] then
        for k, v in pairs(tempObjects[player]) do
            if v == object then
                return object
            end
        end
    end
    return false
end


function destroyTempPlayerObjects(player)
    if tempObjects[player] then
        for _, obj in ipairs(tempObjects[player]) do 
            if isElement(obj) then
                destroyElement(obj)
            end
        end
        tempObjects[player] = nil
    end
end

function findTempPlayerObjectID(player, objectID)
	local tablica = tempObjects[player]
	for k,v in pairs(tablica) do
		if isElement(v) and getElementModel(v) == objectID then
			return v
		end
	end
	return false
end
function getPlayerItems(player)
    local ms = getTickCount()

    local owner = exports.rp_login:getPlayerData(player, "characterID")
    if not owner then
        return false
    end
	local items = tempItems[player]
	if items then return items end
    local result = exports.rp_db:query("SELECT * FROM items WHERE owner = ? and ownerType = 1", owner)

    local tmpTable = {}
    for k, v in pairs(result) do
		v.var4 = fromJSON(v.var4) or {}
        tmpTable[v.id] = v
    end
    local ms2 = getTickCount() - ms
	if ms2 > 100 then
    print("Wczytywanie ekwipunku dla gracz zajelo " .. ms2.." ms.")
	end
	
	tempItems[player] = tmpTable
    return tmpTable
end


function updatePlayerItemsInDatabase(player, owner)
    if not owner then
        return
    end

    local items = tempItems[player]
    if not items then
        return
    end

    for itemID, item in pairs(items) do
        local query = "UPDATE items SET owner = ?, itemCount = ?, var1 = ?, var2 = ?, var3 = ?, var4 = ? WHERE id = ? AND owner = ? AND ownerType = 1"
		exports.rp_db:query(query, item.owner, item.itemCount, item.var1, item.var2, item.var3, toJSON(item.var4), itemID, owner)
    end
	tempItems[player] = nil
    return true
end

function playerSobriety(player)
	if isElement(player) then
		exports.rp_login:setPlayerData(player,"drunkLevel", 0, true)
		exports.rp_nicknames:setPlayerStatus(player, "pijanstwo", false)
	end
end

function handlerUseItem(itemID)
    local uidItem = tonumber(itemID)
    local item = tempItems[client] and tempItems[client][uidItem]
    if not item or exports.rp_bw:hasPlayerBW(client) then return end

    local itemType, name = item.itemType, item.name
    local function ame(action) exports.rp_nicknames:amePlayer(client, action) end

    if itemType == 1 then -- Jedzenie
        setElementHealth(client, getElementHealth(client) + item.var1)
        ame("spożywa " .. name .. ".")
        updateItem(client, itemID, 2, 1)
        setPedAnimation(client, "FOOD", "EAT_Burger", 500, false, true, false, true, 250, true)
        if getElementHealth(client) > 20 then exports.rp_nicknames:setPlayerStatus(client, "zraniony", false) end
		if tonumber(item.var2) == 2 then 
			local drunkLevel = exports.rp_login:getPlayerData(client, "drunkLevel") or 0
			exports.rp_login:setPlayerData(client,"drunkLevel", drunkLevel + item.var3, true)
			triggerClientEvent(client,"onPlayerGotDrank", client, drunkLevel)
			if not exports.rp_nicknames:getPlayerStatus(client, "pijanstwo") then
				exports.rp_nicknames:setPlayerStatus(client, "pijanstwo", true)
			end
			if not sobrietyTimers[client] then sobrietyTimers[client] = setTimer ( playerSobriety, 180000, 1, client) end
			if drunkLevel >= 200 then
				exports.rp_chat:meCommand(client, nil, "upada na ziemię")
				exports.rp_bw:setPlayerBW(client, 100)
				if isTimer(sobrietyTimers[client]) then killTimer(sobrietyTimers[client]) end
			end
		end
    elseif itemType == 2 then -- Broń
        if item.var3 <= 0 then return end
        item.using = not item.using

        if item.using then
			if playerUsingWeapon[client] then  item.using = false exports.rp_library:createBox(client,"Schowaj broń") return end
            exports.rp_anticheat:allowPlayerWeapon(client, tonumber(item.var1))
            ame("wyciąga " .. name .. ".")
            giveWeapon(client, item.var1, item.var3, true)
            playerUsingWeapon[client] = {itemID, item.var3}
			triggerClientEvent(root,"onPlayerWeaponChangedState", getRootElement(), client, true)
			 local styleWeapon = item.var2
			if weaponStyles[item.var1] then
            if styleWeapon == "pro" then
                setPedStat(client, weaponStyles[item.var1], 1000)
            elseif styleWeapon == "std" then
                setPedStat(client, weaponStyles[item.var1], 500)
            elseif styleWeapon == "poor" then
                setPedStat(client, weaponStyles[item.var1], 0)
            end
			end
        else
            ame("chowa " .. name .. ".")
            takeWeapon(client, item.var1)
            exports.rp_anticheat:allowPlayerWeapon(client, 0)
            playerUsingWeapon[client] = nil
			triggerClientEvent(root,"onPlayerWeaponChangedState", getRootElement(), client)
        end

    elseif itemType == 3 then -- Kominiarka
        item.using = not item.using
        -- item.var1 = item.var1 - 1
        if item.var1 <= 0 then
            updateItem(client, itemID, 2, 1)
            exports.rp_library:createBox(client, "Kominiarka się podarła.")
            return exports.rp_login:setPlayerData(client, "visibleName", exports.rp_login:getPlayerData(client, "name") .. " " .. exports.rp_login:getPlayerData(client, "surname"))
        end
        if item.using then
            ame("zakłada kominiarkę.")
            local gender = exports.rp_login:getPlayerGender(client) == "male" and "Zamaskowany " or "Zamaskowana "
            exports.rp_login:setPlayerData(client, "visibleName", gender .. exports.rp_utils:toHex(exports.rp_login:getPlayerData(client, "characterID") + 9999))
			item.var1 = item.var1 - 1
        else
            ame("ściąga kominiarkę.")
            exports.rp_login:setPlayerData(client, "visibleName", exports.rp_login:getPlayerData(client, "name") .. " " .. exports.rp_login:getPlayerData(client, "surname"))
        end

    elseif itemType == 4 then -- Magazynek
        local weapon = getPedWeapon(client)
        local weaponUsing = playerUsingWeapon[client]
        if not weaponUsing or exports.rp_utils:isMelee(weapon) or weapon ~= tonumber(item.var2) then return end

        local itemCurrent = tempItems[client][weaponUsing[1]]
        itemCurrent.var3 = itemCurrent.var3 + item.var1
        updateItem(client, itemID, 2, 1)
        setWeaponAmmo(client, weapon, itemCurrent.var3)
        ame("załadował magazynek do " .. itemCurrent.name .. ".")

    elseif itemType == 5 then -- Kamizelka
        item.using = not item.using
        if item.var1 <= 0 then
            updateItem(client, itemID, 2, 1)
            exports.rp_library:createBox(client, "Kamizelka się zniszczyła.")
            return setPedArmor(client, 0)
        end
        setPedArmor(client, item.using and 100 or 0)
		ame(item.using and "zakłada kamizelkę." or "ściąga kamizelkę.")
        exports.rp_nicknames:setPlayerStatus(client, "kamizelka", item.using)

    elseif itemType == 8 then -- Rękawiczki -- 6 to cialo
		item.using = not item.using
		if item.using then
			item.var1 = item.var1 - 1
			if item.var1 <= 0 then 
				updateItem(client, itemID, 2, 1)
				exports.rp_library:createBox(client, "Rękawiczki się podarły.")
				return
			end
		end
		ame(item.using and "zakłada rękawiczki." or "ściąga rękawiczki.")
		exports.rp_nicknames:setPlayerStatus(client, "rękawiczki", item.using)

	elseif itemType == 7 then -- narkotyki 
		exports.rp_drugs:onPlayerUseDrug(client,item.var1) -- var1 przy narkotykach to typ narkotyku.
		exports.rp_nicknames:setPlayerStatus(client, "nacpany", true)
        ame("zażywa " .. name .. ".")
        updateItem(client, itemID, 2, 1)
	elseif itemType == 9 then -- boombox link komenda link pod muze. attach obiektu 2226
		item.using = not item.using
		ame(item.using and "wyciąga boomboxa." or "chowa boomboxa.")
		if item.using then
			if not tempObjects[client] then tempObjects[client] = {} end
			local url = exports.rp_login:getPlayerData(client,"boomboxUrl")
			if not url then item.using = false return exports.rp_library:createBox(client,"Podaj link, do boomboxa. /boombox [link]") end
			local boombox = createObject(2226, 0, 0, 0)
			table.insert(tempObjects[client], boombox)
			exports.pAttach:attach(boombox, client, 34, 0.4, 0, 0, 0, 280, 0)
			triggerClientEvent(root,"onPlayerStartBoombox", getRootElement(), client, url)
			else
				local obj, index = findTempPlayerObjectID(client, 2226)
				if obj then destroyElement(obj) end
				table.remove(tempObjects[client], index)
				triggerClientEvent(root, "onPlayerStopBoombox", getRootElement(), client)
		end
	
	elseif itemType == 10 then -- spray
		if item.var3 <= 0 then return exports.rp_library:createBox(client,"Nie ma nic w sprayu.") end
		item.using = not item.using
		ame(item.using and "wyciąga spray." or "chowa spray.")
	-- triggerClientEvent(client,"onPlayerEnableGraffiti", client)
	if item.using then
		if playerUsingWeapon[client] then exports.rp_library:createBox(client, "Schowaj broń")  item.using = false return end
	    exports.rp_anticheat:allowPlayerWeapon(client, tonumber(item.var1))
	    playerUsingWeapon[client] = {itemID, item.var3}
		giveWeapon(client, item.var1, item.var3, true)
	else
		playerUsingWeapon[client] = nil
		takeWeapon(client, item.var1, item.var3)
	end
	elseif itemType == 11 then -- ciuch
		if exports.rp_newmodels:getElementModel(client) == item.var1 then
			local defaultSkin = exports.rp_login:getCharDataFromTable(client, "skin")
			exports.rp_newmodels:setElementModel(client, defaultSkin)
			item.using = false
		else
			local hasPremium = exports.rp_login:getPlayerData(client,"premium")
			if not hasPremium and exports.rp_shop:skinIsPremium(tonumber(item.var1)) then return exports.rp_library:createBox(client,"Skiny customowe może zakładać tylko gracz premium.") end
			ame("zakłada outfit.")
			exports.rp_newmodels:setElementModel(client, item.var1)
			item.using = true
		end
	elseif itemType == 12 then -- kanister
			local vehicle = exports.rp_utils:getNearestElement(client, "vehicle", 3)
			if not vehicle then return exports.rp_library:createBox(client,"Nie ma pojazdu obok, do którego chcesz wlać paliwo.") end
			local noFuel = exports.rp_vehicles:getVehicleCurrentData(vehicle,"fuel") < 1
			if noFuel then
				updateItem(client, itemID, 2, 1)
				exports.rp_vehicles:changeVehicleCurrentStatistics(vehicle,"fuel", 5)
				ame("tankuje pojazd.")
			else 
				exports.rp_library:createBox(client,"Pojazd posiada paliwo.")
			end
	elseif itemType == 13 then -- steryd
		updateItem(client, itemID, 2, 1)
		ame("wstrzykuje steryd.")
		exports.rp_gym:onPlayerUsedSteroids(client)
	elseif itemType == 15 then -- wytrych
		local vehicle = exports.rp_utils:getNearestElement(client, "vehicle", 3)
		if not vehicle then return exports.rp_library:createBox(client,"Nie ma pojazdu obok, do którego możesz uzyć wytrychu.") end
		if not isVehicleLocked(vehicle) then return exports.rp_library:createBox(client,"Pojazd jest już otwarty, użyj /v kradnij będąć w pojeździe.") end
		setVehicleLocked(vehicle, false)
	elseif itemType == 16 then -- taser
			item.using = not item.using
			if item.using then
			if playerUsingWeapon[client] then  item.using = false exports.rp_library:createBox(client,"Schowaj broń") return end
            exports.rp_anticheat:allowPlayerWeapon(client, 23)
            ame("wyciąga " .. name .. ".")
            giveWeapon(client, 23, 99999, true)
            playerUsingWeapon[client] = {itemID, 99999}
			exports.rp_login:setPlayerData(client, "taser", true, true)
        else
            ame("chowa " .. name .. ".")
            takeWeapon(client, 23)
            exports.rp_anticheat:allowPlayerWeapon(client, 0)
            playerUsingWeapon[client] = nil
			exports.rp_login:setPlayerData(client, "taser", false, true)
        end
		elseif itemType == 17 then -- telefon
			item.using = not item.using
			if item.using then
				local phoneData = item.var4
				-- local number = tonumber(phoneData.settings[1]["number"])
				bindKey ( client, "home", "down", openPhone, itemID)
				phoneDatas[client] = phoneData
				ame("wyciąga "..name..".")
				else
				unbindKey ( client, "home", "down", openPhone) -- tworzenie obiektu, cos?
				phoneDatas[client] = nil
			end
	
	elseif itemType == 999 then
			outputChatBox("Dane: "..item.var2, client, 255, 255, 255)
    end
end

addEvent("onPlayerUseItem", true)
addEventHandler("onPlayerUseItem", getRootElement(), handlerUseItem)

function useItem(player, itemType)
	if not tempItems[player] then getPlayerItems(player) end
	for k,v in pairs(tempItems[player]) do
		if tonumber(v.itemType) == tonumber(itemType) then
			phoneDatas[player] = v.var4
			bindKey ( player, "home", "down", openPhone, v.id)
			v.using = true
			break
		end
	end
end
-- addCommandHandler("kutas", useItem, false, false)
function openPhone(player, key, keystate, itemID)
	-- iprint("serwer: ", phoneData)
	if exports.rp_bw:hasPlayerBW(player) then return exports.rp_library:createBox(player,"Nie możesz używać telefonu podczas BW.") end
	local phoneData = tempItems[player][itemID].var4
	-- iprint(phoneData)
	triggerClientEvent(player,"onPlayerUsePhone", player, phoneData)
end

function getPlayerPhoneData(player)
	return phoneDatas[player] or false
end

function getPlayerPhoneNumber(player)
	local number = phoneDatas[player].number
	return number or false
	-- return phoneDatas[player].
end

function findPlayerByNumer(number)
    if not number then return print("brak numeru") end
    
    for player, data in pairs(phoneDatas) do
		-- iprint(player,data)
        if data and tonumber(data.number) == tonumber(number) then
            return player
        end
    end
    return false
end

-- addCommandHandler("super", findPlayerByNumer, false, false)
function handlerDivideItem(itemID, divideAmount)
	-- outputChatBox("ID przedmiotu: "..itemID.." Podzielić: "..divideAmount)
    local uidItem = tonumber(itemID)
    local item = tempItems[client]
    if not item then
        return 
    end -- ban
    local item = tempItems[client][uidItem]
    if not item then
        return 
    end
	
	local amount = tonumber(item.itemCount)
	local divideAmount = tonumber(divideAmount)
	if divideAmount < 0 then return end
	if tonumber(amount) <= tonumber(divideAmount) then return print("invalid value") end
	item.itemCount = amount - divideAmount
	addItemToPlayer(client, item.name, item.itemType, divideAmount, item.var1, item.var2, item.var3) --addItemToPlayer(player, name, itemType, itemCount, var1, var2, var3)
	exports.rp_library:createBox(client,"Podzieliłeś ".. item.name.. ".")
	triggerClientEvent(client, "onUpdateInventory", client, getPlayerItems(client))
end
addEvent("onPlayerDivideItem", true)
addEventHandler("onPlayerDivideItem", getRootElement(), handlerDivideItem)


function deployHandlerItem(itemID)
    local uidItem = tonumber(itemID)
    local item = tempItems[client]
    if not item then
        return
    end -- ban
    local item = tempItems[client][uidItem]
    if not item then
        return
    end
		local x,y,z = getElementPosition(client)
		local dim, int = getElementDimension(client), getElementInterior(client)
		local deployedItem = {
        id = uidItem,
        name = item.name,
        x = x,
        y = y,
        z = z,
        interior = int,
        dimension = dim,
        ownerType = 3, 
        owner = 0,
		var1 = item.var1,
		var2 = item.var2,
		var3 = item.var3,
		var4 = item.var4,
		itemType = item.itemType,
		itemCount = item.itemCount
    }

    if not isPedInVehicle(client) then
        exports.rp_db:query_free("UPDATE items SET owner = 0, ownerType = 3, x = ?, y = ?, z = ?, interior = ?, dimension = ? WHERE id = ?",x, y, z, int, dim, uidItem)
		local objID = 2969
		local gunShell = false
		local setRot = false
		if deployedItem.itemType == 2 then
			local var1 = deployedItem.var1
			objID = deployedObjectsID[var1]
			setRot = true
		elseif deployedItem.itemType == 6 then
			objID = 2070
		elseif deployedItem.itemType == 999 then
			objID = 2061
			gunShell = true
		end
		
        deployedItem.obj = createObject(objID, x, y, z - 0.9, 0, 0, 0)
		if setRot then
			setElementRotation(deployedItem.obj, 90, 0, 0)
		end
		if gunShell then
			setElementRotation(deployedItem.obj, 90, 0, 0)
			setObjectScale(deployedItem.obj, 0.2)
		end
        setElementCollisionsEnabled(deployedItem.obj, false)
        if not exports.rp_bw:hasPlayerBW(client) then
            setPedAnimation(client, "BOMBER", "BOM_Plant", -1, false, true, false, false)
        end


        -- item.ownerType, item.owner = 3, 0
        -- item.x, item.y, item.z = x, y, z
        -- item.interior, item.dimension = int, dim
		deployedItem.ownerType = 3
		deployedItem.owner = 0
        exports.rp_nicknames:amePlayer(client, "odkłada przedmiot.")
    else
        local veh = getPedOccupiedVehicle(client)
        local uid = exports.rp_vehicles:getVehicleUID(veh)
        -- item.owner, item.ownerType = uid, 4
        exports.rp_nicknames:amePlayer(client, "odkłada przedmiot w pojeździe.")
        exports.rp_db:query_free("UPDATE items SET owner = ?, ownerType = 4 WHERE id = ?",uid, uidItem)
		deployedItem.ownerType = 4
		deployedItem.owner = uid 
    end
    deployedItems[uidItem] = deployedItem
    tempItems[client][uidItem] = nil
    triggerClientEvent(client, "onUpdateInventory", client, getPlayerItems(client))
	
end
addEvent("onPlayerDeployItem", true)
addEventHandler("onPlayerDeployItem", root, deployHandlerItem)

function pickUpItem(items)
    local player = client
	if exports.rp_bw:hasPlayerBW(player) then return exports.rp_library:createBox(player,"Podczas BW nie możesz podnosić przedmiotów.") end
    if not tempItems[player] then
        getPlayerItems(player)
    end
    local owner = exports.rp_login:getPlayerData(player, "characterID")
    for _, itemID in ipairs(items) do
        local deployedItem = deployedItems[itemID]
        if deployedItem then
            -- local playerX, playerY, playerZ = getElementPosition(player)
            -- local distance = getDistanceBetweenPoints3D(playerX, playerY, playerZ, deployedItem.x, deployedItem.y, deployedItem.z)

            -- if distance <= 5 then 
                tempItems[player][itemID] = {
                    id = deployedItem.id,
                    name = deployedItem.name,
                    var1 = deployedItem.var1,
                    var2 = deployedItem.var2,
                    var3 = deployedItem.var3,
					var4 = deployedItem.var4,
					itemCount = deployedItem.itemCount,
					x = 0,
					y = 0,
					z = 0,
					interior = 0,
					dimension = 0,
                    itemType = deployedItem.itemType,
                    owner = owner, 
                    ownerType = 1 
                }

                exports.rp_db:query_free("UPDATE items SET owner = ?, ownerType = 1 WHERE id = ?",owner, itemID)

                if isElement(deployedItem.obj) then
                    destroyElement(deployedItem.obj)
                end
                deployedItems[itemID] = nil
				if #items > 1 then
				exports.rp_nicknames:amePlayer(player, "podnosi przedmioty.")
				else
				exports.rp_nicknames:amePlayer(player, "podnosi przedmiot.")
				end
			if not exports.rp_bw:hasPlayerBW(player) and not getPedOccupiedVehicle(player) then
            setPedAnimation(player, "BOMBER", "BOM_Plant", -1, false, true, false, false)
			end
			
            -- else
                -- outputChatBox("Przedmiot jest za daleko!", player, 255, 0, 0)
            -- end
        end
    end

    triggerClientEvent(player, "onUpdateInventory", player, getPlayerItems(player))
end
addEvent("onPlayerPickUpItem", true)
addEventHandler("onPlayerPickUpItem", root, pickUpItem)


function combineHandlerItems(items)
    if not tempItems[client] then
        return
    end

    local itemsData = items
    local allCount = 0

    for _, itemId in ipairs(itemsData) do
        local item = tempItems[client][itemId]
        if not item then
            return 
        end
        allCount = allCount + item.itemCount
    end

    for i = 1, #itemsData - 1 do
        local itemId = itemsData[i]
        tempItems[client][itemId] = nil
        exports.rp_db:query_free("DELETE FROM items WHERE id = ?", itemId)
    end

    local lastItemId = itemsData[#itemsData]
    if tempItems[client][lastItemId] then
        tempItems[client][lastItemId].itemCount = allCount
    else
        return
    end

    triggerClientEvent(client, "onUpdateInventory", client, getPlayerItems(client))
end
addEvent("onPlayerCombineItems", true)
addEventHandler("onPlayerCombineItems", root, combineHandlerItems)

function giveHandlerItem(target, itemID)
	local uidItem = tonumber(itemID)
    local item = tempItems[client]
    if not item then
        return
    end -- ban
    local item = tempItems[client][uidItem]
    if not item then
        return
    end
	local targetID = tonumber(target)
	local realTarget = exports.rp_login:findPlayerByID(targetID)
	if not realTarget then return exports.rp_library:createBox(client,"Nie ma gracza o podanym ID na serwerze.") end
	local distance = getDistanceBetweenElements(client, realTarget)
	if distance >= 5 then return exports.rp_library:createBox(client,"Gracz o podanym ID jest za daleko.") end
	-- send offer to player
	 if client == realTarget then exports.rp_library:createBox(client, "Nie możesz podać przedmiotu samemu sobie.") return end
	exports.rp_offers:sendOffer(client, realTarget, 1, uidItem, 0, item.name) -- ofka
	
	
	

end
addEvent("onPlayerGiveItem", true)
addEventHandler("onPlayerGiveItem", root, giveHandlerItem)

function giveItemToPlayer(player, target, itemID)
	local uidItem = tonumber(itemID)
	local item = tempItems[player][uidItem]
	if not item then return exports.rp_library:createBox(player,"Przedmiot nie istnieje.") end
	exports.rp_nicknames:amePlayer(player, "podaje przedmiot do "..exports.rp_utils:getPlayerICName(target)..".")
	item.owner = exports.rp_login:getPlayerData(target, "characterID")
	tempItems[player][uidItem] = nil
	tempItems[target][uidItem] = item
    triggerClientEvent(player, "onUpdateInventory", player, getPlayerItems(player))
	triggerClientEvent(target, "onUpdateInventory", target, getPlayerItems(target))
	exports.rp_db:query_free("UPDATE items SET owner = ? WHERE id = ?",item.owner, uidItem)
	exports.rp_library:createBox(player,"Podałeś przedmiot do gracza.")
end




addEventHandler("onPlayerWeaponFire", root,
    function(weapon, endX, endY, endZ, hitElement, startX, startY, startZ)
        local playerWeapon = playerUsingWeapon[source]
		local taser = exports.rp_login:getPlayerData(source, "taser")

        if not playerWeapon or taser then
            return
        end
        local itemID, ammo = playerUsingWeapon[source][1], playerUsingWeapon[source][2]
        local item = tempItems[source][itemID]

        -- tworzenie łusek
        local isMeleeweapon = exports.rp_utils:isMelee(weapon)
        if not isMeleeweapon then
            if math.random(1, 6) == 1 then  -- 16.6% szansy na stworzenie łuski
                local hadPlayerGloves = exports.rp_nicknames:getPlayerStatus(source, "rękawiczki")
                
                local leaveFingerprint = false
                if hadPlayerGloves then
                    leaveFingerprint = math.random(1, 20) == 1 -- 5% szansy na odcisk mimo rękawiczek
                else
                    leaveFingerprint = math.random(1, 4) == 1  -- 25% szansy na odcisk bez rękawiczek
                end

                createOrUpdateGunShell(source, getWeaponNameFromID(weapon), leaveFingerprint)
            end
        end

        item.var3 = item.var3 - 1
        if item.var3 <= 0 then
            exports.rp_nicknames:amePlayer(source, "chowa " .. item.name .. ".")
            takeWeapon(source, item.var1)
            exports.rp_anticheat:allowPlayerWeapon(source, 0)
            playerUsingWeapon[source] = nil
            item.using = false
        end
    end
)


function generatePhoneNumber(itemID)
    local phoneNumber = 100000 + (itemID * 743) % 900000
    return phoneNumber
end


function addItemToPlayer(player, name, itemType, itemCount, var1, var2, var3)
    if not tempItems[player] then
        getPlayerItems(player) 
    end

    local owner = exports.rp_login:getPlayerData(player, "characterID")
    if not owner then
        return false 
    end

    local queryItem = exports.rp_db:query("SELECT id FROM items ORDER BY id DESC LIMIT 1")
    local itemID = 1
    if queryItem and queryItem[1] then
        itemID = queryItem[1].id + 1 
    end

		-- if next(var1) then var1 = toJSON(var1)
	local isPhone = {}

	if tonumber(itemType) == 17 then
		 local dane = {
        settings = {
            {name = "Zastrzeż numer", state = false},
            {name = "Wycisz telefon", state = false},
            {name = "Dzwonek", state = 1, max = 3},
            {name = "Tło telefonu", state = 1, max = 4}
        },
        contacts = {},
		number = generatePhoneNumber(itemID),
    }
	
	isPhone = dane
	end
    tempItems[player][itemID] = {
        id = itemID,
        name = name,
        ownerType = 1,
        owner = owner,
        itemType = itemType,
        itemCount = itemCount,
        var1 = var1,
        var2 = var2,
        var3 = var3,
		var4 = isPhone
		
    }


		local res = exports.rp_db:query_free("INSERT INTO items (id, name, ownerType, owner, itemType, itemCount, var1, var2, var3, var4) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", itemID, name, 1, owner, itemType, itemCount, var1, var2, var3, toJSON(isPhone))

    -- local insertQuery = string.format("INSERT INTO items (id, name, ownerType, owner, itemType, itemCount, var1, var2, var3) VALUES (%d, '%s', 1, %d, %d, %d, %d, %d, %d)",
        -- itemID, name, owner, itemType, itemCount, var1, var2, var3)
    -- exports.rp_db:query(insertQuery)
end

function addTestItems(player)
    for i = 1, 20 do
        addItemToPlayer(player, "Nazwa Itemu: " .. i, 1, 1, 1, 1, 1)
    end
end

function disposeItem(player, itemID)
	local item = tempItems[player][itemID]
	if not item then return end
	exports.rp_nicknames:amePlayer(player, "utylizuje przedmiot "..item.name)
	tempItems[player][itemID] = nil
	exports.rp_db:query_free("DELETE FROM items WHERE id = ?", itemID)
	triggerClientEvent(player,"onUpdateInventory",player, getPlayerItems(player))
end

function destroyItem(player, itemID)
	local item = tempItems[player][itemID] or deployedItems[itemID]
	if not item then return end
	local obj = item.obj
	if isElement(obj) then destroyElement(obj) end
	tempItems[player][itemID] = nil
	exports.rp_db:query_free("DELETE FROM items WHERE id = ?", itemID)
	triggerClientEvent(player,"onUpdateInventory",player, getPlayerItems(player))
	return true
end

function destroyItemWithoutPlayer(itemID)
	local item = deployedItems[itemID]
	if not item then return end
	local obj = item.obj
	if isElement(obj) then destroyElement(obj) end
	exports.rp_db:query_free("DELETE FROM items WHERE id = ?", itemID)
end

function updateItem(player, uid, typ, number) -- 1 dodawanie, 2 odejmowanie
   	local item = tempItems[player][uid]
	if not item then return end

   if typ == 1 then
      item.itemCount = item.itemCount + number
   elseif  typ == 2 then
      local countItem = item.itemCount
      local dataAferDeduct = countItem - number
      if dataAferDeduct > 0 then
        item.itemCount = dataAferDeduct
      elseif dataAferDeduct <= 0 then
		 tempItems[player][uid] = nil
		 exports.rp_db:query_free("DELETE FROM items WHERE id = ?", uid)
      end
	  triggerClientEvent(player,"onUpdateInventory",player, getPlayerItems(player))
   end
end

function openInventory(player)
    local logged = exports.rp_login:getPlayerData(player,"characterID") --exports.rp_login:isLoggedPlayer(player)
    if not logged then
        return
    end
	if not exports.rp_utils:checkPassiveTimer("inventoryOpen", player, 300) then return exports.rp_library:createBox(player,"Poczekaj chwilę przed otwarciem ekwipunku.") end
    local playerEQ = getPlayerItems(player)
    triggerClientEvent(player, "onPlayerOpenInventory", player, playerEQ)
end

local function playerJoined()
    bindKey(source, "I", "down", openInventory)
end
addEventHandler("onPlayerJoin", root, playerJoined)

local function onResRestart(res)
    if res == getThisResource() then
        local players = getElementsByType("player")
        for k, v in pairs(players) do
            bindKey(v, "I", "down", openInventory)
        end
    end
end
addEventHandler("onResourceStart", root, onResRestart)


addEventHandler("onPlayerQuit", root, function()
    local player = source 
    if playerUsingWeapon[player] then
		playerUsingWeapon[player] = nil
    end
	if phoneDatas[player] then
		phoneDatas[player] = nil
	end
	if tempObjects[player] then
		destroyTempPlayerObjects(player)
	end
end)

function getUsedTypeItem(player, itemType)
    if not tempItems[player] then
        return false
    end

    local items = tempItems[player]

    for _, item in pairs(items) do
        if item.using and tonumber(item.itemType) == tonumber(itemType) then
            return item.id
        end
    end

    return false
end

function findItemInInventoryByItemType(player, itemType)
    if not tempItems[player] then
        return false
    end

    local items = tempItems[player]

    for _, item in pairs(items) do
        if tonumber(item.itemType) == tonumber(itemType) then
            return item.id
        end
    end

    return false
end


function getItemTypeInInventory(player, itemType, updateItemG, getAllItems)
    if not tempItems[player] then
        return false
    end

    local items = tempItems[player]
    itemType = tonumber(itemType)

    if getAllItems then
        local tmpTable = {}
        for _, item in pairs(items) do
            if tonumber(item.itemType) == itemType then
                table.insert(tmpTable, {itemID = item.id, itemCount = item.itemCount}) -- id przedmiotow i ilosc przedmiotu
            end
        end
        return tmpTable
    else
        for _, item in pairs(items) do
            if tonumber(item.itemType) == itemType then
                if updateItemG then
                    updateItem(player, item.id, 2, updateItemG) -- zwraca id przedmiotu i var, zwraca tylko pierwszy znaleziony przedmiot
                end
                return item.id, item.var1
            end
        end
    end

    return false
end




function pItem(player, cmand, action, itemID)
    if action == "p" or action == "podnies" then
        -- iprint(items)
		-- getItemType(player,7)
        local items
        local vehicle = getPedOccupiedVehicle(player)
        if vehicle then
            if not exports.rp_vehicles:hasPlayerPermToVehicle(player, vehicle) then
                return exports.rp_library:createBox(player, "Nie posiadasz uprawnień do przeszukiwania tego pojazdu.")
            end
            items = nearbyDeployedItems(player, vehicle)
        else
            items = nearbyDeployedItems(player)
        end
		if #items <= 0 then
                return exports.rp_library:createBox(player, "Nie ma w pobliżu przedmiotów.")
            end

        -- iprint(items)
		if exports.rp_bw:hasPlayerBW(player) then return exports.rp_library:createBox(player,"Podczas BW nie możesz podnosić przedmiotów.") end
        triggerClientEvent(player, "onPlayerPickUpItems", player, items)
	elseif action == "usun" then
	if not exports.rp_admin:hasAdminPerm(player, "deleteItems") then return end
	local itemID = tonumber(itemID)
	if not itemID then return exports.rp_library:createBox(player,"/p usun [ID przedmiotu]") end
	if not tempItems[player] then getPlayerItems(player) end
	local item = tempItems[player][itemID]
	if not item then return exports.rp_library:createBox(player, "Nie ma takiego przedmiotu w twoim ekwipunku.") end
	destroyItem(player, itemID)
	elseif action == "usunl" then
	if not exports.rp_admin:hasAdminPerm(player, "deleteItems") then return end
	local items = nearbyDeployedItems(player)
	local found = false
	for k,v in pairs(items) do
		destroyItem(player, v.id)
		found = true
	end
	if found then exports.rp_library:createBox(player,"Usunięto w pobliżu przedmioty.") end
    elseif action == "uzyj" then -- bind na uzywanie itemu po uid
	elseif action == "utylizuj" then
	if not exports.rp_groups:hasPerm(player,"disposalItems") then return end
	local itemID = tonumber(itemID)
	if not itemID then return exports.rp_library:createBox(player,"/p utylizuj [ID przedmiotu]") end
	if not tempItems[player] then getPlayerItems(player) end
	local item = tempItems[player][itemID]
	if not item then return exports.rp_library:createBox(player, "Nie ma takiego przedmiotu w twoim ekwipunku.") end
	if tonumber(item.itemType) ~= 2 and tonumber(item.itemType) ~= 7 then return exports.rp_library:createBox(player,"Utylizować można tylko broń i narkotyki.") end
	disposeItem(player, itemID)
    elseif action == "naladuj" then
		local itemID = tonumber(itemID)
		if not itemID then return exports.rp_library:createBox(player,"/p naladuj [ID przedmiotu]") end
        if not tempItems[player] then
            getPlayerItems(player)
        end
        local item = tempItems[player][itemID]
        if not item then
            return exports.rp_library:createBox(player, "Nie ma takiego przedmiotu w twoim ekwipunku.")
        end
        if item.itemType ~= 2 then
            return exports.rp_library:createBox(player, "Nie da się naładować magazynku do tego przedmiotu")
        end
		
		if item.using then 
			return exports.rp_library:createBox(player, "Załaduj magazynek przez ekwipunek, nie przez komendę jeżeli posiadasz broń wyjętą.")
		end
		
        local weapon = item.var1
        local foundMagazine = false
        for k, v in pairs(tempItems[player]) do -- znalezienie magazynka
            if v.itemType == 4 and tonumber(v.var2) == tonumber(weapon) then
                foundMagazine = v.id
                break
            end
        end
		if foundMagazine then 
			local ammo = tempItems[player][foundMagazine].var1
			item.var3 = item.var3 + ammo 
			exports.rp_nicknames:amePlayer(player, "załadował magazynek do "..item.name..".")
			updateItem(player, foundMagazine, 2, 1)
			else
			exports.rp_library:createBox(player,"W ekwipunku nie masz magazynka pasującego do tego przedmiotu.")
		end
		
    else
    end
end
addCommandHandler("p", pItem, false, false)

function searchInventory(player, cmd, targetType, targetID)
    if not exports.rp_groups:hasPerm(player, "searchInterior") or not exports.rp_admin:hasAdminPerm(player, "searchPlayer") then 
        return 
    end

    if not targetType then 
        return exports.rp_library:createBox(player, "/przeszukaj [gracz/pojazd] [id, tylko do gracza]") 
    end

    if targetType == "gracz" or targetType == "g" then
		if not targetID then return exports.rp_library:createBox(player,"Podaj ID gracza.") end
        local targetIDNum = tonumber(targetID)
		
        local realTarget = exports.rp_login:findPlayerByID(targetIDNum)
        if not realTarget then 
            return exports.rp_library:createBox(player, "Nie ma gracza o podanym ID na serwerze.") 
        end

        local distance = getDistanceBetweenElements(player, realTarget)
        if distance >= 5 then 
            return exports.rp_library:createBox(player, "Gracz o podanym ID jest za daleko.") 
        end

        local targetItems = getPlayerItems(realTarget)
		local money = exports.rp_login:getPlayerData(realTarget, "money")
        triggerClientEvent(player, "onPlayerPickUpItems", player, targetItems, true, _, money)
        exports.rp_chat:meCommand(player, nil, "przeszukuje " .. exports.rp_utils:getPlayerICName(realTarget))

    elseif targetType == "p" or targetType == "pojazd" then
        local vehicle = getPedOccupiedVehicle(player)
        if not vehicle or not isElement(vehicle) then 
            return exports.rp_library:createBox(player, "Nie znaleziono pojazdu.") 
        end

        local distance = getDistanceBetweenElements(player, vehicle)
        if distance >= 5 then 
            return exports.rp_library:createBox(player, "Pojazd jest za daleko.") 
        end

        local vehicleItems = nearbyDeployedItems(player, vehicle)
        triggerClientEvent(player, "onPlayerPickUpItems", player, vehicleItems, true, true)
        exports.rp_chat:meCommand(player, nil, "przeszukuje pojazd")

    else
        return exports.rp_library:createBox(player, "Niepoprawny typ celu. Użyj: gracz/g lub pojazd/p.")
    end
end
addCommandHandler("przeszukaj", searchInventory, false, false)


function graffitiCommand(player, cmand)
	if getUsedTypeItem(player, 10) then
		triggerClientEvent(player,"onPlayerEnableGraffiti", player)
	end
end
addCommandHandler("graffiti", graffitiCommand, false, false)

function nearbyDeployedItems(playerElement, vehicle)
    if vehicle then
		local tmpTable = {}
        local uid = exports.rp_vehicles:getVehicleUID(vehicle)
        for idItem, data in pairs(deployedItems) do
            if data.owner == uid then
                table.insert(tmpTable, data)
            end
        end
		return tmpTable 
    else
        local playerX, playerY, playerZ = getElementPosition(playerElement)
        local playerInterior = getElementInterior(playerElement)
        local playerDimension = getElementDimension(playerElement)
        local searchRange = 5

        local nearbyObjects = getElementsWithinRange(playerX, playerY, playerZ, searchRange, "object")
        local tmpTable = {}

        for idItem, data in pairs(deployedItems) do
            if data.obj and isElement(data.obj) then
                for _, object in pairs(nearbyObjects) do
                    if data.obj == object and getElementInterior(object) == playerInterior and getElementDimension(object) == playerDimension then
                        table.insert(tmpTable, data)
                    -- iprint(data)
                    -- break
                    end
                end
            end
        end

        return tmpTable
    end
end




function onPlayerDied(ammo, attacker, weapon, bodypart, stealth, animGroup, animID)
    local playerEQ = getPlayerItems(source)
    if playerEQ then
			if playerUsingWeapon[source] then playerUsingWeapon[source] = nil end
        for k, v in pairs(tempItems[source]) do
            if v.itemType == 2 then
                v.using = false -- przestanie uzywania przedmiotow gracza, czyli broni
            end
        end
    end
end
addEventHandler("onPlayerWasted", root, onPlayerDied)

function loadItemsOnStart()
    for k, v in pairs(exports.rp_db:query("SELECT * FROM items")) do
        if v.var4 and type(v.var4) == "string" and v.var4 ~= "" then
            local decoded = fromJSON(v.var4)
            if type(decoded) == "table" then
                v.var4 = decoded
            else
                outputDebugString("Błąd dekodowania var4 dla itemu ID: " .. tostring(v.id), 1)
                v.var4 = {}
            end
        else
            v.var4 = {}
        end

        if v.ownerType == 3 then -- odlozone przedmioty
			local setRot = false
			local gunShell = false
            local objID = 2969
            if v.itemType == 6 then
                objID = 2070
			elseif v.itemType == 2 then
				local var1 = v.var1
				objID = deployedObjectsID[var1]
				setRot = true
			elseif v.itemType == 999 then
				objID = 2061
				gunShell = true
            end
		
			iprint(objID)
            local obj = createObject(objID, v.x, v.y, v.z - 0.9, 0, 0, 0)
			if setRot then
				setElementRotation(obj, 90, 0, 0)
			end
			if gunShell then
				setObjectScale(obj, 0.2)
				setElementRotation(obj, 90, 0, 0)
			end
            setElementDimension(obj, v.dimension)
            setElementInterior(obj, v.interior)
            setElementCollisionsEnabled(obj, false)
            deployedItems[v.id] = v
            deployedItems[v.id].obj = obj
        elseif v.ownerType == 4 then -- itemy w pojazdach
            deployedItems[v.id] = v
        end
    end
end

loadItemsOnStart()

function getDistanceBetweenElements(arg1, arg2)
	local element1 = Vector3(getElementPosition( arg1 ))
	local element2 = Vector3(getElementPosition( arg2 ))
	local distance = getDistanceBetweenPoints3D( element1,element2 )
	return distance
end

function createCorpse(player, reason)
    local queryItem = exports.rp_db:query("SELECT id FROM items ORDER BY id DESC LIMIT 1")
    local itemID = 1
    if queryItem and queryItem[1] then
        itemID = queryItem[1].id + 1 
    end
		local characterID = exports.rp_login:getPlayerData(player,"characterID")

		local x,y,z = getElementPosition(player)
		local dim, int = getElementDimension(player), getElementInterior(player)
		local name = "Ciało: "..exports.rp_utils:getPlayerICName(player)
		local deployedItem = {
        id = itemID,
        name = name,
        x = x,
        y = y,
        z = z,
        interior = int,
        dimension = dim,
        ownerType = 3, 
        owner = 0,
		var1 = tostring(reason), -- powod smierci
		var2 = 0,
		var3 = 0,
		var4 = {},
		itemType = 6,
		itemCount = 1,
    }
		deployedItem.obj = createObject(2070, x, y, z - 0.9, 0, 0, 0)
		setElementDimension(deployedItem.obj, dim)
		setElementInterior(deployedItem.obj, int)


    deployedItems[itemID] = deployedItem


	local res = exports.rp_db:query_free("INSERT INTO items (id, name, ownerType, owner, itemType, itemCount, var1, var2, var3, var4, x, y, z, interior, dimension) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", itemID, name, 3, 0, 6, 1, 0, tostring(reason), 0, toJSON({}), x, y, z, int, dim)
	kickPlayer(player, "Uśmiercono postać.")
	local ckQuery = exports.rp_db:query_free("UPDATE characters SET ck = 1 WHERE id = ?", characterID)
end

local function roundTo(n, precision)
        return math.floor(n / precision + 0.5) * precision
end

function createOrUpdateGunShell(player, weapon, hit)
 local queryItem = exports.rp_db:query("SELECT id FROM items ORDER BY id DESC LIMIT 1")
    local itemID = 1
    if queryItem and queryItem[1] then
        itemID = queryItem[1].id + 1 
    end
    local x, y, z = getElementPosition(player)
    local dim, int = getElementDimension(player), getElementInterior(player)
    local timestamp = "Zbliżona godzina: " .. getRealTime().hour .. ":" .. getRealTime().minute
    local fingerprint = "brak odcisku"

    if hit then
        fingerprint = exports.rp_utils:getPlayerICName(player) ..
                      " | " .. exports.rp_login:getPlayerData(player, "name") .. 
                      " " .. exports.rp_login:getPlayerData(player, "surname")
    end
	local roundedX = roundTo(x, 3)
    local roundedY = roundTo(y, 3)
    local roundedZ = roundTo(z, 3)
    -- Sprawdzamy, czy już istnieje taki przedmiot w pobliżu
    for _, item in pairs(deployedItems) do
        local itemX, itemY, itemZ = roundTo(item.x, 3), roundTo(item.y, 3), roundTo(item.z, 3)
        if item.name == "Łuska: " .. weapon and itemX == roundedX and itemY == roundedY and itemZ == roundedZ then
            -- Jeśli tak, zwiększamy ilość
            item.itemCount = item.itemCount + 1
            return
        end
    end

	local int = getElementInterior(player)
	local dim = getElementDimension(player)

    local deployedItem = {
        id = itemID,
        name = "Łuska: " .. weapon,
        x = x,
        y = y,
        z = z,
        interior = int,
        dimension = dim,
        ownerType = 3,
        owner = 0,
        var1 = 0,
        var2 = timestamp .. " " .. fingerprint,
        var3 = 0,
		var4 = {},
        itemType = 999,
        itemCount = 1
    }

    local randomPos = math.random(-1, 2)
    deployedItem.obj = createObject(2061, x, y + randomPos, z - 0.98, 90)
    setElementDimension(deployedItem.obj, dim)
    setElementInterior(deployedItem.obj, int)
    setObjectScale(deployedItem.obj, 0.2)
	deployedItems[deployedItem.id] = deployedItem
	local res = exports.rp_db:query_free("INSERT INTO items (id, name, ownerType, owner, itemType, itemCount, var1, var2, var3, var4, x, y, z, interior, dimension) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", itemID, deployedItem.name, 3, 0, 999, deployedItem.itemCount, 0, deployedItem.var2, 0, toJSON({}), x, y, z, int, dim)
    -- table.insert(deployedItems, deployedItem) -- dodanie do listy łusek
	
end

function deleteGunShells()
	for k,v in pairs(deployedItems) do
		if v.itemType == 999 then
			destroyItemWithoutPlayer(v.id)
		end
	end
end


function changePhoneData(player, data)
	if not tempItems[player] then 
		outputDebugString("[changePhoneData] Brak tempItems dla gracza") 
		return 
	end

	local itemID = findItemInInventoryByItemType(player, 17)
	if not itemID then 
		outputDebugString("[changePhoneData] Brak telefonu w EQ") 
		return 
	end

	if not tempItems[player][itemID] then 
		outputDebugString("[changePhoneData] Brak itemu z ID w tempItems") 
		return 
	end

	if not tempItems[player][itemID].var4["settings"] or not tempItems[player][itemID].var4["settings"][1] then
		outputDebugString("[changePhoneData] Brak settings[1]") 
		return
	end

	tempItems[player][itemID].var4["settings"][1]["messages"] = data.messages
	outputDebugString("[changePhoneData] Zmieniono messages dla gracza: " .. getPlayerName(player))
	-- iprint(tempItems[player][itemID].var4["settings"][1]["messages"])
end

local validSettings = {["ringtone"] = true, ["wallpaper"] = true, ["hidecallerid"] = true, ["notes"] = true, ["messages"] = true, ["telegram"] = true, ["mute"] = true }
function isValidRingtone(value)
    value = tonumber(value)
    return value and value >= 1 and value <= 3
end
function isValidWallpaper(value)
    value = tonumber(value)
    return value and value >= 1 and value <= 4
end

function onPlayerChangePhoneSettings(phoneData) -- wygenerowane przez chat gpt, TODO.
    -- Podstawowa walidacja klienta
    if not isElement(client) then return end
    if not tempItems[client] then 
        outputDebugString("Player "..getPlayerName(client).." tried to change phone settings without tempItems")
        return 
    end
    
    local isUsingPhone = getUsedTypeItem(client, 17)
    if not isUsingPhone then 
        outputDebugString("Player "..getPlayerName(client).." tried to change phone settings without using phone")
        return 
    end

    local itemData = tempItems[client][isUsingPhone]
    if not itemData or type(itemData) ~= "table" then 
        outputDebugString("Player "..getPlayerName(client).." has invalid itemData")
        return 
    end

    -- Walidacja struktury phoneData
    if not phoneData or type(phoneData) ~= "table" then
        outputDebugString("Player "..getPlayerName(client).." sent invalid phoneData structure")
        return
    end

    -- Walidacja numeru telefonu
    if not phoneData.number or type(phoneData.number) ~= "number" then
        outputDebugString("Player "..getPlayerName(client).." sent invalid phone number: "..tostring(phoneData.number))
        return
    end
    
    if phoneData.number < 10000 or phoneData.number > 999999 then
        outputDebugString("Player "..getPlayerName(client).." sent phone number out of range: "..phoneData.number)
        return
    end

    -- Walidacja kontaktów
    if not phoneData.contacts or type(phoneData.contacts) ~= "table" then
        outputDebugString("Player "..getPlayerName(client).." sent invalid contacts")
        return
    end

    -- Walidacja każdego kontaktu
    for i, contact in ipairs(phoneData.contacts) do
        if type(contact) ~= "table" then
            outputDebugString("Player "..getPlayerName(client).." sent invalid contact at index "..i)
            return
        end
        
        -- Walidacja nazwy kontaktu
        if not contact.name or type(contact.name) ~= "string" then
            outputDebugString("Player "..getPlayerName(client).." sent invalid contact name at index "..i)
            return
        end
        
        if #contact.name < 1 or #contact.name > 50 then
            outputDebugString("Player "..getPlayerName(client).." sent contact name with invalid length at index "..i)
            return
        end
        
        
        local cleanPhoneNumber = contact.phoneNumber:gsub("%s+", ""):gsub("-", "")
        if #cleanPhoneNumber < 3 or #cleanPhoneNumber > 15 then
            outputDebugString("Player "..getPlayerName(client).." sent contact phoneNumber with invalid length at index "..i)
            return
        end
        

        -- Walidacja wiadomości w kontakcie
        if contact.messages and type(contact.messages) == "table" then
            for j, message in ipairs(contact.messages) do
                if type(message) ~= "table" then
                    outputDebugString("Player "..getPlayerName(client).." sent invalid message at contact "..i..", message "..j)
                    return
                end
                
                -- Walidacja treści wiadomości
                if not message.text or type(message.text) ~= "string" then
                    outputDebugString("Player "..getPlayerName(client).." sent invalid message text at contact "..i..", message "..j)
                    return
                end
                
                if #message.text < 1 or #message.text > 160 then
                    outputDebugString("Player "..getPlayerName(client).." sent message text with invalid length at contact "..i..", message "..j)
                    return
                end
                
                -- Walidacja nadawcy
                if not message.sender or (type(message.sender) ~= "number" and type(message.sender) ~= "string") then
                    outputDebugString("Player "..getPlayerName(client).." sent invalid message sender at contact "..i..", message "..j)
                    return
                end
                
                -- Walidacja odbiorcy
                if not message.receiver or type(message.receiver) ~= "string" then
                    outputDebugString("Player "..getPlayerName(client).." sent invalid message receiver at contact "..i..", message "..j)
                    return
                end
                
                -- Walidacja timestamp
                if message.timestamp and type(message.timestamp) ~= "number" then
                    outputDebugString("Player "..getPlayerName(client).." sent invalid message timestamp at contact "..i..", message "..j)
                    return
                end
                
                -- Walidacja formattedDate
                if message.formattedDate and type(message.formattedDate) ~= "string" then
                    outputDebugString("Player "..getPlayerName(client).." sent invalid message formattedDate at contact "..i..", message "..j)
                    return
                end
                
                -- Walidacja statusu
                if message.status and type(message.status) ~= "string" then
                    outputDebugString("Player "..getPlayerName(client).." sent invalid message status at contact "..i..", message "..j)
                    return
                end
            end
        end
    end

    -- Walidacja ustawień
    if not phoneData.settings or type(phoneData.settings) ~= "table" then
        outputDebugString("Player "..getPlayerName(client).." sent invalid settings")
        return
    end

    for i, setting in ipairs(phoneData.settings) do
        if type(setting) ~= "table" then
            outputDebugString("Player "..getPlayerName(client).." sent invalid setting at index "..i)
            return
        end
        
        -- Walidacja nazwy ustawienia
        if not setting.name or type(setting.name) ~= "string" then
            outputDebugString("Player "..getPlayerName(client).." sent invalid setting name at index "..i)
            return
        end
        
        -- Walidacja stanu ustawienia
        if setting.state == nil then
            outputDebugString("Player "..getPlayerName(client).." sent invalid setting state at index "..i)
            return
        end
        
        -- Walidacja maksymalnej wartości dla ustawień numerycznych
        if setting.max and type(setting.max) ~= "number" then
            outputDebugString("Player "..getPlayerName(client).." sent invalid setting max at index "..i)
            return
        end
        
        -- Sprawdź czy stan mieści się w zakresie dla ustawień z max
        if setting.max and type(setting.state) == "number" then
            if setting.state < 1 or setting.state > setting.max then
                outputDebugString("Player "..getPlayerName(client).." sent setting state out of range at index "..i)
                return
            end
        end
    end

    -- Walidacja głównej listy wiadomości
    if phoneData.messages and type(phoneData.messages) ~= "table" then
        outputDebugString("Player "..getPlayerName(client).." sent invalid messages")
        return
    end

    -- Limit liczby kontaktów (zapobiega spamowaniu)
    if #phoneData.contacts > 11 then
        outputDebugString("Player "..getPlayerName(client).." sent too many contacts: "..#phoneData.contacts)
        return
    end

    -- Limit całkowitej liczby wiadomości
    local totalMessages = 0
    for _, contact in ipairs(phoneData.contacts) do
        if contact.messages then
            totalMessages = totalMessages + #contact.messages
        end
    end
    
    if totalMessages > 1000 then
        outputDebugString("Player "..getPlayerName(client).." sent too many messages: "..totalMessages)
        return
    end


    -- Jeśli wszystkie walidacje przeszły, zapisz dane
    itemData.var4 = phoneData
    local success = exports.rp_db:query_free("UPDATE items SET var4 = ? WHERE id = ?", toJSON(phoneData), isUsingPhone)
    
    if success then
        if phoneDatas[client] then
            phoneDatas[client] = phoneData
        end
        -- outputDebugString("Phone settings updated successfully for player "..getPlayerName(client))
    else
        outputDebugString("Failed to update phone settings in database for player "..getPlayerName(client))
    end
end

addEvent("onPlayerChangePhoneSettings", true)
addEventHandler("onPlayerChangePhoneSettings", root, onPlayerChangePhoneSettings)



gunShellTimer = setTimer ( deleteGunShells, 21600000, 0)

function addMessageToPhoneData(player, messageData)
	if not isElement(player) then return false end
	if not tempItems[player] then return false end

	local itemID = getUsedTypeItem(player, 17)
	if not itemID then return false end

	local itemData = tempItems[player][itemID]
	if not itemData then return false end

	local var4 = itemData.var4 or {}
	var4.settings = var4.settings or {}
	var4.settings[1] = var4.settings[1] or {}
	var4.settings[1].messages = var4.settings[1].messages or {}

	table.insert(var4.settings[1].messages, {
		number = messageData.number,
		message = messageData.message,
		timestamp = messageData.timestamp
	})

	-- Aktualizacja danych
	itemData.var4 = var4

	-- Zapis do bazy
	exports.rp_db:query_free("UPDATE items SET var4 = ? WHERE id = ?", toJSON(var4), itemID)
	return true
end

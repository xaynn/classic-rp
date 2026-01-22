local playerShopData = {}
local itemTable = { 
    [1] = { -- jedzenie i woda.
        {name = "Chleb", itemType = 1, itemCount = 1, var1 = 32, var2 = 1, var3 = 1, price = 100},
        {name = "Woda", itemType = 1, itemCount = 1, var1 = 5, var2 = 1, var3 = 1, price = 25},
        {name = "Cola", itemType = 1, itemCount = 1, var1 = 5, var2 = 1, var3 = 1, price = 25},
        {name = "Hamburger", itemType = 1, itemCount = 1, var1 = 32, var2 = 1, var3 = 1, price = 100},
	    {name = "Piwo", itemType = 1, itemCount = 1, var1 = 5, var2 = 2, var3 = 5, price = 25}

    },
    [2] = { -- narzedzia, telewizor, boomboxy itd
	    {name = "Kanister", itemType = 12, itemCount = 1, var1 = 1, var2 = 1, var3 = 1, price = 100},
        {name = "Wytrych", itemType = 15, itemCount = 1, var1 = 1, var2 = 1, var3 = 1, price = 100},
        -- {name = "Śrubokręt", itemType = 2, itemCount = 1, var1 = 30, var2 = "pro", var3 = 30},
        -- {name = "Klucz francuski", itemType = 2, itemCount = 1, var1 = 30, var2 = "pro", var3 = 30},
        -- {name = "Piła", itemType = 2, itemCount = 1, var1 = 30, var2 = "pro", var3 = 30},
        -- {name = "Telefon", itemType = 2, itemCount = 1, var1 = 30, var2 = "pro", var3 = 30},
		{name = "Telefon", itemType = 17, itemCount = 1, var1 = false, var2 = false, var3 = 200, var4 = {}, price = 100},

        {name = "Boombox", itemType = 9, itemCount = 1, var1 = 1, var2 = 1, var3 = 1, price = 1000}
    },
    [3] = {  -- sklep legalny
        {name = "Glock", itemType = 2, itemCount = 1, var1 = 22, var2 = "std", var3 = 30, price = 2000},
        {name = "Amunicja Glock (x30)", itemType = 4, itemCount = 1, var1 = 30, var2 = 22, var3 = 1, price = 100}
    },
    [4] = { -- sklep dla ZGP.
        {name = "Uzi v1", itemType = 2, itemCount = 1, var1 = 28, var2 = "poor", var3 = 30, price = 1000},
        {name = "Uzi v2", itemType = 2, itemCount = 1, var1 = 28, var2 = "std", var3 = 30, price = 1000},
        {name = "Uzi v3", itemType = 2, itemCount = 1, var1 = 28, var2 = "pro", var3 = 30, price = 1000},

        {name = "AK-47", itemType = 2, itemCount = 1, var1 = 30, var2 = "pro", var3 = 30, price = 1000},
        {name = "AKM", itemType = 2, itemCount = 1, var1 = 30, var2 = "poor", var3 = 30, price = 1000},
        {name = "M4", itemType = 2, itemCount = 1, var1 = 31, var2 = "pro", var3 = 30, price = 1000},
        {name = "HK416", itemType = 2, itemCount = 1, var1 = 31, var2 = "poor", var3 = 30, price = 1000},
        {name = "TEC9 v1", itemType = 2, itemCount = 1, var1 = 32, var2 = "poor", var3 = 30, price = 1000},
		{name = "TEC9 v2", itemType = 2, itemCount = 1, var1 = 32, var2 = "std", var3 = 30, price = 1000},
        {name = "TEC9 v3", itemType = 2, itemCount = 1, var1 = 32, var2 = "pro", var3 = 30, price = 1000},
        {name = "Shotgun v1", itemType = 2, itemCount = 1, var1 = 25, var2 = "poor", var3 = 30, price = 1000},
        {name = "Shotgun v2 ", itemType = 2, itemCount = 1, var1 = 25, var2 = "std", var3 = 30, price = 1000},
        {name = "Shotgun v3", itemType = 2, itemCount = 1, var1 = 25, var2 = "pro", var3 = 30, price = 1000},
        {name = "Combat Shotgun", itemType = 2, itemCount = 1, var1 = 25, var2 = "pro", var3 = 30, price = 1000},
        {name = "Deagle v1", itemType = 2, itemCount = 1, var1 = 24, var2 = "poor", var3 = 30, price = 1000},
		-- {name = "Deagle v2", itemType = 2, itemCount = 1, var1 = 24, var2 = "std", var3 = 30, price = 1000},
		{name = "Deagle v3", itemType = 2, itemCount = 1, var1 = 24, var2 = "pro", var3 = 30, price = 1000},
        {name = "Silenced v1", itemType = 2, itemCount = 1, var1 = 23, var2 = "poor", var3 = 30, price = 1000},
        {name = "Silenced v2", itemType = 2, itemCount = 1, var1 = 23, var2 = "std", var3 = 30, price = 1000},
        {name = "Silenced v3", itemType = 2, itemCount = 1, var1 = 23, var2 = "pro", var3 = 30, price = 1000},

        {name = "Kominiarka", itemType = 3, itemCount = 1, var1 = 16, var2 = 1, var3 = 1, price = 1000},
        {name = "Rękawiczki", itemType = 8, itemCount = 1, var1 = 16, var2 = 1, var3 = 1, price = 1000},
        {name = "Sterydy (x5)", itemType = 13, itemCount = 5, var1 = 16, var2 = 1, var3 = 1, price = 100},

        {name = "Amunicja Glock (x30)", itemType = 4, itemCount = 1, var1 = 30, var2 = 22, var3 = 1, price = 100},
        {name = "Amunicja M4 (x30)", itemType = 4, itemCount = 1, var1 = 30, var2 = 31, var3 = 1, price = 50},
        {name = "Amunicja Deagle (x30)", itemType = 4, itemCount = 1, var1 = 30, var2 = 24, var3 = 1, price = 50},
        {name = "Amunicja Silenced (x30)", itemType = 4, itemCount = 1, var1 = 30, var2 = 23, var3 = 1, price = 50},
        {name = "Amunicja TEC9 (x30)", itemType = 4, itemCount = 1, var1 = 30, var2 = 32, var3 = 1, price = 50},
        {name = "Amunicja Uzi (x30)", itemType = 4, itemCount = 1, var1 = 30, var2 = 28, var3 = 1, price = 50},
        {name = "Amunicja Combat Shotgun (x30)", itemType = 4, itemCount = 1, var1 = 30, var2 = 27, var3 = 1, price = 50},
        {name = "Amunicja AK-47 (x30)", itemType = 4, itemCount = 1, var1 = 30, var2 = 30, var3 = 1, price = 50},
    },
	[5] = { -- dla gangow
	
	    {name = "Glock", itemType = 2, itemCount = 1, var1 = 22, var2 = "std", var3 = 30, price = 500},
		{name = "Kominiarka", itemType = 3, itemCount = 1, var1 = 16, var2 = 1, var3 = 1, price = 1000},
	},
    [6] = {}, -- ciuchy zwykle GTA SA dla facetów.
    [7] = {},  -- ciuchy zwykle GTA SA dla kobiet.
	[8] = {}, -- customowe wszystkie
	
}

local customMaleSkins = {}
local customFemaleSkins = {}

local excludedSkins = {
    [25228] = true, [25227] = true, [25226] = true, [25225] = true, [25224] = true, [25223] = true,
    [25222] = true, [25221] = true, [25220] = true, [25219] = true, [25217] = true, [25216] = true,
    [25207] = true, [25206] = true, [25205] = true, [25204] = true, [25195] = true, [25194] = true,
    [25189] = true, [25170] = true, [25169] = true, [25168] = true, [25161] = true, [25160] = true,
    [25159] = true, [25158] = true, [25157] = true, [25150] = true, [25149] = true, [25134] = true,
    [25133] = true, [25117] = true, [25116] = true, [25114] = true, [25096] = true, [25083] = true,
    [25082] = true, [25081] = true, [25080] = true, [25079] = true, [25075] = true, [25074] = true,
    [25063] = true, [25062] = true, [25056] = true, [25046] = true, [25045] = true, [25043] = true,
    [25042] = true, [25039] = true, [25012] = true, [25011] = true, [25010] = true, [25009] = true, [25008] = true,
	[25007] = true, 
}

local disabledSkins = {
    [25001] = true, [25020] = true, [25025] = true, [25032] = true,
    [25044] = true, [25050] = true, [25051] = true, [25060] = true,
    [25072] = true, [25078] = true, [25084] = true, [25097] = true,
    [25098] = true, [25099] = true, [25100] = true, [25104] = true,
    [25105] = true, [25106] = true, [25107] = true, [25115] = true,
    [25128] = true, [25142] = true, [25162] = true, [25166] = true,
    [25183] = true, [25218] = true, [25229] = true, [25230] = true,
    [25239] = true, [25240] = true, [25244] = true, [25258] = true,
    [25259] = true, [25265] = true, [25262] = true, [25143] = true, [25144] = true, [25145] = true, 
}


local customMaleSkins = {}



for skinID = 25000, 25267 do
	if not disabledSkins[skinID] then
    if excludedSkins[skinID] then
        table.insert(customFemaleSkins, skinID)
    else
        table.insert(customMaleSkins, skinID)
    end
		end
end


-- for skinID = 25000, 25267 do 
	-- table.insert(customMaleSkins, skinID)
-- end

function skinIsPremium(skinID)
    local premium = false
    for k, v in ipairs(customFemaleSkins) do
        if tonumber(v) == tonumber(skinID) then
            premium = true
            break
        end
    end

    for k, v in ipairs(customMaleSkins) do
        if tonumber(v) == tonumber(skinID) then
            premium = true
            break
        end
    end
    return premium
    -- if excludedSkins[skinID] then return true else return false end
end

function insertSkins()
    local maleSkins = exports.rp_utils:returnMaleSkins()
    local femaleSkins = exports.rp_utils:returnFemaleSkins()
    
    for skinID, boolean in pairs(maleSkins) do
        table.insert(itemTable[6], skinID)
    end
    
    for skinID, boolean in pairs(femaleSkins) do
        table.insert(itemTable[7], skinID)
    end

    for k, v in ipairs(customMaleSkins) do
        table.insert(itemTable[6], v)
    end

    for k, v in ipairs(customFemaleSkins) do
        table.insert(itemTable[7], v)
    end
end
setTimer ( insertSkins, 10000, 1)
local markerColors = {[1] = {255, 255, 0}, [2] = {56, 235, 28}, [3] = {235, 201, 28}, [4] = {255, 0, 0}, [5] = {255, 0, 0}}
local createdShopMarkers = {}
local shopMarkers = createElement("shopMarkers")
local blipTable = {
[1] = 10,
[3] = 6,
[6] = 45,
[7] = 45,
[8] = 45,
}
function loadShops()
    local result = exports.rp_db:query("SELECT * FROM shops")
    if result then
        for k, v in pairs(result) do
			local color = markerColors[tonumber(v.shopType)] or {255, 255, 255}
            local marker = createMarker(v.x, v.y, v.z, "cylinder", 1.5, color[1], color[2], color[3], 0)
			local blipID = blipTable[tonumber(v.shopType)]
            createdShopMarkers[marker] = v
			if blipID then
				local blip = createBlip(v.x, v.y, v.z, blipID, 2, 255, 255, 255, 255, 0, 300)
				setElementDimension(blip, v.dimension)
				createdShopMarkers[marker].blip = blip
			end
            setElementParent(marker, shopMarkers)
            exports.rp_login:setObjectData(marker, "3DText", v.name)
			setElementDimension(marker, v.dimension)
			setElementInterior(marker, v.interior)
        end
    end
end



-- local function displayLoadedRes(res)
    -- if getResourceName(res) == "rp_login" then
		-- loadShops()
    -- end
-- end

-- addEventHandler("onResourceStart", root, displayLoadedRes)
setTimer ( loadShops, 15000, 1)


function enableShop(player, type, state)
	if state then
		if type == 4 or type == 5 then
			local perm = exports.rp_groups:hasPerm(player, "Shop"..type) 
			if not perm then return exports.rp_library:createBox(player,"Nie posiadasz uprawnień do tego sklepu.") end
		end
		playerShopData[player] = type 
		triggerClientEvent(player,"onPlayerOpenShop",player,itemTable[type], type)
	else
		playerShopData[player] = nil
		triggerClientEvent(player,"onPlayerOpenShop",player,false)
	end
end



function handleShopCommand(player, command, ...)

    local args = {...}
	
    if args[1] == "lista" then
	    if not exports.rp_admin:hasAdminPerm(player, "createShops") then return end

        outputChatBox("Lista sklepów:", player)
        for k, v in pairs(createdShopMarkers) do
            outputChatBox("ID: " .. v.id .. " Nazwa: " .. v.name, player)
        end
	elseif args[1] == "kup" then
		local marker = exports.rp_utils:getNearestElement(player, "marker", 2)
		local markerData = createdShopMarkers[marker]
		if not markerData then
			return
		end
		local playerGender = exports.rp_login:getPlayerGender(player)
		local markerShop = createdShopMarkers[marker].shopType
		if markerShop == 6 then
			if playerGender == "male" then
				enableShop(player, 6, true)
			else
				enableShop(player, 7, true)
			end
		end

		enableShop(player, markerShop, true)
    elseif args[1] == "stworz" then
    if not exports.rp_admin:hasAdminPerm(player, "createShops") then return end

        local name = args[2]
        local shopType = args[3]
        if not shopType then
            return exports.rp_library:createBox(player, "/sklep stworz [nazwa] [typ sklepu 1-5, 1(jedzenie i woda) 2(narzędzia) 3(legalna bron) 4(ZGP) 5(Gangi) 6(Ciuchy) 7(Ciuchy baby) 8(Customowe ciuchy)")
        end

        name = name:gsub("_", " ")

        local pX, pY, pZ = getElementPosition(player)
        local dim, int = getElementDimension(player), getElementInterior(player)
        pZ = pZ - 0.90

        local _, _, id = exports.rp_db:query("INSERT INTO shops SET name = ?, shopType = ?, x = ?, y = ?, z = ?, dimension = ?, interior = ?", name, shopType, pX, pY, pZ, dim, int)
        local tmpTable = {
            id = id,
            name = name,
            shopType = tonumber(shopType),
            x = pX,
            y = pY,
            z = pZ,
            dimension = dim,
            interior = int
        }
		local color = markerColors[tonumber(shopType)] or {255, 255, 255}
        local marker = createMarker(pX, pY, pZ, "cylinder", 1.5, color[1], color[2], color[3], 50)
        setElementDimension(marker, dim)
        setElementInterior(marker, int)
        createdShopMarkers[marker] = tmpTable
        setElementParent(marker, shopMarkers)
        exports.rp_login:setObjectData(marker, "3DText", name)
		local blipID = blipTable[tonumber(shopType)]
			if blipID then
				local blip = createBlip(pX, pY, pZ, blipID, 2, 255, 255, 255, 255, 0, 300)
				createdShopMarkers[marker].blip = blip
		end
	
    elseif args[1] == "usun" then
    if not exports.rp_admin:hasAdminPerm(player, "createShops") then return end

        local marker = exports.rp_utils:getNearestElement(player, "marker", 2)
        if marker then
            local data = createdShopMarkers[marker]
            exports.rp_db:query("DELETE FROM shops WHERE id = ?", data.id)
            destroyElement(marker)
			if isElement(createdShopMarkers[marker].blip) then destroyElement(createdShopMarkers[marker].blip) end
            createdShopMarkers[marker] = nil
            exports.rp_library:createBox(player, "Pomyślnie usunąłeś sklep.")
        end
	elseif args[1] == "tp" then
    if not exports.rp_admin:hasAdminPerm(player, "createShops") then return end

		local id = tonumber(args[2])
		if not id then return end
		local x, y, z, dim, int = findMarkerByID(id)
		if x then
			setElementDimension(player, dim)
			setElementInterior(player, int)
			setElementPosition(player, x+1, y, z + 0.9)
			else
			exports.rp_library:createBox(player,"Nie znaleziono sklepu o podanym ID")
		end
    else
        exports.rp_library:createBox(player,"Użycie: /sklep [lista/stworz/usun/kup]")
    end
end
addCommandHandler("sklep", handleShopCommand, false, false)

function findMarkerByID(id)
	for k,v in pairs(createdShopMarkers) do
		if id == v.id then
			return v.x, v.y, v.z, v.dimension, v.interior
		end
	end
	return false
end
function handlePlayerMarker(hitElement, matchinDimension)
	local elementType = getElementType(hitElement)
	if elementType ~= "player" then return end
	if matchinDimension then
		if not createdShopMarkers[source] then return end
		-- local shopData = createdShopMarkers[source].shopType
		-- enableShop(hitElement, shopData, true)

		bindKey ( hitElement, "E", "down", bindKeyShop, hitElement, source )
		exports.rp_library:createBox(hitElement,"Kliknij E aby otworzyć sklep.")
	end
	
end
addEventHandler("onMarkerHit", shopMarkers, handlePlayerMarker)


function onMarkerLeave(hitElement, matchinDimension)
	local elementType = getElementType(hitElement)
	if elementType ~= "player" then return end
	if matchinDimension then
		if not createdShopMarkers[source] then return end
		if isKeyBound(hitElement, "E", "down", bindKeyShop) then
		unbindKey ( hitElement, "E", "down", bindKeyShop )
		playerShopData[hitElement] = nil
		end
	end
end
addEventHandler("onMarkerLeave", shopMarkers, onMarkerLeave)
function bindKeyShop(player, key, keyState, _, marker)
		local markerData = createdShopMarkers[marker]
		if not markerData then
			return print("brak danych")
		end
		local playerGender = exports.rp_login:getPlayerGender(player)
		local markerShop = createdShopMarkers[marker].shopType
		if markerShop == 6 then
			if playerGender == "male" then
				enableShop(player, 6, true)
			else
				enableShop(player, 7, true)
			end
		end

	enableShop(player, markerShop, true)
	unbindKey ( player, "E", "down", bindKeyShop )
end



addEventHandler("onPlayerQuit", root,
	function(quitType)
		if playerShopData[source] then playerShopData[source] = nil end
	end
)

function onPlayerBuyItemsFromShop(items, shopType)
    if tonumber(items) then
        local bought = exports.rp_atm:takePlayerCustomMoney(client, 50)
        if not bought then 
            return exports.rp_library:createBox(client, "Nie posiadasz wystarczająco pieniędzy na zakup outfitu.") 
        end 
        return exports.rp_inventory:addItemToPlayer(client, "Ciuch - " .. tonumber(items), 11, 1, tonumber(items), 1, 1), exports.rp_library:createBox(client, "Zakupiłeś outfit.")
    end

    if not itemTable[shopType] then return end
    if playerShopData[client] ~= shopType then return end
    if next(items) == nil then return end

    local totalPrice = 0
    local purchasedItems = {}
    local groupedItems = {}

    for _, itemData in ipairs(items) do
        local itemName = itemData.itemName
        local foundItem = nil

        for _, item in ipairs(itemTable[shopType]) do
            if item.name == itemName then
                foundItem = item
                break
            end
        end

        if foundItem then
            totalPrice = totalPrice + (foundItem.price or 0)

            if foundItem.itemType ~= 2 then
                if not groupedItems[itemName] then
                    groupedItems[itemName] = {
                        name = foundItem.name,
                        itemType = foundItem.itemType,
                        itemCount = foundItem.itemCount or 1,
                        price = foundItem.price,
                        var1 = foundItem.var1,
                        var2 = foundItem.var2,
                        var3 = foundItem.var3
                    }
                else
                    groupedItems[itemName].itemCount = groupedItems[itemName].itemCount + (foundItem.itemCount or 1)
                end
            else
                table.insert(purchasedItems, foundItem)
            end
        else
            outputChatBox("Nie znaleziono przedmiotu: " .. itemName, client, 255, 0, 0)
            return
        end
    end

    local bought = exports.rp_atm:takePlayerCustomMoney(client, totalPrice)
    if not bought then 
        return exports.rp_library:createBox(client, "Nie stać Cię na zakup przedmiotów.") 
    end

    for _, item in pairs(groupedItems) do
        exports.rp_inventory:addItemToPlayer(client, item.name, item.itemType, item.itemCount, item.var1, item.var2, item.var3)
    end

    for _, item in ipairs(purchasedItems) do
        exports.rp_inventory:addItemToPlayer(client, item.name, item.itemType, item.itemCount, item.var1, item.var2, item.var3)
    end

    exports.rp_library:createBox(client, "Zakupiłeś przedmioty za " .. totalPrice .. " $")
    enableShop(client, false, false)
end

addEvent("onPlayerBuyItemsFromShop", true)
addEventHandler("onPlayerBuyItemsFromShop", getRootElement(), onPlayerBuyItemsFromShop)

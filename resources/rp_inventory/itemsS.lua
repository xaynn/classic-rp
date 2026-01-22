

local itemTable = {
["AK47"] = {itemType = 2, itemCount = 1, var1 = 30, var2 = "pro", var3 = 30},  -- var 1 bron, var 2 styl, var 3 ammo 
["AKM"] = {itemType = 2, itemCount = 1, var1 = 30, var2 = "poor", var3 = 30},
["M4"] = {itemType = 2, itemCount = 1, var1 = 31, var2 = "pro", var3 = 30},
["HK416"] = {itemType = 2, itemCount = 1, var1 = 31, var2 = "poor", var3 = 30},
["Stek"] = {itemType = 1, itemCount = 5, var1 = 32, var2 = 1, var3 = 1},
["Frytki"] = {itemType = 1, itemCount = 5, var1 = 16, var2 = 1, var3 = 1},
["Piwo"] = {itemType = 1, itemCount = 5, var1 = 5, var2 = 2, var3 = 5},
--{name = "Piwo", itemType = 1, itemCount = 1, var1 = 5, var2 = 2, var3 = 5, price = 25}
["TEC9"] = {itemType = 2, itemCount = 1, var1 = 32, var2 = "pro", var3 = 30},  -- var 1 bron, var 2 styl, var 3 ammo 
["MP5"] = {itemType = 2, itemCount = 1, var1 = 29, var2 = "pro", var3 = 30},  -- var 1 bron, var 2 styl, var 3 ammo 
["Uzi"] = {itemType = 2, itemCount = 1, var1 = 28, var2 = "pro", var3 = 30},  -- var 1 bron, var 2 styl, var 3 ammo 
["Combat Shotgun"] = {itemType = 2, itemCount = 1, var1 = 27, var2 = "pro", var3 = 30},  -- var 1 bron, var 2 styl, var 3 ammo 
["Shotgun"] = {itemType = 2, itemCount = 1, var1 = 25, var2 = "pro", var3 = 30},  -- var 1 bron, var 2 styl, var 3 ammo 
["Deagle"] = {itemType = 2, itemCount = 1, var1 = 24, var2 = "pro", var3 = 30},  -- var 1 bron, var 2 styl, var 3 ammo 
["Silenced"] = {itemType = 2, itemCount = 1, var1 = 23, var2 = "pro", var3 = 30},  -- var 1 bron, var 2 styl, var 3 ammo 
["Podwójny Glock"] = {itemType = 2, itemCount = 1, var1 = 22, var2 = "pro", var3 = 30},  -- var 1 bron, var 2 styl, var 3 ammo 
["Glock"] = {itemType = 2, itemCount = 1, var1 = 22, var2 = "std", var3 = 30},  -- var 1 bron, var 2 styl, var 3 ammo 
-- ["Low-Glock"] = {itemType = 2, itemCount = 1, var1 = 22, var2 = "poor", var3 = 30},  -- var 1 bron, var 2 styl, var 3 ammo 
["Rifle"] = {itemType = 2, itemCount = 1, var1 = 33, var2 = "pro", var3 = 30},  -- var 1 bron, var 2 styl, var 3 ammo 
["Sniper"] = {itemType = 2, itemCount = 1, var1 = 34, var2 = "pro", var3 = 30},  -- var 1 bron, var 2 styl, var 3 ammo 
["Kominiarka"] = {itemType = 3, itemCount = 1, var1 = 16, var2 = 1, var3 = 1}, -- 16 uzyc ma kominiarka.
["Magazynek M4"] = {itemType = 4, itemCount = 3, var1 = 32, var2 = 31, var3 = 1}, -- var 2 to allowed weapons, ktore moga uzyc tego magazynku, var1 to amunicja
["Magazynek AK47"] = {itemType = 4, itemCount = 3, var1 = 40, var2 = 30, var3 = 1},
["Magazynek Deagle"] = {itemType = 4, itemCount = 3, var1 = 40, var2 = 24, var3 = 1},
["Magazynek Silenced"] = {itemType = 4, itemCount = 3, var1 = 40, var2 = 23, var3 = 1},
["Magazynek Glock"] = {itemType = 4, itemCount = 3, var1 = 40, var2 = 22, var3 = 1},
["Magazynek TEC9"] = {itemType = 4, itemCount = 3, var1 = 40, var2 = 32, var3 = 1},
["Magazynek Uzi"] = {itemType = 4, itemCount = 3, var1 = 40, var2 = 28, var3 = 1},
["Magazynek MP5"] = {itemType = 4, itemCount = 3, var1 = 40, var2 = 29, var3 = 1},
["Magazynek Combat Shotgun"] = {itemType = 4, itemCount = 3, var1 = 40, var2 = 27, var3 = 1},
["Magazynek Sawed-off"] = {itemType = 4, itemCount = 3, var1 = 40, var2 =  26, var3 = 1},
["Magazynek Shotgun"] = {itemType = 4, itemCount = 3, var1 = 40, var2 = 25, var3 = 1},
["Magazynek Rifle"] = {itemType = 4, itemCount = 3, var1 = 40, var2 = 33, var3 = 1},
["Magazynek Sniper"] = {itemType = 4, itemCount = 3, var1 = 40, var2 = 34, var3 = 1},
["Kamizelka"] = {itemType = 5, itemCount = 1, var1 = 16, var2 = 1, var3 = 1},
["Boombox"] = {itemType = 9, itemCount = 1, var1 = 1, var2 = 1, var3 = 1},
["Rękawiczki"] = {itemType = 8, itemCount = 1, var1 = 16, var2 = 1, var3 = 1}, -- 16 uzyc 
["Marihuana"] = {itemType = 7, itemCount = 5, var1 = 1, var2 = 1, var3 = 1}, -- itemCount to liczba ile ma, var1 to typ, 1 to marihuana, 2 - haszysz, 3 - koks
["Haszysz"] = {itemType = 7, itemCount = 5, var1 = 2, var2 = 1, var3 = 1}, -- itemCount to liczba ile ma, var1 to typ, 1 to marihuana, 2 - haszysz, 3 - koks
["Kokaina"] = {itemType = 7, itemCount = 5, var1 = 3, var2 = 1, var3 = 1}, -- itemCount to liczba ile ma, var1 to typ, 1 to marihuana, 2 - haszysz, 3 - koks
["Spray"] = {itemType = 10, itemCount = 1, var1 = 41, var2 = 1, var3 = 200}, -- itemCount to liczba ile ma, var1 to typ, 1 to marihuana, 2 - haszysz, 3 - koks
["Taser"] = {itemType = 16, itemCount = 1, var1 = 23, var2 = "poor", var3 = 200}, 
["Telefon"] = {itemType = 17, itemCount = 1, var1 = false, var2 = false, var3 = 200, var4 = {}}, 
["Pałka"] = {itemType = 2, itemCount = 1, var1 = 3, var2 = "pro", var3 = 30},
["Nóż"] = {itemType = 2, itemCount = 1, var1 = 4, var2 = "pro", var3 = 30},
["Baseball"] = {itemType = 2, itemCount = 1, var1 = 5, var2 = "pro", var3 = 30},
["Łopata"] = {itemType = 2, itemCount = 1, var1 = 6, var2 = "pro", var3 = 30},
["Kamera"] = {itemType = 2, itemCount = 1, var1 = 43, var2 = "pro", var3 = 30},
["Ryba"] = {itemType = 20, itemCount = 1, var1 = 5, var2 = 1, var3 = 1},

}

-- 
-- addItemToPlayer(player, name, itemType, itemCount, var1, var2, var3)
function giveItem(player, itemName, itemCount)
	local string = tostring(itemName)
	addItemToPlayer(player, string, itemTable[string].itemType, itemCount, itemTable[string].var1, itemTable[string].var2, itemTable[string].var3)
end

function spawnItemCmd(player, cmand)
	if not exports.rp_admin:hasAdminPerm(player, "creatingItems") then return end
	triggerClientEvent(player,"onPlayerSpawnItems",player, itemTable)
end
addCommandHandler("spawnitems", spawnItemCmd, false, false)



function onPlayerSpawnItem(items)
    if not exports.rp_admin:hasAdminPerm(client, "creatingItems") then
        return exports.rp_anticheat:banPlayerAC(client, "Manipulate Event", "onPlayerSpawnItem")
    end
	local found = false
    for k, v in pairs(items) do -- nazwy do
        if itemTable[v] then
            addItemToPlayer(client,v,itemTable[v].itemType,itemTable[v].itemCount,itemTable[v].var1,itemTable[v].var2,itemTable[v].var3)
			found = true
        end
    end

    if found then exports.rp_library:createBox(client, "Stworzyłeś przedmioty.") end
end
addEvent("onPlayerSpawnItem", true)
addEventHandler("onPlayerSpawnItem", getRootElement(), onPlayerSpawnItem)

function boomboxLink(player, cmand, url)
	local loggedIn = exports.rp_login:getPlayerData(player,"characterID")
	if not loggedIn then return end
	if not url then return exports.rp_library:createBox(player,"/boombox link") end
	if string.len(url) < 4 then return exports.rp_library:createBox(player, "/boombox link") end -- lub zrobic tylko wskazane radiostacje.. zabijamy tym mozliwosc wybierania czego gracz dokladnie chce sluchac, ale przy tym nikt nie wyciagnie IP.
	exports.rp_login:setPlayerData(player, "boomboxUrl", url, true)
	exports.rp_library:createBox(player, "Ustawiłeś link do boomboxa.") 
end
addCommandHandler("boombox", boomboxLink, false, false)

-- iprint(itemTable["AK47"])
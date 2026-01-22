local createdATMS = {}
local createdATMSID = {}
local isPlayerUsingATM = {}
function giveToPlayerMoney(player, target, amount)
    if not exports.rp_login:isLoggedPlayer(player) or not exports.rp_login:isLoggedPlayer(target) then
        return
    end
    local amount = tonumber(amount)
    local moneyPlayer = exports.rp_login:getPlayerData(player, "money")
    if moneyPlayer < amount then
        return exports.rp_library:createBox(player, "Nie posiadasz wystarczającej liczby pieniędzy.")
    end
    if amount < 1 then
        return
    end
    local targetMoneyPlayer = exports.rp_login:getPlayerData(target, "money")
    exports.rp_login:setPlayerData(player, "money", moneyPlayer - amount)
    exports.rp_login:setPlayerData(target, "money", targetMoneyPlayer + amount)
	local targetName = exports.rp_utils:getPlayerICName(target)
	
	local finalText
	local sex = exports.rp_login:getPlayerGender(player)
	if sex == "male" then
	finalText = "podał pieniądze do"
	else
	finalText = "podała pieniądze do"
	end
	
	exports.rp_chat:meCommand(player,nil,finalText.." "..targetName )
    exports.rp_nicknames:amePlayer(player,finalText .. " " .. targetName)
    return true
end

function takePlayerCustomMoney(player, amount, donttakefromBank)
    if not exports.rp_login:isLoggedPlayer(player) then
        return
    end
    local money = exports.rp_login:getPlayerData(player, "money")
    if money < amount then
		-- try to take from bankAccount.
		if donttakefromBank then return false end
		local buyFromBankMoney = takeBankMoney(player, amount)
		if buyFromBankMoney then return "bank" else return false end
    end
    exports.rp_login:setPlayerData(player, "money", money - amount)
    return true
end

function takeBankMoney(player, amount)
    local bankMoney = exports.rp_login:getCharDataFromTable(player, "bankmoney")
    if bankMoney < amount then
        return false
    end
	exports.rp_login:changeCharData(player,"bankmoney", bankMoney - amount)
    return true
end

function givePlayerCustomMoney(player, amount)
    if not exports.rp_login:isLoggedPlayer(player) then
        return
    end
    local money = exports.rp_login:getPlayerData(player, "money")

    exports.rp_login:setPlayerData(player, "money", money + amount)
end

function giveBankMoney(player, amount)
    local bankMoney = exports.rp_login:getCharDataFromTable(player, "bankmoney")
	-- iprint("giveBankMoney - >".. bankMoney..": "..amount)
	exports.rp_login:changeCharData(player,"bankmoney", bankMoney + amount)
end

function cmdATM(player)
    if getNearbyATM(player) then
        triggerClientEvent(player, "onATMShowed", player)
    end
end

addCommandHandler("atm", cmdATM, false, false)
addCommandHandler("bank", cmdATM, false, false)
addCommandHandler("bankomat", cmdATM, false, false)

function loadATMS()
    local result = exports.rp_db:query("SELECT * FROM atms")
    if result then
        for k, v in pairs(result) do
		local obj = createObject(2942, v.x, v.y, v.z)
		setElementRotation(obj, 0,0,v.r)
		setElementDimension(obj, v.dimension)
		setElementInterior(obj, v.interior)
		createdATMS[obj] = v.id
		createdATMSID[v.id] = obj
        end
    end
end



function createATM(player)
    if exports.rp_admin:hasAdminPerm(player, "creatingAtms") then
        local pX, pY, pZ = getElementPosition(player)
        local r, o, t = getElementRotation(player)
		local dim, int = getElementDimension(player), getElementInterior(player)
        pZ = pZ - 0.35
        local _, _, id = exports.rp_db:query("INSERT INTO atms SET x = ?, y = ?, z = ?, r = ?, dimension = ?, interior = ?", pX, pY, pZ, t, dim, int)
        local obj = createObject(2942, pX, pY, pZ, r)
        setElementRotation(obj, 0, 0, t)
		setElementDimension(obj, dim)
		setElementInterior(obj, int)
		createdATMS[obj] = id
		createdATMSID[id] = obj

    end
end
addCommandHandler("createatm", createATM, false, false)
addCommandHandler("catm", createATM, false, false)



function deleteATM(player, cmand)
    if exports.rp_admin:hasAdminPerm(player, "creatingAtms") then
        local object, objectID = getNearbyATMAdmin(player)
        if object and objectID then
            exports.rp_db:query("DELETE FROM atms WHERE id = ?", objectID)
            destroyElement(object)
			exports.rp_library:createBox(player,"Pomyślnie usunąłeś bankomat.")
        end
    end
end
addCommandHandler("deleteatm", deleteATM, false, false)
addCommandHandler("delatm", deleteATM, false, false)

function listATMS(player, cmand)
    if not exports.rp_admin:hasAdminPerm(player, "creatingAtms") then
        return
    end

    local tmpTable = {}
    for k, v in pairs(createdATMS) do
        -- outputChatBox("ATM: " .. v, player, 231, 217, 176, false)
        table.insert(tmpTable, v)
    end
    --trigger do wyswietlenia wszystkich bankomatow + przycisk TP do bankomatu.
    triggerClientEvent(player, "onPlayerGotATMSList", player, tmpTable)
end
addCommandHandler("atmlist", listATMS, false, false)

function teleportToATM(id)
    if not exports.rp_admin:hasAdminPerm(client, "creatingAtms") then
        return exports.rp_anticheat:banPlayerAC(client,"Manipulate Event", "onPlayerTryToTpATM")
    end
	local atm = createdATMSID[id]
	if not isElement(atm) then return exports.rp_library:createBox(client,"Ten bankomat nie istnieje.") end
	local x,y,z = getElementPosition(atm)
	local dim, int = getElementDimension(atm), getElementInterior(atm)
	setElementPosition(client, x,y,z+1)
	setElementDimension(client, dim)
	setElementInterior(client, int)
	exports.rp_library:createBox(client,"Przeteleportowałeś się do bankomatu, aby go usunąć wpisz komendę /delatm lub postaw na nowo /catm.")
end
addEvent("onPlayerTryToTpATM", true)
addEventHandler("onPlayerTryToTpATM", getRootElement(), teleportToATM)


function getNearbyATM(player)
	local x,y,z = getElementPosition(player)
	local sphere = createColSphere(x,y,z, 2.0)
	local objects = getElementsWithinColShape(sphere, "object")
	destroyElement(sphere)
	for k, v in ipairs(objects) do
		if getElementModel(v) == 2942 then return true end
	end
	return false
end

function getNearbyATMAdmin(player)
	local x,y,z = getElementPosition(player)
	local sphere = createColSphere(x,y,z, 2.0)
	local objects = getElementsWithinColShape(sphere, "object")
	destroyElement(sphere)
	for k, v in ipairs(objects) do
		if getElementModel(v) == 2942 and createdATMS[v] then return v, createdATMS[v] end
	end
	return false
end


function atmEvent(mode, amount)
	-- if not isPlayerUsingATM[client] then return end
	if not getNearbyATM(client) then return end
	if not exports.rp_utils:checkPassiveTimer("atm", client, 1000) then return exports.rp_library:createBox(client,"Poczekaj chwilę przed następnym kliknięciem.") end
    local amount = tonumber(amount)
	-- iprint("amount server: "..amount)
    if not tonumber(amount) then
        return --print("nie jest to liczba serwer")
    end
    if amount < 1 then
        return --print("amount mniejsze od 1 serwer")
    end
    if mode == "withdraw" then
        local bankMoney = exports.rp_login:getCharDataFromTable(client, "bankmoney")
        if bankMoney < amount then
            return exports.rp_library:createBox(client, "Nie posiadasz tylu pieniędzy w banku.")
        end
		takeBankMoney(client, amount)
		givePlayerCustomMoney(client,amount)
		exports.rp_library:createBox(client, "Wypłaciłeś pieniądze z konta bankowego")
		triggerClientEvent(client,"onPlayerUpdatedBankMoney", client, exports.rp_login:getCharDataFromTable(client, "bankmoney"))
    elseif mode == "donate" then
        local playerMoneyInCash = exports.rp_login:getPlayerData(client, "money")
        if playerMoneyInCash < amount then
            return exports.rp_library:createBox(client, "Nie posiadasz tylu pieniędzy, aby wpłacić kasę na konto")
        end
		takePlayerCustomMoney(client, amount)
		giveBankMoney(client, amount)
		exports.rp_library:createBox(client, "Wpłaciłeś pieniądze na konto bankowe")
		triggerClientEvent(client,"onPlayerUpdatedBankMoney", client, exports.rp_login:getCharDataFromTable(client, "bankmoney"))

    end
end


addEvent("onPlayerUsingATM", true)
addEventHandler("onPlayerUsingATM", getRootElement(), atmEvent)

loadATMS()
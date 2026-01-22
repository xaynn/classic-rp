

-- logowanie na serwer przez serwer discord, oauth
-- 
-- kolor podstawowy #2168c4 do labelow, przyciskow, --#3bd39c to tez do przyciskow mozna ale rzadko 
local loggedPlayers = {} --userdata, lub id moze?
local playersData = {}
local ids = {}
local tabPlayers = {}
local elementsData = {}
local playTimeTimer = {}
local logoutTime = {}
local playerRegisterDiscordID = {}



--statistics, to tablica tak samo items, statistics {hp, armor, x, y, z, int, dim}
function isLoggedPlayer(player)
    if loggedPlayers[player] and loggedPlayers[player][3] then
        return true, loggedPlayers[player][1], loggedPlayers[player][2], loggedPlayers[player][3] or false, loggedPlayers[player][4] or false -- logged, accountID, playState, characterID, discordID
    end
    return false
end

function getLoggedPlayers()
	return loggedPlayers
end
function isLoggedAccount(guid)
    for k, v in pairs(loggedPlayers) do
        if v[1] == guid then
            return true
        end
    end
	return false
end

function getPlayerState(player)
	if not loggedPlayers[player] then return end
    	return loggedPlayers[player][2] -- playState
end

function setPlayerState(player, state)
	if not loggedPlayers[player] then return false end
    loggedPlayers[player][2] = state -- "logging"
	-- print("Zmiana playerState na "..state)
end

function setPlayerData(player, data, nowData, disabledSync)
    if not playersData[player] then
        playersData[player] = {}
    end

    playersData[player][data] = nowData ~= false and nowData or false
    -- iprint("[Player Data] setting data for " .. getPlayerName(player) .. " [" .. data .. "] " .. "[" .. nowData .. "] [SYNC]")
    if not disabledSync then
        -- iprint("[Player Data] setting data for " .. getPlayerName(player) .. " [" .. data .. "] " .. "[" .. nowData .. "] [SYNCED]")
		-- iprint("Player Data Set "..data.." "..inspect(nowData))
        -- triggerClientEvent(root, "onLocalDataPlayerChange", root, player, nil, data, nowData)
		-- print("ustawiono dla "..getPlayerName(player) or "ped".. " DATE: "..data)
		        triggerClientEvent(root, "onLocalDataPlayerChange", getRootElement(), player, data, nowData)

    end
end

function setObjectData(element, key, value)
    -- onLocalDataSingleElementUpdate
    if not elementsData[element] then
        elementsData[element] = {}
    end
    -- elementsData[element][data] = nowData
	elementsData[element][key] = value ~= false and value or false
    -- iprint(element,data,nowData)
    triggerClientEvent(root, "onLocalDataSingleElementUpdate", getRootElement(), element, key, value)
end

function getObjectData(element, data)
	-- iprint(element, data)
	if isElement(element) and elementsData[element] then
 	return elementsData[element][data] or false
	end
end

function getPlayerData(player, data)
    if isElement(player) and playersData[player] then
        return playersData[player][data] or false
    end
end


function findPlayerByID(id)
    for k, v in pairs(loggedPlayers) do
        if getPlayerData(k,"playerID") == tonumber(id) then
            if isElement(k) then
                return k, getPlayerName(k) --  zwrot userdata, nazwa gracza.
            end
        end
    end
    return false
end



function isValidDiscordID(discordID)
    if type(discordID) ~= "string" or #discordID ~= 18 or not discordID:match("^%d+$") then
        return false
    end
    

    local idNumber = tonumber(discordID)
    if not idNumber then
        return false
    end
    
    if idNumber <= 0 then
        return false
    end
    
    local discordEpoch = 1420070400000 
    local timestamp = math.floor(idNumber / 2^22) + discordEpoch
    local currentTime = os.time() * 1000 
    
    if timestamp < discordEpoch or timestamp > currentTime then
        return false
    end
    
    return true
end


function verifyPlayer(player, code, username, password, secondpassword, serial, banHash)
	if not exports.rp_utils:checkPassiveTimer("verifyCode", player, 300) then return end
	if not code or code == "" then return exports.rp_library:createBox(player,"Podaj kod.") end
    local url = "http://127.0.0.1:3000/verify-code"
    local jsonData = toJSON({ code = code }):sub(2, -2)

    fetchRemote(url, {
        method = "POST",
        headers = { ["Content-Type"] = "application/json" },
        postData = jsonData
    }, function(responseData, error)

        local data = fromJSON(responseData)
        if data and data.success and data.username then
			exports.rp_library:createBox(player, "✅ Zweryfikowano! Witaj, " .. data.username .. "!.")
			playerRegisterDiscordID[player] = tostring(data.discordID)
			registerPlayer(player, username, password, secondpassword, serial, playerRegisterDiscordID[player], banHash)
			return data.discordID
        else
			return false
        end
    end)
end

-- addCommandHandler("verify", verifyPlayer)







function onTryToLogin(username, password, secondpassword, loginState, discordID, banHash, verifyCode)
    -- if not discordID or discordID == "" or not isValidDiscordID(discordID) then
        -- return
    -- end
	local client = client
    local playerState = getPlayerState(client)
    if playerState == "logged" then
        return exports.rp_anticheat:banPlayerAC(client, "Manipulate Event", "onPlayerTryToLogin")
    end
    if loginState == "login" then
        authPlayer(client, username, password, discordID, banHash)
    elseif loginState == "register" then
		-- if not playerRegisterDiscordID[client] then return exports.rp_library:createBox(client,"Aby się zarejestrować, musisz podać kod z discorda, który znajdziesz na serwerze discord pod komendą /verify.") end
		if not verifyCode then return exports.rp_library:createBox(client,"Nie podałeś kodu weryfikacyjnego.") end
		local verified = verifyPlayer(client, verifyCode, username, password, secondpassword, getPlayerSerial(client), banHash) -- tutaj wjebac register
		-- if not verified then return exports.rp_library:createBox(client,"Kod weryfikacyjny nie zgadza się") end
		
		-- setTimer ( function()
		    -- registerPlayer(client, username, password, secondpassword, getPlayerSerial(client), playerRegisterDiscordID[client], banHash) --dodac banhash
		-- end, 1000, 1 )
    end
end
addEvent("onPlayerTryToLogin", true)
addEventHandler("onPlayerTryToLogin", getRootElement(), onTryToLogin)


function authPlayer(player, username, password, discordID, banHash)
    local accountData =
        exports.rp_db:query(
        "SELECT id, username, password, experience, adminlevel, serial, registerDate, ip, ban_reason, ban_timestamp, discordID, premium_timestamp FROM users WHERE username=? LIMIT 1",
        username
    )

    if not accountData or not accountData[1] then
        return exports.rp_library:createBox(player, "Brak konta o podanym loginie.")
    end
    if banHash then -- jest na podstawie serialu i IP, zacryptowany do clienta.
        --uncrypt banHash.
        local banHashID = exports.rp_admin:uncryptBan(banHash) -- jezeli nie moze odcryptowac kluczem, to znaczy ze ktos probuje to zespoofowac.
        -- iprint(banHashID)
        if banHashID then
            local parts = split(banHashID, ":")
            local serialValid = tostring(getPlayerSerial(player)) == tostring(parts[1]) -- dodac tablice, zbanowanych seriali parts[1], czyli jezeli jest w tablicy po serwerze parts[1] zbanowany, to ma checkowac.
            local legit = false
            if serialValid then
                legit = true
            end
            if legit then
            else
                exports.rp_anticheat:banPlayerAC(player,"SpoofBlacklist","Tried to use spoofer: " .. table.concat(parts, ", ") .. " ban evade: " .. getPlayerSerial(player))
                return
            end
        else
            exports.rp_anticheat:banPlayerAC(player,"SpoofBlacklist","Tried to use spoofer, but blacklist has invalid data.")
            return
        end
    end
    local data = accountData[1]
    local guid, hash, accountSerial, accountIP, adminLevel, discordDB = tonumber(data.id),data.password,tostring(data.serial),data.ip,tonumber(data.adminlevel),data.discordID
    local playerSerial, playerIP = getPlayerSerial(player), getPlayerIP(player)
    local accSerial = accountSerial .. ":" .. accountIP
    local playerConvertedSerial = playerSerial .. ":" .. playerIP
    -- print(accSerial, playerConvertedSerial, discordID, discordDB)
    if accSerial ~= playerConvertedSerial then -- or discordID ~= discordDB then
        return exports.rp_library:createBox(player, "Seriale konta się nie zgadzają lub konto discord.")
    end

    if not passwordVerify(password, hash) then
        return exports.rp_library:createBox(player, "Nieprawidłowe hasło.")
    end

    if isLoggedAccount(guid) then
        return exports.rp_library:createBox(player, "Jest już zalogowane te konto.")
    end

    local currentTimestamp, banTimestamp = getRealTime().timestamp, tonumber(data.ban_timestamp)
    if currentTimestamp < banTimestamp then
        local banReason = data.ban_reason
        local banDate = exports.rp_utils:getDate(banTimestamp)
        return exports.rp_library:createBox(player, "Konto posiada bana do " .. banDate .. " Powód bana: " .. banReason)
    end


    local characters = exports.rp_db:query("SELECT * FROM characters WHERE account_id = ? AND CK = 0", guid)

    triggerClientEvent(player, "onCharacterPanelShow", player, characters)
    generateTempID(player, guid)
    exports.rp_library:createBox(player, "Pomyślnie zalogowano.")
    exports.rp_admin:loadAdminPerms(player, guid)
    setPlayerName(player, data.username)
	local premiumTimestamp = tonumber(data.premium_timestamp)
	if currentTimestamp < premiumTimestamp then
	    local premiumDate = exports.rp_utils:getDate(premiumTimestamp)
		exports.rp_library:createBox(player, "Posiadasz konto premium do "..premiumDate..".")
		setPlayerData(player, "premium", true)
	end
    if adminLevel > 0 then
        setPlayerData(player, "adminlevel", adminLevel, true)
    end
end





function generateTempID(player, accountID)
	local slot = nil
	-- print("wygenerowano tempID")
	for i = 1, 1024 do
		if (ids[i]==nil) then
			slot = i
			break
		end
	end
	
	ids[slot] = player 
	setPlayerData(player, "playerID", slot)
	loggedPlayers[player] = {accountID, "logging"}
end


function registerPlayer(player, username, password, secondpassword, serial, discordID)
    if password ~= secondpassword then return exports.rp_library:createBox(player, "Nie zgadzają się podane hasła.") end
	
    -- local accountCheck = exports.rp_db:query(
        -- "SELECT username FROM users WHERE serial = ? OR discordID = ? OR username = ? LIMIT 1",
        -- serial, discordID, username
    -- )
    local accountCheck = exports.rp_db:query(
        "SELECT username FROM users WHERE serial = ? OR username = ? LIMIT 1",
        serial, username
    )

    if accountCheck and accountCheck[1] then
        if accountCheck[1].username == username then
            return exports.rp_library:createBox(player, "Konto o podanym loginie już istnieje.")
        else
            return exports.rp_library:createBox(player, "Posiadasz już konto: " .. accountCheck[1].username .. ", zaloguj się na nie.")
        end
    end

    local hashedPassword = passwordHash(password, "bcrypt", {})
	if not hashedPassword then return exports.rp_library:createBox(player, "Błąd w tworzeniu hasła.") end
    local query = exports.rp_db:query(
        "INSERT INTO users (username, password, experience, adminlevel, registerDate, serial, ip, discordID) VALUES (?, ?, ?, ?, ?, ?, ?, ?)",
        username, hashedPassword, 0, 0, getTimestamp(), serial, getPlayerIP(player), discordID
    )
	playerRegisterDiscordID[player] = nil
    if query then
        exports.rp_library:createBox(player, "Pomyślnie stworzyłeś konto.")
        return true
    end

    return false
end



addEventHandler(
    "onPlayerQuit",
    root,
    function(quitType)
        local source = source
        local logged, _, _, characterID = isLoggedPlayer(source)
        if logged and characterID then
            if exports.rp_inventory:hasPlayerSetupEQ(source) then
                exports.rp_inventory:updatePlayerItemsInDatabase(source, characterID)
            end

            local loginTime = getPlayerData(source, "loginTime")
            local playtime = getPlayerData(source, "playtime")

            if loginTime and playtime then
                local sessionTime = os.time() - loginTime
                local totalPlaytime = playtime + sessionTime

                setPlayerData(source, "playtime", totalPlaytime, true)
            end
            logoutTime[characterID] = getTickCount()
            if isTimer(playTimeTimer[source]) then
                killTimer(playTimeTimer[source])
                playTimeTimer[source] = nil
            end
        end
        if loggedPlayers[source] then
            loggedPlayers[source] = nil
        end
        destroyPlayerData(source)
        destroyTabPlayer(source)
    end
)



	
	
function onPlayerJoin()
	spawnPlayer(source,0,0,0,0,0,0,0)
    setElementPosition(source, 1, 1, 1)
    setElementDimension(source, math.random(1, 800))
	setElementFrozen(source, true)
	exports.rp_anticheat:allowPlayerWeapon(source, 0)
	fadeCamera(source, true)
	-- setCameraTarget(source)

end
addEventHandler("onPlayerJoin", root, onPlayerJoin)

function getPlayerGender(player)
	local gender = getPlayerData(player,"gender")
	if gender == 0 then gender = "male" else gender = "female" end
	return gender
end
-- jedyna edata dla gracza to MONEY aktywna, reszta bedzie przez getCharDataFromTable(player,data) changeCharData(player, data)
function onPlayerSelectedCharacter(charData)
    if not loggedPlayers[client] or getPlayerState(client) ~= "logging" then return end

    if not charData.account_id or tonumber(charData.account_id) ~= tonumber(loggedPlayers[client][1]) then
        return print("Invalid account ID."), exports.rp_anticheat:banPlayerAC(client, "Manipulate Event", "onPlayerSelectedCharacter")
    end

    local chars = exports.rp_db:query("SELECT * FROM characters WHERE id=?", charData.id)
    if not chars or not chars[1] then return end
    
    local char = chars[1]
    local stats = fromJSON(char.statistics)

    setPlayerData(client, "gender", char.sex, true)
    setPlayerData(client, "name", char.name, true)
    setPlayerData(client, "surname", char.surname, true)
    setPlayerData(client, "visibleName", char.name .. " " .. char.surname)
    setPlayerData(client, "statistics", stats, true)
    setPlayerData(client, "characterID", char.id)
    setPlayerData(client, "loginTime", os.time(), true)
    setPlayerData(client, "playtime", tonumber(char.playtime) or 0, true)

    playTimeTimer[client] = setTimer(checkPlayerCharTime, 60000, 0, client)

    local x, y, z = stats.x or 1483.95544, stats.y or -1740.17810, stats.z or 13.54688
    local dim, int, skin = stats.dim or 0, stats.int or 0, stats.skin or 0
    local walkingStyle, bwtime, money = stats.walkingStyle or 118, stats.bwtime or 0, stats.money or 300
    local jailtime, strength, fitness = stats.jailtime or 0, stats.strength or 0, stats.fitness or 0

    exports.rp_newmodels:spawnPlayer(client, x, y, z, 0, skin, int, dim)
    setPlayerData(client, "money", money)
    setElementHealth(client, math.max(tonumber(stats.hp) or 100, 1))
    setPedWalkingStyle(client, walkingStyle)
    
    fadeCamera(client, true, 2, 0, 0, 0)
    setElementFrozen(client, false)
    showCursor(client, false)
    setCameraTarget(client, client)
    setPlayerBlurLevel(client, 0)

    local logoutTimePassed = logoutTime[char.id] and (getTickCount() - logoutTime[char.id] > 15 * 60 * 1000)
    if logoutTimePassed then
        setElementDimension(client, 0)
        setElementInterior(client, 0)
        setElementPosition(client, 1483.95544, -1740.17810, 13.54688) -- spawn domyślny
    else
        setElementPosition(client, x, y, z) -- ostatnia pozycja
    end

    if tonumber(getRealTime().timestamp) < tonumber(jailtime) then
        exports.rp_library:createBox(client, "Twoja postać jest w więzieniu do: " .. exports.rp_utils:getDate(jailtime))
        setElementPosition(client, 263.7471, 78.0732, 1001.0391)
        setElementInterior(client, 6)
    end

    setPlayerState(client, "logged")
	addTabPlayer(client, exports.rp_utils:getPlayerICName(client), getPlayerData(client,"premium"), getPlayerData(client,"playerID"))
    triggerClientEvent(root, "updateTabData", getRootElement(), tabPlayers)
    
    loggedPlayers[client][3] = char.id
    outputChatBox("Witaj, #870101" .. getPlayerName(client) .. "#07677d (GUID: " .. loggedPlayers[client][1] .. ", CID: " .. char.id .. ") #ffffffMiłej gry życzy ekipa #173f8bClassic RolePlay#ffffff!", client, 255, 255, 255, true)
    triggerClientEvent(client, "onPlayerLoadedDashboardSettings", client, exports.rp_utils:getPlayerICName(client))

    exports.rp_groups:getPlayerGroups(client)
    if bwtime > 0 then
        exports.rp_bw:setPlayerBW(client, bwtime)
    end
    if strength >= 90 then
        exports.rp_nicknames:setPlayerStatus(client, "muskularny", true)
    elseif strength >= 50 then
        exports.rp_nicknames:setPlayerStatus(client, "wysportowany", true)
    end
	local calc = 100 + math.floor(strength)
	setPedMaxHealth(client, calc)
	-- wyjecie telefonu.
	exports.rp_inventory:useItem(client, 17)
end

addEvent("onPlayerSelectedCharacter", true)
addEventHandler("onPlayerSelectedCharacter", getRootElement(), onPlayerSelectedCharacter)




function checkPlayerCharTime(player) 
    local loginTime = getPlayerData(player, "loginTime")
    local playtime = getPlayerData(player, "playtime")

    if loginTime and playtime then
        local currentTime = os.time()
        local sessionTime = currentTime - loginTime

        local oldTotalPlaytime = playtime
        local newTotalPlaytime = playtime + sessionTime

        setPlayerData(player, "playtime", newTotalPlaytime, true)
        setPlayerData(player, "loginTime", currentTime, true)

        -- Sprawdzenie, czy gracz przekroczył pełną godzinę gry
        local oldHours = math.floor(oldTotalPlaytime / 3600)
        local newHours = math.floor(newTotalPlaytime / 3600)

        if newHours > oldHours then
            exports.rp_library:createBox(player, "Otrzymałeś cogodzinny zasiłek w wysokości 500$.")
            exports.rp_atm:givePlayerCustomMoney(player, 500)
        end
    end 
end


function validateNameAndSurname(name, surname)
	local pattern = "^[A-Z][a-z]*$" 

    if not string.match(name, pattern) or not string.match(surname, pattern) then
        return false
    end

    return true
end
local validCreateVehicles = {[439] = true, [410] = true, [549] = true, [491] = true, [529] = true, [462] = true, [478] = true}
function onPlayerCreateCharacter(name, surname, age, sex, skin, weight, height, skinColor, vehicleID)
    if not loggedPlayers[client] or not client then return end
	if not validCreateVehicles[tonumber(vehicleID)] then return end
	-- iprint(vehicleID..": creating!")
    if #name < 4 or #surname < 4 or #name > 16 or #surname > 16 then return end

    if sex ~= 0 and sex ~= 1 then return end

    age, weight, height = tonumber(age), tonumber(weight), tonumber(height)
    if not age or age < 16 or age > 80 then return end
    if not weight or weight < 30 or weight > 150 then return end
    if not height or height < 150 or height > 200 then return end

    if not validateNameAndSurname(name, surname) then
        return exports.rp_library:createBox(client, "Imię i nazwisko zawierają niedozwolone znaki, przykład poprawnych danych: Andrew John.")
    end

    if getPlayerState(client) ~= "logging" then
        return exports.rp_anticheat:banPlayerAC(client, "Manipulate Event", "onPlayerCreateCharacter")
    end

    local existingCharacter = exports.rp_db:query("SELECT 1 FROM characters WHERE name=? AND surname=? LIMIT 1", name, surname)
    if existingCharacter and #existingCharacter > 0 then
        return exports.rp_library:createBox(client, "Postać o podanych danych istnieje.")
    end

    local accountID = loggedPlayers[client][1]
    local characters = exports.rp_db:query("SELECT playtime FROM characters WHERE account_id = ? AND CK = 0", accountID)
    if characters then
        for _, char in ipairs(characters) do
            if char.playtime < 10800 then
                return exports.rp_library:createBox(client, "Posiadasz postacie, które nie mają 3h, dobij godziny na postaciach.")
            end
        end

        local characterData = toJSON({
            hp = 100, x = 1483.95544, y = -1740.17810, z = 13.54688,
            int = 0, dim = 0, money = 300, bankmoney = 1000, skin = skin,
            walkingStyle = 118, bwtime = 0, fightstyles = {}, strength = 0,
            fitness = 0, parttimejob = 0, licenses = {}, jailtime = 0,
            weight = weight, height = height, skinColor = skinColor
        })

        local insertQuery, _, id = exports.rp_db:query(
            "INSERT INTO characters (account_id, name, surname, age, sex, statistics) VALUES (?, ?, ?, ?, ?, ?)",
            accountID, name, surname, age, sex, characterData
        )

        if insertQuery then
			-- local xd = exports.rp_vehicles:createVeh(client, id, tonumber(vehicleID), 1, true)
			 exports.rp_vehicles:createVeh(client, id, tonumber(vehicleID), 1, true)
            local updatedCharacters = exports.rp_db:query("SELECT * FROM characters WHERE account_id = ? AND CK = 0", accountID)
            triggerClientEvent(client, "onCharacterCreated", client, updatedCharacters)
        end
    end
end

addEvent("onPlayerCreateCharacter", true)
addEventHandler("onPlayerCreateCharacter", root, onPlayerCreateCharacter)





function savePlayer(player)
    local charID = getPlayerData(player, "characterID")
    if not charID then return end

    local statsPlayer = getPlayerData(player, "statistics")
    local x, y, z = getElementPosition(player)
    local int, dim = getElementInterior(player), getElementDimension(player)

    -- Pobranie statystyk postaci w jednej operacji
    local stats = {
        bankmoney = getCharData(statsPlayer, "bankmoney"),
        bwtime = getCharData(statsPlayer, "bwtime") or 0,
        fightstyles = getCharData(statsPlayer, "fightstyles"),
        strength = getCharData(statsPlayer, "strength"),
        fitness = getCharData(statsPlayer, "fitness"),
        parttimejob = getCharData(statsPlayer, "parttimejob"),
        licenses = getCharData(statsPlayer, "licenses")
    }

    local money = getPlayerData(player, "money")
    local walkingStyle = getPedWalkingStyle(player)
    local hp = getElementHealth(player)

    if exports.rp_carshop:isPlayerBuyingCar(player) then
        dim = 0
    end

    local dataToChange = {
        x = x, y = y, z = z, hp = hp,
        money = money, bankmoney = stats.bankmoney,
        walkingStyle = walkingStyle, int = int, dim = dim,
        bwtime = stats.bwtime, fightstyles = stats.fightstyles,
        strength = stats.strength, fitness = stats.fitness,
        parttimejob = stats.parttimejob, licenses = stats.licenses
    }

    for k, v in pairs(dataToChange) do
        changeCharStatistics(statsPlayer, k, v)
    end

    exports.rp_db:query("UPDATE characters SET name = ?, surname = ?, statistics = ?, playtime = ? WHERE id = ?", 
        getPlayerData(player, "name"), 
        getPlayerData(player, "surname"),
        toJSON(getPlayerData(player, "statistics")), 
        getPlayerData(player, "playtime"),
        charID
    )

    print(getPlayerData(player, "name") .. " " .. getPlayerData(player, "surname") .. " saved character.")
end


function destroyPlayerData(player)
	savePlayer(player)
	local playerID = getPlayerData(player, "playerID")
    if playerID then
		-- print("usuwanie id gracza")
        ids[playerID] = nil
    end
    playersData[player] = nil
    loggedPlayers[player] = nil
end



function changeCharStatistics(table, key, newValue)
    if table[key] ~= nil then
        table[key] = newValue
		
		-- print(key, newValue)
    end
end

function getCharData(tbl, key)
    if tbl[key] ~= nil then
        return tbl[key]
    else
        return nil
    end
end

function changeCharData(player, data, newData)
    local stats = getPlayerData(player, "statistics")
    changeCharStatistics(stats, data, newData)
    local newData = getPlayerData(player, "statistics")
	setPlayerData(player,"statistics", newData)
	-- iprint(newData)
end


function getCharDataFromTable(player, data)
	local stats = getPlayerData(player, "statistics")
	local datac = getCharData(stats, data)

	return datac or false
end

function getTimestamp(year, month, day, hour, minute, second)
    -- initiate variables
    local monthseconds = { 2678400, 2419200, 2678400, 2592000, 2678400, 2592000, 2678400, 2678400, 2592000, 2678400, 2592000, 2678400 }
    local timestamp = 0
    local datetime = getRealTime()
    year, month, day = year or datetime.year + 1900, month or datetime.month + 1, day or datetime.monthday
    hour, minute, second = hour or datetime.hour, minute or datetime.minute, second or datetime.second
    
    -- calculate timestamp
    for i=1970, year-1 do timestamp = timestamp + (isLeapYear(i) and 31622400 or 31536000) end
    for i=1, month-1 do timestamp = timestamp + ((isLeapYear(year) and i == 2) and 2505600 or monthseconds[i]) end
    timestamp = timestamp + 86400 * (day - 1) + 3600 * hour + 60 * minute + second
    
    timestamp = timestamp - 3600 --GMT+1 compensation
    if datetime.isdst then timestamp = timestamp - 3600 end
    
    return timestamp
end

function isLeapYear(year)
    if year then year = math.floor(year)
    else year = getRealTime().year + 1900 end
    return ((year % 4 == 0 and year % 100 ~= 0) or year % 400 == 0)
end

function setPedMaxHealth(ped, desiredHealth)
    assert(isElement(ped) and (getElementType(ped) == "player" or getElementType(ped) == "ped"),
        "Bad argument @ 'setPedMaxHealth' [Expected ped/player at argument 1, got " .. tostring(ped) .. " (" .. type(ped) .. ")]")

    if not isPedDead(ped) then
        desiredHealth = tonumber(desiredHealth) or 100
        desiredHealth = math.max(100, math.min(200, desiredHealth)) -- clamp do 100-200

        -- Odwrotna formuła do obliczenia siły potrzebnej dla danego zdrowia
        local strength = 569 + (desiredHealth - 100) * 4.31
        strength = math.min(1000, math.max(0, strength)) -- clamp do 0-1000

        setPedStat(ped, 24, strength)
        return setElementHealth(ped, desiredHealth)
    end
end

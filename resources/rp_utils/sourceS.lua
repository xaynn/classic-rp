local controlToDisable = {"jump", "fire", "sprint", "crouch"}

local function tabIndexOverflow(seed, table)
    for i = 1, #table do
        if seed - table[i] <= 0 then
            return i, seed
        end
        seed = seed - table[i]
    end
end

local gWeekDays = { "Niedziela", "Poniedziałek", "Wtorek", "Środa", "Czwartek", "Piątek", "Sobota" }
function formatDate(format, escaper, timestamp)
	
	escaper = (escaper or "'"):sub(1, 1)
	local time = getRealTime(timestamp)
	local formattedDate = ""
	local escaped = false

	time.year = time.year + 1900
	time.month = time.month + 1
	
	local datetime = { d = ("%02d"):format(time.monthday), h = ("%02d"):format(time.hour), i = ("%02d"):format(time.minute), m = ("%02d"):format(time.month), s = ("%02d"):format(time.second), w = gWeekDays[time.weekday+1]:sub(1, 2), W = gWeekDays[time.weekday+1], y = tostring(time.year):sub(-2), Y = time.year }
	
	for char in format:gmatch(".") do
		if (char == escaper) then escaped = not escaped
		else formattedDate = formattedDate..(not escaped and datetime[char] or char) end
	end
	
	return formattedDate
end

function getDate(unix) --exports.rp_utils:getDate()
    assert(unix == nil or type(unix) == "number" or unix:find("/Date%((%d+)"), "Please input a valid number to \"getDate\"")
    local unix = (type(unix) == "string" and unix:match("/Date%((%d+)") / 1000 or unix or os.time()) -- This is for a certain JSON compatability. It works the same even if you don't need it

    local dayCount, year, days, month = function(yr) return (yr % 4 == 0 and (yr % 100 ~= 0 or yr % 400 == 0)) and 366 or 365 end, 1970, math.ceil(unix/86400)

    while days >= dayCount(year) do days = days - dayCount(year) year = year + 1 end -- Calculate year and days into that year

    month, days = tabIndexOverflow(days, {31,(dayCount(year) == 366 and 29 or 28),31,30,31,30,31,31,30,31,30,31}) -- Subtract from days to find current month and leftover days

	return string.format("%02d/%02d/%04d", days, month, year)
end 

function getPlayerICName(player)
	-- local name, surname = exports.rp_login:getPlayerData(player,"name"), exports.rp_login:getPlayerData(player,"surname")
	-- if not name or not surname then return false end
	-- local fullName = name.." "..surname
	local fullName = exports.rp_login:getPlayerData(player,"visibleName")
	if exports.rp_login:getPlayerData(player,"adminDuty") then
	fullName = getPlayerName(player):gsub ( "_", " " )  
	end
	return fullName
end

function getPlayerRealName(player)
	local name, surname = exports.rp_login:getPlayerData(player,"name"), exports.rp_login:getPlayerData(player,"surname")
	local fullName = name.." "..surname
	return fullName
end

function getXYInFrontOfPlayer(player, distance)
	local x, y, z = getElementPosition(player)
	local _, _, rot = getElementRotation(player)
	x = x + math.sin(math.rad(-rot)) * distance
	y = y + math.cos(math.rad(-rot)) * distance
	return x, y, z
end

function getPlayerFromCharID(uid)
	for k, v in pairs(getElementsByType("player")) do
		if exports.rp_login:getPlayerData(v, "characterID") == uid then
			return v
		end
	end
	return false
end

function capitalizeFirstLetter(text)
    return text:sub(1, 1):upper() .. text:sub(2)
end


function isMelee( weapon )
   return weapon and weapon <= 15
end

function getPlayerCharTime(player)
    local loginTime = getPlayerData(player, "loginTime")
    local playtime = getPlayerData(player, "playtime")

    if loginTime and playtime then
        local sessionTime = os.time() - loginTime
        local totalPlaytime = playtime + sessionTime
        setPlayerData(source, "playtime", totalPlaytime, true)
        return totalPlaytime
    end
    return false
end

function toHex ( n )
    local hexnums = {"0","1","2","3","4","5","6","7",
                     "8","9","A","B","C","D","E","F"}
    local str,r = "",n%16
    if n-r == 0 then str = hexnums[r+1]
    else str = toHex((n-r)/16)..hexnums[r+1] end
    return str
end


do
	local passiveTimerGroups = {}
	local cleanUpInterval = 240000
	local nextCleanUpCycle = getTickCount() + cleanUpInterval
	
	local onElementDestroyEventName = triggerServerEvent and "onClientElementDestroy" or "onElementDestroy"
	
	local function isEventHandlerAdded( eventName, elementAttachedTo, func ) -- https://wiki.multitheftauto.com/wiki/GetEventHandlers
		local attachedFunctions = getEventHandlers( eventName, elementAttachedTo )
		if #attachedFunctions > 0 then
			for i=1, #attachedFunctions do
				if attachedFunctions[i] == func then
					return true
				end
			end
		end
		return false
	end
	--[[
		Remove passive timers of elements that are destroyed
	]]
	local function removeDeletedElementTimer ()
		for timerName, passiveTimers in pairs(passiveTimerGroups) do
			if passiveTimers[this] then
				passiveTimers[this] = nil
				if not next(passiveTimers) then
					passiveTimerGroups[timerName] = nil
				end
			end
		end
		removeEventHandler(onElementDestroyEventName, this, removeDeletedElementTimer)
	end
	
	--[[
		Make a clean up cycle to prevent a memory leak
	]]
	local function checkCleanUpCycle (timeNow)
		if timeNow > nextCleanUpCycle then
			nextCleanUpCycle = timeNow + cleanUpInterval
			local maxExecutionTime = timeNow + 3
			for timerName, passiveTimers in pairs(passiveTimerGroups) do
				for key, executionTime in pairs(passiveTimers) do
					if timeNow > executionTime then
						if isElement(key) and isEventHandlerAdded(onElementDestroyEventName, key, removeDeletedElementTimer) then
							removeEventHandler(onElementDestroyEventName, key, removeDeletedElementTimer)
						end
						passiveTimers[key] = nil
					end
				end
				if not next(passiveTimers) then
					passiveTimerGroups[timerName] = nil
				end
				--[[
					Just making sure that during the clean-up cycle no lag spike occur.
				]]
				if getTickCount() >= maxExecutionTime then
					break
				end
			end
		end
	end
	
	function checkPassiveTimer (timerName, key, timeInterval)
		if type(timerName) ~= "string" then
			error("bad argument @ 'checkPassiveTimer' [Expected string at argument 1, got " .. type(timerName) .. "]", 2)
		elseif key == nil then
			error("bad argument @ 'checkPassiveTimer' [Expected anything except for nil at argument 2, got nil]", 2)
		end
		
		local intervalType = type(timeInterval)
		if intervalType == "string" then
			timeInterval = tonumber(timeInterval)
			if not timeInterval then
				error("bad argument @ 'checkPassiveTimer' [Expected a convertible string at argument 3]", 2)
			end
		elseif intervalType ~= "number" then
			error("bad argument @ 'checkPassiveTimer' [Expected number at argument 3, got " .. type(timeInterval) .. "]", 2)
		end
		
		--[[
			Set-up the timer
		]]
		local passiveTimers = passiveTimerGroups[timerName]
		if not passiveTimers then
			passiveTimers = {}
			passiveTimerGroups[timerName] = passiveTimers
		end
		
		local timeNow = getTickCount()


		local executionTime = passiveTimers[key]
		if executionTime then
			if timeNow > executionTime then
				passiveTimers[key] = timeNow + timeInterval
				checkCleanUpCycle(timeNow)
				return true, 0
			end
			checkCleanUpCycle(timeNow)
			return false, executionTime - timeNow
		end
		
		if isElement(key) and not isEventHandlerAdded(onElementDestroyEventName, key, removeDeletedElementTimer) then
			addEventHandler(onElementDestroyEventName, key, removeDeletedElementTimer, false, "high")
		end
		
		passiveTimers[key] = timeNow + timeInterval
		
		checkCleanUpCycle(timeNow)
		return true, 0
	end
end

function getDistanceBetweenElements(arg1, arg2)
	local element1 = Vector3(getElementPosition( arg1 ))
	local element2 = Vector3(getElementPosition( arg2 ))
	local distance = getDistanceBetweenPoints3D( element1,element2 )
	return distance
end


function playerJumpAndRunControlState(player, state)
    for k, v in pairs(controlToDisable) do
        toggleControl(player, v, state)
    end
end


function getPlayerLicense(player, targetLicense)
    local licenseTable = exports.rp_login:getCharDataFromTable(player, "licenses")
	local actual = false
    for k, v in pairs(licenseTable) do
        if v == targetLicense then
            actual = true
        end
    end
	return actual
end


function givePlayerLicense(player, license) -- licencje prawko, prawko tiry, bron, na taser.
    local licenseTable = exports.rp_login:getCharDataFromTable(player, "licenses")
    for k, v in pairs(licenseTable) do
        if v == license then
            return false -- false, czyli nie udalo sie nadac bo juz ma
        end
    end
	table.insert(licenseTable, license)
    exports.rp_login:changeCharData(player, "licenses", licenseTable)
    return true
end

function removePlayerLicense(player, license)
    local licenseTable = exports.rp_login:getCharDataFromTable(player, "licenses")
	for k, v in pairs(licenseTable) do
        if v == license then
            table.remove(licenseTable, k)
			exports.rp_login:changeCharData(player, "licenses", licenseTable)
			return true
        end
    end
	return false
end

function getNearestElement(player, type, distance)
    local result = false
    local dist = nil
    if player and isElement(player) then
        local elements = getElementsWithinRange(Vector3(getElementPosition(player)), distance, type, getElementInterior(player), getElementDimension(player))
        for i = 1, #elements do
            local element = elements[i]
            if not dist then
                result = element
                dist = getDistanceBetweenPoints3D(Vector3(getElementPosition(player)), Vector3(getElementPosition(element)))
            else
                local newDist = getDistanceBetweenPoints3D(Vector3(getElementPosition(player)), Vector3(getElementPosition(element)))
                if newDist <= dist then
                    result = element
                    dist = newDist
                end
            end
        end
    end
    return result
end


function getNearbyPlayers(player, distance)
    if not isElement(player) then return {} end

    local px, py, pz = getElementPosition(player)
    local interior = getElementInterior(player)
    local dimension = getElementDimension(player)

    local players = getElementsWithinRange(px, py, pz, distance, "player", interior, dimension)
    local nearbyPlayers = {}

    for _, p in ipairs(players) do
        -- if p ~= player then
            table.insert(nearbyPlayers, p)
        -- end
    end

    return nearbyPlayers
end


function getNearbyPlayersAtPosition(x, y, z, distance, interior, dimension)
	local players = getElementsWithinRange(x, y, z, distance, "player", interior, dimension)
    local nearbyPlayers = {}

    for _, p in ipairs(players) do
        -- if p ~= player then
            table.insert(nearbyPlayers, p)
        -- end
    end

    return nearbyPlayers
end

local maleSkins = {
	[7]=true,[14]=true,[15]=true,[16]=true,[17]=true,[18]=true,[19]=true,[20]=true,[21]=true,[22]=true,[23]=true,
	[24]=true,[25]=true,[26]=true,[27]=true,[28]=true,[29]=true,[30]=true,[32]=true,[33]=true,[34]=true,[35]=true,[36]=true,
	[37]=true,[43]=true,[44]=true,[45]=true,[46]=true,[47]=true,[48]=true,[49]=true,[50]=true,[51]=true,[52]=true,[57]=true,
	[58]=true,[59]=true,[60]=true,[61]=true,[62]=true,[66]=true,[67]=true,[68]=true,[70]=true,[71]=true,[72]=true,[73]=true,
	[78]=true,[79]=true,[80]=true,[81]=true,[82]=true,[83]=true,[84]=true,[94]=true,[95]=true,[96]=true,[97]=true,[98]=true,
	[99]=true,[100]=true,[101]=true,[102]=true,[103]=true,[104]=true,[105]=true,[106]=true,[107]=true,[108]=true,[109]=true,
	[110]=true,[111]=true,[112]=true,[113]=true,[114]=true,[115]=true,[116]=true,[117]=true,[118]=true,[120]=true,[121]=true,
	[122]=true,[123]=true,[124]=true,[125]=true,[126]=true,[127]=true,[128]=true,[132]=true,[133]=true,[134]=true,[135]=true,
	[136]=true,[137]=true,[142]=true,[143]=true,[144]=true,[146]=true,[147]=true,[153]=true,[154]=true,[155]=true,[156]=true,
	[158]=true,[159]=true,[160]=true,[161]=true,[162]=true,[163]=true,[164]=true,[165]=true,[166]=true,[167]=true,[168]=true,
	[170]=true,[171]=true,[173]=true,[174]=true,[175]=true,[176]=true,[177]=true,[179]=true,[180]=true,[181]=true,[182]=true,
	[183]=true,[184]=true,[185]=true,[186]=true,[187]=true,[188]=true,[189]=true,[200]=true,[202]=true,[203]=true,[204]=true,
	[206]=true,[209]=true,[210]=true,[212]=true,[213]=true,[217]=true,[220]=true,[221]=true,[222]=true,[223]=true,[227]=true,
	[228]=true,[229]=true,[230]=true,[234]=true,[235]=true,[236]=true,[239]=true,[240]=true,[241]=true,[242]=true,[247]=true,
	[248]=true,[249]=true,[250]=true,[252]=true,[253]=true,[254]=true,[255]=true,[258]=true,[259]=true,[260]=true,[261]=true,
	[262]=true,[264]=true,[268]=true,[269]=true,[270]=true,[271]=true,[272]=true,[287]=true,[288]=true,[290]=true,[291]=true,[292]=true,[293]=true,[294]=true,[295]=true,[296]=true,[297]=true,
	[299]=true,[300]=true,[301]=true,[302]=true,[303]=true,[305]=true,[306]=true,[307]=true,[308]=true,[309]=true,[310]=true,
	[311]=true,[312]=true
}

local femaleSkins = {
	[9]=true,[10]=true,[11]=true,[12]=true,[13]=true,[31]=true,[38]=true,[39]=true,[40]=true,[41]=true,[53]=true,[54]=true,
	[55]=true,[56]=true,[63]=true,[64]=true,[69]=true,[75]=true,[76]=true,[77]=true,[85]=true,[87]=true,[88]=true,[89]=true,
	[90]=true,[91]=true,[92]=true,[93]=true,[129]=true,[130]=true,[131]=true,[138]=true,[139]=true,[140]=true,[141]=true,
	[145]=true,[148]=true,[150]=true,[151]=true,[152]=true,[157]=true,[169]=true,[172]=true,[178]=true,[190]=true,[191]=true,
	[192]=true,[193]=true,[194]=true,[195]=true,[196]=true,[197]=true,[198]=true,[199]=true,[201]=true,[205]=true,[207]=true,
	[211]=true,[214]=true,[215]=true,[216]=true,[218]=true,[219]=true,[224]=true,[225]=true,[226]=true,[231]=true,[232]=true,
	[233]=true,[237]=true,[238]=true,[243]=true,[244]=true,[245]=true,[246]=true,[251]=true,[256]=true,[257]=true,[263]=true,
	[298]=true,[304]=true
}

function returnMaleSkins()
	return maleSkins
end

function returnFemaleSkins()
	return femaleSkins
end

setWorldSpecialPropertyEnabled("burnflippedcars", false)
setWorldSpecialPropertyEnabled("extraairresistance", false)
setWorldSpecialPropertyEnabled("randomfoliage", false)
setWorldSpecialPropertyEnabled("vehicle_engine_autostart", false)
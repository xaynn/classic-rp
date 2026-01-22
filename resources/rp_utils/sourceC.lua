local sx, sy = guiGetScreenSize()
local scaleValue = exports.rp_scale:returnScaleValue()
local offSetX, offsetY = exports.rp_scale:returnOffsetXY()
local cpuX, cpuY = exports.rp_scale:getScreenStartPositionFromBox(50*scaleValue, 50*scaleValue, offSetX, offsetY, "left", "top")
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





function generateRandomString()
    local chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890'
    local length = math.random(1, 25)
    local str = ''
    for i = 1, length do
        local char = string.sub(chars, math.random(1, #chars), math.random(1, #chars))
        str = str .. char
    end
    return str
end

function getDate(unix) --exports.rp_utils:getDate()
    assert(unix == nil or type(unix) == "number" or unix:find("/Date%((%d+)"), "Please input a valid number to \"getDate\"")
    local unix = (type(unix) == "string" and unix:match("/Date%((%d+)") / 1000 or unix or os.time()) -- This is for a certain JSON compatability. It works the same even if you don't need it

    local dayCount, year, days, month = function(yr) return (yr % 4 == 0 and (yr % 100 ~= 0 or yr % 400 == 0)) and 366 or 365 end, 1970, math.ceil(unix/86400)

    while days >= dayCount(year) do days = days - dayCount(year) year = year + 1 end -- Calculate year and days into that year

    month, days = tabIndexOverflow(days, {31,(dayCount(year) == 366 and 29 or 28),31,30,31,30,31,31,30,31,30,31}) -- Subtract from days to find current month and leftover days

	return string.format("%02d/%02d/%04d", days, month, year)
end 


function getElementDirectionCardialPoint(p)
    local rotation = select(3, getElementRotation(p))
    if (rotation <= 45) or (rotation >= 315) then
        return "North"
    elseif (rotation >= 45 and rotation <= 135) then
        return "East"
    elseif (rotation > 135 and rotation <= 225) then
        return "South"
    elseif (rotation > 225 and rotation < 315) then
        return "West"
    else
        return "N/A"
    end
end

function setScreenFlash()
    fadeCamera(false, 0.2, 255, 255, 255)
    setTimer(function()
        fadeCamera(true)
    end, 100, 1)
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
	[262]=true,[264]=true,[265]=true,[266]=true,[267]=true,[268]=true,[269]=true,[270]=true,[271]=true,[272]=true,[274]=true,
	[275]=true,[276]=true,[277]=true,[278]=true,[279]=true,[280]=true,[281]=true,[282]=true,[283]=true,[284]=true,[285]=true,
	[286]=true,[287]=true,[288]=true,[290]=true,[291]=true,[292]=true,[293]=true,[294]=true,[295]=true,[296]=true,[297]=true,
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


function moneyFormat(amount)
   local formatted = amount
   while true do
      formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1.%2')
      if (k==0) then
         break
      end
   end
   return formatted
end

setAmbientSoundEnabled( "general", false )
setAmbientSoundEnabled( "gunfire", false )
setPedTargetingMarkerEnabled(false)
toggleControl("action", false)

function getPositionFromElementOffset(element,offX,offY,offZ)
    local m = getElementMatrix ( element )  -- Get the matrix
    local x = offX * m[1][1] + offY * m[2][1] + offZ * m[3][1] + m[4][1]  -- Apply transform
    local y = offX * m[1][2] + offY * m[2][2] + offZ * m[3][2] + m[4][2]
    local z = offX * m[1][3] + offY * m[2][3] + offZ * m[3][3] + m[4][3]
    return x, y, z                               -- Return the transformed point
end
local cpuUsageEnabled = false
function localStats()
    cpuUsageEnabled = not cpuUsageEnabled
    if cpuUsageEnabled then
        addEventHandler("onClientRender", root, cpuUsage)
    else
        removeEventHandler("onClientRender", root, cpuUsage)
    end
end
addCommandHandler("cpu", localStats, false, false)
function cpuUsage()
    local players, peds, objects, vehicles =
        getElementsByType("player", getRootElement(), true),
        getElementsByType("ped", getRootElement(), true),
        getElementsByType("object", getRootElement(), true),
		getElementsByType("vehicle", getRootElement(), true)
    dxDrawText("Peds: " .. #peds .. " Players: " .. #players .. " Objects: " .. #objects.." Vehicles: "..#vehicles, cpuX, cpuY, cpuX, cpuY)
end



local fpsEnabled = false
local fps = 0
local nextTick = 0
function getCurrentFPS() -- Setup the useful function
    return fps
end

local function updateFPS(msSinceLastFrame)
    -- FPS are the frames per second, so count the frames rendered per milisecond using frame delta time and then convert that to frames per second.
    local now = getTickCount()
    if (now >= nextTick) then
        fps = (1 / msSinceLastFrame) * 1000
        nextTick = now + 1000
    end
end
addEventHandler("onClientPreRender", root, updateFPS)

local function drawFPS()
    if not getCurrentFPS() then
        return
    end
    local roundedFPS = math.floor(getCurrentFPS())
    dxDrawText(roundedFPS, sx - dxGetTextWidth(roundedFPS), 0)
end

function fpsCommandHandler()
    fpsEnabled = not fpsEnabled
    if fpsEnabled then
        addEventHandler("onClientHUDRender", root, drawFPS)
    else
        removeEventHandler("onClientHUDRender", root, drawFPS)
    end
end
addCommandHandler("fps", fpsCommandHandler, false, false)

function capitalizeFirstLetter(text)
    return text:sub(1, 1):upper() .. text:sub(2)
end

function getPlayerICName(player)
	local fullName = exports.rp_login:getPlayerData(player,"visibleName")
	if exports.rp_login:getPlayerData(player,"adminDuty") then
	fullName = getPlayerName(player):gsub ( "_", " " )
	end
	return fullName
end

function isMelee( weapon )
   return weapon and weapon <= 15
end


local sm = {moov = 0}

local function removeCamHandler()
    if (sm.moov == 1) then
        sm.moov = 0
    end
end

local start, animTime
local tempPos, tempPos2 = {{},{}}, {{},{}}

local function camRender()
    local now = getTickCount()
    if (sm.moov == 1) then
        local x1, y1, z1 = interpolateBetween(tempPos[1][1], tempPos[1][2], tempPos[1][3], tempPos2[1][1], tempPos2[1][2], tempPos2[1][3], (now-start) / animTime, "InOutQuad")
        local x2, y2, z2 = interpolateBetween(tempPos[2][1], tempPos[2][2], tempPos[2][3], tempPos2[2][1], tempPos2[2][2], tempPos2[2][3], (now-start) / animTime, "InOutQuad")
        setCameraMatrix(x1, y1, z1, x2, y2, z2)
    else
        removeEventHandler("onClientRender", root, camRender)
        fadeCamera(true)
    end
end

function smoothMoveCamera(x1, y1, z1, x1t, y1t, z1t, x2, y2, z2, x2t, y2t, z2t, time)
    if(sm.moov == 1) then
        killTimer(timer1)
        killTimer(timer2)
        removeEventHandler("onClientRender", root, camRender)
        fadeCamera(true)
    end
    fadeCamera(true)
    sm.moov = 1
    timer1 = setTimer(removeCamHandler, time, 1)
    timer2 = setTimer(fadeCamera, time - 1000, 1, false)
    start = getTickCount()
    animTime = time
    tempPos[1], tempPos[2] = {x1, y1, z1}, {x1t, y1t, z1t}
    tempPos2[1], tempPos2[2] = {x2, y2, z2}, {x2t, y2t, z2t}
    addEventHandler("onClientRender", root, camRender)
    return true
end


function destroySmoothMoveCamera()
    if isTimer(timer1) then
        killTimer(timer1)
        killTimer(timer2)
        removeEventHandler("onClientRender", root, camRender)
        fadeCamera(true)
    end
end


function getDistanceBetweenElements(arg1, arg2)
	local element1 = Vector3(getElementPosition( arg1 ))
	local element2 = Vector3(getElementPosition( arg2 ))
	local distance = getDistanceBetweenPoints3D( element1,element2 )
	return distance
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





local gmText = guiCreateLabel(0,sy-25, sx-85, 24, "Classic RolePlay " .. exports.rp_utils:formatDate("W d/m/Y"), false)
guiLabelSetVerticalAlign (gmText,"bottom")
guiLabelSetHorizontalAlign (gmText,"right")
guiSetAlpha(gmText, 0.5)
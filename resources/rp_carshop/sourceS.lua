local isPlayerInCarShop = {}
local isPlayerInCarShopMarker = {}

function isPlayerBuyingCar(player)
    if isPlayerInCarShop[player] then
        return true
    end
    return false
end
local carShopsMarkers = createElement("carShopsElements")
local carShopsPositions = {
[1] = {863.580078125,-1254.146484375,14.553990364075}, 
[2] = {2131.9833984375,-1150.5185546875,24.150405883789},
}

function loadCarShops()
    for k, v in pairs(carShopsPositions) do
        local blip = createBlip(v[1], v[2], v[3], 55, 2, 255, 0, 0, 255, 0, 300)
        local marker = createMarker(v[1], v[2], v[3]-0.9, "cylinder", 2, 255, 0, 0, 0)--createColSphere(v[1], v[2], v[3], 10)
		exports.rp_login:setObjectData(marker, "3DText", "Salon pojazdów")
        setElementParent(marker, carShopsMarkers)
    end
end
-- function displayLoadedRes(res)
    -- if getResourceName(res) == "rp_login" then
		-- loadCarShops()
    -- end
-- end

-- addEventHandler("onResourceStart", root, displayLoadedRes)

-- loadCarShops()
setTimer ( loadCarShops, 10000, 1)


function CarShopEnterHandler(hitElement, matchinDimension)
    if getElementType(hitElement) == "player" then
        if matchinDimension then
			local vehicle = getPedOccupiedVehicle(hitElement)
			if vehicle then return end
            if not isPlayerInCarShopMarker[hitElement] then
                isPlayerInCarShopMarker[hitElement] = true
				bindKey ( hitElement, "E", "down", bindKeyShop, hitElement, source )
            end
        end
    end
end

addEventHandler("onMarkerHit", carShopsMarkers, CarShopEnterHandler)







function CarShopExitHandler(hitElement, matchingDimension)
    if getElementType(hitElement) == "player" then
        if matchingDimension then
            isPlayerInCarShopMarker[hitElement] = nil
			unbindKey ( hitElement, "E", "down", bindKeyShop )
        end
    end
end
addEventHandler("onMarkerLeave", carShopsMarkers, CarShopExitHandler)

local vehicleCategories = {
    ["Sportowe"] = {
    {id = 411, name = "Infernus", price = 60000},
    {id = 415, name = "Cheetah", price = 55000},
    {id = 451, name = "Turismo", price = 52000},
    {id = 541, name = "Bullet", price = 50000},
    {id = 429, name = "Banshee", price = 45000},
    {id = 480, name = "Comet", price = 42000},
    {id = 506, name = "Super GT", price = 40000},
    {id = 559, name = "Jester", price = 38000},
    {id = 560, name = "Sultan", price = 36000},
    {id = 562, name = "Elegy", price = 34000},
    {id = 565, name = "Flash", price = 32000},
    {id = 558, name = "Uranus", price = 30000},
    {id = 561, name = "Stratum", price = 28000},
    {id = 555, name = "Windsor", price = 26000},
    {id = 477, name = "ZR-350", price = 25000},
},

    ["Terenowe"] = {
{ id = 495, name = "Sandking", price = 90000 },
{ id = 444, name = "Monster", price = 100000 },
{ id = 579, name = "Huntley", price = 60000 },
{ id = 400, name = "Landstalker", price = 35000 },
{ id = 500, name = "Mesa", price = 30000 },
{ id = 489, name = "Rancher", price = 35000 },
{ id = 505, name = "Rancher (Lure)", price = 35000 },
{ id = 404, name = "Perennial", price = 20000 },
{ id = 442, name = "Romero", price = 20000 },
{ id = 458, name = "Solair", price = 22000 },
{ id = 479, name = "Regina", price = 22000 },
    },
    ["Ciężarówki"] = {
{ id = 403, name = "Linerunner", price = 85000 },
{ id = 515, name = "Roadtrain", price = 90000 },
{ id = 514, name = "Tanker", price = 85000 },
{ id = 455, name = "Flatbed", price = 60000 },
{ id = 499, name = "Benson", price = 50000 },
{ id = 456, name = "Yankee", price = 55000 },
{ id = 423, name = "Mr. Whoopee", price = 25000 },
{ id = 414, name = "Mule", price = 30000 },
{ id = 443, name = "Packer", price = 40000 },
{ id = 524, name = "Cement Truck", price = 60000 },
{ id = 578, name = "DFT-30", price = 55000 },
{ id = 531, name = "Tractor", price = 10000 },
{ id = 573, name = "Dune", price = 25000 },
{ id = 609, name = "Boxville (Black)", price = 35000 },
{ id = 498, name = "Boxville", price = 30000 },

    },
    ["Lekkie dostawcze"] = {
{ id = 459, name = "RC Van", price = 6000 },
{ id = 422, name = "Bobcat", price = 10000 },
{ id = 482, name = "Burrito", price = 15000 },
{ id = 543, name = "Sadler", price = 9000 },
{ id = 418, name = "Moonbeam", price = 12000 },
{ id = 582, name = "News Van", price = 16000 },
{ id = 413, name = "Pony", price = 14000 },
{ id = 440, name = "Rumpo", price = 14000 },
{ id = 478, name = "Walton", price = 10000 },
{ id = 554, name = "Yosemite", price = 20000 },
    },
    ["Motocykle"] = {
{ id = 461, name = "PCJ-600", price = 20000 },
{ id = 468, name = "Sanchez", price = 15000 },
{ id = 521, name = "FCR-900", price = 25000 },
{ id = 522, name = "NRG-500", price = 40000 },
{ id = 463, name = "Freeway", price = 12000 },
{ id = 586, name = "Wayfarer", price = 10000 },
{ id = 471, name = "Quadbike", price = 13000 },
{ id = 581, name = "BF-400", price = 18000 },
{ id = 462, name = "Faggio", price = 5000 },
{ id = 448, name = "Pizza Boy", price = 8000 },

    },
    ["Rowery"] = {
{ id = 481, name = "BMX", price = 500 },
{ id = 509, name = "Bike", price = 300 },
{ id = 510, name = "Mountain Bike", price = 800 },
    },
    ["Kompaktowe"] = {
        {id = 602, name = "Alpha", price = 30000},
        {id = 496, name = "Blista Compact", price = 28000},
        {id = 401, name = "Bravura", price = 25000},
        {id = 518, name = "Buccaneer", price = 27000},
        {id = 527, name = "Cadrona", price = 26000},
        {id = 589, name = "Club", price = 24000},
        {id = 419, name = "Esperanto", price = 22000},
        {id = 587, name = "Euros", price = 40000},
        {id = 533, name = "Feltzer", price = 45000},
        {id = 526, name = "Fortune", price = 20000},
        {id = 474, name = "Hermes", price = 18000},
        {id = 545, name = "Hustler", price = 16000},
        {id = 517, name = "Majestic", price = 19000},
        {id = 410, name = "Manana", price = 10000},
        {id = 600, name = "Picador", price = 12000},
        {id = 436, name = "Previon", price = 17000},
        {id = 439, name = "Stallion", price = 16000},
        {id = 549, name = "Tampa", price = 15000},
        {id = 491, name = "Virgo", price = 15000}
    },
    ["Luksusowe"] = {
        {id = 445, name = "Admiral", price = 30000},
        {id = 507, name = "Elegant", price = 35000},
        {id = 585, name = "Emperor", price = 34000},
        {id = 466, name = "Glendale", price = 20000},
        {id = 492, name = "Greenwood", price = 22000},
        {id = 546, name = "Intruder", price = 23000},
        {id = 551, name = "Merit", price = 40000},
        {id = 516, name = "Nebula", price = 21000},
        {id = 467, name = "Oceanic", price = 19000},
        {id = 426, name = "Premier", price = 25000},
        {id = 547, name = "Primo", price = 20000},
        {id = 405, name = "Sentinel", price = 28000},
        {id = 580, name = "Stafford", price = 50000},
        {id = 550, name = "Sunrise", price = 32000},
        {id = 566, name = "Tahoma", price = 24000},
        {id = 540, name = "Vincent", price = 26000},
        {id = 421, name = "Washington", price = 27000},
        {id = 529, name = "Willard", price = 18000}
    },
    ["Lowridery"] = {
        {id = 536, name = "Blade", price = 30000},
        {id = 575, name = "Broadway", price = 25000},
        {id = 534, name = "Remington", price = 35000},
        {id = 567, name = "Savanna", price = 28000},
        {id = 535, name = "Slamvan", price = 27000},
        {id = 576, name = "Tornado", price = 20000},
        {id = 412, name = "Voodoo", price = 22000}
    },
    ["Taksówki"] = {
{ id = 420, name = "Taxi", price = 20000 },
{ id = 438, name = "Cabbie", price = 15000 },

    },
    ["Transport publiczny"] = {
{ id = 431, name = "Bus", price = 35000 },
{ id = 437, name = "Coach", price = 45000 },
{ id = 409, name = "Limuzyna", price = 70000 },

    },
    ["Customowe"] = {
        {id = 40008, name = "Landstalker 2", price = 35000 * 1.5},
        {id = 40009, name = "Rancher v3", price = 35000 * 2},
        {id = 40011, name = "Previon v2", price = 17000 * 1.5},
        {id = 40014, name = "Huntley v2", price = 60000 * 1.5},
        {id = 40015, name = "Windsor v2", price = 26000 * 1.5},
        {id = 40016, name = "Buffalo v2", price = 50000 * 1.5}, 
        {id = 40017, name = "Sultan v2", price = 36000 * 1.5},
        {id = 40018, name = "Yosemite v2", price = 20000 * 1.5},
        {id = 40019, name = "Landstalker v3", price = 35000 * 2},
        {id = 40020, name = "Bullet v2", price = 50000 * 1.5},
        {id = 40021, name = "Super GT v2", price = 40000 * 1.5},
        {id = 40022, name = "Euros v2", price = 40000 * 1.5},
        {id = 40023, name = "Buffalo v3", price = 50000 * 2},
        {id = 40024, name = "Club v2", price = 24000 * 1.5},
        {id = 40025, name = "Freeway v2", price = 12000 * 1.5},
        {id = 40026, name = "Wayfarer v2", price = 10000 * 1.5},
        {id = 40027, name = "Phoenix v2", price = 35000 * 1.5}, 
        {id = 40028, name = "Alpha v2", price = 30000 * 1.5},
        {id = 40029, name = "FBI Rancher v2", price = 35000 * 1.5},
        {id = 40030, name = "Regina v2", price = 22000 * 1.5},
        {id = 40031, name = "Bobcat v2", price = 10000 * 1.5},
        {id = 40032, name = "Intruder v2", price = 23000 * 1.5},
        {id = 40033, name = "Willard v2", price = 18000 * 1.5},
        {id = 40034, name = "Emperor v2", price = 34000 * 1.5},
        {id = 40035, name = "Admiral v2", price = 30000 * 1.5},
        {id = 40036, name = "Majestic v2", price = 19000 * 1.5},
        {id = 40037, name = "Washington v2", price = 27000 * 1.5},
        {id = 40038, name = "FCR v2", price = 25000 * 1.5},
        {id = 40039, name = "Jester v2", price = 38000 * 1.5},
        {id = 40040, name = "Premier v2", price = 25000 * 1.5},
        {id = 40041, name = "Feltzer v2", price = 45000 * 1.5},
        {id = 40042, name = "Elegant v2", price = 35000 * 1.5},
        {id = 40043, name = "Greenwood v2", price = 22000 * 1.5},
        {id = 40044, name = "Picador v2", price = 12000 * 1.5},
        {id = 40045, name = "Sentinel v2", price = 28000 * 1.5},
        {id = 40046, name = "Landstalker v4", price = 35000 * 2.5},
        {id = 40047, name = "Moonbeam v2", price = 12000 * 1.5},
        {id = 40048, name = "Nebula v2", price = 21000 * 1.5},
        {id = 40049, name = "Clover v2", price = 25000 * 1.5},
        {id = 40050, name = "Elegy v2", price = 34000 * 1.5},
        {id = 40051, name = "Burrito v2", price = 15000 * 1.5},
        {id = 40052, name = "Quadbike v2", price = 13000 * 1.5},
        {id = 40053, name = "Huntley v3", price = 60000 * 2},
        {id = 40055, name = "Tampa v2", price = 15000 * 1.5},
        {id = 40056, name = "Yosemite v3", price = 20000 * 2},
        {id = 40057, name = "Infernus v2", price = 60000 * 1.5},
    }
}


function enterCarShop(player)
    if isPlayerInCarShopMarker[player] then
        if isPlayerInCarShop[player] then
            return
        end
        isPlayerInCarShop[player] = true
        setElementFrozen(player, true)
        setElementDimension(player, math.random(3000, 9000))
        local dim = getElementDimension(player)
        triggerClientEvent(player, "onPlayerOpenCarShop", player, vehicleCategories, dim)
    end
end
-- addCommandHandler("carshop", enterCarShop, false, false)

function bindKeyShop(player, key, keyState, _, marker)
	setElementFrozen(player, true)
    setElementDimension(player, math.random(3000, 9000))
    local dim = getElementDimension(player)
    triggerClientEvent(player, "onPlayerOpenCarShop", player, vehicleCategories, dim)
	isPlayerInCarShop[player] = true
	unbindKey ( player, "E", "down", bindKeyShop )
end

function leaveCarShop()
	if isPlayerInCarShop[client] then
		setElementFrozen(client, false)
		setElementDimension(client, 0)
		isPlayerInCarShop[client] = nil
		isPlayerInCarShopMarker[client] = nil
		setCameraTarget(client, client)
	end
end
addEvent("onPlayerLeaveCarShop", true)
addEventHandler("onPlayerLeaveCarShop", getRootElement(), leaveCarShop)


function onPlayerBuyCar(category, carID)
	if isPlayerInCarShop[client] then
	-- print(category, carID)
	local name, price = getVehicleNameAndPrice(category, carID)
	-- print(price)
	local bought = exports.rp_atm:takePlayerCustomMoney(client, tonumber(price))
	if not bought then return exports.rp_library:createBox(client,"Nie stać Cię na kupno tego pojazdu.") end
	local playerID = exports.rp_login:getPlayerData(client, "playerID")
	exports.rp_vehicles:createVeh(client, playerID, carID, 1, true)
	exports.rp_library:createBox(client, "Zakupiłeś "..name..".")
	end
end
addEvent("onPlayerBuyCar", true)
addEventHandler("onPlayerBuyCar", getRootElement(), onPlayerBuyCar)

function getVehicleNameAndPrice(category, carID)
	if not category or not carID then return end
    local name, price = false, false
    for k, v in pairs(vehicleCategories[category]) do
        if tonumber(carID) == tonumber(v.id) then
            name = v.name
            price = v.price
            return name, price
        end
    end
    return false
end




addEventHandler("onPlayerQuit", root,
	function(quitType)
		if isPlayerInCarShop[source] then isPlayerInCarShop[source] = nil end
		if isPlayerInCarShopMarker[source] then isPlayerInCarShopMarker[source] = nil end
	end
)




-- loadCarShops()
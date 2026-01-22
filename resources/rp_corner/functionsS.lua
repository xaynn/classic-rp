cornerZones = {}
cornerUID = {}
cornerElements = createElement("cornerZones")
cornerPlayerData = {} -- corner, w jakim gracz stoi i jaki ten corner ma bonus
randomWalkingStyles = {54, 118, 121, 122}
randomPedSkins = {2, 5, 7, 20, 21, 19, 18, 14, 15, 22, 24, 25, 28, 29, 30, 32, 43, 59, 60, 66, 67, 69, 78, 79}
randomPedNames = {"James Marsh","Bobby Cunningham","Tyler Harrison","Terrell Kelly","Cain Pate","Jake Brewer","Joseph Hughes","Griffin Harding","Jovani Walker","Michael Chambers","Ewan Mills"}
local gLimit = 50
local soldG = {}
function loadZones()
	local result = exports.rp_db:query("SELECT * FROM corner_zones")
	for k,v in ipairs(result) do
		local zone = createMarker(v.x, v.y, v.z, "cylinder", 2, 255, 0, 0, 1)
		cornerUID[zone] = v.id
		cornerZones[v.id] = {
			x = v.x,
			y = v.y,
			z = v.z,
			bonus = v.bonus,
			zoneElement = zone,
			playersDoingCorner = 0,
		}
		setElementParent(zone, cornerElements)
	end
end

function correctPosition(ped, x, y, z)
    if not isElement(ped) then
        return
    end
    setElementPosition(ped, x, y, z)
end

function onQuitFromServer()
    if isPlayerDoingCorner(source) then
        setPlayerDoingCorner(source, false)
    end
end
addEventHandler("onPlayerQuit", root, onQuitFromServer)

function cornerEnterHandler(hitElement, matchinDimension)
    if getElementType(hitElement) == "player" then
        if matchinDimension then
			local cornerID = cornerUID[source]
				if not cornerID then return end
				local zoneData = cornerZones[cornerID]
				if not zoneData then return end
				cornerPlayerData[hitElement] = {
				x = zoneData.x,
				y = zoneData.y,
				z = zoneData.z,
				bonus = zoneData.bonus,
				cornerID = cornerID,
				startedCorner = false,
				cornerPed = nil
				}
				outputChatBox("Wszedłeś w corner, możesz na nim sprzedawać narkotyki wpisując komendę /corner", hitElement, 255, 255, 255, true)
            end
        end
    end

addEventHandler("onMarkerHit", cornerElements, cornerEnterHandler)

function cornerExitHandler(hitElement, matchingDimension)
    if getElementType(hitElement) == "player" then
        if matchingDimension then
            if not cornerPlayerData[hitElement] then
                return
            end
            if isPlayerDoingCorner(hitElement) then
                setPlayerDoingCorner(hitElement, false)
            end
			cornerPlayerData[hitElement] = nil
        end
    end
end
addEventHandler("onMarkerLeave", cornerElements, cornerExitHandler)

function fixRotationWithPlayer(ped, pos, pos2)
    local rotZ = findRotation(pos.x, pos.y, pos2.x, pos2.y) - 180

    if not (rotZ == getPedRotation(ped)) then
        setPedRotation(ped, rotZ)
    end
end

function getPlayerSoldGramsInCorner(player)
	local characterID = exports.rp_login:getPlayerData(player,"characterID")
	if not soldG[characterID] then soldG[characterID] = 0 end
	return soldG[characterID]
end

function addAmountToSoldGrams(player, amount)
	local characterID = exports.rp_login:getPlayerData(player,"characterID")
	if not soldG[characterID] then soldG[characterID] = 0 end
	soldG[characterID] = soldG[characterID] + amount
	if soldG[characterID] >= gLimit then
		soldG[characterID] = 50
		exports.rp_library:createBox(player,"Posiadasz dzienny limit sprzedaży na cornerze.")
		setPlayerDoingCorner(player, false)
	end
end

loadZones()
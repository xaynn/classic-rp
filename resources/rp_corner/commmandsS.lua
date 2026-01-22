function cornerCommand(player, cmand, ...)
    local arg = {...}

    if not arg[1] then
	   if not exports.rp_utils:checkPassiveTimer("cornerCommand", player, 1000) then
            return
        end
		if not cornerPlayerData[player] then return exports.rp_library:createBox(player,"Nie jestes w cornerze") end
		local narcotics = exports.rp_inventory:getItemTypeInInventory(player, 7)
		if not narcotics then return exports.rp_library:createBox(player, "Nie masz nic do sprzedaży.") end
		local soldGrams = getPlayerSoldGramsInCorner(player)
		if soldGrams >= 50 then return exports.rp_library:createBox(player,"Posiadasz limit dziennej sprzedaży na cornerze.") end
		if cornerPlayerData[player].startedCorner then
			setPlayerDoingCorner(player, false)
		else
			setPlayerDoingCorner(player, true)
		end
		-- rozpoczecie corneru

    elseif arg[1] == "usun" and tonumber(arg[2]) then
        --perm
		if not exports.rp_admin:hasAdminPerm(player,"creatingCorners") then return end
        if not tonumber(arg[2]) then
            return exports.rp_library:createBox(player,"/corner usun [id cornera]")
        end
		local cornerID = tonumber(arg[2])
		local marker = cornerZones[cornerID]
		if not marker then return exports.rp_library:createBox(player,"Nie ma takiego corneru.") end
		local element = cornerZones[cornerID].zoneElement
		destroyElement(element)
		cornerUID[element] = nil
		cornerZones[cornerID] = nil
		exports.rp_library:createBox(player,"Usunięto corner o ID: "..cornerID)
		local query = exports.rp_db:query_free("DELETE FROM corner_zones WHERE ID = ?", cornerID)
		cornerPlayerData[player] = nil
	elseif arg[1] == "lista" then
		if not exports.rp_admin:hasAdminPerm(player,"creatingCorners") then return end
		outputChatBox("Lista cornerow: ", player, 255, 255, 255, true)
		for k,v in pairs(cornerZones) do
			outputChatBox("Corner ID: "..k, player, 255, 255, 255, true)
		end
	elseif arg[1] == "tp" then
		if not exports.rp_admin:hasAdminPerm(player,"creatingCorners") then return end
		if not arg[2] then return exports.rp_library:createBox("/corner tp [ID]") end
		local corner = cornerZones[tonumber(arg[2])]
		if not corner then return exports.rp_library:createBox(player,"Corner o podanym ID nie istnieje.") end
		setElementPosition(player, corner.x, corner.y, corner.z + 0.9)
    elseif arg[1] == "debug" then
	    if not exports.rp_admin:hasAdminPerm(player,"creatingCorners") then return end
        local isPlayerInCorner = getActualPlayerCorner(player)
        if isPlayerInCorner then
            -- print(isPlayerInCorner, cornerZones[isPlayerInCorner].bonus, cornerZones[isPlayerInCorner].zoneElement)
			exports.rp_library:createBox(player,"Informacje o cornerze ["..isPlayerInCorner.."]: Bonus: "..cornerZones[isPlayerInCorner].bonus, 2)
        end
    elseif arg[1] == "stworz" then
		if not exports.rp_admin:hasAdminPerm(player,"creatingCorners") then return end
		local x,y,z = getElementPosition(player)
		z = z - 0.9
		local _, __, uid = exports.rp_db:query("INSERT INTO corner_zones (x, y, z, bonus) VALUES (?, ?, ?, ?)", x, y, z, 0)
        exports.rp_library:createBox(player, "Stworzyłeś corner [" .. uid .. "]")
        local marker = createMarker(x, y, z, "cylinder", 1.3, 255, 0, 0, 50)
        cornerUID[marker] = uid
        cornerZones[uid] = {
            x = x,
            y = y,
            z = z,
            bonus = 0,
			zoneElement = marker,
			playersDoingCorner = 0
        }
        setElementParent(marker, cornerElements)
    elseif arg[1] == "bonus" then -- arg, bonus, idcornera
        --perm
		if not exports.rp_admin:hasAdminPerm(player,"creatingCorners") then return end
		local bonus, cornerID = tonumber(arg[2]), tonumber(arg[3])
        if not bonus or not cornerID then
            return exports.rp_library:createBox(player, "/corner bonus [bonus] [id cornera]")
        end
        local corner = cornerZones[cornerID]
        if not corner then
            return exports.rp_library:createBox(player, "Nie ma aktywnego corner o takim ID.")
        end

        cornerZones[cornerID].bonus = bonus
        local q = exports.rp_db:query_free("UPDATE corner_zones SET bonus = ? WHERE id = ?", bonus, cornerID)
        exports.rp_library:createBox(player,"Zmieniles bonus na cornerze na: " .. cornerID .. " [" .. bonus .. "]")
    end
end
addCommandHandler("corner", cornerCommand, false, false)
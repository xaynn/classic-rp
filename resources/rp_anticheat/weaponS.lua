local playerAllowedWeapons = {} -- gun, ammo

function allowPlayerWeapon(player, weapon)
    if not weapon then
        playerAllowedWeapons[player] = 0
    else
        playerAllowedWeapons[player] = tonumber(weapon)
    end
end

-- function onPlayerWeaponSwitch(previousWeaponID, currentWeaponID)
    -- local weaponAllowed = playerAllowedWeapons[source]

    -- if not weaponAllowed then
        -- banPlayerAC(source, "Weapon Spawner", "Brak dozwolonej broni")
        -- return
    -- end

    -- if currentWeaponID == weaponAllowed then
        -- return
    -- end

    -- if currentWeaponID == 0 and previousWeaponID == weaponAllowed then
        -- return
    -- end

    -- banPlayerAC(source, "Weapon Spawner", "Niedozwolona zmiana broni: " .. getWeaponNameFromID(currentWeaponID))
-- end
-- addEventHandler("onPlayerWeaponSwitch", root, onPlayerWeaponSwitch)
function onPlayerWeaponSwitch(previousWeaponID, currentWeaponID)
    local weaponAllowed = playerAllowedWeapons[source]
    if weaponAllowed == nil then
        banPlayerAC(source, "Weapon Spawner", "Brak dozwolonej broni")
        return
    end

    if currentWeaponID == 0 or previousWeaponID == 0 then
        return
    end

    if currentWeaponID ~= weaponAllowed and previousWeaponID ~= weaponAllowed then
        banPlayerAC(source, "Weapon Spawner", "Niedozwolona zmiana broni: " .. getWeaponNameFromID(currentWeaponID))
    end
end
addEventHandler("onPlayerWeaponSwitch", root, onPlayerWeaponSwitch)


addEventHandler("onPlayerQuit", root,
	function(quitType)
	if playerAllowedWeapons[source] then playerAllowedWeapons[source] = nil end
	end
)

addEventHandler("onPlayerWeaponFire",root,
    function(weapon, endX, endY, endZ, hitElement, startX, startY, startZ)
        local weaponAllowed = playerAllowedWeapons[source]
        if weaponAllowed == nil or weaponAllowed ~= weapon then
            banPlayerAC(source, "Weapon Spawner", "Brak dozwolonej broni/Fire: " .. getWeaponNameFromID(weapon))
        end
    end
)


function getAllowedWeapons(player)
iprint(playerAllowedWeapons[player])
end
-- addCommandHandler("testwep", getAllowedWeapons, false, false)
local projectileNames = {
    [16]='Grenade',
    [17]='Tear Gas Grenade',
    [18]='Molotov',
    [19]='Rocket (simple)',
    [20]='Rocket (heat seeking)',
    [21]='Air Bomb',
    [39]='Satchel Charge',
    [58]='Hydra flare'
}

local explosionTypes = {
	[0] = "Grenade",
	[1] = "Molotov",
	[2] = "Rocket",
	[3] = "Rocket Weak",
	[4] = "Car",
	[5] = "Car Quick",
	[6] = "Boat",
	[7] = "Aircraft",
	[8] = "Mine",
	[9] = "Object",
	[10] = "Tank Grenade",
	[11] = "Small",
	[12] = "Tiny",
}

addEventHandler('onPlayerProjectileCreation', root,
    function(weaponType) -- tear gas bedzie dostepny jako flash, bedzie trzeba to zmodyfikowac + dodac jako allowPlayerWeapon.
        cancelEvent()
        
        local weaponName = projectileNames[weaponType] or 'Unknown'
		banPlayerAC(source,"Created Projectile", "onPlayerProjectileCreation: "..weaponName)
    end
)

addEventHandler("onPlayerDetonateSatchels", root, function()
    banPlayerAC(source, "Created Projectile", "onPlayerDetonateSachels")
end)


function onExplosion(explosionX, explosionY, explosionZ, explosionType)
	cancelEvent()
	local explosionPos = explosionX..", "..explosionY..", "..explosionZ
	local explosionTypeName = explosionTypes[explosionType] or "Unknown"
	local debugMsg = explosionTypeName.." explosion has occured at "..explosionPos
	-- if isElement(source) and getElementType(source) == "player" then banPlayerAC(source,"onExplosion", "onExplosion: "..debugMsg) end -- moze banowac wszystkich jak cziter zrobi eksplozje - do checku
end
addEventHandler("onExplosion", root, onExplosion)

function notifyAboutExplosion(withExplosion, player)
	cancelEvent()
	-- banPlayerAC(player,"onExplosion", "onVehicleExplode") -- moze banowac kazdego gracza, wiec tylko notyfikacja dla adminow
	local admins = exports.rp_admin:getAdmins()
	for k,v in pairs(admins) do
		exports.rp_chat:sendChatOOC(k, "[Vehicle Explode] "..getPlayerName(player).." ("..exports.rp_utils:getPlayerRealName(player)..") [ ID: "..exports.rp_login:getPlayerData(player,"playerID").."] poinformował serwer o eksplozji. (Nie musi być to cheater, sprawdź to, jak jest sam w aucie i event się wykonuje, to cziter)", 255, 0, 0)
	end
end

addEventHandler("onVehicleExplode", root, notifyAboutExplosion)
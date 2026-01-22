local shoots = {}
local playerCooldown = {}

local function destroyCooldown(player)
	if isElement(player) and playerCooldown[source] then playerCooldown[source] = nil end
end
addEventHandler("onPlayerWeaponFire", root,
    function(weapon, endX, endY, endZ, hitElement, startX, startY, startZ)
        if playerCooldown[source] then return end
        if not exports.rp_utils:isMelee(weapon) then
            if not shoots[source] then
                shoots[source] = 0
            end
            shoots[source] = shoots[source] + 1

            local data = {
                ["lspd"] = true,
                ["lsfd"] = false
            }

            if shoots[source] > 4 and not playerCooldown[source] then
                local location = getElementZoneName(source)
                exports.rp_groups:send911Report(source, "Usłyszałem strzały w okolicy " .. location, data)
                playerCooldown[source] = true
                setTimer(destroyCooldown, 60000, 1, source)
                shoots[source] = nil
            end
        end
    end
)



addEventHandler("onPlayerQuit", root,
	function(quitType)
		if shoots[source] then shoots[source] = nil end
		if playerCooldown[source] then playerCooldown[source] = nil end
	end
)
function playSoundInArea(player, x, y, z, interior, dimension, sound)
    local distance = 15
    local players = {}

    if isElement(player) then
        x, y, z = getElementPosition(player)
        players = exports.rp_utils:getNearbyPlayers(player, distance)
		interior = getElementInterior(player)
		dimension = getElementDimension(player)
    else
        players = exports.rp_utils:getNearbyPlayersAtPosition(x, y, z, distance, interior, dimension)
    end

    for k, v in ipairs(players) do
        triggerClientEvent(v, "onGotSoundInArea", v, sound, interior, dimension, x, y, z)
    end
end

local sounds = {}

function boomboxUse(player, url)
    local x, y, z = getElementPosition(player)
    local world = getElementDimension(player)

    if sounds[player] and isElement(sounds[player].sound) then
        stopSound(sounds[player].sound) 
    end

    local music = playSound3D(url, x, y, z)
    setElementDimension(music, world)
    setSoundMaxDistance(music, 25)
    setSoundVolume(music, 0.2)

    sounds[player] = {sound = music}
end

addEvent("onPlayerStartBoombox", true)
addEventHandler("onPlayerStartBoombox", root, boomboxUse)

function boomboxStop(player)
    if sounds[player] then
        if isElement(sounds[player].sound) then
            stopSound(sounds[player].sound)
        end
        sounds[player] = nil
    end
end

addEvent("onPlayerStopBoombox", true)
addEventHandler("onPlayerStopBoombox", root, boomboxStop)

addEventHandler("onClientRender", root, function()
    for player, data in pairs(sounds) do
        if isElement(data.sound) and isElement(player) then
            local x, y, z = getElementPosition(player)
            setElementPosition(data.sound, x, y, z)
        else
            sounds[player] = nil
        end
    end
end)

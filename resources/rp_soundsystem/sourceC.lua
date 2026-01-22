function onGotSoundInArea(sound, interior, dimension, x, y, z)
local sound = playSound3D("files/"..sound..".mp3", x, y, z, false)
setElementDimension(sound, dimension)
setElementInterior(sound, interior)
setSoundMaxDistance(sound, 30)
setSoundVolume(sound, 0.5)
end
addEvent("onGotSoundInArea", true)
addEventHandler("onGotSoundInArea", getRootElement(), onGotSoundInArea)
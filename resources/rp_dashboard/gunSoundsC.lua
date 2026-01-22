local customSoundsEnabled = false
local weaponSounds = {
		-- [0] = {"files/sounds/punch.wav", "files/sounds/pistol_reload.wav", 500}, -- 1 dzwiek, 2 reload, 3 delay.
		[22] = {"files/sounds/deaglecolt.wav", "files/sounds/pistol_reload.wav", 500}, -- 1 dzwiek, 2 reload, 3 delay.
		[23] = {"files/sounds/silenced.wav", "files/sounds/pistol_reload.wav", 500},
		[24] = {"files/sounds/onlyde.wav", "files/sounds/pistol_reload.wav", 500},
		[25] = {"files/sounds/shotgun.wav", "files/sounds/shotgun_reload.wav", 500},
		[26] = {"files/sounds/shotgun.wav", "files/sounds/shotgun_reload.wav", 1000},
		[27] = {"files/sounds/shotgun.wav", "files/sounds/shotgun_reload.wav", 1000},
		[28] = {"files/sounds/tecuzi.wav", "files/sounds/mg_clipin.wav", 1000},
		[30] = {"files/sounds/akm4.wav", "files/sounds/mg_clipin.wav", 1250},
		[29] = {"files/sounds/mp5.wav", "files/sounds/mg_clipin.wav", 1250},
		[31] = {"files/sounds/akm4.wav", "files/sounds/mg_clipin.wav", 1250},
		[32] = {"files/sounds/tecuzi.wav", "files/sounds/mg_clipin.wav", 1000},
		[34] = "sounds/weap/sniper.ogg",
}


function playGunfireSound(weaponID, ammo, ammoInClip)
    if customSoundsEnabled then
        local muzzleX, muzzleY, muzzleZ = getPedWeaponMuzzlePosition(source)
        local dim = getElementDimension(source)
        local int = getElementInterior(source)

        if weaponSounds[weaponID] then
            if ammoInClip == 0 then
                local sound = playSound3D(weaponSounds[weaponID][2], muzzleX, muzzleY, muzzleZ)
                setTimer(
                    function()
                        local relSound = playSound3D(weaponSounds[weaponID][2], muzzleX, muzzleY, muzzleZ)
                    end,weaponSounds[weaponID][3],1)
            end
            sound = playSound3D(weaponSounds[weaponID][1], muzzleX, muzzleY, muzzleZ)
            setSoundMaxDistance(sound, 90)
            setElementDimension(sound, dim)
            setElementInterior(sound, int)
            setSoundVolume(sound, 0.6)
        end
    end
end


function FistSound(attacker, weapon, bodypart)
    if customSoundsEnabled and exports.rp_utils:isMelee(weapon) then
        local x, y, z = getElementPosition(source)
        local sound = playSound3D("files/sounds/punch.wav", x, y, z)
		setElementDimension(sound, getElementDimension(source))
        setElementInterior(sound, getElementInterior(source))
    end
end

function enableCustomSounds(state)
    if state then
        addEventHandler("onClientPlayerWeaponFire", root, playGunfireSound)
        addEventHandler("onClientPlayerDamage", getRootElement(), FistSound)
    else
        if isEventHandlerAdded("onClientPlayerWeaponFire", root, playGunfireSound) then
            removeEventHandler("onClientPlayerWeaponFire", root, playGunfireSound)
            removeEventHandler("onClientPlayerDamage", getRootElement(), FistSound)
        end
    end
  
    setWorldSoundEnabled(5, not state)
    customSoundsEnabled = state
end


function isEventHandlerAdded( sEventName, pElementAttachedTo, func )
    if type( sEventName ) == 'string' and isElement( pElementAttachedTo ) and type( func ) == 'function' then
        local aAttachedFunctions = getEventHandlers( sEventName, pElementAttachedTo )
        if type( aAttachedFunctions ) == 'table' and #aAttachedFunctions > 0 then
            for i, v in ipairs( aAttachedFunctions ) do
                if v == func then
                    return true
                end
            end
        end
    end
    return false
end
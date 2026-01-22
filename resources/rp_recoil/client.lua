-- Basic recoil script

-- Script Config
local weapon_table = { -- All ticks are: ticks between weapon fire in fullauto + 50, to avoid recoil bypassing by spam clicking
    [22] = { sx_value = 0, sy_value = 2, shot_tick = 355 }, -- Colt 45
    [23] = { sx_value = 0, sy_value = 2, shot_tick = 420 }, -- Silenced
    [24] = { sx_value = 0, sy_value = 3, shot_tick = 775 }, -- Deagle
    [25] = { sx_value = 1, sy_value = 15, shot_tick = 1100 }, -- Shotgun
    [26] = { sx_value = 1, sy_value = 15, shot_tick = 350 }, -- Sawed-off
    [27] = { sx_value = 1, sy_value = 5, shot_tick = 385 }, -- Combat Shotgun
    [28] = { sx_value = 0, sy_value = 2, shot_tick = 175 }, -- Uzi
    [29] = { sx_value = 0, sy_value = 1, shot_tick = 153 }, -- MP5
    [30] = { sx_value = 0, sy_value = 2, shot_tick = 175 }, -- AK-47
    [31] = { sx_value = 0, sy_value = 2, shot_tick = 175 }, -- M4
    [32] = { sx_value = 0, sy_value = 2, shot_tick = 175 }, -- Tec-9
    [33] = { sx_value = 1, sy_value = 15, shot_tick = 150 }, -- Rifle
    [34] = { sx_value = 1, sy_value = 15, shot_tick = 150 }, -- Sniper
    ["default"] = { sx_value = 1, sy_value = 5, shot_tick = 150 } -- default recoil value
}

local recoil_strength = 1 -- multiplier for axis offsets in sprays
local recoil_strength_in_car = 0.8

-- Recoil sprays
local sprays = {
    [30] =  {-- AK-47 stage 1                 -stage 2                                               -stage 3
    ["y"] = { 6,   7,  8,  7,    5, 7, 8,    6,  4.5,  6,    5,  4.5,   6,    5, 4,    6,  4, 5,    6,  1, 1, -1, 2, 1.5, 1.2, -1, 1, -1,  1, 1.5 },
    ["x"] = { 1, 1.8, -1.5,  1.5, -1.5, 1.8, 2, -3.1, -2, -3.1, -1.5, 1.5, -3.3, 1, -2.5, -3, 1, -1.5, -2, 4,  3, 4,   3,   5,  4, 4,  5,  3, 6 }
    },
    [31] =  {-- M4 stage 1                                                     -stage 2                                                                                                       -stage 3
    ["y"] = {  3,   4,    4,   3,    2,  3,   4,    4,   3,    2,   4, 4,    3,  2,    3,  2.5, 2.3,    3, 2.5,    2,    3, 4,    3,  2,    3,  2.5, 2.3,    3, 2.5,    2,    3,   2, 2.5,  3, .5, .5, -.5, 1, 1, 1, -.5, .5, -.5, .5, 1, -.5, .5, -.5, .5, 1 },
    ["x"] = { .5, 0.9, -0.7, 0.8, -0.8, .5, 0.9, -0.7, 0.8, -0.8, 0.9, 1, -1.6, -1, -1.8, -0.9, 0.9, -1.7, 0.5, -1.5, -1.5, 1, -1.6, -1, -1.8, -0.9, 0.9, -1.7, 0.5, -1.5, -1.5, 0.8,  -1, -1,  2,  2,   2, 2, 3, 2,   3,  3,   1,  4, 2,   3,  3,   1,  4, 2 }
    },
    [29] =  {-- MP5 stage 1              -stage 2               -stage 3                                     -stage 4
    ["y"] = {  1, -1,  2,  1,  3, -1,  2, 1, -1, 2, 1, 3, -1, 2,  4,    3, 2, -1.5,   4, 3,    4, -1.5, 3,  2, 1, -1, 2, 1, 3, -1, 2 },
    ["x"] = { -2, -3, -2, -1, -4, -3, -2, 2,  3, 2, 1, 4,  3, 2, -2, -1.5, 2,   -2, 1.5, 2, -1.5,   -2, 2, -2, 2,  3, 2, 1, 4,  3, 2 }
    },
    [32] =  {-- Tec-9 stage 1                                 -stage 2                                                   -stage 3
    ["y"] = { 3, 4, 2, -1, 2, 3, 2,  4, -1, 2, 4, -1, 3, 1, 3,  3,  4,  2, -1,  2,  3,  2, 4, -1,  2,  4, -1,  3,  1,  3, 1, -1, 2, 1.5, 1.2, -1, 1, -1,  1, 1.5, 1, -1, 2, 1.5, 1.2, -1, 1, -1,  1, 1.5 },
    ["x"] = { 2, 3, 2, -1, 4, 3, 2, -1,  2, 3, 2, -1, 4, 3, 2, -2, -3, -2, -1, -4, -3, -2, 1, -2, -3, -2, -1, -4, -3, -2, 4,  3, 4,   3,   5,  4, 4,  5,  3,   6, 4,  3, 4,   3,   5,  4, 4,  5,  3, 6 }
    },
    [28] =  {-- Uzi stage 1                                 -stage 2                                                   -stage 3
    ["y"] = {  3,   4,    4,   3,    2,  3,   4,    4,   3,    2,   4, 4,    3,  2,    3,  2.5, 2.3,    3, 2.5,    2,    3, 4,    3,  2,    3,  2.5, 2.3,    3, 2.5,    2,    3,   2, 2.5,  3, .5, .5, -.5, 1, 1, 1, -.5, .5, -.5, .5, 1, -.5, .5, -.5, .5, 1 },
    ["x"] = { 1.5, 1.9, 0.3, 1.8, 0.2, 1.5, 1.9, 0.3, 1.8, 0.2, 1.9, 2, -0.6, 0, -0.8, 0.1, 1.9, -0.7, 1.5, -0.5, -0.5, 2, -0.6, 0, -0.8, 0.1, 1.9, -0.5, -0.5, -0.5, 1.8, 0, 0, 3, 3, 3, 3, 4, 3, 4, 4, 2, 5, 3, 4, 4, 2, 5, 3 }
    },
    [27] =  {-- Spaz12
    ["y"] = {  7, 8, 6,  5, 6,  8,  5 },
    ["x"] = { -3, 5, 4, -5, 4, -4, -5 }
    },
    [26] =  {-- Sawed-off
    ["y"] = { 20, 20, 20, },
    ["x"] = { 5, -6,  5, }
    },
    [24] =  {-- Deagle
    ["y"] = { 12, 10, 11,  9, 13, 11, 14 },
    ["x"] = {  5, -6,  5, -7,  5,  3, -6 }
    },
    [23] =  {-- silenced
    ["y"] = { 7,  6, 5,  7, 5, 6,  5, 7,  6, 5,  7, 5, 6,  5, 6,  7, 5 },
    ["x"] = { 3, -4, 4, -4, 3, 3, -5, 3, -4, 4, -4, 3, 3, -5, 3, -4, 4 }
    },
    [22] =  {-- Colt
    ["y"] = { 7,  6, 5,  7, 5, 6,  5, 7,  6, 5,  7, 5, 6,  5, 6,  7, 5 },
    ["x"] = { 3, -4, 4, -4, 3, 3, -5, 3, -4, 4, -4, 3, 3, -5, 3, -4, 4 }
    }
}

-- Script variables
local single_shot_weapons = { 25, 26, 27, 33, 34 }
local depth = 10000
local start, endTime, duration, sx, sy
local equipped_weapon = "default"
local sx, sy = guiGetScreenSize() -- gets players' screen size
local recoil_shoot_count = 0 -- how much bullets were shot during spray
local systemUpTime = getTickCount()
local previous_shot_tick, tick_count = 0
local shot_tick = 1000
local shooting = false

-- Script Main Function
function recoil_on_shoot(weapon, ammo, ammoInClip, hitX, hitY, hitZ, hitElement, startX, startY, startZ)
    player_shot_ticks()

    if weapon_table[weapon] ~= nil then -- checks if equipped weapon is in config, if not it gets default config
        equipped_weapon = weapon
    else
        equipped_weapon = "default"
    end

    removeEventHandler("onClientPreRender", root, interpolateCam)
    start = getTickCount()
    endTime = start + 110
    duration = endTime - start
    addEventHandler("onClientPreRender", root, interpolateCam)
end

-- Script Functions
function interpolateCam()
    local start_x, start_y, start_z = getWorldFromScreenPosition(sx/2, sy/2, depth) -- Gets the location in the world from current screen center`
    local end_x, end_y, end_z
    if not isPedInVehicle( localPlayer ) then
        if sprays[equipped_weapon] == nil or sprays[equipped_weapon]["x"][recoil_shoot_count] == nil then
            end_x, end_y, end_z = 
            getWorldFromScreenPosition(
                sx/2 + (weapon_table[equipped_weapon].sx_value * recoil_strength), 
                sy/2 - (weapon_table[equipped_weapon].sy_value * recoil_strength), 
                depth) -- adds recoil offset
        else
            end_x, end_y, end_z = 
            getWorldFromScreenPosition(
                sx/2 + (sprays[equipped_weapon]["x"][recoil_shoot_count] * recoil_strength), 
                sy/2 - (sprays[equipped_weapon]["y"][recoil_shoot_count] * recoil_strength), 
                depth) -- adds recoil offset
        end
    else
        if sprays[equipped_weapon] == nil or sprays[equipped_weapon]["x"][recoil_shoot_count] == nil then
            end_x, end_y, end_z = 
            getWorldFromScreenPosition(
                sx/2 + (weapon_table[equipped_weapon].sx_value * recoil_strength), 
                sy/2 - (weapon_table[equipped_weapon].sy_value * recoil_strength), 
                depth) -- adds recoil offset
        else
            end_x, end_y, end_z = 
            getWorldFromScreenPosition(
                sx/2 + (sprays[equipped_weapon]["x"][recoil_shoot_count] * recoil_strength), 
                sy/2 - (sprays[equipped_weapon]["y"][recoil_shoot_count] * recoil_strength), 
                depth) -- adds recoil offset
        end
    end
    local now = getTickCount()
    local elapsedTime = now - start
    local progress = elapsedTime / duration
    local ix, iy, iz = interpolateBetween(start_x, start_y, start_z, end_x, end_y, end_z, progress, "OutBack", 0, 0, 3) -- smooth recoil animation

    setCameraTarget(ix, iy, iz) -- moves the camera

    if progress >= 1 then -- if animation is completed remove clientPreRender event, and avoid infinite animation loop
        removeEventHandler("onClientPreRender", root, interpolateCam)
    end
end

function is_player_shooting() -- function that updates if player is currently shooting (fullauto)
    if (getTickCount() - previous_shot_tick) >= weapon_table[equipped_weapon].shot_tick then
        shooting = false
        recoil_shoot_count = 0
    else
        shooting = true
    end
end

function player_shot_ticks() -- function that checks if player is shooting in fullauto, and updates current shoot count, also updates ticks between weapon fires
    if shooting then
        recoil_shoot_count = recoil_shoot_count + 1
    end
    shot_tick = getTickCount()
    --print(shot_tick - previous_shot_tick) -- checking ticks between weapon fires
    previous_shot_tick = shot_tick
end

function table.contains(table, element) -- function that checks if given element is in given table
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end

addEventHandler("onClientRender", root, is_player_shooting) -- onClientRender event
addEventHandler("onClientPlayerWeaponFire", localPlayer, recoil_on_shoot) -- onShoot event

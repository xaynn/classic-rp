local weapons = {
    [22] = {
        poor = {weapon_range = 70, accuracy = 100, damage = 25, move_speed = 1},
        std = {weapon_range = 70, accuracy = 100, damage = 30, move_speed = 1},
        pro = {weapon_range = 70, accuracy = 100, damage = 35, move_speed = 1},
    },
    [23] = {
        poor = {weapon_range = 28, damage = 32, accuracy = 100},
        std = {weapon_range = 28, damage = 145, accuracy = 100, flags = 0x000020, move_speed = 1.25},
        pro = {weapon_range = 50, damage = 32, accuracy = 100},
    },
    [24] = {
        poor = {weapon_range = 30, damage = 150, move_speed = 1.2, accuracy = 100}, -- desert eagle z deva
		-- std = {weapon_range = 50, damage = 25, accuracy = 1, move_speed = 1.2, flags = 0x000020, flags = 0x000010},
		pro = {weapon_range = 30, damage = 101, accuracy = 100, move_speed = 1.23},
    },
    [25] = {
        poor = {weapon_range = 23, accuracy = 100, damage = 20, flags = 0x000020},
        std = {weapon_range = 23, accuracy = 100, damage = 30, flags = 0x000020},
        pro = {weapon_range = 23, accuracy = 100, damage = 50, flags = 0x000010},
    },
    [28] = {
        poor = {weapon_range = 35, damage = 11, accuracy = 100},
        std = {weapon_range = 35, damage = 22, accuracy = 100},
        pro = {weapon_range = 35, damage = 33, accuracy = 100},
    },
    [30] = {
        poor = {damage = 85, flags = 0x000020, accuracy = 100, weapon_range = 50},
        std = {damage = 85, accuracy = 100, weapon_range = 50},
        pro = {damage = 85, accuracy = 100, weapon_range = 50},
    },
    [31] = {
        poor = {weapon_range = 50, accuracy = 100, damage = 95, move_speed = 1},
        std = {weapon_range = 50, accuracy = 100, damage = 95, move_speed = 1},
        pro = {weapon_range = 50, accuracy = 100, damage = 95, move_speed = 1},
    },
    [32] = {
        poor = {weapon_range = 35, damage = 11, flag_type_dual = false, accuracy = 100},
        std = {weapon_range = 35, damage = 22, flag_type_dual = false, accuracy = 100},
        pro = {weapon_range = 35, damage = 33, flag_type_dual = true, accuracy = 100},
    },
}

for weaponID, styles in pairs(weapons) do
    for style, properties in pairs(styles) do
        for property, value in pairs(properties) do
            setWeaponProperty(weaponID, style, property, value)
        end
    end
end

-- setWeaponProperty(24, "poor", "flags", 0x000010)
setWeaponProperty(24, "poor", "flags", 0x000020)
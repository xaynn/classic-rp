function onPlayerUseDrug(player, drugID)
	triggerClientEvent(player,"onPlayerUseDrug",player, drugID)
end


function onPlayerSobrietyFromNarcotic()
	exports.rp_nicknames:setPlayerStatus(client, "nacpany", false)
end
addEvent("onPlayerSobrietyFromNarcotic", true)
addEventHandler("onPlayerSobrietyFromNarcotic", root, onPlayerSobrietyFromNarcotic)

-- local ped1 = createPed(20,2142.8037109375,-1202.0283203125,24.031185150146, 90, false)
-- exports.rp_login:setPlayerData(ped1, "playerID", "50")
-- exports.rp_login:setPlayerData(ped1, "visibleName", "Javonte Dorsey")


-- local ped2 = createPed(7,2143.232421875,-1200.12890625,24.050479888916, 90, false)
-- exports.rp_login:setPlayerData(ped2, "playerID", "51")
-- exports.rp_login:setPlayerData(ped2, "visibleName", "Yahir Smalls")


-- local ped3 = createPed(18,2141.6318359375,-1199.7822265625,24.034198760986, -90, false)
-- exports.rp_login:setPlayerData(ped3, "playerID", "53")
-- exports.rp_login:setPlayerData(ped3, "visibleName", "Jasiar Myres")

-- local ped4 = createPed(165,2231.78515625,-1106.2685546875,1050.8828125, -90, false)
-- exports.rp_login:setPlayerData(ped4, "playerID", "1")
-- exports.rp_login:setPlayerData(ped4, "visibleName", "Karol Nawrocki")
-- setElementDimension(ped4, 17)
-- setElementInterior(ped4, 5)
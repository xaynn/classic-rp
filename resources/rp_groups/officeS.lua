-- office, urzad, w urzedzie wyrabianie prawka jezeli gracz nie ma, wybieranie dorywczej pracy, licencje, rejestrowanie pojazdu
local ped = createPed(57, 359.6962890625,173.5576171875,1008.3893432617,-90, false)
setElementDimension(ped,1)
setElementInterior(ped,3)
setElementFrozen(ped, true)
setElementHealth(ped, 9999)


local officeBlip = createBlip(1482.2294921875,-1769.5087890625,18.795755386353, 58, 2, 0, 0, 255, 255, 0, 500)
function displayLoadedRes(res)
	exports.rp_login:setPlayerData(ped,"visibleName", "Urzędnik")
	exports.rp_login:setPlayerData(ped, "playerID", "PED")
	exports.rp_login:setPlayerData(ped,"pedType", 1) -- 1 urzednik
end

-- addEventHandler("onResourceStart", root, displayLoadedRes)

setTimer ( displayLoadedRes, 15000, 1)




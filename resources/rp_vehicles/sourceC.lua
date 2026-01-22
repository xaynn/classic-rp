local sx, sy = guiGetScreenSize()
local scaleValue = exports.rp_scale:returnScaleValue()
DGS = exports.dgs
local tmpVehicles = {}
local font = dxCreateFont('files/Helvetica.ttf', 15 * scaleValue, false, 'proof') or 'default' -- fallback to default
local menuData = {}
function handleVehicleDamage(attacker, weapon, loss, x, y, z, tire)
    if weapon and not tire then
		-- triggerServerEvent("onVehicleCheckDamage",localPlayer, source)
		triggerLatentServerEvent("onVehicleCheckDamage",1000,false,localPlayer,source)
		cancelEvent()
    end
end
addEventHandler("onClientVehicleDamage", root, handleVehicleDamage)

local sounds = {
["engine"] = "engine.wav",
["enginefailed"] = "enginefailed.wav",
["closingwindow"] = "closingwindow.wav",
["handbrake"] = "handbrake.mp3",
["lightswitch"] = "lightswitch.mp3",
["lock"] = "lock.mp3",
["blinker"] = "blinker.mp3",


}
function playVehicleSound(type)
	local sound = playSound("files/"..sounds[type])
	setSoundVolume( sound, 0.7 )
end
addEvent ( "onPlayVehicleSound", true )
addEventHandler ( "onPlayVehicleSound", root, playVehicleSound )



function vehicleMenu(vehicles)
	destroyMenu()
	tmpVehicles = vehicles
	menuData.rectanglesecond = DGS:dgsCreateRoundRect(0,false,tocolor(26,29,38,255))

    menuData.window =  exports.rp_library:createWindow("vehicleWindow", sx/2-300*scaleValue, sy/2-250*scaleValue,500*scaleValue, 500*scaleValue, "Menu pojazdów", 5, 0.55*scaleValue, true)
	-- menuData.labelSign = DGS:dgsCreateLabel(70 * scaleValue,70 * scaleValue,50 * scaleValue,50 * scaleValue,"Classic RolePlay",false,menuData.window)
	-- DGS:dgsSetProperty(menuData.labelSign,"font",font)
	-- DGS:dgsSetProperty(menuData.window,"sizable",false)
	-- iprint(vehicles)
	-- addEventHandler("onClientKey", root, destroyVehiclesMenuOnButton)
	showCursor(true)
	menuData.gridlist = exports.rp_library:createGridList("vehiclesGridList",60 * scaleValue,100 * scaleValue,360*scaleValue,200*scaleValue,menuData.window,nil,1*scaleValue)
	menuData.column = DGS:dgsGridListAddColumn( menuData.gridlist, "Nazwa pojazdu", 0.5 )
	menuData.columnID = DGS:dgsGridListAddColumn( menuData.gridlist, "ID", 0.5 )
	DGS:dgsGridListSetColumnFont(menuData.gridlist, menuData.column, "default-bold")
	DGS:dgsGridListSetColumnFont(menuData.gridlist, menuData.columnID, "default-bold")

	for k,v in pairs(vehicles) do
	local model = getVehicleData(v,"model")
	local mileage = getVehicleData(v,"mileage")
	local hp = getVehicleData(v,"hp")
	local id = getVehicleData(v,"uid")
	local vehName = getVehicleData(v,"vehicleName")
	local tuning = getVehicleData(v,"tuning")
	local row = DGS:dgsGridListAddRow ( menuData.gridlist )
	DGS:dgsGridListSetItemText ( menuData.gridlist, row, menuData.column, vehName )
	DGS:dgsGridListSetItemText ( menuData.gridlist, row, menuData.columnID, id )
	DGS:dgsGridListSetItemData ( menuData.gridlist, row, menuData.column, {id, tuning} )
	DGS:dgsGridListSetItemFont ( menuData.gridlist, row, menuData.column, "default-bold" )
	DGS:dgsGridListSetItemFont ( menuData.gridlist, row, menuData.columnID, "default-bold" )

	end
	 menuData.spawnButton = exports.rp_library:createButtonRounded("vehicle:spawnbutton",80*scaleValue,400*scaleValue,100*scaleValue,30*scaleValue,"Spawn",menuData.window,0.6*scaleValue,10)
	 menuData.shareButton = exports.rp_library:createButtonRounded("vehicle:sharebutton",180*scaleValue,400*scaleValue,100*scaleValue,30*scaleValue,"Udostępnij",menuData.window,0.6*scaleValue,10)
	 menuData.locateButton = exports.rp_library:createButtonRounded("vehicle:locatebutton",280*scaleValue,400*scaleValue,100*scaleValue,30*scaleValue,"Namierz",menuData.window,0.6*scaleValue,10)
	 menuData.tuningButton = exports.rp_library:createButtonRounded("vehicle:gettuning",180*scaleValue,365*scaleValue,100*scaleValue,30*scaleValue,"Tuning",menuData.window,0.6*scaleValue,10)

	 menuData.targetEditbox = exports.rp_library:createEditBox("vehiclesTarget:editbox", 390*scaleValue,390*scaleValue,100*scaleValue,50*scaleValue, "", menuData.window, 0.5*scaleValue, 0.7*scaleValue, 3, false, "ID gracza", false, 5) --(id,x,y,w,h,text,parent,caretHeight,textSize,maxLength,masked,placeHolder,padding,corners)
	addEventHandler("onDgsWindowClose",menuData.window,windowClosed)
	addEventHandler("onDgsMouseClick", menuData.spawnButton, onButtonSpawn)
	addEventHandler("onDgsMouseClick", menuData.shareButton, onButtonShare)
	addEventHandler("onDgsMouseClick", menuData.locateButton, onButtonLocate)
	addEventHandler("onDgsMouseClick", menuData.tuningButton, onButtonTunning)


end
addEvent ( "showVehicles", true )
addEventHandler ( "showVehicles", root, vehicleMenu )

function onButtonSpawn(button, state)
    if source == menuData.spawnButton then
        if button == "left" and state == "down" then
            local selectedRow, selectedColumn = DGS:dgsGridListGetSelectedItem(menuData.gridlist)
            if selectedRow == -1 then return exports.rp_library:createBox("Wybierz pojazd, który chcesz zespawnować") end
				local id = DGS:dgsGridListGetItemData ( menuData.gridlist, selectedRow, selectedColumn)
				triggerServerEvent("onPlayerSpawnVehicle", localPlayer, tonumber(id[1]))
        end
    end
end

local upgradeNames = {
    [1000] = "Pro Spoiler",
    [1001] = "Win Spoiler",
    [1002] = "Drag Spoiler",
    [1003] = "Alpha Spoiler",
    [1004] = "Champ Scoop",
    [1005] = "Fury Scoop",
    [1006] = "Roof Scoop",
    [1007] = "Right Sideskirt",
    [1008] = "5 times Nitro",
    [1009] = "2 times Nitro",
    [1010] = "10 times Nitro",
    [1011] = "Race Scoop",
    [1012] = "Worx Scoop",
    [1013] = "Round Fog Lamps",
    [1014] = "Champ Spoiler",
    [1015] = "Race Spoiler",
    [1016] = "Worx Spoiler",
    [1017] = "Left Sideskirt",
    [1018] = "Upswept Exhaust",
    [1019] = "Twin Exhaust",
    [1020] = "Large Exhaust",
    [1021] = "Medium Exhaust",
    [1022] = "Small Exhaust",
    [1023] = "Fury Spoiler",
    [1024] = "Square Fog Lamps",
    [1025] = "Offroad Wheels",
    [1026] = "Right Alien Sideskirt",
    [1027] = "Left Alien Sideskirt",
    [1028] = "Alien Exhaust",
    [1029] = "X-Flow Exhaust",
    [1030] = "Left X-Flow Sideskirt",
    [1031] = "Right X-Flow Sideskirt",
    [1032] = "Alien Roof Vent",
    [1033] = "X-Flow Roof Vent",
    [1034] = "Alien Exhaust",
    [1035] = "X-Flow Roof Vent",
    [1036] = "Right Alien Sideskirt",
    [1037] = "X-Flow Exhaust",
    [1038] = "Alien Roof Vent",
    [1039] = "Left X-Flow Sideskirt",
    [1040] = "Left Alien Sideskirt",
    [1041] = "Right X-Flow Sideskirt",
    [1042] = "Right Chrome Sideskirt",
    [1043] = "Slamin Exhaust",
    [1044] = "Chrome Exhaust",
    [1045] = "X-Flow Exhaust",
    [1046] = "Alien Exhaust",
    [1047] = "Right Alien Sideskirt",
    [1048] = "Right X-Flow Sideskirt",
    [1049] = "Alien Spoiler",
    [1050] = "X-Flow Spoiler",
    [1051] = "Left Alien Sideskirt",
    [1052] = "Left X-Flow Sideskirt",
    [1053] = "X-Flow Roof",
    [1054] = "Alien Roof",
    [1055] = "Alien Roof",
    [1056] = "Right Alien Sideskirt",
    [1057] = "Right X-Flow Sideskirt",
    [1058] = "Alien Spoiler",
    [1059] = "X-Flow Exhaust",
    [1060] = "X-Flow Spoiler",
    [1061] = "X-Flow Roof",
    [1062] = "Left Alien Sideskirt",
    [1063] = "Left X-Flow Sideskirt",
    [1064] = "Alien Exhaust",
    [1065] = "Alien Exhaust",
    [1066] = "X-Flow Exhaust",
    [1067] = "Alien Roof",
    [1068] = "X-Flow Roof",
    [1069] = "Right Alien Sideskirt",
    [1070] = "Right X-Flow Sideskirt",
    [1071] = "Left Alien Sideskirt",
    [1072] = "Left X-Flow Sideskirt",
    [1073] = "Shadow Wheels",
    [1074] = "Mega Wheels",
    [1075] = "Rimshine Wheels",
    [1076] = "Wires Wheels",
    [1077] = "Classic Wheels",
    [1078] = "Twist Wheels",
    [1079] = "Cutter Wheels",
    [1080] = "Switch Wheels",
    [1081] = "Grove Wheels",
    [1082] = "Import Wheels",
    [1083] = "Dollar Wheels",
    [1084] = "Trance Wheels",
    [1085] = "Atomic Wheels",
    [1086] = "Stereo",
    [1087] = "Hydraulics",
    [1088] = "Alien Roof",
    [1089] = "X-Flow Exhaust",
    [1090] = "Right Alien Sideskirt",
    [1091] = "X-Flow Roof",
    [1092] = "Alien Exhaust",
    [1093] = "Right X-Flow Sideskirt",
    [1094] = "Left Alien Sideskirt",
    [1095] = "Right X-Flow Sideskirt",
    [1096] = "Ahab Wheels",
    [1097] = "Virtual Wheels",
    [1098] = "Access Wheels",
    [1099] = "Left Chrome Sideskirt",
    [1100] = "Chrome Grill Bullbar",
    [1101] = "Left Chrome Flames Sideskirt",
    [1102] = "Left Chrome Strip Sideskirt",
    [1103] = "Covertible Roof",
    [1104] = "Chrome Exhaust",
    [1105] = "Slamin Exhaust",
    [1106] = "Right Chrome Arches",
    [1107] = "Left Chrome Strip Sideskirt",
    [1108] = "Right Chrome Strip Sideskirt",
    [1109] = "Chrome Rear Bullbars",
    [1110] = "Slamin Rear Bullbars",
    [1111] = "Little Front Sign",
    [1112] = "Little Front Sign",
    [1113] = "Chrome Exhaust",
    [1114] = "Slamin Exhaust",
    [1115] = "Chrome Front Bullbars",
    [1116] = "Slamin Front Bullbars",
    [1117] = "Chrome Front Bumper",
    [1118] = "Right Chrome Trim Sideskirt",
    [1119] = "Right Wheelcovers Sideskirt",
    [1120] = "Left Chrome Trim Sideskirt",
    [1121] = "Left Wheelcovers Sideskirt",
    [1122] = "Right Chrome Flames Sideskirt",
    [1123] = "Bullbar Chrome Bars",
    [1124] = "Left Chrome Arches Sideskirt",
    [1125] = "Bullbar Chrome Lights",
    [1126] = "Chrome Exhaust",
    [1127] = "Slamin Exhaust",
    [1128] = "Vinyl Hardtop Roof",
    [1129] = "Chrome Exhaust",
    [1130] = "Hardtop Roof",
    [1131] = "Softtop Roof",
    [1132] = "Slamin Exhaust",
    [1133] = "Right Chrome Strip Sideskirt",
    [1134] = "Right Chrome Strip Sideskirt",
    [1135] = "Slamin Exhaust",
    [1136] = "Chrome Exhaust",
    [1137] = "Left Chrome Strip Sideskirt",
    [1138] = "Alien Spoiler",
    [1139] = "X-Flow Spoiler",
    [1140] = "X-Flow Rear Bumper",
    [1141] = "Alien Rear Bumper",
    [1142] = "Left Oval Hood",
    [1143] = "Right Oval Hood",
    [1144] = "Left Square Hood",
    [1145] = "Right Square Hood",
    [1146] = "X-Flow Spoiler",
    [1147] = "Alien Spoiler",
    [1148] = "X-Flow Rear Bumper",
    [1149] = "Alien Rear Bumper",
    [1150] = "Alien Rear Bumper",
    [1151] = "X-Flow Rear Bumper",
    [1152] = "X-Flow Front Bumper",
    [1153] = "Alien Front Bumper",
    [1154] = "Alien Rear Bumper",
    [1155] = "Alien Front Bumper",
    [1156] = "X-Flow Rear Bumper",
    [1157] = "X-Flow Front Bumper",
    [1158] = "X-Flow Spoiler",
    [1159] = "Alien Rear Bumper",
    [1160] = "Alien Front Bumper",
    [1161] = "X-Flow Rear Bumper",
    [1162] = "Alien Spoiler",
    [1163] = "X-Flow Spoiler",
    [1164] = "Alien Spoiler",
    [1165] = "X-Flow Front Bumper",
    [1166] = "Alien Front Bumper",
    [1167] = "X-Flow Rear Bumper",
    [1168] = "Alien Rear Bumper",
    [1169] = "Alien Front Bumper",
    [1170] = "X-Flow Front Bumper",
    [1171] = "Alien Front Bumper",
    [1172] = "X-Flow Front Bumper",
    [1173] = "X-Flow Front Bumper",
    [1174] = "Chrome Front Bumper",
    [1175] = "Slamin Rear Bumper",
    [1176] = "Chrome Front Bumper",
    [1177] = "Slamin Rear Bumper",
    [1178] = "Slamin Rear Bumper",
    [1179] = "Chrome Front Bumper",
    [1180] = "Chrome Rear Bumper",
    [1181] = "Slamin Front Bumper",
    [1182] = "Chrome Front Bumper",
    [1183] = "Slamin Rear Bumper",
    [1184] = "Chrome Rear Bumper",
    [1185] = "Slamin Front Bumper",
    [1186] = "Slamin Rear Bumper",
    [1187] = "Chrome Rear Bumper",
    [1188] = "Slamin Front Bumper",
    [1189] = "Chrome Front Bumper",
    [1190] = "Slamin Front Bumper",
    [1191] = "Chrome Front Bumper",
    [1192] = "Chrome Rear Bumper",
    [1193] = "Slamin Rear Bumper", 
	[8001] = "Poziom 1 silnika",
	[8002] = "Poziom 2 silnika",
	[8003] = "Poziom 3 silnika"
}
function onButtonTunning(button, state)
	if source == menuData.tuningButton then
		if button == "left" and state == "down" then
		local selectedRow, selectedColumn = DGS:dgsGridListGetSelectedItem(menuData.gridlist)
            if selectedRow == -1 then return exports.rp_library:createBox("Wybierz pojazd, któremu chcesz sprawdzić tuning.") end
				local id = DGS:dgsGridListGetItemData ( menuData.gridlist, selectedRow, selectedColumn)
					outputChatBox("Ulepszenia pojazdu "..id[1]..":", 255, 255, 255)				
				for k,v in pairs(id[2]) do
					local upgrade = upgradeNames[v]
					outputChatBox(upgrade, 255, 255, 255)
				end
		end
	end
end
function onButtonShare(button, state)
    if source == menuData.shareButton then
        if button == "left" and state == "down" then
            local selectedRow, selectedColumn = DGS:dgsGridListGetSelectedItem(menuData.gridlist)
            if selectedRow == -1 then return exports.rp_library:createBox("Wybierz pojazd, który chcesz udostępnić.") end
				local id = DGS:dgsGridListGetItemData ( menuData.gridlist, selectedRow, selectedColumn)
				local target = exports.rp_library:getEditBoxText("vehiclesTarget:editbox")
				triggerServerEvent("onPlayerGiveTempKeys", localPlayer, target, tonumber(id[1]))
        end
    end
end

function onButtonLocate(button, state)
    if source == menuData.locateButton then
        if button == "left" and state == "down" then
            local selectedRow, selectedColumn = DGS:dgsGridListGetSelectedItem(menuData.gridlist)
            if selectedRow == -1 then return exports.rp_library:createBox("Wybierz pojazd, który chcesz namierzyć.") end
				local id = DGS:dgsGridListGetItemData ( menuData.gridlist, selectedRow, selectedColumn)
				triggerServerEvent("onPlayerLocateVehicle", localPlayer, tonumber(id[1]))
        end
    end
end

function windowClosed()
	setTimer(function()
		showCursor(false)
		destroyMenu()
	end,100,1)
end

function getVehicleData(tbl, key)
    if tbl[key] ~= nil then
        return tbl[key]
    else
        return nil
    end
end

function getNearestElement(player, type, distance)
    local result = false
    local dist = nil
    if player and isElement(player) then
        local elements = getElementsWithinRange(Vector3(getElementPosition(player)), distance, type, getElementInterior(player), getElementDimension(player))
        for i = 1, #elements do
            local element = elements[i]
            if not dist then
                result = element
                dist = getDistanceBetweenPoints3D(Vector3(getElementPosition(player)), Vector3(getElementPosition(element)))
            else
                local newDist = getDistanceBetweenPoints3D(Vector3(getElementPosition(player)), Vector3(getElementPosition(element)))
                if newDist <= dist then
                    result = element
                    dist = newDist
                end
            end
        end
    end
    return result
end



addEventHandler("onClientVehicleEnter",getRootElement(),function(thePlayer, seat)
        if thePlayer == localPlayer then
            setRadioChannel(0)
            if getVehicleType(source) == "BMX" and seat == 0 then
                addEventHandler("onClientRender", root, checkBikeSpeed)
            end
        end
    end
)

addEventHandler("onClientVehicleExit",getRootElement(),function(thePlayer, seat)
        if thePlayer == localPlayer then
            if getVehicleType(source) == "BMX" and seat == 0 then
                removeEventHandler("onClientRender", root, checkBikeSpeed)
            end
        end
    end
)

function destroyMenu()
 for k, v in pairs(menuData) do
        if isElement(v) then
            destroyElement(v)
        end
    end
	showCursor(false)
	-- removeEventHandler("onClientKey", root, destroyVehiclesMenuOnButton)

end



local MAX_BIKE_SPEED = 0.3


function checkBikeSpeed()
    local vehicle = getPedOccupiedVehicle(localPlayer)
    if vehicle then
        local vx, vy, vz = getElementVelocity(vehicle)
        local speed = math.sqrt(vx ^ 2 + vy ^ 2 + vz ^ 2)

        if speed > MAX_BIKE_SPEED then
            local factor = MAX_BIKE_SPEED / speed
            setElementVelocity(vehicle, vx * factor, vy * factor, vz * factor)
        end
    end
end

-- setTimer(checkBikeSpeed, 50, 0)


local seatWindows = {
	[0] = 4,
	[1] = 2,
	[2] = 5,
	[3] = 3
}


function onVehicleWindowUpdate(element, data, nowData)
    if isElement(element) and getElementType(element) == "vehicle" and isElementStreamedIn(element) then
        if data == "windows" and type(nowData) == "table" then
            for seat, window in pairs(seatWindows) do
                if nowData[seat + 1] ~= nil then
                    setVehicleWindowOpen(element, window, nowData[seat + 1])
                end
            end
        end
    end
end
addEventHandler("onLocalDataSingleElementUpdate", root, onVehicleWindowUpdate)


function onClientElementStreamIn()
    if getElementType(source) == "vehicle" then
		local source = source
        setTimer(function()
            local data = exports.rp_login:getObjectData(source, "windows")
			if not data then return end
            if type(data) == "table" then
                for seat, window in pairs(seatWindows) do
                    if data[seat + 1] ~= nil then 
                        setVehicleWindowOpen(source, window, data[seat + 1])
                    end
                end
            end
        end, 1000, 1)
    end
end
addEventHandler("onClientElementStreamIn", root, onClientElementStreamIn)

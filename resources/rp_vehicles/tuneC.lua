local tuneMenu = {}
local tuneMenuData = {}
local offSetX, offsetY = exports.rp_scale:returnOffsetXY()

DGS = exports.dgs
local scaleValue = exports.rp_scale:returnScaleValue()
local font = dxCreateFont("files/Helvetica.ttf", 10 * scaleValue, false, "proof") or "default" -- fallback to default
local lastUpgrade = false
local boughtUpgrade = false
local typeButton = false

local function destroyVehicleVisibleUpgrades()
	-- if not boughtColor then
		-- setVehicleColor(tuneMenu.tempVehicle, color1, color2, color3)
	-- end
	exports.cpicker:closePicker(tuneMenu.tempVehicle)
	if isElement(tuneMenu.colorpicker) then destroyElement(tuneMenu.colorpicker) tuneMenu.colorpicker = nil end
	if lastUpgrade == boughtUpgrade then lastUpgrade = false end

	if lastUpgrade then
		removeVehicleUpgrade ( tuneMenu.tempVehicle, lastUpgrade )
	end
	tuneMenu.tempVehicle = false
end
local function windowClosed(closedByBuy)
	tuneMenu.showed = false
	destroyVehicleVisibleUpgrades(tuneMenu.tempVehicle)
	removeEventHandler("onClientCursorMove", root, moveVehicle)
	removeEventHandler("onClientClick", root, clickOnVehicle)
	typeButton = false
	tuneMenu.colorpicker = nil
	triggerServerEvent("onPlayerCancelPreview", localPlayer)
	exports.rp_hud:initHud(true)
	setCameraTarget(localPlayer)
	removeEventHandler("onLocalDataPlayerChange", root, moneyChanged)
	destroyElement(tuneMenu.labelMoney)
	
end



local lastCursorX = nil
local isDragging = false

function startDrag()
    if isCursorShowing() then
        local x, _ = getCursorPosition()
        lastCursorX = x
        isDragging = true
    end
end

function stopDrag()
    isDragging = false
    lastCursorX = nil
end


function moveVehicle(_, _, _, _, absX)
 if isDragging and isElement(tuneMenu.tempVehicle) then
        local x, _ = getCursorPosition()
        if lastCursorX then
            local delta = (x - lastCursorX) * 300 
            lastCursorX = x
            local _, _, rz = getElementRotation(tuneMenu.tempVehicle)
            setElementRotation(tuneMenu.tempVehicle, 0, 0, rz + delta)
        end
    end
end

function onPlayerBoughtMod(mod)
	boughtUpgrade = tonumber(mod)
end
addEvent("onPlayerBoughtMod", true)
addEventHandler("onPlayerBoughtMod", root, onPlayerBoughtMod)

function clickOnVehicle(button, state, _, _, _, _, _, clickedElement)
if button == "left"  then
        if state == "down" and clickedElement == tuneMenu.tempVehicle then
            startDrag()
        else
            stopDrag()
        end
    end
end

function formatMoney(amount)
    local formatted = tostring(amount)
    formatted = formatted:reverse():gsub("(%d%d%d)", "%1 "):reverse()
    -- usuń spację na początku, jeśli jest
    if formatted:sub(1,1) == " " then
        formatted = formatted:sub(2)
    end
    return formatted
end

local function openTuneMenu(upgrades, vehicle, colors)
	if tuneMenu.showed then return end
	tuneMenu.showed = true
	triggerServerEvent("onPlayerEnterPreviewMode", localPlayer)
	triggerLatentServerEvent("onChatTyping", 5000, false, localPlayer, false)
	color1, color2, color3, color4, color5, color6, color7, color8, color9, color10, color11, color12 = getVehicleColor ( vehicle, true)
	color13, color15, color16 = colors[1], colors[2], colors[3]
	oldH, oldY, oldZ = getVehicleHeadLightColor(vehicle)
	tuneMenuData = upgrades
	tuneMenu.tempVehicle = vehicle
	tuneMenu.window = exports.rp_library:createWindow("tuneWindow", 200*scaleValue, 250*scaleValue, 400*scaleValue, 450*scaleValue, "Tuning pojazdu", 5, 0.55*scaleValue, true)
	DGS:dgsCenterElement(tuneMenu.window,true,false)
	tuneMenu.gridlist = exports.rp_library:createGridList("tuneUpgrades",20* scaleValue,20 * scaleValue,360*scaleValue,200*scaleValue,tuneMenu.window,nil,1*scaleValue)
	tuneMenu.column = DGS:dgsGridListAddColumn( tuneMenu.gridlist, "Nazwa modyfikacji", 0.5 )
	tuneMenu.columnPrice = DGS:dgsGridListAddColumn(  tuneMenu.gridlist, "Cena", 0.5 )
	DGS:dgsGridListSetColumnFont( tuneMenu.gridlist,  tuneMenu.column, font)
	DGS:dgsGridListSetColumnFont( tuneMenu.gridlist,  tuneMenu.columnPrice, font)
	addEventHandler("onDgsWindowClose",tuneMenu.window,windowClosed)
	addEventHandler("onClientCursorMove", root, moveVehicle)
	addEventHandler("onClientClick", root, clickOnVehicle)
	tuneMenu.changeColorMain = exports.rp_library:createButtonRounded("tune:changecolor",10 * scaleValue,250 * scaleValue,150 * scaleValue,30 * scaleValue,"Zmień kolor",tuneMenu.window,0.5 * scaleValue,10)
	tuneMenu.changeColorHeadlights = exports.rp_library:createButtonRounded("tune:changecolorheadlights",230 * scaleValue,250 * scaleValue,160 * scaleValue,30 * scaleValue,"Zmień kolor świateł",tuneMenu.window,0.5 * scaleValue,10)
	tuneMenu.changeColorWheels = exports.rp_library:createButtonRounded("tune:wheels",230 * scaleValue,300 * scaleValue,160 * scaleValue,30 * scaleValue,"Zmień kolor felg",tuneMenu.window,0.5 * scaleValue,10)
	tuneMenu.repairVehicle = exports.rp_library:createButtonRounded("tune:repair",100 * scaleValue,350 * scaleValue,160 * scaleValue,30 * scaleValue,"Napraw pojazd",tuneMenu.window,0.5 * scaleValue,10)
	addEventHandler("onDgsMouseClickUp", tuneMenu.changeColorMain, onButtonChangeVehicleColor)
	addEventHandler("onDgsMouseClickUp", tuneMenu.changeColorHeadlights, onButtonChangeVehicleHeadlights)
	addEventHandler("onDgsMouseClickUp", tuneMenu.changeColorWheels, onButtonChangeVehicleWheelColors)
	tuneMenu.buyMod = exports.rp_library:createButtonRounded("tune:mod",10 * scaleValue,300 * scaleValue,160 * scaleValue,30 * scaleValue,"Zakup modyfikację",tuneMenu.window,0.5 * scaleValue,10)
	addEventHandler("onDgsMouseClickUp", tuneMenu.buyMod, onButtonTryToBuyMod)
	addEventHandler("onDgsMouseClickUp", tuneMenu.repairVehicle, onButtonTryToRepair)
	local x, y = exports.rp_scale:getScreenStartPositionFromBox(100 * scaleValue, 100 * scaleValue, 0, offsetY, "center", "bottom")
	addEventHandler("onLocalDataPlayerChange", root, moneyChanged)

	tuneMenu.labelMoney = DGS:dgsCreateLabel(x,y,100*scaleValue,100*scaleValue,"Gotówka: "..formatMoney(exports.rp_login:getPlayerData(localPlayer,"money")).."$")
	DGS:dgsSetFont(tuneMenu.labelMoney, font)
	exports.rp_hud:initHud(false)

	for k,v in ipairs(tuneMenuData) do
			local row = DGS:dgsGridListAddRow(tuneMenu.gridlist) 
			DGS:dgsGridListSetItemText(tuneMenu.gridlist, row, tuneMenu.column, v.name) -- nazwa v[1], v[2] opis 
			DGS:dgsGridListSetItemText(tuneMenu.gridlist, row, tuneMenu.columnPrice, v.price)
			DGS:dgsGridListSetItemData ( tuneMenu.gridlist, row, tuneMenu.column, v )
			DGS:dgsGridListSetItemFont ( tuneMenu.gridlist, row, tuneMenu.column, font )
			DGS:dgsGridListSetItemFont ( tuneMenu.gridlist, row, tuneMenu.columnPrice, font )
	end


	 addEventHandler("onDgsMouseClick",tuneMenu.gridlist,function(button, state)
			if button ~= "left" and state ~= "down" then return end
            local selectedRow, selectedColumn = DGS:dgsGridListGetSelectedItem(tuneMenu.gridlist)
            if selectedRow ~= -1 then
                local data = DGS:dgsGridListGetItemData(tuneMenu.gridlist, selectedRow, selectedColumn)
				if lastUpgrade == boughtUpgrade then lastUpgrade = false end
				if lastUpgrade then removeVehicleUpgrade ( tuneMenu.tempVehicle, lastUpgrade ) end
				if data.id == 8001 or data.id == 8002 or data.id == 8003 then return end
				lastUpgrade = data.id
				addVehicleUpgrade ( tuneMenu.tempVehicle, lastUpgrade)
				
				
            end

        end)
		

setCameraMatrix(2071.0991210938,-1831.1682128906,14.47319984436,2070.1296386719,-1831.3068847656,14.27108001709)
end
addEvent("onPlayerOpenTuneSystem", true)
addEventHandler("onPlayerOpenTuneSystem", root, openTuneMenu)

function moneyChanged(player, data, nowData)
	if player == localPlayer and data == "money" then DGS:dgsSetText(tuneMenu.labelMoney, "Gotówka: "..formatMoney(nowData).."$") end
end



function onButtonChangeVehicleColor(button)
    if source == tuneMenu.changeColorMain and button == "left" then
        if tuneMenu.tempVehicle then
            -- if tuneMenu.colorpicker then
                -- return 
            -- end
			typeButton = 1 
            tuneMenu.colorpicker = exports.cpicker:openPicker(tuneMenu.tempVehicle, "#FFAA00", "Wybierz kolor pojazdu") --DGS:dgsCreateColorPicker("HSLSquare",50,250,200,200,false)
            -- DGS:dgsCenterElement(tuneMenu.colorpicker, false, true)
        -- triggerServerEvent("onPlayerChangeVehicleColor", localPlayer, )
        end
    end
end

function onButtonChangeVehicleHeadlights(button)
	if source == tuneMenu.changeColorHeadlights and button == "left" then
	-- if tuneMenu.colorpicker then
                -- return 
            -- end
		typeButton = 2
            tuneMenu.colorpicker = exports.cpicker:openPicker(tuneMenu.tempVehicle, "#FFAA00", "Wybierz kolor swiateł")
	end
end

function onButtonChangeVehicleWheelColors(button)
	if source == tuneMenu.changeColorWheels and button == "left" then
	-- if tuneMenu.colorpicker then
				if not hasCustomWheels(tuneMenu.tempVehicle) then return exports.rp_library:createBox("Musisz zakupić felgi, aby zmienić ich kolor.") end

                -- return 
            -- end
		typeButton = 3
            tuneMenu.colorpicker = exports.cpicker:openPicker(tuneMenu.tempVehicle, "#FFAA00", "Wybierz kolor felg")
	end
end

function onButtonTryToBuyMod(button)
	if source == tuneMenu.buyMod and button == "left" then
            local selectedRow, selectedColumn = DGS:dgsGridListGetSelectedItem(tuneMenu.gridlist)
            if selectedRow ~= -1 then
                local data = DGS:dgsGridListGetItemData(tuneMenu.gridlist, selectedRow, selectedColumn)
				triggerServerEvent("onPlayerTuneVehicle", localPlayer, data.id)
            end
	end
end

function onButtonTryToRepair(button)
	if source == tuneMenu.repairVehicle and button == "left" then
				triggerServerEvent("onPlayerRepairVehicle", localPlayer)
	end
end




local customWheels = {
    [1073] = true, [1074] = true, [1075] = true, [1076] = true,
    [1077] = true, [1078] = true, [1079] = true, [1080] = true,
    [1081] = true, [1082] = true, [1083] = true, [1084] = true,
    [1085] = true, [1096] = true, [1097] = true, [1098] = true
}

function hasCustomWheels(vehicle)
    local upgrades = getVehicleUpgrades(vehicle)
    for _, upgrade in ipairs(upgrades) do
        if customWheels[upgrade] then
            return true -- ma customowe felgi
        end
    end
    return false -- ma defaultowe
end

addEventHandler(
    "onColorPickerChange",
    root,
    function(element, hex, r, g, b)
        if tuneMenu.colorpicker then
            if typeButton == 1 then
                setVehicleColor(element, r, g, b)
            elseif typeButton == 2 then
                setVehicleHeadLightColor(element, r, g, b)
			elseif typeButton == 3 then
			-- setVehicleColor(element, color1, color2, color3, 0, 0, r, g, b, 0, 0, 0, 0, color13, color14, color15)
			setVehicleColor(element, color1, color2, color3, 0, 0, 0, r, g, b, 0, 0, 0, color13, color14, color15)
            end
        end
    end
)
addEventHandler(
    "onColorPickerOK",
    root,
    function(element, hex, r, g, b)
        if tuneMenu.colorpicker then
            if not tuneMenu.tempVehicle then
                return 
            end
            if typeButton == 1 then
                triggerServerEvent("onPlayerChangeVehicleColor", localPlayer, tonumber(r), tonumber(g), tonumber(b)) -- veh po serwerze
            elseif typeButton == 2 then
                triggerServerEvent("onPlayerChangeVehicleColor", localPlayer, tonumber(r), tonumber(g), tonumber(b), true) -- veh po serwerze
			elseif typeButton == 3 then
				triggerServerEvent("onPlayerChangeVehicleColor", localPlayer, tonumber(r), tonumber(g), tonumber(b), nil, true) -- veh po serwerze
            end
        end
		-- exports.cpicker:closePicker(tuneMenu.tempVehicle)
		-- tuneMenu.colorpicker = nil
    end
)

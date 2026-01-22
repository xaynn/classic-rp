local sx,sy = guiGetScreenSize()
local scaleValue = exports.rp_scale:returnScaleValue()
DGS = exports.dgs


-- local font = dxCreateFont("files/Helvetica.ttf", 15 * scaleValue, false, "proof") or "default" -- fallback to default
local offsetX, offsetY = exports.rp_scale:returnOffsetXY()

local carshopGui = {}
local carshopGuiElements = {}
local tempPrice = false
local tempCarID = false
local tempCategory = "Sportowe"
carshopGuiElements.x, carshopGuiElements.y = exports.rp_scale:getScreenStartPositionFromBox(400*scaleValue, 400*scaleValue, offSetX, 0, "left", "center")
carshopGuiElements.sX, carshopGuiElements.sY = exports.rp_scale:getScreenStartPositionFromBox(300*scaleValue, 25*scaleValue, 0, offsetY, "center", "bottom")
carshopGuiElements.labelX, carshopGuiElements.labelY = exports.rp_scale:getScreenStartPositionFromBox(50*scaleValue, 50*scaleValue, 0, offsetY, "center", "top")
local function windowClosed()
	if isElement(carshopGuiElements.window) then
		showCursor(false)
		carshopGui = {}
		carshopGui.showed = false
		exports.rp_hud:initHud(true)
		-- unbindKey( "c", "down", toggleCursor)
		showChat(true)
		triggerServerEvent("onPlayerLeaveCarShop", localPlayer)
		if isElement(carshopGuiElements.tempCar) then
		destroyElement(carshopGuiElements.tempCar)
		destroyElement(carshopGuiElements.carSelector)
		destroyElement(carshopGuiElements.label)
		removeEventHandler ( "onDgsMouseClickUp", root, onChangeCategory )
		removeEventHandler("onClientCursorMove", root, moveVehicle)
		removeEventHandler("onClientClick", root, clickOnVehicle)

		exports.rp_admin:setCustomCameraTarget(false)
		-- destroyElement(carshopGuiElements.changeViewAngle)
		end
		
	end
end

function toggleCursor(key, state)
    local cursorState = isCursorShowing() -- Retrieve the state of the player's cursor
    local cursorStateOpposite = not cursorState -- The logical opposite of the cursor state

    showCursor(cursorStateOpposite) -- Setting the new cursor state
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
 if isDragging and isElement(carshopGuiElements.tempCar) then
        local x, _ = getCursorPosition()
        if lastCursorX then
            local delta = (x - lastCursorX) * 300 -- czułość, możesz zmniejszyć np. do 150
            lastCursorX = x
            local _, _, rz = getElementRotation(carshopGuiElements.tempCar)
            setElementRotation(carshopGuiElements.tempCar, 0, 0, rz + delta)
        end
    end
end




function clickOnVehicle(button, state)
if button == "left" then
        if state == "down" then
            startDrag()
        else
            stopDrag()
        end
    end
end

function openCarShop(data, dim)
    if carshopGui.showed then return end
    carshopGui.showed = true
    carshopGui.table = data

    carshopGuiElements.window = exports.rp_library:createWindow("carshopGui", carshopGuiElements.x, carshopGuiElements.y, 400 * scaleValue, 400 * scaleValue, "Kategorie pojazdy", 5, 0.55 * scaleValue)
    addEventHandler("onDgsWindowClose", carshopGuiElements.window, windowClosed)
	addEventHandler("onClientCursorMove", root, moveVehicle)
	addEventHandler("onClientClick", root, clickOnVehicle)
    -- showCursor(true)
    exports.rp_hud:initHud(false)
	carshopGuiElements.label = DGS:dgsCreateLabel(carshopGuiElements.labelX, carshopGuiElements.labelY, carshopGuiElements.labelX, carshopGuiElements.labelY, "Cena pojazdu: ")
	DGS:dgsSetProperty(carshopGuiElements.label,"font","default-bold")

    carshopGuiElements.tempCar = exports.rp_newmodels:createVehicle(560, 1984.091796875, -2063.5634765625, 13.084051132202, 0, 0, 0)--createVehicle(560, 1984.091796875, -2063.5634765625, 13.084051132202, 0, 0, 0, "BRAK")
	setElementAlpha(carshopGuiElements.tempCar, 0)
    setElementDimension(carshopGuiElements.tempCar, dim)

    carshopGuiElements.carSelector = DGS:dgsCreateSelector(carshopGuiElements.sX, carshopGuiElements.sY, 300 * scaleValue, 25 * scaleValue)
	-- carshopGuiElements.gridlist = exports.rp_library:createGridList("carshop:gridlist", 5*scaleValue, 5*scaleValue, 380*scaleValue, 300*scaleValue, carshopGuiElements.window)

    local offsetX, offsetY, offsetZ = -5, 0, 2 
    local camX, camY, camZ = getPositionFromElementOffset(carshopGuiElements.tempCar, offsetX, offsetY, offsetZ)

    local lookOffsetX, lookOffsetY, lookOffsetZ = 0, 0, 1 
    local lookX, lookY, lookZ = getPositionFromElementOffset(carshopGuiElements.tempCar, lookOffsetX, lookOffsetY, lookOffsetZ)

    setCameraMatrix(camX, camY, camZ, lookX, lookY, lookZ)
	carshopGuiElements.buttons = {}
    -- for k, v in pairs(carshopGui.table) do
        -- column = DGS:dgsGridListAddColumn(carshopGuiElements.gridlist, k, 0.5)
        -- DGS:dgsGridListSetColumnFont(carshopGuiElements.gridlist, column, "default-bold")

            -- local row = DGS:dgsGridListAddRow(carshopGuiElements.gridlist)
            -- DGS:dgsGridListSetItemFont(carshopGuiElements.gridlist, row, column, "default-bold")
            -- DGS:dgsGridListSetItemText(carshopGuiElements.gridlist, row, column, vehicle.name)
    -- end

	carshopGuiElements.buyButton = exports.rp_library:createButtonRounded("carshop:buyButton",20*scaleValue,330*scaleValue,140*scaleValue,30*scaleValue,"Kup pojazd",carshopGuiElements.window,0.6*scaleValue,10)
	carshopGuiElements.scroll = DGS:dgsCreateScrollPane(5* scaleValue, 5* scaleValue, 380 * scaleValue, 300 * scaleValue, false, carshopGuiElements.window)
	carshopGuiElements.offset = 6
		addEventHandler ( "onDgsMouseClickUp",carshopGuiElements.buyButton,onBuyCar )

		for k,v in pairs(carshopGui.table) do
		carshopGuiElements.buttons[k] = exports.rp_library:createButtonRounded("carshop:button"..k,140*scaleValue,carshopGuiElements.offset,160*scaleValue,30*scaleValue,k,carshopGuiElements.scroll,0.6*scaleValue,10)
		carshopGuiElements.offset = carshopGuiElements.offset + 50
	end
	    addEventHandler ( "onDgsMouseClickUp", root, onChangeCategory )

    for k, v in pairs(carshopGui.table[tempCategory]) do
        local id = v.id
        DGS:dgsSelectorAddItem(carshopGuiElements.carSelector, id)
    end

    addEventHandler("onDgsSelectorSelect", carshopGuiElements.carSelector, onSelected)

	-- bindKey( "c", "down", toggleCursor)
    showChat(false)
end
addEvent("onPlayerOpenCarShop", true)
addEventHandler("onPlayerOpenCarShop", root, openCarShop)

function onBuyCar()
    if source == carshopGuiElements.buyButton then
        triggerServerEvent("onPlayerBuyCar", localPlayer, tempCategory, tempCarID)
    end
end


function onChangeCategory(button)
	
    for k, v in pairs(carshopGuiElements.buttons) do
        if source == v then 
         	setElementAlpha(carshopGuiElements.tempCar, 255)

            tempCategory = k 
            exports.rp_library:createBox("Zmieniono kategorię pojazdów na: "..k)
	
            DGS:dgsSelectorClear(carshopGuiElements.carSelector) 
			local firstID = false
            for _, vehicle in pairs(carshopGui.table[k]) do
				if not firstID then
					firstID = vehicle.id
					tempCarID = firstID
				exports.rp_newmodels:setElementModel(carshopGuiElements.tempCar, tonumber(firstID))
				exports.rp_admin:setCustomCameraTarget(carshopGuiElements.tempCar)
				DGS:dgsSetText(carshopGuiElements.label, "Cena pojazdu: " .. vehicle.price.."$ \n Nazwa: "..vehicle.name) 
				end
                DGS:dgsSelectorAddItem(carshopGuiElements.carSelector, vehicle.id)  
            end
            break
        end
    end
end

function getPositionFromElementOffset(element,offX,offY,offZ)
    local m = getElementMatrix ( element )  -- Get the matrix
    local x = offX * m[1][1] + offY * m[2][1] + offZ * m[3][1] + m[4][1]  -- Apply transform
    local y = offX * m[1][2] + offY * m[2][2] + offZ * m[3][2] + m[4][2]
    local z = offX * m[1][3] + offY * m[2][3] + offZ * m[3][3] + m[4][3]
    return x, y, z                               -- Return the transformed point
end
function getMatrixLeft(m)
    return m[1][1], m[1][2], m[1][3]
end
function getMatrixForward(m)
    return m[2][1], m[2][2], m[2][3]
end
function getMatrixUp(m)
    return m[3][1], m[3][2], m[3][3]
end
function getMatrixPosition(m)
    return m[4][1], m[4][2], m[4][3]
end
function onSelected(current, previous)
    local carID = DGS:dgsSelectorGetItemText(carshopGuiElements.carSelector, current)
    exports.rp_newmodels:setElementModel(carshopGuiElements.tempCar, tonumber(carID))
	-- setElementModel(carshopGuiElements.tempCar, carID)
	setElementAlpha(carshopGuiElements.tempCar, 255)
	local name
    local price
    for k, v in pairs(carshopGui.table[tempCategory]) do
        if tonumber(carID) == tonumber(v.id) then
            price = v.price
			name = v.name
			tempCarID = v.id
        end
    end
    DGS:dgsSetText(carshopGuiElements.label, "Cena pojazdu: " .. price.."$ \n Nazwa: "..name) 
end


setOcclusionsEnabled( false )


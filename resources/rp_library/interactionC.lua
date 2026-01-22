local offset = 0
local interactionsShowed = false
local tableToLoop = false
local selectedType = false
local scaleValue = exports.rp_scale:returnScaleValue()
local offSetX, offsetY = exports.rp_scale:returnOffsetXY()
local interactionX, interactionY = exports.rp_scale:getScreenStartPositionFromBox(1*scaleValue, 1*scaleValue, 0, offsetY, "center", "bottom") 
local font = dxCreateFont('Helvetica.ttf', 10 * scaleValue, true, 'proof')
local cursorX, cursorY
local selectedElement, selectedType, interactionsShowed = nil, nil, false
local buttonWidth, buttonHeight = 200 * scaleValue, 30 * scaleValue 
local buttonSpacing = 5 * scaleValue 
local buttons = {}
local allowed = false

local playerInteractions = {
    [1] = "Pocałunek",
    [2] = "Przytul",
    [3] = "Podaj rękę",
    [4] = "VCARD",
    [5] = "UNAFK",
}

local vehicleInteractions = {
    [1] = "Otwórz/zamknij pojazd",
    [2] = "Otwórz/zamknij bagażnik",
    [3] = "Otwórz/zamknij maskę"
}

local thiefInteraction = {
	[1] = "Zacznij pracę",
}

local fishermanInteraction = {
	[1] = "Sprzedaj ryby",
}

local pedInteractions = {
    [1] = "Zatrudnij się",
    [2] = "Wyrób licencję kierowcy",
	[3] = "Zarejerestruj pojazd",
}

local objInteractions = {
    [1] = "Przesuń obiekt",
    [2] = "Usuń obiekt",
    -- [3] = "Wyrób ID",
}

local tblxd = {
    ["vehicle"] = vehicleInteractions,
    ["player"] = playerInteractions,
    ["ped"] = pedInteractions,
    -- ["object"] = objInteractions,
}

local actualType = false

function enableInteractionMenu(state, type)
    if state then
        actualType = type
        buttons = {}
        for i = 1, #type do
            local buttonX = cursorX
            local buttonY = cursorY + (i - 1) * (buttonHeight + buttonSpacing)
            table.insert(buttons, {x = buttonX, y = buttonY, width = buttonWidth, height = buttonHeight, text = type[i], id = i})
        end
        addEventHandler("onClientRender", root, renderInteractionMenu)
        addEventHandler("onClientClick", root, handleButtonClick)
        interactionsShowed = true
    else
        removeEventHandler("onClientRender", root, renderInteractionMenu)
        removeEventHandler("onClientClick", root, handleButtonClick)
        interactionsShowed = false
        buttons = {}
		showCursor(false)
    end
end

function renderInteractionMenu()
    for _, button in ipairs(buttons) do
        dxDrawRectangle(button.x, button.y, button.width, button.height, tocolor(0, 0, 0, 220))
		dxDrawText(button.text, button.x, button.y, button.x + button.width, button.y + button.height, tocolor(255, 255, 255, 255), 1, font, "center", "center")
			 end
end

function handleButtonClick(button, state, absoluteX, absoluteY)
    if button == "left" and state == "down" then
        for _, button in ipairs(buttons) do
            if absoluteX >= button.x and absoluteX <= button.x + button.width and
               absoluteY >= button.y and absoluteY <= button.y + button.height then
                executeInteraction(button.id)
                enableInteractionMenu(false)
				allowed = false
                break
            end
        end
    end
end

function executeInteraction(id)
    if not actualType or not selectedElement then return end
    local action = actualType[id]
	triggerServerEvent("onPlayerInteract", localPlayer, action, selectedElement)
end

function interactionsclickObject(button, state, absoluteX, absoluteY, worldX, worldY, worldZ, clickedElement)
    if button == "left" and state == "up" and clickedElement and not interactionsShowed and allowed then
        local distance = exports.rp_utils:getDistanceBetweenElements(localPlayer, clickedElement)
        if distance > 5 then return end

        local elementType = getElementType(clickedElement)
        if clickedElement == localPlayer then return end

        local tableToLoop = tblxd[elementType]
        if tableToLoop then
            local pedData = exports.rp_login:getPlayerData(clickedElement, "pedType")
            if elementType == "ped" and (not pedData or pedData == "") then return end

            if elementType == "ped" and pedData == 2 then
                tableToLoop = thiefInteraction -- praca
				elseif elementType == "ped" and pedData == 3 then
				tableToLoop = fishermanInteraction
            end
				
                cursorX, cursorY = absoluteX, absoluteY
                enableInteractionMenu(true, tableToLoop)
				selectedElement = clickedElement
        end
    end
end

addEventHandler("onClientClick", root, interactionsclickObject)


bindKey("x", "down", function()
    showCursor(not isCursorShowing())
	if isCursorShowing() then
	allowed = true
	else
	allowed = false
	end
end)


function WindowFlashing()
setTimer(setWindowFlashing, 1000, 1, true, 10)
end
addEvent( "SetWindowFlashing", true )
addEventHandler( "setWindowFlashing", getRootElement(), WindowFlashing )

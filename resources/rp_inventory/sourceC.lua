DGS = exports.dgs
local scaleValue = exports.rp_scale:returnScaleValue()
local sx, sy = guiGetScreenSize()
inventory = {}
inventoryGui = {}
local dividing = false
tempItems = {}
createdButtons = false
givingToPlayerItem = false

local firstItemType = false
local offset_roll = 0
function dxDrawRoundedRectangle(x, y, width, height, radius, color, postGUI, subPixelPositioning)
    dxDrawRectangle(x+radius, y+radius, width-(radius*2), height-(radius*2), color, postGUI, subPixelPositioning)
    dxDrawCircle(x+radius, y+radius, radius, 180, 270, color, color, 16, 1, postGUI)
    dxDrawCircle(x+radius, (y+height)-radius, radius, 90, 180, color, color, 16, 1, postGUI)
    dxDrawCircle((x+width)-radius, (y+height)-radius, radius, 0, 90, color, color, 16, 1, postGUI)
    dxDrawCircle((x+width)-radius, y+radius, radius, 270, 360, color, color, 16, 1, postGUI)
    dxDrawRectangle(x, y+radius, radius, height-(radius*2), color, postGUI, subPixelPositioning)
    dxDrawRectangle(x+radius, y+height-radius, width-(radius*2), radius, color, postGUI, subPixelPositioning)
    dxDrawRectangle(x+width-radius, y+radius, radius, height-(radius*2), color, postGUI, subPixelPositioning)
    dxDrawRectangle(x+radius, y, width-(radius*2), radius, color, postGUI, subPixelPositioning)
end

--[[
aktualizowanie  ekwipunku, uzywanie, dzielenie przedmiotow -https://www.youtube.com/watch?v=zgMRUanRN4U&t=279s, context menu
]]


function getUsedTypeItem(itemType, ignoreCurrent)
    if not inventory then
        return false
    end

    for _, item in pairs(inventory) do
        if ignoreCurrent and item == ignoreCurrent then
        else
            if item.using and tonumber(item.itemType) == tonumber(itemType) then
                return true
            end
        end
    end

    return false
end


local renderTarget = dxCreateRenderTarget(525*scaleValue, 400*scaleValue, true) -- Create a render target

function renderInventory()
    dxDrawRoundedRectangle(sx / 2 - 250 * scaleValue, sy / 2 - 200 * scaleValue, 525 * scaleValue, 400 * scaleValue, 5, tocolor(19, 23, 24, 255), false, true)
	if not dividing and not givingToPlayerItem then
    dxDrawImage(sx / 2 - 250 * scaleValue, sy / 2 - 180 * scaleValue, 525 * scaleValue, 400 * scaleValue, renderTarget)
	end
	if calculateItems() <= 0 then 
	dxDrawText("Nie posiadasz przedmiotów w ekwipunku", sx / 2, sy / 2 ,sx / 2, sy / 2 , tocolor(255, 255, 255, 255), 1 * scaleValue, "default-bold", "center", "top", false, true)
	end
	
	if dividing then
		dxDrawText("Wpisz ilość, aby podzielić przedmiot, lub naciśnij ESC aby wyjść.", sx / 2, sy / 2 - 100 * scaleValue,sx / 2, sy / 2 - 100 * scaleValue, tocolor(255, 255, 255, 255), 1 * scaleValue, "default-bold", "center", "top", false, true)
		elseif givingToPlayerItem then
		dxDrawText("Podaj ID gracza do którego chcesz podać przedmiot.", sx / 2, sy / 2 - 100 * scaleValue,sx / 2, sy / 2 - 100 * scaleValue, tocolor(255, 255, 255, 255), 1 * scaleValue, "default-bold", "center", "top", false, true)
	end
	
    if inventoryGui.renderInfo then
        dxDrawRoundedRectangle(sx / 2 + 300 * scaleValue, sy / 2 - 200 * scaleValue, 200 * scaleValue, 200 * scaleValue, 5, tocolor(19, 23, 24, 255), false, true)
        dxDrawText("Nazwa przedmiotu: " .. inventoryGui.data[4] .. " \nIlość: " .. inventoryGui.data[1], sx / 2 + 302 * scaleValue, sy / 2 - 200 * scaleValue, sx / 2 + 300 + 200 * scaleValue, sy / 2 - 200 * scaleValue, tocolor(255, 255, 255, 255), 1 * scaleValue, "default-bold", "left", "top", false, true)
    end

	if not dividing and not givingToPlayerItem then
	for j = 1, math.min(calculateItems(), 8) do

    for i = 1, 4 do
        local offset = ((i - 1) * 22)
        local offsetHeight = ((j - 1) * 50)
        offset = offset * scaleValue
        offsetHeight = offsetHeight * scaleValue
        local itemX = sx / 2 + 170 * scaleValue + offset
        local itemY = sy / 2 - 183 * scaleValue
        local itemWidth = 20 * scaleValue
        local itemHeight = 20 * scaleValue

        -- dxDrawRectangle(itemX, itemY+offsetHeight, itemWidth, itemHeight, tocolor(255, 0, 0, 50))

        if isMouseIn(itemX, itemY+offsetHeight, itemWidth, itemHeight) then
            dxDrawRoundedRectangle(sx / 2 + 170 * scaleValue, itemY + 20 * scaleValue + offsetHeight, 85*scaleValue, 25*scaleValue, 5, tocolor(31, 37, 39, 255), false, true)

            local text
            if i == 1 then
                text = "Użyj"
            elseif i == 2 then
                text = "Podziel"
            elseif i == 3 then
                text = "Daj"
            elseif i == 4 then
                text = "Wyrzuć"
            end

            dxDrawText(text, sx / 2 + 215 * scaleValue, itemY + 23 * scaleValue + offsetHeight, sx / 2 + 215 * scaleValue, itemY + 25 * scaleValue, tocolor(255, 255, 255, 255), 1 * scaleValue, "default-bold", "center", "top", false, true)
        end
    end
	end
end

    -- for i = 1, #inventory do
    -- local offset = 0
    -- local itemX = sx / 2 - 250 * scaleValue + 420 * scaleValue
    -- local itemY = sy / 2 - 183 * scaleValue + offset
    -- local itemWidth = 20 * scaleValue -- Zakładana szerokość nazwy
    -- local itemHeight = 20 * scaleValue -- Wysokość wiersza
    -- dxDrawRectangle(itemX, itemY, itemWidth, itemHeight, tocolor(255,0,0,255), true)
    -- print("elo")
    -- end
end

function loadInventory(data)
	if inventoryGui.showed then return destroyEQ(), escapeButton("escape", true) end
	inventoryGui.showed = true
	sortedInventory = {}
	-- inventoryGui.window = exports.rp_library:createWindow("inventory", sx/2-250*scaleValue, sy/2-200*scaleValue, 525*scaleValue, 400*scaleValue, "Ekwipunek", 5, 0.55*scaleValue) -- 525, 400
	-- addEventHandler("onDgsWindowClose",inventoryGui.window,windowClosed)
	addEventHandler("onClientRender",root,renderInventory)

	showCursor(true)
	inventory = data
	updateRenderTarget()
	addEventHandler("onClientClick", root, checkClickOnItem)
	-- table.sort(inventory, function(a, b) return a.id < b.id end)
	-- iprint(inventory)
	
end
addEvent("onPlayerOpenInventory", true)
addEventHandler("onPlayerOpenInventory", root, loadInventory)

function calculateItems()
    local items = 0
    for k, v in pairs(inventory) do
        items = items + 1
    end

    return items
end

function inventoryScroll(button, state)
    if inventoryGui.showed and state then
		local items = calculateItems()
        local maxScroll = (items * 50 * scaleValue) - (400 * scaleValue)  -- Max scroll to the bottom
		
        if button == "mouse_wheel_down" and offset_roll < maxScroll then
            offset_roll = offset_roll + 50 * scaleValue  -- Stała wysokość linii
        elseif button == "mouse_wheel_up" and offset_roll > 0 then
            offset_roll = offset_roll - 50 * scaleValue  -- Stała wysokość linii
        end
        updateRenderTarget()
    end
end
bindKey("mouse_wheel_down", "down", inventoryScroll)
bindKey("mouse_wheel_up", "down",inventoryScroll)

function updateRenderTarget()
	local offset = 0
    dxSetRenderTarget(renderTarget, true)
    dxSetBlendMode("modulate_add")

    local maxItems = calculateItems()
    if offset_roll > maxItems * 50 * scaleValue then
        offset_roll = maxItems * 50 * scaleValue  
    end
	-- iprint(maxItems)
 local sortedInventory = {}
    for _, v in pairs(inventory) do
        table.insert(sortedInventory, v)
    end

    table.sort(sortedInventory, function(a, b)
        return a.id < b.id
    end)
	
    for index, v in pairs(sortedInventory) do
        -- local yPosition = (index - 1) * 25 * scaleValue - offset_roll
		if v.using then
        dxDrawText(v.name.." (UID: "..v.id..") Ilość: "..v.itemCount, 25 * scaleValue, offset - offset_roll, 25 * scaleValue, offset - offset_roll, tocolor(28, 108, 237, 255), 1 * scaleValue, "default-bold", "left", "top")
		elseif v.selectedRow then
		dxDrawText(v.name.." (UID: "..v.id..") Ilość: "..v.itemCount, 25 * scaleValue, offset - offset_roll, 25 * scaleValue, offset - offset_roll, tocolor(217, 190, 13, 255), 1 * scaleValue, "default-bold", "left", "top")
		else
		dxDrawText(v.name.." (UID: "..v.id..") Ilość: "..v.itemCount, 25 * scaleValue, offset - offset_roll, 25 * scaleValue, offset - offset_roll, tocolor(255, 255, 255, 255), 1 * scaleValue, "default-bold", "left", "top")
		end
		dxDrawImage(420 * scaleValue, offset - offset_roll, 19 * scaleValue, 14 * scaleValue, "files/icon_use.png")
		dxDrawImage(445 * scaleValue, offset - offset_roll, 14 * scaleValue, 14 * scaleValue, "files/icon_podziel.png")
		dxDrawImage(465 * scaleValue, offset - offset_roll, 18 * scaleValue, 15 * scaleValue, "files/icon_oddaj.png")
		dxDrawImage(485 * scaleValue, offset - offset_roll, 15 * scaleValue, 14 * scaleValue, "files/icon_close.png")
		
		-- offset = offset + 25 * scaleValue
		offset = offset + 50 * scaleValue

    end

    dxSetBlendMode("blend")
    dxSetRenderTarget()
end

function destroyEQ()
    -- if isElement(inventoryGui.window) then
        -- destroyElement(inventoryGui.window)
		removeEventHandler("onClientRender",root,renderInventory)
		removeEventHandler("onClientClick", root, checkClickOnItem)

		inventoryGui.showed = false
		showCursor(false)
		if createdButtons then
		createAcceptButtons(false)
		end
		
    -- end
end



function windowClosed()
	if isElement(inventoryGui.window) then
		setTimer(function()
		showCursor(false)
			destroyEQ()
	end,100,1)
	end
end

function escapeButton(button, press, state)
    if button == "escape" and press then
		cancelEvent()
        if givingToPlayerItem then
            -- escape from giving item
            givingToPlayerItem = false
            removeEventHandler("onDgsMouseClickUp", inventoryGui.giveButton, onButtonGiveItem)
            removeEventHandler("onClientKey", root, escapeButton)
            exports.rp_library:destroyButton("inventory:givebutton")
            exports.rp_library:destroyEditBox("inventory:giveEditbox")
        else
            if isElement(inventoryGui.editbox) then
                dividing = false
                removeEventHandler("onDgsMouseClickUp", inventoryGui.buttonDivide, onButtonDivide)
                removeEventHandler("onClientKey", root, escapeButton)
                exports.rp_library:destroyButton("inventory:buttondivide")
                exports.rp_library:destroyEditBox("inventory:divide")
            end
        end
    end
end


function checkClickOnItem(button, state, absoluteX, absoluteY)
    if inventoryGui.showed and button == "left" and state == "down" then
        if dividing or givingToPlayerItem then
            return
        end

        local cursorX, cursorY = absoluteX, absoluteY
        local offset = 0
        local sortedInventory = {}
        for _, v in pairs(inventory) do
            table.insert(sortedInventory, v)
        end

        table.sort(
            sortedInventory,
            function(a, b)
                return a.id < b.id
            end
        )
        for index, v in ipairs(sortedInventory) do
            local itemX = sx / 2 - 250 * scaleValue + 420 * scaleValue
            local itemY = sy / 2 - 183 * scaleValue + offset - offset_roll
            local itemWidth = 20 * scaleValue -- Zakładana szerokość nazwy
            local itemHeight = 20 * scaleValue -- Wysokość wiersza
            local itemDivideX = sx / 2 - 250 * scaleValue + 440 * scaleValue
            local giveX = sx / 2 - 250 * scaleValue + 460 * scaleValue
            local dropX = sx / 2 - 250 * scaleValue + 480 * scaleValue
            local nameX = sx / 2 - 250 * scaleValue + 25 * scaleValue
            local checkInfoX = sx / 2 - 250 * scaleValue + 25 * scaleValue
            offset = offset + 50 * scaleValue
            if cursorX >= itemX and cursorX <= itemX + itemWidth and cursorY >= itemY and cursorY <= itemY + itemHeight then
                -- updateRenderTarget()
                -- outputChatBox("Kliknięto na przedmiot: " .. v.name)
				if getUsedTypeItem(v.itemType) and not v.using then return
				exports.rp_library:createBox("Posiadasz już w użyciu ten sam typ przedmiotu.")
				end
                if v.itemType == 2 and v.var3 <= 0 then -- moze byc error
                    return exports.rp_library:createBox("Ta broń nie posiada amunicji.")
                end
                if exports.rp_bw:hasPlayerBW() then
                    return exports.rp_library:createBox("Podczas BW nie możesz używać przedmiotów.")
                end
				if v.itemType == 6 then
					return outputChatBox("Powód smierci: "..v.var2, 255, 255, 255)
				end
                local foundUsedWeapon = false
                for k, v in pairs(sortedInventory) do
                    if v.using and v.itemType == 2 then
                        foundUsedWeapon = v.id
                        break
                    end
                end
                if foundUsedWeapon and v.id ~= foundUsedWeapon and v.itemType == 2 then
                    return exports.rp_library:createBox("Posiadasz w użyciu inną broń.")
                end
				
				if v.itemType == 4 then
					local weapon = getPedWeapon(localPlayer)
					if exports.rp_utils:isMelee(weapon) or not weapon then return exports.rp_library:createBox("Wyjmij broń aby załadować magazynek.")  end
					if weapon ~= tonumber(v.var2) then return exports.rp_library:createBox("Ten magazynek nie pasuje do tej broni.") end

				end
				
                triggerServerEvent("onPlayerUseItem", localPlayer, v.id)
                -- table.remove(inventory, index)
                v.using = not v.using
                updateRenderTarget()
            elseif cursorX >= itemDivideX and cursorX <= itemDivideX + itemWidth and cursorY >= itemY and cursorY <= itemY + itemHeight then
                -- triggerServerEvent("onPlayerDivideItem", localPlayer, v.id)
                -- divideGui()
                if v.itemCount == 1 then
                    return exports.rp_library:createBox("Nie da się podzielić przedmiotu, który jest tylko 1.")
                end
                dividing = true
                inventoryGui.editbox = exports.rp_library:createEditBox("inventory:divide",sx / 2 - 100 * scaleValue,sy / 2,200 * scaleValue,50 * scaleValue,"",nil,0.5*scaleValue,1*scaleValue, 3, false, "Ilość", false, 5) --id,x,y,w,h,text,parent,caretHeight,textSize,maxLength,masked,placeHolder,padding,corners
				DGS:dgsSetPostGUI(inventoryGui.editbox, true)
                inventoryGui.buttonDivide = exports.rp_library:createButtonRounded("inventory:buttondivide",sx / 2 - 50 * scaleValue,sy / 2 + 100 * scaleValue,100 * scaleValue,30 * scaleValue,"Podziel",nil,0.6 * scaleValue,10)
				DGS:dgsSetPostGUI(inventoryGui.buttonDivide, true)
                addEventHandler("onDgsMouseClickUp", inventoryGui.buttonDivide, onButtonDivide)
                addEventHandler("onClientKey", root, escapeButton)
                inventoryGui.divideData = {v.itemCount, v.id}
            elseif cursorX >= giveX and cursorX <= giveX + itemWidth and cursorY >= itemY and cursorY <= itemY + itemHeight then
				if v.using then return exports.rp_library:createBox("Przestań używać przedmiot, aby komuś go dać.") end
				givingToPlayerItem = true
				inventoryGui.editbox = exports.rp_library:createEditBox("inventory:giveEditbox",sx / 2 - 100 * scaleValue,sy / 2,200 * scaleValue,50 * scaleValue,"",nil,0.5*scaleValue,1*scaleValue, 3, false, "ID Gracza", false, 5) --id, x, y, w, h, text, parent, bgImage, bgColor, caretHeight, textSize, maxLength, masked
				DGS:dgsSetPostGUI(inventoryGui.editbox, true)
                inventoryGui.giveButton = exports.rp_library:createButtonRounded("inventory:givebutton",sx / 2 - 50 * scaleValue,sy / 2 + 100 * scaleValue,100 * scaleValue,30 * scaleValue,"Daj",nil,0.6 * scaleValue,10)
				DGS:dgsSetPostGUI(inventoryGui.giveButton, true)
                addEventHandler("onDgsMouseClickUp", inventoryGui.giveButton, onButtonGiveItem)
                addEventHandler("onClientKey", root, escapeButton)
				inventoryGui.divideData = v.id
            elseif cursorX >= dropX and cursorX <= dropX + itemWidth and cursorY >= itemY and cursorY <= itemY + itemHeight then
                if v.using then
                    return exports.rp_library:createBox("Przestań używać przedmiot, aby go wyrzucić.")
                end
                triggerServerEvent("onPlayerDeployItem", localPlayer, v.id)
            elseif cursorX >= checkInfoX and cursorX <= checkInfoX + 180 * scaleValue and cursorY >= itemY and cursorY <= itemY + 25 * scaleValue then
                if not inventoryGui.renderInfo then
                    setTimer(renderInfoTimer, 4000, 1)
                end
                inventoryGui.renderInfo = true
                inventoryGui.data = {v.itemCount, v.itemType, v.var1, v.name}
                if getKeyState("lctrl") then
                    if firstItemType then
                        if tonumber(firstItemType) ~= tonumber(v.itemType) or tonumber(v.itemType) == 2 or v.using or tonumber(v.itemType) == 4 or tonumber(v.itemType) == 11 or tonumber(v.itemType) == 17 then
                            exports.rp_library:createBox("Przedmioty, które chcesz złączyć, nie są tego samego typu, lub jest to broń lub jest przedmiot użyty.")
                            firstItemType = false
							if createdButtons then createAcceptButtons(false) end
                            for k, v in ipairs(sortedInventory) do
                                v.selectedRow = false
                            end
                            tempItems = {} 
                        else
                            -- odznaczanie
                            if v.selectedRow then
                                v.selectedRow = false
                                for k, itemId in ipairs(tempItems) do
                                    if itemId == v.id then
                                        table.remove(tempItems, k)
                                        break
                                    end
                                end
                            else
                                -- zaznaczanie next
                                v.selectedRow = true
                                table.insert(tempItems, v.id)
								if #tempItems == 2 and not createdButtons then createAcceptButtons(true) createdButtons = true end
                            end
                        end
                    else
                        -- first zaznaczenie
						if v.itemType == 2 then return exports.rp_library:createBox("Nie da się łączyć broni.") end
                        firstItemType = v.itemType
                        v.selectedRow = true
                        table.insert(tempItems, v.id)
                    end
                end
                updateRenderTarget()
                break
            end
        end
    end
end
function createAcceptButtons(state)
    if state then
        inventoryGui.buttonCombineAccept = exports.rp_library:createButtonRounded("inventory:buttonconbineaccept",sx / 2 - 50 * scaleValue,sy / 2 + 210 * scaleValue,100 * scaleValue,30 * scaleValue,"Akceptuj",nil,0.6 * scaleValue,10)
        inventoryGui.buttonCombineDecline = exports.rp_library:createButtonRounded("inventory:buttoncombinedecline",sx / 2 - 50 * scaleValue,sy / 2 + 245 * scaleValue,100 * scaleValue,30 * scaleValue,"Anuluj",nil,0.6 * scaleValue,10)
		addEventHandler("onDgsMouseClickUp", inventoryGui.buttonCombineAccept, onButtonCombineAccept)
        addEventHandler("onDgsMouseClickUp", inventoryGui.buttonCombineDecline, onButtonCombineDecline)

    else
		exports.rp_library:destroyButton("inventory:buttonconbineaccept")
		exports.rp_library:destroyButton("inventory:buttoncombinedecline")
		createdButtons = false
		firstItemType = false
		tempItems = {}
    end
end




function renderInfoTimer()
inventoryGui.renderInfo = false
end

function refreshInventory(data)
	sortedInventory = {}
	inventory = data
	updateRenderTarget()
end

addEvent("onUpdateInventory", true)
addEventHandler("onUpdateInventory", root, refreshInventory)




addEventHandler("onClientPlayerWasted", localPlayer, function(killer, weapon, bodyPart)
		if inventoryGui.showed then return destroyEQ() end

end)


function abortAllStealthKills(targetPlayer)
    cancelEvent()
end
addEventHandler("onClientPlayerStealthKill", localPlayer, abortAllStealthKills)
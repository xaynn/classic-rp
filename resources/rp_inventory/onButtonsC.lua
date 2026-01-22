function onButtonCombineAccept(button)
    if source == inventoryGui.buttonCombineAccept then
        if button == "left" then
            triggerServerEvent("onPlayerCombineItems", localPlayer, tempItems)
			createAcceptButtons(false)
			for k, v in pairs(inventory) do
                v.selectedRow = false
            end
        end
    end
end

function onButtonCombineDecline(button)
    if source == inventoryGui.buttonCombineDecline then
        if button == "left" then
            for k, v in pairs(inventory) do
                v.selectedRow = false
            end
			updateRenderTarget()
			createAcceptButtons(false)
        end
    end
end

function onButtonDivide(button)
    if source == inventoryGui.buttonDivide then
        if button == "left" then
            local amount = exports.rp_library:getEditBoxText("inventory:divide")
            if not tonumber(amount) then
                return exports.rp_library:createBox("Wartość musi być liczbą.")
            end
            if tonumber(amount) < 0 then
                return
            end
            if tonumber(inventoryGui.divideData[1]) <= tonumber(amount) then
                return exports.rp_library:createBox("Nie możesz podzielić takiej ilości.")
            end
            triggerServerEvent("onPlayerDivideItem", localPlayer, inventoryGui.divideData[2], amount)
        end
    end
end


function onButtonGiveItem(button)
    if source == inventoryGui.giveButton then
        if button == "left" then
            local targetID = exports.rp_library:getEditBoxText("inventory:giveEditbox")
            if not tonumber(targetID) then
                return exports.rp_library:createBox("Wartość musi być liczbą.")
            end
            if tonumber(targetID) < 0 then
                return
            end

            triggerServerEvent("onPlayerGiveItem", localPlayer, targetID, inventoryGui.divideData)
        end
    end
end

function isMouseIn( x, y, width, height )
	if ( not isCursorShowing( ) ) then
		return false
	end
	local sx, sy = guiGetScreenSize ( )
	local cx, cy = getCursorPosition ( )
	local cx, cy = ( cx * sx ), ( cy * sy )
	
	return ( ( cx >= x and cx <= x + width ) and ( cy >= y and cy <= y + height ) )
end
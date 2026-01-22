function isMouseInPosition ( x, y, width, height )
	if ( not isCursorShowing( ) ) then
		return false
	end
	local sx, sy = guiGetScreenSize ( )
	local cx, cy = getCursorPosition ( )
	local cx, cy = ( cx * sx ), ( cy * sy )
	
	return ( ( cx >= x and cx <= x + width ) and ( cy >= y and cy <= y + height ) )
end

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


local editboxStatus, isValidPosition
local editboxes = {} -- Tablica przechowująca wszystkie editboxy

function dxDrawEditBox(text, startX, startY, width, height, editboxElement, textColor, maxCharacter, isPassword, font, postGUI)
    if not editboxes[editboxElement] then
        editboxes[editboxElement] = {
            text = text,
            placeholder = text,  
            state = false,
            maxCharacters = maxCharacter or 10,
            isMouseOver = false,
            hasContent = false 
        }
    end
    
    local editboxData = editboxes[editboxElement]
    local editboxText = editboxData.text
    local editboxState = editboxData.state
    local editboxCharacter = editboxData.maxCharacters

    if type(editboxText) == "boolean" then return false end

    local displayText
    if not editboxData.hasContent and not editboxState then
        displayText = editboxData.placeholder
    else
        displayText = isPassword and string.gsub(editboxText, ".", "•") or editboxText
    end

    dxDrawText(
        displayText, 
        startX, startY, width + startX, height + startY, 
        textColor or tocolor(255, 255, 255, 255/1.2), 
        1, font or "default", "center", "center", true, false, postGUI or false
    )
    
    dxDrawLine(
        startX, startY + height, width + startX, height + startY, 
        tocolor(255/3, 255/3, 255/3, editboxState and math.abs(math.sin(getTickCount() / 255) * 255) or 255), 
        1, postGUI or false
    )

    if isCursorShowing() then
        local screen, cursor = {guiGetScreenSize()}, {getCursorPosition()}
        local cx, cy = cursor[1] * screen[1], cursor[2] * screen[2]
        editboxData.isMouseOver = (cx >= startX and cx <= startX + width) and (cy >= startY and cy <= startY + height)
    end

    return true
end

local function dxDrawEditBoxClickElement(button, state)
    if (button == "left" and state == "down") then
        local clickedEditbox = false

        local function toggleStatus(element, theState)
            editboxStatus = theState
            guiSetInputEnabled(theState)
            if editboxes[element] then
                editboxes[element].state = theState
            end
        end

        for element, data in pairs(editboxes) do
            if data.isMouseOver then
                clickedEditbox = element
            elseif data.state == true then
                toggleStatus(element, false)
            end
        end

        if not clickedEditbox then return end

        if editboxes[clickedEditbox] then
            if not editboxes[clickedEditbox].state then
                toggleStatus(clickedEditbox, true)
            end
        end
    end
end
addEventHandler("onClientClick", root, dxDrawEditBoxClickElement)

local function dxDrawEditBoxCharacterElement(button)
    if editboxStatus and (not isChatBoxInputActive()) and (not isConsoleActive()) then
        for element, data in pairs(editboxes) do
            if data.state == true and #data.text < data.maxCharacters then
                data.text = data.text .. button
                data.hasContent = true 
            end
        end
    end
end
addEventHandler("onClientCharacter", root, dxDrawEditBoxCharacterElement)

local function dxDrawEditBoxKeyElement(button, press)
    if editboxStatus and (not isChatBoxInputActive()) and (not isConsoleActive()) and press and button == "backspace" then
        for element, data in pairs(editboxes) do
            if data.state == true and #data.text > 0 then
                data.text = utf8.remove(data.text, -1, -1)
                if #data.text == 0 then
                    data.hasContent = false
                end
            end
        end
    end
end
addEventHandler("onClientKey", root, dxDrawEditBoxKeyElement)

function getEditBoxText(editboxElement)
    return editboxes[editboxElement] and editboxes[editboxElement].text or ""
end

function setEditBoxText(editboxElement, text)
    if editboxes[editboxElement] then
        editboxes[editboxElement].text = tostring(text)
        editboxes[editboxElement].hasContent = (#tostring(text) > 0)  -- Ustaw flagę w zależności od długości tekstu
        return true
    end
    return false
end

function destroyEditBox(editboxElement)
    editboxes[editboxElement] = nil
end

function isEditBoxActive(editboxElement)
    return editboxes[editboxElement] and editboxes[editboxElement].state or false
end

function resetEditBox(editboxElement)
    if editboxes[editboxElement] then
        editboxes[editboxElement].text = ""
		editboxes[editboxElement].placeholder = ""
        editboxes[editboxElement].hasContent = false
        editboxes[editboxElement].state = false
        return true
    end
    return false
end
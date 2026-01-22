gui = {}

addEventHandler("onClientResourceStart", resourceRoot,
    function()
        wdwProperties = guiCreateWindow(0.03, 0.33, 0.31, 0.28, "Properties", true)
        guiWindowSetSizable(wdwProperties, false)
        guiSetAlpha(wdwProperties, 0.90)

        posLabel = guiCreateLabel(0.05, 0.19, 0.09, 0.06, "Position:", true, wdwProperties)
        rotLabel = guiCreateLabel(0.05, 0.40, 0.09, 0.06, "Rotation:", true, wdwProperties)
        sclLabel = guiCreateLabel(0.05, 0.61, 0.09, 0.06, "Scale:", true, wdwProperties)
        xPosEditBox = guiCreateEdit(0.20, 0.19, 0.14, 0.06, "0", true, wdwProperties)
        xPosLabel = guiCreateLabel(0.17, 0.19, 0.04, 0.05, "X:", true, wdwProperties)
        yPosLabel = guiCreateLabel(0.36, 0.19, 0.04, 0.05, "Y:", true, wdwProperties)
        zPosLabel = guiCreateLabel(0.56, 0.19, 0.04, 0.05, "Z:", true, wdwProperties)
        yPosEditBox = guiCreateEdit(0.40, 0.19, 0.14, 0.06, "0", true, wdwProperties)
        zPosEditBox = guiCreateEdit(0.59, 0.19, 0.14, 0.06, "0", true, wdwProperties)
        btnClose = guiCreateButton(0.34, 0.87, 0.15, 0.08, "Close", true, wdwProperties)
        btnApply = guiCreateButton(0.54, 0.87, 0.15, 0.08, "Apply", true, wdwProperties)
        btnSetPos = guiCreateButton(0.75, 0.18, 0.24, 0.10, "Set current position", true, wdwProperties)
        xRotLabel = guiCreateLabel(0.17, 0.40, 0.04, 0.05, "X:", true, wdwProperties)
        yRotLabel = guiCreateLabel(0.36, 0.40, 0.04, 0.05, "Y:", true, wdwProperties)
        xRotEditBox = guiCreateEdit(0.20, 0.40, 0.14, 0.06, "0", true, wdwProperties)
        yRotEditBox = guiCreateEdit(0.40, 0.40, 0.14, 0.06, "0", true, wdwProperties)
        zRotLabel = guiCreateLabel(0.56, 0.40, 0.04, 0.05, "Z:", true, wdwProperties)
        zRotEditBox = guiCreateEdit(0.59, 0.40, 0.14, 0.06, "0", true, wdwProperties)
        scaleEditBox = guiCreateEdit(0.16, 0.61, 0.14, 0.06, "0", true, wdwProperties)
        btnPlusXPos = guiCreateButton(0.23, 0.09, 0.04, 0.07, "+", true, wdwProperties)
        btnMinusXPos = guiCreateButton(0.28, 0.09, 0.04, 0.07, "-", true, wdwProperties)
        valYPosEdit = guiCreateEdit(0.36, 0.09, 0.06, 0.07, "1", true, wdwProperties)
        valLabel1 = guiCreateLabel(0.07, 0.09, 0.08, 0.05, "Value", true, wdwProperties)
        valXPosEdit = guiCreateEdit(0.16, 0.09, 0.06, 0.07, "1", true, wdwProperties)
        valZPosEdit = guiCreateEdit(0.55, 0.09, 0.06, 0.07, "1", true, wdwProperties)
        btnPlusYPos = guiCreateButton(0.43, 0.09, 0.04, 0.07, "+", true, wdwProperties)
        btnMinusYPos = guiCreateButton(0.48, 0.09, 0.04, 0.07, "-", true, wdwProperties)
        btnPlusZPos = guiCreateButton(0.62, 0.09, 0.04, 0.07, "+", true, wdwProperties)
        btnMinusZPos = guiCreateButton(0.67, 0.09, 0.04, 0.07, "-", true, wdwProperties)
        btnSetRot = guiCreateButton(0.75, 0.39, 0.24, 0.10, "Set current rotation", true, wdwProperties)
        btnSetScale = guiCreateButton(0.34, 0.61, 0.25, 0.09, "Set current scale", true, wdwProperties)
        valLabel2 = guiCreateLabel(0.07, 0.30, 0.08, 0.05, "Value", true, wdwProperties)
        valXRotEdit = guiCreateEdit(0.16, 0.30, 0.06, 0.07, "1", true, wdwProperties)
        btnPlusXRot = guiCreateButton(0.23, 0.30, 0.04, 0.07, "+", true, wdwProperties)
        btnMinusXRot = guiCreateButton(0.28, 0.30, 0.04, 0.07, "-", true, wdwProperties)
        valYRotEdit = guiCreateEdit(0.36, 0.30, 0.06, 0.07, "1", true, wdwProperties)
        btnPlusYRot = guiCreateButton(0.43, 0.30, 0.04, 0.07, "+", true, wdwProperties)
        btnMinusYRot = guiCreateButton(0.48, 0.30, 0.04, 0.07, "-", true, wdwProperties)
        valZRotEdit = guiCreateEdit(0.55, 0.30, 0.06, 0.07, "1", true, wdwProperties)
        btnPlusZRot = guiCreateButton(0.62, 0.30, 0.04, 0.07, "+", true, wdwProperties)
        btnMinusZRot = guiCreateButton(0.67, 0.30, 0.04, 0.07, "-", true, wdwProperties)
        valSclEdit = guiCreateEdit(0.16, 0.51, 0.06, 0.07, "1", true, wdwProperties)
        btnPlusScale = guiCreateButton(0.23, 0.51, 0.04, 0.07, "+", true, wdwProperties)
        btnMinusScale = guiCreateButton(0.28, 0.51, 0.04, 0.07, "-", true, wdwProperties)
        valLabel3 = guiCreateLabel(0.07, 0.51, 0.08, 0.05, "Value", true, wdwProperties)

        guiSetVisible(wdwProperties, false)

        addEventHandler("onClientGUIClick", btnClose, turnOffPropertiesWindow, false)
        addEventHandler("onClientGUIClick", btnApply, submitProperties, false)
        addEventHandler("onClientGUIClick", btnSetPos, getCurrentPosition, false)
        addEventHandler("onClientGUIClick", btnSetRot, getCurrentRotation, false)
        addEventHandler("onClientGUIClick", btnSetScale, getCurrentScale, false)
        addEventHandler("onClientGUIClick", btnPlusXPos, addXPos, false)
        addEventHandler("onClientGUIClick", btnMinusXPos, minusXPos, false)
        addEventHandler("onClientGUIClick", btnPlusYPos, addYPos, false)
        addEventHandler("onClientGUIClick", btnMinusYPos, minusYPos, false)
        addEventHandler("onClientGUIClick", btnPlusZPos, addZPos, false)
        addEventHandler("onClientGUIClick", btnMinusZPos, minusZPos, false)
        addEventHandler("onClientGUIClick", btnPlusXRot, addXRot, false)
        addEventHandler("onClientGUIClick", btnMinusXRot, minusXRot, false)
        addEventHandler("onClientGUIClick", btnPlusYRot, addYRot, false)
        addEventHandler("onClientGUIClick", btnMinusYRot, minusYRot, false)
        addEventHandler("onClientGUIClick", btnPlusZRot, addZRot, false)
        addEventHandler("onClientGUIClick", btnMinusZRot, minusZRot, false)
        addEventHandler("onClientGUIClick", btnPlusScale, addScale, false)
        addEventHandler("onClientGUIClick", btnMinusScale, minusScale, false)
    end
)

function turnOnPropertiesWindow()
    if (wdwProperties ~= nil) then
        guiSetVisible(wdwProperties, true)
    else
        -- if the GUI hasn't been properly created, tell the player
        outputChatBox("An unexpected error has occurred and the login GUI has not been created.")
    end 

    guiSetInputEnabled(true)
end

function turnOffPropertiesWindow()
    if (wdwProperties ~= nil) then
        guiSetVisible(wdwProperties, false)
    else
        -- if the GUI hasn't been properly created, tell the player
        outputChatBox("An unexpected error has occurred and the login GUI has not been created.")
    end 

    guiSetInputEnabled(false)
end

function submitProperties(button, state)
	if button == "left" and state == "up" then
		-- turnOffPropertiesWindow()

        --setting up selected properties
        if selectedElement then
            local x = tonumber(guiGetText(xPosEditBox))
            local y = tonumber(guiGetText(yPosEditBox))
            local z = tonumber(guiGetText(zPosEditBox))

            if x and y and z then
                setElementPosition(selectedElement, x, y, z)
            end

            x = tonumber(guiGetText(xRotEditBox))
            y = tonumber(guiGetText(yRotEditBox))
            z = tonumber(guiGetText(zRotEditBox))

            if x and y and z then
                setElementRotation(selectedElement, x, y, z)
            end

            scale = tonumber(guiGetText(scaleEditBox))

            if scale then
                setObjectScale(selectedElement, scale)
            end

            undoUpdate(false, false, selectedElement)
        end
	end
end

function getCurrentPosition(button, state)
    if button == "left" and state == "up" then
        --setting up selected properties
        if selectedElement then
            local x, y, z = getElementPosition(selectedElement)
            guiSetText ( xPosEditBox, tostring(x) )
            guiSetText ( yPosEditBox, tostring(y) )
            guiSetText ( zPosEditBox, tostring(z) )
        end
    end
end

function getCurrentRotation(button, state)
    if button == "left" and state == "up" then
        --setting up selected properties
        if selectedElement then
            local x, y, z = getElementRotation(selectedElement)
            guiSetText ( xRotEditBox, tostring(x) )
            guiSetText ( yRotEditBox, tostring(y) )
            guiSetText ( zRotEditBox, tostring(z) )
        end
    end
end

function getCurrentScale(button, state)
    if button == "left" and state == "up" then
        --setting up selected properties
        if selectedElement then
            local x, y, z = getObjectScale(selectedElement)
            guiSetText ( scaleEditBox, tostring(x) )
        end
    end
end

function addXPos(button, state)
    if button == "left" and state == "up" then
        local value = tonumber(guiGetText(valXPosEdit))
        local posValue = tonumber(guiGetText(xPosEditBox))
        if value and posValue then
            local newValue = posValue + value
            guiSetText ( xPosEditBox, newValue )
        end
    end
end

function addYPos(button, state)
    if button == "left" and state == "up" then
        local value = tonumber(guiGetText(valYPosEdit))
        local posValue = tonumber(guiGetText(yPosEditBox))
        if value and posValue then
            local newValue = posValue + value
            guiSetText ( yPosEditBox, newValue )
        end
    end
end

function addZPos(button, state)
    if button == "left" and state == "up" then
        local value = tonumber(guiGetText(valZPosEdit))
        local posValue = tonumber(guiGetText(zPosEditBox))
        if value and posValue then
            local newValue = posValue + value
            guiSetText ( zPosEditBox, newValue )
        end
    end
end

function addXRot(button, state)
    if button == "left" and state == "up" then
        local value = tonumber(guiGetText(valXRotEdit))
        local rotValue = tonumber(guiGetText(xRotEditBox))
        if value and rotValue then
            local newValue = rotValue + value
            guiSetText ( xRotEditBox, newValue )
        end
    end
end

function addYRot(button, state)
    if button == "left" and state == "up" then
        local value = tonumber(guiGetText(valYRotEdit))
        local rotValue = tonumber(guiGetText(yRotEditBox))
        if value and rotValue then
            local newValue = rotValue + value
            guiSetText ( yRotEditBox, newValue )
        end
    end
end

function addZRot(button, state)
    if button == "left" and state == "up" then
        local value = tonumber(guiGetText(valZRotEdit))
        local rotValue = tonumber(guiGetText(zRotEditBox))
        if value and rotValue then
            local newValue = rotValue + value
            guiSetText ( zRotEditBox, newValue )
        end
    end
end

function addScale(button, state)
    if button == "left" and state == "up" then
        local value = tonumber(guiGetText(valSclEdit))
        local scaleValue = tonumber(guiGetText(scaleEditBox))
        if value and scaleValue then
            local newValue = scaleValue + value
            guiSetText ( scaleEditBox, newValue )
        end
    end
end

----------------------------------------------------------------

function minusXPos(button, state)
    if button == "left" and state == "up" then
        local value = tonumber(guiGetText(valXPosEdit))
        local posValue = tonumber(guiGetText(xPosEditBox))
        if value and posValue then
            local newValue = posValue - value
            guiSetText ( xPosEditBox, newValue )
        end
    end
end

function minusYPos(button, state)
    if button == "left" and state == "up" then
        local value = tonumber(guiGetText(valYPosEdit))
        local posValue = tonumber(guiGetText(yPosEditBox))
        if value and posValue then
            local newValue = posValue - value
            guiSetText ( yPosEditBox, newValue )
        end
    end
end

function minusZPos(button, state)
    if button == "left" and state == "up" then
        local value = tonumber(guiGetText(valZPosEdit))
        local posValue = tonumber(guiGetText(zPosEditBox))
        if value and posValue then
            local newValue = posValue - value
            guiSetText ( zPosEditBox, newValue )
        end
    end
end

function minusXRot(button, state)
    if button == "left" and state == "up" then
        local value = tonumber(guiGetText(valXRotEdit))
        local rotValue = tonumber(guiGetText(xRotEditBox))
        if value and rotValue then
            local newValue = rotValue - value
            guiSetText ( xRotEditBox, newValue )
        end
    end
end

function minusYRot(button, state)
    if button == "left" and state == "up" then
        local value = tonumber(guiGetText(valYRotEdit))
        local rotValue = tonumber(guiGetText(yRotEditBox))
        if value and rotValue then
            local newValue = rotValue - value
            guiSetText ( yRotEditBox, newValue )
        end
    end
end

function minusZRot(button, state)
    if button == "left" and state == "up" then
        local value = tonumber(guiGetText(valZRotEdit))
        local rotValue = tonumber(guiGetText(zRotEditBox))
        if value and rotValue then
            local newValue = rotValue - value
            guiSetText ( zRotEditBox, newValue )
        end
    end
end

function minusScale(button, state)
    if button == "left" and state == "up" then
        local value = tonumber(guiGetText(valSclEdit))
        local scaleValue = tonumber(guiGetText(scaleEditBox))
        if value and scaleValue then
            local newValue = scaleValue - value
            guiSetText ( scaleEditBox, newValue )
        end
    end
end
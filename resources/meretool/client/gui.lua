GUIEditor = {
    checkbox = {},
    label = {},
    button = {},
    window = {},
    scrollbar = {},
    combobox = {}
}

addEventHandler("onClientResourceStart", resourceRoot,
    function()
        GUIEditor.window[1] = guiCreateWindow(1550, 354, 356, 331, ":)", false)
        centerRightWindow(GUIEditor.window[1])
        guiWindowSetSizable(GUIEditor.window[1], false)

        GUIEditor.label[1] = guiCreateLabel((356 - 183) / 2, (331 - 29) / 2, 183, 29, "Start the editor", false,
            GUIEditor.window[1])
        guiLabelSetHorizontalAlign(GUIEditor.label[1], "center", false)
        guiLabelSetVerticalAlign(GUIEditor.label[1], "center")


        GUIEditor.button[1] = guiCreateButton(14, 24, 76, 25, "Single", false, GUIEditor.window[1])

        GUIEditor.combobox[1] = guiCreateComboBox(10, 59, 268, 262, "", false, GUIEditor.window[1])
        GUIEditor.checkbox[1] = guiCreateCheckBox(10, 89, 248, 19, "Change texture pixels ( not overlay )", true, false,
            GUIEditor.window[1])
        GUIEditor.checkbox[2] = guiCreateCheckBox(20, 109, 248, 19, "Edit via image editor", false, false,
            GUIEditor.window[1])
        GUIEditor.label[2] = guiCreateLabel(75, 176, 203, 20, "██████████████████████", false, GUIEditor.window[1])
        GUIEditor.label[9] = guiCreateLabel(75, 176, 203, 20, "--------------DISABLED-------------", false,
            GUIEditor.window[1])
        guiLabelSetHorizontalAlign(GUIEditor.label[9], "center", false)
        guiLabelSetVerticalAlign(GUIEditor.label[9], "center")
        guiLabelSetColor(GUIEditor.label[2], 54, 45, 34)
        guiLabelSetHorizontalAlign(GUIEditor.label[2], "center", false)
        guiLabelSetVerticalAlign(GUIEditor.label[2], "center")
        GUIEditor.label[3] = guiCreateLabel(10, 202, 67, 22, "Threshold :-", false, GUIEditor.window[1])
        GUIEditor.scrollbar[1] = guiCreateScrollBar(77, 221, 205, 22, true, false, GUIEditor.window[1])
        GUIEditor.label[4] = guiCreateLabel(-7, 127, 356, 17,
            "------------------------------------------------------------------------------------------------", false,
            GUIEditor.window[1])
        GUIEditor.label[5] = guiCreateLabel(129, 253, 108, 23, "No data", false, GUIEditor.window[1])
        guiLabelSetHorizontalAlign(GUIEditor.label[5], "center", false)
        guiLabelSetVerticalAlign(GUIEditor.label[5], "center")
        GUIEditor.label[6] = guiCreateLabel(288, 221, 41, 15, "0", false, GUIEditor.window[1])
        guiLabelSetHorizontalAlign(GUIEditor.label[6], "center", false)
        guiLabelSetVerticalAlign(GUIEditor.label[6], "center")
        GUIEditor.button[2] = guiCreateButton(5, 290, 82, 24, "Apply", false, GUIEditor.window[1])
        GUIEditor.button[3] = guiCreateButton(266, 290, 82, 24, "Remove", false, GUIEditor.window[1])
        GUIEditor.button[4] = guiCreateButton(289, 59, 20, 20, "<", false, GUIEditor.window[1])
        GUIEditor.button[5] = guiCreateButton(319, 59, 20, 20, ">", false, GUIEditor.window[1])
        GUIEditor.button[6] = guiCreateButton(92, 290, 82, 24, "Copy", false, GUIEditor.window[1])
        GUIEditor.button[7] = guiCreateButton(96, 24, 101, 25, "On Selected", false, GUIEditor.window[1])
        GUIEditor.button[8] = guiCreateButton(179, 290, 82, 24, "Textures", false, GUIEditor.window[1])

        GUIEditor.label[7] = guiCreateLabel(197, 24, 152, 25, "No map loaded", false, GUIEditor.window[1])
        guiLabelSetColor(GUIEditor.label[7], 255, 0, 0)
        guiLabelSetHorizontalAlign(GUIEditor.label[7], "center", false)
        guiLabelSetVerticalAlign(GUIEditor.label[7], "center")
        GUIEditor.label[8] = guiCreateLabel(10, 154, 67, 22, "Color :- ", false, GUIEditor.window[1])


        guiSetVisible(GUIEditor.window[1], false);

        guiLabelSetColor(GUIEditor.label[2], r, g, b)
        colorPicker.constructor()
        guiSetInputMode("no_binds_when_editing")

        guiSetVisible(GUIEditor.label[1], true)
        guiSetVisible(GUIEditor.label[2], false)
        guiSetVisible(GUIEditor.label[3], false)
        guiSetVisible(GUIEditor.label[4], false)
        guiSetVisible(GUIEditor.label[5], false)
        guiSetVisible(GUIEditor.label[6], false)
        guiSetVisible(GUIEditor.label[8], false)
        guiSetVisible(GUIEditor.label[9], false)
        guiSetVisible(GUIEditor.button[1], true)
        guiSetVisible(GUIEditor.button[7], true)
        guiSetVisible(GUIEditor.combobox[1], false)
        guiSetVisible(GUIEditor.checkbox[1], false)
        guiSetVisible(GUIEditor.checkbox[2], false)
        guiSetVisible(GUIEditor.button[2], false)
        guiSetVisible(GUIEditor.button[3], false)
        guiSetVisible(GUIEditor.button[8], false)
        guiSetVisible(GUIEditor.button[4], false)
        guiSetVisible(GUIEditor.button[5], false)
        guiSetVisible(GUIEditor.button[6], false)
        guiSetVisible(GUIEditor.scrollbar[1], false)
        guiSetEnabled(GUIEditor.button[6], false)
        guiComboBoxClear(GUIEditor.combobox[1])
        guiSetEnabled(GUIEditor.button[6], false)


        local editor = getResourceFromName("editor_main");
        if (editor and getResourceState(editor) == "running") then
            setEditorState(true)
            guiSetText(GUIEditor.label[1], "Select an element")
        end

        updateGUI()
    end
)



function centerRightWindow(window)
    if window and isElement(window) then
        local screenW, screenH = guiGetScreenSize()
        local windowW, windowH = guiGetSize(window, false)
        local x = screenW - windowW - 20
        local y = (screenH - windowH) / 2
        guiSetPosition(window, x, y, false)
    end
end

function changeKeyCommandFunc(cmd, key)
    if not key then
        mereOutput("/" .. cmd)
        return
    end
    if not keyTable[key] then
        mereOutput("Invalid key.")
        return
    end
    unbindKey(settings.key, "down", openGUI)
    setSetting("key", key)
    mereOutput("Key set to " .. key)
    bindKey(key, "down", openGUI)
end

function openGUI(key, state)
    if key == settings.key then
        local visible = guiGetVisible(GUIEditor.window[1]);
        guiSetVisible(GUIEditor.window[1], not visible);
    end
end

local previousElement = nil
local allowed_elements = { ["object"] = true, ["vehicle"] = true }



addEventHandler("onClientRender", root,
    function()
        if (not isEditorActive()) then return end
        editor_element = exports["editor_main"]:getSelectedElement()
        local dimension = getElementDimension(localPlayer)

        if editor_element and allowed_elements[getElementType(editor_element)] and dimension == exports["editor_main"]:getWorkingDimension() and dimension == exports["editor_main"]:getWorkingDimension() then
            selectedElement = editor_element
        else
            selectedElement = nil
        end

        if not guiGetVisible(GUIEditor.window[1]) then return end

        if selectedElement and getMode() == 0 and (selectedElement ~= previousElement or not previousElement) then
            setModelTextureNames()
            closeBrowser(true)
        end
        previousElement = selectedElement

        local hasSelection = (getMode() == 0 and selectedElement) or
            (getMode() == 1 and #getSelectedElements() > 0)

        if hasSelection then
            if not guiGetVisible(GUIEditor.label[1]) then return end
            guiSetVisible(GUIEditor.label[1], false)
            guiSetVisible(GUIEditor.label[2], true)
            guiSetVisible(GUIEditor.label[3], true)
            guiSetVisible(GUIEditor.label[4], true)
            guiSetVisible(GUIEditor.label[5], true)
            guiSetVisible(GUIEditor.label[6], true)
            guiSetVisible(GUIEditor.label[8], true)
            guiSetVisible(GUIEditor.button[1], true)
            guiSetVisible(GUIEditor.combobox[1], true)
            guiSetVisible(GUIEditor.checkbox[1], true)
            guiSetVisible(GUIEditor.checkbox[2], true)
            guiSetVisible(GUIEditor.button[2], true)
            guiSetVisible(GUIEditor.button[3], true)
            guiSetVisible(GUIEditor.button[8], true)
            guiSetVisible(GUIEditor.button[4], true)
            guiSetVisible(GUIEditor.button[5], true)
            guiSetVisible(GUIEditor.button[6], true)
            guiSetVisible(GUIEditor.button[7], true)
            guiSetVisible(GUIEditor.scrollbar[1], true)
            updateGUI()
        else
            if guiGetVisible(GUIEditor.label[1]) then return end
            guiSetVisible(GUIEditor.label[1], true)
            guiSetVisible(GUIEditor.label[2], false)
            guiSetVisible(GUIEditor.label[3], false)
            guiSetVisible(GUIEditor.label[4], false)
            guiSetVisible(GUIEditor.label[5], false)
            guiSetVisible(GUIEditor.label[6], false)
            guiSetVisible(GUIEditor.label[8], false)
            guiSetVisible(GUIEditor.label[9], false)
            guiSetVisible(GUIEditor.button[1], true)
            guiSetVisible(GUIEditor.combobox[1], false)
            guiSetVisible(GUIEditor.checkbox[1], false)
            guiSetVisible(GUIEditor.checkbox[2], false)
            guiSetVisible(GUIEditor.button[2], false)
            guiSetVisible(GUIEditor.button[3], false)
            guiSetVisible(GUIEditor.button[8], false)
            guiSetVisible(GUIEditor.button[4], false)
            guiSetVisible(GUIEditor.button[5], false)
            guiSetVisible(GUIEditor.button[6], false)
            guiSetVisible(GUIEditor.scrollbar[1], false)
            guiComboBoxClear(GUIEditor.combobox[1])
            updateGUI()
        end
    end
)


addEventHandler("onClientGUIScroll", resourceRoot,
    function(scrollBar)
        if (scrollBar == GUIEditor.scrollbar[1]) then
            guiSetText(GUIEditor.label[6], tostring(guiScrollBarGetScrollPosition(scrollBar) / 100 * 255))
        end
    end
)


function updateGUI()
    local full = guiCheckBoxGetSelected(GUIEditor.checkbox[1])
    local visible = guiGetVisible(GUIEditor.checkbox[1])
    local edit = guiCheckBoxGetSelected(GUIEditor.checkbox[2])
    guiSetEnabled(GUIEditor.scrollbar[1], (full and not edit))
    guiSetEnabled(GUIEditor.checkbox[2], full)
    guiSetVisible(GUIEditor.label[9], (full and edit and visible))

    guiSetText(GUIEditor.button[2], (full and edit and "Edit" or "Apply"))
    setLabelSize()
    guiSetEnabled(GUIEditor.button[6], (getMode() == 1 and #getSelectedElements() > 1 and not everything))
end

addEventHandler("onClientGUIClick", resourceRoot,
    function(b, s)
        if (b == "left" and s == "up") then
            if (source == GUIEditor.label[2]) then
                colorPicker.openSelect()
            elseif (source == GUIEditor.checkbox[1] or source == GUIEditor.checkbox[2]) then
                updateGUI()
            elseif (source == GUIEditor.button[1]) then
                if (guiGetText(GUIEditor.button[1]) == "Clear") then
                    clearSelectedElements()
                    guiSetText(GUIEditor.button[1], "Multiple")
                else
                    toggleMode()
                end
            elseif (source == GUIEditor.button[4]) then -- Left button
                local current = guiComboBoxGetSelected(GUIEditor.combobox[1])
                local count = guiComboBoxGetItemCount(GUIEditor.combobox[1])
                if count > 0 then
                    local newIndex = (current - 1) % count
                    if newIndex < 0 then newIndex = count - 1 end
                    guiComboBoxSetSelected(GUIEditor.combobox[1], newIndex)
                    triggerEvent("onClientGUIComboBoxAccepted", GUIEditor.combobox[1], GUIEditor.combobox[1])
                end
            elseif (source == GUIEditor.button[5]) then -- Right button
                local current = guiComboBoxGetSelected(GUIEditor.combobox[1])
                local count = guiComboBoxGetItemCount(GUIEditor.combobox[1])
                if count > 0 then
                    local newIndex = (current + 1) % count
                    guiComboBoxSetSelected(GUIEditor.combobox[1], newIndex)
                    triggerEvent("onClientGUIComboBoxAccepted", GUIEditor.combobox[1], GUIEditor.combobox[1])
                end
            elseif (source == GUIEditor.button[7]) then
                if (guiGetText(GUIEditor.button[7]) == "On Selected") then
                    everything = true
                    guiSetText(GUIEditor.button[7], "On Everything")
                else
                    everything = false
                    guiSetText(GUIEditor.button[7], "On Selected")
                end
                updateGUI()
            end
        end
    end
)





----------------------------------------------------------
----------------------------------------------------------
----------------------------------------------------------
---------------------------GLOBAL------------------------
----------------------------------------------------------
----------------------------------------------------------

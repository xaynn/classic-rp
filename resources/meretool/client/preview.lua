local previewEnabled = true
local renderTimer = nil;
local renderTex = nil;
local renderTexSizeW = nil;
local renderTexSizeH = nil;

addEventHandler("onClientGUIComboBoxAccepted", resourceRoot,
    function(comboBox)
        if (comboBox == GUIEditor.combobox[1] and settings.preview) then
            local item = guiComboBoxGetSelected(comboBox)
            local text = tostring(guiComboBoxGetItemText(comboBox, item))
            local element = selectedElement or getSelectedElements()[1]["element"]
            if (text ~= "*" and element) then
                renderTex = engineGetModelTextures(getElementModel(element), text)[text];
                if (not renderTex) then return end
                renderTexSizeW, renderTexSizeH = dxGetPixelsSize(dxGetTexturePixels(renderTex))
                if (isTimer(renderTimer)) then
                    killTimer(renderTimer)
                else
                    addEventHandler("onClientRender", root, renderFunction)
                end
                renderTimer = setTimer(function()
                    removeEventHandler("onClientRender", root, renderFunction)
                end, 1000, 1)
            end
        end
    end)

function renderFunction()
    local screenW, screenH = guiGetScreenSize()
    local outerSizeW = renderTexSizeW + 20
    local outerSizeH = renderTexSizeH + 20
    local innerSizeW = renderTexSizeW
    local innerSizeH = renderTexSizeH
    local outerX = (screenW - outerSizeW) / 2
    local outerY = (screenH - outerSizeH) / 2
    local innerX = (screenW - innerSizeW) / 2
    local innerY = (screenH - innerSizeH) / 2
    dxDrawRectangle(outerX, outerY, outerSizeW, outerSizeH, tocolor(0, 0, 0, 125))
    dxDrawImage(innerX, innerY, innerSizeW, innerSizeH, renderTex)
end

function previewCommandFunc()
    local preview = getSetting("preview")
    setSetting("preview", not preview)
    mereOutput("Texture preview " .. (not preview and "enabled" or "disabled"))
end

local shader = [[
//
// tex_names.fx
//

float Time : TIME;

// Make everything all flashy!
float4 GetColor()
{
    return float4( cos(Time*10), cos(Time*7), cos(Time*4), 1 );
}

//-----------------------------------------------------------------------------
// Techniques
//-----------------------------------------------------------------------------
technique tec0
{
    pass P0
    {
        MaterialAmbient = GetColor();
        MaterialDiffuse = GetColor();
        MaterialEmissive = GetColor();
        MaterialSpecular = GetColor();

        AmbientMaterialSource = Material;
        DiffuseMaterialSource = Material;
        EmissiveMaterialSource = Material;
        SpecularMaterialSource = Material;

        ColorOp[0] = SELECTARG1;
        ColorArg1[0] = Diffuse;

        AlphaOp[0] = SELECTARG1;
        AlphaArg1[0] = Diffuse;

        Lighting = true;
    }
}
]]

local flashEffectEnabled = true
local flashingObjects = {}
local shader = dxCreateShader(shader, 3, 0, false, 'all')

function flashObject(object, texturename)
    if not isElement(object) then return false end
    if flashingObjects[object] then
        removeFlashingEffect(object)
    end
    if not shader then return false end
    engineApplyShaderToWorldTexture(shader, texturename, object)
    local removeTimer = setTimer(function()
        removeFlashingEffect(object)
    end, 700, 1)
    flashingObjects[object] = removeTimer
    return true
end

function removeFlashingEffect(object)
    if not flashingObjects[object] then return false end
    local data = flashingObjects[object]
    if isTimer(data) then killTimer(data) end
    flashingObjects[object] = nil
    engineRemoveShaderFromWorldTexture(shader, "*", object)

    return true
end

addEventHandler("onClientGUIComboBoxAccepted", resourceRoot,
    function(comboBox)
        if (comboBox == GUIEditor.combobox[1] and settings.flash) then
            local item = guiComboBoxGetSelected(comboBox)
            local texture = tostring(guiComboBoxGetItemText(comboBox, item))
            if (texture ~= "*") then
                if (getMode() == 0) then
                    flashObject(selectedElement, texture)
                else
                    for _, v in ipairs(getSelectedElements()) do
                        flashObject(v["element"], texture)
                    end
                end
            end
        end
    end)


function flashCommandFunc()
    local flash = getSetting("flash")
    setSetting("flash", not flash)
    mereOutput("Flash effect " .. (not flash and "enabled" or "disabled"))
end

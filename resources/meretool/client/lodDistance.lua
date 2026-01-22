local loadDistanceValue = 10000
local lodDistance = {
    -- [model] = old distance before the script changing it
}


function changeLodDistnace(model)
    if (getSetting("drawDistance") == 0) then return end
    if (not lodDistance[model]) then
        lodDistance[model] = true
    end
    engineSetModelLODDistance(tonumber(model), loadDistanceValue, true)
end

function resetLodDistance(model)
    if (not lodDistance[model]) then return end
    engineResetModelLODDistance(model)
    lodDistance[model] = nil
end

function lodDisable()
    for model in pairs(lodDistance) do
        resetLodDistance(model)
    end
end

function toggleLodDistance(cmd, number)
    if (not number or not tonumber(number) or tonumber(number) < 0 or tonumber(number) > 2) then
        mereOutput("Current type is (" .. getSetting("drawDistance") .. ")")
        mereOutput("Usage: /" .. cmd .. " [type]")
        outputChatBox(COLOR_CODE .. "--------------------------------", 255, 255, 255, true)
        outputChatBox(COLOR_CODE .. "type values:", 255, 255, 255, true)
        outputChatBox(COLOR_WHITE .. "0 = without draw distance", 255, 255, 255, true)
        outputChatBox(COLOR_WHITE .. "1 = draw distance for all objects", 255, 255, 255, true)
        outputChatBox(COLOR_WHITE .. "2 = draw distance for affected objects only", 255, 255, 255, true)
        outputChatBox(COLOR_CODE .. "--------------------------------", 255, 255, 255, true)
        return
    end
    setSetting("drawDistance", tonumber(number))
    mereOutput("Draw distance :- " .. tonumber(number))
    local newtype = tonumber(number)


    lodDisable()
    if (newtype == 1) then
        for _, v in ipairs(mergeTables(getElementsByType("object"), getElementsByType("vehicle"))) do
            local model = getElementModel(v)
            changeLodDistnace(model)
        end
    elseif (newtype == 2) then
        for ID in pairs(ELEMENTS_DATA) do
            local element = getElementByID(ID)
            if element and isElement(element) then
                changeLodDistnace(getElementModel(element))
            end
        end
    end
end

addEventHandler("onClientResourceStop", resourceRoot,
    function()
        lodDisable()
    end
)


addEvent("onClientElementCreate", true)
addEventHandler("onClientElementCreate", root,
    function()
        local model = getElementModel(source)
        local type = getElementType(source)
        if (type ~= "vehicle" or type ~= "objects") then return end
        if (getSetting("drawDistance") == 1) then
            changeLodDistnace(model)
        end
    end
)

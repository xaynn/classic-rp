settings = {
    flash = true,
    preview = true,
    shaders = true,
    drawDistance = 1,
    key = "n"
}

local settingsFile = "settings.json"

function loadSettings()
    local file = fileExists(settingsFile) and fileOpen(settingsFile)
    if not file then
        saveSettings()
        mereOutput("Press [ " .. COLOR_CODE .. settings.key .. COLOR_WHITE .. " ] to open the tool.")
        bindKey(settings.key, "down", openGUI)
        return
    end

    local content = fileRead(file, fileGetSize(file))
    fileClose(file)

    local result = fromJSON(content)
    if result and result.settings then
        settings = result.settings
        mereOutput("Press [ " .. COLOR_CODE .. settings.key .. COLOR_WHITE .. " ] to open the tool.")
        bindKey(settings.key, "down", openGUI)
    else
        saveSettings()
    end
end

function saveSettings()
    local file = fileCreate(settingsFile)
    if not file then return false end

    local content = toJSON({ settings = settings }, true)
    fileWrite(file, content)
    fileClose(file)
    return true
end

function getSetting(key)
    return settings[key]
end

function setSetting(key, value)
    settings[key] = value
    return saveSettings()
end

addEventHandler("onClientResourceStart", resourceRoot, loadSettings)


function settingsCommandFunc()
    outputChatBox(COLOR_CODE .. "--------------------------------", 255, 255, 255, true)
    for key, value in pairs(settings) do
        local type = type(value)
        mereOutput(key .. ": " .. (type == "boolean" and (value and "#00FF00Enabled" or "#FF0000Disabled") or value))
    end
    outputChatBox(COLOR_CODE .. "--------------------------------", 255, 255, 255, true)
end

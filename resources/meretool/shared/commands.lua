local eventName = getLocalPlayer and "onClientResourceStart" or "onResourceStart"
addEventHandler(eventName, resourceRoot,
    function()
        COMMANDS = {
            {
                client = false,
                command = "meresync",
                description = "Synchronize texture data with the server.",
                func = syncCommand
            },
            {
                client = false,
                command = "meremap",
                description = "Display current map name and data file size.",
                func = mapInfoCommand
            },
            {
                client = false,
                command = "merehelp",
                description = "Display this help message.",
                func = helpCommand
            },
            { -- client side command
                client = true,
                command = "merepreview",
                description = "Toggle the preview when the texture is selected.",
                func = previewCommandFunc
            },
            { -- client side command
                client = true,
                command = "mereflash",
                description = "Toggle the flash effect when the texture is selected.",
                func = flashCommandFunc
            },
            {
                client = false,
                command = "meremax",
                description = "Set maximum number of destroyed elements to store (default: 20).",
                func = maxElementsCommand
            },
            { -- client side command
                client = true,
                command = "merekey",
                description = "Set the key to open the tool.",
                func = changeKeyCommandFunc
            },
            { -- client side command
                client = true,
                command = "meredraw",
                description = "Toggle LOD distance modification for models (forces high draw distance).",
                func = toggleLodDistance
            },
            { -- client side command
                client = true,
                command = "mereshaders",
                description = "Toggle the shaders.",
                func = shaderCommandFunc
            },
            { -- client side command
                client = true,
                command = "meresettings",
                description = "Show the current settings.",
                func = settingsCommandFunc
            },
            {
                client = false,
                command = "mereexport",
                description = "Export the current map data to map files.",
                func = mapExportCommandFunc
            },
            {
                client = false,
                command = "merereload",
                description = "Repair missing and modified files.",
                func = mapFilesRepair
            },
        }


        if (isClient()) then
            for i, v in ipairs(COMMANDS) do
                if (v.client) then
                    addCommandHandler(v.command, v.func)
                end
            end
        else
            for i, v in ipairs(COMMANDS) do
                if (not v.client) then
                    addCommandHandler(v.command, v.func)
                end
            end
        end
    end
)


-- Command Functions
function syncCommand(player)
    triggerClientEvent(player, "MereSendDataToClient", player, TEXTURES_DATA, MAP_NAME)
    mereOutput("Texture data synchronized.", player)
end

function mapInfoCommand(player)
    if not MAP_NAME then
        mereOutput("No map is currently loaded", player)
        return
    end

    local filePath = getMapPath(MAP_NAME)
    if not fileExists(filePath) then
        mereOutput("This map has no data. (" .. MAP_NAME .. ")", player)
        return
    end

    local file = fileOpen(filePath)
    if not file then
        mereOutput("Failed to open map file: " .. MAP_NAME)
        return
    end

    local fileSize = fileGetSize(file)
    fileClose(file)


    local files_count, files_size = getCacheFilesSize()


    mereOutput("Current Map: " .. MAP_NAME .. " main file :- (" .. formatFileSize(fileSize) .. ")", player)

    mereOutput(
        "Current Map: " .. MAP_NAME .. " has " .. files_count .. " files with size(" .. formatFileSize(files_size) .. ")",
        player)

    mereOutput("Note: The actual map data file size will be smaller than this.", player)
end

function helpCommand(player)
    mereOutput("Available commands:", player, 255, 255, 255, true)
    outputChatBox(COLOR_CODE .. "--------------------------------", player, 255, 255, 255, true)
    for _, data in ipairs(COMMANDS) do
        outputChatBox(COLOR_CODE .. data.command .. " - " .. COLOR_WHITE .. data.description, player, 255, 255, 255,
            true)
    end
    outputChatBox(COLOR_CODE .. "--------------------------------", player, 255, 255, 255, true)
end

function maxElementsCommand(player, cmd, value)
    if not value then
        mereOutput("Current maximum undo elements: " .. MAX_UNDO_ELEMENTS, player)
        return
    end

    local newValue = tonumber(value)
    if not newValue or newValue < 0 then
        mereOutput("Please enter a valid number greater than or equal to 0.", player)
        return
    end

    if newValue < #undo_elements then
        local removeCount = #undo_elements - newValue
        for i = 1, removeCount do
            table.remove(undo_elements, 1)
        end
    end

    MAX_UNDO_ELEMENTS = newValue
    mereOutput("Maximum undo elements set to: " .. newValue, player)
end

function getMapPath(name)
    return "./maps/" .. name .. "/" .. name .. ".json"
end

function saveMap(name)
    local file = fileCreate(getMapPath(name))
    if (file) then
        local content = { TEXTURES_DATA, ELEMENTS_DATA }
        fileWrite(file, toJSON(content, false, "tabs"))
        fileClose(file)
    else
        outputDebugString("Meretool : failed to save (" .. name .. ") map data.")
    end
end

function openMap(name)
    deleteDefaultMapFiles()
    TEXTURES_DATA = {}
    ELEMENTS_DATA = {}
    undo_elements = {}
    deleteFilesCache()
    local file = fileExists(getMapPath(name)) and fileOpen(getMapPath(name))
    if (file) then
        local json_content = fileRead(file, fileGetSize(file))
        local data = fromJSON(json_content)

        if (data) then
            TEXTURES_DATA = data[1]
            ELEMENTS_DATA = data[2]
            outputDebugString("Meretool : (" .. name .. ") map data loaded.")
            fillFilesCache()
        else
            outputDebugString("Meretool : No data found for (" .. name .. ") map.")
        end
        fileClose(file)
    else
        outputDebugString("Meretool : No data found for (" .. name .. ") map.")
    end

    triggerClientEvent(root, "MereSendDataToClient", root, TEXTURES_DATA, MAP_NAME)
end

function deleteDefaultMapFiles()
    if (MAP_NAME) then return end
    for texture_name in pairs(TEXTURES_DATA) do
        for key in pairs(TEXTURES_DATA[texture_name]) do
            local data = TEXTURES_DATA[texture_name][key]["DATA"]
            if (data and data["FILE"]) then
                local content = readPNGFile(MAP_NAME, data["FILE"])
                if (content) then
                    deletePNGFile(MAP_NAME, data["FILE"])
                end
            end
        end
    end
end

addEventHandler("onResourceStart", root,
    function(startedResource)
        if getResourceFromName("editor_main") and getResourceState(getResourceFromName("editor_main")) == "running" then
            setEditorState(true)
        end
        if (startedResource == getThisResource()) then
            mereOutput(
                "The resource has been started. Please (open) the map again so that it can identify the map used.", root)
            mereOutput("Using (save as) now will cause the original map data to be lost.", root)
        end
    end
)

addEventHandler("onNewMap", root,
    function()
        outputDebugString("Meretool : new map has been created")
        deleteDefaultMapFiles()
        MAP_NAME = nil
        TEXTURES_DATA = {}
        ELEMENTS_DATA = {}
        undo_elements = {}
        deleteFilesCache()
        triggerClientEvent(root, "MereSendDataToClient", root, TEXTURES_DATA, MAP_NAME)
    end
)


addEventHandler("onMapOpened", root,
    function(resource)
        if (getResourceName(resource) == "editor_dump") then return end
        MAP_NAME = getResourceName(resource)
        openMap(MAP_NAME)
        outputDebugString("Meretool : " .. getResourceName(resource) .. " opend.")
    end
)



--SAVE AS--
--SAVE AS--
--SAVE AS--
addEventHandler("saveResource", root,
    function(resourceName)
        if (MAP_NAME) then
            outputDebugString("Meretool : change map name from " .. MAP_NAME .. ' to ' .. resourceName)
            mereOutput("Map changed from " .. MAP_NAME .. ' to ' .. resourceName)
        end

        -- move from folder to another
        for texture_name in pairs(TEXTURES_DATA) do
            for key in pairs(TEXTURES_DATA[texture_name]) do
                local data = TEXTURES_DATA[texture_name][key]["DATA"]
                if (data and data["FILE"]) then
                    local content = readPNGFile(MAP_NAME, data["FILE"])
                    if (content) then
                        writePNGFile(resourceName, data["FILE"], content)
                        if (not MAP_NAME) then -- if the map was editor_dump
                            deletePNGFile(MAP_NAME, data["FILE"])
                        end
                    end
                end
            end
        end

        deleteDefaultMapFiles()

        MAP_NAME = resourceName
        outputDebugString("Meretool : save to " .. resourceName)
        saveMap(MAP_NAME)
        triggerClientEvent(root, "MereSendDataToClient", root, TEXTURES_DATA, MAP_NAME)
    end
)

-- SAVE --
addEventHandler("quickSaveResource", root,
    function()
        if (not MAP_NAME) then
            -- mereOutput("The map being edited cannot be identified. Please open it again#ff0000!!!!")
            return
        end
        outputDebugString("Meretool : save (" .. MAP_NAME .. ") map data.")
        mereOutput("Saved (" .. MAP_NAME .. ") map data.")
        saveMap(MAP_NAME)
    end
)

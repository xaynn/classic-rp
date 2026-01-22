isEditorRunning = false

function isClient()
    return isElement(localPlayer)
end

function isEditorActive()
    return isEditorRunning
end

function setEditorState(running)
    isEditorRunning = running
end

if isClient() then
    addEventHandler("onClientResourceStart", root, function(resource)
        if getResourceName(resource) == "editor_main" then
            setEditorState(true)
            guiSetText(GUIEditor.label[1], "Select an element")
        end
    end)
else
    addEventHandler("onResourceStart", root, function(resource)
        if getResourceName(resource) == "editor_main" then
            setEditorState(true)
        end
    end)
end


if isClient() then
    addEventHandler("onClientResourceStop", root, function(resource)
        if getResourceName(resource) == "editor_main" then
            setEditorState(false)
            selectedElement = nil
            previousElement = nil
            cleanupSelectedElements()
            guiSetText(GUIEditor.label[1], "Start the editor")
        end
    end)
else
    addEventHandler("onResourceStop", root, function(resource)
        if getResourceName(resource) == "editor_main" then
            setEditorState(false)
            deleteDefaultMapFiles()
            MAP_NAME = nil
            TEXTURES_DATA = {}
            ELEMENTS_DATA = {}
            undo_elements = {}
            deleteFilesCache()
            triggerClientEvent(root, "MereSendDataToClient", root, TEXTURES_DATA, MAP_NAME)
        end
    end)

    addEventHandler("onResourceStop", resourceRoot, function(resource)
        deleteDefaultMapFiles()
    end)
end

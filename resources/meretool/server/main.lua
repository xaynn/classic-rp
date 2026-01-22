MAX_UNDO_ELEMENTS = 20
UNDO_ELEMENTS = {}
MAP_NAME = nil



addEvent("saveResource", true)
addEvent("quickSaveResource", true)
addEvent("onNewMap", true)
addEvent("onMapOpened", true)
addEvent("onElementDestroy", true)
addEvent("onElementCreate", true)
addEvent("mereOnDownloadFinish", true)
addEvent("mereAddData", true)
addEvent("mereClearData", true)
addEvent("mereCopyToElements", true)



addEventHandler("mereOnDownloadFinish", root,
    function(map_name)
        triggerClientEvent(source, "MereSendDataToClient", source, TEXTURES_DATA, MAP_NAME)
    end
)


addEventHandler("mereAddData", root,
    function(type_, data, elements_data, everything)
        for _, v in ipairs(elements_data) do
            local id = v["id"]
            local textures_names = v["textures"]
            processData(getElementByID(id), type_, textures_names, data, v["additional_data"], everything)
        end


        for i, v in ipairs(getElementsByType("player")) do
            if (v ~= source) then
                triggerClientEvent(v, "mereApplyShaders", v, type_, data, elements_data, everything)
            end
        end
    end
)


addEventHandler("mereClearData", root,
    function(elements_data, everything)
        for i, v in ipairs(getElementsByType("player")) do
            if (v ~= source) then
                triggerClientEvent(v, "mereRemoveShaders", v, elements_data, everything)
            end
        end

        for i, v in ipairs(elements_data) do
            for _, name in ipairs(v["textures"]) do
                clearData(v["id"], name, everything)
            end
        end
    end
)

addEventHandler("mereCopyToElements", root,
    function(master, elements, textures_names)
        copyToElements(master, elements, textures_names);
        for i, v in ipairs(getElementsByType("player")) do
            if (v ~= source) then
                triggerClientEvent(v, "mereClientCopyToElements", v, master, elements, textures_names)
            end
        end
    end
)



function getElementDataTexturesName(element_id)
    local textures_names = {}
    local element_data = ELEMENTS_DATA[element_id]
    if (ELEMENTS_DATA[element_id]) then
        for name in pairs(element_data) do
            table.insert(textures_names, name)
        end
    end
    return textures_names
end

---------------------------------------
---------------------------------------
--- CLONE ELEMENTS
---------------------------------------
---------------------------------------

addDebugHook("postFunction",
    function(sourceResource, functionName, isAllowedByACL, luaFilename, luaLineNumber, resource, callName, element,
             editorMode, cloned)
        if callName == "edfCloneElement" then
            local cloned = cloned or editorMode
            setElementData(cloned, "meretool_cloned", element)
            -- if (ELEMENTS_DATA[getElementID(element)]) then
            --     setTimer(function()
            --         if (getElementID(cloned) ~= "" and isElement(cloned) and isElement(element) and getElementModel(element) == getElementModel(cloned) and ELEMENTS_DATA[getElementID(element)]) then
            --             -- setElementData(cloned, "meretool_cloned", nil)
            --             -- local element_model = tostring(getElementModel(cloned))
            --             -- local element_id = getElementID(element)
            --             -- local cloned_id = getElementID(cloned)
            --             -- for name, texture_md5 in pairs(ELEMENTS_DATA[element_id]) do
            --             --     local p = TEXTURES_DATA[name][texture_md5] -- here
            --             --     local size = p["SIZE"] or 0
            --             --     -- addData(element_model, cloned_id, p["FULL"], p["THRESHOLD"], p['TEXTURE_PIXELS'], name,
            --             --     -- p['RED'], p['GREEN'], p['BLUE'], p["ALPHA"], p["TRANSPARENT"], size, p["ORIGINAL"])
            --             -- end
            --             -- -- triggerClientEvent(root, "mereOnClone", element, cloned)
            --         end
            --     end, 300, 1)
            -- end
        end
    end,
    { "call" })

---------------------------------------
---------------------------------------
--- Undo Elements
---------------------------------------
---------------------------------------

function addToUndoElements(element_id, texture_data)
    if MAX_UNDO_ELEMENTS == 0 then return end
    for i, entry in ipairs(UNDO_ELEMENTS) do
        if entry["element_id"] == element_id then
            entry["texture_data"] = texture_data
            table.remove(UNDO_ELEMENTS, i)
            table.insert(UNDO_ELEMENTS, entry)
            return
        end
    end

    if #UNDO_ELEMENTS >= MAX_UNDO_ELEMENTS then
        table.remove(UNDO_ELEMENTS, 1)
    end

    table.insert(UNDO_ELEMENTS, {
        ["element_id"] = element_id,
        ["texture_data"] = texture_data
    })
end

addDebugHook("postFunction",
    function(sourceResource, functionName, isAllowedByACL, luaFilename, luaLineNumber, eventName, source)
        if (getResourceName(sourceResource) == "editor_main" and eventName == "onElementDestroy") then
            if (exports["editor_main"]:getWorkingDimension() == getElementDimension(source)) then
                local element_id = getElementID(source)
                if (ELEMENTS_DATA[element_id]) then
                    local elements_data = {}
                    local textures_names = getElementDataTexturesName(element_id)

                    -- Save texture data before clearing
                    local saved_texture_data = {}
                    for _, name in ipairs(textures_names) do
                        local texture_md5 = ELEMENTS_DATA[element_id][name]
                        if TEXTURES_DATA[name] and TEXTURES_DATA[name][texture_md5] then
                            local texture_data = TEXTURES_DATA[name][texture_md5]
                            saved_texture_data[name] = {
                                ["TYPE"] = texture_data["TYPE"],
                                ["DATA"] = texture_data["DATA"],
                                ["SIZE"] = texture_data["SIZE"],
                                ["KEY"] = texture_md5,
                            }

                            if (texture_data["DATA"]["FILE"]) then
                                saved_texture_data[name]["CONTENT"] = readPNGFile(MAP_NAME, texture_data["DATA"]["FILE"])
                            end
                        end
                        clearData(element_id, name)
                    end

                    addToUndoElements(element_id, saved_texture_data)

                    table.insert(elements_data, { ["id"] = element_id, ["textures"] = textures_names })
                    triggerClientEvent(root, "mereRemoveShaders", root, elements_data)
                end
            end
        end
    end, { "triggerEvent" }
)


addEventHandler("onElementCreate", root,
    function()
        local element_id = getElementID(source)
        if not element_id then return end

        for i, entry in ipairs(UNDO_ELEMENTS) do
            if entry["element_id"] == element_id then
                for texture_name, texture_data in pairs(entry["texture_data"]) do
                    local element = getElementByID(entry["element_id"])
                    local type = texture_data["TYPE"]
                    local data = texture_data["DATA"]
                    local size = texture_data["SIZE"]
                    local key = texture_data["KEY"]
                    local content = texture_data["CONTENT"]
                    addData(element, type, key, texture_name, data, content, size, false);
                    UNDO_ELEMENTS[i]["texture_data"][texture_name]["CONTENT"] = nil
                    triggerClientEvent(root, "mereRestoreElement", root, element_id, texture_name, texture_data)
                end

                outputDebugString("Meretool : " .. element_id .. " restored.")
                table.remove(UNDO_ELEMENTS, i)
                break
            end
        end
    end
)

-- -------------------------------------
-- -------------------------------------
-- - Set Element Model & Set Element ID
-- -------------------------------------
-- -------------------------------------

addDebugHook("preFunction",
    function(_, functionName, _, _, _, element, id)
        if (element and isElement(element)) then
            if functionName == "setElementModel" then
                ----------------------------------------------------
                local element_id = getElementID(element)
                if (ELEMENTS_DATA[element_id]) then
                    local textures_names = getElementDataTexturesName(element_id)
                    for i, name in ipairs(textures_names) do
                        clearData(element_id, name, false)
                    end
                    local elements_data = { {
                        model = tostring(getElementModel(element)),
                        id = element_id,
                        textures = textures_names
                    } }
                    triggerClientEvent(root, "mereRemoveShaders", root, elements_data, false)
                    outputDebugString("Meretool : removing shaders from (" .. element_id .. ") due to the model change.")
                end
                ----------------------------------------------------
            elseif (functionName == "setElementID") then
                ----------------------------------------------------
                local old = getElementID(element)
                if (old == "" and getElementData(element, "meretool_cloned")) then
                    local cloned_from = getElementData(element, "meretool_cloned")
                    setElementData(element, "meretool_cloned", nil)
                    if (cloned_from and isElement(cloned_from) and getElementModel(cloned_from) == getElementModel(element) and ELEMENTS_DATA[getElementID(cloned_from)]) then
                        setTimer(function()
                            if (cloned_from and isElement(cloned_from) and isElement(element) and getElementModel(cloned_from) == getElementModel(element) and ELEMENTS_DATA[getElementID(cloned_from)]) then
                                local elements = { { ["element"] = element } };
                                copyToElements(cloned_from, elements, ELEMENTS_DATA[getElementID(cloned_from)])
                                triggerClientEvent(root, "mereClientCopyToElements", root, cloned_from, elements,
                                    ELEMENTS_DATA[getElementID(cloned_from)])
                            end
                        end, 100, 1)
                    end


                    return
                end
                setTimer(
                    function()
                        local old_id = old
                        local new_id = getElementID(element)
                        if (old_id == new_id) then return end
                        if (ELEMENTS_DATA[old_id]) then
                            for name, texture_md5 in pairs(ELEMENTS_DATA[old_id]) do
                                if (TEXTURES_DATA[name] and TEXTURES_DATA[name][texture_md5]) then
                                    TEXTURES_DATA[name][texture_md5]["ELEMENTS_IDS"][old_id] = nil
                                    TEXTURES_DATA[name][texture_md5]["ELEMENTS_IDS"][new_id] = true
                                end
                            end
                            ELEMENTS_DATA[new_id] = ELEMENTS_DATA[old_id]
                            ELEMENTS_DATA[old_id] = nil
                            outputDebugString("Meretool : renaming (" .. old_id .. ") to (" .. new_id .. ")")
                            triggerClientEvent(root, "mereRenamingID", root, old_id, new_id)
                        end
                    end, 100, 1
                )
                ----------------------------------------------------
            end
        end
    end,
    { "setElementModel", "setElementID" })

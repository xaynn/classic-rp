function mapExportCommandFunc(player, _, drawDistance)
    if not hasObjectPermissionTo(resource, "general.ModifyOtherObjects") then
        mereOutput("This resource doesn't have the right to do this", player)
        mereOutput("use '/aclrequest allow " .. getResourceName(getThisResource()) .. " all", player)
        return
    end


    if not MAP_NAME then
        outputChatBox(COLOR_CODE .. "Meretool : " .. COLOR_WHITE .. "No map is currently loaded", player, 255, 255, 255,
            true)
        return
    end

    if not drawDistance then
        mereOutput("Usage: /mereexport [draw distance]", player)
        outputChatBox(COLOR_CODE .. "--------------------------------", player, 255, 255, 255, true)
        outputChatBox(COLOR_CODE .. "Draw distance values:", player, 255, 255, 255, true)
        outputChatBox(COLOR_WHITE .. "0 = without draw distance", player, 255, 255, 255, true)
        outputChatBox(COLOR_WHITE .. "1 = draw distance for all objects", player, 255, 255, 255, true)
        outputChatBox(COLOR_WHITE .. "2 = draw distance for affected objects only ( )", player, 255, 255, 255, true)
        outputChatBox(COLOR_CODE .. "--------------------------------", player, 255, 255, 255, true)
        return
    end

    drawDistance = tonumber(drawDistance)

    if not drawDistance or drawDistance < 0 or drawDistance > 2 then
        mereOutput(COLOR_CODE .. "Meretool : " .. COLOR_WHITE .. "Invalid draw distance value.", player)
        return
    end

    local texturesTable = {}
    local textureIndexMap = {}
    local elementsTable = {}
    local fullTexturesCount = 0



    for texture_name in pairs(TEXTURES_DATA) do
        if (TEXTURES_DATA[texture_name][all_key]) then
            local texture_data = TEXTURES_DATA[texture_name][all_key]
            local base_md5 = texture_data.DATA.MD5
            if not textureIndexMap[base_md5] then
                local texture_index = #texturesTable + 1
                textureIndexMap[base_md5] = {
                    index = texture_index,
                    full_md5 = all_key
                }




                texturesTable[texture_index] = {
                    n = texture_name,
                    f = texture_data.DATA.FILE or nil,
                    t = texture_data.TYPE,
                    d = texture_data.DATA,
                    e = true
                }

                if texture_data.DATA.FILE then
                    fullTexturesCount = fullTexturesCount + 1
                end
            end
        end
    end


    for element_id, element_data in pairs(ELEMENTS_DATA) do
        local element = getElementByID(element_id)
        if element then
            elementsTable[element_id] = {
                model = tostring(getElementModel(element)),
                textures = {}
            }

            for texture_name, texture_md5 in pairs(element_data) do
                if TEXTURES_DATA[texture_name] and TEXTURES_DATA[texture_name][texture_md5] then
                    local texture_data = TEXTURES_DATA[texture_name][texture_md5]

                    local base_md5 = texture_data.DATA.MD5


                    if not textureIndexMap[base_md5] then
                        local texture_index = #texturesTable + 1
                        textureIndexMap[base_md5] = {
                            index = texture_index,
                            full_md5 = texture_md5
                        }

                        texturesTable[texture_index] = {
                            n = texture_name,
                            f = texture_data.DATA.FILE or nil,
                            t = texture_data.TYPE,
                            d = texture_data.DATA,
                            e = false
                        }

                        if texture_data.DATA.FILE then
                            fullTexturesCount = fullTexturesCount + 1
                        end
                    end

                    table.insert(elementsTable[element_id].textures, {
                        name = texture_name,
                        index = textureIndexMap[base_md5].index
                    })
                end
            end
        else
            outputDebugString("Meretool : Element " .. element_id .. " no longer exists, skipping...")
        end
    end


    mereOutput("Total of " ..
        #texturesTable .. " shaders, " .. fullTexturesCount .. " images, for " .. tableSize(elementsTable) .. " elements")

    -- Remove old files
    local oldFiles = {
        ":" .. MAP_NAME .. "/merescript.lua",
        ":" .. MAP_NAME .. "/meremap.json"
    }

    local metaPath = ":" .. MAP_NAME .. "/meta.xml"
    local metaXml = xmlLoadFile(metaPath)
    if not metaXml then
        mereOutput("Could not load meta.xml (exporting stopped)", player)
        return
    end


    local children = xmlNodeGetChildren(metaXml)
    for i = #children, 1, -1 do
        if nodeName == "file" and string.find(xmlNodeGetAttribute(child, "src") or "", "merefiles/") then
            table.insert(oldFiles, ":" .. MAP_NAME .. "/" .. src)
        end
    end

    -- acl group check
    for _, filePath in ipairs(oldFiles) do
        if fileExists(filePath) then
            fileDelete(filePath)
            outputDebugString("Meretool: Removed old file " .. filePath)
        end
    end

    -- Remove old texture files
    local texturesDir = ":" .. MAP_NAME .. "/merefiles/"
    local files_size = 0
    -- Save textures as PNG files
    for i, texture in ipairs(texturesTable) do
        if texture.f then
            local content, _, size = readPNGFile(MAP_NAME, texture.f)
            if content then
                files_size = files_size + size
                local filePath = texturesDir .. i .. ".png"
                local file = fileCreate(filePath)
                if file then
                    fileWrite(file, content)
                    fileClose(file)
                    outputDebugString("Meretool: Created texture " .. i .. ".png")
                else
                    mereOutput("Failed to create texture file (exporting stopped)" .. filePath, player)
                    return
                end
            else
                mereOutput("There are missing files please use /merereload (exporting stopped)", player)
            end
        end
    end

    -- Save map data
    local content = toJSON({
        drawDistance = drawDistance,
        texturesTable = texturesTable,
        elements = elementsTable
    })

    -- Copy script
    local scriptContent = fileOpen("./server/script.lua")
    if scriptContent then
        local fileContent = fileRead(scriptContent, fileGetSize(scriptContent))
        fileClose(scriptContent)
        scriptContent = fileContent
    else
        mereOutput("Meretool: Could not find script.lua (exporting stopped)", player)
        return
    end

    -- Write merescript.lua
    local scriptPath = ":" .. MAP_NAME .. "/merescript.lua"
    local scriptFile = fileCreate(scriptPath)
    if scriptFile then
        fileWrite(scriptFile, scriptContent)
        fileClose(scriptFile)
    else
        mereOutput("Failed to create merescript.lua (exporting stopped)", player)
        return
    end

    -- Write meremap.json
    local jsonPath = ":" .. MAP_NAME .. "/meremap.json"
    local jsonFile = fileCreate(jsonPath)
    if jsonFile then
        fileWrite(jsonFile, content)
        fileClose(jsonFile)
    else
        mereOutput("Failed to create meremap.json (exporting stopped)", player)
        return
    end

    -- Remove existing Meretool entries
    local children = xmlNodeGetChildren(metaXml)
    for i = #children, 1, -1 do
        local child = children[i]
        local nodeName = xmlNodeGetName(child)
        if nodeName == "script" and xmlNodeGetAttribute(child, "src") == "merescript.lua" then
            xmlDestroyNode(child)
        elseif nodeName == "file" and xmlNodeGetAttribute(child, "src") == "meremap.json" then
            xmlDestroyNode(child)
        elseif nodeName == "file" and string.find(xmlNodeGetAttribute(child, "src") or "", "merefiles/") then
            xmlDestroyNode(child)
        end
    end

    -- Add script
    local scriptNode = xmlCreateChild(metaXml, "script")
    xmlNodeSetAttribute(scriptNode, "src", "merescript.lua")
    xmlNodeSetAttribute(scriptNode, "type", "client")

    -- Add JSON file
    local jsonNode = xmlCreateChild(metaXml, "file")
    xmlNodeSetAttribute(jsonNode, "src", "meremap.json")

    -- Add files
    for i, texture in ipairs(texturesTable) do
        if texture.f then
            local fileNode = xmlCreateChild(metaXml, "file")
            xmlNodeSetAttribute(fileNode, "src", "merefiles/" .. i .. ".png")
        end
    end

    xmlSaveFile(metaXml)
    xmlUnloadFile(metaXml)
    outputDebugString("Meretool: Updated meta.xml")

    mereOutput("Exporting map with draw distance=" .. drawDistance, player)
    mereOutput(
        "Files size : - (" ..
        formatFileSize(files_size) .. ") , Data size :- (" .. formatFileSize(#content + #scriptContent) .. ").",
        player)
end

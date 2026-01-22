everything = false
MAP_NAME = nil
selectedElement = nil;
r, g, b, a = 123, 234, 123, 255
shaders = {
    [[
        float red;
        float green;
        float blue;
        float alpha;
        sampler TextureSampler;

        float4 main(float2 tex : TEXCOORD0) : COLOR
        {
            float4 color = tex2D(TextureSampler, tex);
            color.rgb *= float3(red, green, blue);
            color.a *= (alpha);
            return color;
        }

        technique simple
        {
            pass P0
            {
                AlphaBlendEnable = TRUE;
                SrcBlend = SrcAlpha;
                DestBlend = InvSrcAlpha;

                PixelShader = compile ps_2_0 main();
            }
        }

    ]],
    [[
        texture tex;

        technique replace {
            pass P0 {
                Texture[0] = tex;
            }
        }
    ]],

}



-- Cache of texture pixels for each model and texture name to avoid re-calculating them multiple times in mode 1
-- Used only when applying a texture to multiple elements and when copy
TEXTURE_CACHE = {
    -- [texture_name] = {
    --      pixels = pixels_data,
    --      width = width,
    --      height = height,
    --      size = size
    --      transparent = transparent
    -- }
}


function syncShaders(type_, data, texture_name, apply)
    local elements = {}

    if (getMode() == 0) then
        table.insert(elements, selectedElement)
    else
        for _, v in ipairs(getSelectedElements()) do
            table.insert(elements, v["element"])
        end
    end

    local function getElementData(element)
        local element_model = tostring(getElementModel(element))
        local element_id = getElementID(element)
        local textures_names = (texture_name == "*" and engineGetModelTextureNames(element_model) or { texture_name })
        return {
            model = element_model,
            id = element_id,
            textures = textures_names,
            additional_data = {}
        }
    end

    local elements_data = {}
    for _, element in ipairs(elements) do
        local element_data = getElementData(element)

        if apply then
            if type_ == 0 then
                processData(element, type_, element_data.textures, data, nil, everything)
            elseif (type_ == 1 or type_ == 2) then
                local pixels = getNewPixels(getElementModel(element), texture_name, data.RED, data.GREEN, data.BLUE,
                    data.ALPHA, data.THRESHOLD, true)
                element_data["additional_data"] = pixels
                processData(element, type_, element_data.textures, data, pixels, everything)
            end
        else
            for _, name in ipairs(element_data.textures) do
                clearData(element_data.id, name, everything)
            end
        end
        table.insert(elements_data, element_data)
        if (everything) then break end
    end

    if apply then
        triggerServerEvent("mereAddData", localPlayer, type_, data, elements_data, everything)
    else
        triggerServerEvent("mereClearData", localPlayer, elements_data, everything)
    end
    updateGUI()
    TEXTURE_CACHE = {}
end

--


function getNewPixels(model, texture_name, r, g, b, a, threshold, cache)
    local pixels = {};
    local textures = engineGetModelTextures(model, texture_name == "*" and {} or texture_name)
    for name, tex in pairs(textures) do
        if (cache and TEXTURE_CACHE[texture_name]) then
            table.insert(pixels,
                {
                    ["NAME"] = name,
                    ["SIZE"] = TEXTURE_CACHE[texture_name]["SIZE"],
                    ["PIXELS"] = TEXTURE_CACHE
                        [texture_name]["PIXELS"],
                    ["WDITH"] = TEXTURE_CACHE[texture_name]["WDITH"],
                    ["HEIGHT"] = TEXTURE_CACHE
                        [texture_name]["HEIGHT"],
                    ["TRANSPARENT"] = TEXTURE_CACHE[texture_name]["TRANSPARENT"],
                    ["FILE"] = TEXTURE_CACHE[texture_name]["FILE"],
                })
        else
            local new_pixels, hasTransparentPixel = changeTextureColor(dxGetTexturePixels(tex), r, g, b, a, threshold)
            local width, height = dxGetPixelsSize(new_pixels);
            local encoded = encodeString("base64", new_pixels)
            local size = base64Size(encoded)
            local filename = generateFilename(name)
            table.insert(pixels,
                {
                    ["NAME"] = name,
                    ["PIXELS"] = new_pixels,
                    ["WDITH"] = width,
                    ["FILE"] = filename,
                    ["HEIGHT"] = height,
                    ["TRANSPARENT"] =
                        hasTransparentPixel,
                    ["SIZE"] = size
                })
            if (cache) then
                TEXTURE_CACHE[name] = {
                    ["PIXELS"] = new_pixels,
                    ["WDITH"] = width,
                    ["HEIGHT"] = height,
                    ["TRANSPARENT"] =
                        hasTransparentPixel,
                    ["SIZE"] = size,
                    ["FILE"] = filename
                }
            end
        end
    end
    return pixels;
end

function changeTextureColor(pixels, r, g, b, a, threshold)
    local sizeW, sizeH = dxGetPixelsSize(pixels)
    local hasTransparentPixel = false
    local hasTransparentPixel = false

    for i = 0, sizeW - 1 do
        for j = 0, sizeH - 1 do
            local _, _, _, alpha = dxGetPixelColor(pixels, i, j)
            if alpha then
                if alpha >= threshold then
                    dxSetPixelColor(pixels, i, j, r, g, b, a)
                else
                    hasTransparentPixel = true
                end
                if alpha < 255 then
                    hasTransparentPixel = true
                end
            end
        end
    end

    if not hasTransparentPixel then
        -- outputDebugString("Meretool : No transparent pixels found, creating a single pixel texture")
        local singlePixel = dxCreateTexture(1, 1)
        local singlePixelData = dxGetTexturePixels(singlePixel)
        dxSetPixelColor(singlePixelData, 0, 0, r, g, b, a)
        return dxConvertPixels(singlePixelData, "png", 100)
    end

    return dxConvertPixels(pixels, "png"), hasTransparentPixel
end

function getCommonTextues()
    local selectedElements = getSelectedElements()
    if #selectedElements == 0 then return end

    local firstElement = selectedElements[1]["element"]
    local firstModel = getElementModel(firstElement)
    local commonTextures = {}
    local firstTextures = engineGetModelTextureNames(firstModel)

    for _, name in ipairs(firstTextures) do
        commonTextures[name] = true
    end

    for i = 2, #selectedElements do
        local element = selectedElements[i]["element"]
        local model = getElementModel(element)
        local textures = engineGetModelTextureNames(model)
        local tempCommon = {}

        for _, name in ipairs(textures) do
            if commonTextures[name] then
                tempCommon[name] = true
            end
        end

        commonTextures = tempCommon
        if not next(commonTextures) then break end
    end

    return commonTextures
end

function setModelTextureNames()
    local currentTexture = guiComboBoxGetItemText(GUIEditor.combobox[1], guiComboBoxGetSelected(GUIEditor.combobox[1]))

    guiComboBoxClear(GUIEditor.combobox[1]);

    if getMode() == 0 then
        if (not selectedElement or not isElement(selectedElement)) then return end;
        local names = engineGetModelTextureNames(getElementModel(selectedElement));
        guiComboBoxAddItem(GUIEditor.combobox[1], "*");
        guiComboBoxSetSelected(GUIEditor.combobox[1], 0)
        for _, name in ipairs(names) do
            guiComboBoxAddItem(GUIEditor.combobox[1], name);
            if (currentTexture == name) then
                guiComboBoxSetSelected(GUIEditor.combobox[1], guiComboBoxGetItemCount(GUIEditor.combobox[1]) - 1)
            end
        end
    else
        local commonTextures = getCommonTextues() or {}

        guiComboBoxAddItem(GUIEditor.combobox[1], "*");
        guiComboBoxSetSelected(GUIEditor.combobox[1], 0)
        for name in pairs(commonTextures) do
            guiComboBoxAddItem(GUIEditor.combobox[1], name);
            if (currentTexture == name) then
                guiComboBoxSetSelected(GUIEditor.combobox[1], guiComboBoxGetItemCount(GUIEditor.combobox[1]) - 1)
            end
        end
    end
    setLabelSize()
end

function setLabelSize()
    local texture_name = guiComboBoxGetItemText(GUIEditor.combobox[1], guiComboBoxGetSelected(GUIEditor.combobox[1]))
    if (texture_name == "*") then
        guiSetText(GUIEditor.label[5], "------")
        return
    end

    if (everything) then
        local data = TEXTURES_DATA[texture_name] and TEXTURES_DATA[texture_name][all_key]
        if (data) then
            local hasShader = data["SHADER"];
            if (not hasShader) then
                guiSetText(GUIEditor.label[5], "Downloading...")
                return
            end
            local size = data["SIZE"] or 0
            guiSetText(GUIEditor.label[5], string.format("Size (%.2f KB)", size / 1024))
            return
        end
    else
        local element = selectedElement or getMasterElement()
        if (element and isElement(element)) then
            local element_id = getElementID(element)
            if (ELEMENTS_DATA[element_id] and ELEMENTS_DATA[element_id][texture_name]) then
                local texture_md5 = ELEMENTS_DATA[element_id][texture_name]
                if (not TEXTURES_DATA[texture_name][texture_md5]["SHADER"]) then
                    guiSetText(GUIEditor.label[5], "Downloading...")
                    return
                end
                local data = TEXTURES_DATA[texture_name] and TEXTURES_DATA[texture_name][texture_md5] and
                    TEXTURES_DATA[texture_name][texture_md5]
                if (data) then
                    local size = data["SIZE"] or 0
                    guiSetText(GUIEditor.label[5], string.format("Size (%.2f KB)", size / 1024))
                    return
                end
            end
        end
    end
    guiSetText(GUIEditor.label[5], "No data")
end

---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------


addEventHandler("onClientResourceStart", resourceRoot,
    function()
        setEditorState(false)
        if getResourceFromName("editor_main") and getResourceState(getResourceFromName("editor_main")) == "running" then
            setEditorState(true)
            -- outputDebugString("Meretool : Editor is running")
        end
        triggerServerEvent("mereOnDownloadFinish", localPlayer)
        mereOutput("Type " .. COLOR_CODE .. "/merehelp" .. COLOR_WHITE .. " to see available commands.")
    end
)


addEvent("MereSendDataToClient", true)
addEventHandler("MereSendDataToClient", root,
    function(Data, map_name)
        outputDebugString("Meretool : Clearing old shaders")

        guiSetText(GUIEditor.label[7], map_name and map_name or "No map loaded")

        if (map_name) then
            guiLabelSetColor(GUIEditor.label[7], 255, 255, 255)
        else
            guiLabelSetColor(GUIEditor.label[7], 255, 0, 0)
        end

        MAP_NAME = map_name

        deleteFilesCache()
        requestCancelAll()
        deleteAllTextureEntries()

        for name in pairs(TEXTURES_DATA) do
            local e_texture = TEXTURES_DATA[name][all_key]
            if (e_texture and e_texture["SHADER"]) then
                engineRemoveShaderFromWorldTexture(e_texture["SHADER"], name)
            end
        end

        for element_id in pairs(ELEMENTS_DATA) do
            for texture_name in pairs(ELEMENTS_DATA[element_id]) do
                local element = getElementByID(element_id)
                local texture_key = ELEMENTS_DATA[element_id][texture_name]
                local shader = TEXTURES_DATA[texture_name][texture_key]["SHADER"]
                if (element and shader) then
                    engineRemoveShaderFromWorldTexture(shader, texture_name, element)
                end
            end
        end



        TEXTURES_DATA = {}
        ELEMENTS_DATA = {}

        outputDebugString("Meretool : Applying new shaders")
        for texture_name in pairs(Data) do
            for texture_md5, p in pairs(Data[texture_name]) do
                if (texture_md5 == all_key) then
                    addData(nil, p["TYPE"], texture_md5, texture_name, p["DATA"], nil, p["SIZE"], true)
                else
                    for element_id in pairs(p["ELEMENTS_IDS"]) do
                        local element = getElementByID(element_id)
                        if (element) then
                            addData(element, p["TYPE"], texture_md5, texture_name, p["DATA"], nil, p["SIZE"], false)
                        end
                    end
                end
            end
        end
    end
)

addEventHandler("onClientGUIComboBoxAccepted", resourceRoot,
    function(cb)
        if (cb ~= GUIEditor.combobox[1]) then return end
        setLabelSize()
        closeBrowser(true)
        local texture_name = guiComboBoxGetItemText(cb, guiComboBoxGetSelected(cb))
        if (texture_name == "*") then return end

        local elementsToProcess = {}
        if getMode() == 0 then
            if selectedElement then
                table.insert(elementsToProcess, selectedElement)
            end
        else
            elementsToProcess = getSelectedElements()
        end

        local foundData = nil


        if (everything) then
            local data = TEXTURES_DATA[texture_name] and TEXTURES_DATA[texture_name][all_key]
            if (data) then
                foundData = data
            end
        else
            for _, element in ipairs(elementsToProcess) do
                local element_id = getElementID(getMode() == 0 and element or element["element"])
                local texture_md5 = ELEMENTS_DATA[element_id] and ELEMENTS_DATA[element_id][texture_name]

                if texture_md5 then
                    local p = TEXTURES_DATA[texture_name] and TEXTURES_DATA[texture_name][texture_md5]
                    if p then
                        foundData = p
                        if getMode() == 1 then
                            setMasterElement(getMode() == 0 and element or element["element"])
                        end
                        break
                    end
                end
            end
        end
        if not foundData then return end
        local fr = foundData["DATA"]['RED']
        local fg = foundData["DATA"]['GREEN']
        local fb = foundData["DATA"]['BLUE']
        local fa = foundData["DATA"]['ALPHA']
        local threshold = foundData["DATA"]['THRESHOLD']
        guiCheckBoxSetSelected(GUIEditor.checkbox[1], false)
        guiCheckBoxSetSelected(GUIEditor.checkbox[2], false)
        if (foundData["TYPE"] == 0) then
            r, g, b, a = fr, fg, fb, fa
        elseif (foundData["TYPE"] == 1) then
            guiCheckBoxSetSelected(GUIEditor.checkbox[1], true)
            local pers = (threshold / 255) * 100
            r, g, b, a = fr, fg, fb, fa
            guiScrollBarSetScrollPosition(GUIEditor.scrollbar[1], pers)
        elseif (foundData["TYPE"] == 2) then
            guiCheckBoxSetSelected(GUIEditor.checkbox[1], true)
            guiCheckBoxSetSelected(GUIEditor.checkbox[2], true)
        end
        guiLabelSetColor(GUIEditor.label[2], r, g, b)
        updateGUI()
    end
)



addEventHandler("onClientGUIClick", resourceRoot,
    function(btn, s)
        if (btn ~= "left" or s ~= "up") then return end
        local full = guiCheckBoxGetSelected(GUIEditor.checkbox[1])
        local threshold = guiScrollBarGetScrollPosition(GUIEditor.scrollbar[1]) / 100 * 255
        local texture_name = guiComboBoxGetItemText(GUIEditor.combobox[1], guiComboBoxGetSelected(GUIEditor.combobox[1]))
        local is_edit = full and guiCheckBoxGetSelected(GUIEditor.checkbox[2])

        -- Apply or edit
        if (source == GUIEditor.button[2]) then -- apply
            if (not full) then                  -- type 0 overlay
                local data = {
                    ["RED"] = r,
                    ["GREEN"] = g,
                    ["BLUE"] = b,
                    ["ALPHA"] = a,
                    ["MD5"] = r .. ',' .. g .. ',' .. b .. ',' .. a,
                    ["TIMESTAMP"] = getRealTime()
                        .timestamp
                }
                syncShaders(0, data, texture_name, true)
            elseif (full and not is_edit) then -- type 1 one color change
                local data = {
                    ["RED"] = r,
                    ["GREEN"] = g,
                    ["BLUE"] = b,
                    ["ALPHA"] = a,
                    ["THRESHOLD"] = threshold,
                    ["TIMESTAMP"] = getRealTime().timestamp
                }
                syncShaders(1, data, texture_name, true)
            elseif (is_edit) then -- type 2 edit via image editor
                if (texture_name == "*") then return mereOutput("Choose the texture first") end
                local element = getMode() == 0 and selectedElement or getMasterElement()
                local element_id = getElementID(element)
                local element_model = getElementModel(element)
                local textures = engineGetModelTextures(element_model, texture_name)

                local texture_to_edit = dxGetTexturePixels(textures[texture_name])
                local file_name = false;
                if (everything) then
                    local data = TEXTURES_DATA[texture_name] and TEXTURES_DATA[texture_name][all_key]
                    if (data and data["DATA"]["FILE"]) then
                        file_name = data["DATA"]["FILE"]
                    end
                else
                    if (ELEMENTS_DATA[element_id] and ELEMENTS_DATA[element_id][texture_name]) then
                        local texture_md5 = ELEMENTS_DATA[element_id][texture_name]
                        local data = TEXTURES_DATA[texture_name][texture_md5]
                        if (data and data["DATA"]["FILE"]) then
                            file_name = data["DATA"]["FILE"]
                        end
                    end
                end

                if (file_name) then
                    local content = readPNGFile(MAP_NAME, file_name)
                    if (content) then
                        texture_to_edit = content
                    end
                end

                setBrowserData(element, texture_name, element_model)
                local pixels = dxConvertPixels(texture_to_edit, "png")
                local js = string.format("loadImageIntoEditor('%s');", encodeString("base64", pixels))
                openBrowser(js)
            end
        elseif (source == GUIEditor.button[3]) then -- remove
            syncShaders(2, nil, texture_name, false)
        elseif (source == GUIEditor.button[6]) then -- copy
            if (getMode() == 1 and #getSelectedElements() > 1 and not everything) then
                local textures = getCommonTextues()
                copyToElements(getMasterElement(), getSelectedElements(), textures)
                triggerServerEvent("mereCopyToElements", getLocalPlayer(), getMasterElement(), getSelectedElements(),
                    textures)
            else
                updateGUI()
            end
        elseif (source == GUIEditor.button[8]) then -- textures
            openTexturesBrowser()
        end
    end
)


addEvent("MereExportImage", true)
addEventHandler("MereExportImage", root, function(data, size)
    local element = getMode() == 0 and selectedElement or getMasterElement()
    closeBrowser(false)
    local texture_name = guiComboBoxGetItemText(GUIEditor.combobox[1], guiComboBoxGetSelected(GUIEditor.combobox[1]))
    if (isBrowserDataEqual(element, texture_name, getElementModel(element))) then
        local pixels = decodeString("base64", data)
        local width, height = dxGetPixelsSize(pixels)
        local filename = generateFilename(texture_name)
        -- adding to cache to imitate getNewPixels function
        TEXTURE_CACHE[texture_name] = {
            ["PIXELS"] = pixels,
            ["WDITH"] = width,
            ["HEIGHT"] = height,
            ["TRANSPARENT"] = true,
            ["SIZE"] = size,
            ["FILE"] = filename
        }
        syncShaders(2, { ["FILE"] = filename, ["MD5"] = md5(pixels), ["TIMESTAMP"] = getRealTime().timestamp },
            texture_name, true)
    else
        mereOutput("Something went wrong, please try again.")
    end
end)


addEvent("mereApplyShaders", true)
addEventHandler("mereApplyShaders", root,
    function(type_, data, elements_data, everything)
        for _, v in ipairs(elements_data) do
            local element = getElementByID(v["id"])
            processData(element, type_, v["textures"], data, v["additional_data"], everything)
        end
        updateGUI()
    end
)


addEvent("mereRemoveShaders", true)
addEventHandler("mereRemoveShaders", root,
    function(elements_data)
        for i, v in ipairs(elements_data) do
            for _, name in ipairs(v["textures"]) do
                clearData(v["id"], name)
            end
        end
        updateGUI()
    end
)



addEvent("mereRestoreElement", true)
addEventHandler("mereRestoreElement", root,
    function(element_id, texture_name, texture_data)
        local element = getElementByID(element_id)
        local type = texture_data["TYPE"]
        local data = texture_data["DATA"]
        local size = texture_data["SIZE"]
        local key = texture_data["KEY"]
        addData(element, type, key, texture_name, data, nil, size, false);
    end
)


addEvent("mereRenamingID", true)
addEventHandler("mereRenamingID", root,
    function(old_id, new_id)
        if (ELEMENTS_DATA[old_id]) then
            for name, data in pairs(ELEMENTS_DATA[old_id]) do
                local texture_md5 = data[1]
                if (TEXTURES_DATA[name] and TEXTURES_DATA[name][texture_md5]) then
                    TEXTURES_DATA[name][texture_md5]["ELEMENTS_IDS"][old_id] = nil
                    TEXTURES_DATA[name][texture_md5]["ELEMENTS_IDS"][new_id] = true
                end
            end
            ELEMENTS_DATA[new_id] = ELEMENTS_DATA[old_id]
            ELEMENTS_DATA[old_id] = nil
        end
    end
)


-- addEvent("mereOnClone", true)
-- addEventHandler("mereOnClone", root,
--     function(cloned)
--         if (isElement(source) and isElement(cloned) and ELEMENTS_DATA[getElementID(source)]) then
--             for name, data in pairs(ELEMENTS_DATA[getElementID(source)]) do
--                 local texture_md5 = data[1]
--                 if (TEXTURES_DATA[name] and TEXTURES_DATA[name][texture_md5]) then
--                     local p = TEXTURES_DATA[name][texture_md5]
--                     local pixels = p["FULL"] and { { ['pixels'] = p["TEXTURE_PIXELS"], ['name'] = name } } or nil
--                     applyShader(cloned, p["FULL"], p["THRESHOLD"], name, pixels, p['RED'], p['GREEN'], p['BLUE'],
--                         p["ALPHA"], true, p["ORIGINAL"])
--                 end
--             end
--         end
--     end
-- )


addEvent("mereClientCopyToElements", true)
addEventHandler("mereClientCopyToElements", root,
    function(master, elements, textures_names)
        copyToElements(master, elements, textures_names);
    end
)


addEventHandler("onClientResourceStart", root,
    function(startedRes)
        local res = getResourceName(startedRes)
        if (res == "editor_test") then
            for _, element in ipairs(mergeTables(getElementsByType("object", source), getElementsByType("vehicle", source))) do
                local id = getElementID(element)
                if (id) then
                    local textures = ELEMENTS_DATA[id]
                    if (textures) then
                        for texture_name, texture_key in pairs(textures) do
                            local shader = TEXTURES_DATA[texture_name][texture_key]["SHADER"]
                            engineApplyShaderToWorldTexture(shader, texture_name, element, true)
                        end
                    end
                end
            end
        end
    end
)




function shaderCommandFunc()
    local shaders = getSetting("shaders")
    setSetting("shaders", not shaders)
    mereOutput("Texture shaders " .. (not shaders and "enabled" or "disabled"))



    if (shaders) then
        for element_id in pairs(ELEMENTS_DATA) do
            for texture_name in pairs(ELEMENTS_DATA[element_id]) do
                local element = getElementByID(element_id)
                local texture_key = ELEMENTS_DATA[element_id][texture_name]
                local shader = TEXTURES_DATA[texture_name][texture_key]["SHADER"]
                if (element and shader) then
                    engineRemoveShaderFromWorldTexture(shader, texture_name, element)
                end
            end
        end

        for name in pairs(TEXTURES_DATA) do
            local e_texture = TEXTURES_DATA[name][all_key]
            if (e_texture and e_texture["SHADER"]) then
                engineRemoveShaderFromWorldTexture(e_texture["SHADER"], name)
            end
        end
    else
        for name in pairs(TEXTURES_DATA) do
            local e_texture = TEXTURES_DATA[name][all_key]
            if (e_texture and e_texture["SHADER"]) then
                engineApplyShaderToWorldTexture(e_texture["SHADER"], name)
            end
        end

        for element_id in pairs(ELEMENTS_DATA) do
            for texture_name in pairs(ELEMENTS_DATA[element_id]) do
                local element = getElementByID(element_id)
                local texture_key = ELEMENTS_DATA[element_id][texture_name]
                local shader = TEXTURES_DATA[texture_name][texture_key]["SHADER"]
                if (element and shader) then
                    engineApplyShaderToWorldTexture(shader, texture_name, element)
                end
            end
        end
    end
end

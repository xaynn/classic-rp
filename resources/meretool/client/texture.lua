local isEnabled = false

local itemSize = 128
local gap = 10
local labelHeight = 20
local maxItems = 26

local textureIndex
local allTextureEntries = {}
local currentPage = 1
local currentTextures = {}
local selectedTextureIndex = nil
local selectedTextureData = nil
local selectedTextureIndexPage = nil

GUIEditor2 = {
    button = {},
    scrollpane = {},
    edit = {},
    combobox = {}
}

local selectedComboBox1 = 0
local selectedComboBox2 = 0


local myWindow = guiCreateWindow(0, 0, 1, 1, ":)", true)
guiWindowSetMovable(myWindow, false)
guiWindowSetSizable(myWindow, false)
guiSetAlpha(myWindow, 0)
guiSetVisible(myWindow, false)

addEventHandler("onClientResourceStart", resourceRoot, function()
    GUIEditor2.scrollpane[1] = guiCreateScrollPane(0.41, 0.03, 0.20, 0.25, true)
    GUIEditor2.edit[1] = guiCreateEdit(0.08, 0.03, 0.83, 0.12, "", true, GUIEditor2.scrollpane[1])
    GUIEditor2.combobox[1] = guiCreateComboBox(0.51, 0.25, 0.40, 0.62, "Both", true, GUIEditor2.scrollpane[1])
    guiComboBoxAddItem(GUIEditor2.combobox[1], "Original textures")
    guiComboBoxAddItem(GUIEditor2.combobox[1], "Custom textures")
    guiComboBoxAddItem(GUIEditor2.combobox[1], "Both")
    guiComboBoxSetSelected(GUIEditor2.combobox[1], 2)
    GUIEditor2.combobox[2] = guiCreateComboBox(0.08, 0.25, 0.41, 0.62, "Textures name", true, GUIEditor2.scrollpane[1])
    guiComboBoxAddItem(GUIEditor2.combobox[2], "Model ID")
    guiComboBoxAddItem(GUIEditor2.combobox[2], "Textures name")
    GUIEditor2.button[1] = guiCreateButton(0.38, 0.48, 0.24, 0.17, "Search", true, GUIEditor2.scrollpane[1])
    guiComboBoxSetSelected(GUIEditor2.combobox[2], 0)

    guiSetVisible(GUIEditor2.scrollpane[1], false)
    local file = fileOpen("client/texture_index.json", true)
    if file then
        local size = fileGetSize(file)
        local content = fileRead(file, size)
        textureIndex = fromJSON(content)
        fileClose(file)
    end
end)



-- addCommandHandler("create_texts",
--     function()
--         local textures = {}
--         for i = 0, 22000 do
--             local textures_names = engineGetModelTextureNames(i)
--             if (textures_names) then
--                 for _, name in ipairs(textures_names) do
--                     local lower_name = name:lower()
--                     if (not textures[lower_name]) then
--                         textures[lower_name] = { i, name }
--                     end
--                 end
--             end
--         end

--         local file = fileCreate("new.json")
--         fileWrite(file, toJSON(textures))
--         fileClose(file)
--     end
-- )


local screenW, screenH = guiGetScreenSize()
local areaX = 0
local areaY = screenH * 0.2074
local areaW = screenW
local areaH = screenH * 0.6843

local itemsPerRow = math.floor((areaW + gap) / (itemSize + gap))
local rows = math.ceil(maxItems / itemsPerRow)
local maxRows = math.floor((areaH + gap) / (itemSize + labelHeight + gap))
if rows > maxRows then
    rows = maxRows
    itemsPerRow = math.ceil(maxItems / rows)
end

local perPage = rows * itemsPerRow

local totalGridWidth = itemsPerRow * itemSize + (itemsPerRow - 1) * gap
local totalGridHeight = rows * (itemSize + labelHeight) + (rows - 1) * gap
local startX = areaX + (areaW - totalGridWidth) / 2
local startY = areaY + (areaH - totalGridHeight) / 2

local gridRects = {}

local function updateGridRects()
    gridRects = {}
    local x = startX
    local y = startY
    local i = 0
    for row = 1, rows do
        for col = 1, itemsPerRow do
            i = i + 1
            if i > maxItems then return end
            table.insert(gridRects, { x = x, y = y, w = itemSize, h = itemSize })
            x = x + itemSize + gap
        end
        x = startX
        y = y + itemSize + labelHeight + gap
    end
end

function destroyAllTextures()
    for _, t in ipairs(currentTextures) do
        if isElement(t.texture) then
            destroyElement(t.texture)
        end
    end
    currentTextures = {}
end

function loadCurrentPage()
    destroyAllTextures()
    updateGridRects()

    local startIndex = (currentPage - 1) * perPage + 1
    local loaded = 0
    local i = startIndex

    while loaded < perPage and i <= #allTextureEntries do
        local entry = allTextureEntries[i]
        local modelID = entry[2] -- or key
        local textureName = entry[1]
        local type = entry[3]    -- 0 = game tex , 1 = file text
        if (type == 0) then
            local textures = engineGetModelTextures(modelID, textureName)
            if textures and textures[textureName] then
                table.insert(currentTextures, {
                    texture = textures[textureName],
                    name = textureName,
                    model = modelID
                })
                loaded = loaded + 1
                i = i + 1
            else
                table.remove(allTextureEntries, i)
            end
        elseif (type == 1) then
            if (TEXTURES_DATA[textureName] and TEXTURES_DATA[textureName][modelID]) then
                local file = TEXTURES_DATA[textureName][modelID]["DATA"]["FILE"]
                if (file) then
                    local image = readPNGFile(MAP_NAME, file)
                    if (image) then
                        table.insert(currentTextures, {
                            texture = dxCreateTexture(image),
                            name = textureName .. "*",
                            model = modelID,
                            file = file,
                        })
                        loaded = loaded + 1
                        i = i + 1
                    else
                        table.remove(allTextureEntries, i)
                    end
                else
                    table.remove(allTextureEntries, i)
                end
            else
                table.remove(allTextureEntries, i)
            end
        end
    end
end

addCommandHandler("page",
    function(_, page)
        if not isEnabled then return end
        local page = tonumber(page)
        local maxPages = math.ceil(#allTextureEntries / perPage)
        if page > 1 and currentPage < maxPages then
            currentPage = page
            loadCurrentPage()
        end
    end
)

function searchTextures(type, texture_type, term)
    destroyAllTextures()
    allTextureEntries = {}
    currentPage = 1
    selectedTextureIndex = nil
    selectedTextureIndexPage = nil
    selectedTextureData = nil

    if (type == 1) then
        term = term and term:lower() or ""

        for textureName, data in pairs(textureIndex) do
            if term == "" or string.find(textureName:lower(), term, 1, true) then
                if (texture_type ~= 1) then
                    table.insert(allTextureEntries, { data[2], data[1], 0 })
                end
                if (texture_type ~= 0) then
                    if (TEXTURES_DATA[data[2]]) then
                        for key in pairs(TEXTURES_DATA[data[2]]) do
                            local hasFile = TEXTURES_DATA[data[2]][key]["DATA"]["FILE"]
                            if (hasFile) then
                                table.insert(allTextureEntries, { data[2], key, 1 })
                            end
                        end
                    end
                end
            end
        end
    elseif (type == 0) then
        if (term) then
            local textures = engineGetModelTextureNames(term)
            if textures then
                for _, textureName in ipairs(textures) do
                    if (texture_type ~= 1) then
                        table.insert(allTextureEntries, { textureName, term, 0 })
                    end
                    if (texture_type ~= 0) then
                        if (TEXTURES_DATA[textureName]) then
                            for key in pairs(TEXTURES_DATA[textureName]) do
                                local hasFile = TEXTURES_DATA[textureName][key]["DATA"]["FILE"]
                                if (hasFile) then
                                    table.insert(allTextureEntries, { textureName, key, 1 })
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    if #allTextureEntries == 0 then
        -- mereOutput("No textures found for: " .. term)
    else
        loadCurrentPage()
    end
end

function previousPage()
    if not isEnabled then return end
    if currentPage > 1 then
        currentPage = currentPage - 1
        loadCurrentPage()
    end
end

function nextPage()
    if not isEnabled then return end
    local maxPages = math.ceil(#allTextureEntries / perPage)
    if currentPage < maxPages then
        currentPage = currentPage + 1
        loadCurrentPage()
    end
end

function getGridTileFromMouse(mx, my)
    for i, rect in ipairs(gridRects) do
        if mx >= rect.x and mx <= rect.x + rect.w and my >= rect.y and my <= rect.y + rect.h then
            return i
        end
    end
    return nil
end

addEventHandler("onClientClick", root, function(btn, state, x, y)
    if not isEnabled then return end
    if btn == "left" and state == "down" then
        local tile = getGridTileFromMouse(x, y)
        if tile and currentTextures[tile] then
            selectedTextureIndex = tile
            selectedTextureData = currentTextures[tile]
            selectedTextureIndexPage = currentPage
            return
        end
        -- left arrow
        local leftX, leftY, leftW, leftH = screenW * 0.4208, screenH * 0.9009, screenW * 0.4469, screenH * 0.9343
        if x >= leftX and x <= leftW and y >= leftY and y <= leftH then
            previousPage()
            return
        end
        -- right arrow
        local rightX, rightY, rightW, rightH = screenW * 0.5531, screenH * 0.9009, screenW * 0.5792, screenH * 0.9343
        if x >= rightX and x <= rightW and y >= rightY and y <= rightH then
            nextPage()
            return
        end
        -- close button
        local closeX, closeY, closeW, closeH = screenW * 0.9776, screenH * 0.0278, screenW * 0.0141, screenH * 0.0231
        if x >= closeX and x <= closeX + closeW and y >= closeY and y <= closeY + closeH then
            isEnabled = false
            showChat(true)
            showCursor(false)
            if (isEventHandlerAdded("onClientKey", root, cancelAllKeys)) then
                removeEventHandler("onClientKey", root, cancelAllKeys)
            end
            guiSetVisible(myWindow, false)
            guiSetVisible(GUIEditor2.scrollpane[1], false)
            exports["editor_gui"]:setGUIShowing(true)
            exports["editor_gui"]:setHUDAlpha(100)
            return
        end
        -- set button
        local setX, setY, setW, setH = screenW * 0.4849, screenH * 0.9556, screenW * 0.0307, screenH * 0.0352
        if x >= setX and x <= setX + setW and y >= setY and y <= setY + setH and selectedTextureData then
            isEnabled = false
            showChat(true)
            showCursor(false)
            if (isEventHandlerAdded("onClientKey", root, cancelAllKeys)) then
                removeEventHandler("onClientKey", root, cancelAllKeys)
            end
            guiSetVisible(myWindow, false)
            guiSetVisible(GUIEditor2.scrollpane[1], false)
            exports["editor_gui"]:setGUIShowing(true)
            exports["editor_gui"]:setHUDAlpha(100)
            if selectedTextureData then
                local element = getMode() == 0 and selectedElement or getMasterElement()
                local texture_name = guiComboBoxGetItemText(GUIEditor.combobox[1],
                    guiComboBoxGetSelected(GUIEditor.combobox[1]))
                if (element and isBrowserDataEqual(element, texture_name, getElementModel(element))) then
                    local pixels = nil
                    if (selectedTextureData.file) then
                        pixels = readPNGFile(MAP_NAME, selectedTextureData.file)
                    end
                    if (not pixels) then
                        pixels = dxGetTexturePixels(selectedTextureData.texture)
                        pixels = dxConvertPixels(pixels, "png")
                    end
                    local width, height = dxGetPixelsSize(pixels)
                    local filename = generateFilename(texture_name)
                    TEXTURE_CACHE[texture_name] = {
                        ["PIXELS"] = pixels,
                        ["WDITH"] = width,
                        ["HEIGHT"] = height,
                        ["TRANSPARENT"] = true,
                        ["SIZE"] = string.len(pixels or ""),
                        ["FILE"] = filename
                    }
                    syncShaders(2,
                        { ["FILE"] = filename, ["MD5"] = md5(pixels), ["TIMESTAMP"] = getRealTime().timestamp },
                        texture_name, true)
                else
                    mereOutput("Something went wrong, please try again.")
                end
            else
                mereOutput("No texture selected.")
            end
            return;
        end
    end
end)

addEventHandler("onClientRender", root, function()
    if not isEnabled then return end
    guiBringToFront(GUIEditor2.scrollpane[1])

    dxDrawRectangle(0, 0, screenW, screenH, tocolor(1, 0, 0, 124), false)
    dxDrawRectangle(areaX, areaY, areaW, areaH, tocolor(0, 0, 0, 124))

    if not currentTextures or #currentTextures == 0 then
        local msg = "No textures found"
        local textWidth = dxGetTextWidth(msg, 5.0, "default")
        local textX = areaX + (areaW - textWidth) / 2
        local textY = areaY + (areaH - labelHeight) / 2
        dxDrawText("No search results", textX, textY, textX + textWidth, textY + labelHeight,
            tocolor(255, 255, 255, 180), 5.0, "default", "center", "center", false, false, false, true)
    else
        for i, rect in ipairs(gridRects) do
            local textureData = currentTextures[i]
            if textureData then
                local color = tocolor(255, 255, 255, 40)
                if selectedTextureIndexPage == currentPage and selectedTextureIndex == i then
                    dxDrawRectangle(rect.x - 2, rect.y - 2, rect.w + 4, rect.h + 4, tocolor(20, 242, 77, 180))
                end
                dxDrawRectangle(rect.x, rect.y, rect.w, rect.h, color)
                local label = textureData.name or ("Tile " .. i)
                dxDrawImage(rect.x, rect.y, rect.w, rect.h, textureData.texture, 0, 0, 0, tocolor(255, 255, 255, 255),
                    true)
                dxDrawText(label, rect.x, rect.y + rect.h + 2, rect.x + rect.w, rect.y + rect.h + labelHeight,
                    tocolor(255, 255, 255, 255), 1.0, "default", "center", "top", false, false, false, true)
            end
        end
    end

    dxDrawText("↩", screenW * 0.4208, screenH * 0.9009, screenW * 0.4469, screenH * 0.9343, tocolor(255, 255, 255, 255),
        3.00, "default", "center", "center")
    dxDrawText("↪", screenW * 0.5531, screenH * 0.9009, screenW * 0.5792, screenH * 0.9343, tocolor(255, 255, 255, 255),
        3.00, "default", "center", "center")
    dxDrawText(currentPage .. "/" .. math.max(1, math.ceil(#allTextureEntries / perPage)), screenW * 0.4469,
        screenH * 0.9009, screenW * 0.5531, screenH * 0.9343, tocolor(255, 255, 255, 255), 3.00, "default", "center",
        "center", false, false, false, false, false)
    local enabled = selectedTextureData and tocolor(20, 242, 77, 124) or tocolor(105, 105, 105, 124)
    dxDrawRectangle(screenW * 0.4849, screenH * 0.9556, screenW * 0.0307, screenH * 0.0352, enabled)
    dxDrawText("SET", screenW * 0.4854, screenH * 0.9565, screenW * 0.5156, screenH * 0.9907, tocolor(255, 255, 255, 255),
        2.00, "default", "center", "center")
    dxDrawRectangle(screenW * 0.9776, screenH * 0.0278, screenW * 0.0141, screenH * 0.0231, tocolor(255, 95, 95, 235),
        false)
    dxDrawText("X", screenW * 0.9781, screenH * 0.0278, screenW * 0.9917, screenH * 0.0509,
        tocolor(255, 255, 255, 255), 2.00, "default", "center", "center")
end)




addEventHandler("onClientGUIClick", resourceRoot,
    function(btn, s)
        if (btn ~= "left" or s ~= "up") then return end
        if source == GUIEditor2.button[1] then
            local searchFor = guiGetText(GUIEditor2.edit[1]);
            local texture_type = selectedComboBox1 -- 0 = Original, 1 = Custom, 2 = Both
            local type = selectedComboBox2
            searchTextures(type, texture_type, searchFor)
        end
    end
)


addEventHandler("onClientGUIComboBoxAccepted", root,
    function(comboBox)
        local item = guiComboBoxGetSelected(comboBox)
        if (comboBox == GUIEditor2.combobox[1]) then
            selectedComboBox1 = item
        elseif (comboBox == GUIEditor2.combobox[2]) then
            selectedComboBox2 = item
        end
    end
)


function openTexturesBrowser()
    if isEnabled then return end
    if (guiGetVisible(browserGUI)) then return end;
    local element = getMode() == 0 and selectedElement or getMasterElement()
    local texture_name = guiComboBoxGetItemText(GUIEditor.combobox[1],
        guiComboBoxGetSelected(GUIEditor.combobox[1]))
    if (element) then
        if (texture_name ~= "*") then
            isEnabled = true
            setBrowserData(element, texture_name, getElementModel(element))
            if (not isEventHandlerAdded("onClientKey", root, cancelAllKeys)) then
                addEventHandler("onClientKey", root, cancelAllKeys)
            end
            guiSetVisible(GUIEditor.window[1], false)
            guiSetVisible(myWindow, true)
            guiSetVisible(GUIEditor2.scrollpane[1], true)
            showChat(false)
            showCursor(true)
            exports["editor_gui"]:setGUIShowing(false)
            exports["editor_gui"]:setHUDAlpha(0)
        else
            mereOutput("Choose the texture first.")
        end
    else
        mereOutput("Please select an element first.")
    end
end

function deleteAllTextureEntries()
    destroyAllTextures()
    allTextureEntries = {}
end

function isValidModel(ID)
    return engineGetModelNameFromID(ID) or engineGetModelIDFromName(ID)
end

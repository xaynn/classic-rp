selectedElements = {
    -- [index] = {["element"] = element, ["model"] = model}
};

local mode = 0 -- 0 = single, 1 = multiple
local arrowAnimationOffset = 0
local arrowAnimationSpeed = 0.02
local masterElement = nil

function setMasterElement(element)
    masterElement = element

    -- close the browser
    closeBrowser(true)
end

function getMasterElement()
    return masterElement
end

function findNewMaster()
    if #selectedElements > 0 then
        local texture_name = guiComboBoxGetItemText(GUIEditor.combobox[1], guiComboBoxGetSelected(GUIEditor.combobox[1]))
        if texture_name and texture_name ~= "*" then
            for _, v in ipairs(selectedElements) do
                local element = v["element"]
                local element_id = getElementID(element)
                local element_model = tostring(getElementModel(element))
                local texture_md5 = ELEMENTS_DATA[element_id] and ELEMENTS_DATA[element_id][texture_name]
                if texture_md5 then
                    local key = texture_md5 .. ',' .. texture_name
                    local p = DATA[element_model] and DATA[element_model][key]
                    if p then
                        setMasterElement(element)
                        return
                    end
                end
            end
        end
        setMasterElement(selectedElements[1]["element"])
    else
        setMasterElement(nil)
    end
end

local allowed_elements = { ["object"] = true, ["vehicle"] = true }
addEvent("onClientElementSelect", true)
addEventHandler("onClientElementSelect", root,
    function()
        if (not source) then return end;
        if (mode == 0) then return end;
        if (not guiGetVisible(GUIEditor.window[1])) then return end;
        local index = getIndexFromElement(source)
        if (not index and allowed_elements[getElementType(source)]) then
            table.insert(selectedElements, { ["element"] = source, ["model"] = getElementModel(source) })
            if #selectedElements == 1 then
                setMasterElement(source)
            end
        else
            if source == masterElement then
                table.remove(selectedElements, index)
                findNewMaster()
            else
                table.remove(selectedElements, index)
            end
        end

        if (#selectedElements > 0) then
            guiSetText(GUIEditor.button[1], "Clear")
            setModelTextureNames();
        else
            guiSetText(GUIEditor.button[1], "Multiple")
            setMasterElement(nil)
        end

        updateGUI()
    end
)

function getIndexFromElement(element)
    for i, v in ipairs(selectedElements) do
        if v["element"] == element then
            return i
        end
    end
    return nil
end

function getMode()
    return mode
end

function toggleMode()
    clearSelectedElements()
    mode = (mode == 0 and 1 or 0)
    if (mode == 0) then
        guiSetText(GUIEditor.button[1], "Single")
        setModelTextureNames();
    else
        guiSetText(GUIEditor.button[1], "Multiple")
    end
    closeBrowser(true)
end

function clearSelectedElements()
    selectedElements = {}
    setMasterElement(nil)
end

function getSelectedElements()
    return selectedElements
end

function cleanupSelectedElements()
    local elementsToRemove = {}
    for i, v in ipairs(selectedElements) do
        local dimension = isElement(v["element"]) and getElementDimension(v["element"]) or 0
        if not isElement(v["element"]) or getElementModel(v["element"]) ~= v["model"] or dimension ~= exports["editor_main"]:getWorkingDimension() then
            table.insert(elementsToRemove, v["element"])
        end
    end

    for i, v in ipairs(elementsToRemove) do
        removeElement(v)
    end

    if (#selectedElements == 0) then
        guiSetText(GUIEditor.button[1], "Multiple")
        setMasterElement(nil)
        setModelTextureNames();
    end
end

function removeElement(element)
    for i, v in ipairs(selectedElements) do
        if v["element"] == element then
            table.remove(selectedElements, i)
            return
        end
    end
end

addEventHandler("onClientRender", root, function()
    if getMode() == 1 and isEditorActive() then
        cleanupSelectedElements()

        if (not guiGetVisible(GUIEditor.window[1])) then return end;

        arrowAnimationOffset = arrowAnimationOffset + arrowAnimationSpeed
        if arrowAnimationOffset > 1 then
            arrowAnimationOffset = 0
        end

        local camX, camY, camZ = getCameraMatrix()

        for _, v in ipairs(selectedElements) do
            local element = v["element"]

            if isElement(element) then
                local x, y, z = getElementPosition(element)
                local rx, ry, rz = getElementRotation(element)
                local minX, minY, minZ, maxX, maxY, maxZ = getElementBoundingBox(element)

                local distance = getDistanceBetweenPoints3D(camX, camY, camZ, x, y, z)
                local thickness = math.max(2, math.min(4, 150 / distance * 1))

                local r, g, b = 0, 255, 0 -- Default green
                if element == masterElement then
                    r, g, b = 255, 0, 0   -- Red for master
                end

                local elementMatrix = getElementMatrix(element)

                local faces = {
                    -- Top face
                    {
                        { minX, minY, maxZ },
                        { maxX, minY, maxZ },
                        { maxX, maxY, maxZ },
                        { minX, maxY, maxZ }
                    },
                    -- Bottom face
                    {
                        { minX, minY, minZ },
                        { maxX, minY, minZ },
                        { maxX, maxY, minZ },
                        { minX, maxY, minZ }
                    }
                }

                for i, face in ipairs(faces) do
                    for j, vertex in ipairs(face) do
                        local vx, vy, vz = vertex[1], vertex[2], vertex[3]
                        local transformedX = vx * elementMatrix[1][1] + vy * elementMatrix[2][1] +
                            vz * elementMatrix[3][1] + elementMatrix[4][1]
                        local transformedY = vx * elementMatrix[1][2] + vy * elementMatrix[2][2] +
                            vz * elementMatrix[3][2] + elementMatrix[4][2]
                        local transformedZ = vx * elementMatrix[1][3] + vy * elementMatrix[2][3] +
                            vz * elementMatrix[3][3] + elementMatrix[4][3]
                        faces[i][j] = { transformedX, transformedY, transformedZ }
                    end
                end

                local furthestNode, furthestDistance = nil, 0
                for _, face in ipairs(faces) do
                    for _, vertex in ipairs(face) do
                        local distance = getDistanceBetweenPoints3D(camX, camY, camZ, vertex[1], vertex[2], vertex[3])
                        if distance > furthestDistance then
                            furthestDistance = distance
                            furthestNode = vertex
                        end
                    end
                end

                for i, face in ipairs(faces) do
                    for j = 1, 4 do
                        local nextJ = j % 4 + 1
                        local v1, v2 = face[j], face[nextJ]

                        if not (vectorCompare(v1, furthestNode) or vectorCompare(v2, furthestNode)) then
                            dxDrawLine3D(v1[1], v1[2], v1[3], v2[1], v2[2], v2[3], tocolor(r, g, b, 255), thickness)
                        end
                    end
                end

                for i = 1, 4 do
                    local v1, v2 = faces[1][i], faces[2][i]
                    if not (vectorCompare(v1, furthestNode) or vectorCompare(v2, furthestNode)) then
                        dxDrawLine3D(v1[1], v1[2], v1[3], v2[1], v2[2], v2[3], tocolor(r, g, b, 255), thickness)
                    end
                end

                local centerX = (minX + maxX) / 2
                local centerY = (minY + maxY) / 2

                local objectWidth = math.max(4, maxX - minX)
                local objectHeight = math.max(4, maxY - minY)

                local arrowHeight = math.max(4, math.sqrt(objectWidth * objectWidth + objectHeight * objectHeight) * 0.2)
                local arrowSize = math.max(2, math.sqrt(objectWidth * objectWidth + objectHeight * objectHeight) * 0.15)

                local arrowOffset = math.sin(arrowAnimationOffset * math.pi * 2) * arrowHeight * 0.1

                local baseHeight = maxZ + arrowHeight * 0.8

                local arrowPoints = {
                    { centerX,                   centerY,                   baseHeight + arrowOffset },
                    { centerX,                   centerY,                   baseHeight - arrowHeight * 0.6 + arrowOffset },
                    { centerX - arrowSize * 0.1, centerY - arrowSize * 0.1, baseHeight - arrowHeight * 0.4 + arrowOffset },
                    { centerX + arrowSize * 0.1, centerY - arrowSize * 0.1, baseHeight - arrowHeight * 0.4 + arrowOffset },
                    { centerX + arrowSize * 0.1, centerY + arrowSize * 0.1, baseHeight - arrowHeight * 0.4 + arrowOffset },
                    { centerX - arrowSize * 0.1, centerY + arrowSize * 0.1, baseHeight - arrowHeight * 0.4 + arrowOffset }
                }

                local transformedPoints = {}
                for _, point in ipairs(arrowPoints) do
                    local px, py, pz = point[1], point[2], point[3]
                    local transformedX = px * elementMatrix[1][1] + py * elementMatrix[2][1] + pz * elementMatrix[3][1] +
                        elementMatrix[4][1]
                    local transformedY = px * elementMatrix[1][2] + py * elementMatrix[2][2] + pz * elementMatrix[3][2] +
                        elementMatrix[4][2]
                    local transformedZ = px * elementMatrix[1][3] + py * elementMatrix[2][3] + pz * elementMatrix[3][3] +
                        elementMatrix[4][3]
                    table.insert(transformedPoints, { transformedX, transformedY, transformedZ })
                end

                dxDrawLine3D(
                    transformedPoints[1][1], transformedPoints[1][2], transformedPoints[1][3],
                    transformedPoints[2][1], transformedPoints[2][2], transformedPoints[2][3],
                    tocolor(r, g, b, 255), thickness * 1.5
                )

                for i = 3, 6 do
                    dxDrawLine3D(
                        transformedPoints[2][1], transformedPoints[2][2], transformedPoints[2][3],
                        transformedPoints[i][1], transformedPoints[i][2], transformedPoints[i][3],
                        tocolor(r, g, b, 255), thickness * 1.5
                    )
                end
            end
        end
    end
end)

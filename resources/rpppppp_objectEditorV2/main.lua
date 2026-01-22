---- SCRIPT CONFIG

POSITION_STRENGTH = 6
ROTATION_STRENGTH = 250
SCALE_STRENGTH = 1
local tempObjects = {}
---- SCRIPT VARIABLES

createdObjects = {}
editedObjects = {}

local undo = {}

isInX = false
isInY = false
isInZ = false

canXYZ = {
    false,
    false,
    false
}

editMode = false

psx1, psy1 = 0
selectedElement = nil

editorMode = {
    true, -- position
    false, -- rotation
    false -- scale
}
local tempObjTexturesData = {} -- a, b
local undoIndex = 0
local redoIndex = 0

function checkPermission()
    -- funkcja ktora bedzie sprawdzac permisje do obiektu
    return true
end
local tempObj = false

function selectClick( button, state, clickedElement )
    if button == "left" then
        if state == "down" then
            psx1, psy1 = getCursorPosition()
            if clickedElement ~= selectedElement and clickedElement ~= localPlayer and clickedElement then
                if getElementType ( clickedElement ) ~= "vehicle" and checkPermission() == true and isInX == false and isInY == false and isInZ == false then
                    selectedElement = objectOps.selectObject(clickedElement)
					tempObj = selectedElement
                end
            end
        end
    else
        if selectedElement then selectedElement = objectOps.deSelectObject(selectedElement) end
    end
end

local func1, func21

-- CFrame to nazwa na wszystko - rotacje, pozycje, wielkosc
function startCFrameUpdate()
    cursorX1, cursorY1 = getCursorPosition()
    cursorX1, cursorY1 = cursorX1 * screenX, cursorY1 * screenY
    canXYZ[1] = isInX
    canXYZ[2] = isInY
    canXYZ[3] = isInZ
end

function stopCFrameUpdate()
    canXYZ[1] = false
    canXYZ[2] = false
    canXYZ[3] = false
end

function CFrameClick( button, state )
    if button == "left" then
        if state == "down" then
            if isInX or isInY or isInZ then
                startCFrameUpdate()
            end
        else
            if canXYZ[1] or canXYZ[2] or canXYZ[3] then
                if selectedElement then
                    undoUpdate(false, false, selectedElement)
                end
            end
            stopCFrameUpdate()
        end
    else
        stopCFrameUpdate()
    end
end

local guiFunctions = {
    (function() rot_or_pos = "pos" changeMode() end),
    (function() rot_or_pos = "rot" changeMode() end),
    (function() rot_or_pos = "scale" changeMode() end),
    (function() doUndo() end),
    (function() doRedo() end),
    (function() 
        local newObj = objectOps.cloneObject(selectedElement)
        table.insert(createdObjects, {newObj, false})
        selectedElement = newObj
        undoUpdate(true, false, selectedElement)
        undoUpdate(false, false, selectedElement)
    end),
    (function() turnOnPropertiesWindow() end),
    (function() saveEditedObjects() saveCreatedObjects() turnEditMode() end),
    (function() 
        if selectedElement then
            local obj = selectedElement
            removeObject(obj)
            undoUpdate(false, false, obj)
			-- usuwanie
        end
    end),
    (function() turnEditMode() cancel() end)
}

function optionsClick( button, state )
    if button == "left" then
        if state == "up" then
            for i, v in ipairs(buttonsLocations) do
                if v[5] == true then 
                    guiFunctions[i]()
                end
            end
        end
    end
end

function onMouseClick( button, fstate, absoluteX, absoluteY, worldX, worldY, worldZ, clickedElement )
    if editMode then
		if not tempObj then
			for k,v in ipairs(tempObjects) do
			iprint(v.obj, clickedElement)
		if v.obj ~= clickedElement then return outputChatBox("bad obj") end 
		
	end
	end
        selectClick(button, fstate, clickedElement)
        CFrameClick(button, fstate)
        optionsClick(button, fstate)
    end
end

function changeMode()
    if editMode then
        if rot_or_pos == "rot" then
            editorMode[2] = true
            editorMode[1] = false
            editorMode[3] = false
        elseif rot_or_pos == "pos" then
            editorMode[2] = false
            editorMode[1] = true
            editorMode[3] = false
        else
            editorMode[2] = false
            editorMode[1] = false
            editorMode[3] = true
        end
        axis_mode = tostring(new_axis_mode)
    end
end

function clearCreatedObjects(table)
    for i, v in ipairs(table) do
        if v[1] then
            destroyElement(v[1])
            i = nil
        end
    end
end

function saveEditedObjects()
    if #editedObjects > 0 then
        local objectsPackage = {}
        for _, object in ipairs(editedObjects) do
            table.insert(objectsPackage, objectOps.packEditedObject(object["Object"], object["Delete"]))
        end

        --clears edited table
        editedObjects = {}

        --sends data to server
		local lastID
		local posx, posy, posz = getElementPosition(tempObj)
		local posTable = {posx, posy, posz}
		local rotx, roty, rotz = getElementRotation(tempObj)
		local textureImageA
		local textureImageB
		local rotTable = {rotx, roty, rotz}
		
		outputChatBox("empty data")
			for k,v in pairs(tempObjects) do
			if v.obj == tempObj then 
				lastID = v.lastObjectID
				textureImageA = v.textureImageA
				textureImageB = v.textureImageB
				outputChatBox("set data")
			end
		end
        triggerServerEvent ( "updateObj", localPlayer, lastID, rotTable, posTable, textureImageA, textureImageB )
    end
end

function saveCreatedObjects()
    if #createdObjects > 0 then
        local objectsPackage = {}
        for i, object in ipairs(createdObjects) do
            if object[2] == true then
                destroyElement(object[1])
                object[1] = nil
            else
                table.insert(objectsPackage, objectOps.packCreatedObject(object[1]))
            end
        end
        
        --clears createdTable and destroys all objects in it



		local lastID
		local posx, posy, posz = getElementPosition(tempObj)
		local posTable = {posx, posy, posz}
		local rotx, roty, rotz = getElementRotation(tempObj)
		local textureImageA = tempObjTexturesData[tempObj].a
		local textureImageB = tempObjTexturesData[tempObj].b
		local rotTable = {rotx, roty, rotz}
		iprint(textureImageA, textureImageB)
		outputChatBox("empty data")
		
        -- triggerServerEvent ( "updateObj", localPlayer, lastID, rot, pos, textureImageA, textureImageB )
        --sends data to server
        triggerServerEvent ( "createObj", localPlayer, getElementModel(tempObj), posTable, rotTable, textureImageA, textureImageB)
		clearCreatedObjects(createdObjects)
        createdObjects = {}
    end
end

function undoUpdate(created, deleted, object)
    local isInEditedObjects = {false, 0}
    if undoIndex < #undo then
        for i = #undo, 1, -1 do
            if i > undoIndex then
                table.remove(undo, i)
            end
        end
    end

    for i, v in ipairs(editedObjects) do
        if object == v["Object"] then
            isInEditedObjects = {true, i}
        end
    end
    local posX, posY, posZ, rotX, rotY, rotZ, scale = objectOps.getObjectCFrame(object)
    table.insert(undo,
        {
            ["ModelID"] = getElementModel(object),
            ["Edited"] = isInEditedObjects,
            ["Deleted"] = deleted,
            ["Created"] = created,
            ["Object"] = object,
            ["Position"] = {posX, posY, posZ},
            ["Rotation"] = {rotX, rotY, rotZ},
            ["Size"] = scale
        }
    )
    undoIndex = #undo
    redoIndex = #undo
end

function jobUndo()
    local object = undo[undoIndex]["Object"]
    local x, y, z = unpack(undo[undoIndex]["Position"])
    local rx, ry, rz = unpack(undo[undoIndex]["Rotation"])
    local scale = undo[undoIndex]["Size"]
    local modelID = undo[undoIndex]["ModelID"]

    local created = undo[undoIndex]["Created"]
    local deleted = undo[undoIndex]["Deleted"]
    local edited = undo[undoIndex]["Edited"][1]
    local index = false
    if edited then
        index = undo[undoIndex]["Edited"][2]
    else
        for i, v in ipairs(createdObjects) do
            if v[1] == object then index = i break end
        end
    end

    if created then
        if edited then
            editedObjects[index]["Delete"] = true
            setElementAlpha(object, 0)
            setElementCollisionsEnabled ( object, false ) 
            selectedElement = nil
        else
            createdObjects[index][2] = true -- delete
            setElementAlpha(object, 0)
            setElementCollisionsEnabled ( object, false ) 
            selectedElement = nil
        end
    elseif deleted then
        if edited then
            editedObjects[index]["Delete"] = false
            setElementAlpha(object, 255)
            setElementCollisionsEnabled ( object, true ) 
        else
            createdObjects[index][2] = false -- delete
            setElementAlpha(object, 255)
            setElementCollisionsEnabled ( object, true ) 
        end
    else
        objectOps.setObjectCFrame(object, x, y, z, rx, ry, rz, scale )
    end
end

function doUndo()
    if undoIndex > 1 then
        justDeleted = false
        redoIndex = undoIndex
        undoIndex = undoIndex - 1
        jobUndo()
        if undoIndex == 1 then redoIndex = 1 end
    end
end

function jobRedo()
    local object = undo[redoIndex]["Object"]
    local x, y, z = unpack(undo[redoIndex]["Position"])
    local rx, ry, rz = unpack(undo[redoIndex]["Rotation"])
    local scale = undo[redoIndex]["Size"]
    local modelID = undo[redoIndex]["ModelID"]

    local created = undo[redoIndex]["Created"]
    local deleted = undo[redoIndex]["Deleted"]
    local edited = undo[redoIndex]["Edited"][1]
    local index = false
    if edited then
        index = undo[undoIndex]["Edited"][2]
    else
        for i, v in ipairs(createdObjects) do
            if v[1] == object then index = i break end
        end
    end

    if created then
        if edited then
            editedObjects[index]["Delete"] = false
            setElementAlpha(object, 255)
            setElementCollisionsEnabled ( object, true ) 
        else
            createdObjects[index][2] = false
            setElementAlpha(object, 255)
            setElementCollisionsEnabled ( object, true ) 
        end
    elseif deleted then
        if edited then
            editedObjects[index]["Delete"] = true
            setElementAlpha(object, 0)
            setElementCollisionsEnabled ( object, false ) 
            selectedElement = nil
        else
            createdObjects[index][2] = true
            setElementAlpha(object, 0)
            setElementCollisionsEnabled ( object, false ) 
            selectedElement = nil
        end
    else
        objectOps.setObjectCFrame(object, x, y, z, rx, ry, rz, scale )
    end
end

function doRedo()
    if redoIndex < #undo then
        jobRedo()
        redoIndex = redoIndex + 1
        undoIndex = redoIndex
    elseif redoIndex == #undo then
        jobRedo()
        undoIndex = #undo
        redoIndex = redoIndex + 1
    end
end

function cancel()
    if #editedObjects > 0 then
        for _, objectTable in ipairs(editedObjects) do
            local object = objectTable["Object"]
            local x, y, z = unpack(objectTable["Position"])
            local rx, ry, rz = unpack(objectTable["Rotation"])
            local scale = objectTable["Size"]
            objectOps.setObjectCFrame(object, x, y, z, rx, ry, rz, scale)

            if objectTable["Delete"] == true then
                setElementAlpha(object, 255)
                setElementCollisionsEnabled ( object, true ) 
            end
        end
    end

    clearCreatedObjects(createdObjects)
    createdObjects = {}
    editedObjects = {}
end

function removeObject(object)
    for i, v in ipairs(createdObjects) do
        if v[1] == object then
            v[2] = true
            undoUpdate(false, true, object)
            selectedElement = nil
            setElementAlpha(object, 0)
            setElementCollisionsEnabled ( object, false ) 
            return
        end
    end

    for i, v in ipairs(editedObjects) do
        if object == v["Object"] then
            v["Delete"] = true
            undoUpdate(false, true, object)
            selectedElement = nil
            setElementAlpha(object, 0)
            setElementCollisionsEnabled ( object, false ) 
        end
    end
end
----- Script commands

local bottomImagesAndText = {
    {dxCreateTexture('images/move.png', _, true, "clamp"), "Zmiana pozycji"},
    {dxCreateTexture('images/rotate.png', _, true, "clamp"), "Zmiana rotacji"},
    {dxCreateTexture('images/scale.png', _, true, "clamp"), "Zmiana skali"},
    {dxCreateTexture('images/undo.png', _, true, "clamp"), "Cofnij"},
    {dxCreateTexture('images/redo.png', _, true, "clamp"), "Przywróć"},
    {dxCreateTexture('images/clone.png', _, true, "clamp"), "Sklonuj"},
    {dxCreateTexture('images/properties.png', _, true, "clamp"), "Właściwości"},
    {dxCreateTexture('images/save.png', _, true, "clamp"), "Zapisz"},
    {dxCreateTexture('images/remove.png', _, true, "clamp"), "Usuń"},
    {dxCreateTexture('images/cancel.png', _, true, "clamp"), "Anuluj"}
}

-- HERE THE SCRIPT ACTUALLY STARTS (AFTER edit COMMAND) / rozpoczecie edycji - TUTAJ SKRYPT SIE ZACZYNA PO WYWOLANIU
function turnEditMode(lastObjectServerID, objElement, objectID, position, rotation)
    if not editMode then
		tempObjects = exports.rp_interiors:getTempTextureObjectsInInterior()
		createScrollPane()
        editMode = not editMode
        showCursor( true, false )
        toggleControl ( "fire", false ) 
        for _, v in ipairs(gui) do
            guiSetVisible(v, true)
        end
        addEventHandler ("onClientClick", root, onMouseClick)
        addEventHandler("onClientRender", root, function()
            dxGui.drawVerticalGui(bottomImagesAndText, 10, 45, 45, "left", "bottom", 675)
            dxGui.drawAxisLines()
        end)
    else
        editMode = not editMode
        for _, v in ipairs(gui) do
            guiSetVisible(v, false)
        end
        showCursor( false, false )
        toggleControl ( "fire", true ) 
        stopCFrameUpdate()
        removeEventHandler ( "onClientClick", root, onMouseClick )
        removeEventHandler("onClientRender", root, function()
            dxGui.drawVerticalGui(bottomImages, 10, 45, 45, "left", "bottom", 675)
            dxGui.drawAxisLines()
        end)
        isInX = false
        isInY = false
        isInZ = false
        undo = {}
        undoIndex = 0
        selectedElement = nil
    end
end
DGS = exports.dgs
local scaleValue = exports.rp_scale:returnScaleValue()
local tempTextureType = "b"

function createScrollPane()
    local offsetX, offsetY = exports.rp_scale:returnOffsetXY()
    local windowWidth, windowHeight = 350 * scaleValue, 400 * scaleValue

    local startX, startY = exports.rp_scale:getScreenStartPositionFromBox(windowWidth, windowHeight, offsetX, 0, "right", "center")
    local window = DGS:dgsCreateWindow(startX, startY, windowWidth, windowHeight + 50 * scaleValue, "Tekstury", false)
    DGS:dgsWindowSetSizable(window, false)
    DGS:dgsWindowSetMovable(window, true)

    local checkbox = DGS:dgsCreateCheckBox(10 * scaleValue, 10 * scaleValue, 150 * scaleValue, 20 * scaleValue, "Edytowanie tekstury A", false, false, window)

    local padding = 10 * scaleValue
    local scrollpaneWidth = windowWidth - 2 * padding
    local scrollpaneHeight = windowHeight - 2 * padding - 25 * scaleValue
    local scrollpane = DGS:dgsCreateScrollPane(padding, padding + 50 * scaleValue, scrollpaneWidth, scrollpaneHeight, false, window)

    local buttonSize = 50 * scaleValue
    local spacing = 10 * scaleValue
    local buttonsPerRow = 5

    for i = 1, 343 do
        local row = math.floor((i - 1) / buttonsPerRow)
        local col = (i - 1) % buttonsPerRow

        local x = col * (buttonSize + spacing)
        local y = row * (buttonSize + spacing)

        local imagePath = ":rp_interiors/files/images/" .. i .. ".jpg"
        if fileExists(imagePath) then
            local texture = dxCreateTexture(imagePath)
            local button = DGS:dgsCreateButton(x, y, buttonSize, buttonSize, "", false, scrollpane)
            DGS:dgsSetProperty(button, "image", {texture, texture, texture})

            -- Tooltip
            local tooltip = DGS:dgsCreateToolTip()
            DGS:dgsTooltipApplyTo(tooltip, button, "Tekstura #" .. i)

            addEventHandler("onDgsMouseClick", button, function(btn, state)
                if btn == "left" and state == "down" then
                    outputChatBox("Kliknięto teksturę #" .. i .. (DGS:dgsCheckBoxGetSelected(checkbox) and " (tryb A)" or " (tryb B)"))
					exports.rp_interiors:applyTextureToObject(tempObj, ":rp_interiors/files/images/" .. i .. ".jpg", tempTextureType)
					if not tempObjTexturesData[tempObj] then tempObjTexturesData[tempObj] = {} end
					if DGS:dgsCheckBoxGetSelected(checkbox) then
						tempObjTexturesData[tempObj].a = i
						else
						tempObjTexturesData[tempObj].b = i
					end
                end
            end, false)
        end
    end

    addEventHandler("onDgsMouseClick", checkbox, function(btn, state)
        if btn == "left" and state == "down" then
            local isSelected = DGS:dgsCheckBoxGetSelected(checkbox)
            outputChatBox("Tryb edycji: " .. (isSelected and "Tekstura A" or "Tekstura B"))
			if isSelected then tempTextureType = "a" else tempTextureType = "b" end
        end
    end, false)
end


addCommandHandler( "edit", function()
    turnEditMode()
end)

----- Temp script commands

addCommandHandler ( "create", function(arg0, objectID, x_pos, y_pos, z_pos)
	local x,y,z = getElementPosition(localPlayer)
	tempObjects = exports.rp_interiors:getTempTextureObjectsInInterior()
	iprint(tempObjects)
	-- table.insert()
    if objectID  then
        local object = createObject(objectID,x, y, z)
        table.insert(createdObjects, { object, false })
		setElementDimension(object, getElementDimension(localPlayer))
		setElementInterior(object, getElementInterior(localPlayer))
		tempObj = object
       
    end
end)

----- Utility commands

-- get the camera direction, plr position, and direction percentage / outputuje na chacie kierunek kamery, procent kierunku i pozycje gracza
addCommandHandler( "plrPos", function()
    local x, y, z = getElementPosition(localPlayer)
    local face_lr, face_fb, face_ud, face_lrP, face_fbP = cameraCalc.getPlayerFace()
    outputChatBox("Player position: x: " .. tostring(x) .. " y: " .. tostring(y) .. " z: " .. tostring(z))
    local x, y, z, lx, ly, lz = getCameraMatrix()
    local x_value, y_value, z_value = utility.findRotation3D(x, y, z, lx, ly, lz)
    outputChatBox("Camera look at coordinates: x:" .. tostring(x_value) .. " y: " .. tostring(y_value) .. " z: " .. tostring(z_value))
    outputChatBox("")
    outputChatBox("Camera is facing: " .. face_fb .. " " .. face_fbP * 100 .. "% " .. face_lr .. " " .. face_lrP * 100 .. "%")
    outputChatBox("")
    outputChatBox(face_ud)
end)

addCommandHandler("testobj", function()
    triggerServerEvent("test", resourceRoot)
end)

-- createScrollPane()
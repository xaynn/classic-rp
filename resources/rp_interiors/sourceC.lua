local interiorGui = {}
interiorGui.showed = false
local interiorData = {}
DGS = exports.dgs
local sx,sy = guiGetScreenSize()
local scaleValue = exports.rp_scale:returnScaleValue()
local offSetX, offsetY = exports.rp_scale:returnOffsetXY()
interiorGui.x, interiorGui.y = 508 * scaleValue, 108 * scaleValue
interiorGui.startX, interiorGui.startY = exports.rp_scale:getScreenStartPositionFromBox(interiorGui.x, interiorGui.y,0, offsetY, "center", "bottom")
interiorGui.font = dxCreateFont("files/font.ttf", 15 * scaleValue, false, "proof")
interiorGui.loadedObjects = false
interiorGui.tempObjects = {}
local appliedObjectsTexture = {}

function getTempTextureObjectsInInterior()
	return interiorGui.tempObjects
end

function onPlayerShowInterior(name, description, locked, id, state)
    interiorGui.showed = state
	-- iprint(name,description,locked,id)
    if interiorGui.showed then
		interiorData.name, interiorData.description, interiorData.locked, interiorData.id = name, description, locked, id
		if isEventHandlerAdded("onClientRender", root, renderInterior) then
			removeEventHandler("onClientRender", root, renderInterior)
		end
        addEventHandler("onClientRender", root, renderInterior)
    else
        removeEventHandler("onClientRender", root, renderInterior)
    end
end
addEvent("onPlayerShowInterior", true)
addEventHandler("onPlayerShowInterior", root, onPlayerShowInterior)

function renderInterior()
    dxDrawRoundedRectangle(interiorGui.startX,interiorGui.startY,interiorGui.x,interiorGui.y,5,tocolor(19,23,24,255),false,true)
    dxDrawText(interiorData.name .. " (ID: " .. interiorData.id .. ")",interiorGui.startX + 250 * scaleValue,interiorGui.startY,interiorGui.startX + 250 * scaleValue,interiorGui.startY,tocolor(255, 255, 255, 255),1.00,interiorGui.font,"center","top",false,false,false,false,false)
    dxDrawText(interiorData.description,interiorGui.startX + 7 * scaleValue,interiorGui.startY + 35 * scaleValue,interiorGui.startX + interiorGui.x - 40 * scaleValue,interiorGui.startY + 35 * scaleValue,tocolor(255, 255, 255, 255),1.00,interiorGui.font,"left","top",false,true,false,false,false)
    dxDrawRectangle(interiorGui.startX,interiorGui.startY + 30 * scaleValue,interiorGui.x,1 * scaleValue,tocolor(125, 109, 237, 255))
    if interiorData.locked then
        dxDrawImage(interiorGui.startX + 450 * scaleValue,interiorGui.startY + 45 * scaleValue,44 * scaleValue,44 * scaleValue,"files/locked_icon.png",0,0,0,tocolor(255, 255, 255, 255),false)
    else
        dxDrawImage(interiorGui.startX + 450 * scaleValue,interiorGui.startY + 45 * scaleValue,44 * scaleValue,44 * scaleValue,"files/unlocked_icon.png",0,0,0,tocolor(255, 255, 255, 255),false)
    end
end




function dxDrawRoundedRectangle(x, y, width, height, radius, color, postGUI, subPixelPositioning)
    dxDrawRectangle(x+radius, y+radius, width-(radius*2), height-(radius*2), color, postGUI, subPixelPositioning)
    dxDrawCircle(x+radius, y+radius, radius, 180, 270, color, color, 16, 1, postGUI)
    dxDrawCircle(x+radius, (y+height)-radius, radius, 90, 180, color, color, 16, 1, postGUI)
    dxDrawCircle((x+width)-radius, (y+height)-radius, radius, 0, 90, color, color, 16, 1, postGUI)
    dxDrawCircle((x+width)-radius, y+radius, radius, 270, 360, color, color, 16, 1, postGUI)
    dxDrawRectangle(x, y+radius, radius, height-(radius*2), color, postGUI, subPixelPositioning)
    dxDrawRectangle(x+radius, y+height-radius, width-(radius*2), radius, color, postGUI, subPixelPositioning)
    dxDrawRectangle(x+width-radius, y+radius, radius, height-(radius*2), color, postGUI, subPixelPositioning)
    dxDrawRectangle(x+radius, y, width-(radius*2), radius, color, postGUI, subPixelPositioning)
end

local interiorCreateGui = {}
interiorCreateGui.showed = false
interiorCreateGui.width, interiorCreateGui.height = 400 * scaleValue, 400 * scaleValue
interiorCreateGui.x, interiorCreateGui.y = exports.rp_scale:getScreenStartPositionFromBox(interiorCreateGui.width, interiorCreateGui.height, 0, 0, "center", "center") 
local interiorGuiElements = {}
-- tworzenie intka w gui, potem triggerServerEvent z rzeczami.
function onPlayerTryToCreateInterior()
	interiorGuiElements.showed = not interiorGuiElements.showed
	if interiorGuiElements.showed then
    interiorGuiElements.window = exports.rp_library:createWindow("interiorCreateWindow", interiorCreateGui.x,interiorCreateGui.y, interiorCreateGui.width, interiorCreateGui.height, "Tworzenie interioru", 5, 0.55*scaleValue, true)
	interiorGuiElements.interiorName = exports.rp_library:createEditBox("interior:editboxName", 10*scaleValue,10*scaleValue,150*scaleValue,30*scaleValue, "", interiorGuiElements.window, 0.5*scaleValue, 0.65*scaleValue, 20, false, "Nazwa interioru", false, 5)--(id,x,y,w,h,text,parent,caretHeight,textSize,maxLength,masked,placeHolder,padding,corners)
	interiorGuiElements.interiorType = exports.rp_library:createEditBox("interior:editboxType", 10*scaleValue,50*scaleValue,150*scaleValue,30*scaleValue, "", interiorGuiElements.window, 0.5*scaleValue, 0.7*scaleValue, 1, false, "Typ interioru", false, 5)
	interiorGuiElements.interiorDesc = exports.rp_library:createEditBox("interior:editboxDesc", 10*scaleValue,90*scaleValue,150*scaleValue,30*scaleValue, "", interiorGuiElements.window, 0.5*scaleValue, 0.7*scaleValue, 20, false, "Opis interioru", false, 5)
	interiorGuiElements.interiorID = exports.rp_library:createEditBox("interior:editboxInteriorID", 10*scaleValue,130*scaleValue,150*scaleValue,30*scaleValue, "", interiorGuiElements.window, 0.5*scaleValue, 0.7*scaleValue, 3, false, "ID intka z GTA", false, 5) -- 50 puste, tutaj mozna robic intki, budowac
	interiorGuiElements.owner = exports.rp_library:createEditBox("interior:editboxOwner", 10*scaleValue,170*scaleValue,150*scaleValue,30*scaleValue, "", interiorGuiElements.window, 0.5*scaleValue, 0.6*scaleValue, 3, false, "ID Gracza, ownera", false, 5) -- 50 puste, tutaj mozna robic intki, budowac
	interiorGuiElements.price = exports.rp_library:createEditBox("interior:editboxPrice", 10*scaleValue,210*scaleValue,250*scaleValue,30*scaleValue, "", interiorGuiElements.window, 0.5*scaleValue, 0.55*scaleValue, 10, false, "Cena za intek jeżeli typ intka to 2.", false, 5)
	interiorGuiElements.garage = exports.rp_library:createEditBox("interior:editboxGarage", 10*scaleValue,250*scaleValue,150*scaleValue,30*scaleValue, "", interiorGuiElements.window, 0.5*scaleValue, 0.7*scaleValue, 1, false, "Garaż: 0-1.", false, 5)
	interiorGuiElements.createButton = exports.rp_library:createButtonRounded("interior:createInteriorButton",150*scaleValue,310*scaleValue,120*scaleValue,30*scaleValue,"Stwórz interior",interiorGuiElements.window,0.6*scaleValue,10)
	showCursor(true)
	addEventHandler("onDgsMouseClickUp", interiorGuiElements.createButton, onButtonCreateInterior)
	addEventHandler("onDgsWindowClose",interiorGuiElements.window,windowClosed)
	-- DGS:dgsSetInputMode("no_binds")
	else
	destroyInteriorGui()
	end
end
addEvent("onPlayerTryToCreateInterior", true)
addEventHandler("onPlayerTryToCreateInterior", root, onPlayerTryToCreateInterior)
local interiorEditElements = {}

function onPlayerEditInterior(name, descInt, owner, garage, admin)
	adminLocal = admin
	interiorEditElements.showed = not interiorEditElements.showed
	if interiorEditElements.showed then
	interiorEditElements.window = exports.rp_library:createWindow("interiorEditWindow", interiorCreateGui.x,interiorCreateGui.y, interiorCreateGui.width, interiorCreateGui.height, "Edytowanie interioru", 5, 0.55*scaleValue, true)
	interiorEditElements.interiorName = exports.rp_library:createEditBox("interior:editboxName", 10*scaleValue,10*scaleValue,150*scaleValue,50*scaleValue, "", interiorEditElements.window, 0.5*scaleValue, 0.7*scaleValue, 20, false, "Nazwa interioru", false, 5)
	interiorEditElements.interiorDesc = exports.rp_library:createEditBox("interior:editboxDesc", 10*scaleValue,90*scaleValue,150*scaleValue,50*scaleValue, "", interiorEditElements.window, 0.5*scaleValue, 0.7*scaleValue, 20, false, "Opis interioru", false, 5)

	if admin then
		interiorEditElements.owner = exports.rp_library:createEditBox("interior:editboxOwner", 10*scaleValue,170*scaleValue,150*scaleValue,50*scaleValue, "", interiorEditElements.window, 0.5*scaleValue, 0.7*scaleValue, 3, false, "ID gracza, ownera", false, 5) -- 50 puste, tutaj mozna robic intki, budowac
		interiorEditElements.garage = exports.rp_library:createEditBox("interior:editboxGarage", 10*scaleValue,250*scaleValue,150*scaleValue,50*scaleValue, "", interiorEditElements.window, 0.5*scaleValue, 0.7*scaleValue, 1, false, "Garaż: 0-1", false, 5)
		-- exports.rp_library:setEditBoxText("interior:editboxType", intType)
		-- exports.rp_library:setEditBoxText("interior:editboxInteriorID", interiorID)
		-- exports.rp_library:setEditBoxText("interior:editboxOwner", owner)
		-- exports.rp_library:setEditBoxText("interior:editboxPrice", price)
		-- exports.rp_library:setEditBoxText("interior:editboxGarage", garage)



	end
	exports.rp_library:setEditBoxText("interior:editboxName", name)
	exports.rp_library:setEditBoxText("interior:editboxDesc", descInt)
	interiorEditElements.editButton = exports.rp_library:createButtonRounded("interior:editInteriorButton",150*scaleValue,310*scaleValue,120*scaleValue,30*scaleValue,"Edytuj interior",interiorEditElements.window,0.6*scaleValue,10)
	showCursor(true)
	addEventHandler("onDgsMouseClickUp", interiorEditElements.editButton, onButtonEditInterior)
	addEventHandler("onDgsWindowClose",interiorEditElements.window,windowClosed)
	-- DGS:dgsSetInputMode("no_binds")
	else
	destroyInteriorGui()
	end
	
end
addEvent("onPlayerTryToEditInterior", true)
addEventHandler("onPlayerTryToEditInterior", root, onPlayerEditInterior)

function windowClosed()
	setTimer(function()
		showCursor(false)
		destroyInteriorGui()
	end,100,1)
end

function destroyInteriorGui()
    for k, v in pairs(interiorGuiElements) do
        if isElement(v) then
            destroyElement(v)
        end
    end
	    for k, v in pairs(interiorEditElements) do
        if isElement(v) then
            destroyElement(v)
        end
    end
    showCursor(false)
	interiorGuiElements.showed = false
	interiorEditElements.showed = false

	-- DGS:dgsSetInputMode("allow_binds")

	-- removeEventHandler("onDgsMouseClickUp", interiorGuiElements.createButton, onButtonCreateInterior)
end


function onButtonCreateInterior(button)
    if source == interiorGuiElements.createButton then
        if button == "left" then
            triggerServerEvent("onPlayerCreateInterior", localPlayer, exports.rp_library:getEditBoxText("interior:editboxName"), tonumber(exports.rp_library:getEditBoxText("interior:editboxType")), exports.rp_library:getEditBoxText("interior:editboxDesc"), tonumber(exports.rp_library:getEditBoxText("interior:editboxInteriorID")), exports.rp_library:getEditBoxText("interior:editboxOwner"), exports.rp_library:getEditBoxText("interior:editboxPrice"), exports.rp_library:getEditBoxText("interior:editboxGarage"))
        end
    end
end

function onButtonEditInterior(button)
    if source == interiorEditElements.editButton then --
        if button == "left" then
		if adminLocal then
			triggerServerEvent("onPlayerEditInterior", localPlayer, exports.rp_library:getEditBoxText("interior:editboxName"), exports.rp_library:getEditBoxText("interior:editboxDesc"), tonumber(exports.rp_library:getEditBoxText("interior:editboxOwner")) or false, tonumber(exports.rp_library:getEditBoxText("interior:editboxGarage")) or false)
		else
			triggerServerEvent("onPlayerEditInterior", localPlayer, exports.rp_library:getEditBoxText("interior:editboxName"), exports.rp_library:getEditBoxText("interior:editboxDesc"))
		end
        end
    end
end

function onPlayerGotFlashbang()
	local sound = playSound("files/flash.ogg", false)
	flash()
end
function flash()
  fadeCamera(false, 0, 255, 255, 255)
  setTimer(fadeCamera, 4000, 1, true, 1)
end

addEvent("onPlayerGotFlashed", true)
addEventHandler("onPlayerGotFlashed", root, onPlayerGotFlashbang)




function onPlayerGotDoorBreaked()
	local sound = playSound("files/doorbreak.mp3", false)
	outputChatBox("(( W budynku wyważono drzwi... )", 171, 38, 171)
end
addEvent("onPlayerGotDoorBreaked", true)
addEventHandler("onPlayerGotDoorBreaked", getRootElement(),  onPlayerGotDoorBreaked)

function knockingDoor(player)
	local sound = playSound("files/knockdoors.mp3", false)
	if not player then
		outputChatBox("(( Ktoś puka do drzwi... ))", 171, 38, 171)
	end
end
addEvent("onPlayerKnockDoor", true)
addEventHandler("onPlayerKnockDoor", getRootElement(), knockingDoor)


function onPlayerLoadInteriorObjects(objectData, exiting)
    if exiting then
        if interiorGui.tempObjects then
            for _, v in ipairs(interiorGui.tempObjects) do
                if isElement(v.obj) then
                    if appliedObjectsTexture[v.obj] then
                        for _, data in pairs(appliedObjectsTexture[v.obj]) do
                            if isElement(data.shader) then destroyElement(data.shader) end
                            if isElement(data.texture) then destroyElement(data.texture) end
                        end
                        appliedObjectsTexture[v.obj] = nil
                    end
                    destroyElement(v.obj)
                end
            end
            interiorGui.tempObjects = {}
        end
        return
    end

    interiorGui.tempObjects = {}
    local total = #objectData
    local loaded = 0
    local index = 0 

    interiorGui.titleText = DGS:dgsCreateLabel(
        sx/2 - 5 * scaleValue, sy/2 + 300 * scaleValue,
        10 * scaleValue, 10 * scaleValue,
        "Wczytywanie " .. total .. " obiektów...", false, nil, 0xFFFFFFFF,
        1, 1, nil, nil, nil, "center", "center"
    )

    interiorGui.progressBarObjects = DGS:dgsCreateProgressBar(
        sx/2 - 100 * scaleValue, sy/2 + 350 * scaleValue,
        200 * scaleValue, 40 * scaleValue, false
    )

    setTimer(function()
        setTimer(function()
            if index >= total then return end 

            index = index + 1
            local v = objectData[index]
            if v then
                local obj = createObject(v.id, v.position[1], v.position[2], v.position[3], v.rotation[1], v.rotation[2], v.rotation[3])
                table.insert(interiorGui.tempObjects, {
                    obj = obj,
                    position = v.position,
                    rotation = v.rotation,
                    objectID = v.id,
                    lastObjectID = v.lastObjectID
                })

                iprint(v.lastObjectID)
                applyTextureToObject(obj, v.textures.a, "a")
                applyTextureToObject(obj, v.textures.b, "b")

                setElementDimension(obj, getElementDimension(localPlayer))
                setElementInterior(obj, getElementInterior(localPlayer))

                loaded = loaded + 1
                local percent = math.floor((loaded / total) * 100)
                DGS:dgsProgressBarSetProgress(interiorGui.progressBarObjects, percent)
            end

            if index == total then
                if isElement(interiorGui.titleText) then destroyElement(interiorGui.titleText) end
                if isElement(interiorGui.progressBarObjects) then destroyElement(interiorGui.progressBarObjects) end
                interiorGui.loadedObjects = true
                setTimer(function()
                    setElementFrozen(localPlayer, false)
                end, 2000, 1)
            end
        end, 50, total)
    end, 2000, 1)
end


addEvent("onPlayerLoadInteriorObjects", true)
addEventHandler("onPlayerLoadInteriorObjects", getRootElement(), onPlayerLoadInteriorObjects)



function onPlayerUpdateObjectInInterior(pos, rot, obj, textureImageA, textureImageB, lastID, destroyObject)
    local found = false
    -- outputChatBox("triggered")

    if destroyObject then
        -- outputChatBox("trying to destroy object")
        for k, v in pairs(interiorGui.tempObjects) do
            if v.lastObjectID == destroyObject and isElement(v.obj) then
                if appliedObjectsTexture[v.obj] then
                    for _, data in pairs(appliedObjectsTexture[v.obj]) do
                        if isElement(data.shader) then destroyElement(data.shader) end
                        if isElement(data.texture) then destroyElement(data.texture) end
                    end
                    appliedObjectsTexture[v.obj] = nil
                end
                destroyElement(v.obj)
                table.remove(interiorGui.tempObjects, k)
                break
            end
        end
        return
    end

    for k, v in pairs(interiorGui.tempObjects) do
        if v.lastObjectID == lastID and isElement(v.obj) then
            -- outputChatBox("found object, changing properties")
            found = true
            if pos then
                v.position = {pos[1], pos[2], pos[3]}
                setElementPosition(v.obj, pos[1], pos[2], pos[3])
            end
            if rot then
                v.rotation = {rot[1], rot[2], rot[3]}
                setElementRotation(v.obj, rot[1], rot[2], rot[3])
            end
            if textureImageA then
                applyTextureToObject(v.obj, textureImageA, "a")
            end
            if textureImageB then
                applyTextureToObject(v.obj, textureImageB, "b")
            end
            break
        end
    end

    if not found and obj then
        -- outputChatBox("didnt found object, creating")
        local newObj = createObject(obj, pos[1], pos[2], pos[3])
        setElementDimension(newObj, getElementDimension(localPlayer))
        setElementInterior(newObj, getElementInterior(localPlayer))

        if isElement(newObj) then
            setElementRotation(newObj, rot[1], rot[2], rot[3])
            table.insert(interiorGui.tempObjects, {
                obj = newObj,
                position = {pos[1], pos[2], pos[3]},
                rotation = {rot[1], rot[2], rot[3]},
                lastObjectID = lastID
            })

            if textureImageA then
                applyTextureToObject(newObj, textureImageA, "a")
            end
            if textureImageB then
                applyTextureToObject(newObj, textureImageB, "b")
            end
        end
    end
end
addEvent("onPlayerUpdateObjectInInterior", true)
addEventHandler("onPlayerUpdateObjectInInterior", getRootElement(), onPlayerUpdateObjectInInterior)








function isEventHandlerAdded( sEventName, pElementAttachedTo, func )
    if type( sEventName ) == 'string' and isElement( pElementAttachedTo ) and type( func ) == 'function' then
        local aAttachedFunctions = getEventHandlers( sEventName, pElementAttachedTo )
        if type( aAttachedFunctions ) == 'table' and #aAttachedFunctions > 0 then
            for i, v in ipairs( aAttachedFunctions ) do
                if v == func then
                    return true
                end
            end
        end
    end
    return false
end

local confirmExit = {}
local yesButton
local noButton

-- function createWindow(id, x, y, width, height, windowText, rounded, textSize, movable, closeButton)

local function sendConfirmationToInterior(button, state)
	if source ~= yesButton then return end
	if button == "left" and state == "up" then
		-- print("button clicked")
		confirmExit.showed = false
		DGS:dgsCloseWindow(confirmExit.window)
		triggerServerEvent("confirmExitFromGymFromClient", localPlayer)
	end
end

local function closeConfirmation(button, state)
	-- print(source)
	-- print(noButton)
	if source ~= noButton then return end
	if button == "left" and state == "up" then
		confirmExit.showed = false
		DGS:dgsCloseWindow(confirmExit.window)
		-- print("cos tam")
		return
	end
end

local function closeWindow()
	confirmExit.showed = false
	removeEventHandler("onDgsWindowClose", confirmExit.window, closeWindow)
end

local function confirmExitFromGym()
	-- print("local confirm")
    local WIDTH = 700
    local HEIGHT = 200
	local windowXPosition = ((1920 - WIDTH) / 2) * scaleValue
	local windowYPosition = ((1080 - HEIGHT) / 2) * scaleValue

	if confirmExit.showed then return end
	confirmExit.showed = true
	confirmExit.window = exports.rp_library:createWindow("confirmExit", windowXPosition, windowYPosition, WIDTH * scaleValue, HEIGHT * scaleValue, "Potwierdzenie wyjścia", 5, 0.55 * scaleValue, true)

	local TEXT_WIDTH = 600
    local TEXT_HEIGHT = 30

	local confirmationText = DGS:dgsCreateLabel(((WIDTH - TEXT_WIDTH)/2), ((HEIGHT - TEXT_HEIGHT)/4), TEXT_WIDTH * scaleValue, TEXT_HEIGHT * scaleValue, "Nie zużyłeś całej staminy, wychodząc zakończysz swój trening. Czy na pewno chesz wyjść?", false, confirmExit.window)

	DGS:dgsSetProperty(confirmationText, "textSize", {1.2, 1.2})
	DGS:dgsSetProperty(confirmationText, "font", "files\\font.ttf")

    local BUTTONS_WIDTH = 100
    local BUTTONS_HEIGHT = 30

	yesButton = DGS:dgsCreateButton(((WIDTH - BUTTONS_WIDTH)/2) - 125, ((HEIGHT - BUTTONS_HEIGHT)/2), BUTTONS_WIDTH * scaleValue, BUTTONS_HEIGHT * scaleValue, "Tak", false, confirmExit.window)

	DGS:dgsSetProperty(yesButton, "textSize", {1.2, 1.2})
	DGS:dgsSetProperty(yesButton, "font", "files\\font.ttf")

	noButton = DGS:dgsCreateButton(((WIDTH - BUTTONS_WIDTH)/2) + 125, ((HEIGHT - BUTTONS_HEIGHT)/2), BUTTONS_WIDTH * scaleValue, BUTTONS_HEIGHT * scaleValue, "Nie", false, confirmExit.window)

	DGS:dgsSetProperty(noButton, "textSize", {1.2, 1.2})
	DGS:dgsSetProperty(noButton, "font", "files\\font.ttf")

	addEventHandler ("onDgsWindowClose", confirmExit.window, closeWindow)
	addEventHandler ("onDgsMouseClick", yesButton, sendConfirmationToInterior)
	addEventHandler ("onDgsMouseClick", noButton, closeConfirmation)
end

addEvent("confirmExitFromGym", true)
addEventHandler("confirmExitFromGym", getRootElement(), confirmExitFromGym)


function applyTextureToObject(obj, texture, type)
    local txt = dxCreateTexture(texture)
    if not txt then return outputChatBox("Błąd z tworzeniem tekstury: " .. tostring(texture)) end

    local shader = dxCreateShader("files/shader.fx")
    if not shader then return outputChatBox("Błąd z tworzeniem shadera!") end

    -- Przypisz shader i teksturę do obiektu    
	if not appliedObjectsTexture[obj] then
        appliedObjectsTexture[obj] = {}
    end

    appliedObjectsTexture[obj][type] = {
        shader = shader,
        texture = txt
    }

    dxSetShaderValue(shader, "PdTexture", txt)
    dxSetShaderValue(shader, "PdBrightness", 1.0)
    dxSetShaderValue(shader, "RGBColor", {0.0, 0.0, 0.0})
    dxSetShaderValue(shader, "AlphaColor", 1.0)

    local textureName = (type == "a") and "a" or "b"
    engineApplyShaderToWorldTexture(shader, textureName, obj)
end
function test()
	local x,y,z = getElementPosition(localPlayer)
   local obj = createObject(8086, x, y, z)
   setElementDimension(obj, getElementDimension(localPlayer))
   setElementInterior(obj, getElementInterior(localPlayer))
   exports.rp_testeditor:startEdit(obj, false, false, true, localPlayer)
end
addCommandHandler("testing", test)



Config = {}
Config.isPermission = false
Config.models = {
	[8594] = "floor_1",
	[8593] = "floor_2",
	[8087] = "floor_3",
	[8081] = "wall_1",
	[8082] = "wall_2",
	[8083] = "wall_3",
	[8084] = "wall_4",
	[8085] = "wall_5",
	[8086] = "wall_6",
	[8595] = "wall_7",
	[16747] = "pod_suf_biale",
	[16746] = "pod_suf_dyw",
	[16745] = "pod_suf_dyw2",
	[16744] = "pod_suf_pan",
	[16743] = "pod_suf_pan2",
	[16742] = "pod_suf_plytki",
	[16741] = "pod_suf_plytki2",
	[16740] = "pod_suf_plytki3",
	[10229] = "sciana_biala",
	[10230] = "sciana_blekitna",
	[10231] = "sciana_zielona",
	[10228] = "sciana_kremowa",
	[10227] = "sciana_drzwi_biala",
	[16739] = "sciana_drzwi_blekitna",
	[16738] = "sciana_drzwi_zielona",
	[2028] = "devone",
	[1719] = "devps",
	[1429] = "hqtv1",
	[14772] = "lowtv1",
	[1809] = "mhifi1",
	[2225] = "mhifi2",
	[2227] = "mhifi3",
	[1781] = "mtv1",
	[1750] = "mtv2",
	[1749] = "mtv3",
	[1751] = "mtv4",
	[1792] = "protv1",
	[1791] = "protv2",
	[2344] = "tvrem",
	[8981] = "pumpkin",
	[2014] = "kruton9000",
	[2015] = "ramp",
	[2016] = "welder",
	[2018] = "dev_tool",
	[2019] = "dev_tool2",
	[2020] = "dev_tool3",
	[2021] = "tire",
	[2022] = "tire2",
	[1630] = "tools",
	[18000] = "choinka",
	[1942] = "prezenty",
	[1943] = "skarpety",
	[9590] = "greenscreen",
	[1310] = "first_backpack",
	[328] = "second_backpack",
	[2054] = "first_cap",
	[2052] = "second_cap",
	[2203] = "pot_one",
	[2194] = "pot_two",
	[1516] = "garden_table",
	[2777] = "garden_chair",
	[2190] = "macbook",
	[14820] = "dj1",
	[1964] = "klawiatura_mysz", -- start
	[2882] = "monitor",
	[1840] = "speaker",
	[2006] = "podest",
	[1841] = "speaker2",
	[3067] = "podnosnik_maly",
	[1958] = "podnosnik_duzy",
	[1784] = "pc",
	[3964] = "toolkit",
	[3963] = "toolbox",
	[2025] = "automat_sprunk",
	[3193] = "automat2",
	[1657] = "drukarka",
	[1658] = "kopierer",
	[1671] = "modern_chairr",
	[2402] = "backpack_vice",
	[2256] = "modern_frame",
	[2211] = "szafka1",
	[3051] = "dev_elevator",
	[13360] = "dev_elevatord",
	[962] = "dev_elevatorb",
	[330] = "ifruitx",
	[2210] = "kitchen1",
	[1316] = "kitchen2",
	-- [1317] = "kitchen3",
	[1944] = "kitchen4",
	[1945] = "kitchen5",
	[14728] = "shelf_h",
	[2617] = "sofa_h",
	[1707] = "sofa2_h",
	[2834] = "dywan1_h",
	[2847] = "dywan2_h",
	[2835] = "dywan3_h",
	[2836] = "dywan4_h", -- end
	[1839] = "tv_h",
	[3921] = "fotel_h",
	[2122] = "fotel2_h",
	[2013] = "rtv1_h",
	[2017] = "rtv2_h",
	[2287] = "obraz1_h",
	[2285] = "obraz2_h",
	[2284] = "obraz3_h",
	[2282] = "obraz4_h",
	[2283] = "obraz5_h",
	[2263] = "obraz6_h",
	[2250] = "grass1_h",
	[2249] = "grass2_h",
	[2247] = "grass3_h",
	[2085] = "tablek_h",
	[2086] = "chairk_h",
	[16353] = "book_h",
	[2331] = "shelf2_h",
	[2585] = "shelf3_h",
	[1700] = "bed_h",
	[2097] = "bath_h",
	[14480] = "sinkb_h",
	[2521] = "toilet_h",
	[14494] = "heater_h",
	[14481] = "accessoriesb_h",
	[14806] = "speaker_h",
	[1562] = "sofa3_h",
	[1826] = "modern_desk_h",
	[1491] = "modern_doors_h",
	[2123] = "chairk2_h",
	[2592] = "tables_h",
	[14556] = "wardrobe_h",
	-- Od wersji 1.2 - Furniture update
	[8969] = "Armchair",
	[8608] = "Bar_chair",
	[8607] = "Bath",
	[8596] = "BBQ",
	[7862] = "Bed", -- z szafką
	[7649] = "Bedside_table",
	[7648] = "Bookshelf",
	[7647] = "Ceiling_lamp",
	[7646] = "Console1",
	[7645] = "Console2",
	[7644] = "Couch",
	[7643] = "Dining_chair",
	[7642] = "Dining_table",
	[7641] = "High_cabinet",
	[7640] = "High_corner",
	[7639] = "High_cupboard",
	[7638] = "High_oven",
	[7637] = "High_washer",
	[7609] = "Kitchen_island",
	[7608] = "Lamp",
	[7607] = "Low_cabinet",
	[7598] = "Low_corner",
	[7578] = "Low_cupboard",
	[7577] = "Low_oven",
	[7576] = "Low_washer",
	[7575] = "Monitor2",
	[7574] = "Notebook",
	[7573] = "Office_chair",
	[7572] = "Office_desk",
	[7571] = "Outside_bench",
	[7570] = "Outside_table",
	[7569] = "PC2",
	[7568] = "Plant",
	[7567] = "Sink",
	[7566] = "Towel_holder",
	[7565] = "Tv",
	[7564] = "TvStand_1",
	[7563] = "Wall_lamp",
	[7562] = "Wardrobe",
	-- Od wersji 1.3 - Furniture update v2
	[7543] = "chillidogs",
	[7542] = "noodle",
	[7541] = "woodhouse",
	[955] = "sprunk",
	[5764] = "sirens",
	[18472] = "Cross1",
	[18471] = "MetalFork1",
	[18470] = "MetalKnife1",
	[18448] = "SweetsSaucepan1",
	[18215] = "SweetsSaucepan2",
	[18214] = "SweetsBed1",
	[18213] = "Radiator1",
	[18212] = "SauceBottle1",
	[18211] = "SauceBottle2",
	[18210] = "FireplaceSurround1",
	[18209] = "Fireplace1",
	[18208] = "WRockingHorse1",
	[18207] = "WRockingChair1",
	[18206] = "MedicCase1",
	[18205] = "MCoffeeMachine1",
}

local originalTXD = engineLoadTXD("files/models/textures.txd")
		for k,v in pairs(Config.models) do
			if k ~= 955 then
				removeWorldModel(k, 9999, 0, 0, 0)
			end
			if fileExists("files/models/" .. v .. ".txd") then
				engineImportTXD(engineLoadTXD("files/models/" .. v .. ".txd"), k)
			else
				engineImportTXD(originalTXD, k)
			end
			if fileExists("files/models/" .. v .. ".dff") then
				engineReplaceModel(engineLoadDFF("files/models/" .. v .. ".dff"), k, true)
			end
			if fileExists("files/models/" .. v .. ".col") then
				engineReplaceCOL(engineLoadCOL("files/models/" .. v .. ".col"), k)
			end
		end
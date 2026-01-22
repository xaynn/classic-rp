local phoneGui = {}
local sx, sy = guiGetScreenSize()
local scaleValue = exports.rp_scale:returnScaleValue()
DGS = exports.dgs
local offsetX, offsetY = exports.rp_scale:returnOffsetXY()
local font = dxCreateFont("files/Helvetica.ttf", 10 * scaleValue, false, "proof") or "default" -- fallback to default
local apps = {
    {name = "Ustawienia", id = "settings"},
    -- {name = "Portfel", id = "payments"},
    {name = "Notatki", id = "notes"},
    {name = "Wiadomości", id = "messages"},
    -- {name = "Aparat", id = "camera"},
    -- {name = "Zdjęcia", id = "photos"},
    -- {name = "Telegram", id = "telegram"},
	-- {name = "FaceTime", id = "facetime"},
}
phoneGui.showed = false
local createdImages = false
local createdAppIcons = false
local appButtons = {}
local appLabels = {}
local textures = {}
local playerRingtones = {}

local startX, startY = exports.rp_scale:getScreenStartPositionFromBox(369 * scaleValue, 507 * scaleValue, offsetX, offsetY, "right", "bottom")
local animating = false
local homeButtontexture = dxCreateTexture("files/home.png")
local whiteTexture = dxCreateTexture("files/bg4.jpg", "argb", true, "wrap")
local declineTexture = dxCreateTexture("files/rejectcall.png")
local answerTexture = dxCreateTexture("files/answer.png")


local txtGlobal = false
local tempApp = {}
local soundRingtones = false
local answering = false
local ringtoneSet = false
local wallpaperSet = false
local phoneSet = false
local phoneNumberCall = false
local timeTalking = 0
local actualApp = false


function hideHomeScreen()
 for _, btn in ipairs(appButtons) do
            DGS:dgsSetVisible(btn, false)
        end
        for _, lbl in ipairs(appLabels) do
            DGS:dgsSetVisible(lbl, false)
        end
end

local function enableApp(name)
    if name == "home" then -- home screen
        for _, btn in ipairs(appButtons) do
            DGS:dgsSetVisible(btn, true)
        end
        for _, lbl in ipairs(appLabels) do
            DGS:dgsSetVisible(lbl, true)
        end
		createWallpaper("background")
		actualApp = "home"
		destroyApp()
    elseif name == "settings" then
	
			hideHomeScreen()
			-- createWallpaper("white")
			createApp(name)
	elseif name == "notes" then
		hideHomeScreen()
		createApp(name)
	elseif name == "messages" then -- w wiadomosciach wiadomosci, oraz mozliwosc dodania kontaktow
		hideHomeScreen()
		createApp(name)
    end
	-- createWallpaper("white")
end

function setRing(button)
	if source == tempApp.setRingButton then
		changePhoneSettings("ringtone", ringtoneSet)
	end
end

function setWallpaper(button)
	if source == tempApp.setWallpaperButton then
		changePhoneSettings("wallpaper", wallpaperSet)
		createWallpaper("background")
	end
end


function addNoteFunc(button)
	if source == tempApp.addnotebutton and button == "left" then
		local text = DGS:dgsGetText(tempApp.memonotes)
		if string.len(text) < 4 then return exports.rp_library:createBox("Notatka jest za krótka, wymagane są conajmniej 4 znaki.") end
		table.insert(phoneGui.phoneData.settings[1]["notes"], text)
		changePhoneSettings("notes", phoneGui.phoneData.settings[1]["notes"])
		local row = DGS:dgsGridListAddRow(tempApp.gridlistt) 
		DGS:dgsGridListSetItemData ( tempApp.gridlistt, row, tempApp.column, text )
		DGS:dgsGridListSetItemText(tempApp.gridlistt, row, tempApp.column, text)
	end
end

function deleteNoteFunc(button)
	if source == tempApp.deletenotebutton and button == "left" then
		local selectedRow, selectedColumn = DGS:dgsGridListGetSelectedItem(tempApp.gridlistt)
            if selectedRow ~= -1 then
				local note = DGS:dgsGridListGetItemData ( tempApp.gridlistt, selectedRow, selectedColumn) -- zwraca tablice.
                DGS:dgsGridListRemoveRow(tempApp.gridlistt, selectedRow)
				for k,v in pairs(phoneGui.phoneData.settings[1]["notes"]) do
					if v == note then
						table.remove(phoneGui.phoneData.settings[1]["notes"], k)
					end
				end
				changePhoneSettings("notes", phoneGui.phoneData.settings[1]["notes"])
            end
	end
end


function addContactFunc(button)
	if source == tempApp.addContact and button == "left" then
		--nowe okienko z textboxami, oraz przyciskiem cofania do kontaktow.
		destroyApp()
		createApp("addcontacts")
	end
end

function addContactFuncFinall(button)
    if source ~= tempApp.addContactFinall or button ~= "left" then return end

    local name = DGS:dgsGetText(tempApp.nameEditbox)
    local phone = tonumber(DGS:dgsGetText(tempApp.numberEditbox))

    if not phone then
        return exports.rp_library:createBox("Numer musi być liczbą, numer ma maksymalnie 6 liczb.")
    end

    if string.len(tostring(phone)) ~= 6 then
        return exports.rp_library:createBox("Numer ma mieć dokładnie 6 cyfr.")
    end

    addContact(name, phone)
    exports.rp_library:createBox("Dodano kontakt")
end


function callContact(button)
	if source == tempApp.callContact and button == "left" then
		local phoneToCall = phoneSet
		if phoneToCall then
			-- enableApp()
			triggerServerEvent("onPlayerCallToPlayer", localPlayer, phoneToCall)
		end
	end

end

function deleteContact(button)
    if source == tempApp.deleteContact and button == "left" then
        local selectedRow, selectedColumn = DGS:dgsGridListGetSelectedItem(tempApp.gridlistmessages)
        if selectedRow ~= -1 then
            local phone = DGS:dgsGridListGetItemData(tempApp.gridlistmessages, selectedRow, selectedColumn) -- zwraca tablice.
            DGS:dgsGridListRemoveRow(tempApp.gridlistmessages, selectedRow)
            deleteContactFunc(phone)
        end
    end
end


function formatCallTime(seconds)
    local minutes = math.floor(seconds / 60)
    local secs = seconds % 60
    return string.format("%02d:%02d", minutes, secs)
end

function onPlayerCalling(phoneNumber, answeringx, talking, disconnected)
    if talking then
		if not createdImages then return end-- nie mial nigdy otwartego telefonu, trzeba sam mu otworzyc i zbindowac klawisz po serwerze aby dane sie pobraly.
		timeTalking = 0
		destroyApp()
		createApp("talking")
        return
    end
	
	if disconnected then
		enableApp("home")
		actualApp = "home"
		timeTalking = 0
		if isTimer(labelTimer) then killTimer(labelTimer) end
		return
	end

    if answeringx then
        answering = true
    else
        answering = false
    end
    phoneNumberCall = phoneNumber
    destroyApp()
    createApp("calling")
end
addEvent("onPlayerCalling", true)
addEventHandler("onPlayerCalling", getRootElement(), onPlayerCalling)
function onPlayerMakeRingSound(player, ringtone, sms)
	if ringtone == "disable" then
	if not playerRingtones[player] then return end
	destroyElement(playerRingtones[player])
	playerRingtones[player] = nil
	return 
	
	end
	if sms then
	local x,y,z = getElementPosition(player)
	local sound = playSound3D("files/ringtones/sms.mp3", x, y, z, false)
	setSoundVolume(sound, 0.3)
	return
	end
	local x,y,z = getElementPosition(player)

	local sound = playSound3D("files/ringtones/"..ringtone..".mp3", x, y, z, true)
	setElementDimension(sound, getElementDimension(player))
	setElementInterior(sound, getElementInterior(player))
	attachElements(sound, player, 0, 0, 0)
	playerRingtones[player] = sound
	setSoundVolume(sound, 0.1)
end
addEvent("onPlayerMakeRingSound", true)
addEventHandler("onPlayerMakeRingSound", getRootElement(), onPlayerMakeRingSound)

function onPlayerUpdateSMS(from, text, timestampp, sender, toNumber)
	
	if sender == localPlayer then
	addMessage("Ja", text, timestampp)
	table.insert(phoneGui.phoneData.settings[1].messages, {number = from, message = text, timestamp = timestampp, to = toNumber})
	else
		addMessage(from, text, timestampp)
		table.insert(phoneGui.phoneData.settings[1].messages, {number = from, message = text, timestamp = timestampp, to = toNumber})

	end
end
addEvent("onPlayerUpdateSMS", true)
addEventHandler("onPlayerUpdateSMS", getRootElement(), onPlayerUpdateSMS)

local screenW, screenH = guiGetScreenSize()
local sourceFaceTime = dxCreateScreenSource(200*scaleValue, 200*scaleValue)
local isFacetimeActive = false
local targetPlayer = nil
local lastCamMatrix = {}

function startFacetime(target)
    if not isElement(target) then return end
    isFacetimeActive = true
    targetPlayer = target
    addEventHandler("onClientPreRender", root, renderFacetime)
end

function stopFacetime()
    isFacetimeActive = false
    removeEventHandler("onClientPreRender", root, renderFacetime)
    targetPlayer = nil
end

function renderFacetime()
    if not isFacetimeActive or not isElement(targetPlayer) then return stopFacetime() end

    -- pozycja kamery za głową gracza
    local px, py, pz = getElementPosition(targetPlayer)
    local _, _, rz = getElementRotation(targetPlayer)
    local rotRad = math.rad(rz)

    local camX = px - math.sin(rotRad) * 2
    local camY = py + math.cos(rotRad) * 2
    local camZ = pz + 1.5

    -- setCameraMatrix(camX, camY, camZ, px, py, pz)

    dxUpdateScreenSource(sourceFaceTime)

    -- opcjonalnie zapamiętujemy ostatnią kamerę
    -- lastCamMatrix = {camX, camY, camZ, px, py, pz}
end

function drawFacetimeWindow()
    if not isFacetimeActive then return end
    dxDrawImage(x,y,w,h, sourceFaceTime)
end

-- addEventHandler("onClientRender", root, drawFacetimeWindow)

function faceTimeContact(button)
if button == "left" then
destroyApp()
startFacetime(localPlayer)

end


end
function addMessage(from, text, timestamp)
	if actualApp ~= "messageConversation" then return end
	-- table.insert(phoneGui.phoneData.settings[1].messages, {number = from, message = text, timestamp = timestamp})
	if from == phoneGui.phoneData.settings[1]["number"] then 
	from = "Ja" 
	end
	-- return
	-- end
    if not tempApp.y then tempApp.y = 10 end
    local width = 200 * scaleValue
    local scrollWidth = 300 * scaleValue
    local margin = 100 * scaleValue
    local senderOffsetX = 100 * scaleValue
    local padding = 10 * scaleValue

    local align = from == "Ja" and "right" or "left"
    local x = from == "Ja"
        and (scrollWidth - width - margin)
        or (margin - senderOffsetX)



    -- Oblicz rozmiar tekstu
    local testLabel = DGS:dgsCreateLabel(-1000, -1000, width - 2 * padding, 0, text, false)
    DGS:dgsSetProperty(testLabel, "wordBreak", true)
    DGS:dgsSetProperty(testLabel, "font", font)
    local textHeight = DGS:dgsLabelGetFontHeight(testLabel, false)
    local lineCount = math.ceil(DGS:dgsLabelGetTextExtent(testLabel) / (width - 2 * padding))
    DGS:dgsSetVisible(testLabel, false)
    local height = (textHeight * lineCount) + 2 * padding + 15 * scaleValue  -- + miejsce na datę
    destroyElement(testLabel)

    -- Tło wiadomości
    tempApp.bg = DGS:dgsCreateImage(x, tempApp.y, width, height, nil, false, tempApp.scroll, tocolor(from == "Ja" and 100 or 60, 60, 100, 200))
    DGS:dgsSetProperty(tempApp.bg, "rounded", {10, 10})

    -- Tekst wiadomości
    tempApp.label = DGS:dgsCreateLabel(x + padding, tempApp.y + padding, width - 2 * padding, height - 2 * padding - 15 * scaleValue, getNameInContacts(from)..": "..text, false, tempApp.scroll)
    DGS:dgsSetProperty(tempApp.label, "alignment", {align, "top"})
    DGS:dgsSetProperty(tempApp.label, "wordBreak", true)
    DGS:dgsSetProperty(tempApp.label, "font", font)
    DGS:dgsSetProperty(tempApp.label, "color", tocolor(255, 255, 255, 255))

    -- Data i godzina wiadomości
    local timeLabel = DGS:dgsCreateLabel(x + padding, tempApp.y + height - 15 * scaleValue, width - 2 * padding, 15 * scaleValue, timestamp, false, tempApp.scroll)
    DGS:dgsSetProperty(timeLabel, "alignment", {"right", "center"})
    DGS:dgsSetProperty(timeLabel, "font", font)
    DGS:dgsSetProperty(timeLabel, "color", tocolor(200, 200, 200, 180))
    DGS:dgsSetProperty(timeLabel, "textSize", {0.8, 0.8})

    -- Aktualizacja pozycji
    tempApp.y = tempApp.y + height + 10

    -- Blokada interakcji
    DGS:dgsSetEnabled(tempApp.label, false)
    DGS:dgsSetEnabled(tempApp.bg, false)
    DGS:dgsSetEnabled(timeLabel, false)

    -- Ustaw rozmiar scrolla
    DGS:dgsSetProperty(tempApp.scroll, "CanvasSize", {nil, tempApp.y})
end

function createApp(name)
		actualApp = name
    if name == "settings" then
        tempApp.gridlist = exports.rp_library:createGridList("dzwonektelefonu", 30*scaleValue, 30 * scaleValue, 170 * scaleValue, 100 * scaleValue, phoneGui.background, 15 * scaleValue, 0.30)--DGS:dgsCreateGridList(30 * scaleValue, 30 * scaleValue, 170 * scaleValue, 100 * scaleValue, false, phoneGui.background)
        local column = DGS:dgsGridListAddColumn(tempApp.gridlist, "Wybierz dzwonek telefonu", 1)
        local row = DGS:dgsGridListAddRow(tempApp.gridlist)
        DGS:dgsGridListSetItemText(tempApp.gridlist, row, column, "1")
        row = DGS:dgsGridListAddRow(tempApp.gridlist)
        DGS:dgsGridListSetItemText(tempApp.gridlist, row, column, "2")
        row = DGS:dgsGridListAddRow(tempApp.gridlist)
        DGS:dgsGridListSetItemText(tempApp.gridlist, row, column, "3")
        tempApp.setRingButton = exports.rp_library:createButtonRounded("setring", 30*scaleValue, 130*scaleValue, 170*scaleValue, 20*scaleValue, "Ustaw dzwonek", phoneGui.background, 0.5, 5*scaleValue)--DGS:dgsCreateButton(30 * scaleValue, 130 * scaleValue, 170 * scaleValue, 20 * scaleValue, "Ustaw dzwonek", false, phoneGui.background)

        tempApp.gridlistWallpaper = exports.rp_library:createGridList("tapetatelefon", 30 * scaleValue, 200 * scaleValue, 170 * scaleValue, 100 * scaleValue, phoneGui.background, 15 * scaleValue, 0.4)--DGS:dgsCreateGridList(30 * scaleValue, 200 * scaleValue, 170 * scaleValue, 100 * scaleValue, false, phoneGui.background)
        local wallpaperColumn = DGS:dgsGridListAddColumn(tempApp.gridlistWallpaper, "Wybierz tapetę", 1)
        row = DGS:dgsGridListAddRow(tempApp.gridlistWallpaper)
        DGS:dgsGridListSetItemText(tempApp.gridlistWallpaper, row, wallpaperColumn, "1")
        row = DGS:dgsGridListAddRow(tempApp.gridlistWallpaper)
        DGS:dgsGridListSetItemText(tempApp.gridlistWallpaper, row, wallpaperColumn, "2")
        row = DGS:dgsGridListAddRow(tempApp.gridlistWallpaper)
        DGS:dgsGridListSetItemText(tempApp.gridlistWallpaper, row, wallpaperColumn, "3")
        row = DGS:dgsGridListAddRow(tempApp.gridlistWallpaper)
        DGS:dgsGridListSetItemText(tempApp.gridlistWallpaper, row, wallpaperColumn, "4")

        tempApp.setWallpaperButton = exports.rp_library:createButtonRounded("setwallpaper", 30*scaleValue, 300 * scaleValue, 170 * scaleValue, 20 * scaleValue, "Ustaw tapetę", phoneGui.background, 0.5, 5 * scaleValue)--DGS:dgsCreateButton(30 * scaleValue, 300 * scaleValue, 170 * scaleValue, 20 * scaleValue, "Ustaw tapetę", false, phoneGui.background)

        addEventHandler("onDgsMouseClickUp", tempApp.setRingButton, setRing)
        addEventHandler("onDgsMouseClickUp", tempApp.setWallpaperButton, setWallpaper)

            tempApp.label = DGS:dgsCreateLabel(80*scaleValue, 350*scaleValue, 80*scaleValue, 50*scaleValue, "Twój numer telefonu: "..phoneGui.phoneData.settings[1]["number"], false, phoneGui.background, 0xFFFFFFFF, 1, 1, 1, 1, tocolor(0,0,0,255))
            DGS:dgsSetProperty(tempApp.label, "alignment", {"center", "center"})
            DGS:dgsSetProperty(tempApp.label, "wordBreak", false)
			DGS:dgsSetProperty(tempApp.label, "font", font)
			DGS:dgsSetProperty(tempApp.label, "shadow", {1, 1, tocolor(0, 0, 0, 200)})
			-- tempApp.checkboxMute = exports.rp_library:createCheckBox("mute", 30*scaleValue, 390*scaleValue, "Wycisz telefon", phoneGui.background, 0.50*scaleValue)
			-- exports.rp_library:setCheckBoxState("mute", phoneGui.phoneData.settings[1]["mute"])
			-- tempApp.checkboxCallerHide = exports.rp_library:createCheckBox("hidecallerid", 30*scaleValue, 420*scaleValue, "Włącz zastrzeżony numer", phoneGui.background, 0.50*scaleValue)
			-- exports.rp_library:setCheckBoxState("hidecallerid", phoneGui.phoneData.settings[1]["hidecallerid"])
			-- tempApp.checkboxMute = DGS:dgsCreateCheckBox(30*scaleValue, 390*scaleValue, 64, 64,"Wycisz telefon",false,false,phoneGui.background)
			-- tempApp.checkboxCallerHide = DGS:dgsCreateCheckBox(30*scaleValue, 420*scaleValue, 64, 64,"Wycisz telefon",false,false,phoneGui.background)
			local uncheckedRect = DGS:dgsCreateRoundRect(5 * scaleValue, false, tocolor(111,97,209,255))
			local checkedRect = DGS:dgsCreateRoundRect(5 * scaleValue, false, tocolor(51, 43, 107, 255))
			tempApp.checkboxCallerHide = DGS:dgsCreateCheckBox(30*scaleValue, 390*scaleValue, 16, 16, "Zastrzeż numer", false, false, phoneGui.background, tocolor(255, 255, 255, 255), 1, 1, uncheckedRect, uncheckedRect, uncheckedRect, nil, nil, nil, checkedRect, checkedRect, checkedRect)
			tempApp.checkboxMute = DGS:dgsCreateCheckBox(30*scaleValue, 420*scaleValue, 16, 16, "Wycisz telefon", false, false, phoneGui.background, tocolor(255, 255, 255, 255), 1, 1, uncheckedRect, uncheckedRect, uncheckedRect, nil, nil, nil, checkedRect, checkedRect, checkedRect)
			DGS:dgsSetProperty(tempApp.checkboxCallerHide, "font", font)
			DGS:dgsSetProperty(tempApp.checkboxMute, "font", font)
			DGS:dgsCheckBoxSetSelected (tempApp.checkboxCallerHide, phoneGui.phoneData.settings[1]["hidecallerid"] )
			DGS:dgsCheckBoxSetSelected (tempApp.checkboxMute, phoneGui.phoneData.settings[1]["mute"] )
			local function onStateChanged(state)
				if source == tempApp.checkboxCallerHide then
					changePhoneSettings("hidecallerid", not phoneGui.phoneData.settings[1]["hidecallerid"])
					elseif source == tempApp.checkboxMute then
					changePhoneSettings("mute", not phoneGui.phoneData.settings[1]["mute"])
				end
			end
		addEventHandler("onDgsCheckBoxChange", root, onStateChanged)
        -- OBSŁUGA WYBORU DZWONKA I TAPETY
        addEventHandler("onDgsGridListSelect", root,
            function(current, currentColumn)
                if source == tempApp.gridlist then
                    local selected = DGS:dgsGridListGetSelectedItem(tempApp.gridlist)
                    if selected ~= -1 then
                        local output = DGS:dgsGridListGetItemText(tempApp.gridlist, selected, 1)
                        if isElement(soundRingtones) then
                            destroyElement(soundRingtones)
                        end
						soundRingtones = playSound("files/ringtones/" .. output .. ".mp3")
                        ringtoneSet = output
                        if isTimer(ringTimer) then
                            killTimer(ringTimer)
                        end
                        ringTimer = setTimer(function()
                            if isElement(soundRingtones) then
                                destroyElement(soundRingtones)
                            end
                        end, 10000, 1)
                    end

                elseif source == tempApp.gridlistWallpaper then
                    local selected = DGS:dgsGridListGetSelectedItem(tempApp.gridlistWallpaper)
                    if selected ~= -1 then
                        local output = DGS:dgsGridListGetItemText(tempApp.gridlistWallpaper, selected, 1)
                        wallpaperSet = output
                    end
                end
            end
        )
    elseif name == "notes" then
		tempApp.gridlistt = exports.rp_library:createGridList("gridlistnotes", 20*scaleValue, 40*scaleValue, 200*scaleValue, 200*scaleValue, phoneGui.background, 15, 0.5)
		tempApp.column = DGS:dgsGridListAddColumn(tempApp.gridlistt, "Notatki", 1)
        tempApp.memonotes = exports.rp_library:createMemoEditBox("notesMemo", 20* scaleValue, 240 * scaleValue, 200 * scaleValue, 100 * scaleValue, "", phoneGui.background, 1, 0.6, 80, "Napisz tutaj notatkę", 5)--DGS:dgsCreateMemo(20 * scaleValue,79 * scaleValue,360 * scaleValue,50 * scaleValue,"",false,menuDesc.window)
		DGS:dgsSetProperty(tempApp.memonotes, "wordWrap", 1)
	    tempApp.addnotebutton = exports.rp_library:createButtonRounded("addnote", 20*scaleValue, 340 * scaleValue, 200 * scaleValue, 20 * scaleValue, "Dodaj notatkę", phoneGui.background, 0.5, 5 * scaleValue)--DGS:dgsCreateButton(30 * scaleValue, 300 * scaleValue, 170 * scaleValue, 20 * scaleValue, "Ustaw tapetę", false, phoneGui.background)
		tempApp.deletenotebutton = exports.rp_library:createButtonRounded("deletenote", 20*scaleValue, 360 * scaleValue, 200 * scaleValue, 20 * scaleValue, "Usuń notatkę", phoneGui.background, 0.5, 5 * scaleValue)--DGS:dgsCreateButton(30 * scaleValue, 300 * scaleValue, 170 * scaleValue, 20 * scaleValue, "Ustaw tapetę", false, phoneGui.background)
		addEventHandler("onDgsMouseClickUp", tempApp.addnotebutton, addNoteFunc)
		addEventHandler("onDgsMouseClickUp", tempApp.deletenotebutton, deleteNoteFunc)
		for k,v in pairs(phoneGui.phoneData.settings[1]["notes"]) do
			local row = DGS:dgsGridListAddRow(tempApp.gridlistt) 
			DGS:dgsGridListSetItemText(tempApp.gridlistt, row, tempApp.column, tostring(v)) -- nazwa v[1], v[2] opis 
			DGS:dgsGridListSetItemData ( tempApp.gridlistt, row, tempApp.column, v )
			-- DGS:dgsGridListSetItemFont ( tempApp.gridlist, row, column, font )
		end
		
	    addEventHandler("onDgsGridListItemDoubleClick",tempApp.gridlistt,
        function(button, state, item)
            if button == "left" and state == "down" and item and source == tempApp.gridlistt then
                -- iprint(item, tempCharacters[item])
				DGS:dgsGridListGetItemText(tempApp.gridlistt , item, tempApp.column)
				local data = DGS:dgsGridListGetItemData ( tempApp.gridlistt, item, tempApp.column) -- zwraca tablice.
				DGS:dgsSetText(tempApp.memonotes,data)
            end
        end
    )
		-- local buttonSet = 
	elseif name == "photos" then
	
	elseif name == "camera" then
	
	elseif name == "messages" then --w tablicy numer = wiadomosci.
		tempApp.gridlistmessages = exports.rp_library:createGridList("gridlistmessages", 20*scaleValue, 40*scaleValue, 200*scaleValue, 200*scaleValue, phoneGui.background, 15, 0.5)
		tempApp.column = DGS:dgsGridListAddColumn(tempApp.gridlistmessages, "Wiadomosci", 1)
		tempApp.addContact = exports.rp_library:createButtonRounded("addcontact", 20*scaleValue, 240 * scaleValue, 200 * scaleValue, 20 * scaleValue, "Dodaj kontakt", phoneGui.background, 0.5, 5 * scaleValue)--DGS:dgsCreateButton(30 * scaleValue, 300 * scaleValue, 170 * scaleValue, 20 * scaleValue, "Ustaw tapetę", false, phoneGui.background)
		tempApp.callContact = exports.rp_library:createButtonRounded("callcontact", 20*scaleValue, 260 * scaleValue, 200 * scaleValue, 20 * scaleValue, "Zadzwoń do kontaktu", phoneGui.background, 0.5, 5 * scaleValue)--DGS:dgsCreateButton(30 * scaleValue, 300 * scaleValue, 170 * scaleValue, 20 * scaleValue, "Ustaw tapetę", false, phoneGui.background)
		-- tempApp.faceTimeContact = exports.rp_library:createButtonRounded("facetimecontact", 20*scaleValue, 280 * scaleValue, 200 * scaleValue, 20 * scaleValue, "FaceTime do kontaktu", phoneGui.background, 0.5, 5 * scaleValue)--DGS:dgsCreateButton(30 * scaleValue, 300 * scaleValue, 170 * scaleValue, 20 * scaleValue, "Ustaw tapetę", false, phoneGui.background)
		tempApp.deleteContact = exports.rp_library:createButtonRounded("deletecontact", 20*scaleValue, 300 * scaleValue, 200 * scaleValue, 20 * scaleValue, "Usuń kontakt", phoneGui.background, 0.5, 5 * scaleValue)--DGS:dgsCreateButton(30 * scaleValue, 300 * scaleValue, 170 * scaleValue, 20 * scaleValue, "Ustaw tapetę", false, phoneGui.background)
		addEventHandler("onDgsMouseClickUp", tempApp.addContact, addContactFunc)
		addEventHandler("onDgsMouseClickUp", tempApp.callContact, callContact)
		addEventHandler("onDgsMouseClickUp", tempApp.deleteContact, deleteContact)
		-- addEventHandler("onDgsMouseClickUp", tempApp.faceTimeContact, faceTimeContact)

		
		for k,v in pairs(phoneGui.phoneData.contacts[1]) do
			if v then
			local row = DGS:dgsGridListAddRow(tempApp.gridlistmessages) 
			DGS:dgsGridListSetItemText(tempApp.gridlistmessages, row, tempApp.column, v.phone.." "..v.name) -- nazwa v[1], v[2] opis 
			DGS:dgsGridListSetItemData ( tempApp.gridlistmessages, row, tempApp.column, v.phone )
			-- DGS:dgsGridListSetItemFont ( tempApp.gridlist, row, column, font )
			end
		end
		 addEventHandler("onDgsGridListItemDoubleClick",tempApp.gridlistmessages,
        function(button, state, item)
            if button == "left" and state == "down" and item and source == tempApp.gridlistmessages then
                -- iprint(item, tempCharacters[item])
				local data = DGS:dgsGridListGetItemData ( tempApp.gridlistmessages, item, tempApp.column) -- zwraca tablice.
				phoneSet = data
				-- otwiera okno z wiadomosciami, mozna pisac z graczem.
				createApp("messageConversation")
				actualApp = "messageConversation"
            end
        end
    )
	
			 addEventHandler("onDgsGridListSelect",tempApp.gridlistmessages,
        function(current, currentcolumn, previous, previouscolumn)
            if source == tempApp.gridlistmessages then
					local selectedRow, selectedColumn = DGS:dgsGridListGetSelectedItem(tempApp.gridlistmessages)
            if selectedRow ~= -1 then
                -- iprint(item, tempCharacters[item])
				local data = DGS:dgsGridListGetItemData ( tempApp.gridlistmessages, current, currentcolumn) -- zwraca tablice.
				phoneSet = data
				-- otwiera okno z wiadomosciami, mozna pisac z graczem.
            end
        end
		end
    )
	
	elseif name == "addcontacts" then
	-- tempApp.nameEditbox = exports.rp_library:createEditBox("nameeditboxphone",20*scaleValue,150*scaleValue,205*scaleValue,40*scaleValue,"",phoneGui.background,1,0.5,20,false,"Nazwa Kontaktu",0,5)
	tempApp.nameEditbox = exports.rp_library:createEditBox("nameeditboxphone",20*scaleValue,150*scaleValue,205*scaleValue,40*scaleValue,"",phoneGui.background,0.5,0.6,25,false,"Nazwa kontaktu",false,5)--id, x, y, w, h, text, parent, caretHeight, textSize, maxLength, masked, placeHolder, padding, corners
	tempApp.numberEditbox = exports.rp_library:createEditBox("numbereditboxphone",20*scaleValue,200*scaleValue,205*scaleValue,40*scaleValue,"",phoneGui.background,0.5,0.6,6,false,"Numer",false,5)--id, x, y, w, h, text, parent, caretHeight, textSize, maxLength, masked, placeHolder, padding, corners
	tempApp.addContactFinall = exports.rp_library:createButtonRounded("addcontactfinall", 20*scaleValue, 240 * scaleValue, 200 * scaleValue, 20 * scaleValue, "Dodaj kontakt", phoneGui.background, 0.5, 5 * scaleValue)--DGS:dgsCreateButton(30 * scaleValue, 300 * scaleValue, 170 * scaleValue, 20 * scaleValue, "Ustaw tapetę", false, phoneGui.background)
		addEventHandler("onDgsMouseClickUp", tempApp.addContactFinall, addContactFuncFinall)

	elseif name == "talking" then
		timeTalking = 0
	local name = getNameInContacts(phoneNumberCall)
		tempApp.label = DGS:dgsCreateLabel(120*scaleValue, 70*scaleValue, 120*scaleValue, 30*scaleValue, "Rozmawiasz z: "..name, false, phoneGui.cellphone, 0xFFFFFFFF, 1, 1, 1, 1, tocolor(0,0,0,255))
		tempApp.labelTime = DGS:dgsCreateLabel(120*scaleValue, 100*scaleValue, 120*scaleValue, 30*scaleValue, formatCallTime(timeTalking), false, phoneGui.cellphone, 0xFFFFFFFF, 1, 1, 1, 1, tocolor(0,0,0,255))
		DGS:dgsSetProperty(tempApp.labelTime, "alignment", {"center", "center"})
		DGS:dgsSetProperty(tempApp.labelTime, "font", font)
		DGS:dgsSetProperty(tempApp.labelTime, "shadow", {1, 1, tocolor(0, 0, 0, 200)})
		DGS:dgsSetProperty(tempApp.label, "alignment", {"center", "center"})
		DGS:dgsSetProperty(tempApp.label, "font", font)
		DGS:dgsSetProperty(tempApp.label, "shadow", {1, 1, tocolor(0, 0, 0, 200)})
		DGS:dgsSetPostGUI(tempApp.label, true)
		DGS:dgsSetProperty(tempApp.label, "wordBreak", false)
		labelTimer = setTimer(addTime, 1000, 0)
	 tempApp.declineButton = DGS:dgsCreateButton(100*scaleValue, 380 * scaleValue, 48 * scaleValue, 48 * scaleValue, "", false, phoneGui.background)
            DGS:dgsSetProperty(tempApp.declineButton, "image", {declineTexture, declineTexture, declineTexture})
            DGS:dgsSetProperty(tempApp.declineButton, "color", {
                tocolor(255, 255, 255, 255),
                tocolor(200, 200, 200, 255),
                tocolor(150, 150, 150, 255)
            })
			addEventHandler("onDgsMouseClickUp", tempApp.declineButton, declineCall)
	
	elseif name == "messageConversation" then
		destroyApp()

-- ScrollPane na wiadomości
tempApp.scroll = DGS:dgsCreateScrollPane(20*scaleValue, 20*scaleValue, 360*scaleValue, 300*scaleValue, false, phoneGui.background)
DGS:dgsSetProperty(tempApp.scroll, "padding", {10, 10})

-- Pole tekstowe na nową wiadomość
tempApp.edit = DGS:dgsCreateEdit(20*scaleValue, 350*scaleValue, 210*scaleValue, 40*scaleValue, "", false, phoneGui.background)
-- DGS:dgsSetProperty(convGui.edit, "textSize", {0.5*scaleValue, 0.5*scaleValue})
DGS:dgsSetProperty(tempApp.edit, "font", font)

-- Przycisk "Wyślij"
tempApp.sendButton = DGS:dgsCreateButton(20*scaleValue, 400*scaleValue, 90*scaleValue, 40*scaleValue, "Wyślij", false, phoneGui.background)
-- DGS:dgsSetProperty(convGui.sendButton, "textSize", {0.5*scaleValue, 0.5*scaleValue})
DGS:dgsSetProperty(tempApp.sendButton, "font", font)

tempApp.y = 10
-- Funkcja do dodania jednej wiadomości




local myNumber = phoneGui.phoneData.settings[1].number
local contactNumber = phoneSet -- numer kontaktu, z którym przeglądasz czat

for _, msg in ipairs(phoneGui.phoneData.settings[1].messages) do
    if (msg.number == myNumber and msg.to == contactNumber) or
       (msg.number == contactNumber and msg.to == myNumber) then
        addMessage(msg.number, msg.message, msg.timestamp)
    end
end
DGS:dgsSetPostGUI(tempApp.edit, true)
DGS:dgsEditSetMaxLength(tempApp.edit, 40)
DGS:dgsSetPostGUI(tempApp.sendButton, true)
-- Obsługa wysyłania wiadomości
addEventHandler("onDgsMouseClick", tempApp.sendButton, function()
    local text = DGS:dgsGetText(tempApp.edit)
    if text ~= "" then
        -- addMessage("Ja", text)
        DGS:dgsSetText(tempApp.edit, "")
		triggerServerEvent("onPlayerSendMessage", localPlayer, phoneSet, text)
    end
end, false)
	elseif name == "telegram" then
	
	elseif name == "calling" then

		if answering then -- odbiera, wiec pokazujemy mu gui z odebraniem telefonu
		local name = getNameInContacts(phoneNumberCall)
		tempApp.label = DGS:dgsCreateLabel(120*scaleValue, 70*scaleValue, 120*scaleValue, 30*scaleValue, "Dzwoni: "..name, false, phoneGui.cellphone, 0xFFFFFFFF, 1, 1, 1, 1, tocolor(0,0,0,255))
		DGS:dgsSetProperty(tempApp.label, "alignment", {"center", "center"})
		DGS:dgsSetProperty(tempApp.label, "font", font)
		DGS:dgsSetProperty(tempApp.label, "shadow", {1, 1, tocolor(0, 0, 0, 200)})
		DGS:dgsSetPostGUI(tempApp.label, true)
		DGS:dgsSetProperty(tempApp.label, "wordBreak", false)
		tempApp.acceptButton = DGS:dgsCreateButton(50*scaleValue, 380 * scaleValue, 48 * scaleValue, 48 * scaleValue, "", false, phoneGui.background)
		 tempApp.declineButton = DGS:dgsCreateButton(150*scaleValue, 380 * scaleValue, 48 * scaleValue, 48 * scaleValue, "", false, phoneGui.background)
            DGS:dgsSetProperty(tempApp.declineButton, "image", {declineTexture, declineTexture, declineTexture})
            DGS:dgsSetProperty(tempApp.declineButton, "color", {
                tocolor(255, 255, 255, 255),
                tocolor(200, 200, 200, 255),
                tocolor(150, 150, 150, 255)
            })
			
			DGS:dgsSetProperty(tempApp.acceptButton, "image", {answerTexture, answerTexture, answerTexture})
            DGS:dgsSetProperty(tempApp.acceptButton, "color", {
                tocolor(255, 255, 255, 255),
                tocolor(200, 200, 200, 255),
                tocolor(150, 150, 150, 255)
            })
			
			
			addEventHandler("onDgsMouseClickUp", tempApp.declineButton, declineCall)
			addEventHandler("onDgsMouseClickUp", tempApp.acceptButton, answerCall)
		else -- ten dzwoni, wiec juz ma calling i numer goscia.
			local name = getNameInContacts(phoneNumberCall)

			tempApp.label = DGS:dgsCreateLabel(120*scaleValue, 70*scaleValue, 120*scaleValue, 30*scaleValue, "Dzwonisz do: "..name, false, phoneGui.cellphone, 0xFFFFFFFF, 1, 1, 1, 1, tocolor(0,0,0,255))
			DGS:dgsSetProperty(tempApp.label, "alignment", {"center", "center"})
			DGS:dgsSetProperty(tempApp.label, "wordBreak", false)
			DGS:dgsSetProperty(tempApp.label, "font", font)
			DGS:dgsSetProperty(tempApp.label, "shadow", {1, 1, tocolor(0, 0, 0, 200)})
			DGS:dgsSetPostGUI(tempApp.label, true)
			 tempApp.declineButton = DGS:dgsCreateButton(100*scaleValue, 380 * scaleValue, 48 * scaleValue, 48 * scaleValue, "", false, phoneGui.background)
            DGS:dgsSetProperty(tempApp.declineButton, "image", {declineTexture, declineTexture, declineTexture})
            DGS:dgsSetProperty(tempApp.declineButton, "color", {
                tocolor(255, 255, 255, 255),
                tocolor(200, 200, 200, 255),
                tocolor(150, 150, 150, 255)
            })
			addEventHandler("onDgsMouseClickUp", tempApp.declineButton, declineCall)

			
		end
	
    end
end


function addTime()
	timeTalking = timeTalking + 1
	DGS:dgsSetText(tempApp.labelTime, formatCallTime(timeTalking))
end
function declineCall(button)
	if source == tempApp.declineButton and button == "left" then
		triggerServerEvent("onPlayerDeclineCall", localPlayer)
		enableApp("home")
	end
end

function answerCall(button)
	if source == tempApp.acceptButton and button == "left" then
		triggerServerEvent("onPlayerAnswerCall", localPlayer)
	end
end
function getNameInContacts(phoneNumber)
    local name = phoneNumber
    for k, v in pairs(phoneGui.phoneData.contacts[1]) do
        if tonumber(v.phone) == tonumber(phoneNumber) then
            name = v.name
            break
        end
    end
    return name
end


function destroyApp()
	if isElement(soundRingtones) then destroyElement(soundRingtones) end
	if isElement(tempApp.memonotes) then exports.rp_library:destroyEditBox("notesMemo") end
	-- if isElement(tempApp.checkboxCallerHide) then exports.rp_library:destroyCheckbox("hidecallerid") end
	if isElement(tempApp.nameEditbox) then exports.rp_library:destroyEditBox("nameeditboxphone") end
	if isElement(tempApp.numberEditbox) then exports.rp_library:destroyEditBox("numbereditboxphone") end
	-- if isElement(tempApp.checkboxMute) then exports.rp_library:destroyCheckbox("mute") end
	-- if isElement(tempApp.faceTimeContact) then exports.rp_library

	for k,v in pairs(tempApp) do
		if isElement(v) then
			destroyElement(v)
		end
	end
	
end


function createWallpaper(type)
	if isElement(txtGlobal) then destroyElement(txtGlobal) end
	txtGlobal = false
	if type == "white" then
		txtGlobal = whiteTexture
	    DGS:dgsSetProperty(phoneGui.background, "image", {txtGlobal, txtGlobal, txtGlobal})
	elseif type == "background" then
		local backgroundPhone = phoneGui.phoneData.settings[1]["wallpaper"] or 1 --phoneGui.settings[1].wallpaper or "1"
		txtGlobal = dxCreateTexture("files/bg"..backgroundPhone..".jpg")
		DGS:dgsSetProperty(phoneGui.background, "image", txtGlobal)
	end
	
end
function homeClick(button)
    if source == phoneGui.homeButton then
        if button == "left" then
			if  timeTalking > 0 or actualApp == "talking" or actualApp == "calling" then return end
            enableApp("home")
			actualApp = "home"
        end
    end
end

local function onAppButtonClick(button, state)
    if button == "left" then
        local btn = source
        local idx = nil
        for i, b in ipairs(appButtons) do
            if b == btn then
                idx = i
                break
            end
        end
        if idx then
            local app = apps[idx]
            enableApp(app.id)
        end
    end
end


function localTimeTimer()
local timehour, timeminute = getTime()
timehour = timehour + 2
timeminute = timeminute + 1
DGS:dgsSetText(phoneGui.timeLabel, timehour..":"..timeminute)

end
local function createPhone(phoneData, client)
	if animating then return end
		-- iprint(phoneData)
		phoneGui.phoneData = phoneData or {}
		phoneGui.phoneData.contacts[1] = phoneGui.phoneData.contacts[1] or {}
		phoneGui.phoneData.settings[1].messages = phoneGui.phoneData.settings[1].messages or {}
		-- table.insert(phoneGui.phoneData.settings[1].messages, {number = 1000, message = "asdasdasd", timestamp = 0})
		-- iprint(phoneGui.phoneData.settings[1].messages)
		table.insert(phoneGui.phoneData.contacts[1], {name = "Numer alarmowy", phone = 911})
	if phoneNumberCall then
		triggerServerEvent("onPlayerDeclineCall", localPlayer)
	end
		destroyApp()
    if not createdImages then
        phoneGui.cellphone = DGS:dgsCreateImage(startX, startY + 600 * scaleValue, 369 * scaleValue, 507 * scaleValue, "files/cellphone.png", false)
        phoneGui.background = DGS:dgsCreateImage(65 * scaleValue, 10 * scaleValue, 240 * scaleValue, 470 * scaleValue, "files/bg"..phoneGui.phoneData.settings[1]["wallpaper"]..".jpg", false, phoneGui.cellphone)
		phoneGui.battery = DGS:dgsCreateImage(270 * scaleValue, 20 * scaleValue, 16 * scaleValue, 8 * scaleValue, "files/battery.png", false, phoneGui.cellphone)
		local timehour, timeminute = getTime()
		timeminute = timeminute + 1
		timehour = timehour + 2
		phoneGui.timeLabel = DGS:dgsCreateLabel(80*scaleValue, 20*scaleValue, 10*scaleValue, 30*scaleValue, timehour..":"..timeminute, false, phoneGui.cellphone, 0xFFFFFFFF, 1, 1, 1, 1, tocolor(0,0,0,255))
		DGS:dgsSetProperty(phoneGui.timeLabel, "font", font)
		DGS:dgsSetProperty(phoneGui.timeLabel, "shadow", {1, 1, tocolor(0, 0, 0, 200)})
		-- phoneGui.homeButton = DGS:dgsCreateImage(130*scaleValue, 465 * scaleValue, 116 * scaleValue, 8 * scaleValue, "files/home.png", false, phoneGui.cellphone)
        DGS:dgsSetProperty(phoneGui.background, "color", tocolor(255, 255, 255, 255))
		phoneGui.timerForTimeLabel = setTimer(localTimeTimer, 60000, 0)
        DGS:dgsSetPostGUI(phoneGui.cellphone, true)
        DGS:dgsSetPostGUI(phoneGui.battery, true)
	    DGS:dgsSetPostGUI(phoneGui.timeLabel, true)

		 phoneGui.homeButton = DGS:dgsCreateButton(70*scaleValue, 450 * scaleValue, 116 * scaleValue, 8 * scaleValue, "", false, phoneGui.background)
            DGS:dgsSetProperty(phoneGui.homeButton, "image", {homeButtontexture, homeButtontexture, homeButtontexture})
            DGS:dgsSetProperty(phoneGui.homeButton, "color", {
                tocolor(255, 255, 255, 255),
                tocolor(200, 200, 200, 255),
                tocolor(150, 150, 150, 255)
            })
        DGS:dgsSetPostGUI(phoneGui.homeButton, true)

        DGS:dgsSetVisible(phoneGui.cellphone, false)
		addEventHandler("onDgsMouseClickUp", getRootElement(), onAppButtonClick)
		addEventHandler("onDgsMouseClickUp", phoneGui.homeButton, homeClick)
        createdImages = true
    end
	-- iprint(phoneData)
    phoneGui.showed = not phoneGui.showed
	if phoneGui.showed then
	setTimerPaused(phoneGui.timerForTimeLabel, false)
	DGS:dgsSetInputMode("no_binds_when_editing")
	-- showCursor(true)
    DGS:dgsSetVisible(phoneGui.cellphone, true)
    for _, btn in ipairs(appButtons) do
        DGS:dgsSetVisible(btn, true)
    end
    for _, lbl in ipairs(appLabels) do
        DGS:dgsSetVisible(lbl, true)
    end
    DGS:dgsMoveTo(phoneGui.cellphone, startX, startY, false, "OutQuad", 2000)
	-- DGS:dgsSetInputMode("no_binds")

else
    DGS:dgsMoveTo(phoneGui.cellphone, startX, startY + 600 * scaleValue, false, "OutQuad", 2000)
	DGS:dgsSetInputMode("allow_binds")
	-- showCursor(false)
	setTimerPaused(phoneGui.timerForTimeLabel, true)
    animating = true
    setTimer(function()
        DGS:dgsSetVisible(phoneGui.cellphone, false)
		-- showCursor(false)
		-- DGS:dgsSetInputMode("allow_binds")
        for _, btn in ipairs(appButtons) do
            DGS:dgsSetVisible(btn, false)
        end
        for _, lbl in ipairs(appLabels) do
            DGS:dgsSetVisible(lbl, false)
        end
        animating = false
    end, 2000, 1)
end

    if not createdAppIcons then
        local iconSize = 64 * scaleValue
        local padding = 20 * scaleValue
        local marginX = 5 * scaleValue
        local marginY = 30 * scaleValue
        local labelHeight = 15 * scaleValue
        local columns = 3

        for k, v in ipairs(apps) do
            local row = math.floor((k - 1) / columns)
            local col = (k - 1) % columns
            local x = marginX + col * (iconSize + padding)
            local y = marginY + row * (iconSize + padding)

			local texturePath = "files/" .. v.id .. ".png"
			local texture = dxCreateTexture(texturePath, "argb", true, "wrap")
            textures[#textures + 1] = texture -- trzymamy referencję

            local button = DGS:dgsCreateButton(x, y, iconSize, iconSize, "", false, phoneGui.background)
            DGS:dgsSetProperty(button, "image", {texture, texture, texture})
            DGS:dgsSetProperty(button, "color", {
                tocolor(255, 255, 255, 255),
                tocolor(200, 200, 200, 255),
                tocolor(150, 150, 150, 255)
            })
            table.insert(appButtons, button)


            local label = DGS:dgsCreateLabel(x, y + iconSize + 2 * scaleValue, iconSize, labelHeight, v.name, false, phoneGui.background, 0xFFFFFFFF, 1, 1, 1, 1, tocolor(0,0,0,255))
            DGS:dgsSetProperty(label, "alignment", {"center", "center"})
            DGS:dgsSetProperty(label, "wordBreak", false)
			DGS:dgsSetProperty(label, "font", font)
			DGS:dgsSetProperty(label, "shadow", {1, 1, tocolor(0, 0, 0, 200)})

            table.insert(appLabels, label)
        end
        createdAppIcons = true
    else
        -- for _, btn in ipairs(appButtons) do
            -- DGS:dgsSetVisible(btn, phoneGui.showed)
        -- end
        -- for _, lbl in ipairs(appLabels) do
            -- DGS:dgsSetVisible(lbl, phoneGui.showed)
        -- end
    end
end
addEvent("onPlayerUsePhone", true)
addEventHandler("onPlayerUsePhone", root, createPhone)
-- addCommandHandler("tel", createPhone, false, false)


function onClientPlayerWasted()
    if phoneGui.showed then
        createPhone(phoneGui.phoneData)
		-- destroyApp()
    end
end
addEventHandler("onClientPlayerWasted", localPlayer, onClientPlayerWasted)


-- local dane = {}

-- dane.contacts = {}
-- dane.settings = {}

-- table.insert(dane.settings, {ringtone = 1, wallpaper = 1, notes = {}, messages = {}, telegram = {}, number = 0})

-- setClipboard(toJSON(dane))
-- iprint(dane)
function addContact(name, phone)
    table.insert(phoneGui.phoneData.contacts[1], {
        name = name,
        phone = phone,
    })
	-- iprint(phoneGui.phoneData.contacts[1])
    triggerServerEvent("onPlayerPhoneEdit", localPlayer, "contact", {name = name, phone = phone})
end

function deleteContactFunc(phone)
	for k,v in pairs(phoneGui.phoneData.contacts[1]) do
		if v.phone == phone then
			table.remove(phoneGui.phoneData.contacts[1], k)
		end
	end
    triggerServerEvent("onPlayerPhoneEdit", localPlayer, "deletecontact", {name = name, phone = phone})
end

function changePhoneSettings(setting, value)
    if not phoneGui.phoneData.settings then return end

    phoneGui.phoneData.settings[1][setting] = value
    triggerServerEvent("onPlayerPhoneEdit", localPlayer, "settings", {setting = setting, value = value})
end

local characterEditorData = {}
DGS = exports.dgs
local sx, sy = guiGetScreenSize()
local scaleValue = exports.rp_scale:returnScaleValue()
local font = dxCreateFont('files/Helvetica.ttf', 11 * scaleValue, false, 'proof') or 'default' -- fallback to default
local tempCharacters = {}


function updateTempCharacters(characters) -- tylko update jak gracz stworzy postac:-)
tempCharacters = characters
buttonBackMenu()
-- iprint(tempCharacters, characters)
-- outputChatBox("stworzono postac")
exports.rp_library:createBox("Pomyślnie stworzono postać.")
end

addEvent ( "onCharacterCreated", true )
addEventHandler ( "onCharacterCreated", root, updateTempCharacters )


local disabledButton = false
function disableButton()
    if disabledButton then
        return
    end
    DGS:dgsSetEnabled(characterEditorData.buttonCreateChar, false)
    setTimer(
        function()
            disabledButton = false
            if isElement(characterEditorData.buttonCreateChar) then
                DGS:dgsSetEnabled(characterEditorData.buttonCreateChar, true)
            end
        end,
        3000,
        1
    )
end

function characterSelectGUI(characters)
	-- if #characters < 1 then return destroyLoginPanel(), createCharacter() end
    tempCharacters = characters
    destroyLoginPanel()
    characterEditorData.rectanglesecond = DGS:dgsCreateRoundRect(20, false, tocolor(26, 29, 38, 255))
    characterEditorData.window = DGS:dgsCreateWindow(sx / 2 - 200 * scaleValue,sy / 2 - 250 * scaleValue,400 * scaleValue,500 * scaleValue,nil,false,nil,0,characterEditorData.rectanglesecond,nil,characterEditorData.rectanglesecond,nil,nil,true)

	
    DGS:dgsSetProperty(characterEditorData.window, "sizable", false)
    characterEditorData.gridList = DGS:dgsCreateGridList(10 * scaleValue,10 * scaleValue,380 * scaleValue,480 * scaleValue,false,characterEditorData.window)
    characterEditorData.column = DGS:dgsGridListAddColumn(characterEditorData.gridList, "Postacie ("..#tempCharacters..")", 1)
	-- DGS:dgsSetPostGUI(characterEditorData.gridList, false)
    for k, v in ipairs(characters) do
		local playtimeInHours = math.floor(v.playtime / 3600)
		local playtimeInMinutes = math.floor((v.playtime % 3600) / 60) 
        local characterName = v.name .. " " .. v.surname.. " Czas gry: "..playtimeInHours.."h".." "..playtimeInMinutes.."m"
        local row = DGS:dgsGridListAddRow(characterEditorData.gridList)
        DGS:dgsGridListSetItemText(characterEditorData.gridList, row, characterEditorData.column, characterName)
		DGS:dgsGridListSetItemFont ( characterEditorData.gridList, row, characterEditorData.column, "default-bold" )
    end

    -- DGS:dgsSetProperty(characterEditorData.gridList, "font", font)
    DGS:dgsSetProperty(characterEditorData.gridList, "columnTextPosOffset", {120*scaleValue, 1*scaleValue})
    DGS:dgsSetProperty(characterEditorData.gridList, "leading", 5*scaleValue)
    DGS:dgsSetProperty(characterEditorData.gridList, "sortEnabled", false)
	DGS:dgsGridListSetColumnFont(characterEditorData.gridList, characterEditorData.column, "default-bold")

	characterEditorData.rectangleButton = DGS:dgsCreateRoundRect(15*scaleValue,false,tocolor(23,63,139,255))
	characterEditorData.rectangleButtonHoover = DGS:dgsCreateRoundRect(15*scaleValue,false,tocolor(0,95,255,255))
	characterEditorData.buttonCreateCharMenu = DGS:dgsCreateButton( sx /2 + 200 * scaleValue, sy / 2 - 250 * scaleValue, 200*scaleValue, 30*scaleValue, "Stwórz postać", false, nil, nil, 1, 1, characterEditorData.rectangleButton, characterEditorData.rectangleButtonHoover, characterEditorData.rectangleButtonHoover)
	DGS:dgsSetProperty(characterEditorData.buttonCreateCharMenu,"font",font)
	DGS:dgsSetProperty(characterEditorData.buttonCreateCharMenu,"textSize",{0.7,0.7})
	-- DGS:dgsSetPostGUI(characterEditorData.buttonCreateChar, true)
	addEventHandler ( "onDgsMouseClickUp", characterEditorData.buttonCreateCharMenu, buttonCharMenu )

    addEventHandler("onDgsGridListItemDoubleClick",characterEditorData.gridList,
        function(button, state, item)
            if button == "left" and state == "down" and item and source == characterEditorData.gridList then
                -- iprint(item, tempCharacters[item])
                triggerServerEvent("onPlayerSelectedCharacter", localPlayer, tempCharacters[item]) -- trigger id postaci, potem check czy postac serio o id jest jego, jezeli nie to kick/cheater i set data po serwerze
				exports.object_preview:destroyObjectPreview(characterEditorData.preview)
                destroyCharacterPanel()
				local music = returnMusic()
				if isElement(music) then destroyElement(music) end
				exports.rp_utils:destroySmoothMoveCamera()
				showChat(true)
            end
        end
    )

    showCursor(true)
end
addEvent ( "onCharacterPanelShow", true )
addEventHandler ( "onCharacterPanelShow", root, characterSelectGUI )

local maleSkins = exports.rp_utils:returnMaleSkins()
local femaleSkins = exports.rp_utils:returnFemaleSkins()


local lastSelectedSkin = false
function createCharacter() -- nowy form z editboxami.
    characterEditorData.rectanglesecond = DGS:dgsCreateRoundRect(20, false, tocolor(26, 29, 38, 255))

	characterEditorData.window =  DGS:dgsCreateWindow(sx / 2 - 200 * scaleValue,sy / 2 - 250 * scaleValue,400 * scaleValue,500 * scaleValue,nil,false,nil,0,characterEditorData.rectanglesecond,nil,characterEditorData.rectanglesecond,nil,nil,true)
	DGS:dgsSetProperty(characterEditorData.window, "sizable", false)
	characterEditorData.label = DGS:dgsCreateLabel(140 * scaleValue,70 * scaleValue,50 * scaleValue,50 * scaleValue,"Stwórz postać",false,characterEditorData.window)
	DGS:dgsSetProperty(characterEditorData.label,"font",font)
	
	
	
	characterEditorData.rectangleButton = DGS:dgsCreateRoundRect(15*scaleValue,false,tocolor(23,63,139,255))
	characterEditorData.rectangleButtonHoover = DGS:dgsCreateRoundRect(15*scaleValue,false,tocolor(0,95,255,255))
	characterEditorData.buttonCreateChar = DGS:dgsCreateButton( 100*scaleValue, 400*scaleValue, 200*scaleValue, 30*scaleValue, "Stwórz postać", false, characterEditorData.window, nil, 1, 1, characterEditorData.rectangleButton, characterEditorData.rectangleButtonHoover, characterEditorData.rectangleButtonHoover)
	DGS:dgsSetProperty(characterEditorData.buttonCreateChar,"font",font)
	DGS:dgsSetProperty(characterEditorData.buttonCreateChar,"textSize",{0.7,0.7})
	characterEditorData.nameEditbox = exports.rp_library:createEditBox("name:editbox", 100*scaleValue,140*scaleValue,200*scaleValue,50*scaleValue, "", characterEditorData.window, nil, tocolor(200, 200, 200, 0), 0.5, 0.6*scaleValue, 25, false) --id, x, y, w, h, text, parent, bgImage, bgColor, caretHeight, textSize, maxLength, masked
	characterEditorData.surnameEditbox = exports.rp_library:createEditBox("surname:editbox", 100*scaleValue,220*scaleValue,200*scaleValue,50*scaleValue, "", characterEditorData.window, nil, tocolor(200, 200, 200, 0), 0.5, 0.6*scaleValue, 25, false) --id, x, y, w, h, text, parent, bgImage, bgColor, caretHeight, textSize, maxLength, masked
	characterEditorData.ageEditbox = exports.rp_library:createEditBox("age:editbox", 100*scaleValue,300*scaleValue,200*scaleValue,50*scaleValue, "", characterEditorData.window, nil, tocolor(200, 200, 200, 0), 0.5, 0.6*scaleValue, 25, false) --id, x, y, w, h, text, parent, bgImage, bgColor, caretHeight, textSize, maxLength, masked
	characterEditorData.labelName = DGS:dgsCreateLabel(100 * scaleValue,130 * scaleValue,50 * scaleValue,50 * scaleValue,"Imie",false,characterEditorData.window)
	characterEditorData.labelSurname = DGS:dgsCreateLabel(100 * scaleValue,215 * scaleValue,50 * scaleValue,50 * scaleValue,"Nazwisko",false,characterEditorData.window)
	characterEditorData.labelAge = DGS:dgsCreateLabel(100 * scaleValue,290 * scaleValue,50 * scaleValue,50 * scaleValue,"Wiek",false,characterEditorData.window)
	setLabelSettings(characterEditorData.labelSurname)
	setLabelSettings(characterEditorData.labelName)
	setLabelSettings(characterEditorData.labelAge)
	characterEditorData.radiobutton = exports.rp_library:createCheckBox("checkbox:sex", 100*scaleValue, 360*scaleValue, "Płeć kobiety", characterEditorData.window, 0.5*scaleValue)

	
	characterEditorData.buttonBackMenu = DGS:dgsCreateButton( 100*scaleValue, 450*scaleValue, 200*scaleValue, 30*scaleValue, "Cofnij do wyboru postaci", false, characterEditorData.window, nil, 1, 1, characterEditorData.rectangleButton, characterEditorData.rectangleButtonHoover, characterEditorData.rectangleButtonHoover)
	DGS:dgsSetProperty(characterEditorData.buttonBackMenu,"font",font)
	DGS:dgsSetProperty(characterEditorData.buttonBackMenu,"textSize",{0.7,0.7})
	showCursor(true)
	characterEditorData.tempNPC = createPed(85, 0, 0, 0)
	setElementFrozen(characterEditorData.tempNPC, true)
	characterEditorData.preview = exports.object_preview:createObjectPreview(characterEditorData.tempNPC,0, 0, 180, sx/2+200*scaleValue, sy/2-250*scaleValue, 400*scaleValue, 440*scaleValue, false, true, true)
	characterEditorData.skinSelector = DGS:dgsCreateSelector(sx/2+250*scaleValue, sy/2+110*scaleValue, 300*scaleValue, 100*scaleValue)
	for k,v in pairs(maleSkins) do
	DGS:dgsSelectorAddItem(characterEditorData.skinSelector, k)
	end
	-- exports.object_preview:destroyObjectPreview(element objectPreviewElement)
	addEventHandler ( "onDgsMouseClickUp", characterEditorData.buttonBackMenu, buttonBackMenu )
	addEventHandler ( "onDgsMouseClickUp", characterEditorData.buttonCreateChar, buttonCreateChar )
	addEventHandler("onDgsSelectorSelect",characterEditorData.skinSelector,onSelected)
	addEventHandler("onDgsCheckBoxChange", characterEditorData.radiobutton, onStateChanged)


end
function onStateChanged(state)
    if source == characterEditorData.radiobutton then
        if state then
            DGS:dgsSelectorClear(characterEditorData.skinSelector)
            for k, v in pairs(femaleSkins) do
                DGS:dgsSelectorAddItem(characterEditorData.skinSelector, k)
            end
			if lastSelectedSkin then
			setElementModel(characterEditorData.tempNPC, DGS:dgsSelectorGetItemText(characterEditorData.skinSelector, tonumber(lastSelectedSkin)))
			end
        else
            DGS:dgsSelectorClear(characterEditorData.skinSelector)

            for k, v in pairs(maleSkins) do
                DGS:dgsSelectorAddItem(characterEditorData.skinSelector, k)
            end
			if lastSelectedSkin then
			setElementModel(characterEditorData.tempNPC, DGS:dgsSelectorGetItemText(characterEditorData.skinSelector, tonumber(lastSelectedSkin)))
			end
        end
    end
end


function onSelected(current, previous)
    setElementModel(characterEditorData.tempNPC, DGS:dgsSelectorGetItemText(characterEditorData.skinSelector, current))
	lastSelectedSkin = DGS:dgsSelectorGetItemText(characterEditorData.skinSelector, current)
	-- print(lastSelectedSkin, current)
end

function buttonCharMenu()
    if source == characterEditorData.buttonCreateCharMenu then
        destroyCharacterPanel()
        createCharacter()
    end
end

function buttonCreateChar()
    if source == characterEditorData.buttonCreateChar then
		if not lastSelectedSkin then return exports.rp_library:createBox("Wybierz skina") end
        local name, surname, age = capitalizeFirstLetter(exports.rp_library:getEditBoxText("name:editbox")), capitalizeFirstLetter(exports.rp_library:getEditBoxText("surname:editbox")), exports.rp_library:getEditBoxText("age:editbox")
        if string.len(name) < 4 or string.len(surname) < 4 or string.len(name) > 16 or string.len(surname) > 16 then
            return exports.rp_library:createBox("Imie lub nazwisko postaci jest za krótkie lub zbyt długie (max 16 znaków na każde pole)")
        end
        if not tonumber(age) then
            return exports.rp_library:createBox("Wiek musi być liczbą, przedział 16-80")
        end
        if tonumber(age) < 16 or tonumber(age) > 80 then
            return exports.rp_library:createBox("Wiek posiada przedział 16-80.")
        end
		local sex = 0
		if exports.rp_library:getCheckBoxState("checkbox:sex") then
			sex = 1
		end
        triggerServerEvent("onPlayerCreateCharacter", localPlayer, name, surname, age, sex, lastSelectedSkin)
		disableButton()
    end
end

function buttonBackMenu()
    if source == characterEditorData.buttonBackMenu then
        destroyCharacterPanel()
        characterSelectGUI(tempCharacters)
    end
end




function destroyCharacterPanel()
	-- destroyElement(characterEditorData.gridList)
    for k, v in pairs(characterEditorData) do
        if isElement(v) then
            destroyElement(v)
        end
    end
    -- tempCharacters = {}
end







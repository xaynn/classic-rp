local characterEditorData = {}
DGS = exports.dgs
local sx, sy = guiGetScreenSize()
local scaleValue = exports.rp_scale:returnScaleValue()
local font = dxCreateFont('files/Helvetica.ttf', 10 * scaleValue, false, 'proof') or 'default' -- fallback to default
local tempCharacters = {}
local previews = {} 
local lastSelectedSkin = false

function updateTempCharacters(characters) -- tylko update jak gracz stworzy postac:-)
tempCharacters = characters
backToCharacters()
exports.rp_library:createBox("Pomyślnie stworzono postać.")
end

addEvent ( "onCharacterCreated", true )
addEventHandler ( "onCharacterCreated", root, updateTempCharacters )

local maleSkins = exports.rp_utils:returnMaleSkins()
local femaleSkins = exports.rp_utils:returnFemaleSkins()

function onCharacterPanelShow(characters)
tempCharacters = characters
-- iprint(tempCharacters)
destroyLoginPanel()
addEventHandler("onClientRender", root, drawCharacterSelection)
addEventHandler("onClientClick", root, onClick)
characterEditorData.menuCreate = exports.rp_library:createButtonRounded("charcreatemenu:button",sx / 2 - 170 * scaleValue,sy / 2 - 160 * scaleValue,340 * scaleValue,45 * scaleValue,"Stwórz postać",_,0.7*scaleValue,15)
addEventHandler("onDgsMouseClickUp", characterEditorData.menuCreate, openMenu)

end
addEvent ( "onCharacterPanelShow", true )
addEventHandler ( "onCharacterPanelShow", root, onCharacterPanelShow )
local tempVehiclesTable = {439, 410, 549, 491, 529, 462, 478}-- check po serverze czy jest dobre ID.
local lastSelectedVehicle = false
function openMenu()
	characterEditorData.tempVehicle = createVehicle(439, 0, 0, 0, 0, 0, 0, "NONE")
	removeEventHandler("onClientRender", root, drawCharacterSelection)
	removeEventHandler("onClientClick", root, onClick)
	exports.rp_library:destroyButton("charcreatemenu:button") 
	characterEditorData.nameeditbox = exports.rp_library:createEditBox("name:charcreate",sx / 2 - 170 * scaleValue,sy / 2 - 160 * scaleValue,200 * scaleValue,40 * scaleValue,"",_,0.5*scaleValue,0.6*scaleValue,15,false,"Imie",false,15)
	characterEditorData.surnameeditbox = exports.rp_library:createEditBox("surname:charcreate",sx / 2 - 170 * scaleValue,sy / 2 - 100 * scaleValue,200 * scaleValue,40 * scaleValue,"",_,0.5*scaleValue,0.6*scaleValue,15,false,"Nazwisko",false,15)
	characterEditorData.ageeditbox = exports.rp_library:createEditBox("age:charcreate",sx / 2 - 170 * scaleValue,sy / 2 - 40 * scaleValue,200 * scaleValue,40 * scaleValue,"",_,0.5*scaleValue,0.6*scaleValue,15,false,"Wiek (16-80)",false,15)
	characterEditorData.weightchar = exports.rp_library:createEditBox("weight:charcreate",sx / 2 - 170 * scaleValue,sy / 2 + 20 * scaleValue,200 * scaleValue,40 * scaleValue,"",_,0.5*scaleValue,0.6*scaleValue,3,false,"Waga",false,15)
	characterEditorData.heightchar = exports.rp_library:createEditBox("height:charcreate",sx / 2 + 40 * scaleValue,sy / 2 - 160 * scaleValue,200 * scaleValue,40 * scaleValue,"",_,0.5*scaleValue,0.6*scaleValue,3,false,"Wzrost",false,15)
	characterEditorData.menuBackToChars = exports.rp_library:createButtonRounded("charback:button",sx / 2 - 170 * scaleValue,sy / 2 + 100 * scaleValue,340 * scaleValue,45 * scaleValue,"Cofnij do postaci",_,0.7*scaleValue,15)
	addEventHandler("onDgsMouseClickUp", characterEditorData.menuBackToChars, backToCharacters)
	characterEditorData.createCharacter = exports.rp_library:createButtonRounded("char:createbutton",sx / 2 - 170 * scaleValue,sy / 2 + 160 * scaleValue,340 * scaleValue,45 * scaleValue,"Stwórz postać",_,0.7*scaleValue,15)
	addEventHandler("onDgsMouseClickUp", characterEditorData.createCharacter, tryToCreateCharacter)
    characterEditorData.checkbox = exports.rp_library:createCheckBox( "checkbox:sex",sx / 2 + 45 * scaleValue,sy / 2 + 60 * scaleValue,"Płeć kobiety",_,0.5 * scaleValue)
	characterEditorData.charSkin = exports.rp_library:createComboBox("combobox:skin", sx / 2 + 40 * scaleValue,sy / 2 - 100 * scaleValue,200 * scaleValue,40 * scaleValue, "Kolor postaci", nil, 20, 0.6*scaleValue)
	DGS:dgsComboBoxAddItem(characterEditorData.charSkin, "Czarny")
	DGS:dgsComboBoxAddItem(characterEditorData.charSkin, "Biały")
	DGS:dgsComboBoxAddItem(characterEditorData.charSkin, "Żółty")
	characterEditorData.skinSelector =  DGS:dgsCreateSelector(sx / 2 + 310 * scaleValue,sy / 2 + 130 * scaleValue, 300*scaleValue, 100*scaleValue)
	characterEditorData.skinSelectorVehicle =  DGS:dgsCreateSelector(sx / 2 - 500 * scaleValue,sy / 2 - 10  * scaleValue, 300*scaleValue, 100*scaleValue)
	addEventHandler("onDgsSelectorSelect",characterEditorData.skinSelector,onSelected)
	addEventHandler("onDgsSelectorSelect",characterEditorData.skinSelectorVehicle,onSelectedVehicle)
	addEventHandler("onDgsCheckBoxChange", characterEditorData.checkbox, onStateChanged)
	for k,v in pairs(maleSkins) do
	DGS:dgsSelectorAddItem(characterEditorData.skinSelector, k)
	end
	for k,v in pairs(tempVehiclesTable) do
		DGS:dgsSelectorAddItem(characterEditorData.skinSelectorVehicle, v)
	end
	characterEditorData.tempNPC = createPed(7, 0, 0, 0)
	setElementFrozen(characterEditorData.tempNPC, true)
	characterEditorData.preview = exports.object_preview:createObjectPreview(characterEditorData.tempNPC,0, 0, 180, sx/2+250*scaleValue, sy/2-250*scaleValue, 400*scaleValue, 440*scaleValue, false, true, true)
	characterEditorData.previewVehicle = exports.object_preview:createObjectPreview(characterEditorData.tempVehicle,0, 0, 180, sx/2-550*scaleValue, sy/2-300*scaleValue, 400*scaleValue, 440*scaleValue, false, true, true)

end


function backToCharacters()
	exports.rp_library:destroyEditBox("name:charcreate")
	exports.rp_library:destroyEditBox("surname:charcreate")
	exports.rp_library:destroyEditBox("age:charcreate")
	exports.rp_library:destroyButton("charback:button")
	exports.rp_library:destroyButton("char:createbutton")
	exports.rp_library:destroyCheckbox("checkbox:sex")
	exports.rp_library:destroyComboBox("combobox:skin")
	exports.rp_library:destroyEditBox("weight:charcreate")
	exports.rp_library:destroyEditBox("height:charcreate")
	destroyElement(characterEditorData.skinSelector)
	destroyElement(characterEditorData.skinSelectorVehicle)
	-- exports.object_preview:destroyObjectPreview(characterEditorData.tempNPC)
	-- exports.object_preview:destroyObjectPreview(characterEditorData.tempVehicle)
	destroyElement(characterEditorData.tempNPC)
	destroyElement(characterEditorData.tempVehicle)

	

	onCharacterPanelShow(tempCharacters)
end

function onStateChanged(state)
    if source == characterEditorData.checkbox then
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

function onSelectedVehicle(current, previous)
    setElementModel(characterEditorData.tempVehicle, DGS:dgsSelectorGetItemText(characterEditorData.skinSelectorVehicle, current))
	-- print(lastSelectedSkin, current)
	lastSelectedVehicle = DGS:dgsSelectorGetItemText(characterEditorData.skinSelectorVehicle, current)
end

function tryToCreateCharacter()

	local item = DGS:dgsComboBoxGetSelectedItem(characterEditorData.charSkin)
	if item == -1 then return exports.rp_library:createBox("Wybierz kolor postaci.") end
	if not lastSelectedSkin then return exports.rp_library:createBox("Wybierz skin postaci.") end
    local text = DGS:dgsComboBoxGetItemText(characterEditorData.charSkin, item)
   local name, surname, age, weight, height, skinColor = capitalizeFirstLetter(exports.rp_library:getEditBoxText("name:charcreate")), capitalizeFirstLetter(exports.rp_library:getEditBoxText("surname:charcreate")), tonumber(exports.rp_library:getEditBoxText("age:charcreate")), tonumber(exports.rp_library:getEditBoxText("weight:charcreate")), tonumber(exports.rp_library:getEditBoxText("height:charcreate")), text
        if string.len(name) < 4 or string.len(surname) < 4 or string.len(name) > 20 or string.len(surname) > 20 then
            return exports.rp_library:createBox("Imie lub nazwisko postaci jest za krótkie lub zbyt długie (max 20 znaków na każde pole)")
        end
        if not tonumber(age) then
            return exports.rp_library:createBox("Wiek musi być liczbą, przedział 16-80")
        end
        if tonumber(age) < 16 or tonumber(age) > 80 then
            return exports.rp_library:createBox("Wiek posiada przedział 16-80.")
        end
		if tonumber(weight) > 150 or tonumber(weight) < 30  then return exports.rp_library:createBox("Waga ma zakres 30-150 kg.") end
		if tonumber(height) > 200 or tonumber(height) < 150 then return exports.rp_library:createBox("Wzrost ma zakres 150-200cm.") end
		local sex = 0
		if exports.rp_library:getCheckBoxState("checkbox:sex") then
			sex = 1
		end
		if not lastSelectedVehicle then return exports.rp_library:createBox("Wybierz startowy pojazd.") end
        triggerServerEvent("onPlayerCreateCharacter", localPlayer, name, surname, age, sex, lastSelectedSkin, weight, height, skinColor, lastSelectedVehicle)
end

local visibleIndex = 1  
local maxVisible = 3    
local buttonPositions = {} 

function drawCharacterSelection()
    local startX, startY = sx/2-200*scaleValue, sy/2-100*scaleValue  
    local spacing = 150 * scaleValue              
    buttonPositions = {}            

    for i = 0, maxVisible - 1 do
        local index = visibleIndex + i
        if tempCharacters[index] then
            local charX = startX + i * spacing
            local charY = startY

            dxDrawRectangle(charX, charY, 120 * scaleValue, 200 * scaleValue, tocolor(0, 0, 0, 150))
            dxDrawText(tempCharacters[index].name.." "..tempCharacters[index].surname, charX, charY + 220 * scaleValue, charX + 120 * scaleValue, charY + 250 * scaleValue, tocolor(255, 255, 255), 0.8, font, "center", "top")
			local playtimeInHours = math.floor(tempCharacters[index].playtime / 3600)
			local playtimeInMinutes = math.floor((tempCharacters[index].playtime % 3600) / 60) 
			dxDrawText("Czas gry: "..playtimeInHours.."h, "..playtimeInMinutes.."m", charX, charY + 240 * scaleValue, charX + 120 * scaleValue, charY + 250 * scaleValue, tocolor(255, 255, 255), 0.8, font, "center", "top")
			local frmjson = fromJSON(tempCharacters[index].statistics)
			local skin = getCharData(frmjson, "skin")
			if fileExists("files/skins/"..skin..".png") then
			dxDrawImage(charX - 5 * scaleValue, charY+30 * scaleValue, 128 * scaleValue, 128 * scaleValue, "files/skins/"..skin..".png", _, _, _, _, true)
			else
				dxDrawText("?",charX+60*scaleValue, charY+80*scaleValue, charX+60*scaleValue, charY+80*scaleValue, tocolor(111, 97, 209, 255), 5*scaleValue, 5*scaleValue, "default", "center", "center")
			end			
            local buttonX, buttonY, buttonW, buttonH = charX + 10 * scaleValue, charY + 260 * scaleValue, 100 * scaleValue, 30 * scaleValue
            dxDrawRectangle(buttonX, buttonY, buttonW, buttonH, tocolor(111, 97, 209, 200))
            dxDrawText("Wybierz", buttonX, buttonY, buttonX + buttonW, buttonY + buttonH, tocolor(17,18,19,255), 1, font, "center", "center")

            table.insert(buttonPositions, {x = buttonX, y = buttonY, w = buttonW, h = buttonH, char = tempCharacters[index]})
        end
    end

    if visibleIndex > 1 then
        dxDrawText("<", startX - 50, startY + 100, startX - 20, startY + 150, tocolor(255, 255, 255), 1.5, "default-bold", "center", "center")
    end

    if visibleIndex + maxVisible - 1 < #tempCharacters then
        dxDrawText(">", startX + maxVisible * spacing, startY + 100, startX + maxVisible * spacing + 30, startY + 150, tocolor(255, 255, 255), 1.5, "default-bold", "center", "center")
    end
end

function onClick(button, state, x, y)
    if button == "left" and state == "down" then
        local startX, startY = sx/2-200*scaleValue, sy/2-100*scaleValue
        local spacing = 150 * scaleValue

        if x >= startX - 50 * scaleValue and x <= startX - 20 * scaleValue and visibleIndex > 1 then
            visibleIndex = visibleIndex - 1
            return
        end

        if x >= startX + maxVisible * spacing and x <= startX + maxVisible * spacing + 30 * scaleValue and visibleIndex + maxVisible - 1 < #tempCharacters then
            visibleIndex = visibleIndex + 1
            return
        end

        for _, btn in ipairs(buttonPositions) do
            if x >= btn.x and x <= btn.x + btn.w and y >= btn.y and y <= btn.y + btn.h then
                selectCharacter(btn.char)
                return
            end
        end
    end
end

function selectCharacter(tableData)
	triggerServerEvent("onPlayerSelectedCharacter", localPlayer, tableData)
	removeEventHandler("onClientRender", root, drawCharacterSelection)
	removeEventHandler("onClientClick", root, onClick)
	destroyElement(background)
	local music = returnMusic()
	destroyElement(music)
	showChat(true)
	exports.rp_library:destroyButton("charcreatemenu:button") 

    -- outputChatBox("Wybrałeś postać: " .. tableData.name, 255, 255, 0)
end




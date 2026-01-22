DGS = exports.dgs
local menuDesc = {}
local descColors = {}
local savedDescs = {}

guiSetInputMode("no_binds_when_editing")
menuDesc.showedDescMenu = false
local sx, sy = guiGetScreenSize()
local scaleValue = exports.rp_scale:returnScaleValue()
local font = dxCreateFont("files/Helvetica.ttf", 12 * scaleValue, false, "proof") or "default" -- fallback to default

function setLabelSettings(label)
    DGS:dgsSetProperty(label, "font", font)
    DGS:dgsSetProperty(label, "textSize", {0.7, 0.7})
    DGS:dgsSetProperty(label, "textColor", tocolor(226, 227, 227))
end

function onButtonSetDesc(button, state)
    if source == menuDesc.buttonSet then
        if button == "left" and state == "down" then
            local desc = DGS:dgsGetText(menuDesc.memo)
            -- local txt = splitText(desc, 40)
            local txt = correctDescColors(desc)
            triggerServerEvent("onPlayerChangeDescription", localPlayer, txt)
        end
    end
end

function onButtonSaveDesc(button, state)
    if source == menuDesc.buttonSave then
        if button == "left" and state == "down" then
            local text = DGS:dgsGetText(menuDesc.memo)
            local desc = DGS:dgsGetText(menuDesc.memo)
			if string.len(text) < 1 then return exports.rp_library:createBox("Nie da się zapisać pustego opisu.") end
            if #text > 10 then
                text = text:sub(1, 10) .. "..."
            end

            setSavedDesc(text, desc)
            local tmpTable = {text, desc}
            local row = DGS:dgsGridListAddRow(menuDesc.gridlist)
            DGS:dgsGridListSetItemText(menuDesc.gridlist, row, menuDesc.column, text) -- nazwa v[1], v[2] opis
            DGS:dgsGridListSetItemData(menuDesc.gridlist, row, menuDesc.column, tmpTable)
        end
    end
    saveDescToXML()
end

function onButtonDeleteDesc(button, state)
    if source == menuDesc.buttonDelete then
        if button == "left" and state == "down" then
            local selectedRow, selectedColumn = DGS:dgsGridListGetSelectedItem(menuDesc.gridlist)
            if selectedRow ~= -1 then
                local data = DGS:dgsGridListGetItemData(menuDesc.gridlist, selectedRow, selectedColumn)
                DGS:dgsGridListRemoveRow(menuDesc.gridlist, selectedRow)
                deleteDesc(data[2])
                exports.rp_library:createBox("Pomyślnie usunięto opis.")
            --delete
            end
        end
    end
    saveDescToXML()
end



function deleteDesc(data)
    for k, v in ipairs(savedDescs) do
        if v[2] == data then
            table.remove(savedDescs, k)
        end
    end
end



function setSavedDesc(descName, desc)
table.insert(savedDescs, {descName, desc})
end

function onDescMenuCreated()
    menuDesc.showedDescMenu = not menuDesc.showedDescMenu
    if menuDesc.showedDescMenu then
        -- menuDesc.rectanglesecond = DGS:dgsCreateRoundRect(20, false, tocolor(26, 29, 38, 255))
        menuDesc.window = exports.rp_library:createWindow("descWindow", sx/2-200*scaleValue, sy/2-250*scaleValue, 400*scaleValue, 500*scaleValue, "Menu opisów", 5, 0.55*scaleValue, true)--DGS:dgsCreateWindow(sx / 2 - 200 * scaleValue,sy / 2 - 250 * scaleValue,400 * scaleValue,500 * scaleValue,nil,false,nil,0,menuDesc.rectanglesecond,nil,menuDesc.rectanglesecond,nil,nil,true)
        -- menuDesc.labelSign = DGS:dgsCreateLabel(70 * scaleValue,70 * scaleValue,50 * scaleValue,50 * scaleValue,"Classic RolePlay",false,menuDesc.window)
        DGS:dgsSetProperty(menuDesc.window, "sizable", false)
        menuDesc.labelSign = DGS:dgsCreateLabel(20 * scaleValue,30 * scaleValue,30 * scaleValue,50 * scaleValue,"Witaj w panelu opisów, wpisz swój opis i zapisz go, bądź ustaw.",false,menuDesc.window)
		menuDesc.labelDesc = DGS:dgsCreateLabel(20 * scaleValue,60 * scaleValue,30 * scaleValue,50 * scaleValue,"Opis:",false,menuDesc.window)
        menuDesc.memo = exports.rp_library:createMemoEditBox("descMemo", 20* scaleValue, 79 * scaleValue, 360 * scaleValue, 50 * scaleValue, "", menuDesc.window, 0.8*scaleValue, 0.6*scaleValue, 80, "Napisz tutaj swój piękny opis", 5)--DGS:dgsCreateMemo(20 * scaleValue,79 * scaleValue,360 * scaleValue,50 * scaleValue,"",false,menuDesc.window)
		-- DGS:dgsSetProperty(menuDesc.memo,"font","default-bold")
		-- DGS:dgsSetProperty(menuDesc.memo,"bgImage",menuDesc.rectangleforMemo)
        menuDesc.buttonSet = exports.rp_library:createButtonRounded("desc:buttonset",80*scaleValue,380*scaleValue,100*scaleValue,30*scaleValue,"Ustaw",menuDesc.window,0.6*scaleValue,10)
		menuDesc.buttonSave = exports.rp_library:createButtonRounded("desc:buttonsave",200*scaleValue,380*scaleValue,100*scaleValue,30*scaleValue,"Zapisz opis",menuDesc.window,0.6*scaleValue,10)
		menuDesc.buttonDelete = exports.rp_library:createButtonRounded("desc:buttondelete",140*scaleValue,420*scaleValue,100*scaleValue,30*scaleValue,"Usun opis",menuDesc.window,0.6*scaleValue,10)

        addEventHandler("onDgsMouseClick", menuDesc.buttonSet, onButtonSetDesc)
		addEventHandler("onDgsMouseClick", menuDesc.buttonSave, onButtonSaveDesc)
		addEventHandler("onDgsMouseClick", menuDesc.buttonDelete, onButtonDeleteDesc)
        setLabelSettings(menuDesc.labelSign)
		setLabelSettings(menuDesc.labelDesc)
		-- DGS:dgsSetProperty(menuDesc.memo,"placeHolderVisibleWhenFocus","Test")
		addEventHandler("onDgsWindowClose",menuDesc.window,windowClosed)


		-- DGS:dgsSetProperty(menuDesc.memo,"placeHolder","Opis")
        -- DGS:dgsSetProperty(menuDesc.memo, "caretOffset", 1)
        DGS:dgsSetProperty(menuDesc.memo, "wordWrap", 1)
		-- DGS:dgsMemoSetMaxLength(menuDesc.memo, 80)
		DGS:dgsSetText(menuDesc.memo, exports.rp_login:getPlayerData(localPlayer,"desc") or "")
		-- addEventHandler("onClientKey", root, destroyDescMenuOnButton)
		menuDesc.gridlist = DGS:dgsCreateGridList (20*scaleValue, 163*scaleValue, 360*scaleValue, 200*scaleValue, false, menuDesc.window )
		menuDesc.column = DGS:dgsGridListAddColumn( menuDesc.gridlist, "Nazwa opisu", 1 )
		DGS:dgsGridListSetColumnFont(menuDesc.gridlist, menuDesc.column, "default-bold")

		
		    addEventHandler("onDgsGridListItemDoubleClick",menuDesc.gridlist,
        function(button, state, item)
            if button == "left" and state == "down" and item and source == menuDesc.gridlist then
                -- iprint(item, tempCharacters[item])
				DGS:dgsGridListGetItemText(menuDesc.gridlist , item, menuDesc.column)
				local data = DGS:dgsGridListGetItemData ( menuDesc.gridlist, item, menuDesc.column) -- zwraca tablice.
				DGS:dgsSetText(menuDesc.memo,data[2])
            end
        end
    )
		
		for k,v in ipairs(savedDescs) do
			local row = DGS:dgsGridListAddRow(menuDesc.gridlist) 
			DGS:dgsGridListSetItemText(menuDesc.gridlist, row, menuDesc.column, tostring(v[1])) -- nazwa v[1], v[2] opis 
			DGS:dgsGridListSetItemData ( menuDesc.gridlist, row, menuDesc.column, v )
			DGS:dgsGridListSetItemFont ( menuDesc.gridlist, row, menuDesc.column, "default-bold" )
		end
		-- DGS:dgsGridListSetItemText ( menuDesc.gridlist, row, menuDesc.column, "testowe" )
        showCursor(true)
    else
        destroyDescMenu()
    end
end
addCommandHandler("opis", onDescMenuCreated, false, false)

function windowClosed()
	cancelEvent()
	menuDesc.showedDescMenu = false
	setTimer(function()
		showCursor(false)
		destroyDescMenu()
	end,50,1)
end

function destroyDescMenuOnButton(button, press)
	if button == "escape" and press then
	cancelEvent()
	removeEventHandler("onClientKey", root, destroyDescMenuOnButton)
    for k, v in pairs(menuDesc) do
        if isElement(v) then
            destroyElement(v)
        end
    end
    showCursor(false)
	menuDesc.showedDescMenu = false
	end
end

function destroyDescMenu(button, press)
    for k, v in pairs(menuDesc) do
        if isElement(v) then
            destroyElement(v)
        end
    end
    showCursor(false)
	menuDesc.showedDescMenu = false
end

function splitText(originalText, lim)
    if originalText then
        local tab = split(originalText, " ")
        local newText = ""
        local currentLineNumber = 0
        local lineLim = lim or 50

        for k, v in ipairs(tab) do
            local orgLen = string.len(v)
            local vAfter = string.gsub(v, "#%x%x%x%x%x%x", "")
             --tekst po usuniecu hexów
            local newLen = string.len(vAfter)

            --outputChatBox ("B: " .. v .. ", A: " .. tostring(vAfter))

            if newLen < 40 then -- zabezpieczenie przeciw dlugim slowom
                if currentLineNumber + newLen > lineLim then
                    newText = newText .. "\n" .. v
                    currentLineNumber = newLen
                else
                    newText = newText .. " " .. v
                    currentLineNumber = currentLineNumber + newLen + 1 -- +1 bo spacja
                end
            end
        end

        return newText
    end
end

descColors["{n}"] = "#dca2f4"
 --220,162,244
descColors["{normalny}"] = "#dca2f4"
 --220,162,244
descColors["{standardowy}"] = "#dca2f4"
 --220,162,244

descColors["{r}"] = "#db0000" -- 219,0,0
descColors["{czerwony}"] = "#db0000" -- 219,0,0

descColors["{b}"] = "#224ff4" -- 34,79,244
descColors["{niebieski}"] = "#224ff4" -- 34,79,244

descColors["{aq}"] = "#22e3f4" -- 34,227,244
descColors["{aqua}"] = "#22e3f4" -- 34,227,244

descColors["{g}"] = "#22f44a" -- 34,227,74
descColors["{zielony}"] = "#22f44a" -- 34,227,74

descColors["{y}"] = "#f4f222" -- 244,242,34
descColors["{zolty}"] = "#f4f222" -- 244,242,34

descColors["{o}"] = "#f4b122" -- 244,177,34
descColors["{pomaranczowy}"] = "#f4b122" -- 244,177,34

function correctDescColors(desc)
    if not exports.rp_login:getPlayerData(localPlayer,"premium") then
        desc = string.gsub(desc, "#%x%x%x%x%x%x", "") -- usuwa hexy
        for i, v in pairs(descColors) do
            desc = string.gsub(desc, i, "")
        end
    else
        for i, v in pairs(descColors) do
            desc = string.gsub(desc, i, v)
        end
    end

    return desc
end




function loadDescs()
    local fileAnims = xmlLoadFile("files/description.xml")
    if fileAnims then
        local anims = xmlFindChild(fileAnims, "savedDesc", 0)
        local data = xmlNodeGetValue(anims)
        -- outputChatBox(data)
        if data == "" then
            return
        end
        -- outputChatBox("check2")
        local json = fromJSON(data)
        savedDescs = json
    end

    xmlUnloadFile(fileAnims)
end

if not fileExists("files/description.xml") then
    local rootNode = xmlCreateFile("files/description.xml", "Descs")
    local childNode = xmlCreateChild(rootNode, "savedDesc")
    xmlSaveFile(rootNode)
    xmlUnloadFile(rootNode)
else
    loadDescs()
end


function saveDescToXML()
local file = xmlLoadFile("files/description.xml")
        if file then
            local nodeNick = xmlFindChild(file, "savedDesc", 0)
            local json = toJSON(savedDescs)
            xmlNodeSetValue(nodeNick, json)
            xmlSaveFile(file)
            xmlUnloadFile(file)
        end
end
loadDescs()
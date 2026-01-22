local sx,sy = guiGetScreenSize()
local scaleValue = exports.rp_scale:returnScaleValue()
DGS = exports.dgs
local mdtGui = {}
local gui911 = {}
local mdtData = {}
local data911 = {}
local font = dxCreateFont("files/Helvetica.ttf", 18 * scaleValue, false, "proof")
local fontheader = dxCreateFont("files/Helvetica.ttf", 10 * scaleValue, false, "proof")

local offSetX, offsetY = exports.rp_scale:returnOffsetXY()
local function windowClosedMDT()
    showCursor(false)
    mdtGui.showed = false
    mdtData = {}
    actualPlayer = false
end
local actualPlayer = false
local function openMDT(data)
    if mdtGui.showed then
        return
    end
    mdtGui.showed = true
    mdtData = data
    mdtGui.window = exports.rp_library:createWindow("MDTOpenGui",sx / 2 - 350 * scaleValue,sy / 2 - 250 * scaleValue,600 * scaleValue,500 * scaleValue,"Mobile Database Terminal",5,0.55 * scaleValue,true)
    local rectangle = DGS:dgsCreateRoundRect({{0, false}, {0, false}, {6, false}, {6, false}}, tocolor(26, 29, 38, 255))
    mdtGui.tabPanel = DGS:dgsCreateTabPanel(5 * scaleValue,1 * scaleValue,590 * scaleValue,450 * scaleValue,false,mdtGui.window,_,rectangle)
    DGS:dgsCenterElement(mdtGui.window)
    mdtGui.tab1 = DGS:dgsCreateTab("Poszukiwane osoby", mdtGui.tabPanel)
    mdtGui.tab2 = DGS:dgsCreateTab("Poszukiwane pojazdy", mdtGui.tabPanel)
    mdtGui.tab3 = DGS:dgsCreateTab("Legalna broń", mdtGui.tabPanel)
    mdtGui.tab4 = DGS:dgsCreateTab("Lista osób", mdtGui.tabPanel)
    mdtGui.tab5 = DGS:dgsCreateTab("Wystaw poszukiwanie", mdtGui.tabPanel)
    mdtGui.editboxWantedPersons = exports.rp_library:createEditBox("mdt:editboxwantedpersons",5 * scaleValue,10 * scaleValue,580 * scaleValue,30 * scaleValue,"",mdtGui.tab1,0.5 * scaleValue,0.7 * scaleValue,10,false,"Dane",false,0)
    mdtGui.editboxWantedVehicles = exports.rp_library:createEditBox("mdt:editboxwantedvehicles",5 * scaleValue,10 * scaleValue,580 * scaleValue,30 * scaleValue,"",mdtGui.tab2,0.5 * scaleValue,0.7 * scaleValue,10,false,"Dane",false,0)
    mdtGui.editboxPlayers = exports.rp_library:createEditBox("mdt:editboxplayers",5 * scaleValue,10 * scaleValue,580 * scaleValue,30 * scaleValue,"",mdtGui.tab4,0.5 * scaleValue,0.7 * scaleValue,10,false,"Dane",false,0)

    mdtGui.gridListWantedPersons = exports.rp_library:createGridList("mdt:wantedpersons",5 * scaleValue,50 * scaleValue,580 * scaleValue,150 * scaleValue,mdtGui.tab1,nil,1 * scaleValue)
    mdtGui.gridListLogs = exports.rp_library:createGridList("mdt:wantedpersonslogs",5 * scaleValue,230 * scaleValue,580 * scaleValue,150 * scaleValue,mdtGui.tab1,nil,1 * scaleValue)
    mdtGui.buttonDeleteFromWanted = exports.rp_library:createButtonRounded("mdt:deletefromwanted",180 * scaleValue,385 * scaleValue,200 * scaleValue,30 * scaleValue,"Usuń z poszukiwanych",mdtGui.tab1,0.5 * scaleValue,10)
    mdtGui.sendWantedButton = exports.rp_library:createButtonRounded("mdt:sendWantedButton",180 * scaleValue,320 * scaleValue,200 * scaleValue,30 * scaleValue,"Zapisz do listy",mdtGui.tab5,0.5 * scaleValue,10)
    mdtGui.wantedVehicles = exports.rp_library:createGridList("mdt:wantedvehicles",5 * scaleValue,50 * scaleValue,580 * scaleValue,150 * scaleValue,mdtGui.tab2,nil,1 * scaleValue)
    mdtGui.buttonDeleteFromWantedVehicle = exports.rp_library:createButtonRounded("mdt:deletefromwantedvehicle",180 * scaleValue,385 * scaleValue,200 * scaleValue,30 * scaleValue,"Usuń z poszukiwanych",mdtGui.tab2,0.5 * scaleValue,10)

    mdtGui.gridPlayers = exports.rp_library:createGridList("mdt:gridplayers",5 * scaleValue,50 * scaleValue,580 * scaleValue,150 * scaleValue,mdtGui.tab4,nil,1 * scaleValue)
    mdtGui.gridPlayerLogs = exports.rp_library:createGridList("mdt:gridplayerslogs",5 * scaleValue,230 * scaleValue,580 * scaleValue,150 * scaleValue,mdtGui.tab4,nil,1 * scaleValue)

    local wantedColumn = DGS:dgsGridListAddColumn(mdtGui.gridListWantedPersons, "Lista", 1)
    local wantedLogs = DGS:dgsGridListAddColumn(mdtGui.gridListLogs, "Spis", 1)
    local wantedVehicles = DGS:dgsGridListAddColumn(mdtGui.wantedVehicles, "Lista", 1)
    local listPlayers = DGS:dgsGridListAddColumn(mdtGui.gridPlayers, "Lista", 1)
    DGS:dgsGridListSetColumnFont(mdtGui.gridListWantedPersons, wantedColumn, "default-bold")
    DGS:dgsGridListSetColumnFont(mdtGui.gridListLogs, wantedLogs, "default-bold")
    DGS:dgsGridListSetColumnFont(mdtGui.wantedVehicles, wantedVehicles, "default-bold")
    DGS:dgsGridListSetColumnFont(mdtGui.gridPlayers, listPlayers, "default-bold")

    local playerLogs = DGS:dgsGridListAddColumn(mdtGui.gridPlayerLogs, "Spis", 1)
    DGS:dgsGridListSetColumnFont(mdtGui.gridPlayerLogs, playerLogs, "default-bold")

    mdtGui.vehicleWantedLabel = exports.rp_library:createLabel("wantedReasonVehicle",180 * scaleValue,250 * scaleValue,180 * scaleValue,10 * scaleValue,"Powód poszukiwania: ",mdtGui.tab2,0.6 * scaleValue,"center","top",true,true,false)

    DGS:dgsSetProperty(mdtGui.tab1, "font", "default-bold")
    DGS:dgsSetProperty(mdtGui.tab2, "font", "default-bold")
    DGS:dgsSetProperty(mdtGui.tab3, "font", "default-bold")
    DGS:dgsSetProperty(mdtGui.tab4, "font", "default-bold")
    DGS:dgsSetProperty(mdtGui.tab5, "font", "default-bold")
    addEventHandler("onDgsMouseClickUp", mdtGui.sendWantedButton, sendWantedButton)
    addEventHandler("onDgsMouseClickUp", mdtGui.buttonDeleteFromWanted, onButtonDeleteFromWanted)
    addEventHandler("onDgsMouseClickUp", mdtGui.buttonDeleteFromWantedVehicle, onButtonDeleteFromWantedVehicle)

    mdtGui.editboxWantedName = exports.rp_library:createEditBox("mdt:editboxwantedname",180 * scaleValue,10 * scaleValue,200 * scaleValue,30 * scaleValue,"",mdtGui.tab5,0.5 * scaleValue,0.7 * scaleValue,35,false,"Dane",false,0)
    mdtGui.editboxWantedReason = exports.rp_library:createEditBox("mdt:editboxwantednamereason",180 * scaleValue,60 * scaleValue,200 * scaleValue,30 * scaleValue,"",mdtGui.tab5,0.5 * scaleValue,0.7 * scaleValue,50,false,"Powód",false,0)
    mdtGui.checkboxWanted = exports.rp_library:createCheckBox("checkbox:wantedstate",170 * scaleValue,400 * scaleValue,"Wystaw poszukiwany pojazd",mdtGui.tab5,0.5 * scaleValue)
    mdtGui.checkboxNotWanted = exports.rp_library:createCheckBox("checkbox:notwantedstate",170 * scaleValue,370 * scaleValue,"Czy ma to być tylko wpis bez poszukiwania?",mdtGui.tab5,0.5 * scaleValue)

    addEventHandler(
        "onDgsCheckBoxChange",
        mdtGui.checkboxWanted,
        function(state)
            if source == mdtGui.checkboxWanted then
                if state then -- zgloszenie samochodu
                    exports.rp_library:destroyEditBox("mdt:editboxwantedname")
                    exports.rp_library:destroyEditBox("mdt:editboxwantednamereason")
                    mdtGui.editboxWantedName = exports.rp_library:createEditBox("mdt:editboxwantedname",180 * scaleValue,10 * scaleValue,200 * scaleValue,30 * scaleValue,"",mdtGui.tab5,0.5 * scaleValue,0.7 * scaleValue,35,false,"Rejestracja samochodu",false,0)
                    mdtGui.editboxWantedNameMarka = exports.rp_library:createEditBox("mdt:editboxwantednamee",180 * scaleValue,60 * scaleValue,200 * scaleValue,30 * scaleValue,"",mdtGui.tab5,0.5 * scaleValue,0.7 * scaleValue,25,false,"Marka samochodu",false,0)
                    mdtGui.editboxWantedReason = exports.rp_library:createEditBox("mdt:editboxwantednamereason",180 * scaleValue,110 * scaleValue,200 * scaleValue,30 * scaleValue,"",mdtGui.tab5,0.5 * scaleValue,0.7 * scaleValue,50,false,"Powód",false,0)
                else
                    exports.rp_library:destroyEditBox("mdt:editboxwantedname")
                    exports.rp_library:destroyEditBox("mdt:editboxwantednamee")
                    exports.rp_library:destroyEditBox("mdt:editboxwantednamereason")

                    mdtGui.editboxWantedName = exports.rp_library:createEditBox("mdt:editboxwantedname",180 * scaleValue,10 * scaleValue,200 * scaleValue,30 * scaleValue,"",mdtGui.tab5,0.5 * scaleValue,0.7 * scaleValue,35,false,"Dane",false,0)
                    mdtGui.editboxWantedReason = exports.rp_library:createEditBox("mdt:editboxwantednamereason",180 * scaleValue,60 * scaleValue,200 * scaleValue,30 * scaleValue,"",mdtGui.tab5,0.5 * scaleValue,0.7 * scaleValue,50,false,"Powód",false,0)
                end
            end
        end
    )
    addEventHandler(
        "onDgsMouseClick",
        mdtGui.gridListWantedPersons,
        function()
            DGS:dgsGridListClear(mdtGui.gridListLogs)
            local selectedRow, selectedColumn = DGS:dgsGridListGetSelectedItem(mdtGui.gridListWantedPersons)
            if selectedRow ~= -1 then
                local data = DGS:dgsGridListGetItemData(mdtGui.gridListWantedPersons, selectedRow, selectedColumn)
                actualPlayer = data.fullName
            end
            if not actualPlayer then
                return
            end
            for k, v in pairs(mdtData[actualPlayer].logs) do
                local row = DGS:dgsGridListAddRow(mdtGui.gridListLogs)
                DGS:dgsGridListSetItemText(mdtGui.gridListLogs, row, 1, v, false, false)
                DGS:dgsGridListSetItemFont(mdtGui.gridListLogs, row, wantedLogs, "default-bold")
            end
        end
    )

    addEventHandler(
        "onDgsTextChange",
        mdtGui.editboxWantedPersons,
        function()
            local searchText = DGS:dgsGetText(source):lower()

            DGS:dgsGridListClear(mdtGui.gridListWantedPersons)

            for _, v in pairs(mdtData) do
                if string.find(v.fullName:lower(), searchText, 1, true) and v.wanted and v.type == "player" then
                    local row = DGS:dgsGridListAddRow(mdtGui.gridListWantedPersons)
                    DGS:dgsGridListSetItemText(mdtGui.gridListWantedPersons, row, 1, v.fullName, false, false)
                    DGS:dgsGridListSetItemFont(mdtGui.gridListWantedPersons, row, wantedColumn, "default-bold")
                    DGS:dgsGridListSetItemData(mdtGui.gridListWantedPersons, row, wantedColumn, v)
                end
            end
        end
    )

    addEventHandler(
        "onDgsTextChange",
        mdtGui.editboxWantedVehicles,
        function()
            local searchText = DGS:dgsGetText(source):lower()

            DGS:dgsGridListClear(mdtGui.wantedVehicles)

            for _, v in pairs(mdtData) do
                if string.find(v.fullName:lower(), searchText, 1, true) and v.wanted and v.type == "vehicle" then
                    local row = DGS:dgsGridListAddRow(mdtGui.wantedVehicles)
                    DGS:dgsGridListSetItemText(mdtGui.wantedVehicles, row, 1, v.fullName, false, false)
                    DGS:dgsGridListSetItemFont(mdtGui.wantedVehicles, row, wantedColumn, "default-bold")
                    DGS:dgsGridListSetItemData(mdtGui.wantedVehicles, row, wantedColumn, v)
                end
            end
        end
    )
    addEventHandler(
        "onDgsMouseClick",
        mdtGui.wantedVehicles,
        function()
            DGS:dgsGridListClear(mdtGui.gridListLogs)
            local selectedRow, selectedColumn = DGS:dgsGridListGetSelectedItem(mdtGui.wantedVehicles)
            if selectedRow ~= -1 then
                local data = DGS:dgsGridListGetItemData(mdtGui.wantedVehicles, selectedRow, selectedColumn)
                DGS:dgsSetText(mdtGui.vehicleWantedLabel, "Powód poszukiwania: " .. data.logs[1])
            end
        end
    )

    addEventHandler(
        "onDgsTextChange",
        mdtGui.editboxPlayers,
        function()
            local searchText = DGS:dgsGetText(source):lower()

            DGS:dgsGridListClear(mdtGui.gridPlayers)

            for _, v in pairs(mdtData) do
                if string.find(v.fullName:lower(), searchText, 1, true) and not v.wanted and v.type == "player" then
                    local row = DGS:dgsGridListAddRow(mdtGui.gridPlayers)
                    DGS:dgsGridListSetItemText(mdtGui.gridPlayers, row, 1, v.fullName, false, false)
                    DGS:dgsGridListSetItemFont(mdtGui.gridPlayers, row, listPlayers, "default-bold")
                    DGS:dgsGridListSetItemData(mdtGui.gridPlayers, row, listPlayers, v)
                end
            end
        end
    )
    addEventHandler(
        "onDgsMouseClick",
        mdtGui.gridPlayers,
        function()
            DGS:dgsGridListClear(mdtGui.gridPlayerLogs)
            local selectedRow, selectedColumn = DGS:dgsGridListGetSelectedItem(mdtGui.gridPlayers)
            if selectedRow ~= -1 then
                local data = DGS:dgsGridListGetItemData(mdtGui.gridPlayers, selectedRow, selectedColumn)
                actualPlayer = data.fullName
            end
            if not actualPlayer then
                return
            end
            for k, v in pairs(mdtData[actualPlayer].logs) do
                local row = DGS:dgsGridListAddRow(mdtGui.gridPlayerLogs)
                DGS:dgsGridListSetItemText(mdtGui.gridPlayerLogs, row, 1, v, false, false)
                DGS:dgsGridListSetItemFont(mdtGui.gridPlayerLogs, row, playerLogs, "default-bold")
            end
        end
    )

    addEventHandler("onDgsWindowClose", mdtGui.window, windowClosedMDT)

    showCursor(true)
end
addEvent("onPlayerOpenMDT", true)
addEventHandler("onPlayerOpenMDT", getRootElement(), openMDT)

function onButtonDeleteFromWanted(button)
    if source == mdtGui.buttonDeleteFromWanted and button == "left" then
        local selectedRow, selectedColumn = DGS:dgsGridListGetSelectedItem(mdtGui.gridListWantedPersons)
        if selectedRow ~= -1 then
            local data = DGS:dgsGridListGetItemData(mdtGui.gridListWantedPersons, selectedRow, selectedColumn)
            triggerServerEvent("onPlayerTryRemoveWantedPlayer", localPlayer, data.fullName)
            mdtData[data.fullName].wanted = false
            DGS:dgsGridListRemoveRow(mdtGui.gridListWantedPersons, selectedRow)
        end
    end
end

function sendWantedButton(button)
    if source == mdtGui.sendWantedButton and button == "left" then
        local state, wpis =
            exports.rp_library:getCheckBoxState("checkbox:wantedstate"),
            exports.rp_library:getCheckBoxState("checkbox:notwantedstate")
        if state and wpis then
            return exports.rp_library:createBox("Możesz wpis zrobić tylko dla graczy, odznacz checkbox.")
        end
        if state then
            triggerServerEvent(
                "onPlayerSendWanted",localPlayer,exports.rp_library:getEditBoxText("mdt:editboxwantedname"),exports.rp_library:getEditBoxText("mdt:editboxwantednamee"),exports.rp_library:getEditBoxText("mdt:editboxwantednamereason"))
        else
            if wpis then
                wpis = "log"
            end
            triggerServerEvent("onPlayerSendWanted",localPlayer,exports.rp_library:getEditBoxText("mdt:editboxwantedname"),exports.rp_library:getEditBoxText("mdt:editboxwantednamereason"),nil,wpis)
        end
    end
end

function onButtonDeleteFromWantedVehicle(button)
    if source == mdtGui.buttonDeleteFromWantedVehicle and button == "left" then
        local selectedRow, selectedColumn = DGS:dgsGridListGetSelectedItem(mdtGui.wantedVehicles)
        if selectedRow ~= -1 then
            local data = DGS:dgsGridListGetItemData(mdtGui.wantedVehicles, selectedRow, selectedColumn)
            triggerServerEvent("onPlayerTryRemoveWantedPlayer", localPlayer, data.fullName, "vehicle")
            DGS:dgsSetText(mdtGui.vehicleWantedLabel, "Powód poszukiwania: ")
            mdtData[data.fullName].wanted = false
            DGS:dgsGridListRemoveRow(mdtGui.wantedVehicles, selectedRow)
        end
    end
end


gui911.width, gui911.height = 400 * scaleValue, 250 * scaleValue
gui911.x, gui911.y = exports.rp_scale:getScreenStartPositionFromBox(gui911.width, gui911.height, 0, 0, "center", "center") 
local function windowClosed()
      showCursor(false)
	  gui911.showed = false
end


function onButtonAcceptReport(button)
    if source == gui911.acceptReport and button == "left" then
        if gui911.tempData then
            triggerServerEvent("onPlayerDo911", localPlayer, gui911.tempData, true)
            DGS:dgsGridListRemoveRow(gui911.reportList, gui911.lastSelectedRow)
			gui911.tempData = false
			gui911.lastSelectedRow = false
			DGS:dgsSetText(gui911.memo, "")
        end
    end
end

function onButtonDeclineReport(button)
    if source == gui911.declineReport and button == "left" then
			if gui911.tempData then
            triggerServerEvent("onPlayerDo911", localPlayer, gui911.tempData)
            DGS:dgsGridListRemoveRow(gui911.reportList, gui911.lastSelectedRow)
			gui911.tempData = false
			gui911.lastSelectedRow = false
			DGS:dgsSetText(gui911.memo, "")
        end
    end
end


local function onGridListSelected(current, currentcolumn, previous, previouscolumn)
		if source == gui911.reportList then
    local selectedRow, selectedColumn = DGS:dgsGridListGetSelectedItem(gui911.reportList)
    if selectedRow ~= -1 then
		local data = DGS:dgsGridListGetItemData(gui911.reportList, selectedRow, selectedColumn)
		DGS:dgsSetText(gui911.memo, data.text)
		gui911.tempData = data
		gui911.lastSelectedRow = selectedRow
    end
	end
end


local function open911(data, admin) -- po akceptacji zgloszenia z 911, usuwanie z tablicy, tworzenie blipa skad gracz zglosil, dane kto zglosil, checkbox z anonimem!
	if gui911.showed then return end
	gui911.showed = true
	data911 = data 
	if admin then
	gui911.window = exports.rp_library:createWindow("911Window",sx / 2 - 200 * scaleValue,sy / 2 - 70 ,600 * scaleValue,400 * scaleValue,"Lista zgłoszeń 911",5,0.55 * scaleValue, true)
	gui911.reportList = exports.rp_library:createGridList("911gridlist",5 * scaleValue,1 * scaleValue,150*scaleValue,350*scaleValue,gui911.window, nil, 1*scaleValue)
		DGS:dgsCenterElement(gui911.window)
	local reportListColumn = DGS:dgsGridListAddColumn(gui911.reportList, "Zgłoszenia", 1)
    DGS:dgsGridListSetColumnFont(gui911.reportList, reportListColumn, fontheader)
	gui911.memo = exports.rp_library:createMemoEditBox("911desc",200 * scaleValue,20 * scaleValue,360 * scaleValue,250 * scaleValue, "", gui911.window, 1.1*scaleValue, 0.5*scaleValue, 80, "Opis zgłoszenia", 5) 
	gui911.acceptReport = exports.rp_library:createButtonRounded("911:acceptreport",230*scaleValue,300*scaleValue,150*scaleValue,30*scaleValue,"Akceptuj",gui911.window,0.6*scaleValue,10)
	gui911.declineReport = exports.rp_library:createButtonRounded("911:declinereport",400*scaleValue,300*scaleValue,150*scaleValue,30*scaleValue,"Odrzuć",gui911.window,0.6*scaleValue,10)
	addEventHandler ( "onDgsGridListSelect",gui911.reportList,onGridListSelected )
	addEventHandler ( "onDgsMouseClickUp",gui911.acceptReport,onButtonAcceptReport )
	addEventHandler ( "onDgsMouseClickUp",gui911.declineReport,onButtonDeclineReport )
		DGS:dgsMemoSetReadOnly( gui911.memo, true )
for characterID, report in pairs(data911) do
    local row = DGS:dgsGridListAddRow(gui911.reportList)
    DGS:dgsGridListSetItemFont(gui911.reportList, row, reportListColumn, fontheader)
    DGS:dgsGridListSetItemText(gui911.reportList, row, reportListColumn, report.sender)
    DGS:dgsGridListSetItemData(gui911.reportList, row, reportListColumn, report)
end
	else
	gui911.window = exports.rp_library:createWindow("911Window", gui911.x, gui911.y, gui911.width, gui911.height, "Wyślij zgłoszenie na 911", 5, 0.55 * scaleValue, true)
	gui911.memo = exports.rp_library:createMemoEditBox("911desc", 20* scaleValue, 30 * scaleValue, 360 * scaleValue, 50 * scaleValue, "", gui911.window, 1.1*scaleValue, 0.5*scaleValue, 80, "Opis zgłoszenia", 5)
	gui911.checkbox = exports.rp_library:createCheckBox("911anonim", 300*scaleValue, 100*scaleValue, "Anonim", gui911.window, 0.5*scaleValue)
	gui911.checkboxLSPD = exports.rp_library:createCheckBox("lspd:checkbox", 230*scaleValue, 100*scaleValue, "LSPD", gui911.window, 0.5*scaleValue)
	gui911.checkboxEMS = exports.rp_library:createCheckBox("ems:checkbox", 160*scaleValue, 100*scaleValue, "LSFD", gui911.window, 0.5*scaleValue)

	gui911.sendButton = exports.rp_library:createButtonRounded("911window:send",100*scaleValue,160*scaleValue,200*scaleValue,30*scaleValue,"Wyślij zgłoszenie",gui911.window,0.6*scaleValue,10)
	addEventHandler("onDgsMouseClick", gui911.sendButton, send911)

	end
	
	addEventHandler("onDgsWindowClose",gui911.window,windowClosed)
	showCursor(true)
end



function send911(button, state)
	if source == gui911.sendButton and button == "left" and state == "up" then
	local anonim, lspd, ems = exports.rp_library:getCheckBoxState("911anonim"), exports.rp_library:getCheckBoxState("lspd:checkbox"), exports.rp_library:getCheckBoxState("ems:checkbox")
	local text = DGS:dgsGetText(gui911.memo)
	if string.len(text) < 4 or string.len(text) > 80 then return exports.rp_library:createBox("Zgłoszenie musi mieć więcej niż 4 znaki.") end
	local data = {lspd=lspd, lsfd=ems}
		triggerServerEvent("onPlayerSend911Report", localPlayer, text, anonim, data)
	end
	
end

addEvent("onPlayerOpen911", true)
addEventHandler("onPlayerOpen911", getRootElement(), open911)
local currentroadBlockID = false
local roadblockShowed = false
local roadblockTempModel = false
local roadBlocksModels = {[1] = {1459, "barierka 2"}, [2] = {1427, "barierka 3"}, [3] = {1237, "barierka 4"}, [4] = {2899, "kolczatka"}}
local roadblockOffsets = {[1] = -0.4, [2] = -0.4, [3] = -1, [4] = -0.8}
local function openRoadBlockGui()
	roadblockShowed = not roadblockShowed
	if roadblockShowed then
		addEventHandler("onClientRender", root, renderRoadBlockGui)
		currentroadBlockID = 1
		-- bind key st rzalki
		bindKey( "arrow_l", "up", onLeftArrow ) 
		bindKey( "arrow_r", "up", onRightArrow ) 
		bindKey( "backspace", "up", onBackSpaceKey ) 
		addEventHandler("onClientVehicleStartEnter", root, onClientVehicleEnterWhileRoadBlock)
	setTimer ( function()
		bindKey( "enter", "up", onEnterKey)
	end, 500, 1 )		
		roadblockTempModel = createObject(1459, 0, 0, 0)
		setElementCollisionsEnabled(roadblockTempModel, false)
		setElementAlpha(roadblockTempModel, 170)
		setElementDimension(roadblockTempModel, getElementDimension(localPlayer))
		setElementInterior(roadblockTempModel, getElementInterior(localPlayer))
		local offset = roadblockOffsets[currentroadBlockID] or 0
        attachElements ( roadblockTempModel, localPlayer, 0, 1, offset )
	else
		removeEventHandler("onClientRender", root, renderRoadBlockGui)
		unbindKey( "arrow_l", "up", onLeftArrow ) 
		unbindKey( "arrow_r", "up", onRightArrow )
		unbindKey( "enter", "up", onEnterKey)
		unbindKey( "backspace", "up", onBackSpaceKey ) 
		removeEventHandler("onClientVehicleStartEnter", root, onClientVehicleEnterWhileRoadBlock)
		destroyElement(roadblockTempModel)
	end
end
addEvent("onPlayerOpenRoadBlockGui", true)
addEventHandler("onPlayerOpenRoadBlockGui", getRootElement(), openRoadBlockGui)

function onLeftArrow(key, keyState)
	if currentroadBlockID == 4 then return end
	currentroadBlockID = currentroadBlockID + 1
	setElementModel(roadblockTempModel, roadBlocksModels[currentroadBlockID][1])
	local offset = roadblockOffsets[currentroadBlockID] or 0
	setElementAttachedOffsets (roadblockTempModel,0,1,offset,0, 0, 0)

end

function onRightArrow(key, keyState)
	if currentroadBlockID == 1 then return end
	currentroadBlockID = currentroadBlockID - 1
	setElementModel(roadblockTempModel, roadBlocksModels[currentroadBlockID][1])
	local offset = roadblockOffsets[currentroadBlockID] or 0
	setElementAttachedOffsets (roadblockTempModel,0,1,offset,0, 0, 0)
end

function onBackSpaceKey(key, keyState)
	triggerServerEvent("onPlayerRemoveRoadBlock", localPlayer)
end

function onEnterKey(key, keyState)
    local objX, objY, objZ = getElementPosition(roadblockTempModel)
    local rotX, rotY, rotZ = getElementRotation(roadblockTempModel)
    triggerServerEvent("onPlayerCreateRoadBlock", localPlayer, roadBlocksModels[currentroadBlockID][1], objX, objY, objZ, rotX, rotY, rotZ)
end

function renderRoadBlockGui()
    dxDrawText("Zmieniaj model klikając strzałki <- ->, aktualnie: "..roadBlocksModels[currentroadBlockID][2], sx/2, sy/2+450, sx/2, sy/2+450,tocolor(255, 255, 255, 255),1,font,"center","top")
end



function onClientVehicleEnterWhileRoadBlock(player, seat, door)
	if player == localPlayer and roadblockShowed then
		cancelEvent()
	end
end

-- alpr
function vehicleElementName(vehicle)
	local vehicleData = exports.rp_newmodels:getElementModel(vehicle)
	local vehicleName = exports.rp_newmodels:getCustomModelName(vehicleData) or getVehicleNameFromModel(vehicleData)
	return vehicleName
end
local alpr = {}
local pdVehicles = { [598]=true, [596]=true, [597]=true, [599]=true }
local seats = {[0]=true, [1]=true}
alpr.gui = dxCreateTexture("files/gui.png", "argb", true, "clamp", "2d")
alpr.model = "Brak"
alpr.speed = 0
alpr.speedmax = 0
alpr.plate = "Brak"
alpr.owner = "Brak"
alpr.drawX, alpr.drawY = 291 * scaleValue, 400 * scaleValue
alpr.startX, alpr.startY = exports.rp_scale:getScreenStartPositionFromBox(alpr.drawX, alpr.drawY,offSetX, 0, "right", "center")
alpr.showedGui = falses
alpr.font = dxCreateFont("files/Helvetica.ttf", 18 * scaleValue, false, "proof")

function alpr.Enable()
    if not alpr.showedGui then
	    addEventHandler("onClientRender", root, alpr.render)
	else
		removeEventHandler("onClientRender", root, alpr.render)

	end
   alpr.showedGui = not alpr.showedGui
end
bindKey( "\\", "up", alpr.Enable )

function vehicleElementName(vehicle)
	local vehicleData = exports.rp_newmodels:getElementModel(vehicle)
	local vehicleName = exports.rp_newmodels:getCustomModelName(vehicleData) or getVehicleNameFromModel(vehicleData)
	return vehicleName
end
function alpr.render()
   local veh = getPedOccupiedVehicle(localPlayer)
   if veh and getVehicleEngineState(veh) then
      if alpr.showedGui and ((not exports.rp_login:getObjectData(veh,"customPD")) and seats[getPedOccupiedVehicleSeat(localPlayer)] and pdVehicles[getElementModel(veh)] or exports.rp_login:getObjectData(veh,"customPD")) then
         local matrix = veh:getMatrix()

         local newMatrix = matrix:transformPosition(Vector3(0, 20, 0))
         local hit, hitX, hitY, hitZ, hitElement = processLineOfSight(matrix:getPosition(),newMatrix, true,true,false,true,true,false,false,false,veh,false,true)
         -- dxDrawLine3D(matrix:getPosition(), newMatrix, tocolor(255, 255, 255, 255))
         if hit then
            if isElement(hitElement) and hitElement:getType() == "vehicle" then
               if veh ~= hitElement then
                  local speed = getElementSpeed(hitElement, "km/h")
                  if speed then
                     alpr.speedmax = speed
                     alpr.speed = speed
                  end
                  local modelName = vehicleElementName(hitElement)
                  if modelName then
                     alpr.model = modelName
                  else
                     alpr.model = "Brak"
                  end
                  local plate = getVehiclePlateText(hitElement)
                  if plate then
                     alpr.plate = plate
                  else
                     alpr.plate = "Brak"
                  end
                  local vehicleOwner = exports.rp_login:getObjectData(veh, "ownerName") --getElementData(veh,"vehOwnerName") -- funkcja do zrobienia.
                  if vehicleOwner then
                     alpr.owner = vehicleOwner
                  else
                     alpr.owner = "Brak"
                  end
               end
            end
         else
            alpr.speed = 0
         end
         dxDrawImage(alpr.startX,alpr.startY,alpr.drawX,alpr.drawY,alpr.gui,0,0,0,tocolor(255, 255, 255, 255),false)
         dxDrawText("ALPR:", alpr.startX + 17*scaleValue, alpr.startY + 10 *scaleValue, 100 * scaleValue, 100 *scaleValue,tocolor(255, 255, 255, 255),1,alpr.font,"left","top")
         dxDrawText("Model: "..alpr.model, alpr.startX + 20 *scaleValue, alpr.startY + 85 *scaleValue, 100 * scaleValue, 100 *scaleValue,tocolor(255, 255, 255, 255),1,alpr.font,"left","top")
         -- dxDrawText("Właściciel:", alpr.startX + 20 *scaleValue, alpr.startY + 120 *scaleValue, 100 * scaleValue, 100 *scaleValue,tocolor(255, 255, 255, 255),1,alpr.font,"left","top") --35
         -- dxDrawText(alpr.owner, alpr.startX + 140 *scaleValue, alpr.startY + 126 *scaleValue, 100 * scaleValue, 100 *scaleValue,tocolor(255, 255, 255, 255),1,alpr.font,"left","top") --35
         dxDrawText("Rejestracja: "..alpr.plate, alpr.startX + 20 *scaleValue, alpr.startY + 155 *scaleValue, 100 * scaleValue, 100 *scaleValue,tocolor(255, 255, 255, 255),1,alpr.font,"left","top")
         dxDrawText("LIDAR: ", alpr.startX + 15 *scaleValue, alpr.startY + 230 *scaleValue, 100 * scaleValue, 100 *scaleValue,tocolor(255, 255, 255, 255),1,alpr.font,"left","top")
         dxDrawText("Prędkość: "..math.floor(alpr.speed), alpr.startX + 20 *scaleValue, alpr.startY + 305 *scaleValue, 100 * scaleValue, 100 *scaleValue,tocolor(255, 255, 255, 255),1,alpr.font,"left","top")
         dxDrawText("Prędkość max: "..math.floor(alpr.speedmax), alpr.startX + 20 *scaleValue, alpr.startY + 340 *scaleValue, 100 * scaleValue, 100 *scaleValue,tocolor(255, 255, 255, 255),1,alpr.font,"left","top")

      end
   end
end

function getElementSpeed(theElement, unit)
    -- Check arguments for errors
    assert(isElement(theElement), "Bad argument 1 @ getElementSpeed (element expected, got " .. type(theElement) .. ")")
    local elementType = getElementType(theElement)
    assert(elementType == "player" or elementType == "ped" or elementType == "object" or elementType == "vehicle" or elementType == "projectile", "Invalid element type @ getElementSpeed (player/ped/object/vehicle/projectile expected, got " .. elementType .. ")")
    assert((unit == nil or type(unit) == "string" or type(unit) == "number") and (unit == nil or (tonumber(unit) and (tonumber(unit) == 0 or tonumber(unit) == 1 or tonumber(unit) == 2)) or unit == "m/s" or unit == "km/h" or unit == "mph"), "Bad argument 2 @ getElementSpeed (invalid speed unit)")
    -- Default to m/s if no unit specified and 'ignore' argument type if the string contains a number
    unit = unit == nil and 0 or ((not tonumber(unit)) and unit or tonumber(unit))
    -- Setup our multiplier to convert the velocity to the specified unit
    local mult = (unit == 0 or unit == "m/s") and 50 or ((unit == 1 or unit == "km/h") and 180 or 111.84681456)
    -- Return the speed by calculating the length of the velocity vector, after converting the velocity to the specified unit
    return (Vector3(getElementVelocity(theElement)) * mult).length
end

-- syreny

--StreamIn, jezeli gracz ma dzwiek to odpalamy.
local pdSoundsVehicles = {}
local pdHeadLightsVehicles = {}
local pdHeadLightsTimers = {}

function onVehiclePDSoundUpdate(element, data, nowData)
	if not isElement(element) then return end
    if not getElementType(element) ~= "vehicle"  and not isElementStreamedIn(element) then
        return
    end
    if data == "PDSound" then
        if nowData == false and pdSoundsVehicles[element] then
            destroyElement(pdSoundsVehicles[element])
            pdSoundsVehicles[element] = nil
            return
        end
        if not nowData then
            return
        end
        local x, y, z = getElementPosition(element)
        local sound = playSound3D("files/" .. nowData .. ".ogg", x, y, z, true)
        setElementDimension(sound, getElementDimension(element))
        setElementInterior(sound, getElementInterior(element))
        attachElements(sound, element, 0, 0, 2)
        pdSoundsVehicles[element] = sound
		setSoundMaxDistance(sound, 200)
		setSoundVolume(sound, 0.5)
	elseif data == "headlight" and nowData ~= false then
	    setHeadLightTypeVehicle(element, 1)

    end
end

addEventHandler("onLocalDataSingleElementUpdate", root, onVehiclePDSoundUpdate)

function setHeadLightTypeVehicle(vehicle, type)
	-- if pdHeadLightsTimers[vehicle] then  killTimer(pdHeadLightsTimers[vehicle]) pdHeadLightsVehicles[vehicle] = nil setVehicleHeadLightColor(vehicle, 255, 0, 0) return end
	pdHeadLightsVehicles[vehicle] = type
	pdHeadLightsTimers[vehicle] = setTimer ( setVehicleHeadLightTimer, 150, 0, vehicle, type)
end


function setVehicleHeadLightTimer(vehicle)
    local data = exports.rp_login:getObjectData(vehicle, "headlight")
		if not getVehicleSirensOn(vehicle) then
			setVehicleSirensOn(vehicle, true)
		end
    if data == false then
        if pdHeadLightsTimers[vehicle] then  
            killTimer(pdHeadLightsTimers[vehicle])
            pdHeadLightsVehicles[vehicle] = nil 
			setVehicleSirensOn(vehicle, false)
        end
        setVehicleLightState(vehicle, 0, 0)
        setVehicleLightState(vehicle, 1, 0)
        setVehicleLightState(vehicle, 2, 0)
        setVehicleLightState(vehicle, 3, 0)
        setVehicleHeadLightColor(vehicle, 255, 255, 255)
        return
    end

    if data == 1 then
        setVehicleLightState(vehicle, 0, 0)
        setVehicleLightState(vehicle, 1, 1) 
        setVehicleHeadLightColor(vehicle, 255, 0, 0)
        exports.rp_login:setObjectData(vehicle, "headlight", 2)
    elseif data == 2 then
        setVehicleLightState(vehicle, 0, 1)
        setVehicleLightState(vehicle, 1, 0) 
        setVehicleHeadLightColor(vehicle, 66, 134, 244)
        exports.rp_login:setObjectData(vehicle, "headlight", 1)
    end
end
local function toggleSirenBinding(state)
    if state then
        bindKey("1", "down", enableSirenSound)
        bindKey("2", "down", enableSirenSound)
		bindKey("3", "down", enableSirenSound)
		bindKey("4", "down", enableSirenSound)
		bindKey("m", "up", enableHeadLights)
    else
        unbindKey("1", "down", enableSirenSound)
        unbindKey("2", "down", enableSirenSound)
		unbindKey("3", "down", enableSirenSound)
		unbindKey("4", "down", enableSirenSound)
		unbindKey("m", "up", enableHeadLights)
    end
end

function enableHeadLights(key)
	triggerServerEvent("onPlayerChangeSirenSound", localPlayer, false, true)
end
local function onClientVehicleChange(player, seat, state)
    if player == localPlayer then
        toggleSirenBinding(state)
    end
end
addEventHandler("onClientVehicleEnter", root, function(player, seat)
    onClientVehicleChange(player, seat, true)
end)
addEventHandler("onClientVehicleExit", root, function(player, seat)
    onClientVehicleChange(player, seat, false)
end)

function enableSirenSound(key)
    if getKeyState("lshift") then
        triggerServerEvent("onPlayerChangeSirenSound", localPlayer, tonumber(key))
    end
end


local function onClientElementStreamIn()
    if getElementType(source) == "vehicle" then
		local source = source
        setTimer(function()
            local data = exports.rp_login:getObjectData(source, "PDSound")
			if not data then return end
			if pdSoundsVehicles[source] then return end
            local x, y, z = getElementPosition(source)
			local sound = playSound3D("files/" .. data .. ".ogg", x, y, z, true)
			setElementDimension(sound, getElementDimension(source))
			setElementInterior(sound, getElementInterior(source))
			attachElements(sound, source, 0, 0, 2)
			pdSoundsVehicles[source] = sound
			setSoundMaxDistance(sound, 200)
			setSoundVolume(sound, 0.5)
        end, 1000, 1)
		
		 setTimer(function()
            local data = exports.rp_login:getObjectData(source, "headlight")
			if not data then return end
			if pdHeadLightsTimers[source] or pdHeadLightsVehicles[source] then return end
			setHeadLightTypeVehicle(source, 1)
        end, 1000, 1)
    end
end
addEventHandler("onClientElementStreamIn", root, onClientElementStreamIn)

local function onClientElementStreamOut()
	if getElementType(source) == "vehicle" then
		if pdSoundsVehicles[source] then destroyElement(pdSoundsVehicles[source]) pdSoundsVehicles[source] = nil end
		if pdHeadLightsTimers[source] then 
			if isTimer(pdHeadLightsTimers[source]) then killTimer(pdHeadLightsTimers[source]) end
			pdHeadLightsTimers[source] = nil
			setVehicleHeadLightColor(source, 255, 255, 255)
			pdHeadLightsVehicles[source] = nil
		end
	end
end
addEventHandler("onClientElementStreamOut", root, onClientElementStreamOut)

function onClientElementDestroy()
	if getElementType(source) == "vehicle" then
		if pdSoundsVehicles[source] then destroyElement(pdSoundsVehicles[source]) pdSoundsVehicles[source] = nil end
		if pdHeadLightsTimers[source] then  if isTimer(pdHeadLightsTimers[source]) then killTimer(pdHeadLightsTimers[source]) end pdHeadLightsVehicles[source] = nil end
	end
end
addEventHandler("onClientElementDestroy", root, onClientElementDestroy)


-- Group:17 index 10,11.
-- setWorldSoundEnabled
setWorldSoundEnabled(17, 10, false, true)
setWorldSoundEnabled(17, 11, false, true)

-- blipy pojazdow



-- taser
function gotTased(x, y, z, dim, interior)
	local sound = playSound3D("files/Fire.wav", x, y, z, false) 
	setElementDimension(sound, dim)
	setElementInterior(sound, interior)
	for i = 1, 5, 1 do
		fxAddPunchImpact(x, y, z, 0, 0, 0)
		fxAddSparks(x, y, z, 0, 0, 0, 8, 1, 0, 0, 0, true, 3, 1)
	end
end

addEvent("onClientPlayerGotTased", true)
addEventHandler("onClientPlayerGotTased", root, gotTased)
--todo widok komend dla administracji, spis komend.
local sx,sy = guiGetScreenSize()
local scaleValue = exports.rp_scale:returnScaleValue()
DGS = exports.dgs

local permsNames = {
	["vehicleCreate"] = "Tworzenie pojazdów",
	["vehicleSpawn"] = "Spawnowanie pojazdów",
	["vehicleBring"] = "Teleportowanie pojazdów do siebie",
	["bw"] = "Permisje do BW",
	["spec"] = "Spectowanie graczy",
	["ban"] = "Banowanie graczy",
	["kick"] = "Wyrzucanie graczy",
	["charBlock"] = "Blokowanie postaci",
	["unban"] = "Odbanowywanie graczy",
	["fly"] = "Korzystanie z /fly",
	["ninja"] = "Korzystanie z /ninja",
	["creatingItems"] = "Możliwość tworzenie przedmiotów do ekwipunku",
	["vehicleFix"] = "Naprawa pojazdów",
	["tpToPlayer"] = "Teleportowanie do graczy",
	["cash"] = "Nadawanie gotówki",
	["displayName"] = "Zmiana danych postaci",
	["fightstyles"] = "Dodawanie/usuwanie stylow walki gracza",
	["creatingAtms"] = "Stawianie bankomatów",
	["creatingInteriors"] = "Stawianie interiorów",
	["tpInteriors"] = "Teleportowanie do interiorów",
	["openInteriors"] = "Dostęp do otwierania/zamykania interiorów",
	["creatingGroups"] = "Dostęp do tworzenia/edytowania grup",
	["globalChats"] = "Globalne wiadomośći, /globooc, /globme /globdo",
	["deleteItems"] = "Dostęp do usuwania przedmiotów",
	["createShops"] = "Dostęp do tworzenia sklepów",
	["creatingCorners"] = "Dostęp do tworzenia cornerów",
	["searchPlayer"] = "Dostęp do przeszukiwania graczy",
	["resetpassword"] = "Resetowanie haseł graczy",

}
adminPerms = {
    perms = {},
	level = {},
}
local playerElement = nil
function createPermsWindow(player, perms, playerName, adminlevel)
	if isElement(adminPerms.window) then destroyElement(adminPerms.window) removeEventHandler("onClientGUIClick", root, clickAdmin) end
	playerElement = player
	showCursor(true)
	adminPerms.window = guiCreateWindow(490, 188, 300, 346, "Ustawianie uprawnień administratorskich", false)
	guiWindowSetSizable(adminPerms.window, false)

	adminPerms.levelLabel = guiCreateLabel(10, 72, 50, 20, "Poziom:", false, adminPerms.window)
	guiSetFont(adminPerms.levelLabel, "default-bold-small")
	adminPerms.nameLabel = guiCreateLabel(10, 30, 200, 20, string.format("Gracz:      %s", playerName), false, adminPerms.window)
	guiSetFont(adminPerms.nameLabel, "default-bold-small")
	adminPerms.closeButton = guiCreateButton(270, 30, 20, 22, "X", false, adminPerms.window)
	adminPerms.acceptButton = guiCreateButton(270, 56, 20, 22, "V", false, adminPerms.window)
	guiSetProperty(adminPerms.closeButton, "NormalTextColour", "FFAAAAAA")
	guiSetProperty(adminPerms.acceptButton, "NormalTextColour", "FFAAAAAA")
	adminPerms.scroll = guiCreateScrollPane(10, 105, 280, 230, false, adminPerms.window)
	adminPerms.levelCombo = guiCreateComboBox(60, 72, 200, 90, "", false, adminPerms.window)
	adminPerms.level[0] = guiComboBoxAddItem(adminPerms.levelCombo, "0") -- gracz
	adminPerms.level[1] = guiComboBoxAddItem(adminPerms.levelCombo, "1") -- suppek
	adminPerms.level[2] = guiComboBoxAddItem(adminPerms.levelCombo, "2") -- cm
	adminPerms.level[3] = guiComboBoxAddItem(adminPerms.levelCombo, "3") -- admin
	adminPerms.y = 6
	addEventHandler ( "onClientGUIClick", adminPerms.acceptButton, clickAdmin )
	addEventHandler ( "onClientGUIClick",  adminPerms.closeButton, clickExit )

	guiComboBoxSetSelected(adminPerms.levelCombo, adminPerms.level[adminlevel])
	for k,v in pairs(permsNames) do
		adminPerms.perms[k] = guiCreateCheckBox(4, adminPerms.y, 266, 22, v, perms[k] and true or false, false, adminPerms.scroll)
		guiSetFont(adminPerms.perms[k], "default-bold-small")
		adminPerms.y = adminPerms.y + 20
	end
end

addEvent("onOpenAdminRights", true)
addEventHandler("onOpenAdminRights", root, createPermsWindow)


function clickAdmin(button, state)
    if source == adminPerms.acceptButton and button == "left" and state == "up" then
        local permTable = {}
        for k, v in pairs(adminPerms.perms) do
            if guiCheckBoxGetSelected(adminPerms.perms[k]) then
                permTable[k] = true
            end
        end
		
        showCursor(false)
        local item = guiComboBoxGetSelected(adminPerms.levelCombo)
        local adminlevel = guiComboBoxGetItemText(adminPerms.levelCombo, item)
        triggerServerEvent("onPlayerGotAdmin", localPlayer, playerElement, permTable, tonumber(adminlevel))
        removeEventHandler("onClientGUIClick", adminPerms.closeButton, clickExit)
        removeEventHandler("onClientGUIClick", adminPerms.acceptButton, clickAdmin)
        destroyElement(adminPerms.window)
        playerElement = nil
    end
end


function clickExit(button, state)
    if source == adminPerms.closeButton and button == "left" and state == "up" then
        destroyElement(adminPerms.window)
        showCursor(false)
        playerElement = nil
    end
end


local adminListData = {}
local function windowClosedList()
    if isElement(adminListData.window) then
		adminListData = {}
		adminListData.showed = false
        showCursor(false)
    end
end
function adminList(data)
	if adminListData.showed then return end
    adminListData = data
    adminListData.window = exports.rp_library:createWindow("adminList",sx / 2 - 200 * scaleValue,sy / 2 - 250 * scaleValue,400 * scaleValue,500 * scaleValue,"Lista administracji",5,0.55 * scaleValue, true)
    adminListData.gridlist = exports.rp_library:createGridList("adminGridlist",5 * scaleValue,1 * scaleValue,390*scaleValue,400*scaleValue,adminListData.window, nil, 1*scaleValue) -- createGridList(id, x, y, width, height, parent, columnHeight, scale)
    local adminName = DGS:dgsGridListAddColumn(adminListData.gridlist, "Nazwa", 0.2)
	local adminRank = DGS:dgsGridListAddColumn(adminListData.gridlist, "Ranga", 0.35)
	local adminID = DGS:dgsGridListAddColumn(adminListData.gridlist, "ID", 0.3)
    DGS:dgsGridListSetColumnFont(adminListData.gridlist, adminName, "default-bold")
    DGS:dgsGridListSetColumnFont(adminListData.gridlist, adminRank, "default-bold")
    DGS:dgsGridListSetColumnFont(adminListData.gridlist, adminID, "default-bold")
	addEventHandler("onDgsWindowClose",adminListData.window,windowClosedList)
	adminListData.showed = true
	table.sort(adminListData, function(a, b)
		return a[4] > b[4]
    end)

    for k, v in ipairs(adminListData) do
        local row = DGS:dgsGridListAddRow(adminListData.gridlist)
		DGS:dgsGridListSetItemFont ( adminListData.gridlist, row, adminName, "default-bold" )
		DGS:dgsGridListSetItemFont ( adminListData.gridlist, row, adminRank, "default-bold" )
		DGS:dgsGridListSetItemFont ( adminListData.gridlist, row, adminID, "default-bold" )
		DGS:dgsGridListSetItemText ( adminListData.gridlist, row, adminName, v[1] )
		DGS:dgsGridListSetItemText ( adminListData.gridlist, row, adminRank, v[2] )
		DGS:dgsGridListSetItemText ( adminListData.gridlist, row, adminID, v[3] )

	end

	showCursor(true)
end
addEvent("onPlayerShowAdmins", true)
addEventHandler("onPlayerShowAdmins", root, adminList)
local reportGui = {}
local reportAdminGui = {}
local function reportWindowClosed()
 if isElement(reportGui.window) then
		reportGui = {}
		reportGui.showed = false
        showCursor(false)
    end
end
function onPlayerShowReportGui()
	if reportGui.showed then return end
	reportGui.window = exports.rp_library:createWindow("reportGui",sx / 2 - 200 * scaleValue,sy / 2 - 70 ,400 * scaleValue,200 * scaleValue,"System raportów - zgłoś problem",5,0.55 * scaleValue, true)
	reportGui.rectangleforMemo = DGS:dgsCreateRoundRect(5, false, tocolor(42, 49, 71, 255))
	reportGui.memo =  exports.rp_library:createMemoEditBox("reportsMemo",20 * scaleValue,70 * scaleValue,360 * scaleValue,50 * scaleValue, "", reportGui.window, 1.1*scaleValue, 0.5*scaleValue, 60, "Opis zgłoszenia", 5) --DGS:dgsCreateMemo(20 * scaleValue,70 * scaleValue,360 * scaleValue,50 * scaleValue,"",false,reportGui.window)
	reportGui.category = exports.rp_library:createComboBox("report:combobox", 20*scaleValue, 25*scaleValue, 120*scaleValue, 20*scaleValue, "", reportGui.window, nil, 0.4*scaleValue)--DGS:dgsCreateComboBox(20* scaleValue, 25* scaleValue, 120 * scaleValue, 20 * scaleValue, "", false, reportGui.window)
	DGS:dgsComboBoxAddItem(reportGui.category, "Zgłoszenie gracza") 
	DGS:dgsComboBoxAddItem(reportGui.category, "Błąd") 
	reportGui.label = exports.rp_library:createLabel("reportLabel", 20 * scaleValue,3 * scaleValue,30 * scaleValue,50 * scaleValue, "Witaj w panelu reportów, wypełnij treść raportu i kategorię.", reportGui.window, 0.45*scaleValue, "left", "top", false, true, false)--DGS:dgsCreateLabel(20 * scaleValue,5 * scaleValue,30 * scaleValue,50 * scaleValue,"Witaj w panelu reportów, wypełnij treść raportu i kategorię.",false,reportGui.window)
	reportGui.sendReport = exports.rp_library:createButtonRounded("report:sendreport",90*scaleValue,130*scaleValue,200*scaleValue,30*scaleValue,"Wyślij",reportGui.window,0.6*scaleValue,10)
	addEventHandler("onDgsWindowClose",reportGui.window,reportWindowClosed)
	addEventHandler ( "onDgsMouseClickUp",reportGui.sendReport,onButtonSendReport )
	DGS:dgsComboBoxSetSelectedItem ( reportGui.category, 1)
	reportGui.reportID = exports.rp_library:createEditBox("reportGui:target", 150*scaleValue,20*scaleValue,100*scaleValue,30*scaleValue, "", reportGui.window, 0.5*scaleValue, 0.5*scaleValue, 3, false, "ID gracza", _, 5) --(id, x, y, w, h, text, parent, caretHeight, textSize, maxLength, masked, placeHolder, padding, corners)
	reportGui.showed = true
	showCursor(true)

end
addEvent("onPlayerShowReportGui", true)
addEventHandler("onPlayerShowReportGui", root, onPlayerShowReportGui)
local reportsData = {}

local function reportAdminGuiWindowClosed()
 if isElement(reportAdminGui.window) then
		reportsData = {}
		reportAdminGui = {} 
		reportAdminGui.showed = false
        showCursor(false)
    end
end
function onPlayerShowReportAdminGui(table)
	if reportAdminGui.showed then return end
	reportsData = table
	reportAdminGui.window = exports.rp_library:createWindow("reportadminGui",sx / 2 - 200 * scaleValue,sy / 2 - 70 ,600 * scaleValue,400 * scaleValue,"Lista raportów",5,0.55 * scaleValue, true)
	reportAdminGui.reportList = exports.rp_library:createGridList("reportListGridList",5 * scaleValue,1 * scaleValue,150*scaleValue,350*scaleValue,reportAdminGui.window, nil, 1*scaleValue)
	DGS:dgsCenterElement(reportAdminGui.window)
	addEventHandler("onDgsWindowClose",reportAdminGui.window,reportAdminGuiWindowClosed)
    local reportListColumn = DGS:dgsGridListAddColumn(reportAdminGui.reportList, "Reporty graczy", 1)
    DGS:dgsGridListSetColumnFont(reportAdminGui.reportList, reportListColumn, "default-bold")
	reportAdminGui.rectangleforMemo = DGS:dgsCreateRoundRect(5, false, tocolor(42, 49, 71, 255))
	reportAdminGui.memo = DGS:dgsCreateMemo(200 * scaleValue,20 * scaleValue,360 * scaleValue,250 * scaleValue,"",false,reportAdminGui.window)
	DGS:dgsSetProperty(reportAdminGui.memo,"font","default-bold")
	DGS:dgsSetProperty(reportAdminGui.memo,"bgImage",reportAdminGui.rectangleforMemo)
    DGS:dgsSetProperty(reportAdminGui.memo, "caretOffset", 1)
    DGS:dgsSetProperty(reportAdminGui.memo, "wordWrap", 1)
	DGS:dgsMemoSetReadOnly( reportAdminGui.memo, true )
	reportAdminGui.acceptReport = exports.rp_library:createButtonRounded("report:acceptreport",230*scaleValue,300*scaleValue,150*scaleValue,30*scaleValue,"Akceptuj",reportAdminGui.window,0.6*scaleValue,10)
	reportAdminGui.declineReport = exports.rp_library:createButtonRounded("report:declinereport",400*scaleValue,300*scaleValue,150*scaleValue,30*scaleValue,"Odrzuć",reportAdminGui.window,0.6*scaleValue,10)
	addEventHandler ( "onDgsGridListSelect",reportAdminGui.reportList,onGridListSelected )
	addEventHandler ( "onDgsMouseClickUp",reportAdminGui.acceptReport,onButtonAcceptReport )
	addEventHandler ( "onDgsMouseClickUp",reportAdminGui.declineReport,onButtonDeclineReport )
	reportAdminGui.label = DGS:dgsCreateLabel(200*scaleValue, 1*scaleValue, 30*scaleValue, 30*scaleValue,"",false,reportAdminGui.window)
	DGS:dgsSetFont(reportAdminGui.label, "default-bold")
	for k, v in ipairs(reportsData) do
        local row = DGS:dgsGridListAddRow(reportAdminGui.reportList)
		DGS:dgsGridListSetItemFont ( reportAdminGui.reportList, row, reportListColumn, "default-bold" )
		DGS:dgsGridListSetItemText ( reportAdminGui.reportList, row, reportListColumn, v.reportTitle )
		DGS:dgsGridListSetItemData(reportAdminGui.reportList, row, reportListColumn, v)


		end
	reportAdminGui.showed = true
	showCursor(true)
end
addEvent("onPlayerShowReportAdminGui", true)
addEventHandler("onPlayerShowReportAdminGui", root, onPlayerShowReportAdminGui)

function onButtonSendReport()
    if source == reportGui.sendReport then
        local item = DGS:dgsComboBoxGetSelectedItem(reportGui.category)
        local category = DGS:dgsComboBoxGetItemText(reportGui.category, item)
        local reportText = DGS:dgsGetText(reportGui.memo)
        if string.len(reportText) <= 5 then
            return exports.rp_library:createBox("Report jest za krótki aby go wysłać.")
        end
			local text = false
		if category == "Zgłoszenie gracza" then
			text = exports.rp_library:getEditBoxText("reportGui:target")
			text = tonumber(text)
			if not text then return exports.rp_library:createBox("Musisz podać ID gracza, którego chcesz zgłosić.") end
			if string.len(text) < 0 then return exports.rp_library:createBox("Podaj ID gracza.") end
		end
        triggerServerEvent("onPlayerSubmitReport", localPlayer, reportText, category, text)
    end
end
function onButtonAcceptReport()
    if source == reportAdminGui.acceptReport then
        if reportAdminGui.tempData then
            triggerServerEvent("onPlayerAcceptReport", localPlayer, reportAdminGui.tempData)
            DGS:dgsGridListRemoveRow(reportAdminGui.reportList, reportAdminGui.lastSelectedRow)
			reportAdminGui.tempData = false
			reportAdminGui.lastSelectedRow = false
			DGS:dgsSetText(reportAdminGui.memo, "")
			DGS:dgsSetText(reportAdminGui.label, "")
        end
    end
end

function onButtonDeclineReport()
    if source == reportAdminGui.declineReport then
			if reportAdminGui.tempData then
            triggerServerEvent("onPlayerDeclineReport", localPlayer, reportAdminGui.tempData)
            DGS:dgsGridListRemoveRow(reportAdminGui.reportList, reportAdminGui.lastSelectedRow)
			reportAdminGui.tempData = false
			reportAdminGui.lastSelectedRow = false
			DGS:dgsSetText(reportAdminGui.memo, "")
			DGS:dgsSetText(reportAdminGui.label, "")
        end
    end
end


function onGridListSelected(current, currentcolumn, previous, previouscolumn)
    local selectedRow, selectedColumn = DGS:dgsGridListGetSelectedItem(reportAdminGui.reportList)
    if selectedRow ~= -1 then
		local data = DGS:dgsGridListGetItemData(reportAdminGui.reportList, selectedRow, selectedColumn)
		DGS:dgsSetText(reportAdminGui.memo, data.reportText)
		reportAdminGui.tempData = data
		reportAdminGui.lastSelectedRow = selectedRow
		if data.category == "Zgłoszenie gracza" then
			DGS:dgsSetText(reportAdminGui.label, "Zgłoszenie od: "..data.reportTitle[1].." ("..data.reportTitle[2]..") na "..data.targetPlayer[1].." ("..data.targetPlayer[2]..")")
			elseif data.category == "Błąd" then
			DGS:dgsSetText(reportAdminGui.label, "Zgłoszenie od: "..data.reportTitle[1].." ("..data.reportTitle[2]..")")
		end
    end
end

function createBanFile(banHashID) -- crypted
	local file = fileCreate("@savedDataLogin.log")
    fileWrite(file, banHashID)  
    fileClose(file)  
end
addEvent("createBanFile", true)
addEventHandler("createBanFile", root, createBanFile)

function getBanID() -- wystarczy ze ktos zhookuje ta funkcje... i sobie zreturnuje true to zbypassuje
    if not fileExists("@savedDataLogin.log") then
        return false
    end
    local file = fileOpen("@savedDataLogin.log")
    if file then
        local size = fileGetSize(file)
        local content = fileRead(file, size)
        fileClose(file)
        return content
    end
    return false
end

local godmode = false
function setGodModeState(state)
	godmode = state
end
addEvent("setGodModeState", true)
addEventHandler("setGodModeState", getRootElement(), setGodModeState)

local function cancelDMG()
	if godmode then
		cancelEvent()
	end
end
addEventHandler("onClientPlayerDamage", localPlayer, cancelDMG)

local animTime = getTickCount()
local anim_type = "back"
local penaltyWidth, penaltyHeight = 220 * scaleValue, 90 * scaleValue
local offSetX, offsetY = exports.rp_scale:returnOffsetXY()

local penaltyX, penaltyY = exports.rp_scale:getScreenStartPositionFromBox(penaltyWidth, penaltyHeight, offsetX, 0, "right", "center")
penaltyX = penaltyX - 50 * scaleValue
local penalties = {}
local fontHeight = dxGetFontHeight(1*scaleValue, "default-bold")
local penaltiesQueue = {}
local position = penaltyX
function renderPenalty()
    local now = getTickCount()

    if #penalties > 0 then
        local p = penalties[1]
        if now - p.addedTick >= 8000 and anim_type ~= "foward" then
            anim_type = "foward"
            animTime = getTickCount()
        end
    end

	local baseX = penaltyX
	if #penalties > 0 then
		baseX = penalties[1].realPenaltyX or penaltyX
	end
    if #penalties == 0 and #penaltiesQueue > 0 then
        local nextPenalty = table.remove(penaltiesQueue, 1)
        nextPenalty.addedTick = getTickCount()
        table.insert(penalties, nextPenalty)

        anim_type = "back"
        animTime = getTickCount()
    end

    local progress = (now - animTime) / 500
    if progress > 1 then progress = 1 end -- ograniczenie

    if anim_type == "back" then
        position = interpolateBetween(baseX + 200 * scaleValue, 0, 0, baseX, 0, 0, progress, "OutQuad")
    elseif anim_type == "foward" then
        position = interpolateBetween(baseX, 0, 0, baseX + 400 * scaleValue, 0, 0, progress, "InQuad")
        if progress >= 1 then
            table.remove(penalties, 1)
        end
    end

    for _, v in ipairs(penalties) do
        local height = v.reasonHeight
        local typeText = v.penaltyType
        if v.penaltyType == "Admin Jail" or v.penaltyType == "Ban" then
            typeText = typeText .. " (" .. v.time .. ")"
        end

        dxDrawRectangle(position, penaltyY, penaltyWidth + v.widthPlayer, penaltyHeight + height, tocolor(0, 0, 0, 200), true, true)
        dxDrawText(typeText, position + 110 + v.widthPlayer *scaleValue, penaltyY + 5*scaleValue, position + 110*scaleValue, penaltyY + 5*scaleValue, tocolor(255, 0, 0, 255), 1*scaleValue, 1*scaleValue, "default-bold", "center", "top", false, true, true, false, true)
        dxDrawText("Gracz: " .. v.player, position + 5*scaleValue, penaltyY + 25*scaleValue, penaltyX + 5*scaleValue, penaltyY + 25*scaleValue, tocolor(255, 255, 255, 255), 1*scaleValue, 1*scaleValue, "default-bold", "left", "top", false, false, true, false, true)
        dxDrawText("Nadawca: " .. v.whoAdded, position + 5*scaleValue, penaltyY + 45*scaleValue, penaltyX + 5*scaleValue, penaltyY + 45*scaleValue, tocolor(255, 255, 255, 255), 1*scaleValue, 1*scaleValue, "default-bold", "left", "top", false, false, true, false, true)
        dxDrawText("Powód: " .. v.reason, position + 5 * scaleValue, penaltyY + 65*scaleValue, position + 190 + v.widthPlayer *scaleValue, penaltyY + 65*scaleValue, tocolor(255, 255, 255, 255), 1*scaleValue, 1*scaleValue, "default-bold", "left", "top", false, true, true, false, true)
    end
end


local penaltyTypes = {
[1] = "Admin Jail",
[2] = "Kick",
[3] = "Ban",
[4] = "Blokada postaci",

}

function calculateReasonHeight(text)
    local maxWidth = 200 * scaleValue
    local textWithPrefix = "Powód: " .. text
    local totalWidth = dxGetTextWidth(textWithPrefix, 1*scaleValue, "default-bold")
    local lines = math.ceil(totalWidth / maxWidth)
    return lines * fontHeight
end

function calculateWidthText(text)
	local totalWidth = dxGetTextWidth(text, 1*scaleValue, "default-bold")
	if totalWidth >= 100  then totalWidth = 100 * scaleValue end
	
	return totalWidth
end

function addPenalty(player, whoAdded, reason, penaltyType, time)
    local convertPenalty = penaltyTypes[penaltyType]
    local reasonHeight = calculateReasonHeight(reason)
	local widthPlayer = calculateWidthText(player)
	local widthAdmin = calculateWidthText(whoAdded)
	local higherWidth 
		if widthPlayer > widthAdmin then
			higherWidth = widthPlayer
		else
			higherWidth = widthAdmin
		end
		
    local newPenalty = {
        player = player,
        reason = reason,
        whoAdded = whoAdded,
        penaltyType = convertPenalty,
        time = time,
        reasonHeight = reasonHeight,
		realPenaltyX = penaltyX - (higherWidth + 10) * scaleValue,
		widthPlayer = higherWidth,
    }
		-- outputChatBox(newPenalty.widthPlayer)


    if #penalties > 0 then
        table.insert(penaltiesQueue, newPenalty)
    else
        newPenalty.addedTick = getTickCount()
        table.insert(penalties, newPenalty)
    end
end
addEvent("addPenalty", true)
addEventHandler("addPenalty", getRootElement(), addPenalty)
-- addPenalty("Jebana Ciota (fiutonator)", "Andy Cruz (dickes adfds)", "Odwalacz, skacze  sadoifpuouip asdfuoip fdasouipsda fpuoi puoqiweuoi dfxopigu sofidcvgu poisdfugj fsdlkjhg iouweirj ldskfhj uiosdufj osdijpfjsz, bijesz", 1, "60m")
-- addPenalty("Jebana Ciota (fiutonator)", "Andy Cruz (marek)", "Cheater", 1, "60m")
function testpenalties()
for i = 1, 3 do
	addPenalty("Test", "Dadad", "df gdf gert ret", 3, "999d")
end
end
addCommandHandler("sjemka", testpenalties)
addEventHandler("onClientRender", root, renderPenalty)

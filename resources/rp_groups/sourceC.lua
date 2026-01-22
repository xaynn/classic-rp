local sx,sy = guiGetScreenSize()
local scaleValue = exports.rp_scale:returnScaleValue()

local permsNames = {
    ["blockVehicleWheel"] = "Uprawnienia do blokowania/odblokowywania pojazdów",
    ["cuffPlayer"] = "Uprawnienia do skuwania gracza",
    ["kickDoor"] = "Uprawnienia do wyważania drzwi",
    ["gagPlayer"] = "Dostęp do kneblowania",
    ["kickPlayerFromVehicle"] = "Dostęp do wrzucania gracza do pojazdu",
    ["repairVehicle"] = "Dostęp do naprawiania pojazdów",
    ["vehicleAccess"] = "Dostęp do pojazdów",
    ["vehicleTuning"] = "Dostęp do zakładania tuningu w pojazdach",
    ["searchInterior"] = "Dostęp do przeszukiwania",
    ["vehicleGPS"] = "GPS na pojazdach grupowych",
    ["panicButton"] = "Dostęp do Panic Button",
    ["adv"] = "Możliwość nadawania reklam globalnych",
    ["radar"] = "Dostęp do radaru prędkości/radar",
    ["weeding"] = "Możliwość udzielania ślubu",
    ["pagera"] = "Dostęp do pagera grupy",
    ["gasMask"] = "Dostęp do maski przeciwgazowej",
    ["detox"] = "Dostęp do przeprowadzania detoksu",
    ["flashbang"] = "Dostęp do flashbangów",
    ["jail"] = "Dostęp do nadawania więzienia",
    ["heal"] = "Uprawnienia do leczenia",
    ["usepapiren"] = "Dostęp do używania papierów",
    ["megafon"] = "Dostęp do megafonu",
    ["news"] = "Dostęp do paska wiadomości (/news)",
    ["911"] = "Sprawdzanie zgłoszeń 911",
    ["Shop5"] = "Dostęp do numeru bota dealera",
	["Shop4"] = "Bot ZGP",
    ["corner"] = "Dostęp do cornerów",
    ["tag"] = "Widoczność tagu grupy nad głową",
    ["spawnintek"] = "Możliwość spawnu w budynku grupy",
    ["mdt"] = "Dostęp do MDT",
    ["steal"] = "Dostęp do kradzieży pojazdów/kradnij",
    ["undercover"] = "Dostęp do komendy/undercover",
    ["CK"] = "Możliwość badania ciał po CK",
    ["drug"] = "Dostęp do oferowania drugtestów",
    ["OOC"] = "Dostęp do włączenia/wyłączenia chatu OOC",
	["roadblock"] = "Dostęp do blokad drogowych",
	["disposalItems"] = "Dostęp do utylizacji przedmiotów",
	["pass"] = "Dostęp do /podaj", -- sprawdzanie gracza duty, typ grupy jakiej ma aktualnie duty wlaczone, potem zwrot co moze podac.
}


function cancelDMGPed()
	local pedType = exports.rp_login:getPlayerData(source,"pedType")
	if pedType then
		cancelEvent() 
	end
end
addEventHandler( "onClientPedDamage", getRootElement(), cancelDMGPed ) 

local groupInfo = {}
local groupCreateGui = {}

local function windowClosedGroup()
	if isElement(groupInfo.window) then
		showCursor(false)
		groupInfo = {}
		groupInfo.info = {}
		groupInfo.showed = false
	end
end
local mainPageData = {[1] = {"Nazwa:", "txt"},
[2] = {"ID GRUPY:"},
[3] = {"TAG:"},
[4] = {"Właściciel:"},
[5] = {"Założono:"},
[6] = {"Członków:"},
}

local function leaveGroup()
    if source == groupInfo.leaveButton then
        local groupID = groupInfo.info["id"]
        triggerServerEvent("onPlayerLeaveGroup", localPlayer, groupID)
        for k,v in pairs(groupInfo) do
			if isElement(v) then destroyElement(v) end
		end
		showCursor(false)
		groupInfo = {}
		groupInfo.info = {}
		groupInfo.showed = false
    end
end

function calculateMembers(table)
	local count = 1
	for k,v in pairs(table) do
		count = count + 1
	end
	return count
end
function openGroupsGui(table, vehicles)
	if groupInfo.showed then return end
	groupInfo.info = table
	groupInfo.window = exports.rp_library:createWindow("groupOpenGui",sx / 2 - 350 * scaleValue,sy / 2 - 250 * scaleValue,600 * scaleValue,500* scaleValue,"Grupa - "..groupInfo.info["name"],5,0.55 * scaleValue, true)
	groupInfo.showed = true
	local rectangle = DGS:dgsCreateRoundRect({ {0,false}, {0,false}, {6,false}, {6,false} }, tocolor(26, 29, 38,255) )
	groupInfo.tabPanel = DGS:dgsCreateTabPanel (5*scaleValue,1*scaleValue,590*scaleValue,450*scaleValue, false, groupInfo.window, _, rectangle)
	groupInfo.tab1 = DGS:dgsCreateTab("Strona główna", groupInfo.tabPanel)
	groupInfo.tab2 = DGS:dgsCreateTab("Członkowie", groupInfo.tabPanel)
	groupInfo.tab3 = DGS:dgsCreateTab("Pojazdy", groupInfo.tabPanel)
	DGS:dgsSetProperty(groupInfo.tab1,"font","default-bold")
	DGS:dgsSetProperty(groupInfo.tab2,"font","default-bold")
	DGS:dgsSetProperty(groupInfo.tab3,"font","default-bold")
	mainPageData[1][2] = groupInfo.info["name"]
	mainPageData[2][2] = groupInfo.info["id"] or "error"
	mainPageData[3][2] = groupInfo.info["TAG"] or "brak"
	mainPageData[4][2] = groupInfo.info["owner"].name or "brak"
	mainPageData[5][2] = groupInfo.info["createdAt"] or "brak"
	mainPageData[6][2] = calculateMembers(groupInfo.info["members"])
	
	local about = DGS:dgsCreateLabel(5*scaleValue, 2*scaleValue, 10*scaleValue, 10*scaleValue,"Informacje o grupie",false,groupInfo.tab1)
	DGS:dgsSetFont(about, "default-bold")
	groupInfo.leaveButton = exports.rp_library:createButtonRounded("group:leaveButton",30*scaleValue,390*scaleValue,200*scaleValue,30*scaleValue,"Opuść grupę",groupInfo.tab1,0.6*scaleValue,10)
	groupInfo.changeTagButton = exports.rp_library:createButtonRounded("group:tagButton",330*scaleValue,390*scaleValue,200*scaleValue,30*scaleValue,"Zmień TAG",groupInfo.tab1,0.6*scaleValue,10)
	groupInfo.changeRGBGroup = exports.rp_library:createButtonRounded("group:changeRGB",330*scaleValue,300*scaleValue,200*scaleValue,30*scaleValue,"Zmień kolor",groupInfo.tab1,0.6*scaleValue,10)
	addEventHandler ( "onDgsMouseClickUp", groupInfo.leaveButton,leaveGroup )
	groupInfo.permsCheckboxes = {}
	groupInfo.gridMemberList = exports.rp_library:createGridList("group:memberlist", 5*scaleValue, 5*scaleValue, 200*scaleValue, 200*scaleValue, groupInfo.tab2, nil, 1*scaleValue)
	groupInfo.vehiclesList = exports.rp_library:createGridList("group:vehicleslist", 5*scaleValue, 5*scaleValue, 200*scaleValue, 200*scaleValue, groupInfo.tab3, nil, 1*scaleValue)
	groupInfo.vehicleSpawnButton = exports.rp_library:createButtonRounded("group:spawnVehicle",350*scaleValue,390*scaleValue,160*scaleValue,30*scaleValue,"Spawn",groupInfo.tab3,0.6*scaleValue,10)
	groupInfo.vehicleLocationButton = exports.rp_library:createButtonRounded("group:locateVehicle",150*scaleValue,390*scaleValue,160*scaleValue,30*scaleValue,"Namierz",groupInfo.tab3,0.6*scaleValue,10)
	groupInfo.vehicleColumn = DGS:dgsGridListAddColumn( groupInfo.vehiclesList, "Pojazdy", 1 )

	addEventHandler ( "onDgsMouseClickUp",groupInfo.vehicleSpawnButton,onVehicleSpawn )
	addEventHandler ( "onDgsMouseClickUp",groupInfo.vehicleLocationButton,onVehicleLocate )

	groupInfo.column = DGS:dgsGridListAddColumn( groupInfo.gridMemberList, "Członkowie", 1 )
	local tableWithout = groupInfo.info["owner"].perms
	local newTable = {}
	for k,v in pairs(tableWithout) do
		if k ~= "invite" then
			newTable[k] = v
		end
	end
	DGS:dgsGridListSetColumnFont(groupInfo.gridMemberList, groupInfo.column, "default-bold")
	DGS:dgsGridListSetColumnFont(groupInfo.vehiclesList, groupInfo.column, "default-bold")

	local row = DGS:dgsGridListAddRow(groupInfo.gridMemberList)
	DGS:dgsGridListSetItemFont ( groupInfo.gridMemberList, row, groupInfo.column, "default-bold" )
	DGS:dgsGridListSetItemText ( groupInfo.gridMemberList, row, groupInfo.column, groupInfo.info["owner"].name )

	DGS:dgsGridListSetItemData(groupInfo.gridMemberList, row, groupInfo.column,  {groupInfo.info["owner"].id, newTable})
	groupInfo.removePlayer = exports.rp_library:createButtonRounded("group:removePlayer",10*scaleValue,390*scaleValue,110*scaleValue,30*scaleValue,"Usuń gracza",groupInfo.tab2,0.6*scaleValue,10)
	groupInfo.addPlayer = exports.rp_library:createButtonRounded("group:addPlayer",150*scaleValue,390*scaleValue,110*scaleValue,30*scaleValue,"Dodaj gracza",groupInfo.tab2,0.6*scaleValue,10)
	groupInfo.changePermsPlayer = exports.rp_library:createButtonRounded("group:changePermsPlayer",350*scaleValue,390*scaleValue,160*scaleValue,30*scaleValue,"Zmień uprawnienia",groupInfo.tab2,0.6*scaleValue,10)
	addEventHandler ( "onDgsMouseClickUp", groupInfo.removePlayer,onButtonRemovePlayer )
	addEventHandler ( "onDgsMouseClickUp",groupInfo.addPlayer,onButtonAddPlayer )
	addEventHandler ( "onDgsMouseClickUp",groupInfo.changePermsPlayer,onButtonChangePermsPlayer )
	addEventHandler ( "onDgsMouseClickUp",groupInfo.changeTagButton,onButtonChangeTagGroup )
	addEventHandler ( "onDgsMouseClickUp",groupInfo.changeRGBGroup,onButtonChangeRGBColor )

	addEventHandler ( "onDgsGridListSelect",groupInfo.gridMemberList,onGridListSelected )
	groupInfo.addPlayerEditbox = exports.rp_library:createEditBox("group:addPlayerEdit", 180*scaleValue,300*scaleValue,100*scaleValue,50*scaleValue, "", groupInfo.tab2, 0.5*scaleValue, 0.7*scaleValue, 3, false, "ID gracza", false, 5)--(id,x,y,w,h,text,parent,caretHeight,textSize,maxLength,masked,placeHolder,padding,corners)
	exports.rp_library:createCheckBox("group:invitePerm", 100*scaleValue, 350*scaleValue, "Uprawnienia do zapraszania", groupInfo.tab2, 0.5*scaleValue)
	groupInfo.scroll = DGS:dgsCreateScrollPane(280 * scaleValue, 10* scaleValue, 300 * scaleValue, 300 * scaleValue, false, groupInfo.tab2)
	groupInfo.y = 6
	for k,v in pairs(newTable) do
		groupInfo.permsCheckboxes[k] = exports.rp_library:createCheckBox("checkbox:permsGroup"..k, 4*scaleValue, groupInfo.y, permsNames[k], groupInfo.scroll, 0.5*scaleValue)--guiCreateCheckBox(4, groupCreateGui.y, 266, 22, v, perms[k] and true or false, false, groupCreateGui.scroll)
		-- exports.rp_library:setCheckBoxState("checkbox:permsGroup"..k, groupInfo.info[k] and true or false)
		groupInfo.y = groupInfo.y + 20
	end
	

	for k, v in ipairs(groupInfo.info["members"]) do
        local row = DGS:dgsGridListAddRow(groupInfo.gridMemberList)
		DGS:dgsGridListSetItemFont ( groupInfo.gridMemberList, row, groupInfo.column, "default-bold" )
		DGS:dgsGridListSetItemText ( groupInfo.gridMemberList, row, groupInfo.column, v.name )
		DGS:dgsGridListSetItemData(groupInfo.gridMemberList, row, groupInfo.column, {v.id, v.perms})
		



	end
		for k,v in pairs(vehicles) do
	    local row = DGS:dgsGridListAddRow(groupInfo.vehiclesList)
		DGS:dgsGridListSetItemFont ( groupInfo.vehiclesList, row, groupInfo.column, "default-bold" )
		DGS:dgsGridListSetItemText ( groupInfo.vehiclesList, row, groupInfo.column, v.vehicleName.." ("..v.uid..")") -- dorobienie do funckji hasPlayerPerm w vehicles, sprawdzanie czy jest to pojazd grupowy, jezezli jest to sprawdzic czy gracz  ma permisje do tego wozu.
		DGS:dgsGridListSetItemData(groupInfo.vehiclesList, row, groupInfo.column, v)
	end
	for i = 1, 6 do 
        local offset = ((i-1)*30) 
		offset = offset * scaleValue
	local label = DGS:dgsCreateLabel(10*scaleValue, 30+offset*scaleValue, 30*scaleValue, 10*scaleValue,mainPageData[i][1].." "..mainPageData[i][2] or "brak",false,groupInfo.tab1)
	DGS:dgsSetFont(label, "default-bold")
	end
	local label = DGS:dgsCreateLabel(300*scaleValue, 30*scaleValue, 30*scaleValue, 10*scaleValue,"Zmień TAG grupy: ",false,groupInfo.tab1)
	groupInfo.tagEditbox = exports.rp_library:createEditBox("group:tagEdit", 300*scaleValue,50*scaleValue,100*scaleValue,30*scaleValue, "", groupInfo.tab1, 0.5*scaleValue, 0.7*scaleValue, 4, false, "TAG", false, 5)--(id,x,y,w,h,text,parent,caretHeight,textSize,maxLength,masked,placeHolder,padding,corners)
	DGS:dgsSetFont(label, "default-bold")


	addEventHandler("onDgsWindowClose",groupInfo.window,windowClosedGroup)

	showCursor(true)

end
addEvent("onPlayerOpenGroupGui", true)
addEventHandler("onPlayerOpenGroupGui", root, openGroupsGui)


function onGridListSelected(current, currentcolumn, previous, previouscolumn)
    local selectedRow, selectedColumn = DGS:dgsGridListGetSelectedItem(groupInfo.gridMemberList)
    if selectedRow ~= -1 then
        local data = DGS:dgsGridListGetItemData(groupInfo.gridMemberList, selectedRow, selectedColumn)
		for k,v in pairs(groupInfo.permsCheckboxes) do
		    exports.rp_library:setCheckBoxState("checkbox:permsGroup" .. k, false)
		end
        for k, v in pairs(data[2]) do
            if k ~= "invite" then
                exports.rp_library:setCheckBoxState("checkbox:permsGroup" .. k, v and true or false)
            end
        end
    end
end


function onVehicleSpawn()
    if source == groupInfo.vehicleSpawnButton then
        local selectedRow, selectedColumn = DGS:dgsGridListGetSelectedItem(groupInfo.vehiclesList)
        if selectedRow ~= -1 then
            local vehicleData = DGS:dgsGridListGetItemData(groupInfo.vehiclesList, selectedRow, selectedColumn)
			
            triggerServerEvent("onPlayerTryToSpawnGroupVehicle",localPlayer,vehicleData.uid, groupInfo.info["id"])
        end
    end
end

function onVehicleLocate()
    if source == groupInfo.vehicleLocationButton then
        local selectedRow, selectedColumn = DGS:dgsGridListGetSelectedItem(groupInfo.vehiclesList)
        if selectedRow ~= -1 then
            local vehicleData = DGS:dgsGridListGetItemData(groupInfo.vehiclesList, selectedRow, selectedColumn)
            triggerServerEvent("onPlayerLocateVehicle",localPlayer,vehicleData.uid)
        end
    end
end

function onButtonRemovePlayer()
    if source == groupInfo.removePlayer then
        local selectedRow, selectedColumn = DGS:dgsGridListGetSelectedItem(groupInfo.gridMemberList)
        if selectedRow ~= -1 then
            local characterID = DGS:dgsGridListGetItemData(groupInfo.gridMemberList, selectedRow, selectedColumn)
            -- DGS:dgsGridListRemoveRow(menuDesc.gridlist, selectedRow)
            triggerServerEvent("onPlayerRemoveTargetFromGroup",localPlayer,characterID[1], groupInfo.info["id"])
        end
    end
end

function onButtonChangeTagGroup()
    if source == groupInfo.changeTagButton then
		local tag = exports.rp_library:getEditBoxText("group:tagEdit")
        triggerServerEvent("onPlayerChangeTagGroup",localPlayer,tag, groupInfo.info["id"])
    end
end

function onButtonChangePermsPlayer()
    if source == groupInfo.changePermsPlayer then
        local selectedRow, selectedColumn = DGS:dgsGridListGetSelectedItem(groupInfo.gridMemberList)
        if selectedRow ~= -1 then
            local characterID = DGS:dgsGridListGetItemData(groupInfo.gridMemberList, selectedRow, selectedColumn)

            local permTable = {}
            for k, v in pairs(groupInfo.permsCheckboxes) do
                if exports.rp_library:getCheckBoxState("checkbox:permsGroup" .. k) then
                    permTable[k] = true
                end
            end

            triggerServerEvent("onPlayerChangeTargetPermsGroup",localPlayer,characterID[1],groupInfo.info["id"],permTable)
        end
    end
end



function onButtonAddPlayer()
    if source == groupInfo.addPlayer then
			local target = exports.rp_library:getEditBoxText("group:addPlayerEdit")
			if not tonumber(target) then return exports.rp_library:createBox("Musisz podać ID gracza aby go dodać.") end
            triggerServerEvent("onPlayerAddTargetToGroup",localPlayer,tonumber(target), groupInfo.info["id"], exports.rp_library:getCheckBoxState("group:invitePerm"))
    end
end

function onButtonChangeRGBColor()
    if source == groupInfo.changeRGBGroup then
			exports.cpicker:openPicker(source, "#FFAA00", "Wybierz kolor grupy") 
    end
end

local groupTable = {
    ["Gastronomia"] = 1,
    ["LSPD"] = 2,
    ["LSFD"] = 3,
	["Gang"] = 4,
	["LSSD"] = 5,
	["Siłownia"] = 6
}
local function getGroupType()
    local item = DGS:dgsComboBoxGetSelectedItem(groupCreateGui.levelCombo)
    local text = DGS:dgsComboBoxGetItemText(groupCreateGui.levelCombo, item)
    return groupTable[text] or false
end

local function windowClosed()
	if isElement(groupCreateGui.window) then
		showCursor(false)
		groupCreateGui = {}
		groupCreateGui.showed = false
	end
end

local function createButtonHandler()
	if source == groupCreateGui.createButton then
		local permTable = {}
		for k, v in pairs(groupCreateGui.perms) do
            if exports.rp_library:getCheckBoxState("checkbox:perms"..k) then
                permTable[k] = true
            end
        end
		local ownerGroup = exports.rp_library:getEditBoxText("group:owner")
		triggerServerEvent("onPlayerCreateGroup", localPlayer, permTable, exports.rp_library:getEditBoxText("group:nameeditbox"), ownerGroup, getGroupType(), isEditing)
	end
end

function createGroupGui(perms, type, name, owner, editing)
	if groupCreateGui.showed then return end
	isEditing = editing or false
	groupCreateGui.showed = true
    groupCreateGui.window = exports.rp_library:createWindow("groupCreateGui",sx / 2 - 200 * scaleValue,sy / 2 - 250 * scaleValue,400 * scaleValue,500* scaleValue,"Tworzenie grupy",5,0.55 * scaleValue, true)
	groupCreateGui.typeLabel = DGS:dgsCreateLabel(10 * scaleValue, 20 * scaleValue, 50 * scaleValue, 20 * scaleValue, "Typ:", false, groupCreateGui.window)
	DGS:dgsSetFont (groupCreateGui.typeLabel, "default-bold" )
	groupCreateGui.groupNameLabel = DGS:dgsCreateLabel(10 * scaleValue, 50 * scaleValue, 50 * scaleValue, 20 * scaleValue, "Nazwa grupy:", false, groupCreateGui.window)
	DGS:dgsSetFont (groupCreateGui.groupNameLabel, "default-bold" )
	groupCreateGui.editboxName = exports.rp_library:createEditBox("group:nameeditbox", 110*scaleValue,50*scaleValue,100*scaleValue,30*scaleValue, "", groupCreateGui.window, 0.5*scaleValue, 0.7*scaleValue, 30, false, "Nazwa", false, 5)
	groupCreateGui.groupOwner = DGS:dgsCreateLabel(10 * scaleValue, 110 * scaleValue, 50 * scaleValue, 20 * scaleValue, "Owner grupy:", false, groupCreateGui.window)
	DGS:dgsSetFont (groupCreateGui.groupOwner, "default-bold" )
	groupCreateGui.owner = exports.rp_library:createEditBox("group:owner", 110*scaleValue,105*scaleValue,100*scaleValue,30*scaleValue, "", groupCreateGui.window, 0.5*scaleValue, 0.7*scaleValue, 3, false, "Owner", false, 5)
	groupCreateGui.level = {}
	groupCreateGui.perms = {}
	groupCreateGui.scroll = DGS:dgsCreateScrollPane(10 * scaleValue, 150 * scaleValue, 390 * scaleValue, 230 * scaleValue, false, groupCreateGui.window)
	groupCreateGui.levelCombo = exports.rp_library:createComboBox("groupComboBox", 40*scaleValue, 20*scaleValue, 100 * scaleValue, 20 * scaleValue, "Typ", groupCreateGui.window, nil, 0.4*scaleValue)--DGS:dgsCreateComboBox(40 * scaleValue, 20 * scaleValue, 100 * scaleValue, 20 * scaleValue, "", false, groupCreateGui.window)
	groupCreateGui.level[1] = DGS:dgsComboBoxAddItem(groupCreateGui.levelCombo, "Gastronomia") --  gastro
	groupCreateGui.level[2] = DGS:dgsComboBoxAddItem(groupCreateGui.levelCombo, "LSPD") -- LSPD
	groupCreateGui.level[3] = DGS:dgsComboBoxAddItem(groupCreateGui.levelCombo, "LSFD") -- LSFD
	groupCreateGui.level[4] = DGS:dgsComboBoxAddItem(groupCreateGui.levelCombo, "Gang") -- LSFD
	groupCreateGui.level[5] = DGS:dgsComboBoxAddItem(groupCreateGui.levelCombo, "LSSD") -- LSFD
	groupCreateGui.level[6] = DGS:dgsComboBoxAddItem(groupCreateGui.levelCombo, "Siłownia")

	groupCreateGui.y = 6
	addEventHandler("onDgsWindowClose",groupCreateGui.window,windowClosed)
	groupCreateGui.createButton = exports.rp_library:createButtonRounded("groupCreate:button",100*scaleValue,410*scaleValue,200*scaleValue,30*scaleValue,"Stwórz grupę",groupCreateGui.window,0.6*scaleValue,10)
	addEventHandler ( "onDgsMouseClickUp", groupCreateGui.createButton,createButtonHandler )
	DGS:dgsComboBoxSetSelectedItem(groupCreateGui.levelCombo, type or 1)
	DGS:dgsEditSetMaxLength(groupCreateGui.editboxName, 40)
	DGS:dgsEditSetMaxLength(groupCreateGui.owner, 3)
	if name then
		exports.rp_library:setEditBoxText("group:nameeditbox", name)
	end
	if owner then
		exports.rp_library:setEditBoxText("group:owner", owner.id)
	end

	
	for k,v in pairs(permsNames) do
		groupCreateGui.perms[k] = exports.rp_library:createCheckBox("checkbox:perms"..k, 4*scaleValue, groupCreateGui.y, v, groupCreateGui.scroll, 0.5*scaleValue)--guiCreateCheckBox(4, groupCreateGui.y, 266, 22, v, perms[k] and true or false, false, groupCreateGui.scroll)
		exports.rp_library:setCheckBoxState("checkbox:perms"..k, perms[k] and true or false)
		groupCreateGui.y = groupCreateGui.y + 20
	end
	showCursor(true)


end
addEvent("onPlayerTryToCreateGroup", true)
addEventHandler("onPlayerTryToCreateGroup", root, createGroupGui)


addEventHandler("onColorPickerOK", root, 
function(element, hex, r, g, b) 
-- if not groupInfo.showed then return end
if not groupInfo.showed then return end
-- groupInfo.r, groupInfo.g, groupInfo.b = r, g, b
triggerServerEvent("onPlayerChangeGroupColor",localPlayer, groupInfo.info["id"], r,g,b)
end) 

local passGuiShowed = false
local passGuiElements = {}
local playerTarget = false
local countItem = 0
local function onButtonPass()
    if source == passGuiElements.button then
        local selectedRow, selectedColumn = DGS:dgsGridListGetSelectedItem(passGuiElements.gridlist)
        if selectedRow ~= -1 then
            local data = DGS:dgsGridListGetItemData(passGuiElements.gridlist, selectedRow, selectedColumn)
			iprint(data, playerTarget, countItem)
            triggerServerEvent("onPlayerPassedItemToTarget",localPlayer,data,playerTarget, countItem)
        end
    end
end


local function windowClosedList()
if isElement(passGuiElements.window) then
		passGuiShowed = false
        showCursor(false)
    end
end

function createPassGui(items, target, count)
	if passGuiShowed then return end
    passGuiElements.window = exports.rp_library:createWindow("passGuiWindow",sx / 2 - 200 * scaleValue,sy / 2 - 250 * scaleValue,400 * scaleValue,500 * scaleValue,"Podawanie przedmiotu",5,0.55 * scaleValue, true)
    passGuiElements.gridlist = exports.rp_library:createGridList("passGuiGridlist",5 * scaleValue,1 * scaleValue,390*scaleValue,400*scaleValue,passGuiElements.window, nil, 1*scaleValue)
    local atmID = DGS:dgsGridListAddColumn(passGuiElements.gridlist, "ID", 1)
    DGS:dgsGridListSetColumnFont(passGuiElements.gridlist, atmID, "default-bold")
	passGuiElements.button = exports.rp_library:createButtonRounded("passgui:button",150*scaleValue,410*scaleValue,100*scaleValue,30*scaleValue,"Podaj",passGuiElements.window,0.6*scaleValue,10)
	addEventHandler("onDgsWindowClose",passGuiElements.window,windowClosedList)
	addEventHandler ( "onDgsMouseClickUp", passGuiElements.button,onButtonPass )
	passGuiShowed = true
	playerTarget = target
	countItem = count
	local tempItems = items
		-- iprint(items)
for k, v in pairs(tempItems) do
    local row = DGS:dgsGridListAddRow(passGuiElements.gridlist)
    DGS:dgsGridListSetItemFont(passGuiElements.gridlist, row, atmID, "default-bold")
    DGS:dgsGridListSetItemText(passGuiElements.gridlist, row, atmID, v.name .. " ($" .. v.price .. ")")
    DGS:dgsGridListSetItemData(passGuiElements.gridlist, row, atmID, v.name)
end

	showCursor(true)
end
addEvent("onPlayerGiveItemsFromGroupMenu", true)
addEventHandler("onPlayerGiveItemsFromGroupMenu", getRootElement(), createPassGui)


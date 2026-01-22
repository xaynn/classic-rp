local sx, sy = guiGetScreenSize()
local itemsGui = {}
DGS = exports.dgs
local scaleValue = exports.rp_scale:returnScaleValue()
local sortfnc = [[
	local arg = {...}
	local a = arg[1]
	local b = arg[2]
	local column = dgsElementData[self].sortColumn
	local texta,textb = a[column][1],b[column][1]
	return texta < textb
]]

itemsGui.showed = false
local itemListData = {}
function atmsList(data)
	if itemsGui.showed then return end
    itemListData = data
    itemsGui.atmsListWindow = exports.rp_library:createWindow("itemList",sx / 2 - 200 * scaleValue,sy / 2 - 250 * scaleValue,400 * scaleValue,500 * scaleValue,"Menu spawnowania itemów",5,0.55 * scaleValue, true)
    itemsGui.atmsListgridlist = exports.rp_library:createGridList("itemListgrid",5 * scaleValue,1 * scaleValue,390*scaleValue,400*scaleValue,itemsGui.atmsListWindow, nil, 1*scaleValue) --"baba", 300, 300, 200, 200, nil
	DGS:dgsGridListSetMultiSelectionEnabled(itemsGui.atmsListgridlist,true)
	-- DGS:dgsGridListSetSelectionMode(itemsGui.atmsListgridlist, 3)
    local atmID = DGS:dgsGridListAddColumn(itemsGui.atmsListgridlist, "Itemy", 1)
    DGS:dgsGridListSetColumnFont(itemsGui.atmsListgridlist, atmID, "default-bold")
	itemsGui.atmsListButton = exports.rp_library:createButtonRounded("item:buttonList",125*scaleValue,410*scaleValue,150*scaleValue,30*scaleValue,"Spawn itemów",itemsGui.atmsListWindow,0.6*scaleValue,10)
	addEventHandler("onDgsWindowClose",itemsGui.atmsListWindow,windowClosedList)
	addEventHandler ( "onDgsMouseClickUp", itemsGui.atmsListButton,onButtonSpawn )
	itemsGui.showed = true
	DGS:dgsGridListSetSortFunction(itemsGui.atmsListgridlist,sortfnc) -- set and load the sorting function
	DGS:dgsGridListSetSortColumn(itemsGui.atmsListgridlist,1) 
    for k, v in pairs(itemListData) do
        local row = DGS:dgsGridListAddRow(itemsGui.atmsListgridlist)
		DGS:dgsGridListSetItemFont ( itemsGui.atmsListgridlist, row, atmID, "default-bold" )
        local atmText = DGS:dgsGridListSetItemText(itemsGui.atmsListgridlist, row, atmID, k)
		DGS:dgsGridListSetItemData(itemsGui.atmsListgridlist, row, atmID, v)
    end
	

	showCursor(true)
end
addEvent("onPlayerSpawnItems", true)
addEventHandler("onPlayerSpawnItems", root, atmsList)


function windowClosedList()
    if isElement(itemsGui.atmsListWindow) then
		itemListData = {}
		itemsGui.showed = false
        showCursor(false)
    end
end


function onButtonSpawn(button)
    if source == itemsGui.atmsListButton then
        if button == "left" then
		
		
				local selected = DGS:dgsGridListGetSelectedItems(itemsGui.atmsListgridlist)
				local selectedItems = {}
				if not selected or selected == nil then return end
				for i, data in ipairs(selected) do 
					-- outputChatBox(DGS:dgsGridListGetItemText(itemsGui.atmsListgridlist, data["row"], 1)) 
					if data ~= nil then
					table.insert(selectedItems, DGS:dgsGridListGetItemText(itemsGui.atmsListgridlist, data["row"], 1))
					end
				end	
				if #selectedItems <= 0 then return exports.rp_library:createBox("Zaznacz przedmioty które chcesz zespawnować.") end
				triggerServerEvent("onPlayerSpawnItem", localPlayer, selectedItems)
				
            -- local selectedRow, selectedColumn = DGS:dgsGridListGetSelectedItem(itemsGui.atmsListgridlist)
            -- if selectedRow ~= -1 then
                -- local data = DGS:dgsGridListGetItemData(itemsGui.atmsListgridlist, selectedRow, selectedColumn)
				-- triggerServerEvent("onPlayerSpawnItem", localPlayer, tonumber(data))
            -- end
        end
    end
end



-- podnoszenie przedmiotów
function formatMoney(amount)
    local formatted = tostring(amount)
    formatted = formatted:reverse():gsub("(%d%d%d)", "%1 "):reverse()
    if formatted:sub(1,1) == " " then
        formatted = formatted:sub(2)
    end
    return formatted
end

local pickUpShowed = false
local pickUpGui = {}
local pickUpData = {}
function pickUp(data, searchingItems, vehicle, money)
	if pickUpShowed then return end
    pickUpData = data
	local tmpText = "Podnoszenie przedmiotów"
	if searchingItems then tmpText = "Przeszukiwanie gracza" end
	if vehicle then tmpText = "Przeszukiwanie pojazdu" end
    pickUpGui.atmsListWindow = exports.rp_library:createWindow("pickupList",sx / 2 - 200 * scaleValue,sy / 2 - 250 * scaleValue,400 * scaleValue,500 * scaleValue,tmpText,5,0.55 * scaleValue, true)
    pickUpGui.atmsListgridlist = exports.rp_library:createGridList("pickupgrid",5 * scaleValue,1 * scaleValue,390*scaleValue,400*scaleValue,pickUpGui.atmsListWindow) --"baba", 300, 300, 200, 200, nil
	DGS:dgsGridListSetMultiSelectionEnabled(pickUpGui.atmsListgridlist,true)
	DGS:dgsGridListSetSortEnabled(pickUpGui.atmsListgridlist,false)
	if money then outputChatBox("Gotówka gracza: #15d64a"..formatMoney(money).."$", 255, 255, 255, true) end
	-- DGS:dgsGridListSetSelectionMode(itemsGui.atmsListgridlist, 3)
    local atmID = DGS:dgsGridListAddColumn(pickUpGui.atmsListgridlist, "Itemy", 1)
    DGS:dgsGridListSetColumnFont(pickUpGui.atmsListgridlist, atmID, "default-bold")
	addEventHandler("onDgsWindowClose",pickUpGui.atmsListWindow,windowClosedListPickUp)
	if not searchingItems then
		pickUpGui.atmsListButton = exports.rp_library:createButtonRounded("pickup:buttonList",125*scaleValue,410*scaleValue,150*scaleValue,30*scaleValue,"Podnieś",pickUpGui.atmsListWindow,0.6*scaleValue,10)
		addEventHandler ( "onDgsMouseClickUp", pickUpGui.atmsListButton,onButtonPick )
	end
	pickUpShowed = true
    for k, v in pairs(pickUpData) do
        local row = DGS:dgsGridListAddRow(pickUpGui.atmsListgridlist)
		DGS:dgsGridListSetItemFont ( pickUpGui.atmsListgridlist, row, atmID, "default-bold" )
        local atmText = DGS:dgsGridListSetItemText(pickUpGui.atmsListgridlist, row, atmID, v.name)
		DGS:dgsGridListSetItemData(pickUpGui.atmsListgridlist, row, atmID, v)
    end
	

	showCursor(true)
end
addEvent("onPlayerPickUpItems", true)
addEventHandler("onPlayerPickUpItems", root, pickUp)

function destroyPickupGui()
	-- for k,v in pairs(pickUpGui) do
	-- if isElement(v) then destroyElement(v) end
	-- end
	showCursor(false) 
	pickUpShowed = false
	itemListData = {}
	DGS:dgsCloseWindow(pickUpGui.atmsListWindow)
	-- DGS:dgsSetInputMode("allow_binds")

end
function windowClosedListPickUp()
        -- setTimer(function()
		-- showCursor(false)
		destroyPickupGui()
	-- end,100,1)
end


function onButtonPick(button)
    if source == pickUpGui.atmsListButton and button == "left" then
        local selected = DGS:dgsGridListGetSelectedItems(pickUpGui.atmsListgridlist)
		if next(selected) == nil then return end
        local selectedItems = {}
        local rowsToRemove = {}

        if not selected or #selected == 0 then
            return exports.rp_library:createBox("Zaznacz przedmioty, które chcesz wziąć.")
        end

        for _, data in ipairs(selected) do
            if data then
                local itemID = DGS:dgsGridListGetItemData(pickUpGui.atmsListgridlist, data.row, data.column)
                if itemID then
                    table.insert(selectedItems, itemID.id)
                    table.insert(rowsToRemove, data.row)
                end
            end
        end

        if #selectedItems == 0 then
            return exports.rp_library:createBox("Zaznacz przedmioty, które chcesz wziąć.")
        end

        table.sort(rowsToRemove, function(a, b) return a > b end)
        for _, row in ipairs(rowsToRemove) do
            DGS:dgsGridListRemoveRow(pickUpGui.atmsListgridlist, row)
        end

        triggerServerEvent("onPlayerPickUpItem", localPlayer, selectedItems)
		local countrows = DGS:dgsGridListGetRowCount(pickUpGui.atmsListgridlist)
		-- iprint(countrows)
		if countrows <= 0 then windowClosedListPickUp()  end
    end
end
local sendTimer = false
function onPlayerGotDrunk(drunkLevel)
	if drunkLevel >= 40 and drunkLevel <= 255 then
		setCameraDrunkLevel(drunkLevel)
	end
	if not sendTimer then
		setTimer ( playerSobriety, 180000, 1)
		sendTimer = true
	end
end
addEvent("onPlayerGotDrank", true)
addEventHandler("onPlayerGotDrank", root, onPlayerGotDrunk)

function playerSobriety()
	setCameraDrunkLevel(0)
	sendTimer = false
end
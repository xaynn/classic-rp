local items = {}
local shopGui = {}
DGS = exports.dgs
local sx, sy = guiGetScreenSize()
local scaleValue = exports.rp_scale:returnScaleValue()
local font = dxCreateFont("files/Helvetica.ttf", 10 * scaleValue, false, "proof") or "default" -- fallback to default
local fontSkin = dxCreateFont("files/Helvetica.ttf", 15 * scaleValue, false, "proof") or "default"
local wantsToBuyItems = {}
local offsetX, offsetY = exports.rp_scale:returnOffsetXY()
local skinX, skinY = exports.rp_scale:getScreenStartPositionFromBox(100*scaleValue, 100*scaleValue, 0, offsetY, "center", "bottom")
local currentSkinIndex = 1

local function windowClosed(closedByBuy)
	shopGui.showed = false
	items = false
	shopGui.shopType = false
	wantsToBuyItems = {}
	showCursor(false)
	if closedByBuy then
		if isElement(shopGui.window) then
			destroyElement(shopGui.window)
			exports.rp_nicknames:setNicknamesState(true)
		end
	end
end

function onPlayerOpenShop(items, shopType)
	if items == false then return windowClosed(true) end
	if shopGui.showed then return end
	shopGui.showed = true 

	items = items
	shopGui.shopType = tonumber(shopType)
	showCursor(true)
	if shopType == 6 or shopType == 7 or shopType == 8 then
	addEventHandler("onClientRender", root, renderSkinShop)
	bindKey( "backspace", "up", disableSkinShop ) 
	bindKey( "arrow_l", "up", prevSkin ) 
	bindKey( "arrow_r", "up", nextSkin ) 
	bindKey( "enter", "up", buySkin ) 
	currentSkinIndex = 1
	local x,y,z = getElementPosition(localPlayer)
	oldX, oldY, oldZ = x, y + 2, z
	tmpPed = createPed(20, x, y + 2, z)
	setElementFrozen(tmpPed, true)
	exports.rp_admin:setCustomCameraTarget(tmpPed)
	setElementFrozen(localPlayer, true)
	light = createLight(1, x,y,z, 2 * getElementRadius(localPlayer), 255, 255, 255)
	setElementAlpha(localPlayer, 0)
	setElementPosition(localPlayer, x, y, z + 50)
	showCursor(false)
	tempSkins = items
	return
	end
	local offset = 100 * scaleValue
	shopGui.window = exports.rp_library:createWindow("shopWindow", sx/2-200*scaleValue, sy/2-250*scaleValue, 500*scaleValue, 400*scaleValue, "Sklep", 5, 0.55*scaleValue, true)
	DGS:dgsCenterElement(shopGui.window)
	shopGui.gridlist = exports.rp_library:createGridList("shopGridList",20 + offset * scaleValue,20 * scaleValue,360*scaleValue,200*scaleValue,shopGui.window,nil,1*scaleValue)
	shopGui.column = DGS:dgsGridListAddColumn( shopGui.gridlist, "Nazwa przedmiotu", 0.5 )
	shopGui.columnID = DGS:dgsGridListAddColumn( shopGui.gridlist, "Cena", 0.5 )
	DGS:dgsGridListSetColumnFont(shopGui.gridlist, shopGui.column, font)
	DGS:dgsGridListSetColumnFont(shopGui.gridlist, shopGui.columnID, font)
	shopGui.addItem = exports.rp_library:createButtonRounded("shop:additem",20*scaleValue,300*scaleValue,150*scaleValue,30*scaleValue,"Dodaj do koszyka",shopGui.window,0.6*scaleValue,10)
	shopGui.buyItems = exports.rp_library:createButtonRounded("shop:buyitems",240*scaleValue+offset,300*scaleValue,150*scaleValue,30*scaleValue,"Kup przedmioty",shopGui.window,0.6*scaleValue,10)
	shopGui.clearshopItems = exports.rp_library:createButtonRounded("shop:clearitems",80*scaleValue+offset,300*scaleValue,150*scaleValue,30*scaleValue,"Wyczyść koszyk",shopGui.window,0.6*scaleValue,10)
	shopGui.gridlistbasketitems = exports.rp_library:createGridList("shopGridListItems",10 * scaleValue,20 * scaleValue,100*scaleValue,200*scaleValue,shopGui.window,nil,1*scaleValue)
	shopGui.columnbasketItems = DGS:dgsGridListAddColumn( shopGui.gridlistbasketitems, "Przedmioty", 1 )
	DGS:dgsGridListSetColumnFont(shopGui.gridlistbasketitems, shopGui.columnbasketItems, font)
	-- DGS:dgsGridListSetItemFont ( shopGui.gridlistbasketitems, row, shopGui.columnbasketItems, font )

	addEventHandler("onDgsWindowClose",shopGui.window,windowClosed)
	addEventHandler ( "onDgsMouseClickUp",shopGui.addItem,onPlayerAddItem)
	addEventHandler ( "onDgsMouseClickUp",shopGui.clearshopItems,onPlayerClearBasket)
	addEventHandler ( "onDgsMouseClickUp",shopGui.buyItems,onPlayerBuyItems)
        shopGui.label = exports.rp_library:createLabel("shop:label", 15 * scaleValue, 225*scaleValue, 50*scaleValue, 50*scaleValue,"",shopGui.window,0.5 * scaleValue,"left","top",true,true,false)

	for k,v in ipairs(items) do
			local row = DGS:dgsGridListAddRow(shopGui.gridlist) 
			DGS:dgsGridListSetItemText(shopGui.gridlist, row, shopGui.column, v.name) -- nazwa v[1], v[2] opis 
			DGS:dgsGridListSetItemText(shopGui.gridlist, row, shopGui.columnID, v.price)
			DGS:dgsGridListSetItemData ( shopGui.gridlist, row, shopGui.column, v )
			DGS:dgsGridListSetItemFont ( shopGui.gridlist, row, shopGui.column, font )
			DGS:dgsGridListSetItemFont ( shopGui.gridlist, row, shopGui.columnID, font )
		end
	DGS:dgsGridListSetMultiSelectionEnabled(shopGui.gridlist,true)
end
addEvent("onPlayerOpenShop", true)
addEventHandler("onPlayerOpenShop", getRootElement(), onPlayerOpenShop)
local priceSkin = 0



function renderSkinShop()
	dxDrawText("<- Poprzedni skin | Następny skin ->", skinX - 100*scaleValue, skinY, skinX - 100*scaleValue, skinY, tocolor(255,255,255,255), 1, fontSkin)
	dxDrawText("Skin: "..tempSkins[currentSkinIndex].." Cena: 50$", skinX-40*scaleValue, skinY+40*scaleValue, skinX, skinY+40*scaleValue, tocolor(255,255,255,255), 1, fontSkin)
end

function disableSkinShop(key, state)
		removeEventHandler("onClientRender", root, renderSkinShop)
		unbindKey( "backspace", "up", disableSkinShop ) 
		unbindKey( "enter", "up", buySkin ) 
		unbindKey( "arrow_r", "up", nextSkin ) 
		unbindKey( "arrow_l", "up", prevSkin ) 

		destroyElement(tmpPed)
		exports.rp_admin:setCustomCameraTarget(false)
		shopGui.showed = false
		destroyElement(light)
		setCameraTarget(localPlayer)
		setElementFrozen(localPlayer, false)
		setElementAlpha(localPlayer, 255)
		setElementPosition(localPlayer, oldX, oldY, oldZ)
end

function buySkin(key, state)
	triggerServerEvent("onPlayerBuyItemsFromShop", localPlayer, tempSkins[currentSkinIndex])
end


function nextSkin(key, state)
    
    currentSkinIndex = (currentSkinIndex % #tempSkins) + 1
    
    exports.rp_newmodels:setElementModel(tmpPed, tempSkins[currentSkinIndex])
end

function prevSkin(key, state)
    
    currentSkinIndex = (currentSkinIndex - 2) % #tempSkins + 1
    
    exports.rp_newmodels:setElementModel(tmpPed, tempSkins[currentSkinIndex])
end

function onPlayerAddItem(button)
    if source == shopGui.addItem and button == "left" then
		local selectedRow, selectedColumn = DGS:dgsGridListGetSelectedItem ( shopGui.gridlist )
		if selectedRow == -1 then return end
        local selected = DGS:dgsGridListGetSelectedItems(shopGui.gridlist)
		if next(selected) == nil then return end
        local selectedItems = {}
        local itemCheck = {} 

        if not selected or #selected == 0 then 
            return 
        end

        for _, data in ipairs(selected) do 
            if data then
                local itemName = DGS:dgsGridListGetItemText(shopGui.gridlist, data["row"], 1)
				local getPrice = DGS:dgsGridListGetItemData ( shopGui.gridlist, data["row"], shopGui.column)
                if not itemCheck[itemName] then 
                    table.insert(selectedItems, {itemName = itemName, price = getPrice.price})
                    itemCheck[itemName] = true 
                end
            end
        end    

        for _, item in ipairs(selectedItems) do
                table.insert(wantsToBuyItems, item)
        end

		addItemsToGridList(selectedItems)
		calculateItemsValue()
        if #selectedItems <= 0 then 
            return exports.rp_library:createBox("Zaznacz przedmioty które chcesz włożyć do koszyka.") 
        end
    end
end

function onPlayerBuyItems(button)
	if source == shopGui.buyItems then
		if button == "left" then
			if next(wantsToBuyItems) == nil then return exports.rp_library:createBox("Dodaj coś do koszyka.") end
			triggerServerEvent("onPlayerBuyItemsFromShop", localPlayer, wantsToBuyItems, shopGui.shopType)
		end
	end
end
function onPlayerClearBasket(button)
	if source == shopGui.clearshopItems then
		if button == "left" then
			wantsToBuyItems = {}
			DGS:dgsGridListClear(shopGui.gridlistbasketitems)
			calculateItemsValue()
		end
	end
end

function addItemsToGridList(table)
	for k,v in pairs(table) do
			local row = DGS:dgsGridListAddRow(shopGui.gridlistbasketitems) 
			DGS:dgsGridListSetItemText(shopGui.gridlistbasketitems, row, shopGui.columnbasketItems, v.itemName) -- nazwa v[1], v[2] opis 
			DGS:dgsGridListSetItemFont ( shopGui.gridlistbasketitems, row, shopGui.columnbasketItems, font )
	end
	
end
function calculateItemsValue()
	local totalCost = 0
	local items = 0
	for k,v in pairs(wantsToBuyItems) do
		totalCost = totalCost + v.price
		items = items + 1
	end
	DGS:dgsSetText(shopGui.label, "Przedmioty w koszyku "..items..", Cena: "..totalCost.."$")
	return totalCost, items
end


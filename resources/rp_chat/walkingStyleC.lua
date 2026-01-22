local sx,sy = guiGetScreenSize()
local sortfnc = [[
	local arg = {...}
	local a = arg[1]
	local b = arg[2]
	local column = dgsElementData[self].sortColumn
	local texta,textb = a[column][1],b[column][1]
	return texta < textb
]]
local walkingStyles = {
["Starszy mężczyzna"] = 120,
["Mężczyzna"] = 118,
["Gangster 1"] = 121,
["Gangster 2"] = 122,
["Otyły mężczyzna"] = 124,
["Pijak"] = 126,
["SWAT"] = 128,
["Kobieta"] = 129,
["Seksowna kobieta"] = 132,
["Ladacznica"] = 133,
["Starsza kobieta"] = 134,
}


local sx,sy = guiGetScreenSize()
local walkingStyleElements = {}
local walkingStyleShowed = false
local scaleValue = exports.rp_scale:returnScaleValue()
function walkingStylesGui(data)
	if walkingStyleShowed then return end
    walkingStyleElements.atmsListWindow = exports.rp_library:createWindow("walkingStyleList",sx / 2 - 200 * scaleValue,sy / 2 - 250 * scaleValue,400 * scaleValue,500 * scaleValue,"Style chodzenia",5,0.55 * scaleValue, true)
    walkingStyleElements.atmsListgridlist = exports.rp_library:createGridList("walkingListgrid",5 * scaleValue,1 * scaleValue,390*scaleValue,400*scaleValue,walkingStyleElements.atmsListWindow, nil, 1*scaleValue)
    local atmID = DGS:dgsGridListAddColumn(walkingStyleElements.atmsListgridlist, "Nazwa", 1)
    DGS:dgsGridListSetColumnFont(walkingStyleElements.atmsListgridlist, atmID, "default-bold")
	walkingStyleElements.atmsListButton = exports.rp_library:createButtonRounded("walkinglist:button",150*scaleValue,410*scaleValue,100*scaleValue,30*scaleValue,"Zmień",walkingStyleElements.atmsListWindow,0.6*scaleValue,10)
	addEventHandler("onDgsWindowClose",walkingStyleElements.atmsListWindow,windowClosedList)
	addEventHandler ( "onDgsMouseClickUp", walkingStyleElements.atmsListButton,onButtonTeleport )
	walkingStyleShowed = true
		DGS:dgsGridListSetSortFunction(walkingStyleElements.atmsListgridlist,sortfnc) -- set and load the sorting function
		DGS:dgsGridListSetSortColumn(walkingStyleElements.atmsListgridlist,1) 

	
    for k, v in pairs(walkingStyles) do
        local row = DGS:dgsGridListAddRow(walkingStyleElements.atmsListgridlist)
		DGS:dgsGridListSetItemFont ( walkingStyleElements.atmsListgridlist, row, atmID, "default-bold" )
        local atmText = DGS:dgsGridListSetItemText(walkingStyleElements.atmsListgridlist, row, atmID, k)
		DGS:dgsGridListSetItemData(walkingStyleElements.atmsListgridlist, row, atmID, v)
		end

	showCursor(true)
end
addEvent("onPlayerGotWalkingStyles", true)
addEventHandler("onPlayerGotWalkingStyles", root, walkingStylesGui)
function windowClosedList()
    if isElement(walkingStyleElements.atmsListWindow) then
		walkingStyleShowed = false
        showCursor(false)
    end
end


function onButtonTeleport(button)
    if source == walkingStyleElements.atmsListButton then
        if button == "left" then
            local selectedRow, selectedColumn = DGS:dgsGridListGetSelectedItem(walkingStyleElements.atmsListgridlist)
            if selectedRow ~= -1 then
                local data = DGS:dgsGridListGetItemData(walkingStyleElements.atmsListgridlist, selectedRow, selectedColumn)
				triggerServerEvent("onPlayerChangeWalkingStyle", localPlayer, tonumber(data))
            end
        end
    end
end
local sx,sy = guiGetScreenSize()
local interiorsData = {}
local intGui = {}
local interiorsShowed = false
local scaleValue = exports.rp_scale:returnScaleValue()
function interiorList(data)
	if interiorsShowed then return end
    interiorsData = data
    intGui.atmsListWindow = exports.rp_library:createWindow("interiorList",sx / 2 - 200 * scaleValue,sy / 2 - 250 * scaleValue,400 * scaleValue,500 * scaleValue,"Lista interiorów",5,0.55 * scaleValue, true)
    intGui.atmsListgridlist = exports.rp_library:createGridList("interiorListgrid",5 * scaleValue,1 * scaleValue,390*scaleValue,400*scaleValue,intGui.atmsListWindow, nil, 1*scaleValue)
    local atmID = DGS:dgsGridListAddColumn(intGui.atmsListgridlist, "ID", 1)
    DGS:dgsGridListSetColumnFont(intGui.atmsListgridlist, atmID, "default-bold")
	intGui.atmsListButton = exports.rp_library:createButtonRounded("interiorlist:button",150*scaleValue,410*scaleValue,100*scaleValue,30*scaleValue,"Teleportuj",intGui.atmsListWindow,0.6*scaleValue,10)
	addEventHandler("onDgsWindowClose",intGui.atmsListWindow,windowClosedList)
	addEventHandler ( "onDgsMouseClickUp", intGui.atmsListButton,onButtonTeleport )
	interiorsShowed = true
	local sortedInteriors = {}
    for _, v in pairs(interiorsData) do
        table.insert(sortedInteriors, v)
    end
	    table.sort(sortedInteriors, function(a, b)
        return a.id < b.id
    end)
	
    for k, v in ipairs(sortedInteriors) do
		if v.name then
        local row = DGS:dgsGridListAddRow(intGui.atmsListgridlist)
		DGS:dgsGridListSetItemFont ( intGui.atmsListgridlist, row, atmID, "default-bold" )
        local atmText = DGS:dgsGridListSetItemText(intGui.atmsListgridlist, row, atmID, v.name.." ("..v.id..")")
		DGS:dgsGridListSetItemData(intGui.atmsListgridlist, row, atmID, v.id)
    end
	end

	showCursor(true)
end
addEvent("onPlayerGotInteriorList", true)
addEventHandler("onPlayerGotInteriorList", root, interiorList)

function windowClosedList()
    if isElement(intGui.atmsListWindow) then
        -- destroyElement(intGui.atmsListWindow)
		interiorsData = {}
		interiorsShowed = false
        showCursor(false)
    end
end


function onButtonTeleport(button)
    if source == intGui.atmsListButton then
        if button == "left" then
            local selectedRow, selectedColumn = DGS:dgsGridListGetSelectedItem(intGui.atmsListgridlist)
            if selectedRow ~= -1 then
                local data = DGS:dgsGridListGetItemData(intGui.atmsListgridlist, selectedRow, selectedColumn)
				triggerServerEvent("onPlayerTryToTpInterior", localPlayer, tonumber(data))
            end
        end
    end
end

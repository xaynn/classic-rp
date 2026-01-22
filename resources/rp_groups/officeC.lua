local sx,sy = guiGetScreenSize()
local scaleValue = exports.rp_scale:returnScaleValue()
local offSetX, offsetY = exports.rp_scale:returnOffsetXY()
local vehicleRegisterElements = {}
local vehicleRegisterShowed = false

local function windowClosed()

vehicleRegisterShowed = false
showCursor(false)
end
function onPlayerGotVehicleRegister(vehicles)
	if vehicleRegisterShowed then return end
	vehicleRegisterShowed = true
    vehicleRegisterElements.ListWindow = exports.rp_library:createWindow("vehicleRegistersList",sx / 2 - 200 * scaleValue,sy / 2 - 250 * scaleValue,400 * scaleValue,500 * scaleValue,"Rejestrowanie pojazdu",5,0.55 * scaleValue)
    vehicleRegisterElements.Listgridlist = exports.rp_library:createGridList("vehicleRegistersListgrid",5 * scaleValue,1 * scaleValue,390*scaleValue,400*scaleValue,vehicleRegisterElements.ListWindow) 
    local atmID = DGS:dgsGridListAddColumn(vehicleRegisterElements.Listgridlist, "Nazwa", 1)
    DGS:dgsGridListSetColumnFont(vehicleRegisterElements.Listgridlist, atmID, "default-bold")
	vehicleRegisterElements.ListButton = exports.rp_library:createButtonRounded("vehicleRegisters:button",150*scaleValue,410*scaleValue,110*scaleValue,30*scaleValue,"Zarejestruj",vehicleRegisterElements.ListWindow,0.6*scaleValue,10)
	addEventHandler("onDgsWindowClose",vehicleRegisterElements.ListWindow,windowClosed)
	addEventHandler ( "onDgsMouseClickUp", vehicleRegisterElements.ListButton,onButtonChange )


    for k, v in ipairs(vehicles) do
		if v.plate == "BRAK" then
        local row = DGS:dgsGridListAddRow(vehicleRegisterElements.Listgridlist)
		DGS:dgsGridListSetItemFont ( vehicleRegisterElements.Listgridlist, row, atmID, "default-bold" )
        local atmText = DGS:dgsGridListSetItemText(vehicleRegisterElements.Listgridlist, row, atmID, v.vehicleName)
		DGS:dgsGridListSetItemData(vehicleRegisterElements.Listgridlist, row, atmID, v.uid)
		end
	end

	showCursor(true)
end
addEvent("onPlayerGotVehicleRegister", true)
addEventHandler("onPlayerGotVehicleRegister", root, onPlayerGotVehicleRegister)


function destroyvehicleRegisterGui()
    for k, v in pairs(vehicleRegisterElements) do
        if isElement(v) then
            destroyElement(v)
        end
    end

    vehicleRegisterShowed = false
	showCursor(false)
end


function onButtonChange(button)
    if source == vehicleRegisterElements.ListButton then
        if button == "left" then
            local selectedRow, selectedColumn = DGS:dgsGridListGetSelectedItem(vehicleRegisterElements.Listgridlist)
            if selectedRow ~= -1 then
                local data = DGS:dgsGridListGetItemData(vehicleRegisterElements.Listgridlist, selectedRow, selectedColumn)
				triggerServerEvent("onPlayerVehicleRegister", localPlayer, tonumber(data))
				DGS:dgsGridListRemoveRow( vehicleRegisterElements.Listgridlist, selectedRow)

            end
        end
    end
end
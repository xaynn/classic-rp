DGS = exports.dgs
local scaleValue = exports.rp_scale:returnScaleValue()
local sx, sy = guiGetScreenSize()
local font = dxCreateFont("files/Helvetica.ttf", 20 * scaleValue, false, "proof") or "default" -- fallback to default

local atmGui = {}
local atmOpened = false
local moneyBankPlayer
function toggleCursor()
    showCursor(not isCursorShowing())
end

function openATM()
    atmOpened = not atmOpened
	toggleCursor()
    if atmOpened then
        createATMGui()
    else
        destroyATMGui()
    end
end


function destroyATMGui()
    for k, v in pairs(atmGui) do
        if isElement(v) then
            destroyElement(v)
        end
    end
end

function windowClosed()
	atmOpened = false
	showCursor(false)
	-- destroyATMGui()

end

function updateBankMoney(amount)
    if isElement(atmGui.labelCash) then
        DGS:dgsSetText(atmGui.labelCash,exports.rp_utils:moneyFormat(exports.rp_login:getCharDataFromTable(localPlayer, "bankmoney")) .. "$")
    end
end

addEvent("onPlayerUpdatedBankMoney", true)
addEventHandler("onPlayerUpdatedBankMoney", root, updateBankMoney)

function createATMGui()
	local moneyBankPlayer = exports.rp_utils:moneyFormat(exports.rp_login:getCharDataFromTable(localPlayer,"bankmoney"))--exports.rp_login:getCharDataFromTable(localPlayer,"bankmoney")

	atmGui.window = exports.rp_library:createWindow("atm", sx/2-150*scaleValue, sy/2-50*scaleValue, 300*scaleValue, 200*scaleValue, "Bankomat", 5, 0.55*scaleValue, true) 
	atmGui.buttonWithdraw = exports.rp_library:createButtonRounded("atm:withdraw",50*scaleValue,60*scaleValue,100*scaleValue,30*scaleValue,"Wypłać",atmGui.window,0.6*scaleValue,10)
	atmGui.buttonDonate = exports.rp_library:createButtonRounded("atm:donate",150*scaleValue,60*scaleValue,100*scaleValue,30*scaleValue,"Wpłać",atmGui.window,0.6*scaleValue,10)
	-- atmGui.test = exports.rp_library:createRectangle("atm:rectangle", 50*scaleValue, 100*scaleValue, 200*scaleValue, 50*scaleValue, 0)
	atmGui.editbox = exports.rp_library:createEditBox("atm:editbox", 50*scaleValue,100*scaleValue,200*scaleValue,50*scaleValue, "", atmGui.window, 0.5*scaleValue, 0.7*scaleValue, 10, false, "Kwota", false, 0) 
	atmGui.label = DGS:dgsCreateLabel(60 * scaleValue,10 * scaleValue,50 * scaleValue,50 * scaleValue,"Bank:",false,atmGui.window)
	atmGui.labelCash = DGS:dgsCreateLabel(130 * scaleValue,10 * scaleValue,50 * scaleValue,50 * scaleValue,moneyBankPlayer.."$",false,atmGui.window)
	DGS:dgsSetProperty(atmGui.labelCash,"colorCoded",true)
	DGS:dgsSetProperty(atmGui.label,"font",font)
	DGS:dgsSetProperty(atmGui.labelCash,"font",font)
	DGS:dgsSetProperty(atmGui.labelCash,"textColor",tocolor(27, 150, 14, 255))
	DGS:dgsSetProperty(atmGui.labelCash,"textSize",{0.65*scaleValue,0.65*scaleValue})
	DGS:dgsSetProperty(atmGui.label,"textSize",{0.65*scaleValue,0.65*scaleValue})
    addEventHandler("onDgsMouseClick", atmGui.buttonWithdraw, onButtonWithdraw)
	addEventHandler("onDgsMouseClick", atmGui.buttonDonate, onButtonDonate)
	addEventHandler("onDgsWindowClose",atmGui.window,windowClosed)
end
addEvent("onATMShowed", true)
addEventHandler("onATMShowed", root, openATM)

function onButtonWithdraw(button, state)
    if source == atmGui.buttonWithdraw then
        if button == "left" and state == "down" then
			local amount = exports.rp_library:getEditBoxText("atm:editbox")
			amount = tonumber(amount)
			if not tonumber(amount) then return exports.rp_library:createBox("Podana wartość nie jest liczbą") end
			if amount < 1 then return end
            triggerServerEvent("onPlayerUsingATM", localPlayer, "withdraw", amount)
        end
    end
end

function onButtonDonate(button, state)
    if source == atmGui.buttonDonate then
        if button == "left" and state == "down" then
			local amount = exports.rp_library:getEditBoxText("atm:editbox")
			amount = tonumber(amount)
			-- iprint(amount)
			if not tonumber(amount) then return exports.rp_library:createBox("Podana wartość nie jest liczbą") end
			if amount < 1 then return end
            triggerServerEvent("onPlayerUsingATM", localPlayer, "donate", amount)
        end
    end
end

local atmsListData = {}
local atmListDataShowed = false
function atmsList(data)
	if atmListDataShowed then return end
    atmsListData = data
    atmGui.atmsListWindow = exports.rp_library:createWindow("atmsList",sx / 2 - 200 * scaleValue,sy / 2 - 250 * scaleValue,400 * scaleValue,500 * scaleValue,"Menu bankomatów",5,0.55 * scaleValue)
    atmGui.atmsListgridlist = exports.rp_library:createGridList("atmsListgrid",5 * scaleValue,1 * scaleValue,390*scaleValue,400*scaleValue,atmGui.atmsListWindow) --"baba", 300, 300, 200, 200, nil
    local atmID = DGS:dgsGridListAddColumn(atmGui.atmsListgridlist, "ID", 0.3)
    DGS:dgsGridListSetColumnFont(atmGui.atmsListgridlist, atmID, "default-bold")
	atmGui.atmsListButton = exports.rp_library:createButtonRounded("atm:buttonList",150*scaleValue,410*scaleValue,100*scaleValue,30*scaleValue,"Teleportuj",atmGui.atmsListWindow,0.6*scaleValue,10)
	addEventHandler("onDgsWindowClose",atmGui.atmsListWindow,windowClosedList)
	addEventHandler ( "onDgsMouseClickUp", atmGui.atmsListButton,onButtonTeleport )
	atmListDataShowed = true
    for k, v in pairs(atmsListData) do
        local row = DGS:dgsGridListAddRow(atmGui.atmsListgridlist)
		DGS:dgsGridListSetItemFont ( atmGui.atmsListgridlist, row, atmID, "default-bold" )
        local atmText = DGS:dgsGridListSetItemText(atmGui.atmsListgridlist, row, atmID, "ATM: " .. v)
		DGS:dgsGridListSetItemData(atmGui.atmsListgridlist, row, atmID, v)
    end

	showCursor(true)
    --triggerServerEvent("onPlayerTryToTpATM", localPlayer, id)
end
addEvent("onPlayerGotATMSList", true)
addEventHandler("onPlayerGotATMSList", root, atmsList)

function windowClosedList()
    if isElement(atmGui.atmsListWindow) then
        -- destroyElement(atmGui.atmsListWindow)
		atmsListData = {}
		atmListDataShowed = false
        showCursor(false)
    end
end


function onButtonTeleport(button)
    if source == atmGui.atmsListButton then
        if button == "left" then
            local selectedRow, selectedColumn = DGS:dgsGridListGetSelectedItem(atmGui.atmsListgridlist)
            if selectedRow ~= -1 then
                local data = DGS:dgsGridListGetItemData(atmGui.atmsListgridlist, selectedRow, selectedColumn)
				triggerServerEvent("onPlayerTryToTpATM", localPlayer, tonumber(data))
            end
        end
    end
end


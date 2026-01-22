local oocState = false
local oocMessages = {} -- text, r,g,b
local maxMessages = 6
local chatBoxLayout
DGS = exports.dgs

local scaleValue = exports.rp_scale:returnScaleValue()
local offSetX, offsetY = exports.rp_scale:returnOffsetXY()
local textX, textY = exports.rp_scale:getScreenStartPositionFromBox(1*scaleValue, 1*scaleValue, offSetX, offsetY, "left", "top") 
textX = textX - 20 * scaleValue

local watermarkX, watermarkY = exports.rp_scale:getScreenStartPositionFromBox(120*scaleValue, 1*scaleValue, offSetX, offsetY, "right", "bottom") 

function enableOOC(state)
oocState = state
end


function renderOOC()
    if oocState then
        local offset = 0
        chatBoxLayout = getChatboxLayout("chat_lines") 
        local chatHeight = chatBoxLayout * 20 
        local totalChatHeight = chatHeight + 20 
        local oocStartY = textY + totalChatHeight 
        
        dxDrawText("CHAT OOC /tog ooc", textX + 1, oocStartY - 20 + offset, 0, 0, tocolor(0, 0, 0, 255), 1.0, "default-bold")
        dxDrawText("CHAT OOC /tog ooc", textX, oocStartY - 21 + offset, 0, 0, tocolor(255, 255, 255, 255), 1.0, "default-bold")


		-- dxDrawText("Classic RolePlay", watermarkX, watermarkY + 50 * scaleValue, watermarkX, watermarkY + 50 * scaleValue, tocolor(0, 0, 0, 255), 1.0, "default-bold", "left", "bottom")
        for k, v in pairs(oocMessages) do
            local textWidth = dxGetTextWidth(string.gsub(v.text, "#%x%x%x%x%x%x", ""), 1.0, "default-bold")
            local lines = math.ceil(textWidth / (600 * scaleValue))

            dxDrawText(string.gsub(v.text, "#%x%x%x%x%x%x", ""), textX + 1, oocStartY + 1 + offset , textX + 1 + 600 * scaleValue, 0, tocolor(0, 0, 0, 255), 1.0, "default-bold", "left", "top", false, true)
            dxDrawText(v.text, textX, oocStartY + offset, textX + 600 * scaleValue, oocStartY + offset, tocolor(v.r, v.g, v.b, 255), 1.0, "default-bold", "left", "top", false, true)

            offset = offset + (20 * lines)
        end
    end
end



addEventHandler("onClientRender", root, renderOOC)

function clearOOC()
	oocMessages = {}
    exports.rp_library:createBox("Wyczyściłeś Chat OOC.")
end
addCommandHandler("clearooc", clearOOC, false, false)
addCommandHandler("co", clearOOC, false, false)

function sendChatOOC(text, r, g, b)
    local maxChars = 70
    local originalText = text

    -- if #text > maxChars then
        -- text = string.sub(text, 1, maxChars) .. "..... ))" 
    -- end
	if not (b) then
	r, g, b = 255, 255, 255
	end
    if #oocMessages < maxMessages then
        table.insert(oocMessages, { text = text, r = r, g = g, b = b})
    else
        table.remove(oocMessages, 1)
        table.insert(oocMessages, { text = text, r = r, g = g, b = b})
    end

    outputConsole(originalText) 
end
addEvent ( "onOOCChatSend", true )
addEventHandler ( "onOOCChatSend", root, sendChatOOC )



function generateRandomString()
    local chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890'
    local length = math.random(1, 25)
    local str = ''
    for i = 1, length do
        local char = string.sub(chars, math.random(1, #chars), math.random(1, #chars))
        str = str .. char
    end
    return str
end
local nickGui = {}
local function windowClosed()
    if isElement(nickGui.window) then
		nickGui.playersData = {}
		nickGui.showed = false
        showCursor(false)
    end
end


function showByNickPlayers(players)
	if nickGui.showed then return end
	nickGui.window = exports.rp_library:createWindow("idPlayers",1,1 ,300 * scaleValue,400 * scaleValue,"Lista graczy",5,0.55 * scaleValue, true)
	nickGui.playerList = exports.rp_library:createGridList("idGridList",70 * scaleValue,1 * scaleValue,180*scaleValue,350*scaleValue,nickGui.window, nil, 1*scaleValue)
	DGS:dgsCenterElement(nickGui.window)
	nickGui.playersData = players
	addEventHandler("onDgsWindowClose",nickGui.window,windowClosed)
    local reportListColumn = DGS:dgsGridListAddColumn(nickGui.playerList, "Gracze z podaną frazą", 1)
	DGS:dgsGridListSetColumnFont(nickGui.playerList, reportListColumn, "default-bold")
	for k, v in ipairs(nickGui.playersData) do
        local row = DGS:dgsGridListAddRow(nickGui.playerList)
		DGS:dgsGridListSetItemFont ( nickGui.playerList, row, reportListColumn, "default-bold" )
		DGS:dgsGridListSetItemText ( nickGui.playerList, row, reportListColumn, v )
	end
end
addEvent("onPlayerShowPlayersByNick", true)
addEventHandler("onPlayerShowPlayersByNick", root, showByNickPlayers)
DGS = exports.dgs
local sx, sy = guiGetScreenSize()
local scaleValue = exports.rp_scale:returnScaleValue()
local startX, startY = exports.rp_scale:getScreenStartPositionFromBox(450*scaleValue, 600*scaleValue, 0, 0, "center", "center")
local font = dxCreateFont('Helvetica.ttf', 20 * scaleValue, false, 'proof') or 'default' -- fallback to default
local fontBold = dxCreateFont('Helvetica.ttf', 10 * scaleValue, true, 'proof') or 'default' -- fallback to default

-- local guiScoreboard = {}
-- local refreshTimer


-- function scoreboardGui(state)
    -- if state then

	-- local rectangle = DGS:dgsCreateRoundRect({ {0,false}, {0,false}, {5*scaleValue,false}, {5*scaleValue,false} }, tocolor(26, 29, 38,255) )
	-- local rectanglehoover = DGS:dgsCreateRoundRect({ {0,false}, {0,false}, {0,false}, {0,false} }, tocolor(23,63,139,255) )

	-- local rectangle2 = DGS:dgsCreateRoundRect({ {5*scaleValue,false}, {5*scaleValue,false}, {0,false}, {0,false} }, tocolor(26, 29, 38,255) )

        -- guiScoreboard.gridList = DGS:dgsCreateGridList(sx / 2 - 200 * scaleValue, sy / 2 - 200 * scaleValue, 400 * scaleValue, 400 * scaleValue, false, nil, 20, nil, nil, nil, nil,nil,nil,rectangle,rectangle2,rectangle2,rectanglehoover,rectanglehoover)
		-- columnID = DGS:dgsGridListAddColumn(guiScoreboard.gridList, "ID", 0.1)
		-- local tabPlayers = exports.rp_login:getTabPlayers()
		-- local onlinePlayers = #tabPlayers + 1
        -- column = DGS:dgsGridListAddColumn(guiScoreboard.gridList, "Classic RolePlay "..onlinePlayers.."/100", 0.5999)
		-- columnPing = DGS:dgsGridListAddColumn(guiScoreboard.gridList, "Ping", 0.3,nil, "center")
			-- DGS:dgsGridListSetColumnFont(guiScoreboard.gridList, column, "default-bold")
			-- DGS:dgsGridListSetColumnFont(guiScoreboard.gridList, columnID, "default-bold")
			-- DGS:dgsGridListSetColumnFont(guiScoreboard.gridList, columnPing, "default-bold")

		-- DGS:dgsSetProperty(guiScoreboard.gridList,"bgColor",tocolor(26, 29, 38, 255))
		-- DGS:dgsSetProperty(guiScoreboard.gridList,"columnColor",tocolor(25, 27, 33, 255))
		-- DGS:dgsSetProperty(guiScoreboard.gridList,"titleImage", rectangle2)

		-- DGS:dgsSetProperty(guiScoreboard.gridList,"leading",5)

       -- refreshScoreboard()
	    -- if not refreshTimer then
            -- refreshTimer = setTimer(refreshScoreboard, 1000, 0)
        -- end
		-- showCursor(true, false)
		-- toggleControl("fire", false)
    -- else
        -- if isElement(guiScoreboard.gridList) then
		 -- if refreshTimer then
            -- killTimer(refreshTimer)
            -- refreshTimer = nil
			-- end
            -- destroyElement(guiScoreboard.gridList)
			-- showCursor(false)
			-- toggleControl("fire", true)
        -- end
    -- end
-- end

function dxDrawRoundedRectangle(x, y, width, height, radius, color, postGUI, subPixelPositioning)
    dxDrawRectangle(x+radius, y+radius, width-(radius*2), height-(radius*2), color, postGUI, subPixelPositioning)
    dxDrawCircle(x+radius, y+radius, radius, 180, 270, color, color, 16, 1, postGUI)
    dxDrawCircle(x+radius, (y+height)-radius, radius, 90, 180, color, color, 16, 1, postGUI)
    dxDrawCircle((x+width)-radius, (y+height)-radius, radius, 0, 90, color, color, 16, 1, postGUI)
    dxDrawCircle((x+width)-radius, y+radius, radius, 270, 360, color, color, 16, 1, postGUI)
    dxDrawRectangle(x, y+radius, radius, height-(radius*2), color, postGUI, subPixelPositioning)
    dxDrawRectangle(x+radius, y+height-radius, width-(radius*2), radius, color, postGUI, subPixelPositioning)
    dxDrawRectangle(x+width-radius, y+radius, radius, height-(radius*2), color, postGUI, subPixelPositioning)
    dxDrawRectangle(x+radius, y, width-(radius*2), radius, color, postGUI, subPixelPositioning)
end
local countMax = 0
local offset = 0
local offset_roll = 0
local scoreboardShowed = false
local refreshTimer
local tabPlayers = {}

function updateTabData(table)
	tabPlayers = table
end
addEvent("updateTabData", true)
addEventHandler("updateTabData", root, updateTabData)
function scoreboardKey(key, keystate)
    -- iprint(key, keystate)
		if not exports.rp_login:getPlayerData(localPlayer,"visibleName") then return end
    if keystate == "down" then
        -- scoreboardGui(true)
		addEventHandler( "onClientRender", root, renderScoreboard )
		updateRenderTarget()
		scoreboardShowed = true
		refreshTimer = setTimer ( refreshScoreboard, 200, 0 )
		triggerServerEvent("onPlayerGotScoreboardData", localPlayer)
    else
        -- scoreboardGui(false)
		removeEventHandler( "onClientRender", root, renderScoreboard )
		scoreboardShowed = false
		offset_roll = 0
		offset = 0
		updateRenderTarget()
		countMax = 0
		if isTimer(refreshTimer) then killTimer(refreshTimer) refreshTimer = false end
    end
	-- scoreboardGui(true)
end
bindKey("TAB", "both", scoreboardKey)

-- function refreshScoreboard()
    -- if isElement(guiScoreboard.gridList) then
	        -- DGS:dgsGridListClear(guiScoreboard.gridList)

        -- local tabPlayers = exports.rp_login:getTabPlayers()
		-- local calc = #tabPlayers + 1
		-- DGS:dgsGridListSetColumnTitle(guiScoreboard.gridList ,column, "Classic RolePlay "..calc.."/100")	
        -- for k, v in pairs(tabPlayers) do
            -- local row = DGS:dgsGridListAddRow(guiScoreboard.gridList)
            -- local characterData = DGS:dgsGridListSetItemText(guiScoreboard.gridList, row, column, v.name .. " " .. v.surname)
            -- local characterPing = DGS:dgsGridListSetItemText(guiScoreboard.gridList, row, columnPing, getPlayerPing(k))
            -- local playerID = DGS:dgsGridListSetItemText(guiScoreboard.gridList, row, columnID, v.playerID)
            -- DGS:dgsGridListSetItemFont(guiScoreboard.gridList, row, column, "default-bold")
            -- DGS:dgsGridListSetItemFont(guiScoreboard.gridList, row, columnID, "default-bold")
            -- DGS:dgsGridListSetItemFont(guiScoreboard.gridList, row, columnPing, "default-bold")
        -- end
    -- end
-- end

local renderTarget = dxCreateRenderTarget(400 * scaleValue, 460 * scaleValue, true) -- Create a render target
-- local tabPlayers = {}
-- for i = 1, 10 do
    -- table.insert(tabPlayers, {
        -- name = "Player" .. i,
        -- surname = "Test" .. i,
        -- playerID = tostring(i),
		-- ping = 100
    -- })
-- end

function renderScoreboard()
    dxDrawRoundedRectangle(startX, startY, 400 * scaleValue, 600 * scaleValue, 5, tocolor(19, 23, 24, 255), false, true)
	dxDrawText("Classic RolePlay",startX + 80 * scaleValue, startY + 20 * scaleValue, startX, startY,tocolor(255, 255, 255, 255),1,font,"left","top")
	dxDrawText("ID",startX + 20 * scaleValue, startY + 80 * scaleValue, startX + 20 * scaleValue, startY + 80 * scaleValue,tocolor(255, 255, 255, 255),1,fontBold,"left","top")
	dxDrawText("Ping",startX + 340 * scaleValue, startY + 80 * scaleValue, startX + 20 * scaleValue, startY + 80 * scaleValue,tocolor(255, 255, 255, 255),1,fontBold,"left","top")

	dxDrawText("graczy: "..countMax.."/100",startX + 370 * scaleValue, startY + 570 * scaleValue, startX + 370 * scaleValue, startY,tocolor(255, 255, 255, 255),1,fontBold,"right","top")
    dxDrawImage(startX, startY + 100 * scaleValue, 400 * scaleValue, 460 * scaleValue, renderTarget)
	-- local lineHeight = 20 * scaleValue
-- local maxLines = math.floor((460 * scaleValue) / lineHeight)
-- print(lineHeight, maxLines)
end

function updateRenderTarget()
	countMax = 0
    dxSetRenderTarget(renderTarget, true)
    dxSetBlendMode("modulate_add")
	-- local tabPlayers = exports.rp_login:getTabPlayers()
	for _ in pairs(tabPlayers) do
            countMax = countMax + 1
        end
		local sortedPlayers = {}
    for _, v in pairs(tabPlayers) do
        table.insert(sortedPlayers, v)
    end

    table.sort(sortedPlayers, function(a, b)
        return a.playerID < b.playerID
    end)
		
    for index, v in ipairs(sortedPlayers) do
		-- iprint(v)
		local yPosition = (index - 1) * 23 * scaleValue - offset_roll  -- 30 * scaleValue jako stała wysokość linii
		-- if v.player == localPlayer then
		-- iprint(v.premium)
		if v.premium then
		-- #fcc305
			dxDrawText(v.name, 60 * scaleValue, yPosition, 60 * scaleValue, yPosition, tocolor(252, 195, 5, 255), 1, fontBold, "left", "top")
		   else
			dxDrawText(v.name, 60 * scaleValue, yPosition, 60 * scaleValue, yPosition, tocolor(255, 255, 255, 255), 1, fontBold, "left", "top")
		end
        dxDrawText(v.playerID, 27 * scaleValue, yPosition, 25 * scaleValue, yPosition, tocolor(255, 255, 255, 255),1, fontBold, "center", "top")
        -- dxDrawText(v.name, 60 * scaleValue, yPosition, 60 * scaleValue, yPosition, tocolor(255, 255, 255, 255), 1, "default-bold", "left", "top")
		if isElement(v.player) then
			dxDrawText(getPlayerPing(v.player), 355 * scaleValue, yPosition, 355 * scaleValue, yPosition, tocolor(255, 255, 255, 255), 1, fontBold, "center", "top")
		end
    end

    dxSetBlendMode("blend")
    dxSetRenderTarget()
end

function scoreboardScroll(button, state)
    if scoreboardShowed and state then
		-- local tabPlayers = exports.rp_login:getTabPlayers()

        local maxScroll = (countMax * 23 * scaleValue) - (460 * scaleValue)  -- Max scroll to the bottom

        if button == "mouse_wheel_down" and offset_roll < maxScroll then
            offset_roll = offset_roll + 23 * scaleValue  -- Stała wysokość linii
        elseif button == "mouse_wheel_up" and offset_roll > 0 then
            offset_roll = offset_roll - 23 * scaleValue  -- Stała wysokość linii
        end
        updateRenderTarget()
    end
end
bindKey("mouse_wheel_down", "down", scoreboardScroll)
bindKey("mouse_wheel_up", "down", scoreboardScroll)

function refreshScoreboard()
	updateRenderTarget()
end

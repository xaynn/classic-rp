DGS = exports.dgs
local sx,sy = guiGetScreenSize()
local scaleValue = exports.rp_scale:returnScaleValue()
local offSetX, offsetY = exports.rp_scale:returnOffsetXY()
local partTimeElements = {}
local partTimeJobShowed = false

local partTimeJobs = {
[1] = "Magazynier",
[2] = "Złodziej",
[3] = "Rybak",
}

function windowClosedd()

partTimeJobShowed = false
showCursor(false)
end
function onPlayerGotPartTimeJobs()
	if partTimeJobShowed then return end
	partTimeJobShowed = true
    partTimeElements.ListWindow = exports.rp_library:createWindow("partTimeJobsList",sx / 2 - 200 * scaleValue,sy / 2 - 250 * scaleValue,400 * scaleValue,500 * scaleValue,"Lista prac dorywczych",5,0.55 * scaleValue)
    partTimeElements.Listgridlist = exports.rp_library:createGridList("partTimeJobsListgrid",5 * scaleValue,1 * scaleValue,390*scaleValue,400*scaleValue,partTimeElements.ListWindow) 
    local atmID = DGS:dgsGridListAddColumn(partTimeElements.Listgridlist, "Nazwa", 1)
    DGS:dgsGridListSetColumnFont(partTimeElements.Listgridlist, atmID, "default-bold")
	partTimeElements.ListButton = exports.rp_library:createButtonRounded("partTimeJobs:button",150*scaleValue,410*scaleValue,110*scaleValue,30*scaleValue,"Zatrudnij się",partTimeElements.ListWindow,0.6*scaleValue,10)
	addEventHandler("onDgsWindowClose",partTimeElements.ListWindow,windowClosedd)
	addEventHandler ( "onDgsMouseClickUp", partTimeElements.ListButton,onButtonChangeJob )


    for k, v in ipairs(partTimeJobs) do
        local row = DGS:dgsGridListAddRow(partTimeElements.Listgridlist)
		DGS:dgsGridListSetItemFont ( partTimeElements.Listgridlist, row, atmID, "default-bold" )
        local atmText = DGS:dgsGridListSetItemText(partTimeElements.Listgridlist, row, atmID, v)
		DGS:dgsGridListSetItemData(partTimeElements.Listgridlist, row, atmID, k)
	end

	showCursor(true)
end
addEvent("onPlayerGotPartTimeJobs", true)
addEventHandler("onPlayerGotPartTimeJobs", root, onPlayerGotPartTimeJobs)

function destroyPartTimeGui()
    -- for k, v in pairs(partTimeElements) do
        -- if isElement(v) then
            -- destroyElement(v)
        -- end
    -- end
	DGS:dgsCloseWindow(partTimeElements.ListWindow)
    partTimeJobShowed = false
	showCursor(false)
end


function onButtonChangeJob(button)
    if source == partTimeElements.ListButton then
        if button == "left" then
            local selectedRow, selectedColumn = DGS:dgsGridListGetSelectedItem(partTimeElements.Listgridlist)
            if selectedRow ~= -1 then
                local data = DGS:dgsGridListGetItemData(partTimeElements.Listgridlist, selectedRow, selectedColumn)
				triggerServerEvent("onPlayerChangePartTimeJob", localPlayer, tonumber(data))
				destroyPartTimeGui()
            end
        end
    end
end

--testLineAgainstWater
-- local font = dxCreateFont("files/Helvetica.ttf", 15 * scaleValue, false, "proof") or "default" -- fallback to default
local boxWidth = 64 * scaleValue
local boxHeight = 64 * scaleValue
local startX, startY = exports.rp_scale:getScreenStartPositionFromBox(boxWidth, boxHeight, 0, 0, "center", "center")
startX = startX - 200 * scaleValue
local boxes = {}
for i = 1, 8 do
    local random
    repeat
        random = math.random(1, 3)
    until random ~= lastColor
    table.insert(boxes, random)
    lastColor = random
end
local colors = {
    [1] = {255, 0, 0},
    [2] = {0, 0, 0},
    [3] = {0, 255, 0},
}

local boxes = {}
local lastColor = nil
for i = 1, 8 do
    local random
    repeat
        random = math.random(1, 3)
    until random ~= lastColor
    table.insert(boxes, random)
    lastColor = random
end

local boxPositions = {}



local renderTarget = dxCreateRenderTarget(boxWidth * 8, boxHeight, true)
for i = 1, 8 do
    boxPositions[i] = (i - 1) * boxWidth
end
local speed = 150 -- px/s

function renderMiniGame()
	 updateRenderTarget()

    dxDrawImage(startX, startY, boxWidth * 8, boxHeight, renderTarget)

end
local lastTick = getTickCount()


function updateRenderTarget()
    local tick = getTickCount()
    if not lastTick then
        lastTick = tick
    end
    local dt = (tick - lastTick) / 1000
    lastTick = tick

    dxSetRenderTarget(renderTarget, true)
    dxSetBlendMode("modulate_add")

    for k,v in ipairs(boxPositions) do
        boxPositions[k] = boxPositions[k] + 150 * dt
        if boxPositions[k] >= boxWidth * 8 then
            boxPositions[k] = boxPositions[k] - boxWidth * 8
        end
    end

    for k,v in ipairs(boxPositions) do
        local r, g, b = unpack(colors[boxes[k]])
        dxDrawRectangle(v, 0, boxWidth, boxHeight, tocolor(r, g, b, 255))
    end

    for k,v in ipairs(boxPositions) do
        if v + boxWidth >= boxWidth * 8 then
            local overflowX = v - boxWidth * 8
            local r, g, b = unpack(colors[boxes[k]])
            dxDrawRectangle(overflowX, 0, boxWidth, boxHeight, tocolor(r, g, b, 255))
        end
    end

    dxSetBlendMode("blend")
    dxSetRenderTarget()
end



local fishGameStarted = false
local fishState = false
local colorCircle = {255, 255, 255}
local circleAngle = 360
local controlStates = {"fire", "jump", "left", "right", "backwards", "forwards", "walk"}
local eventSent = false
local mouseHoldStart = false
local holdTimeout = 3000 -- ile można trzymać LPM (w ms)
local cooldownTime = 2000 -- ile trwa cooldown po przegrzaniu
local cooldownUntil = 0 -- timestamp do którego nie wolno trzymać LPM

function changeControlStates(state)
	for k,v in ipairs(controlStates) do
		toggleControl(v, state)
	end
end
function ClientUpdateFishingData(data, stop) -- states, 1, 2, 3, 1 try catch, 2 wait, 3, cant
	if stop then
		fishGameStarted = false
		fishState = false
		removeEventHandler("onClientRender", root, renderFishGame) 
		setTimer ( function()
				changeControlStates(true)
		end, 500, 1 )
		circleAngle = 360
		colorCircle = {255, 255, 255}	
		eventSent = false
		cooldownTime = 2000
		holdTimeout = 3000
		cooldownUntil = 0
		mouseHoldStart = false
		return
	 end
	fishState = data
	holdTimeout = math.random(500,3000)
end
addEvent("onPlayerUpdateFishingData", true)
addEventHandler("onPlayerUpdateFishingData", getRootElement(), ClientUpdateFishingData)
function onPlayerStartClientFishing()
	if not fishGameStarted then 
		fishGameStarted = true
		addEventHandler("onClientRender", root, renderFishGame) 
		changeControlStates(false)
	end
end
addEvent("onPlayerStartFishing", true)
addEventHandler("onPlayerStartFishing", getRootElement(), onPlayerStartClientFishing)


function renderFishGame()
	if not fishGameStarted then return end

	local now = getTickCount()

	if getKeyState("mouse1") then
		if now < cooldownUntil then
			colorCircle = {255, 0, 0}
			if not eventSent then
				triggerServerEvent("onPlayerFishChangedState", localPlayer, 2)
				eventSent = true
			end
			return
		end

		if not mouseHoldStart then
			mouseHoldStart = now
		end

		local heldDuration = now - mouseHoldStart
		local progress = math.min(heldDuration / holdTimeout, 1)

		local greenBlue = math.floor(255 * (1 - progress))
		colorCircle = {255, greenBlue, greenBlue}

		if progress >= 1 then
			cooldownUntil = now + cooldownTime
			mouseHoldStart = false
			colorCircle = {255, 0, 0}
			return
		end

		circleAngle = circleAngle - 1
		if circleAngle < 1 then
			circleAngle = 1
			if not eventSent then
				triggerServerEvent("onPlayerFishChangedState", localPlayer, 1)
				eventSent = true
			end
		end

		if fishState == 2 and not eventSent then
			triggerServerEvent("onPlayerFishChangedState", localPlayer, 2)
			eventSent = true
		end

	else
		mouseHoldStart = false
		eventSent = false

		if now >= cooldownUntil then
			local r, g, b = colorCircle[1], colorCircle[2], colorCircle[3]
			local speed = 5

			g = math.min(g + speed, 255)
			b = math.min(b + speed, 255)

			colorCircle = {255, g, b}

			local angleRecoverSpeed = 2
			circleAngle = math.min(circleAngle + angleRecoverSpeed, 360)
		end
	end

	dxDrawCircle(sx/2, sy/2, 50 * scaleValue, 0, 360, tocolor(0, 0, 0, 255))
	dxDrawCircle(sx/2, sy/2, 50 * scaleValue, 0, circleAngle, tocolor(colorCircle[1], colorCircle[2], colorCircle[3]))
end


setDevelopmentMode(true)
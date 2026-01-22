local DGS = exports.dgs
local casinoGui = {}
local offset = 50
local slotBoxSize = 64         -- rozmiar jednego boxa
local slotHeight = 64          -- wysokość slotu
local slotVisibleBoxes = 8     -- ile boxów widać w oknie
local slotWidth = slotBoxSize * slotVisibleBoxes  -- szerokość widocznego obszaru
local slotSpeed = 150          -- px/s

local slotColors = {
    tocolor(255,0,0,255),   -- czerwony
    tocolor(0,255,0,255),   -- zielony
    tocolor(0,0,0,255),     -- czarny
}

local slotOffset = 0
local lastTick = getTickCount()
local slotRunning = false
local stopping = false
local currentSpeed = 0
local targetOffset = 0

local centerShift = slotBoxSize / 2  

-- Timer do odliczania sekund
local drawInterval = 60       
local nextDrawTime = 0      
-- Parametry slotu

-- Pozycja slotu
local slotAreaX = 0
local slotAreaY = 1 + offset
local totalBoxes = 17 
local slotRects = {}

function createInterface()
	casinoGui.material = DGS:dgsCreate3DInterface(1117.2126953125,7.1833984375,1002.0859375, 6, 6, 512, 512, tocolor(255, 255, 255, 255), 90, 1, 0)
	DGS:dgs3DSetDimension(casinoGui.material, 12)
	DGS:dgs3DSetInterior(casinoGui.material, 12)
	casinoGui.window = DGS:dgsCreateWindow(0, 0, 512, 512, "Kasyno", false, nil, nil, nil, nil, nil, nil, nil, true, material)
	DGS:dgsSetProperty(casinoGui.window, "image", DGS:dgsCreateRoundRect({ {0,false}, {0,false}, {0,false}, {0,false} }, tocolor(255, 255, 255, 255)))
	DGS:dgsSetProperty(casinoGui.window, "sizable", false)
	DGS:dgsSetProperty(casinoGui.window, "movable", false)
	DGS:dgsSetParent(casinoGui.window, casinoGui.material)
	casinoGui.balance = DGS:dgsCreateLabel(25, 80 + offset, 200, 20, "Stan konta: ", false, casinoGui.window)
	DGS:dgsSetProperty(casinoGui.balance, "textColor", tocolor(0, 0, 0, 255))
	casinoGui.edit = DGS:dgsCreateEdit(25, 100 + offset, 450, 25, "", false, casinoGui.window)
	casinoGui.secondsLabel = DGS:dgsCreateLabel(25, 130 + offset, 300, 20, "Następne losowanie za: 60 sekund", false, casinoGui.window)
	DGS:dgsSetProperty(casinoGui.secondsLabel, "textColor", tocolor(0, 0, 0, 255)) -- żółty tekst
local buttonStyles = {
    { x = 25, y = 150 + offset, color = tocolor(255, 0, 0, 255), color2 = tocolor(255, 0, 0, 200), color3 = tocolor(255, 0, 0, 100) },
    { x = 200, y = 150 + offset, color = tocolor(0, 255, 50, 255), color2 = tocolor(0, 255, 50, 200), color3 = tocolor(0, 255, 50, 100) },
    { x = 380, y = 150 + offset, color = tocolor(0, 0, 0, 255), color2 = tocolor(0, 0, 0, 200), color3 = tocolor(0, 0, 0, 100) },
}

local buttonNames = {"Red", "Green", "Black"}

for i, style in ipairs(buttonStyles) do
    local btn = DGS:dgsCreateButton(style.x, style.y, 100, 30, buttonNames[i], false, casinoGui.window)
    local rect = DGS:dgsCreateRoundRect({ {5,false}, {5,false}, {5,false}, {5,false} }, style.color)
    local rect2 = DGS:dgsCreateRoundRect({ {5,false}, {5,false}, {5,false}, {5,false} }, style.color2)
    local rect3 = DGS:dgsCreateRoundRect({ {5,false}, {5,false}, {5,false}, {5,false} }, style.color3)
    DGS:dgsSetProperty(btn, "image", {rect, rect2, rect3})

    addEventHandler("onDgsMouseClickUp", btn, function(button, state)
        if button == "left" and state == "up" then
            if i == 1 then
                onPlayerBetRed()
            elseif i == 2 then
                onPlayerBetGreen()
            elseif i == 3 then
                onPlayerBetBlack()
            end
			setTimer(function()
            local money = exports.rp_login:getPlayerData(localPlayer, "money")
            DGS:dgsSetText(casinoGui.balance, "Stan konta: "..money.."$")
        end, 3000, 1)
        end
    end, false)
end
casinoGui.slotBackground = DGS:dgsCreateImage(slotAreaX, slotAreaY, slotWidth, slotHeight, nil, false, casinoGui.window, tocolor(220,220,220,180))
DGS:dgsSetProperty(casinoGui.slotBackground, "clip", true)

for i = 1, totalBoxes do
    local colorIndex = ((i - 1) % #slotColors) + 1
    local rect = DGS:dgsCreateImage((i-1)*slotBoxSize, 0, slotBoxSize, slotHeight, nil, false, casinoGui.slotBackground, slotColors[colorIndex])
    slotRects[#slotRects+1] = rect
end
local centerLineX = slotWidth / 2 - 32
local centerLine = DGS:dgsCreateImage(centerLineX - 1, 0, 2, slotHeight, nil, false, casinoGui.slotBackground, tocolor(255, 255, 0, 255))
addEventHandler("onClientRender", root, renderSlots)
end




function renderSlots()
 local now = getTickCount()

    -- Odświeżanie slotu
    if slotRunning then
        local deltaTime = (now - lastTick) / 1000
        lastTick = now

        slotOffset = (slotOffset + currentSpeed * deltaTime) % (totalBoxes * slotBoxSize)

        if stopping then
            local diff = math.abs(slotOffset - targetOffset)
            if diff > (totalBoxes * slotBoxSize / 2) then
                diff = (totalBoxes * slotBoxSize) - diff
            end

            if diff < 5 then
                slotOffset = targetOffset
                slotRunning = false
                stopping = false
                currentSpeed = 0
            else
                currentSpeed = math.max(currentSpeed - 500 * deltaTime, 50)
            end
        end

        for i, rect in ipairs(slotRects) do
            local xPos = ((i-1) * slotBoxSize) - slotOffset - centerShift
            if xPos < -slotBoxSize then
                xPos = xPos + (totalBoxes * slotBoxSize)
            end
            DGS:dgsSetPosition(rect, xPos, 0, false)
        end
    else
        lastTick = now
    end

    -- Odliczanie sekund do następnego losowania
    if nextDrawTime > 0 then
        local remaining = math.max(0, math.floor((nextDrawTime - now) / 1000))
        DGS:dgsSetText(casinoGui.secondsLabel, "Następne losowanie za: " .. remaining .. " sekund")
        if remaining <= 0 then
            nextDrawTime = 0
            DGS:dgsSetText(casinoGui.secondsLabel, "Trwa losowanie!")
        end
    else
        DGS:dgsSetText(casinoGui.secondsLabel, "Oczekiwanie na losowanie...")
    end
end



function onPlayerBetRed()
    local betAmount = tonumber(DGS:dgsGetText(casinoGui.edit)) or 0
	if not betAmount or betAmount == 0 then return end
    triggerServerEvent("playerBet", localPlayer, "czerwone", betAmount)
end

function onPlayerBetGreen()
    local betAmount = tonumber(DGS:dgsGetText(casinoGui.edit)) or 0
    triggerServerEvent("playerBet", localPlayer, "zielone", betAmount)
end

function onPlayerBetBlack()
    local betAmount = tonumber(DGS:dgsGetText(casinoGui.edit)) or 0
    triggerServerEvent("playerBet", localPlayer, "czarne", betAmount)
end


-- === SLOT MACHINE (POZIOMA) ===

-- Tło slotu


-- Żółta linia pośrodku slotu


-- Efekt nieskończonej taśmy w PRAWO
  

function startSlot()
    slotRunning = true
    stopping = false
    currentSpeed = slotSpeed
end





function startCountDown(time)
    nextDrawTime = getTickCount() + time
end
function casinoState(state)
	if state then
		createInterface()
	else
		destroyCasinoGUI()
	end
end
addEvent("casinoState", true)
addEventHandler("casinoState", root, casinoState)

addEvent("onPlayerUpdateTimeCasino", true)
addEventHandler("onPlayerUpdateTimeCasino", root, function(time, moneyc)
	if not isElement(casinoGui.material) then return end
	if moneyc then return
		DGS:dgsSetText(casinoGui.balance, "Stan konta: "..moneyc.."$")
	end
	startCountDown(time)
	local money = exports.rp_login:getPlayerData(localPlayer, "money")
	if not money then return end
	DGS:dgsSetText(casinoGui.balance, "Stan konta: "..money.."$")

end)
addEvent("startSlotMachine", true)
addEventHandler("startSlotMachine", root, function(wynik)
	if not isElement(casinoGui.material) then return end
    startSlot()
    setTimer(function()
        stopSlotOnResult(wynik)
        setTimer(function()
            local money = exports.rp_login:getPlayerData(localPlayer, "money")
            DGS:dgsSetText(casinoGui.balance, "Stan konta: "..money.."$")
        end, 3000, 1)
    end, 3000, 1)
end)

function stopSlotOnResult(wynik)
    local targetColor
    if wynik == "red" then
        targetColor = tocolor(255,0,0,255)
    elseif wynik == "green" then
        targetColor = tocolor(0,255,0,255)
    elseif wynik == "black" then
        targetColor = tocolor(0,0,0,255)
    end

    local targetIndex = nil
    for i, rect in ipairs(slotRects) do
        local color = DGS:dgsGetProperty(rect, "color")
        if color == targetColor then
            targetIndex = i
            break
        end
    end

    if targetIndex then
        targetOffset = ((targetIndex - 1) * slotBoxSize) - centerShift
        targetOffset = (targetOffset + (totalBoxes * slotBoxSize)) % (totalBoxes * slotBoxSize)
        stopping = true
		startCountDown(60000)
    end
end


-- createInterface()

function destroyCasinoGUI()
    if isElement(casinoGui.material) then destroyElement(casinoGui.material) end
    removeEventHandler("onClientRender", root, renderSlots)
end


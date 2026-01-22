DGS = exports.dgs


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

local boxes = {}
local fontHeight = dxGetFontHeight(1, "default-bold")

local fadeDuration = 1000 -- czas trwania zanikania w ms
local moveDuration = 300 -- czas trwania przesuwania w ms

function createBox(info)
    local width, height = calculateHeight(info)
	local blurBox = DGS:dgsCreateBlurBox( width, height)
	local blurBoxRectangle = DGS:dgsCreateImage(-300,0,width,height,blurBox,false)
	-- DGS:dgsSetAlpha(blurBoxRectangle, 0)
	-- DGS:dgsAttachToAutoDestroy(blurBox)
    table.insert(boxes, {
        txt = info,
        startTime = getTickCount(),
        endTime = getTickCount() + 6000,
        fading = false,
        fadeStart = 0,
        targetOffset = 0,
        currentOffset = 0,
        moveStart = getTickCount(),
        width = width,
        height = height,
		blurBox = blurBox,
		blurBoxRectangle = blurBoxRectangle
    })
    local sound = playSound("sound.mp3")
    outputConsole("[NOTI] " .. info)
end
addEvent("onPlayerGotNotification", true)
addEventHandler("onPlayerGotNotification", root, createBox)
function insertBox(cmand, text)
    createBox(generateRandomString())
end

-- addCommandHandler("box", insertBox, false, false)

local offSetX, offsetY = exports.rp_scale:returnOffsetXY()
local scaleValue = exports.rp_scale:returnScaleValue()


function calculateHeight(text)
    local reasonWidth = dxGetTextWidth(text, 1, "default-bold")
    local newHeight = fontHeight * ((reasonWidth + 370 * scaleValue - 1) / (370 * scaleValue))
    
    if reasonWidth > 370 * scaleValue then
        reasonWidth = 370 * scaleValue
        _, newHeight = dxGetTextSize(text, reasonWidth, 1, "default-bold", true)
	else 
	
    end
    
    local width, height = math.floor(reasonWidth) + 5 * scaleValue, newHeight + 5 * scaleValue
    
    return width, height
end

function updateOffsets()
    local now = getTickCount()
    local offset = 0
    
    for _, v in ipairs(boxes) do
        v.targetOffset = offset
        offset = offset + v.height + 2
    end
    
    for _, v in ipairs(boxes) do
        local moveElapsed = now - v.moveStart
        local moveProgress = math.min(moveElapsed / moveDuration, 1)
        v.currentOffset = v.currentOffset + (v.targetOffset - v.currentOffset) * moveProgress
        
        if moveProgress == 1 then
            v.moveStart = now -- restart moveStart for the next update
        end
    end
end

function renderBoxes()
    local now = getTickCount()
local startX, startY = exports.rp_scale:getScreenStartPositionFromBox(270 * scaleValue, 220 * scaleValue, offSetX, offsetY, "left", "bottom")

    startX = startX - 30 * scaleValue
    updateOffsets()

    for k, v in ipairs(boxes) do
        local elapsedTime = now - v.startTime
        local text = v.txt
        local alpha = 255
        
        if now > v.endTime then
            if not v.fading then
                v.fading = true
                v.fadeStart = now
            end
            
            local fadeElapsed = now - v.fadeStart
            local fadeProgress = fadeElapsed / fadeDuration
            alpha = 255 * (1 - fadeProgress)
            
            if fadeProgress >= 1 then
                if isElement(v.blurBoxRectangle) then
                    destroyElement(v.blurBoxRectangle)
					destroyElement(v.blurBox)
                end
                table.remove(boxes, k)
            end
        end

        local newY = startY - v.currentOffset - v.height
        if v.lastY == nil or math.abs(newY - v.lastY) > 1 then  -- Próg tolerancji (1px)
            if isElement(v.blurBoxRectangle) then
                DGS:dgsSetPosition(v.blurBoxRectangle, startX, newY)
            end
            v.lastY = newY
        end
		dxDrawRectangle(startX, newY, v.width, v.height, tocolor(0, 0, 0, 200 * (alpha / 255)))
		-- dxDrawRectangle(startX, startY - v.currentOffset - v.height, v.width + 5 * scaleValue, v.height, tocolor(0, 0, 0, 200 * (alpha / 255)))
        dxDrawText(text,startX + 2 * scaleValue,newY + 2 * scaleValue,startX + 370 * scaleValue - 5 * scaleValue,newY + v.height - 2 * scaleValue,tocolor(255, 255, 255, alpha),1,"default-bold","left","top",false,true,true)
    end
end

addEventHandler("onClientRender", root, renderBoxes)


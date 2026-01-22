dxGui = {}

function createToolTip(x, y, text, font, scale, padding, margin)
    scale = scale or 1.0
    padding = padding or 5
    margin = margin or 5
    local textWidth = dxGetTextWidth(text, scale, font)
    local textHeight = dxGetFontHeight(scale, font)
    local totalWidth = textWidth + (padding * 2) + (margin * 2)
    local totalHeight = textHeight + (padding * 2) + (margin * 2)
    x = x-totalWidth
    y = y-totalHeight/2
    dxDrawRectangle(x, y, totalWidth, totalHeight, tocolor(0, 0, 0, 200), true)
    dxDrawText(text, x + margin + padding, y + margin + padding, x + totalWidth - margin - padding, y + totalHeight - margin - padding, tocolor(255, 255, 255, 255), scale, font, "center", "center", false, false, true)
end

--[[
	- Scaled version for all screen resolutions
	- Multiple rectangles
]]

screenX, screenY = guiGetScreenSize()

function getScreenStartPositionFromBox (width, height, offsetX, offsetY, startIndicationX, startIndicationY)

    if type(width) ~= "number" then
        width = 0
    end
    
    if type(height) ~= "number" then
        height = 0
    end
    
    if type(offsetX) ~= "number" then
        offsetX = 0
    end
    
    if type(offsetY) ~= "number" then
        offsetY = 0
    end
    
    local startX = offsetX 
    local startY = offsetY
    
    if startIndicationX == "right" then
        startX = screenX - (width + offsetX)
    elseif startIndicationX == "center" then
        startX = screenX / 2 - width / 2 + offsetX
    end
    
    if startIndicationY == "bottom" then
        startY = screenY - (height + offsetY)
    elseif startIndicationY == "center" then
        startY = screenY / 2 - height / 2 + offsetY
    end
    
    return startX, startY
end

--[[
	Prepare the scale multiplier:
]]
-- Your resolution as developer.
local devScreenX = 1920
local devScreenY = 1080

-- Get the scale value
local scaleValue = screenY / devScreenY

-- Set an upper limit, so that it isn't scaled too small.
scaleValue = math.max(scaleValue, 0.65)

local axisMoveImages = {
    dxCreateTexture('images/movex.png', _, true, "clamp"),
    dxCreateTexture('images/movey.png', _, true, "clamp"),
    dxCreateTexture('images/movez.png', _, true, "clamp")
}

local axisRotateImages = {
    dxCreateTexture('images/rotx.png', _, true, "clamp"),
    dxCreateTexture('images/roty.png', _, true, "clamp"),
    dxCreateTexture('images/rotz.png', _, true, "clamp")
}

local axisScaleImages = {
    dxCreateTexture('images/scalex.png', _, true, "clamp"),
    dxCreateTexture('images/scaley.png', _, true, "clamp"),
    dxCreateTexture('images/scalez.png', _, true, "clamp")
}

local axisButtonsLocations = {}

local background = dxCreateTexture('images/background.png')

function extendLineToScreenEdges(Xsx1, Xsy1, Xsx2, Xsy2)
    -- Given points
    local x1, y1 = Xsx1, Xsy1 -- Center of the screen
    local x2, y2 = Xsx2, Xsy2 -- Target point

    -- Calculate slope (m)
    local m = (y2 - y1) / (x2 - x1)

    -- Calculate y-intercept (b)
    local b = y1 - m * x1

    -- Calculate intersection points
    local topX = -b / m
    local bottomX = (1080 - b) / m
    local leftY = b
    local rightY = m * 1920 + b

    -- -- Print the results
    -- print("Intersection point with top edge:", topX, 0)
    -- print("Intersection point with bottom edge:", bottomX, 1080)

    -- print("Intersection point with left edge:", 0, leftY)
    -- print("Intersection point with right edge:", 1920, rightY)

    local startX, startY, endX, endY
    if topX >= 0 and topX <= 1920 then
        startX, startY, endX, endY = topX, 0, bottomX, 1080
    else
        startX, startY, endX, endY = 0, leftY, 1920, rightY
    end
    return startX, startY, endX, endY
end

cursorX1, cursorY1 = getCursorPosition()
cursorX1, cursorY1 = cursorX1 * screenX, cursorY1 * screenY

function closerToPoint(cursorX1, cursorX2, cursorY1, cursorY2, startPointX, startPointY, targetPointX, targetPointY, xstrenf, ystrenf)
    local distanceToX1 = math.abs(targetPointX - cursorX1)
    local distanceToX2 = math.abs(targetPointX - cursorX2)

    local distanceToY1 = math.abs(targetPointY - cursorY1)
    local distanceToY2 = math.abs(targetPointY - cursorY2)

    local xv, yv

    xv = -(cursorX2 - cursorX1)/1920
    if targetPointX - startPointX > 0 then -- wartosc dodatnia
        xv = -xv
    elseif targetPointX - startPointX < 0 then
        xv = xv
    end

    yv = -(cursorY2 - cursorY1)/1920
    if targetPointY - startPointY > 0 then -- wartosc ujemna
        yv = yv
    elseif targetPointY - startPointY < 0 then
        yv = -yv
    end

    return xv * xstrenf, yv * ystrenf

end

local posSensivity = 5
local rotSensivity = 200
local scaleSensivity = 1

function dxGui.drawAxisLines()
    if selectedElement ~= nil and editMode then

        local x, y, z = getElementPosition(selectedElement)
        local radius = getElementRadius(selectedElement)
        -- X axis
        local startX = x - radius
        local endX = x + radius
        local Xsx1, Xsy1 = getScreenFromWorldPosition (startX, y, z, 1000, false)
        local Xsx2, Xsy2 = getScreenFromWorldPosition (endX, y, z, 1000, false)


        -- Y axis
        local startY = y - radius
        local endY = y + radius
        local Ysx1, Ysy1 = getScreenFromWorldPosition (x, startY, z, 1000, false)
        local Ysx2, Ysy2 = getScreenFromWorldPosition (x, endY, z, 1000, false)
        -- Z axis
        local startZ = z - radius
        local endZ = z + radius
        local Zsx1, Zsy1 = getScreenFromWorldPosition (x, y, startZ, 1000, false)
        local Zsx2, Zsy2 = getScreenFromWorldPosition (x, y, endZ, 1000, false)

        local buttonsPosition = {
            {Xsx2, Xsy2, Xsx1, Xsy1, tocolor(51,153,255)},
            {Ysx2, Ysy2, Ysx1, Ysy1, tocolor(153,0,0)},
            {Zsx2, Zsy2, Zsx1, Zsy1, tocolor(0,102,0)}
        }

        if Xsx1 and Xsy2 and Ysx1 and Ysy2 and Zsx1 and Zsy2 then
            -- tworzenie osi
            dxDrawLine (Zsx1, Zsy1, Zsx2, Zsy2, tocolor(0,102,0), 1)
            dxDrawLine (Ysx1, Ysy1, Ysx2, Ysy2, tocolor(153,0,0), 1)
            dxDrawLine (Xsx1, Xsy1, Xsx2, Xsy2, tocolor(51,153,255), 1)

            local imagesTable
            if editorMode[1] then
                imagesTable = axisMoveImages
            elseif editorMode[2] then
                imagesTable = axisRotateImages
            else
                imagesTable = axisScaleImages
            end

            local weidth, heigth = 45 * scaleValue, 45 * scaleValue
            local xOffset = 18 * scaleValue
            local yOffset = 19 * scaleValue
            for i, v in ipairs(imagesTable) do
                local bx, by = buttonsPosition[i][1], buttonsPosition[i][2]
                
                if #axisButtonsLocations < #imagesTable then
                    table.insert(axisButtonsLocations, {(bx - xOffset), (by - yOffset), weidth, heigth, false})
                end

                if canXYZ[i] then
                    sx1, sy1, sx2, sy2 = extendLineToScreenEdges(buttonsPosition[i][3], buttonsPosition[i][4], buttonsPosition[i][1], buttonsPosition[i][2])

                    local xstrenf, ystrenf = (math.abs(sx2 - sx1)/1920), (math.abs(sy2 - sy1)/1080),

                    dxDrawLine (sx1, sy1, sx2, sy2, buttonsPosition[i][5], 1)

                    dxDrawImage ( bx - xOffset, by - yOffset, weidth, heigth, background, 0, 0, 0, tocolor(255,0,0,255), false )

                    local cursorX2, cursorY2 = getCursorPosition()
                    cursorX2, cursorY2 = cursorX2 * screenX, cursorY2 * screenY

                    local valx, valy = closerToPoint(cursorX1, cursorX2, cursorY1, cursorY2, sx1, sy1, sx2, sy2, xstrenf, ystrenf)

                    local face_lr, face_fb = cameraCalc.getPlayerFace()

                    local x, y, z
                    local sensivity

                    if editorMode[1] then
                        sensivity = posSensivity
                        x, y, z = getElementPosition(selectedElement)
                    elseif editorMode[2] then
                        sensivity = rotSensivity
                        x, y, z = getElementRotation(selectedElement)
                    else
                        sensivity = scaleSensivity
                        x, y, z = getObjectScale(selectedElement)
                    end

                    if canXYZ[1] then
                        if sy1 == 0 then
                            if face_lr == "left" then
                                valx = valx
                                valy = -valy
                            end
                        else
                            if face_fb == "back" then
                                valx = -valx
                                valy = valy 
                            end
                        end
                        x = x + (valx + valy) * sensivity
                    elseif canXYZ[2] then
                        if sy1 == 0 then
                            if face_fb == "front" then
                                valx = -valx
                                valy = valy 
                            else
                                valy = -valy
                            end
                        else
                            if face_lr == "right" then
                                valx = -valx 
                                valy = valy 
                            end
                        end
                        y = y + (valx + valy) * sensivity
                    else
                        z = z + (valx + valy) * sensivity * 2
                    end

                    if editorMode[1] then
                        setElementPosition(selectedElement, x, y, z)
                    elseif editorMode[2] then
                        setElementRotation(selectedElement, x, y, z)
                    else
                        setObjectScale(selectedElement, x, y, z)
                    end

                    cursorX1, cursorY1 = cursorX2, cursorY2
                elseif axisButtonsLocations[i][5] then
                    dxDrawImage ( bx - xOffset, by - yOffset, weidth, heigth, background, 0, 0, 0, tocolor(0,0,0,255), false )
                else
                    dxDrawImage ( bx - xOffset, by - yOffset, weidth, heigth, background)
                end

                dxDrawImage ( bx - xOffset, by - yOffset, weidth, heigth, v, 0, 0, 0, _, false )

                axisButtonsLocations[i][1] = (bx - xOffset)
                axisButtonsLocations[i][2] = (by - yOffset)
                axisButtonsLocations[i][3] = weidth
                axisButtonsLocations[i][4] = heigth
            end

            for i, v in ipairs(axisButtonsLocations) do
                v[5] = utility.isMouseInPosition(v[1], v[2], v[3], v[4])
            end

            isInX = axisButtonsLocations[1][5]
            isInY = axisButtonsLocations[2][5] and isInX == false
            isInZ = axisButtonsLocations[3][5] and isInX == false and isInY == false
        end
    end
end

buttonsLocations = {} -- 1. move, 2. rotate 3. scale 4. undo 5. redo 6. clone 7. properties 8. save 9. remove 10. cancel

function dxGui.drawVerticalGui(imagesTable, pixelsBetween, width, heigth, startIndicationX, startIndicationY, startOffset)
    if editMode then
            -- Scale the dimensions:
        local rectangleWidth, rectangleHeight = width * scaleValue, heigth * scaleValue 
        local offSetX, offsetY = startOffset * scaleValue, 50 * scaleValue
        pixelsBetween = pixelsBetween * scaleValue

        local curX, curY = getCursorPosition ()
        -- Start drawing at the correct position:
        local startX, startY
        for i, v in ipairs(imagesTable) do
            startX, startY = getScreenStartPositionFromBox(rectangleWidth, rectangleHeight, offSetX, offsetY, startIndicationX, startIndicationY)

            if #buttonsLocations < #imagesTable then
                table.insert(buttonsLocations, {startX, startY, rectangleWidth, rectangleHeight, false})
            end

            --dxDrawImage ( startX, startY, rectangleWidth, rectangleHeight, background, 0, 0, 0, _, false )
            if buttonsLocations[i][5] == true and getKeyState("mouse1") or editorMode[i] == true then
                dxDrawImage ( startX, startY, rectangleWidth, rectangleHeight, background, 0, 0, 0, tocolor(255,0,0,255), false )
            elseif buttonsLocations[i][5] == true then
                --createToolTip(screenX * curX, screenY * curY, "Tool tip text", "default-bold", 1.0, 5, 5)
                dxDrawImage ( startX, startY, rectangleWidth, rectangleHeight, background, 0, 0, 0, tocolor(0,0,0,255), false )
            else
                dxDrawImage ( startX, startY, rectangleWidth, rectangleHeight, background, 0, 0, 0, _, false )
            end

            if buttonsLocations[i][5] == true then
                createToolTip(screenX * curX, screenY * curY, tostring(v[2]), "default-bold", 1.0, 2.5 * scaleValue, 2.5 * scaleValue)
            end

            dxDrawImage ( startX + (3.75 * scaleValue), startY + (3.75 * scaleValue), rectangleWidth - (7.5 * scaleValue), rectangleHeight - (7.5 * scaleValue), v[1], 0, 0, 0, _, false )

            offSetX = (offSetX + rectangleWidth + pixelsBetween) * scaleValue
        end

        for i, v in ipairs(buttonsLocations) do
            v[5] = utility.isMouseInPosition(v[1], v[2], v[3], v[4])
        end
    end
end
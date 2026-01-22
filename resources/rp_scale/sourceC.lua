local screenX, screenY = guiGetScreenSize()
local devScreenX = 1920
local devScreenY = 1080
local scaleValue = screenY / devScreenY

-- scaleValue = math.max(scaleValue, 0.65)
scaleValue = math.min(2, 1920/screenX)


local offSetX, offsetY = 50 * scaleValue, 50 * scaleValue

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
function returnOffsetXY()
return offSetX, offsetY
end
function returnScaleValue()
return scaleValue
end

local getOffsetX, getOffsetY = returnOffsetXY()
local huj = returnScaleValue()
--tutorial

-- export function to your resource -- local getScreenStartPositionFromBox = exports.tactic_scale:getScreenStartPositionFromBox  local offSetX, offsetY = exports.tactic_scale:returnOffsetXY




local rotX, rotY, rotRadius, maxRadius = 0, -math.pi/2, 10, 20 
local isCustomCamera = false 
local cameraTarget = nil 
local sX, sY = guiGetScreenSize() 
local addedEventHandler = false

function renderCustomCamera()
    if isCustomCamera and isElement(cameraTarget) then
        local x, y, z = getElementPosition(cameraTarget)
        local cx, cy, cz

        cx = x + rotRadius * math.sin(rotY) * math.cos(rotX)
        cy = y + rotRadius * math.sin(rotY) * math.sin(rotX)
        cz = z + rotRadius * math.cos(rotY)

        local hit, hitX, hitY, hitZ = processLineOfSight(x, y, z, cx, cy, cz, _, false, _, _, _, _, _, _, cameraTarget)
        if hit then
            cx, cy, cz = hitX, hitY, hitZ
        end

        setCameraMatrix(cx, cy, cz, x, y, z)
    end
end


function customCameraKey(button)
    if button == "mouse_wheel_up" then
        rotRadius = math.max(2, rotRadius - 1)
    elseif button == "mouse_wheel_down" then
        rotRadius = math.min(maxRadius, rotRadius + 1)
    end
end

function customCursorMove(cX, cY, aX, aY)
    if isCursorShowing() or isMTAWindowActive() then
        return
    end

    aX = aX - sX / 2
    aY = aY - sY / 2

	rotX = rotX - aX * 0.01745 * 0.10
	rotY = math.min(-0.02, math.max(rotY + aY * 0.01745 * 0.10, -3.11))
end

function setCustomCameraTarget(element)
    if isElement(element) then
        cameraTarget = element
        isCustomCamera = true
		if not addedEventHandler then
		addEventHandler("onClientCursorMove", root, customCursorMove)
		addEventHandler("onClientKey", root, customCameraKey)
		addEventHandler("onClientPreRender", root, renderCustomCamera)
		addedEventHandler = true
		end
        return true
    else
		removeEventHandler("onClientCursorMove", root, customCursorMove)
		removeEventHandler("onClientKey", root, customCameraKey)
		removeEventHandler("onClientPreRender", root, renderCustomCamera)
		addedEventHandler = false
        cameraTarget = nil
        isCustomCamera = false
    end
end

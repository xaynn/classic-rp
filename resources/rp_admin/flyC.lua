local flyState = false
local speed = {horizontal = 3, vertical = 1}
local pos = {}

function noclipRender()

	if isPedDead(localPlayer) or getCameraTarget() ~= localPlayer or getPedOccupiedVehicle(localPlayer) then
		removeEventHandler("onClientRender", root, noclipRender)
		flyState = false
		return
	end
	
	local _, _, camera_rotation = getElementRotation(getCamera())
	
	if not isMTAWindowActive() and not isCursorShowing() then 
		if getKeyState("w") then
			setElementPosition(localPlayer, 
				pos[1]+math.sin(math.rad((getKeyState("d") and 45-camera_rotation) or (getKeyState("a") and -45-camera_rotation) or -camera_rotation))*speed.horizontal,
				pos[2]+math.cos(math.rad((getKeyState("d") and 45-camera_rotation) or (getKeyState("a") and -45-camera_rotation) or -camera_rotation))*speed.horizontal,
				(getKeyState("space") and pos[3]+speed.vertical) or (getKeyState("lshift") and pos[3]-speed.vertical) or pos[3]
			)
			
		elseif getKeyState("s") then
			setElementPosition(localPlayer, 
				pos[1]-math.sin(math.rad((getKeyState("d") and -45-camera_rotation) or (getKeyState("a") and 45-camera_rotation) or -camera_rotation))*speed.horizontal,
				pos[2]-math.cos(math.rad((getKeyState("d") and -45-camera_rotation) or (getKeyState("a") and 45-camera_rotation) or -camera_rotation))*speed.horizontal,
				(getKeyState("space") and pos[3]+speed.vertical) or (getKeyState("lshift") and pos[3]-speed.vertical) or pos[3]
			)
			
		elseif getKeyState("d") then
			setElementPosition(localPlayer, 
				pos[1]+math.sin(math.rad(90-camera_rotation))*speed.horizontal,
				pos[2]+math.cos(math.rad(90-camera_rotation))*speed.horizontal,
				(getKeyState("space") and pos[3]+speed.vertical) or (getKeyState("lshift") and pos[3]-speed.vertical) or pos[3]
			)
			
		elseif getKeyState("a") then
			setElementPosition(localPlayer, 
				pos[1]-math.sin(math.rad(90-camera_rotation))*speed.horizontal,
				pos[2]-math.cos(math.rad(90-camera_rotation))*speed.horizontal,
				(getKeyState("space") and pos[3]+speed.vertical) or (getKeyState("lshift") and pos[3]-speed.vertical) or pos[3]
			)
			
		elseif getKeyState("space") then
			setElementPosition(localPlayer, pos[1], pos[2], pos[3]+speed.vertical)
			
		elseif getKeyState("lshift") then
			setElementPosition(localPlayer, pos[1], pos[2], pos[3]-speed.vertical)
		else
			setElementPosition(localPlayer, pos[1], pos[2], pos[3])
		end
	else
		setElementPosition(localPlayer, pos[1], pos[2], pos[3]) 
	end
	setElementRotation(localPlayer, 0, 0, -camera_rotation)
	
	pos = {getElementPosition(localPlayer)} 
end

function toggleFly(state)
    flyState = not flyState
    if flyState then
		pos = {getElementPosition(localPlayer)}
        addEventHandler("onClientRender", root, noclipRender)
    else
        removeEventHandler("onClientRender", root, noclipRender)
    end
end
addEvent("onPlayerToggleFly", true)
addEventHandler("onPlayerToggleFly", getRootElement(), toggleFly)
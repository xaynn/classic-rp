local markersVeh = {}

function onVehicleIndicatorUpdate(element, data, nowData)
	if not isElement(element) then return end
    local elementType = getElementType(element)
    if elementType == "vehicle" and isElementStreamedIn(element) then
        local posX, posY, posZ = getVehicleComponentPosition(element, "wheel_lb_dummy")
		local posXLeft, posYLeft, posZLeft = getVehicleComponentPosition(element, "wheel_lf_dummy")
		
        if data == "indicator[" and nowData == true then
            local leftMarker = createMarker(posX, posY, posZ, "corona", 0.3, 255, 255, 0, 170)
            local leftMarkerBack = createMarker(posXLeft, posYLeft, posZLeft, "corona", 0.3, 255, 255, 0, 170)

            attachElements(leftMarkerBack, element, posX, posY - 0.6, posZ + 0.3)
            attachElements(leftMarker, element, posXLeft, posYLeft + 0.6, posZLeft + 0.3)

            markersVeh[element] = {leftMarker, leftMarkerBack}
        
		elseif data == "indicator]" and nowData == true then
            local posX, posY, posZ = getVehicleComponentPosition(element, "wheel_rf_dummy")
			local posXRight, posYRight, posZRight = getVehicleComponentPosition(element, "wheel_rb_dummy")
			
			local rightMarker = createMarker(posX, posY, posZ, "corona", 0.3, 255, 255, 0, 170)
			local rightMarkerBack = createMarker(posXRight, posYRight, posZRight, "corona", 0.3, 255, 255, 0, 170)

			attachElements(rightMarker, element, posX, posY + 0.6, posZ + 0.3)
			attachElements(rightMarkerBack, element, posXRight, posYRight - 0.6, posZRight + 0.3)

			markersVeh[element] = {rightMarker, rightMarkerBack}

		elseif data == "indicator;" and nowData == true then
			
			-- lewe
			
			
			 local posX, posY, posZ = getVehicleComponentPosition(element, "wheel_lb_dummy")
			local posXLeft, posYLeft, posZLeft = getVehicleComponentPosition(element, "wheel_lf_dummy")
		
		
            local leftMarker = createMarker(posX, posY - 0.6, posZ + 0.3, "corona", 0.3, 255, 255, 0, 170)
            local leftMarkerBack = createMarker(posXLeft, posYLeft, posZLeft, "corona", 0.3, 255, 255, 0, 170)

            attachElements(leftMarkerBack, element, posX, posY - 0.6, posZ + 0.3)
            attachElements(leftMarker, element, posXLeft, posYLeft + 0.6, posZLeft + 0.3)

			local posXR, posYR, posZR = getVehicleComponentPosition(element, "wheel_rf_dummy")
			local posXRight, posYRight, posZRight = getVehicleComponentPosition(element, "wheel_rb_dummy")
			local rightMarker = createMarker(posXR, posYR, posZR, "corona", 0.3, 255, 255, 0, 170)
			local rightMarkerBack = createMarker(posXRight, posYRight, posZRight, "corona", 0.3, 255, 255, 0, 170)

			attachElements(rightMarker, element, posXR, posYR + 0.6, posZR + 0.3)
			attachElements(rightMarkerBack, element, posXRight, posYRight - 0.6, posZRight + 0.3)

			markersVeh[element] = {leftMarker, leftMarkerBack, rightMarker, rightMarkerBack}
        
		elseif nowData == false then
            if markersVeh[element] then
                for _, marker in ipairs(markersVeh[element]) do
                    destroyElement(marker)
                end
                markersVeh[element] = nil 
            end
        end
    end
end

addEventHandler("onLocalDataSingleElementUpdate", root, onVehicleIndicatorUpdate)



addEventHandler("onClientElementDestroy", root, function()
	if getElementType(source) == "vehicle" then
		if markersVeh[source] then
                for _, marker in ipairs(markersVeh[source]) do
                    destroyElement(marker)
                end
                markersVeh[source] = nil 
	end
	end
end)

function getPositionInfrontOfElement(element, meters)
    if not element or not isElement(element) then
        return false
    end
    if not meters then
        meters = 3
    end
    local posX, posY, posZ = getElementPosition(element)
    local _, _, rotation = getElementRotation(element)
    posX = posX + math.sin(math.rad(rotation)) * meters
    posY = posY - math.cos(math.rad(rotation)) * meters
    return posX, posY, posZ
end

-- addEventHandler ( "onClientRender", root,
-- function()
	-- countTest = 0
	-- if isPedInVehicle ( localPlayer ) and getPedOccupiedVehicle ( localPlayer ) then
		-- local veh = getPedOccupiedVehicle ( localPlayer )
		-- for v in pairs ( getVehicleComponents(veh) ) do
			-- countTest = countTest + 1
			-- local x,y,z = getVehicleComponentPosition ( veh, v, "world" )
			-- local sx,sy = getScreenFromWorldPosition ( x, y, z )
			-- if sx and sy then
				-- dxDrawRectangle(sx,sy, 10, 10)
				-- dxDrawLine(sx, sy, sx - (100 + (countTest * 5)), sy-(200+ (countTest * 10)))
				-- dxDrawText ( v, (sx-(120 + (countTest * 5))) -1, (sy-(220 + (countTest * 10))) -1, 0 -1, 0 -1, tocolor(0,0,0), 1, "default-bold" )
				-- dxDrawText ( v, (sx-(120 + (countTest * 5))) +1, (sy-(220 + (countTest * 10))) -1, 0 +1, 0 -1, tocolor(0,0,0), 1, "default-bold" )
				-- dxDrawText ( v, (sx-(120 + (countTest * 5))) -1, (sy-(220 + (countTest * 10))) +1, 0 -1, 0 +1, tocolor(0,0,0), 1, "default-bold" )
				-- dxDrawText ( v, (sx-(120 + (countTest * 5))) +1, (sy-(220 + (countTest * 10))) +1, 0 +1, 0 +1, tocolor(0,0,0), 1, "default-bold" )
				-- dxDrawText ( v, (sx-(120 + (countTest * 5))), (sy-(220 + (countTest * 10))), 0, 0, tocolor(0,255,255), 1, "default-bold" )
			-- end
		-- end
	-- end
-- end)
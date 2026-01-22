local alpr = {}
local pdVehicles = { [598]=true, [596]=true, [597]=true, [599]=true }
local seats = {[0]=true, [1]=true}
local scaleValue = exports.rp_scale:returnScaleValue()
local offSetX, offsetY = exports.rp_scale:returnOffsetXY()
engineSetAsynchronousLoading( true, true ) -- dotestu
alpr.drawX, alpr.drawY = 291 * scaleValue, 400 * scaleValue
alpr.startX, alpr.startY = exports.rp_scale:getScreenStartPositionFromBox(alpr.drawX, alpr.drawY,offSetX, 0, "right", "center")
alpr.showedGui = false
alpr.font = dxCreateFont("files/font.ttf", 18 * scaleValue, false, "proof")
alpr.header = dxCreateFont("files/font.ttf", 23 * scaleValue, false, "proof")
alpr.header2 = dxCreateFont("files/font.ttf", 10 * scaleValue, false, "proof")
alpr.gui = dxCreateTexture("files/gui.png", "argb", true, "clamp", "2d")
alpr.model = "Brak"
alpr.speed = 0
alpr.speedmax = 0
alpr.plate = "Brak"
alpr.owner = "Brak"


function alpr.Enable()
    if not alpr.showedGui then
	    addEventHandler("onClientRender", root, alpr.render)
	else
		removeEventHandler("onClientRender", root, alpr.render)

	end
   alpr.showedGui = not alpr.showedGui
end
bindKey( "\\", "up", alpr.Enable )

function getVehicleSpeed(veh)
    if isPedInVehicle(localPlayer) and veh then
        local vx, vy, vz = getElementVelocity(veh)
		local calculate = math.sqrt(vx^2 + vy^2 + vz^2) * 187.5
		if calculate == 0 then return false else return math.sqrt(vx^2 + vy^2 + vz^2) * 187.5 end
    end
end

-- function getVehicleOwner(veh)
-- local vehicleOwner = getElementData(veh,"vehOwnerName")
-- if not vehicleOwner then vehicleOwner = "Brak" end
-- return vehicleOwner
-- end

function vehicleElementName(vehicle)
	local vehicleData = exports.rp_newmodels:getElementModel(vehicle)
	local vehicleName = exports.rp_newmodels:getCustomModelName(vehicleData) or getVehicleNameFromModel(vehicleData)
	return vehicleName
end

function alpr.render()
   local veh = getPedOccupiedVehicle(localPlayer)
   if veh and getVehicleEngineState(veh) then
      if alpr.showedGui and ((not exports.rp_login:getObjectData(veh,"customPD")) and seats[getPedOccupiedVehicleSeat(localPlayer)] and pdVehicles[getElementModel(veh)] or exports.rp_login:getObjectData(veh,"customPD")) then
         local matrix = veh:getMatrix()

         local newMatrix = matrix:transformPosition(Vector3(0, 20, 0))
         local hit, hitX, hitY, hitZ, hitElement = processLineOfSight(matrix:getPosition(),newMatrix, true,true,false,true,true,false,false,false,veh,false,true)
         -- dxDrawLine3D(matrix:getPosition(), newMatrix, tocolor(255, 255, 255, 255))
         if hit then
            if isElement(hitElement) and hitElement:getType() == "vehicle" then
               if veh ~= hitElement then
                  local speed = getVehicleSpeed(hitElement)
                  if speed then
                     alpr.speedmax = speed
                     alpr.speed = speed
                  end
                  local modelName = vehicleElementName(hitElement)
                  if modelName then
                     alpr.model = modelName
                  else
                     alpr.model = "Brak"
                  end
                  local plate = getVehiclePlateText(hitElement)
                  if plate then
                     alpr.plate = plate
                  else
                     alpr.plate = "Brak"
                  end
                  -- local vehicleOwner = getElementData(veh,"vehOwnerName") -- funkcja do zrobienia.
                  -- if vehicleOwner then
                     -- alpr.owner = vehicleOwner
                  -- else
                     -- alpr.owner = "Brak"
                  -- end
               end
            end
         else
            alpr.speed = 0
         end
         dxDrawImage(alpr.startX,alpr.startY,alpr.drawX,alpr.drawY,alpr.gui,0,0,0,tocolor(255, 255, 255, 255),false)
         dxDrawText("ALPR:", alpr.startX + 17*scaleValue, alpr.startY + 10 *scaleValue, 100 * scaleValue, 100 *scaleValue,tocolor(255, 255, 255, 255),1,alpr.header,"left","top")
         dxDrawText("Model: "..alpr.model, alpr.startX + 20 *scaleValue, alpr.startY + 85 *scaleValue, 100 * scaleValue, 100 *scaleValue,tocolor(255, 255, 255, 255),1,alpr.font,"left","top")
         -- dxDrawText("Właściciel:", alpr.startX + 20 *scaleValue, alpr.startY + 120 *scaleValue, 100 * scaleValue, 100 *scaleValue,tocolor(255, 255, 255, 255),1,alpr.font,"left","top") --35
         -- dxDrawText(alpr.owner, alpr.startX + 140 *scaleValue, alpr.startY + 126 *scaleValue, 100 * scaleValue, 100 *scaleValue,tocolor(255, 255, 255, 255),1,alpr.header2,"left","top") --35
         dxDrawText("Rejestracja: "..alpr.plate, alpr.startX + 20 *scaleValue, alpr.startY + 155 *scaleValue, 100 * scaleValue, 100 *scaleValue,tocolor(255, 255, 255, 255),1,alpr.font,"left","top")
         dxDrawText("LIDAR: ", alpr.startX + 15 *scaleValue, alpr.startY + 230 *scaleValue, 100 * scaleValue, 100 *scaleValue,tocolor(255, 255, 255, 255),1,alpr.header,"left","top")
         dxDrawText("Prędkość: "..math.floor(alpr.speed), alpr.startX + 20 *scaleValue, alpr.startY + 305 *scaleValue, 100 * scaleValue, 100 *scaleValue,tocolor(255, 255, 255, 255),1,alpr.font,"left","top")
         dxDrawText("Prędkość max: "..math.floor(alpr.speedmax), alpr.startX + 20 *scaleValue, alpr.startY + 340 *scaleValue, 100 * scaleValue, 100 *scaleValue,tocolor(255, 255, 255, 255),1,alpr.font,"left","top")

      end
   end
end





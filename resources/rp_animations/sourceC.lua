local animations = {}
tableAnims = {}
local favoriteAnims = {}

-- v.block, v.anim, v.loop, v.updatePosition, v.customAnim, v.commandName, v.category
function animations.addFavoriteAnimToTable(nameAnim, block, anim, loop, updatePosition, customAnim, category, state)
   if state then
      local file = xmlLoadFile("files/savedAnims.xml")
      local nodeAnim = xmlFindChild(file, "savedAnims", 0)
      local json = toJSON(favoriteAnims)
      xmlNodeSetValue(nodeAnim, json)
      xmlSaveFile(file)
      xmlUnloadFile(file)
   else
      table.insert(favoriteAnims,{commandName =nameAnim, block =block, anim =anim, loop=loop,category="Ulubione",updatePosition=updatePosition,desc="fav",customAnim=customAnim,used=0,clicked=false,id = #tableAnims + 1, originalCategory = category })
      local file = xmlLoadFile("files/savedAnims.xml")
      local nodeAnim = xmlFindChild(file, "savedAnims", 0)
      local json = toJSON(favoriteAnims)
      xmlNodeSetValue(nodeAnim, json)
      xmlSaveFile(file)
      xmlUnloadFile(file)
   end
end




local scaleValue = exports.rp_scale:returnScaleValue()
local offSetX, offsetY = exports.rp_scale:returnOffsetXY()
animations.drawX, animations.drawY = 663 * scaleValue, 580 * scaleValue
animations.startX, animations.startY = exports.rp_scale:getScreenStartPositionFromBox(animations.drawX, animations.drawY, 0, 0, "center", "center")
animations.font = dxCreateFont("files/font.ttf", 20 * scaleValue, false, "proof")
animations.header = dxCreateFont("files/font.ttf", 15 * scaleValue, false, "proof")
animations.header2 = dxCreateFont("files/font.ttf", 10 * scaleValue, false, "proof")
animations.header3 = dxCreateFont("files/font.ttf", 13 * scaleValue, false, "proof")

animations.textInfoX, animations.textInfoY = exports.rp_scale:getScreenStartPositionFromBox(100*scaleValue, 100*scaleValue, 0, offsetY, "center", "bottom")

animations.currentCategory = "Stanie"


animations.updatePosition = false
animations.playerHasAnim = false
animations.showedGui = false

animations.currentCount = 0

function isPlayerHasEnabledAnimationsGUI()
   return animations.showedGui
end



function disableAnimationGui()
if not animations.showedGui then return end
  removeEventHandler("onClientRender", root, animations.renderAnimationsGui)
  if isElement(obj) then exports.object_preview:destroyObjectPreview(obj) end
  if isElement(ped) then destroyElement(ped) end
   animations.showedGui = false
   showCursor(false)
end


function animations.EnableRender(state, updatePosition )

   if state then

      if animations.playerHasAnim then
         return
      end
      addEventHandler("onClientRender", root, animations.Render)
	  -- addEventHandler("onClientClick", root, onClick)

      animations.playerHasAnim = true
      animations.lastPos = Vector3(getElementPosition(localPlayer))
      if updatePosition then
         animations.updatePosition = true
      end
   else

      if animations.playerHasAnim then
         removeEventHandler("onClientRender", root, animations.Render)
         animations.playerHasAnim = false
         animations.updatePosition = false
		 -- removeEventHandler("onClientClick", root, onClick)

      end
   end
end

addEvent("animations->EnableRender", true)
addEventHandler("animations->EnableRender", root, animations.EnableRender)



count = 0
offset_roll = 0
local lastTriggerTick = 0 
function animations.Render()
   if animations.playerHasAnim then
      if not getKeyState("lshift") then 

         dxDrawText("Aby przesunąć się użyj klawiszy SHIFT + (A,W,S,D,+,-)",animations.textInfoX, animations.textInfoY ,animations.textInfoX, animations.textInfoY,tocolor(255, 255, 255, 255),1,animations.font,"center","top")
      else
         dxDrawText(
         "Naciśnij spację aby anulować animację",animations.textInfoX, animations.textInfoY ,animations.textInfoX, animations.textInfoY,tocolor(255, 255, 255, 255),1,animations.font,"center","top")
      end

      if not isMainMenuActive() and not isChatBoxInputActive() and not isConsoleActive() then
         if getKeyState("a") and getKeyState("lshift") then
            local x, y, z = getPositionFromElementOffset(localPlayer, -0.01, 0, 0)

            if getDistanceBetweenPoints3D(animations.lastPos["x"],animations.lastPos["y"],animations.lastPos["z"], x, y,z) < 2.0 then
               setElementPosition(localPlayer, x, y, z, false)
            end
            if animations.updatePosition == true then
               animations.updatePosition = false
            end
         elseif getKeyState("w") and getKeyState("lshift") then
            local x, y, z = getPositionFromElementOffset(localPlayer, 0, 0.01, 0)

            if getDistanceBetweenPoints3D(animations.lastPos["x"],animations.lastPos["y"],animations.lastPos["z"],x,y,z) < 2.0 then
               setElementPosition(localPlayer, x, y, z, false)
            end
            if animations.updatePosition == true then
               animations.updatePosition = false
            end
         elseif getKeyState("s") and getKeyState("lshift") then
            local x, y, z = getPositionFromElementOffset(localPlayer, 0, -0.01, 0)

            if getDistanceBetweenPoints3D(animations.lastPos["x"],animations.lastPos["y"],animations.lastPos["z"],x,y,z) < 2.0 then
               setElementPosition(localPlayer, x, y, z, false)
            end
            if animations.updatePosition == true then
               animations.updatePosition = false
            end
         elseif getKeyState("d") and getKeyState("lshift") then
            local x, y, z = getPositionFromElementOffset(localPlayer, 0.01, 0, 0)

            if getDistanceBetweenPoints3D(animations.lastPos["x"],animations.lastPos["y"],animations.lastPos["z"],x,y,z) < 2.0 then
               setElementPosition(localPlayer, x, y, z, false)
            end
            if animations.updatePosition == true then
               animations.updatePosition = false
            end
         elseif getKeyState("=") and getKeyState("lshift") then
            local x, y, z = getElementPosition(localPlayer)
            if getDistanceBetweenPoints3D(animations.lastPos["x"],animations.lastPos["y"],animations.lastPos["z"],x,y,z) < 2.0 then
               setElementPosition(localPlayer, x, y, z + 0.01, false)
            end

         elseif getKeyState("arrow_u") and getKeyState("lshift") then
            local px, py, pz, lx, ly, lz = getCameraMatrix()
            animations.rotation = findRotation(px, py, lx, ly)
            setElementRotation(localPlayer, 0, 0, animations.rotation)
			   local now = getTickCount()
        if now - lastTriggerTick >= 1000 then -- 1000ms cooldown
            lastTriggerTick = now

            local data = exports.rp_login:getPlayerData(localPlayer, "animation->default")
            if data then
                local tmpTable = {data[1], animations.rotation, data[3]}
                triggerServerEvent("onPlayerCorrectPosAnimation", localPlayer, tmpTable, 1)
            end

            local dataSecond = exports.rp_login:getPlayerData(localPlayer, "customAnim->anim")
            if dataSecond then
                triggerServerEvent("onPlayerCorrectPosAnimation", localPlayer, {dataSecond[1], animations.rotation, dataSecond[3]})
            end
			end
         elseif getKeyState("space") then
            if not animations.updatePosition then
			-- triggerServerEvent("onPlayerSetAnimation", {dataSecond[1], animations.rotation, dataSecond[3]})
               setElementPosition( localPlayer, animations.lastPos["x"],animations.lastPos["y"],animations.lastPos["z"])
            end
            triggerServerEvent("animations->stopAnim", localPlayer)
            animations.EnableRender(false)
         elseif getKeyState("-") and getKeyState("lshift") then
            local x, y, z = getElementPosition(localPlayer)
            if getDistanceBetweenPoints3D(animations.lastPos["x"],animations.lastPos["y"],animations.lastPos["z"],x,y,z - 0.01) < 2.0 then
               setElementPosition(localPlayer, x, y, z - 0.01, false)
            end
         end
      end
   end
end

function disableGUIOnDead()
   if animations.playerHasAnim then
      removeEventHandler("onClientRender", root, animations.Render)
      animations.playerHasAnim = false
   end
end
addEvent("animations->Dead", true)
addEventHandler("animations->Dead", root, disableGUIOnDead)
local sorted = false
function animations.showAnimationsGui(state)
   if not animations.showedGui then
	  -- if 
      addEventHandler("onClientRender", root, animations.renderAnimationsGui)
	  addEventHandler("onClientClick", root, onClick)
	  addEventHandler("onClientKey", root, animations.clickKey)
	  addEventHandler("onClientKey", root, animations.scroll)

      animations.startTime = getTickCount()
      animations.endTime = animations.startTime + 500
      ped = createPed(getElementModel(localPlayer), 0,0,0)
      obj = exports.object_preview:createObjectPreview(ped,0,0,180, animations.startX+350*scaleValue, animations.startY+80*scaleValue, 300*scaleValue, 300*scaleValue, false, true, true)

      table.sort(tableAnims, function(a, b)
      if a.category == "Ulubione" and b.category ~= "Ulubione" then
         return true
      elseif a.category ~= "Ulubione" and b.category == "Ulubione" then
         return false
      else
         return a.category < b.category
      end
      end)
	showCursor(true)

   else
      removeEventHandler("onClientRender", root, animations.renderAnimationsGui)
	  removeEventHandler("onClientClick", root, onClick)
	  removeEventHandler("onClientKey", root, animations.clickKey)
	  removeEventHandler("onClientKey", root, animations.scroll)

      if isElement(obj) then exports.object_preview:destroyObjectPreview(obj) end
      if isElement(ped) then destroyElement(ped) end
	      showCursor(false)


	 -- if 
   end
   animations.showedGui = not animations.showedGui


   Update()
   animations.currentCount = getNumberAnimations()
end
addEvent("animations->showGui", true)
addEventHandler("animations->showGui", root, animations.showAnimationsGui)

local sx,sy = guiGetScreenSize()
local favOrNormalAnim = "Dodaj do ulubionych"
animations.icon = dxCreateTexture("files/header_icon.png", "argb", true, "clamp", "2d")
animations.bg = dxCreateTexture("files/window.png", "argb", true, "clamp", "2d")
animations.iconclose = dxCreateTexture("files/close.png", "argb", true, "clamp", "2d")
animations.row = dxCreateTexture("files/row.png", "argb", true, "clamp", "2d")
animations.selectedrow = dxCreateTexture("files/selected_row.png", "argb", true, "clamp", "2d")
animations.scrollimage = dxCreateTexture("files/scroll.png", "argb", true, "clamp", "2d")
animations.scrollbarimage = dxCreateTexture("files/scrollbar.png", "argb", true, "clamp", "2d")
animations.button = dxCreateTexture("files/button.png", "argb", true, "clamp", "2d")
animations.iconaccept = dxCreateTexture("files/accept.png", "argb", true, "clamp", "2d")
animations.info = dxCreateTexture("files/info.png", "argb", true, "clamp", "2d")

animations.renderTargetX, animations.renderTargetY =  320*scaleValue, 420*scaleValue
animations.renderTarget = dxCreateRenderTarget(animations.renderTargetX, animations.renderTargetY, true)
animations.offset = 0


function animations.renderAnimationsGui()
   local now = getTickCount()
   local elapsedTime = now - animations.startTime
   local duration = animations.endTime - animations.startTime
   local progress = elapsedTime / duration
   animations.alpha = interpolateBetween (
   0, 0, 0,
   255, 0, 0,
   progress, "Linear")

   dxDrawImage( animations.startX, animations.startY,animations.drawX, animations.drawY,animations.bg, 0,0,0,tocolor(255,255,255,animations.alpha))
   dxDrawImage( animations.startX+25*scaleValue, animations.startY+15*scaleValue,32*scaleValue, 32*scaleValue,animations.icon, 0,0,0,tocolor(255,255,255,animations.alpha))
   dxDrawImage( animations.startX+animations.drawX-40*scaleValue, animations.startY+25*scaleValue,10*scaleValue, 10*scaleValue,animations.iconclose, 0,0,0,tocolor(255,255,255,animations.alpha))
   dxDrawImage( animations.startX+animations.drawX-220*scaleValue, animations.startY+450*scaleValue,134*scaleValue, 39*scaleValue,animations.button, 0,0,0,tocolor(255,255,255,animations.alpha))
   if isMouseInPosition(animations.startX+animations.drawX-220*scaleValue, animations.startY+450*scaleValue,134*scaleValue, 39*scaleValue) then
   dxDrawImage( animations.startX+animations.drawX-220*scaleValue, animations.startY+450*scaleValue,134*scaleValue, 39*scaleValue,animations.button, 0,0,0,tocolor(255,255,255,animations.alpha))
   end
   dxDrawImage( animations.startX+animations.drawX-210*scaleValue, animations.startY+463*scaleValue,16*scaleValue, 12*scaleValue,animations.iconaccept, 0,0,0,tocolor(255,255,255,animations.alpha))


   dxDrawText("Akceptuj",animations.startX+480*scaleValue, animations.startY+455*scaleValue, animations.startX, animations.startY+20*scaleValue, tocolor(255, 255, 255, animations.alpha),1,animations.header,"left","top")
   dxDrawText(favOrNormalAnim,animations.startX+520*scaleValue, animations.startY+400*scaleValue, animations.startX+520*scaleValue, animations.startY+400*scaleValue, tocolor(243, 107, 255, animations.alpha),1,animations.header,"center","top")




   local index = count
   local linecount = 9
   local itemscount = animations.currentCount
   local windowheight = 420 * scaleValue

   local visiblefactor = math.min(linecount / itemscount, 1.0)

   visiblefactor = math.max(visiblefactor, 0.05)

   local barheight = (windowheight - 20) * visiblefactor

   local position = math.min(index / itemscount, 1.0 - visiblefactor) * (windowheight - 20)
   dxDrawImage(animations.startX  + 350* scaleValue,animations.startY + 85 * scaleValue,4*scaleValue,windowheight - 20,animations.scrollbarimage,0,0,0,tocolor(255, 255, 255, animations.alpha)) --scrollbg
   dxDrawImage(animations.startX + 350 * scaleValue,animations.startY + position + 85 * scaleValue,4*scaleValue,barheight,animations.scrollimage,0,0,0,tocolor(255, 255, 255, animations.alpha)) --scroll



   dxDrawText("Panel animacji",animations.startX+90*scaleValue, animations.startY+20*scaleValue, animations.startX+90*scaleValue, animations.startY+20*scaleValue, tocolor(255, 255, 255, animations.alpha),1,animations.header,"left","top")
   dxDrawRectangle ( animations.startX, animations.startY+60*scaleValue,animations.drawX, 1*scaleValue, tocolor ( 61, 77, 134, animations.alpha ) )

    for i = 1, #categories do
         local offset = ((i-1)*60)
         offset = offset * scaleValue
         local imgIcon = categories[i].icon
         local w,h = 32 * scaleValue, 32 * scaleValue
		 if isMouseInPosition(animations.startX+offset+133*scaleValue, animations.startY+510*scaleValue,w,h) then

		 dxDrawImage(animations.startX+offset+125*scaleValue, animations.startY+500*scaleValue,45*scaleValue, 45*scaleValue,imgIcon,0,0,0,tocolor(255, 255, 255, 255),false)
		 dxDrawRoundedRectangle(animations.startX+offset+117*scaleValue, animations.startY+550*scaleValue, 60*scaleValue, 20*scaleValue, 5, tocolor(122, 106, 235,255))
		 dxDrawText(categories[i].text,animations.startX+offset+147*scaleValue, animations.startY+550*scaleValue,animations.startX+offset+147*scaleValue, animations.startY+550*scaleValue, tocolor(255, 255, 255, animations.alpha),1,animations.header2,"center","top")

		 else

		 dxDrawImage(animations.startX+offset+133*scaleValue, animations.startY+510*scaleValue,w,h,imgIcon,0,0,0,tocolor(255, 255, 255, 255),false)


		 end
      end
   
   dxSetBlendMode("add")
   dxDrawImage( animations.startX+20*scaleValue, animations.startY+65*scaleValue, 320*scaleValue, 420*scaleValue,animations.renderTarget, 0,0,0,tocolor(255,255,255,animations.alpha))
   dxSetBlendMode("blend")
end


categories = {
    [1] = {
		icon = dxCreateTexture("files/stand.png", "argb", true, "clamp", "2d"),
        text = "Stanie"
    },
    [2] = {
		icon = dxCreateTexture("files/dance.png", "argb", true, "clamp", "2d"),
        text = "Taniec"
    },
    [3] = {
		icon = dxCreateTexture("files/running.png", "argb", true, "clamp", "2d"),
        text = "Chód"
    },
    [4] = {
		icon = dxCreateTexture("files/gang.png", "argb", true, "clamp", "2d"),
        text = "Gang"
    },
    [5] = {
		icon = dxCreateTexture("files/serce.png", "argb", true, "clamp", "2d"),
        text = "Custom"
    },
	 [6] = {
		icon = dxCreateTexture("files/sit.png", "argb", true, "clamp", "2d"),
        text = "Siedzenie"
    },
	 [7] = {
		icon = dxCreateTexture("files/lezenie.png", "argb", true, "clamp", "2d"),
        text = "Leżenie"
    }
	
}

function updateWithTimer()
   Update()
end

function Update()
    animations.offset = 0
    animations.currentCount = getNumberAnimations()

    if type(tableAnims) == "table" and #tableAnims > 0 then
        dxSetRenderTarget(animations.renderTarget, true)

        local currentCategory = ""
        for k,v in ipairs(tableAnims) do
            if v.category == animations.currentCategory or v.category == "Ulubione" then
                if v.category ~= currentCategory then
                    currentCategory = v.category
                    dxDrawText(currentCategory..":", 10*scaleValue, (animations.offset - offset_roll - 5*scaleValue), 25*scaleValue, (animations.offset - offset_roll - 5*scaleValue), tocolor(255, 255, 255, 255), 1, animations.header, "left", "top")
                    animations.offset = animations.offset + 25*scaleValue
                end

                if tableAnims[k].clicked then
                    dxDrawText("//"..(v.commandName or "blad"), 10*scaleValue, (animations.offset - offset_roll+10*scaleValue), 25*scaleValue, (animations.offset - offset_roll + 5*scaleValue), tocolor(127, 110, 250, 255), 1, animations.header, "left", "top")
                    dxDrawImage(1*scaleValue, (animations.offset - offset_roll), 308*scaleValue, 45*scaleValue, animations.selectedrow, 0, 0, 0, tocolor(255, 255, 255, 255))
                else
                    dxDrawText("//"..(v.commandName or "blad"), 10*scaleValue, (animations.offset - offset_roll+10*scaleValue), 25*scaleValue, (animations.offset - offset_roll + 5*scaleValue), tocolor(255, 255, 255, 255), 1, animations.header, "left", "top")
                end

                dxDrawImage(1*scaleValue, (animations.offset - offset_roll), 308*scaleValue, 45*scaleValue, animations.row, 0, 0, 0, tocolor(255, 255, 255, 255))
                animations.offset = animations.offset + 50*scaleValue
            end
        end

        dxSetBlendMode("blend")
        dxSetRenderTarget()
    end
end

function onClick(button, state, x, y)
    if button == "left" and state == "down" then
        local clickOffset = 0

        for k,v in ipairs(tableAnims) do
            if v.category == animations.currentCategory or v.category == "Ulubione" then
                local animX, animY = animations.startX + 45 * scaleValue, (clickOffset + 350 * scaleValue - offset_roll)
                local animW, animH = 130 * scaleValue, 40 * scaleValue

                if isMouseInPosition(animX, animY, animW, animH) then
                    animations.blockTemp, animations.nameTemp, animations.loopTemp, animations.updatePositionTemp, animations.isCustomAnim, animations.tempCommandName, animations.tempCategory = v.block, v.anim, v.loop, v.updatePosition, v.customAnim, v.commandName, v.category
                    
                    favOrNormalAnim = (animations.tempCategory == "Ulubione") and "Usun z ulubionych" or "Dodaj do ulubionych"
                    
                    if animations.lastIDUsed then
                        tableAnims[animations.lastIDUsed].clicked = false
                    end
                    
                    tableAnims[k].clicked = true
                    animations.lastIDUsed = k
                    setTimer(updateWithTimer, 100, 1)
                    setPedAnimation(ped, animations.blockTemp, animations.nameTemp, -1, animations.loopTemp)
                    return
                end
                clickOffset = clickOffset + 50 * scaleValue
            end
        end
    end
end




-- testx, testy, testxz, testyz = animations.startX+45*scaleValue, (animations.offset + 360 * scaleValue - offset_roll), 130 * scaleValue, 25 * scaleValue

-- function testRender(x,y,xz,yz)
-- dxDrawRectangle ( testx,testy,testxz,testyz, tocolor ( 61, 77, 134, 155 ),true,true )

-- end
-- addEventHandler("onClientRender", root, testRender)


count = 0
offset_roll = 0

function animations.scroll(button, state)
   if animations.showedGui then
      local latestLine = count + 7 -- do zmiany, ile na strone ma byc widoczne
      if button == "mouse_wheel_down" and state then
         if latestLine < animations.currentCount then
            count = count + 1
            offset_roll = offset_roll + 50 * scaleValue -- do zmiany
            Update()

         end
      elseif button == "mouse_wheel_up" and state then
         if count > 0 then
            count = count - 1
            offset_roll = offset_roll - 50 * scaleValue
            Update()

         end
      end
   end
end

function animations.clickKey(button, press)
   if animations.showedGui then
      if button == "escape" then
         animations.disableGui()
      elseif button == "mouse1" and press then
         Update(true)
         if isMouseInPosition(animations.startX+animations.drawX-220*scaleValue, animations.startY+450*scaleValue,134*scaleValue, 39*scaleValue) then
            if animations.blockTemp then
               if animations.isCustomAnim then
                  triggerServerEvent("animations->customAnimApply",localPlayer,animations.tempCommandName, animations.updatePosition or animations.updatePositionTemp)
               else
                  triggerServerEvent("animations->applyAnim",localPlayer,animations.blockTemp,animations.nameTemp,animations.loopTemp,animations.updatePosition or animations.updatePositionTemp)
               end
            end
         elseif isMouseInPosition(animations.startX+animations.drawX-40*scaleValue, animations.startY+25*scaleValue,10*scaleValue, 10*scaleValue) then
            animations.disableGui()
		elseif isMouseInPosition(animations.startX+130*scaleValue, animations.startY+510*scaleValue,400*scaleValue,40*scaleValue) then
		for i = 1, #categories do
         local offset = ((i-1)*60)
         offset = offset * scaleValue
         local imgIcon = categories[i].icon
         local w,h = 32 * scaleValue, 32 * scaleValue
		 if isMouseInPosition(animations.startX+offset+130*scaleValue, animations.startY+500*scaleValue,35*scaleValue, 45*scaleValue) then
		 animations.currentCategory = categories[i].text
		 count = 0
		 offset_roll = 0
		 Update()
		 end
      end

         elseif isMouseInPosition(animations.startX+animations.drawX-230*scaleValue, animations.startY+400*scaleValue,200*scaleValue, 39*scaleValue)then -- fav
            if animations.tempCategory == "Ulubione" then
               for k,v in ipairs(tableAnims) do
                  if animations.tempCommandName == v.commandName then
                     tempcommandName, tempBlock, tempAnim, tempLoop, originalCategory, tempUpdatePosition, tempCustomAnim = v.commandName, v.block, v.anim, v.loop, v.originalCategory, v.updatePosition, v.customAnim
                     table.remove(tableAnims,k)
                  end
               end
			   exports.rp_library:createBox("Ulubiona animacja została usunięta")
               -- table.remove(tableAnims,k)
               table.remove(favoriteAnims,k)
               animations.addFavoriteAnimToTable(nil, nil, nil, nil,nil, nil, nil, true)
               table.insert(tableAnims, {commandName=animations.tempCommandName, block=tempBlock, anim=tempAnim, loop=tempLoop, category=originalCategory, updatePosition=tempUpdatePosition, desc="whatever", customAnim=tempCustomAnim, used=0, clicked = 0, id = #tableAnims + 1})
               for k,v in ipairs(tableAnims) do
                  tableAnims[k].used = 0
                  tableAnims[k].clicked = false
               end
               Update()

               return
            end
            if animations.tempCommandName then
               table.insert(tableAnims,{commandName = animations.tempCommandName,block = animations.blockTemp,anim = animations.nameTemp,loop = animations.loopTemp,category = "Ulubione",updatePosition = animations.updatePositionTemp,desc = "fav",customAnim = animations.isCustomAnim,used = 0,clicked = false,id = #tableAnims + 1, originalCategory = originalCategory})
			   exports.rp_library:createBox("Dodano ulubioną animacje.")
               animations.addFavoriteAnimToTable(animations.tempCommandName, animations.blockTemp, animations.nameTemp, animations.loopTemp, animations.updatePositionTemp, animations.isCustomAnim, animations.tempCategory)
               table.sort(tableAnims, function(a, b)
               if a.category == "Ulubione" and b.category ~= "Ulubione" then
                  return true
               elseif a.category ~= "Ulubione" and b.category == "Ulubione" then
                  return false
               else
                  return a.category < b.category
               end
               end)
               for k,v in ipairs(tableAnims) do
                  tableAnims[k].used = 0
                  tableAnims[k].clicked = false
               end

               Update()
            end
         end
      end
   end
end

-- elseif button == "mouse1" and press and isMouseInPosition(animations.startX+animations.drawX-40*scaleValue, animations.startY+25*scaleValue,10*scaleValue, 10*scaleValue) then
-- animations.disableGui()
-- elseif button == "escape" and press then
-- animations.disableGui()
-- cancelEvent()


function animations.disableGui()
   animations.showedGui = false
   removeEventHandler("onClientRender", root,  animations.renderAnimationsGui)
   removeEventHandler("onClientClick", root, onClick)
   removeEventHandler("onClientKey", root, animations.clickKey)
   removeEventHandler("onClientKey", root, animations.scroll)
   -- animations.playerHasAnim = false
   -- animations.updatePosition = false
   if isElement(obj) then exports.object_preview:destroyObjectPreview(obj) end
   setElementAlpha(ped,0)
   local x,y,z = getElementPosition(localPlayer)
   setElementPosition(ped,x,y,z+5)
   if isElement(ped) then destroyElement(ped) end
   showCursor(false)
   animations.offset = 0
   count = 0
   offset_roll = 0
   for k,v in ipairs(tableAnims) do
   tableAnims[k].clicked = false
   end
   cancelEvent()
end

addEventHandler(
"onClientVehicleStartExit",
getRootElement(),
function(player, seat)
   if player == localPlayer then
      triggerServerEvent("animations->stopAnim", localPlayer)
      animations.EnableRender(false)
   end
end
)

function getPositionFromElementOffset(element, offX, offY, offZ)
   local m = getElementMatrix(element)
   local x = offX * m[1][1] + offY * m[2][1] + offZ * m[3][1] + m[4][1]
   local y = offX * m[1][2] + offY * m[2][2] + offZ * m[3][2] + m[4][2]
   local z = offX * m[1][3] + offY * m[2][3] + offZ * m[3][3] + m[4][3]
   return x, y, z
end

function findRotation(x1, y1, x2, y2)
   local t = -math.deg(math.atan2(x2 - x1, y2 - y1))
   return t < 0 and t + 360 or t
end

local hasAnotherGui = false
function PlayerHasAnotherGui()
   return hasAnotherGui
end
function setPlayerAnotherGui(state)
   hasAnotherGui = state
end


function animations.loadFavAnims()
   local fileAnims = xmlLoadFile("files/savedAnims.xml")
   if fileAnims then
      local anims = xmlFindChild(fileAnims, "savedAnims", 0)
      local data  = xmlNodeGetValue(anims)
      -- outputChatBox(data)
      if data == "" then return end
      -- outputChatBox("check2")
      local json = fromJSON(data)
      favoriteAnims = json
      for k,v in ipairs(favoriteAnims) do
         table.insert(tableAnims,{commandName = v.commandName,block = v.block,anim = v.anim,loop = v.loop,category = "Ulubione",updatePosition = v.updatePosition,desc = "fav",customAnim = v.customAnim,used = 0,clicked = false,id = #tableAnims + 1, originalCategory = v.originalCategory})
      end
      -- end
   end

   xmlUnloadFile(fileAnims)
end

function animations.onStart() -- xml i tak jak da sie false to zamienia na string, trzeba zimenic
   if not fileExists("files/savedanims.xml") then
      local rootNode = xmlCreateFile("files/savedanims.xml","FavoriteAnims")
      local childNode = xmlCreateChild(rootNode, "savedAnims")
      xmlSaveFile(rootNode)
      xmlUnloadFile(rootNode)
   end

   animations.loadFavAnims()




   local file = xmlLoadFile("files/animlist.xml")
   if file then
      local xmlNodes = xmlNodeGetChildren(file)
      for i, v in ipairs(xmlNodes) do
         local name = xmlNodeGetAttribute(v, "commandName")
         local desc = xmlNodeGetAttribute(v, "desc")
         local block = xmlNodeGetAttribute(v, "block")
         local anim = xmlNodeGetAttribute(v, "anim")
         local loop = xmlNodeGetAttribute(v, "isLoop")
         local category = xmlNodeGetAttribute(v, "category")
         local id = xmlNodeGetAttribute(v, "id")
         local updatePosition = xmlNodeGetAttribute(v, "updatePosition")
         local customAnim = xmlNodeGetAttribute(v, "customAnim")
         if loop == "false" then
            loop = false
         else
            loop = true
         end
         if customAnim == "false" then
            customAnim = false
         else
            customAnim = true
         end
         if updatePosition == "false" then
            updatePosition = false
         else
            updatePosition = true
         end
         table.insert(
         tableAnims,
         {
            commandName = name,
            block = block,
            anim = anim,
            loop = loop,
            category = category,
            updatePosition = updatePosition,
            desc = desc,
            customAnim = customAnim,
            used = 0,
            clicked = false,
            id = id,
            originalCategory = category
         }
         )
      end
   end
   xmlUnloadFile(file)
end
animations.onStart()

local positionButtons = {["a"]=true,["w"]=true,["s"]=true,["d"]=true,}


function playerPressedKeyonAnim(button, press)
   if positionButtons[button] and press and animations.playerHasAnim then
      if (getKeyState("lshift")) then
         local veh = getPedOccupiedVehicle(localPlayer)
         if veh then return end
         local col = getElementCollisionsEnabled(localPlayer)
         if col then
            triggerServerEvent("animations->disableCollision", localPlayer)
         end
      end
   end
end
addEventHandler("onClientKey", root, playerPressedKeyonAnim)
-- bindKey("lshift", "down", playerPressedKeyonAnim)



function animations.checkMouse(_, _, x, y)
   if animations.showedGui then
      if isMouseInPosition(animations.startX+20*scaleValue, animations.startY+110*scaleValue, 320*scaleValue, 420*scaleValue) then
         Update(nil,true)
      end
   end
end


function dxDrawRoundedRectangle(x, y, width, height, radius, color, postGUI, subPixelPositioning)
   dxDrawRectangle(
   x + radius,
   y + radius,
   width - (radius * 2),
   height - (radius * 2),
   color,
   postGUI,
   subPixelPositioning
   )
   dxDrawCircle(x + radius, y + radius, radius, 180, 270, color, color, 16, 1, postGUI)
   dxDrawCircle(x + radius, (y + height) - radius, radius, 90, 180, color, color, 16, 1, postGUI)
   dxDrawCircle((x + width) - radius, (y + height) - radius, radius, 0, 90, color, color, 16, 1, postGUI)
   dxDrawCircle((x + width) - radius, y + radius, radius, 270, 360, color, color, 16, 1, postGUI)
   dxDrawRectangle(x, y + radius, radius, height - (radius * 2), color, postGUI, subPixelPositioning)
   dxDrawRectangle(x + radius, y + height - radius, width - (radius * 2), radius, color, postGUI, subPixelPositioning)
   dxDrawRectangle(x + width - radius, y + radius, radius, height - (radius * 2), color, postGUI, subPixelPositioning)
   dxDrawRectangle(x + radius, y, width - (radius * 2), radius, color, postGUI, subPixelPositioning)
end

function isCursorOnElement(x, y, w, h)
   if isCursorShowing() then
      local mx, my = getCursorPosition()
      local fullx, fully = guiGetScreenSize()

      cursorx, cursory = mx * fullx, my * fully

      if cursorx > x and cursorx < x + w and cursory > y and cursory < y + h then
         return true
      else
         return false
      end
   end
end

function isMouseInPosition(x, y, width, height)
   if (not isCursorShowing()) then
      return false
   end
   local sx, sy = guiGetScreenSize()
   local cx, cy = getCursorPosition()
   local cx, cy = (cx * sx), (cy * sy)

   return ((cx >= x and cx <= x + width) and (cy >= y and cy <= y + height))
end




function table.empty (self)
   for _, _ in pairs(self) do
      return false
   end
   return true
end


function getNumberAnimations()
local count = 0
for k,v in ipairs(tableAnims) do
if v.category == animations.currentCategory or v.category == "Ulubione" then
count = count + 1
end
end
-- outputChatBox(count)
return count
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
local animations = {}
tableAnims = {}
local favoriteAnims = {}


function animations.addFavoriteAnimToTable(nameAnim, state)
if state then
local file = xmlLoadFile("files/savedAnims.xml")
local nodeAnim = xmlFindChild(file, "savedAnims", 0)
local json = toJSON(favoriteAnims)
xmlNodeSetValue(nodeAnim, json)
xmlSaveFile(file)
xmlUnloadFile(file)
else
table.insert(favoriteAnims,{animName = nameAnim, used = false})
local file = xmlLoadFile("files/savedAnims.xml")
local nodeAnim = xmlFindChild(file, "savedAnims", 0)
local json = toJSON(favoriteAnims)
xmlNodeSetValue(nodeAnim, json)
xmlSaveFile(file)
xmlUnloadFile(file)
end


end

-- function animations.placeCategories(type)
-- dxDrawRoundedRectangle(animations.backGroundX+220*scaleValue, animations.backGroundY+400*scaleValue, 45*scaleValue, 45*scaleValue, 10*scaleValue, tocolor ( 150, 84, 117, 255 ), false)
-- dxDrawImage ( animations.backGroundX+225*scaleValue, animations.backGroundY+405*scaleValue, 32*scaleValue, 32*scaleValue, "files/"..type..".png", 0,0,0, tocolor(255,255,255,255), false )
-- end

local scaleValue = exports.rp_scale:returnScaleValue()
local offSetX, offsetY = exports.rp_scale:returnOffsetXY()
animations.drawX, animations.drawY = 450 * scaleValue, 100 * scaleValue
animations.startX, animations.startY = exports.rp_scale:getScreenStartPositionFromBox(animations.drawX, animations.drawY, 0, offsetY, "center", "bottom")
animations.font = dxCreateFont("files/font.ttf", 20 * scaleValue, false, "proof")
animations.header = dxCreateFont("files/font.ttf", 15 * scaleValue, false, "proof")
animations.header2 = dxCreateFont("files/font.ttf", 10 * scaleValue, false, "proof")
animations.header3 = dxCreateFont("files/font.ttf", 13 * scaleValue, false, "proof")

animations.drawBackGroundX, animations.drawBackGroundY = 500 * scaleValue, 500 * scaleValue
animations.backGroundX, animations.backGroundY = exports.rp_scale:getScreenStartPositionFromBox(animations.drawBackGroundX,animations.drawBackGroundY,0,0,"center","center")

animations.categoryTemp,animations.blockTemp,animations.updatePositionTemp,animations.animTemp,animations.animLoopTemp,animations.tempID, animations.customAnim, animations.commandNameTemp = false, false, false, false, false, false, false, false
animations.renderTargetX, animations.renderTargetY = 500 * scaleValue, 285 * scaleValue
animations.renderTarget = dxCreateRenderTarget(animations.renderTargetX, animations.renderTargetY, true)
animations.offset = 0
animations.offsetImages = 0
animations.currentCategory = "Gang"
animations.alpha = 255
animations.categoryTargetting = false
animations.updatePosition = false
animations.playerHasAnim = false
animations.showedGui = false
animations.getNumberAnimations = 0
animations.textX, animations.textY = 1 * scaleValue, 150 * scaleValue

animations.drawTextX, animations.drawTextY = exports.rp_scale:getScreenStartPositionFromBox(animations.textX, animations.textY,offSetX,0,"right","center")
animations.offsetFavAnims = 0
animations.showedFavAnims = false
animations.currentSlotFavAnims = 1
function testRender()
    animations.offsetFavAnims = 0
    if table.empty(favoriteAnims) then
        -- dxDrawRectangle ( animations.drawTextX *scaleValue,animations.drawTextY * scaleValue,animations.textX,animations.textY, tocolor ( 0, 0, 0, 150 ) )
        dxDrawText("Nie posiadasz ulubionych animacji",animations.drawTextX - 250 * scaleValue,animations.drawTextY,animations.textX,animations.textY,tocolor(255, 255, 255, 255),1,animations.header,"left","top")
    else
        for k, v in ipairs(favoriteAnims) do
            if k <= 10 then
                if v.used then
                    dxDrawText(v.animName,animations.drawTextX - 70 * scaleValue,animations.drawTextY + animations.offsetFavAnims * scaleValue, animations.textX,animations.textY,tocolor(255, 255, 255, 255),1,animations.font, "left","top")
                else
                    dxDrawText( v.animName, animations.drawTextX - 60 * scaleValue,animations.drawTextY + animations.offsetFavAnims * scaleValue,animations.textX, animations.textY, tocolor(255, 255, 255, 255), 1,animations.header,"left","top")end

                animations.offsetFavAnims = animations.offsetFavAnims + 45 * scaleValue
            end
        end
    end
end

-- todo zapis do pliku XML ulubione animacje


function isPlayerHasEnabledAnimationsGUI()
return animations.showedGui
end

-- local hasEnabledGui = exports.rp_animations:isPlayerHasEnabledAnimationsGUI()
-- if hasEnabledGui then


function animations.EnableRender(state, updatePosition )

    if state then
	
        if animations.playerHasAnim then
            return
        end
        addEventHandler("onClientRender", root, animations.Render)
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
        end
    end
end

addEvent("animations->EnableRender", true)
addEventHandler("animations->EnableRender", root, animations.EnableRender)



count = 0
offset_roll = 0
function animations.Render()
    if animations.playerHasAnim then
        if not getKeyState("lshift") then --Aby przesunąć się użyj klawiszy (A,W,S,D,+,-)
            dxDrawText("Aby przesunąć się użyj klawiszy SHIFT + (A,W,S,D,+,-)",animations.startX - 40 * scaleValue,animations.startY,animations.drawX,animations.drawY,tocolor(255, 255, 255, 255),1,animations.font,"left","top")
        else
            dxDrawText(
                "Naciśnij spację aby anulować animację",animations.startX,animations.startY,animations.drawX,animations.drawY,tocolor(255, 255, 255, 255),1,animations.font,"left","top")
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
				local data = getElementData(localPlayer,"animation->defaultanim")
				if data then
				setElementData(localPlayer,"animation->defaultanim", {data[1], animations.rotation, data[3]})
				end
				local dataSecond = getElementData(localPlayer,"customAnim->anim")
				if dataSecond then
				setElementData(localPlayer,"customAnim->anim", {dataSecond[1], animations.rotation, dataSecond[3]})
				end
            elseif getKeyState("space") then
                if not animations.updatePosition then
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

function animations.showAnimationsGui(state)
    if not animations.showedGui then
        addEventHandler("onClientRender", root, animations.renderAnimationsGui)
		local how = 0
		for k,v in ipairs(tableAnims) do
		if v.category == animations.currentCategory then
		how = how + 1
		end
		end
		animations.getNumberAnimations = how

		animations.startTime = getTickCount()
		animations.endTime = animations.startTime + 500
    else
        removeEventHandler("onClientRender", root, animations.renderAnimationsGui)
    end
    animations.showedGui = not animations.showedGui
    showCursor(not isCursorShowing())


    Update()
end
addEvent("animations->showGui", true)
addEventHandler("animations->showGui", root, animations.showAnimationsGui)

function animations.renderAnimationsGui()
	local now = getTickCount()
	local elapsedTime = now - animations.startTime
	local duration = animations.endTime - animations.startTime
	local progress = elapsedTime / duration
	animations.alpha = interpolateBetween ( 
		0, 0, 0,
		255, 0, 0,
		progress, "Linear")
    dxDrawImage(animations.backGroundX,animations.backGroundY,animations.drawBackGroundX,animations.drawBackGroundY,"files/bg.png",0,0,0,tocolor(255, 255, 255, animations.alpha),false)
    -- dxDrawImage ( animations.backGroundX+, animations.backGroundY, 67*scaleValue,18*scaleValue, "files/rectangle.png", 0,0,0, tocolor(255,255,255,255), false )

    dxDrawText("PANEL ANIMACJI",animations.backGroundX + 15 * scaleValue,animations.backGroundY + 10 * scaleValue,animations.drawBackGroundX,animations.drawBackGroundY, tocolor(255, 255, 255, animations.alpha),1,animations.font,"left","top")
	dxDrawText("X",animations.backGroundX + 465 * scaleValue,animations.backGroundY + 10 * scaleValue,animations.drawBackGroundX,animations.drawBackGroundY, tocolor(255, 255, 255, animations.alpha),1,animations.font,"left","top")
	dxDrawText("Aby usunąć ulubioną animację, wejdź do listy ulubionych i wciśnij SCROLL.",animations.backGroundX - 50 * scaleValue,animations.backGroundY + 520 * scaleValue,animations.drawBackGroundX,animations.drawBackGroundY, tocolor(255, 255, 255, animations.alpha),1,animations.header,"left","top")
	dxDrawText("Aby użyć animacji naciśnij na nią LPM, bądź wpisz np. //bar1.",animations.backGroundX - 15 * scaleValue,animations.backGroundY + 540 * scaleValue,animations.drawBackGroundX,animations.drawBackGroundY, tocolor(255, 255, 255, animations.alpha),1,animations.header,"left","top")
	dxDrawText("Aby dodać animację do ulubionych naciśnij na nią PPM.",animations.backGroundX - 15 * scaleValue,animations.backGroundY + 560 * scaleValue,animations.drawBackGroundX,animations.drawBackGroundY, tocolor(255, 255, 255, animations.alpha),1,animations.header,"left","top")


    -- dxDrawImage ( animations.backGroundX, animations.backGroundY+53*scaleValue, 500*scaleValue,50*scaleValue, "files/bar2.png", 0,0,0, tocolor(255,255,255,255), true )
    -- dxDrawImage ( animations.backGroundX, animations.backGroundY+100*scaleValue, 500*scaleValue,50*scaleValue, "files/bar1.png", 0,0,0, tocolor(255,255,255,255), true )
    -- dxDrawImage ( animations.backGroundX, animations.backGroundY+147*scaleValue, 500*scaleValue,50*scaleValue, "files/bar2.png", 0,0,0, tocolor(255,255,255,255), true )
    -- dxDrawImage ( animations.backGroundX, animations.backGroundY+194*scaleValue, 500*scaleValue,50*scaleValue, "files/bar1.png", 0,0,0, tocolor(255,255,255,255), true )
    -- dxDrawImage ( animations.backGroundX, animations.backGroundY+241*scaleValue, 500*scaleValue,50*scaleValue, "files/bar2.png", 0,0,0, tocolor(255,255,255,255), true )
    -- dxDrawImage ( animations.backGroundX, animations.backGroundY+288*scaleValue, 500*scaleValue,50*scaleValue, "files/bar1.png", 0,0,0, tocolor(255,255,255,255), true )
    dxDrawImage( animations.backGroundX,animations.backGroundY + 53 * scaleValue,animations.renderTargetX,animations.renderTargetY,animations.renderTarget, 0,0,0,tocolor(255,255,255,animations.alpha))

    dxDrawText("Scrolluj, aby zobaczyć więcej animacji.",animations.backGroundX + animations.drawBackGroundX / 6,animations.backGroundY + 350 * scaleValue,animations.drawBackGroundX,animations.drawBackGroundY,tocolor(255, 255, 255, animations.alpha),1,animations.header,"left","top")
    -- dxDrawImage ( animations.backGroundX+240*scaleValue, animations.backGroundY+400*scaleValue, 24*scaleValue, 24*scaleValue, "files/stand.png", 0,0,0, tocolor(255,255,255,255), false )
    animations.offsetImages = 1 * scaleValue
    -- dxDrawRectangle ( animations.backGroundX + 458 * scaleValue,animations.backGroundY + 10 * scaleValue, 32*scaleValue,32*scaleValue, tocolor ( 255, 0, 0, 150 ) )

    for k, v in ipairs(categories) do
        -- iprint(v)
        animations.placeCategories(categories[k]["icon"], categories[k]["used"], categories[k]["text"], k, categories[k]["size"])
        animations.offsetImages = animations.offsetImages + 60 * scaleValue
        categories[k]["offset"] = animations.offsetImages
    end
    -- animations.placeCategories("stand")
end

function animations.placeCategories(type, used, text, id, size)
-- if categories[id]["text"] == "Sex" or categories[id]["text"] == "Gang" then
		-- newOffset = 8 * scaleValue
		-- end

    if used or size == true then
        dxDrawRoundedRectangle(animations.backGroundX + categories[id]["offset"] - 10 * scaleValue,animations.backGroundY + 385 * scaleValue,45 * scaleValue,45  * scaleValue,10 * scaleValue,tocolor(150, 84, 117, animations.alpha),false)
        -- dxDrawImage(animations.backGroundX + categories[id]["offset"] - 3 * scaleValue,animations.backGroundY + 390 * scaleValue,32  * scaleValue,32  * scaleValue,"files/" .. type,0,0,0,tocolor(255, 255, 255, animations.alpha),false)
		   dxDrawImage(animations.backGroundX + categories[id]["offset"] - 3 * scaleValue,animations.backGroundY + 390 * scaleValue,32  * scaleValue,32  * scaleValue,type,0,0,0,tocolor(255, 255, 255, animations.alpha),false)

	if categories[id]["text"] == "Sex" then
	categories[id]["offset"] = categories[id]["offset"] + 10 * scaleValue
	end
	if categories[id]["text"] == "Gang"  then
	categories[id]["offset"] = categories[id]["offset"] + 3 * scaleValue
	end
	if categories[id]["text"] == "Siedzenie" then
	categories[id]["offset"] = categories[id]["offset"] - 12 * scaleValue
	end
	if categories[id]["text"] == "Chodzenie" then
	categories[id]["offset"] = categories[id]["offset"] - 16 * scaleValue
	end
	if categories[id]["text"] == "Custom" then
	categories[id]["offset"] = categories[id]["offset"] - 10 * scaleValue
	end
		dxDrawText(text,animations.backGroundX + categories[id]["offset"] - 10  * scaleValue,animations.backGroundY + 450 * scaleValue,animations.drawBackGroundX,animations.drawBackGroundY,tocolor(255, 255, 255, animations.alpha),1,animations.header3,"left","top")
    else
		
        dxDrawRoundedRectangle(animations.backGroundX + categories[id]["offset"] - 6 * scaleValue,animations.backGroundY + 395 * scaleValue,30  * scaleValue,30  * scaleValue,10 * scaleValue,tocolor(150, 84, 117, 150),false)
        -- dxDrawImage(animations.backGroundX + categories[id]["offset"] + 2 * scaleValue,animations.backGroundY + 400 * scaleValue,16 * scaleValue, 16 * scaleValue,"files/" .. type,0,0,0,tocolor(255, 255, 255, 150),false)
		   dxDrawImage(animations.backGroundX + categories[id]["offset"] + 2 * scaleValue,animations.backGroundY + 400 * scaleValue,16 * scaleValue, 16 * scaleValue,type,0,0,0,tocolor(255, 255, 255, 150),false)


	if categories[id]["text"] == "Sex"  then
	categories[id]["offset"] = categories[id]["offset"] + 10 * scaleValue
	end
	if categories[id]["text"] == "Gang"  then
	categories[id]["offset"] = categories[id]["offset"] + 6 * scaleValue
	end
	if categories[id]["text"] == "Siedzenie"  then
	categories[id]["offset"] = categories[id]["offset"] - 8 * scaleValue
	end
	if categories[id]["text"] == "Chodzenie"  then
	categories[id]["offset"] = categories[id]["offset"] - 12 * scaleValue
	end
	if categories[id]["text"] == "Custom" then
	categories[id]["offset"] = categories[id]["offset"] - 2 * scaleValue
	end
		dxDrawText(text,animations.backGroundX + categories[id]["offset"] - 10  * scaleValue,animations.backGroundY + 435 * scaleValue,animations.drawBackGroundX,animations.drawBackGroundY,tocolor(255, 255, 255, 150),1,animations.header2,"left", "top")
    end

    if isCursorOnElement( animations.backGroundX + categories[id]["offset"] - 10 * scaleValue,animations.backGroundY + 385 * scaleValue,45 * scaleValue,45 * scaleValue) then
        animations.categoryTargetting = categories[id]["text"]
		categories[id]["size"] = true
		else
		categories[id]["size"] = false
    -- outputChatBox(animations.categoryTargetting)
    end
end


function getNumberAnimations()
for k,v in ipairs(tableAnims) do
if v.category == animations.currentCategory then
return k
end
end
end


function Update(rightclick, scrollClick)
    itest = 0
    animations.offset = 0
	countImages = countImages
    dxSetRenderTarget(animations.renderTarget, true)


    for k, v in ipairs(tableAnims) do
        if v.category == animations.currentCategory then
            local nameAnim = v.commandName
            local descAnim = v.desc
            local loop = v.loop
            -- dxDrawImage ( 1*scaleValue, animations.offset, 500*scaleValue,50*scaleValue, "files/bar2.png", 0,0,0, tocolor(255,255,255,255), false )
            -- dxDrawImage ( 1*scaleValue, animations.offset, 500*scaleValue,50*scaleValue, "files/bar1.png", 0,0,0, tocolor(255,255,255,255), false )

            local width, height = dxGetTextWidth(v.commandName), dxGetFontHeight()

            --dxDrawImage ( animations.backGroundX, animations.backGroundY+53*scaleValue, 500*scaleValue,50*scaleValue, "files/bar2.png", 0,0,0, tocolor(255,255,255,255), false )
            local fillSpace = placeImage()
            if fillSpace then
                dxDrawImage(1 * scaleValue,(animations.offset - offset_roll),500 * scaleValue,50 * scaleValue,"files/bar2.png",0,0,0,tocolor(255, 255, 255, 255),false)
            else
                dxDrawImage(1 * scaleValue,(animations.offset - offset_roll),500 * scaleValue,50 * scaleValue,"files/bar1.png", 0,0,0,tocolor(255, 255, 255, 255),false)

            end

            -- dxDrawRoundedRectangle(14 * scaleValue, (animations.offset-offset_roll), 500*scaleValue, 50*scaleValue, 10*scaleValue, tocolor ( 150, 84, 117, 255 ), false)

            -- dxDrawRectangle ( 1*scaleValue, (animations.offset-offset_roll), width + 50 * scaleValue, height + 10 *scaleValue, tocolor ( 50, 50, 50, 255 ), false )
            -- dxDrawRectangle ( animations.backGroundX, (animations.offset+260*scaleValue-offset_roll), width + 50 * scaleValue, height + 10 *scaleValue, tocolor ( 50, 50, 50, 255 ), false )
				

            if isCursorOnElement(animations.backGroundX,(animations.offset + 350 * scaleValue - offset_roll), width + 50 * scaleValue,height + 10 * scaleValue) then
                dxDrawText(nameAnim,14 * scaleValue,(animations.offset - offset_roll),animations.drawBackGroundX,animations.drawBackGroundY,tocolor(150, 84, 117, 255),1,animations.header,"left","top",false,false,false,false,false)
                animations.categoryTemp,animations.blockTemp,animations.updatePositionTemp,animations.animTemp,animations.animLoopTemp,animations.tempID,animations.customAnim,animations.commandNameTemp = v.category, v.block, v.updatePosition, v.anim, v.loop, k, v.customAnim, v.commandName
                if tableAnims[k]["clicked"] then
				tableAnims[k]["clicked"] = tableAnims[k]["clicked"] + 1
				end
				-- if scrollClick then
				-- for k,v in ipairs(favoriteAnims) do
				-- if v.animName == animations.commandNameTemp then
				-- table.remove(favoriteAnims, k)
				-- outputChatBox("Animacja została usunięta z ulubionych.")
				-- animations.addFavoriteAnimToTable(nil,true)
				-- Update()
				-- return
				-- end
				-- end
				-- end
				if rightclick then
				if #favoriteAnims == 10 then return outputChatBox("Limit zapisanych animacji dla gracza to 10."), Update() end
				for k,v in ipairs(favoriteAnims) do
				-- print(v.animName)
				if v.animName == animations.commandNameTemp then return outputChatBox("Ta animacja jest dodana juz do ulubionych"), Update() end -- usuwanie animacji 
				end
				outputChatBox("Dodano animacje "..v.commandName.." do ulubionych.")
				animations.addFavoriteAnimToTable(v.commandName)
				tableAnims[k]["clicked"] = 0
				end
                if tableAnims[k]["clicked"] == 2 then
                    v.used = true
                    tableAnims[k]["clicked"] = 0
                end
            else
                dxDrawText(nameAnim,14 * scaleValue,(animations.offset - offset_roll),animations.drawBackGroundX,animations.drawBackGroundY,tocolor(255, 255, 255, 255),1,animations.header,"left","top",false,false,false,false,false)
                v.used = false
                tableAnims[k]["clicked"] = 0
            end
            if loop then
                dxDrawText("Animacja ciągła",370 * scaleValue, (animations.offset - offset_roll + 10 * scaleValue),animations.drawBackGroundX,animations.drawBackGroundY,tocolor(255, 255, 255, 150),1,animations.header3,"left","top",false,false, false, false, false)
            end
            dxDrawText(v.desc,16 * scaleValue,(animations.offset - offset_roll + 25 * scaleValue),animations.drawBackGroundX,animations.drawBackGroundY,tocolor(255, 255, 255, animations.alpha),1,animations.header2,"left","top",false,false,false,false, false)

            animations.offset = animations.offset + 47 * scaleValue
        end
    end

    dxSetBlendMode("blend")

    dxSetRenderTarget()
end
itest = 0
countImages = 0
function placeImage()
    if itest == 0 then
        itest = 1
		countImages = countImages + 1
        return true
    elseif itest == 1 then
        itest = 0
		countImages = countImages + 1
        return false
    end
end

function animations.handleRestore(didClearRenderTargets)
    if didClearRenderTargets then
        Update()
    end
end
addEventHandler("onClientRestore", root, animations.handleRestore)

categories = {
    [1] = {
        offset = 0,
        -- icon = "stand.png",
		icon = dxCreateTexture("files/stand.png", "argb", true, "clamp", "2d"),
        text = "Stanie",
		size = false,
        used = false
    },
    [2] = {
        offset = 0,
        -- icon = "dance.png",
		icon = dxCreateTexture("files/dance.png", "argb", true, "clamp", "2d"),
        text = "Taniec",
		size = false,
        used = false
    },
    [3] = {
        offset = 0,
		icon = dxCreateTexture("files/running.png", "argb", true, "clamp", "2d"),
        -- icon = "running.png",
        text = "Chodzenie",
		size = false,
        used = false
    },
    [4] = {
        offset = 0,
		icon = dxCreateTexture("files/gang.png", "argb", true, "clamp", "2d"),
        -- icon = "gang.png",
        text = "Gang",
		size = false,
        used = true
    },
    [5] = {
        offset = 0,
		icon = dxCreateTexture("files/serce.png", "argb", true, "clamp", "2d"),
        -- icon = "serce.png",
        text = "Custom",
		size = false,
        used = false
    },
	 [6] = {
        offset = 0,
        -- icon = "sit.png",
		icon = dxCreateTexture("files/sit.png", "argb", true, "clamp", "2d"),
        text = "Siedzenie",
		size = false,
        used = false
    },
	 [7] = {
        offset = 0,
		icon = dxCreateTexture("files/lezenie.png", "argb", true, "clamp", "2d"),
        -- icon = "lezenie.png",
        text = "Leżenie",
		size = false,
        used = false
    }
	
}

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
                    used = false,
                    clicked = false,
                    id = id
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

function animations.bindIt()
if exports.rp_gainProject:PlayerHasEnabledGPGui() or getElementData(localPlayer,"loggedIn")  ~= 2 or exports.rp_items:isInventoryEnabled() then return end -- przy nowych zasobach, dodawac nowe exporty
 if not animations.showedFavAnims then
        addEventHandler("onClientRender", root, testRender)
    else
        removeEventHandler("onClientRender", root, testRender)

    end
    animations.showedFavAnims = not animations.showedFavAnims
end
bindKey( "3", "down", animations.bindIt )
function animations.scroll(button, state, absoluteX, absoluteY, worldX, worldY, worldZ, clickedElement)
if animations.showedFavAnims and button == "mouse_wheel_up" and not isMainMenuActive() and not isChatBoxInputActive() and not isConsoleActive() then
    if animations.currentSlotFavAnims > 1 and not animations.showedGui then
        favoriteAnims[animations.currentSlotFavAnims]["used"] = false

        animations.currentSlotFavAnims = animations.currentSlotFavAnims - 1
        favoriteAnims[animations.currentSlotFavAnims]["used"] = true
    end
elseif animations.showedFavAnims and button == "mouse_wheel_down" and not isMainMenuActive() and not isChatBoxInputActive() and not isConsoleActive() then
    if animations.currentSlotFavAnims < #favoriteAnims and not animations.showedGui then
        favoriteAnims[animations.currentSlotFavAnims]["used"] = false

        animations.currentSlotFavAnims = animations.currentSlotFavAnims + 1
        favoriteAnims[animations.currentSlotFavAnims]["used"] = true
    end
-- print(animations.currentSlotFavAnims)
end
if button == "mouse1" and state and animations.showedFavAnims and not animations.showedGui and not isMainMenuActive() and not isChatBoxInputActive() and not isConsoleActive() then
    if animations.currentSlotFavAnims >= 1 then
        if table.empty(favoriteAnims) then
            return
        end
        local anim = favoriteAnims[animations.currentSlotFavAnims]["animName"]
        local block
        local animT
        local animLoop
        local updatePosition
        local isCustom
        for k, v in ipairs(tableAnims) do
            if v.commandName == anim then
                block = v.block
                animT = v.anim
                animLoop = v.loop
                updatePosition = v.updatePosition
                isCustom = v.customAnim
                if isCustom then
				triggerServerEvent("animations->customAnimApply",localPlayer,localPlayer,v.commandName, updatePosition)
				else
				triggerServerEvent("animations->applyAnim",localPlayer,localPlayer,block,animT,animLoop,updatePosition)
				end
            end
        end
    end
end


if button == "escape" and animations.showedGui then
cancelEvent()
removeEventHandler("onClientRender", root, animations.renderAnimationsGui)
animations.showedGui = false
showCursor(false)
end
-- outputChatBox(animations.currentSlotFavAnims)
if button == "mouse1" and state and animations.showedGui and isCursorOnElement( animations.backGroundX + 458 * scaleValue,animations.backGroundY + 10 * scaleValue, 32*scaleValue,32*scaleValue) then
			removeEventHandler("onClientRender", root, animations.renderAnimationsGui)
			animations.showedGui = false
			setTimer ( function()
			showCursor(false)
			end, 100, 1 )
end
    if animations.showedGui then
        if button == "mouse_wheel_down" and state then
            if count < animations.getNumberAnimations then
			-- print(animations.getNumberAnimations)
                count = count + 1
                offset_roll = offset_roll + 47 * scaleValue
                Update()
            end
        elseif button == "mouse_wheel_up" and state then
            if count > 0 then
                count = count - 1
                offset_roll = offset_roll - 47 * scaleValue
                Update()
            end
			
        elseif button == "mouse1" and state then
            Update()
			
            if isCursorOnElement(animations.backGroundX, animations.backGroundY + 390 * scaleValue,500 * scaleValue,50 * scaleValue) then
                --  outputChatBox(animations.categoryTargetting)
                animations.currentCategory = animations.categoryTargetting
                Update()
				local how = 0
				for k,v in ipairs(tableAnims) do
				if v.category == animations.currentCategory then
				how = how + 1
				end
				end
				animations.getNumberAnimations = how
                local id
                local newId
                local oldIcon
                local oldText
                local nowIcon
                local nowText

                for k, v in ipairs(categories) do
                    if categories[k]["used"] == true then
                        id = k
                        -- oldText = v.text
                        -- oldIcon = v.icon
                    end
                end
                for k, v in ipairs(categories) do
                    if animations.categoryTargetting == v.text then
                        categories[id]["used"] = false
                        newId = k
                        -- nowIcon = v.icon --
                        -- nowText = v.text --  

                        -- categories[newId]["icon"] = oldIcon
                        -- categories[newId]["text"] = oldText
                        -- categories[id]["icon"] = nowIcon
                        -- categories[id]["text"] = nowText
                        categories[newId]["used"] = true
                        count = 0
                        offset_roll = 0
						countImages = 0
                        Update()
                    end
                end
            end
        elseif isCursorOnElement(animations.backGroundX,animations.backGroundY + 53 * scaleValue,animations.renderTargetX,animations.renderTargetY) and animations.animTemp and tableAnims[animations.tempID]["used"] == true then
			if animations.customAnim then
			-- print("customowa")
			triggerServerEvent("animations->customAnimApply",localPlayer,localPlayer,animations.commandNameTemp, animations.updatePosition or animations.updatePositionTemp)
			-- triggerServerEvent("animations->customAnimApply",localPlayer,localPlayer,animations.blockTemp,animations.animTemp,animations.animLoopTemp,animations.updatePosition)
			else
			if getElementData(localPlayer,"customAnim->anim") then 
			setElementData(localPlayer,"customAnim->anim", false) 
			-- print("delete")
			end
			triggerServerEvent("animations->applyAnim",localPlayer,localPlayer,animations.blockTemp,animations.animTemp,animations.animLoopTemp,animations.updatePosition or animations.updatePositionTemp)
			end
            animations.blockTemp, animations.animTemp, animations.animLoopTemp, animations.updatePosition, animations.customAnim = false,false,false,false,false
		elseif button == "mouse2" and state then -- add animation to favorite
			Update(1)
		-- elseif button == "mouse3" and state and animations.showedFavAnims then
		-- outputChatBox("clicked")
		-- for k,v in ipairs(favoriteAnims) do
		-- print(k)
				-- if k == animations.currentSlotFavAnims then
				-- table.remove(favoriteAnims, k)
				-- outputChatBox("Animacja została usunięta z ulubionych.")
				-- animations.addFavoriteAnimToTable(nil,true)
				-- end
				-- end
		-- outputChatBox("scroll")
		-- Update(nil,2)
		
        end
    end
end
addEventHandler("onClientKey", root, animations.scroll)



function animations.favAnimsKey(button, state)
if button == "mouse3" and state and animations.showedFavAnims and not animations.showedGui then
if exports.rp_gainProject:PlayerHasEnabledGPGui() or getElementData(localPlayer,"loggedIn")  ~= 2 or exports.rp_items:isInventoryEnabled() then return end -- przy nowych zasobach, dodawac nowe exporty
local id = animations.currentSlotFavAnims
for k,v in ipairs(favoriteAnims) do
if k == id then
-- print(k, id)
animations.currentSlotFavAnims = animations.currentSlotFavAnims - 1
if k == 1 then
favoriteAnims[k]["used"] = true
animations.currentSlotFavAnims = 1
else
favoriteAnims[k-1]["used"] = true

end
table.remove(favoriteAnims,k)
animations.addFavoriteAnimToTable(nil, true)

end
end
cancelEvent()
end
end
addEventHandler("onClientKey", root, animations.favAnimsKey)


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


function animations.commandDeleteFavAnimations()
favoriteAnims = {}
end
addCommandHandler("usunulubioneanimacje", animations.commandDeleteFavAnimations, false, false)

function table.empty (self)
    for _, _ in pairs(self) do
        return false
    end
    return true
end
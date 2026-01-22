local table3dTexts = {}
local drawing = false
addEventHandler(
    "onClientElementStreamIn",
    root,
    function()
        if getElementType(source) == "marker" then
            setTimer(add3dText, 500, 1, source)
            -- if not drawing then
                -- drawing = true
                -- addEventHandler("onClientRender", root, render3DTexts)
            -- end
        end
    end
)

function add3dText(marker)
    local data = exports.rp_login:getObjectData(marker, "3DText")
    if data then
        table3dTexts[marker] = data
    end
end


local arrow = dxCreateTexture("files/arrow.png") -- przykładowa tekstura
local light = dxCreateTexture("files/light.png") -- przykładowa tekstura
local distance = 50

local animTime = getTickCount()
local anim_type = "back"
local position = 0

addEventHandler("onClientPreRender", root,
    function()
        local now = getTickCount()

        for i, v in ipairs(getElementsByType("marker")) do
			if getElementAlpha(v) == 0  then

            local x, y, z = getElementPosition(v)
            local x2, y2, z2 = getElementPosition(localPlayer)
            local r, g, b, a = getMarkerColor(v)
            local distanceBetweenPoints = getDistanceBetweenPoints3D(x, y, z, x2, y2, z2)
		
            if distanceBetweenPoints < distance then
                local distanceFactor = 1 - (distanceBetweenPoints / distance)
                local finalAlpha = math.floor(255 * distanceFactor)

                local size = getMarkerSize(v)
				if size < 0.9 then return end
                if anim_type == "back" then
                    local progress = (now - animTime) / 1500
                    position = math.floor(interpolateBetween(0, 0, 0, 200, 0, 0, progress, "InQuad"))
                    if(progress > 1) then
                        anim_type = "foward"
                        animTime = now
                    end
                else
                    local progress = (now - animTime) / 1500
                    position = math.floor(interpolateBetween(200, 0, 0, 0, 0, 0, progress, "OutQuad"))
                    if(progress > 1) then
                        anim_type = "back"
                        animTime = now
                    end
                end
				
                dxDrawMaterialLine3D(x, y, z+1+1+(position/1000), x, y, z+1+(position/1000), arrow, 1, tocolor(r, g, b, finalAlpha))
                dxDrawMaterialLine3D(x+size, y+size, z+0.04, x-size, y-size, z+0.04, light, size*3, tocolor(r, g, b, math.floor(finalAlpha * 0.6)), x, y, z)
				
                local text = table3dTexts[v]
                if text then
                    local scale = 0.5 + 0.7 * distanceFactor  -- skala od 0.5 (daleko) do 1.2 (blisko)
                    local screenX, screenY = getScreenFromWorldPosition(x, y, z + size + 1 + (position / 1000))
					local cx, cy, cz = getCameraMatrix()
                    if isLineOfSightClear(cx, cy, cz, x, y, z, true, false, false, true, false, false, false) then
                    if screenX and screenY then
                        dxDrawText(
                            text,
                            screenX, screenY,
                            screenX, screenY,
                            tocolor(r, g, b, finalAlpha),
                            scale, "default-bold",
                            "center", "bottom",
                            false, false, false,
                            true
                        )
                    end
                end
            end
        end
		end
		end
    end
)


function countMarkers()
    local count = 0

    for k, v in pairs(table3dTexts) do
        count = count + 1
    end
    return count
end

addEventHandler(
    "onClientElementStreamOut",
    root,
    function()
        if getElementType(source) == "marker" then
            table3dTexts[source] = nil
            local count = countMarkers()
            -- if count == 0 and drawing then
                -- removeEventHandler("onClientRender", root, render3DTexts)
                -- drawing = false
            -- end
        end
    end
)

addEventHandler(
    "onClientElementDestroy",
    root,
    function()
        if getElementType(source) == "marker" then
            table3dTexts[source] = nil
            -- if count == 0 and drawing then
                -- removeEventHandler("onClientRender", root, render3DTexts)
                -- drawing = false
            -- end
        end
    end
)

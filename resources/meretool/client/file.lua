local fileRequests = {}
local showProgress = false

function requestPNGFile(mapName, fileName, texture_key, texture_name)
    local path = getPath(mapName, fileName)
    if (fileRequests[path]) then return end

    fileRequests[path] = {
        mapName = mapName,
        name = fileName,
        bytesReceived = 0,
        totalBytes = 0,
        key = texture_key,
        texture_name = texture_name
    }
    updateGUI()
    triggerServerEvent("mereRequestFile", getLocalPlayer(), path)
end

-- Receive final file
addEvent("mereReceiveFile", true)
addEventHandler("mereReceiveFile", resourceRoot, function(path, data)
    if not fileRequests[path] then return end

    if not data then
        fileRequests[path] = nil
        return
    end



    local texture_name = fileRequests[path]["texture_name"]
    local texture_key = fileRequests[path]["key"]
    local mapName = fileRequests[path]["mapName"]
    local file_name = fileRequests[path]["name"]
    local received_md5 = md5(data)

    writePNGFile(mapName, file_name, data)

    fileRequests[path] = nil


    if (TEXTURES_DATA[texture_name][texture_key] and TEXTURES_DATA[texture_name][texture_key]["DATA"]) then
        if (not TEXTURES_DATA[texture_name][texture_key]["DATA"]["MD5"]) then return end;
        if (TEXTURES_DATA[texture_name][texture_key]["DATA"]["MD5"] == received_md5) then
            local data = TEXTURES_DATA[texture_name][texture_key]
            if (texture_key == all_key) then return applyShader(nil, data["TYPE"], texture_name, data["DATA"], true) end
            for ID in pairs(data["ELEMENTS_IDS"]) do
                local element = getElementByID(ID)
                if (isElement(element)) then
                    applyShader(element, data["TYPE"], texture_name, data["DATA"], false)
                end
            end
            -- else
            --     mereOutput(file_name .. " found but it's changed in the server!")
        end
    end
    updateGUI()
end)


function isRequesting(mapName, fileName)
    local path = getPath(mapName, fileName)
    return fileRequests[path] and true or false
end

function requestCancel(mapName, fileName)
    local path = getPath(mapName, fileName)
    if not fileRequests[path] then return end
    fileRequests[path] = nil
    triggerServerEvent("onClientCancelFile", getLocalPlayer(), path)
end

function requestCancelAll()
    for path in pairs(fileRequests) do
        requestCancel(fileRequests[path].mapName, fileRequests[path].name)
    end
end

-- Receive progress updates
addEvent("onUpdateFileProgress", true)
addEventHandler("onUpdateFileProgress", resourceRoot, function(path, percent, total)
    if not fileRequests[path] then return end
    local received = math.floor(total * percent / 100)

    fileRequests[path].bytesReceived = received
    fileRequests[path].totalBytes = total


    showProgress = true

    local done = tableSize(fileRequests) == 0

    if done then
        setTimer(function() showProgress = false end, 3000, 1)
    end
end)



addEventHandler("onClientRender", root, function()
    if not showProgress then return end

    local totalReceived, totalSize, fileCount = 0, 0, 0
    for _, data in pairs(fileRequests) do
        totalReceived = totalReceived + (data.bytesReceived or 0)
        totalSize = totalSize + (data.totalBytes or 0)
        fileCount = fileCount + 1
    end

    if totalSize == 0 then return end

    local sx, sy = guiGetScreenSize()
    local barWidth = 400
    local x = (sx - barWidth) / 2
    local y = sy - 100

    local mbReceived = totalReceived / (1024 * 1024)
    local mbTotal = totalSize / (1024 * 1024)
    local text = string.format("Downloading [%d file%s]  %.4f MB / %.4f MB",
        fileCount, fileCount ~= 1 and "s" or "", mbReceived, mbTotal)

    dxDrawText(text, x, y - 24, x + barWidth, y, tocolor(255, 255, 255, 255), 1.2, "default-bold", "center", "bottom")
end)



------------------------------------------------
------------------------------------------------
------------------------------------------------
----CACHE
